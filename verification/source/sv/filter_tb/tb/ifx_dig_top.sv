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

`include "ifx_dig_defines.svh"
`include"uvm_macros.svh"

module ifx_dig_top;
//-----------------------------------------------------------------------------

    /// UVM import
    import uvm_pkg::*;

    import ifx_dig_data_bus_uvc_pkg::*;
    import ifx_dig_pkg::*;
    import ifx_dig_test_pkg::*;

    //===========================================================================
    // start UVM class environment - (uvm_test_top)
    //===========================================================================
    initial begin
        $timeformat(-9, 3, " ns", 15);// set time format.
        $display("running test");
        run_test();
    end

    //===========================================================================
    // wires connected to the RTL interface
    //===========================================================================
    //system clock & reset
    reg  clk;
    wire rstn_i_w;

// system data communication interface
    wire acc_en_i_w;
    wire wr_en_i_w;
    wire [`AWIDTH-1:0] addr_i_w;
    wire [`DWIDTH-1:0] wdata_i_w;
    wire [`DWIDTH-1:0] rdata_o_w;

    // external inputs
    wire [`FILT_NB-1:0] data_in_w;
    // system outputs
    wire [`FILT_NB-1:0] data_out_w;
    wire int_pulse_out_w;

    //===========================================================================
    // wires for other interconnection
    //===========================================================================

    //===========================================================================
    // clocks and extra wires
    //===========================================================================

    //===========================================================================
    // Connection to DUT
    //===========================================================================

    // TODO: --  add here instance for DUT


    //===========================================================================
    //              INTERFACES
    //===========================================================================

    // TODO:  add here instance for dig_if


    //===========================================================================
    // interconnect module and/or interface UVCs
    //===========================================================================
    // interfaces for UVCs


    ifx_dig_data_bus_uvc_interface data_uvc_if(
        .clk_i(clk),
        .rstn_i(rstn_i_w),

        .acc_en_o(acc_en_i_w),
        .wr_en_o(wr_en_i_w),
        .addr_o(addr_i_w),
        .wdata_o(wdata_i_w),
        .rdata_i(rdata_o_w)
    );

    genvar i_filt;
    generate
        for (i_filt = 0; i_filt < `FILT_NB; i_filt++) begin : gen_filter_if
            ifx_dig_pin_filter_uvc_interface pin_filter_if (
                .clk_i(clk),
                .rstn_i(rstn_i_w),

                .pin_i(data_in_w[i_filt]), // as an active driver, the UVC will monitor its output
                .pin_o(data_in_w[i_filt])
            );
            // set the interface to the corresponding UVC
            initial begin
                uvm_config_db #(virtual ifx_dig_pin_filter_uvc_interface)::set(uvm_top, $sformatf("pin_filter_uvc_agt_[%0d]", i_filt), "vif", pin_filter_if);
            end
        end
    endgenerate

    //===========================CLOCKS=============================
    // TODO: Modify generate_clock task call so that a 100 MHz will be generated
    initial begin
        generate_clock();
    end

    // TODO: Write a task capable of generating a clock signal
    task generate_clock(string time_unit = "us", bit [31:0] period = 1);

    endtask

    //===========================================================================
    // pass virtual interfaces to the testbench
    //===========================================================================

    initial begin
        //----------DIG-----------
        uvm_config_db #(virtual ifx_dig_interface)::set(uvm_top, "*", "dig_if", dig_if);

        // interfaces for UVCs
        uvm_config_db #(virtual ifx_dig_data_bus_uvc_interface)::set(uvm_top, "data_bus_uvc_agt", "vif", data_uvc_if);

    end
endmodule
