/******************************************************************************
 * (C) Copyright 2019 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT: mercury
 * AUTHOR:
 * DATE:
 * FILE:
 * REVISION:
 *
 * FILE DESCRIPTION: Digital module DUT interface
 *
 *******************************************************************************/

`include "ifx_dig_defines.svh"

interface ifx_dig_interface (

        //system clock & reset
        input logic               clk_i,
        output logic              rstn_i,

// system data communication interface
        input logic acc_en_i,
        input logic wr_en_i,
        input logic [`AWIDTH-1:0] addr_i,
        input logic [`DWIDTH-1:0] wdata_i,
        input logic [`DWIDTH-1:0] rdata_o,

        // external inputs
        input logic [`FILT_NB-1:0] data_in,

        // system outputs
        input logic [`FILT_NB-1:0] data_out,
        input logic int_pulse_out
    );

    // TODO: Add SVA assertion for input reset values

endinterface
