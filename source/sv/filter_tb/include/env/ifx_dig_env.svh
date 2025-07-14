/******************************************************************************
 * (C) Copyright 2019 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT:
 * AUTHOR:
 * DATE:
 * FILE: ifx_dig_env
 * REVISION:
 *
 * FILE DESCRIPTION: digital tb environment
 *
 *******************************************************************************/

class ifx_dig_env extends uvm_env;

  //========= UVM UTILS MACRO ===========
  `uvm_component_utils(ifx_dig_env)

  //=========================================================================
  // Golden model instantiation.
  //-------------------------------------------------------------------------
  //=========================================================================
  ifx_dig_scoreboard scoreboard;

  //=========================================================================
  // UVC instantiation - COMMON for DIG & SOC.
  //-------------------------------------------------------------------------
  //=========================================================================


  //=========================================================================
  // Environment component instantiation.
  //-------------------------------------------------------------------------
  //=========================================================================
  ifx_dig_config p_dig_cfg;

  ifx_dig_virtual_sequencer v_seqr; // holds pointers to all the other sequencers

  //=========================================================================
  // UVC instantiation.
  //-------------------------------------------------------------------------
  //=========================================================================

  ifx_dig_data_bus_uvc_agent data_bus_uvc_agt;

  ifx_dig_pin_filter_uvc_agent pin_filter_uvc_agt[`FILT_NB-1:0];

  //=========================================================================
  // Events and other variables
  //-------------------------------------------------------------------------
  //=========================================================================

  //=========================================================================
  // Methods.
  //-------------------------------------------------------------------------
  //=========================================================================
  function new(string name, uvm_component parent);
    super.new(name, parent);

  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info (get_type_name(), $sformatf(">>>>>>>>>>>>ENV BUILD_PHASE starts<<<<<<<<<"), UVM_LOW)

    //=======================COMPONENT CREATES======================
    scoreboard = ifx_dig_scoreboard::type_id::create("scoreboard", this);

    //=======================CONFIG SET COMPONENT SCOPE======================

    if (!uvm_config_db #(ifx_dig_config)::get(this, "*", "p_dig_cfg", p_dig_cfg))
    `uvm_fatal("DIG_ENV/NOCFG", "No config specified for Environment")
    //=======================AGENT CREATES======================

    data_bus_uvc_agt = ifx_dig_data_bus_uvc_agent::type_id::create("data_bus_uvc_agt", this);

    foreach(pin_filter_uvc_agt[idx]) begin
      pin_filter_uvc_agt[idx] = ifx_dig_pin_filter_uvc_agent::type_id::create($sformatf("pin_filter_uvc_agt_[%0d]", idx), this);
    end

    v_seqr = ifx_dig_virtual_sequencer::type_id::create("v_seqr", this);

  endfunction : build_phase


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //=======================GOLDEN MODEL/MONITOR CONNECT======================
    scoreboard.p_env = this;
    scoreboard.p_env_cfg = p_dig_cfg;

    //=======================TLM======================
    // connect UVC tlm ports

    // TODO: Connect data_bus_uvc analysis port to scoreboard import

    foreach(pin_filter_uvc_agt[idx]) begin
      pin_filter_uvc_agt[idx].monitor.mon_port.connect(scoreboard.pin_filter_uvcs_imp_fifo.analysis_export);
    end

    // connect pointers to virtual sequencer
    v_seqr.p_data_bus_uvc_seqr = data_bus_uvc_agt.sequencer;
    foreach(pin_filter_uvc_agt[idx]) begin
      v_seqr.p_pin_filter_uvc_seqr[idx] = pin_filter_uvc_agt[idx].sequencer;
    end


  endfunction : connect_phase


  function void start_of_simulation_phase(uvm_phase phase);
  endfunction : start_of_simulation_phase

  task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
  endtask : reset_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info (get_type_name(), $sformatf(">>>>>>>>>>>>ENV RUN_PHASE starts<<<<<<<<<"), UVM_LOW)


  endtask : run_phase

endclass
