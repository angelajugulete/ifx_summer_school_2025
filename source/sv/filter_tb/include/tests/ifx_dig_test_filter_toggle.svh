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
 *
 *******************************************************************************/

class ifx_dig_test_filter_toggle extends ifx_dig_testbase;

    `uvm_component_utils(ifx_dig_test_filter_toggle)


    // Test variables
    int filter_list[$]; // contains the indexes of the filters to be tested

    rand filt_type_t filter_type;
    rand filt_reset_t filter_reset;
    rand bit [3:0] window_size;

    function new(string name = "ifx_dig_test_filter_toggle", uvm_component parent);
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

        // create a random order of the filters to be tested
        for(int ifilt = 1; ifilt <= `FILT_NB; ifilt++) begin
            filter_list.push_back(ifilt);
        end
        filter_list.shuffle();


        // TODO: go through the filters and test them as described in requirement



        phase.drop_objection(this);
    endtask

endclass
