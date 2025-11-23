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
 * This is intended to showcase the usage of the register model with it's built in functions as well as
 * various sequences and methods to read and write registers.
 * This test does not test the DUT!
 *
 * The test will:
 * - Print all register values.
 * - Print all fields values.
 * - Get register by name and address.
 * - Getting register name by address.
 * - Getting LSB and MSB position of a field.
 * - Getting size of a field.
 * - Predicting field value.
 * - Writing a register value and getting register value.
 * - Writing a register directly through the sequence.
 * - Writing a register through the testbase task.
 * - Reading a register directly through the sequence.
 * - Reading a register through the testbase task.
 *
 *******************************************************************************/

class ifx_dig_test_regmodel_showcase extends ifx_dig_testbase;

    `uvm_component_utils(ifx_dig_test_regmodel_showcase)

    ifx_dig_reg reg1;
    ifx_dig_reg reg2;

    string reg1_name;
    string reg2_name;

    int reg_value;

    //=========================================================================
    // Sequences and variables.

    //=========================================================================
    // Test controls.
    //-------------------------------------------------------------------------
    //=========================================================================

    //=========================================================================
    // Functions and phases.
    //-------------------------------------------------------------------------
    //=========================================================================

    function new(string name = "ifx_dig_test_regmodel_showcase", uvm_component parent);
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

        //Print all register values
        `uvm_info(get_name(), $sformatf("Size of filter_ctrl %0d", $size(regblock.FILTER_CTRL)), UVM_NONE)
        for(int i = 0; i < $size(regblock.FILTER_CTRL); i++)begin
            `uvm_info(get_name(), $sformatf("Value for FILTER_CTRL%0d = 0x%0h, address %0d.", i+1, regblock.FILTER_CTRL[i].get_reg_value(), regblock.FILTER_CTRL[i].get_address()), UVM_NONE)
        end

        for(int i = 0; i < $size(regblock.INT_STATUS); i++)begin
            `uvm_info(get_name(), $sformatf("Value for INT_STATUS%0d = 0x%0h, address %0d.", i+1, regblock.INT_STATUS[i].get_reg_value(), regblock.INT_STATUS[i].get_address()), UVM_NONE)
        end

        //Print all fields values
        for(int i = 0; i < $size(regblock.FILTER_CTRL); i++)begin
            for(int j = 0; j < $size(regblock.FILTER_CTRL[i].fields_list); j++)
                `uvm_info(get_name(), $sformatf("Register FILTER_CTRL[%0d] field %s[%0d] value %0d.", i, regblock.FILTER_CTRL[i].fields_list[j].get_name(), j, regblock.FILTER_CTRL[i].fields_list[j].get_value()), UVM_NONE)
        end

        for(int i = 0; i < $size(regblock.INT_STATUS); i++)begin
            for(int j = 0; j < $size(regblock.INT_STATUS[i].fields_list); j++)
                `uvm_info(get_name(), $sformatf("Register INT_STATUS[%0d] field %s[%0d] value %0d.", i, regblock.INT_STATUS[i].fields_list[j].get_name(), j, regblock.INT_STATUS[i].fields_list[j].get_value()), UVM_NONE)
        end


        //Get reg by name
        reg1 = regblock.get_reg_by_name("FILTER_CTRL1");
        reg2 = regblock.get_reg_by_name("INT_STATUS2");
        `uvm_info(get_name(), $sformatf("Register1 name %0s.", reg1.get_name()), UVM_NONE)
        `uvm_info(get_name(), $sformatf("Register2 name %0s.", reg2.get_name()), UVM_NONE)

        //Get reg by address
        reg1 = regblock.get_reg_by_address(5);  // this returns FILTER_CTRL6
        reg2 = regblock.get_reg_by_address(20); // this returns NULL as there is no register at address 20
        `uvm_info(get_name(), $sformatf("Register1 %p.", reg1), UVM_NONE)
        `uvm_info(get_name(), $sformatf("Register2 %p.", reg2), UVM_NONE)

        //Get reg name by address
        reg1_name = regblock.get_reg_name_by_address(16); // this returns INT_STATUS2
        reg2_name = regblock.get_reg_name_by_address(22); // this returns "" as there is no register at address 22
        `uvm_info(get_name(), $sformatf("Register1 name %0s.", reg1_name), UVM_NONE)
        `uvm_info(get_name(), $sformatf("Register2 name %0s.", reg2_name), UVM_NONE)



        //Get LSB position
        `uvm_info(get_name(), $sformatf("Register FILTER_CTRL10 WD_RST LSB position %0d.", regblock.get_reg_by_name("FILTER_CTRL10").get_field_by_name("WD_RST").get_lsb_possition()), UVM_NONE)
        // Get MSB position
        `uvm_info(get_name(), $sformatf("Register FILTER_CTRL10 WD_RST MSB position %0d.", regblock.get_reg_by_name("FILTER_CTRL10").get_field_by_name("WD_RST").get_msb_possition()), UVM_NONE)
        // get number of bits in a field
        `uvm_info(get_name(), $sformatf("Register FILTER_CTRL10 WD_RST size %0d.", regblock.get_reg_by_name("FILTER_CTRL10").get_field_by_name("WD_RST").get_size()), UVM_NONE)


        /*
         * NOTE: Predict vs Write
         * - Predict is used to predict the value of a field/register as a result of an internal event (e.g. interrupt). Therefore is mostly used for updating values in status registers
         * - Write is used to write a value to a field/register as a result of an external event, usually only after a write access through the register access protocol
         */

        //Predict field value - NOTE: all register prediction must be done inside scoreboard - this is just an example
        regblock.predict_field_value("INT_STATUS1", "IN2_INT", 1);
        `uvm_info(get_name(), $sformatf("Register field INT_STATUS1.IN2_INT %0d.", regblock.get_field_value("INT_STATUS1", "IN2_INT")), UVM_NONE)

        //Predict field value - NOTE: all register prediction must be done inside scoreboard - this is just an example
        regblock.predict_field_value("FILTER_CTRL8", "WD_RST", 1);
        `uvm_info(get_name(), $sformatf("Register field FILTER_CTRL8.WD_RST %0d.", regblock.get_field_value("FILTER_CTRL8", "WD_RST")), UVM_NONE)


        //Write register value and get register value
        reg_value = regblock.get_reg_value("FILTER_CTRL10");
        `uvm_info(get_name(), $sformatf("FILTER_CTRL10 before write operation 0x%0h.", reg_value), UVM_NONE)
        regblock.write_reg_value("FILTER_CTRL10", 'hAB);
        reg_value = regblock.get_reg_value("FILTER_CTRL10");
        `uvm_info(get_name(), $sformatf("FILTER_CTRL10 after write operation 0x%0h.", reg_value), UVM_NONE)



        // Writing a register directly through the sequence - sequence is already defined in testbase
        data_bus_write_seq.address = 4;                               // what register is this?
        data_bus_write_seq.data    = 8'hBC;                           // you write to all the fields all at once. What if you want to write only a specific field and keep others values?
        data_bus_write_seq.start(dig_env.data_bus_uvc_agt.sequencer); // will start on the data bus UVC sequencer

        //Write register thorough the very useful testbase task
        write_reg_fields(
            .reg_name("FILTER_CTRL10"),                    // very clear what register will be written
            .fields_names({"FILTER_TYPE", "WINDOW_SIZE"}), // you can write multiple fields at once
            .fields_values({2, 5}),                        // you can write multiple fields at once - only the fields that are selected will be written, others will keep their values
            .read_after_write(1)                           // read register after write operation
        );


        //Read a register directly through the sequence - sequence is already defined in testbase
        data_bus_read_seq.address = 0; // what register is this?
        data_bus_read_seq.start(dig_env.data_bus_uvc_agt.sequencer);

        //Read register thorough the very useful testbase task
        read_reg("FILTER_CTRL10");

        `WAIT_US(1000)

        phase.drop_objection(this);
    endtask

endclass
