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

`timescale 1ns/100ps

package ifx_dig_pin_filter_uvc_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "ifx_dig_pin_filter_uvc_typedef.svh"
  `include "ifx_dig_pin_filter_uvc_config.svh"
  `include "ifx_dig_pin_filter_uvc_seq_item.svh"
  `include "ifx_dig_pin_filter_uvc_sequencer.svh"
  `include "ifx_dig_pin_filter_uvc_sequence_lib.svh"
  `include "ifx_dig_pin_filter_uvc_driver.svh"
  `include "ifx_dig_pin_filter_uvc_monitor.svh"
  `include "ifx_dig_pin_filter_uvc_agent.svh"

endpackage
