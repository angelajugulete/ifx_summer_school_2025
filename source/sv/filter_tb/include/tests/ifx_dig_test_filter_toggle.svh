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
    //parametrii mei random
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

        super.main_phase(phase); // call default main phase, aveam reset initial

        `TEST_INFO("Main phase started")

        // create a random order of the filters to be tested
        for(int ifilt = 1; ifilt <= `FILT_NB; ifilt++) begin
            filter_list.push_back(ifilt);
        end
        filter_list.shuffle();


          // TODO: go through the filters and test them as described in requirement
        foreach(filter_list[idx]) begin

            `TEST_INFO($sformatf("Test filter %0d", filter_list[idx]))
            configure_filter(
                .filt_idx(filter_list[idx]),
                .int_en(0)
            );

            `TEST_INFO($sformatf("Driving a valid pulse on filter %0d", filter_list[idx]))
            pin_filter_valid_pulse_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[idx] - 1]);
            //foreach ca sa parcurg filtrele, TEST_INFO si il configurez random
                    //apoi pun cond de filtru valid , l am mai folosit
                    //dupa citesc statusurile si asteptam 100ns
            read_filter_status(0);
            `WAIT_NS(100)
        end

        phase.drop_objection(this);
    endtask
/* Second option: configure the filter with random parameters
            this.randomize(); //this este pointer catre obiect
            write_reg_fields(
                .reg_name($sformatf("FILTER_CTRL%0d", filter_list[idx])),
                .fields_names({"WD_RST", "WINDOW_SIZE", "FILTER_TYPE"}),
                .fields_values({filter_reset, window_size, filter_type})
            );
       */
endclass
   