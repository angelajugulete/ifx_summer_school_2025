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


class ifx_dig_virtual_sequencer extends uvm_virtual_sequencer;


    `uvm_component_utils(ifx_dig_virtual_sequencer)

    ifx_dig_pin_filter_uvc_sequencer p_pin_filter_uvc_seqr[`FILT_NB-1:0]; // array of pin filter UVC sequencers
    ifx_dig_data_bus_uvc_sequencer p_data_bus_uvc_seqr;                   // data bus UVC sequencer


    function new(string name = "ifx_dig_virtual_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass