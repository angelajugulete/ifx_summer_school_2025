/******************************************************************************
 * (C) Copyright 2020 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT:
 * AUTHOR:
 * DATE:
 * FILE:
 * REVISION:
 *
 * FILE DESCRIPTION:
 *
 *******************************************************************************/

class ifx_dig_testbase extends uvm_test;

    `uvm_component_utils(ifx_dig_testbase)

    ifx_dig_config          dig_cfg;

    // HINT --  add here declaration for dig_env
    ifx_dig_env             dig_env;

    ifx_dig_regblock regblock;

    //=========================================================================
    // Sequences.
    //-------------------------------------------------------------------------
    //=========================================================================

    // data bus UVC sequences
    ifx_dig_data_bus_uvc_sequence data_bus_seq;
    ifx_dig_data_bus_uvc_write_sequence data_bus_write_seq;
    ifx_dig_data_bus_uvc_read_sequence data_bus_read_seq;

    // filter UVC sequences
    ifx_dig_pin_filter_uvc_pulse_sequence pin_filter_pulse_seq;
    ifx_dig_pin_filter_uvc_generic_sequence pin_filter_generic_seq;
    ifx_dig_pin_filter_uvc_invalid_pulse_train_sequence pin_filter_invalid_pulse_train_seq;

    //=========================================================================
    // Variables.
    //-------------------------------------------------------------------------
    //=========================================================================

    uvm_report_server report_server;// used to display relevant info at the end of the test
    //=========================================================================
    // Methods.
    //-------------------------------------------------------------------------
    //=========================================================================
    extern function new(string name = "ifx_dig_testbase", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);

//=========================================================================
// GENERAL METHODS for STIMULI.
//-------------------------------------------------------------------------
//=========================================================================

    /*
     * task used to write the specific fields of a register with given values
     */
    extern task write_reg_fields(string reg_name, string fields_names[]={}, int fields_values[]={}, read_after_write = 0);

    /*
     * task used to read a register given as argument
     */
    extern task read_reg(string reg_name);

    /*
     * task used to drive the reset signal of the digital interface for a given period of time
     */
    extern virtual task drive_reset(int reset_duration_ns = 100, bit use_clock_cycle = 0, int numb_of_clocks = 3);

    /*
     * task used to configure a filter with the given parameters
     * Default configuration is random
     */
    extern virtual task configure_filter(
        int filt_idx,                                         // index of the filter to be configured
        filt_reset_t wd_rst      = filt_reset_t'(`RAND_1BIT), // reset type: asynchronous or synchronous
        bit int_en               = `RAND_1BIT,                // interrupt enable: 1 to enable, 0 to disable
        int window_size          = `RAND_4BIT,                // selection of the filter length
        filt_type_t filter_type  = filt_type_t'(`RAND_2BIT)   // filter type: rising, falling, both edges, or disabled
    );

    /*
     * task used to read the status of a filter
     * if filt_idx = 0, all status registers are read
     */
    extern virtual task read_filter_status(int filt_idx = 0);

    /*
     * task used to clear the status of a filter
     * if filt_idx = 0, all status registers are cleared, one by one
     */
    extern virtual task clear_filter_status(int filt_idx = 0);

endclass: ifx_dig_testbase


//=========================================================================
// Method implementation.
//-------------------------------------------------------------------------
//=========================================================================
function ifx_dig_testbase::new(
        string        name   = "ifx_dig_testbase",
        uvm_component parent = null
    );
    super.new(name, parent);
endfunction : new


task ifx_dig_testbase::reset_phase(uvm_phase phase);
endtask : reset_phase

// Hook that can be overloaded in sub-classes to add configuration statements
//-----------------------------------------------------------------------------

function void ifx_dig_testbase::build_phase(uvm_phase phase);
    super.build_phase(phase);

    //------------------=====================================---------------
    //-=========================- CREATE CONFIGURATION OBJECT -=========================-
    //------------------=====================================---------------
    dig_cfg = ifx_dig_config::type_id::create("dig_cfg", this);

    //------------------=====================================---------------
    //-=========================- INTERFACE GET -=========================-
    //------------------=====================================---------------
    //-----------Digital interface-----------
    if (!uvm_config_db#(virtual ifx_dig_interface)::get(this, "", "dig_if", dig_cfg.dig_vif))
        `uvm_fatal("TEST_BASE/NOVIF", "No virtual interface specified for TEST BASE")

    //------------------=====================================---------------
    //-=========================- CREATE ENV  -=========================-
    //------------------=====================================---------------
    dig_env = ifx_dig_env::type_id::create("dig_env", this);

    //------------------=====================================---------------
    //-=========================- SET CONFIGURATION OBJECTS -=========================-
    //------------------====================/******************************************************************************=================---------------
    uvm_config_db #(ifx_dig_config)::set(this, "*", "p_dig_cfg", dig_cfg);

    //  configuration objects for their corresponding agents
    uvm_config_db #(ifx_dig_data_bus_uvc_config)::set(uvm_top, "data_bus_uvc_agt" , "cfg", dig_cfg.data_bus_uvc_cfg);
    for (int i = 0; i < `FILT_NB; i++) begin
        uvm_config_db #(ifx_dig_pin_filter_uvc_config)::set(uvm_top, $sformatf("pin_filter_uvc_agt_[%0d]", i), "cfg", dig_cfg.pin_filter_uvc_cfg[i]);
    end

    //------------------=====================================---------------
    //-=========================- CREATE SEQUENCES -=========================-
    //------------------=====================================---------------

    data_bus_seq        = ifx_dig_data_bus_uvc_sequence::type_id::create("data_bus_seq", this);
    data_bus_read_seq   = ifx_dig_data_bus_uvc_read_sequence::type_id::create("data_bus_read_seq", this);
    data_bus_write_seq  = ifx_dig_data_bus_uvc_write_sequence::type_id::create("data_bus_write_seq", this);

    pin_filter_pulse_seq               = ifx_dig_pin_filter_uvc_pulse_sequence::type_id::create("pin_filter_pulse_seq", this);
    pin_filter_generic_seq             = ifx_dig_pin_filter_uvc_generic_sequence::type_id::create("pin_filter_generic_seq", this);
    pin_filter_invalid_pulse_train_seq = ifx_dig_pin_filter_uvc_invalid_pulse_train_sequence::type_id::create("pin_filter_invalid_pulse_train_seq", this);

    regblock = ifx_dig_regblock::type_id::create("regblock");
    regblock.build();
endfunction : build_phase

function void ifx_dig_testbase::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

// add necessary connections
endfunction

function void ifx_dig_testbase::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // stop running after 1000 error
    set_report_severity_action_hier(UVM_ERROR, UVM_DISPLAY | UVM_COUNT);
    report_server = get_report_server();
    report_server.set_max_quit_count(1000);

endfunction: end_of_elaboration_phase


function void ifx_dig_testbase::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);

endfunction : start_of_simulation_phase

task ifx_dig_testbase:: run_phase(uvm_phase phase);
    super.run_phase(phase);
endtask : run_phase

task ifx_dig_testbase::main_phase(uvm_phase phase);
    super.main_phase(phase);

    // drive an initial reset to initialize the DUT
    drive_reset(100);
endtask : main_phase

//=========================================================================
// GENERAL METHODS for STIMULI.
//-------------------------------------------------------------------------
//=========================================================================

/*
 * task used to write the specific fields of a register with given values
 */
task ifx_dig_testbase::write_reg_fields(string reg_name, string fields_names[]={}, int fields_values[]={}, read_after_write = 0);
    ifx_dig_data_bus_uvc_write_sequence write_seq;
    ifx_dig_reg reg_obj = dig_env.scoreboard.regblock.get_reg_by_name(reg_name);

    write_seq         = ifx_dig_data_bus_uvc_write_sequence::type_id::create("write_seq", this);
    write_seq.address = reg_obj.get_address();
    write_seq.data    = reg_obj.get_reg_value();
    `uvm_info("DEBUG", $sformatf("Reg value before write = %b", write_seq.data), UVM_MEDIUM)

    foreach(fields_names[idx]) begin
        ifx_dig_field field_obj = reg_obj.get_field_by_name(fields_names[idx]);
        int field_val           = (2**field_obj.get_size() -1) & fields_values[idx];
        for(int pos=0 ;pos<=field_obj.get_size()-1; pos++) begin
            write_seq.data[pos+field_obj.get_lsb_possition()] = field_val[pos];
        end
    end
    `uvm_info("write_reg_fields", $sformatf("Write register %s fields %p with values %p", reg_name, fields_names, fields_values), UVM_NONE)
    write_seq.start(dig_env.data_bus_uvc_agt.sequencer);

    if(read_after_write)
        read_reg(reg_name);

endtask

/*
 * TODO: Implement wrapper task used to read a register given as argument
 */
task ifx_dig_testbase::read_reg(string reg_name);
    ifx_dig_data_bus_uvc_read_sequence read_seq;


    `uvm_info("read_reg", $sformatf("Read register %s", reg_name), UVM_NONE)

endtask

/*
 * TODO: Implement task used to drive the reset signal of the digital interface for a given period of time
 * or for for a given number of clock, cycles.
 */
task ifx_dig_testbase::drive_reset(int reset_duration_ns = 100, bit use_clock_cycle = 0, int numb_of_clocks = 3);

endtask : drive_reset

/*
 * task used to configure a filter with the given parameters
 * Default configuration is random
 */
task ifx_dig_testbase::configure_filter(
        int filt_idx,                                         // index of the filter to be configured
        filt_reset_t wd_rst      = filt_reset_t'(`RAND_1BIT), // reset type: asynchronous or synchronous
        bit int_en               = `RAND_1BIT,                // interrupt enable: 1 to enable, 0 to disable
        int window_size          = `RAND_4BIT,                // selection of the filter length
        filt_type_t filter_type  = filt_type_t'(`RAND_2BIT)   // filter type: rising, falling, both edges, or disabled
    );

    int filter_type_int;
    if (filt_idx < 0 || filt_idx > `FILT_NB) begin
        `uvm_fatal("TEST_BASE/CONFIGURE_FILTER", $sformatf("Invalid filter index %0d", filt_idx))
    end
    case(filter_type) // conver to the value the register needs
        FILT_DISABLED: filter_type_int = 0;
        FILT_RISING:   filter_type_int = 1;
        FILT_FALLING:  filter_type_int = 2;
        FILT_BOTH:     filter_type_int = 3;
    endcase

    `uvm_info("TEST_BASE/CONFIGURE_FILTER", $sformatf("Filter %0d configured with reset type %s, int_en %0d, window size %0d, filter type %s",
            filt_idx, wd_rst.name(), int_en, window_size, filter_type.name()), UVM_NONE)

    write_reg_fields($sformatf("FILTER_CTRL%0d", filt_idx),
        {"WD_RST", "INT_EN", "WINDOW_SIZE", "FILTER_TYPE"},
        {wd_rst == FILT_SYNC_RESET ? 1 : 0, int_en, window_size, filter_type_int});

endtask : configure_filter

/*
 * task used to read the status of a filter
 * if filt_idx = 0, all status registers are read
 */
task ifx_dig_testbase::read_filter_status(int filt_idx = 0);
    string regs_to_read[$];

    if (filt_idx < 0 || filt_idx > `FILT_NB) begin
        `uvm_fatal("TEST_BASE/READ_FILTER_STATUS", $sformatf("Invalid filter index %0d", filt_idx))
    end
    if( filt_idx == 0 ) begin // read all filter status registers
        int regs_no = `FILT_NB%8 == 0 ? `FILT_NB/8 : `FILT_NB/8 + 1;
        for (int i = 1; i <= regs_no; i++) begin
            regs_to_read.push_back($sformatf("INT_STATUS%0d", i));
        end
    end else begin
        // read only the status register of the specified filter
        regs_to_read.push_back($sformatf("INT_STATUS%0d", filt_idx%8  == 0 ? (filt_idx/8) : (filt_idx/8 + 1)));
    end

    `uvm_info("TEST_BASE/READ_FILTER_STATUS", $sformatf("Reading filter status for %s", filt_idx != 0 ? $sformatf("filter %0d", filt_idx) : "all filters"), UVM_NONE);
    foreach(regs_to_read[reg_id])
        read_reg(regs_to_read[reg_id]);
endtask

/*
 * task used to clear the status of a filter
 * if filt_idx = 0, all status registers are cleared, one by one
 */
task ifx_dig_testbase::clear_filter_status(int filt_idx = 0);
    if (filt_idx < 0 || filt_idx > `FILT_NB) begin
        `uvm_fatal("TEST_BASE/CLEAR_FILTER_STATUS", $sformatf("Invalid filter index %0d", filt_idx))
    end

    `uvm_info("TEST_BASE/CLEAR_FILTER_STATUS", $sformatf("Clearing filter status for %s", filt_idx != 0 ? $sformatf("filter %0d", filt_idx) : "all filters"), UVM_NONE);

    if( filt_idx == 0 ) begin // clear all filter status registers
        int regs_no = `FILT_NB%8 == 0 ? `FILT_NB/8 : `FILT_NB/8 + 1;
        for (int ireg = 1; ireg <= regs_no; ireg++) begin
            string fields[$];
            for(int ifield = (ireg-1)*8 + 1; ifield <= ireg*8; ifield++) begin
                if(ifield > `FILT_NB)
                    break; // avoid accessing out of bounds
                fields.push_back($sformatf("IN%0d_INT", ifield));
            end
            write_reg_fields(
                .reg_name($sformatf("INT_STATUS%0d", ireg)),
                .fields_names({fields}),
                .fields_values({1,1,1,1,1,1,1,1}),
                .read_after_write(1) // always read after a write to verify the operation
            );
        end
    end else begin
        // clear only the status register of the specified filter
        write_reg_fields(
            .reg_name($sformatf("INT_STATUS%0d", filt_idx%8  == 0 ? (filt_idx/8) : (filt_idx/8 + 1))),
            .fields_names({$sformatf("IN%0d_INT", filt_idx)}),
            .fields_values({1}),
            .read_after_write(1) // always read after a write to verify the operation
        );
    end

endtask
