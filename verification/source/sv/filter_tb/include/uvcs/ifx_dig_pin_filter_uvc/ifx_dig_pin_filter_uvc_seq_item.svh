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

class ifx_dig_pin_filter_uvc_seq_item extends uvm_sequence_item;

    // both monitoring and driving relevant
    rand filt_edge_t filt_edge; // tells if the filtering occurs on rising or falling edge

    // monitoring only relevant
    rand filt_validity_t filter_validity; // tells if the filtering was valid or not
    int id;                               // filter ID, used to identify the filter when used in an array of UVC filters when using a single TLM port in the scoreboard - always holds the value from config

    // driving only relevant
    rand filt_drive_t drive_type; // selects the type of driving
    // if set to 1, the driving level will be automatically selected based on the filter lengths (rising or falling)
    // if the filter is applied on both edges, the driving will be on the oposite edge of the current interface value
    rand int pulse_length_clk;    // pulse length in clock cycles for drive_type = FILT_DRV_PULSE
    rand bit driving_edge_auto_select;

    // register this class with UVM factory.
    // by adding the fields we can use built in UVM methods like `do_copy()`, `do_compare()`, etc.
    `uvm_object_utils_begin(ifx_dig_pin_filter_uvc_seq_item)
        `uvm_field_enum(filt_edge_t, filt_edge, UVM_ALL_ON)
        `uvm_field_enum(filt_validity_t, filter_validity, UVM_ALL_ON)
        `uvm_field_int(id, UVM_ALL_ON)
        `uvm_field_enum(filt_drive_t, drive_type, UVM_ALL_ON)
        `uvm_field_int(pulse_length_clk, UVM_ALL_ON)
        `uvm_field_int(driving_edge_auto_select, UVM_ALL_ON)
    `uvm_object_utils_end


    constraint pulse_length_constraint{
        soft pulse_length_clk inside {[10:100]};
    }

    constraint level_contrains{
        soft driving_edge_auto_select == 1;
    }

    function new (string name="");
        super.new(name);
    endfunction

endclass