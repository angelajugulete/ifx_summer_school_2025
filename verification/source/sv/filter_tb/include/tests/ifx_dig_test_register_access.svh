/******************************************************************************
 * (C) Copyright 2025 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT: SUMMER_SCHOOL_2025
 * AUTHOR:
 * DATE:
 * FILE:
 * REVISION:
 *
 * FILE DESCRIPTION:
 * Testcase will write and read in all the register space.
 * Write all 1's then read, write all 0's then read, write random value and read.
 *
 * Perform a reset and then read all registers.
 *
 *******************************************************************************/

class ifx_dig_test_register_access extends ifx_dig_testbase;

    `uvm_component_utils(ifx_dig_test_register_access)


    //=========================================================================
    // Sequences and variables.

    //=========================================================================
    // Test controls.
    //-------------------------------------------------------------------------
    //=========================================================================

    int reg_addresses[$]; // contains the addresses of the registers to be tested

    //=========================================================================
    // Functions and phases.
    //-------------------------------------------------------------------------
    //=========================================================================

    function new(string name = "ifx_dig_test_register_access", uvm_component parent);
        super.new(name, parent);
        // create the sequences using factory
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

    endfunction : build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
    endtask

    task main_phase(uvm_phase phase);

        phase.raise_objection(this);

        super.main_phase(phase); // call default main phase, contains reset
        `TEST_INFO("Main phase started")
        `WAIT_US(10)

        for(int idx = 0; idx < 2**`AWIDTH; idx++) begin
            reg_addresses.push_back(idx);
        end

        // write all 1's to all registers
        reg_addresses.shuffle(); // random order of registers
        foreach(reg_addresses[idx]) begin
            `TEST_INFO($sformatf("Writing all 1's to register at address: %0d then read back the data", reg_addresses[idx]))
            data_bus_write_seq.address = reg_addresses[idx];
            data_bus_write_seq.data    = 8'hFF;                           // all 1's
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer); // will start on the data bus UVC sequencer

            data_bus_read_seq.address = reg_addresses[idx]; // what register is this?
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
        end

        // write all 0's to all registers
        reg_addresses.shuffle(); // random order of registers
        foreach(reg_addresses[idx]) begin
            `TEST_INFO($sformatf("Writing all 0's to register at address: %0d then read back the data", reg_addresses[idx]))
            data_bus_write_seq.address = reg_addresses[idx];
            data_bus_write_seq.data    = 8'h00;                           // all 0's
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer); // will start on the data bus UVC sequencer

            data_bus_read_seq.address = reg_addresses[idx]; // what register is this?
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
        end

        // write random value to all registers
        reg_addresses.shuffle(); // random order of registers
        foreach(reg_addresses[idx]) begin
            `TEST_INFO($sformatf("Writing random value to register at address: %0d then read back the data", reg_addresses[idx]))
            data_bus_write_seq.address = reg_addresses[idx];
            data_bus_write_seq.data    = `RAND_8BIT;                        // random value
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer);   // will start on the data bus UVC sequencer

            data_bus_read_seq.address = reg_addresses[idx]; // what register is this?
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
        end

        // perform a reset and read all registers
        `TEST_INFO("Performing a reset and reading all registers")
        drive_reset();
        `WAIT_US(10)             // let DUT reinitialize
        reg_addresses.shuffle(); // random order of registers
        foreach(reg_addresses[idx]) begin
            `TEST_INFO($sformatf("Reading register at address: %0d", reg_addresses[idx]))
            data_bus_read_seq.address = reg_addresses[idx]; // what register is this?
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
        end



        phase.drop_objection(this);
    endtask

endclass
