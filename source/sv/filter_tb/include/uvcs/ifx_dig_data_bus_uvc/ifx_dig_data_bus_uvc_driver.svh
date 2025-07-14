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

class ifx_dig_data_bus_uvc_driver extends uvm_driver #(ifx_dig_data_bus_uvc_seq_item);

  `uvm_component_utils(ifx_dig_data_bus_uvc_driver)

  virtual interface ifx_dig_data_bus_uvc_interface vif;

  ifx_dig_data_bus_uvc_config cfg;

  string agent_name;

  //Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //Build Phase
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
  endfunction

  //Run Phase
  virtual task run_phase (uvm_phase phase);

    // initialize output signals
    vif.addr_o   = 0;
    vif.wr_en_o  = 0;
    vif.acc_en_o = 0;
    vif.wdata_o  = 0;

    forever begin
      // get the next item from the sequencer
      seq_item_port.get_next_item(req);

      case(req.access_type)
        READ : begin
          @(posedge vif.clk_i);
          vif.addr_o   = req.address;
          vif.wr_en_o  = 0;
          vif.acc_en_o = 1;
          @(posedge vif.clk_i);
          vif.acc_en_o = 0;
        end

        WRITE: begin
          @(posedge vif.clk_i);
          vif.addr_o   = req.address;
          vif.wdata_o  = req.data;
          vif.wr_en_o  = 1;
          vif.acc_en_o = 1;
          @(posedge vif.clk_i);
          vif.acc_en_o = 0;
        end
        
        INVALID_READ : begin
          @(posedge vif.clk_i);
          vif.addr_o   = req.address;
          vif.wr_en_o  = 0;
          vif.acc_en_o = 0;
        end

        INVALID_WRITE: begin
          @(posedge vif.clk_i);
          vif.addr_o   = req.address;
          vif.wdata_o  = req.data;
          vif.wr_en_o  = 1;
          vif.acc_en_o = 0;
        end
      endcase

      // tell the sequence the current item driving has finished
      seq_item_port.item_done();
    end
  endtask

endclass
