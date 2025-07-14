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

class ifx_dig_data_bus_uvc_agent extends uvm_agent;

  uvm_active_passive_enum is_active = UVM_ACTIVE;     //active flag

  `uvm_component_utils_begin(ifx_dig_data_bus_uvc_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  ifx_dig_data_bus_uvc_config    cfg;
  ifx_dig_data_bus_uvc_driver   driver;
  ifx_dig_data_bus_uvc_monitor   monitor;
  ifx_dig_data_bus_uvc_sequencer sequencer;

  string name;
  virtual interface ifx_dig_data_bus_uvc_interface vif;

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
    this.name = name;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual ifx_dig_data_bus_uvc_interface)::get(uvm_top, name, "vif", vif)) begin
      `uvm_fatal("AGT/NOVIF", $sformatf("No virtual interface specified for this agent instance. Agent name is %s", name))
    end

    if (!uvm_config_db#(ifx_dig_data_bus_uvc_config)::get(uvm_top, name, "cfg", cfg)) begin
      `uvm_fatal("AGT/NOCFG", "No configuration specified for this agent instance")
    end

    monitor = ifx_dig_data_bus_uvc_monitor::type_id::create("monitor", this);
    //create sequencer and drive only if the agent is active
    if (is_active == UVM_ACTIVE) begin
      driver    = ifx_dig_data_bus_uvc_driver::type_id::create("driver", this);
      sequencer = ifx_dig_data_bus_uvc_sequencer::type_id::create("sequencer", this);
    end

  endfunction

  function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      driver.agent_name = this.name;
      driver.cfg        = this.cfg;
      driver.vif        = vif;
    end

    monitor.agent_name = this.name;
    monitor.cfg        = this.cfg;
    monitor.vif        = vif;
  endfunction

endclass

