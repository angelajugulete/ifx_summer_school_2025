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
    top_filter_bank #(.N(`FILT_NB)) DUT (
        .clk_i(clk),
        .rstn_i(rstn_i_w),

        // system data communication interface
        .acc_en_i(acc_en_i_w),
        .wr_en_i(wr_en_i_w),
        .addr_i(addr_i_w),
        .wdata_i(wdata_i_w),
        .rdata_o(rdata_o_w),

        // external inputs
        .data_in(data_in_w),

        // system outputs
        .data_out(data_out_w),
        .int_pulse_out(int_pulse_out_w)
    );

    //===========================================================================
    //              INTERFACES
    //===========================================================================

    // TODO:  add here instance for dig_if
    ifx_dig_interface dig_if (
        //system clock & reset
        .clk_i(clk),
        .rstn_i(rstn_i_w),

        // system data communication interface
        .acc_en_i(acc_en_i_w),
        .wr_en_i(wr_en_i_w),
        .addr_i(addr_i_w),
        .wdata_i(wdata_i_w),
        .rdata_o(rdata_o_w),

        // external inputs
        .data_in(data_in_w),

        // system outputs
        .data_out(data_out_w),
        .int_pulse_out(int_pulse_out_w)
    );

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
    //interfata filtru
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
        generate_clock("ns",10);//perioada clock de 10 ns
    end

   
// TODO: Write a task capable of generating a clock signal
    task generate_clock(string time_unit = "us", bit [31:0] period = 1);
        int clk_half_per_ps;
        case(time_unit)
            "ns":clk_half_per_ps = period*1000/2;
            "us":clk_half_per_ps = period*1000*1e6/2;
            "ms":clk_half_per_ps = period*1000*1e9/2;
        endcase
        clk=0;
        forever begin#(clk_half_per_ps*1ps) clk=!clk;
        end
    endtask
    

    //===========================================================================
    // pass virtual interfaces to the testbench
    //===========================================================================

    initial begin
        //----------DIG-----------
        uvm_config_db #(virtual ifx_dig_interface)::set(uvm_top, "*", "dig_if", dig_if);//set->config_db->top
        //fctia SET si apoi pot sa dau GET
        // interfaces for UVCs
        uvm_config_db #(virtual ifx_dig_data_bus_uvc_interface)::set(uvm_top, "data_bus_uvc_agt", "vif", data_uvc_if);

    end
endmodule