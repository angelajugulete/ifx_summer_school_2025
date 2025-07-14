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

class ifx_dig_pin_filter_uvc_config extends uvm_object;

    `uvm_object_utils(ifx_dig_pin_filter_uvc_config)

    string name; // name of the UVC instance

    filt_sync_stage_t filter_synchronization_stage_sel; // selects the number of filter synchronization stages
    filt_reset_t filter_reset_sel;                      // selects the type of filter reset

    filt_type_t filter_type; // selects the type of filter - RISING, FALLING or BOTH edges

    int rise_filt_length_clk; // filter length for rising edge in clock cycles - selecting 0 means no filter
    int fall_filt_length_clk; // filter length for falling edge in clock cycles - selecting 0 means no filter

    int id; // filter ID, used to identify the filter when used in an array of UVC filters when using a single TLM port in the scoreboard.

    function new (string name = "pin_filter_config");
        super.new(name);
    endfunction

endclass