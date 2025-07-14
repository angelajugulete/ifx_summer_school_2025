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

interface ifx_dig_pin_filter_uvc_interface
    (
        input logic clk_i,  // clock signal used for synchronization and filtering
        input logic rstn_i, // reset signal, active low

        input logic pin_i, // monitored signal in UVC PASSIVE mode

        output logic pin_o // driven signal in UVC ACTIVE mode, this signal is also monitored in UVC ACTIVE mode
    );

    // control signals
    bit is_active;          // indicates if the UVC is in ACTIVE mode
    bit filt_reset_type;    // 0 - asynchronous reset (every edge resets the synchronization); 1 - synchronous reset (only on rising edge of clk_i)
    bit synch_stage_select; // 0 - single stage, 1 - double stage

    // signal processing variables
    logic pin_s;              // pin level multiplexed between input and output depending on the UVC mode
    logic pin_monitor_s;      // signal monitored by the UVC - after the synchronization stages

    logic pin_s_sync1, pin_s_sync2; // Synchronizer stages for pin_s
    logic sync_areset; // asynchronous reset for the synchronizer // detect if level changes
    logic pin_s_async1, pin_s_async2; // synchronizer stage for pin_s with asynchronous reset


    // multiplexing input and output pin based on UVC mode
    assign pin_s = is_active ? pin_o : pin_i;


    // Synchronization stages for pin_s
    // First Synchronization stage for pin_s
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            pin_s_sync1 <= 0;
        end else begin // synchronous mode
            pin_s_sync1 <= pin_s;
        end
    end

    //First Synchronization stage with asynchronous reset
    // assign sync_areset = ~(pin_s ^ pin_s_sync1); // asynchronous reset signal for the synchronizer
    assign sync_areset = rstn_i & pin_s; // Discussed with DD, the asynchronous reset is only working on the rising edge. For it to be working on both edges, we need to use a much more different approach which is not needed for the current design.
    always_ff @(posedge clk_i or negedge sync_areset) begin
        if (!sync_areset) begin
            pin_s_async1 <= 0;
        end else begin
            pin_s_async1 <= pin_s;
        end
    end

     // Second Synchronization stage for pin_s
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            pin_s_sync2 <= 0;
        end else begin
            pin_s_sync2 <= filt_reset_type ? pin_s_sync1 : pin_s_async1; // select the first stage based on the reset type
        end
    end

    // pass the signal to the monitor after the synchronization stage
    assign pin_monitor_s = synch_stage_select ? pin_s_sync2 : (filt_reset_type ? pin_s_sync1 : pin_s_async1);

endinterface
