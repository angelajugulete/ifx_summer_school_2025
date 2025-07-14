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
 
class ifx_dig_data_bus_uvc_seq_item extends uvm_sequence_item;

  `uvm_object_utils(ifx_dig_data_bus_uvc_seq_item)

  rand bit[`DWIDTH-1:0] data;
  rand bit[`AWIDTH-1:0] address;
  rand access_type_t access_type;
  rand address_validity_t addr_validity;
  

  constraint access_constraint {
    soft access_type inside {READ, WRITE};
  }
  constraint addr_validity_constraint {
    soft addr_validity == ADDR_VALID;
  }

  function new (string name="");
    super.new(name);
  endfunction

endclass