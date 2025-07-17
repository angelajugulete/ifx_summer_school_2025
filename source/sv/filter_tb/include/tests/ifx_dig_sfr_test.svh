/**************************
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
 *
 ***************************/

class ifx_dig_sfr_test extends ifx_dig_testbase;

    `uvm_component_utils(ifx_dig_sfr_test)

    function new(string name = "ifx_dig_sfr_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `TEST_INFO("Run phase started")
    endtask

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);

        super.main_phase(phase); // call default main phase, contains reset

        `TEST_INFO("Main phase started")

        for (int addr=0; addr < 2**`AWIDTH; addr++) begin

            `TEST_INFO($sformatf("Write all 1's to address %b", addr))
            data_bus_write_seq.address = addr;
            data_bus_write_seq.data = 8'hFF;
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer);
            
            `WAIT_NS(20)

            `TEST_INFO($sformatf("Read from address %b", addr))
            data_bus_read_seq.address = addr;
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);

            `WAIT_NS(100)

            `TEST_INFO($sformatf("Write all 0's to address %b", addr))
            data_bus_write_seq.address = addr;
            data_bus_write_seq.data = 8'h00;
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer);

            `TEST_INFO($sformatf("Read from address %b", addr))
            data_bus_read_seq.address = addr;
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);


            `WAIT_NS(100)

            `TEST_INFO($sformatf("Write random value to address %b", addr))
            data_bus_write_seq.address = addr;
            data_bus_write_seq.data = $urandom;
            data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer);

            `TEST_INFO($sformatf("Read from address %b", addr))
            data_bus_read_seq.address = addr;
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);

            `WAIT_NS(500)
        end

        `TEST_INFO("Driving a reset pulse")
        drive_reset();
        `WAIT_NS(100)
        for (int addr=0; addr < 2**`AWIDTH; addr++) begin
            `TEST_INFO($sformatf("Read from address %b", addr))
            data_bus_read_seq.address = addr;
            data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);
            `WAIT_NS(20)
        end

        phase.drop_objection(this);
    endtask

endclass