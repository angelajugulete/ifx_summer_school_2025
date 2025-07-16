/******************************************************************************
 * (C) Copyright 2019 All Rights Reserved
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

package ifx_dig_pkg;

  //=========================================================================
  // UVM and DEFINES.
  //-------------------------------------------------------------------------
  //=========================================================================
  import uvm_pkg::*;
  `include  "uvm_macros.svh"

  `include "ifx_dig_defines.svh"

  //=========================================================================
  // TODO: import the UVC packages
  //-------------------------------------------------------------------------
  import ifx_dig_regblock_pkg::*;
  import ifx_dig_data_bus_uvc_pkg::*;
  import ifx_dig_pin_filter_uvc_pkg::*;
  //=========================================================================
  // TODO: Include Environment files (env, scoreboard, sequencer, types, config)
  //-------------------------------------------------------------------------
  //=========================================================================
  `include "ifx_dig_config.svh"
  `include "ifx_dig_scoreboard.svh"
  `include "ifx_dig_virtual_sequencer.svh"
  `include "ifx_dig_env.svh"

endpackage
