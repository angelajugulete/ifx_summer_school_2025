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

class ifx_dig_data_bus_uvc_config extends uvm_object;

  `uvm_object_utils(ifx_dig_data_bus_uvc_config)

  bit[`AWIDTH-1:0] invalid_address[] = {}; // store invalid addresses in the available address space
  string name;

  function new (string name = "data_bus_uvc_config");
    super.new(name);
  endfunction

endclass