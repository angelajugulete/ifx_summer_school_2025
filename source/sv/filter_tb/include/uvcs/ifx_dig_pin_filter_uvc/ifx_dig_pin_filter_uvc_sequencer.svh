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

class ifx_dig_pin_filter_uvc_sequencer extends uvm_sequencer #(ifx_dig_pin_filter_uvc_seq_item);

  `uvm_component_utils(ifx_dig_pin_filter_uvc_sequencer)

    ifx_dig_pin_filter_uvc_config    cfg; // pointer to configuration object, to be used in sequences

  function new (string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual function void start_of_simulation_phase (uvm_phase phase);
    `uvm_info (get_type_name(),$sformatf(" Executing start of simulation phase: SEQUENCER"), UVM_HIGH);
  endfunction

endclass