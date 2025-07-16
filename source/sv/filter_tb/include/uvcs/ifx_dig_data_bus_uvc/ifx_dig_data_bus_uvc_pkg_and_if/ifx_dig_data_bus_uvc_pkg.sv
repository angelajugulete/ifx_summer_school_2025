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
//.sv cv ce trb inclus de mana si .svh(header) fisiere incluse deja in package pkg
`timescale 1ns/100ps

package ifx_dig_data_bus_uvc_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "ifx_dig_data_bus_uvc_typedef.svh"
  `include "ifx_dig_data_bus_uvc_config.svh"
  // TODO: Include data bus uvc files
  `include "ifx_dig_data_bus_uvc_seq_item.svh"
  `include "ifx_dig_data_bus_uvc_sequence_lib.svh"
  `include "ifx_dig_data_bus_uvc_sequencer.svh"
  `include "ifx_dig_data_bus_uvc_driver.svh"
  `include "ifx_dig_data_bus_uvc_monitor.svh"
  `include "ifx_dig_data_bus_uvc_agent.svh"
endpackage
