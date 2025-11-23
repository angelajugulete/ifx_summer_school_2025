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
`timescale 1ps/1ps // force timescale in the drive to keep a consistent timing resolution

class ifx_dig_pin_filter_uvc_driver extends uvm_driver #(ifx_dig_pin_filter_uvc_seq_item);

    `uvm_component_utils(ifx_dig_pin_filter_uvc_driver)

    virtual interface ifx_dig_pin_filter_uvc_interface vif;

    ifx_dig_pin_filter_uvc_config cfg;
    int clk_period_ps = 1000; // clock period in picoseconds, default 1000 ps

    string agent_name;

    ifx_dig_pin_filter_uvc_seq_item req; // sequence item to drive

    //Constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
        req = ifx_dig_pin_filter_uvc_seq_item::type_id::create("req", this);
    endfunction

    //Build Phase
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    //Run Phase
    virtual task run_phase (uvm_phase phase);
        filt_edge_t filt_edge;       // tells what edge will be driven in case of VALID and INVALID filters

        // initialize output signals
        vif.pin_o = 0;

        fork // start the clock period measurement in parallel
            measure_clock_period();
        join_none

        forever begin
            // get the next item from the sequencer
            seq_item_port.get_next_item(req);
            if(cfg.filter_type == FILT_RISING) begin
                filt_edge = FILT_RISE_EDGE;
            end else if(cfg.filter_type == FILT_FALLING) begin
                filt_edge = FILT_FALL_EDGE;
            end else if(req.driving_edge_auto_select) begin // when filter is applied on both edges, the driving level will be automatically selected based on current interface value
                filt_edge = vif.pin_o ? FILT_FALL_EDGE : FILT_RISE_EDGE;
            end else begin
                filt_edge = req.filt_edge; // get the edge type from the sequence item
            end

            if(req.drive_type inside {FILT_DRV_VALID, FILT_DRV_INVALID, FILT_DRV_PULSE} && cfg.filter_type inside {FILT_RISING, FILT_FALLING}) begin
                vif.pin_o = filt_edge == FILT_RISE_EDGE ? 0 : 1; // reset the bus to the opposite of the edge type, so that the filtering will take place
                repeat(2) @(posedge vif.clk_i); // wait for 2 clock cycles to ensure the level change is taken into account by the filter
            end

            #($urandom_range(0.1*clk_period_ps, 0.9*clk_period_ps)*1ps); // wait for a random time before driving the pin, to simulate asynchronous driving

            case(req.drive_type)
                FILT_DRV_GLITCH : begin
                    int glitch_length_ps = $urandom_range(0.9*clk_period_ps, 0.1*clk_period_ps);                                          // generate a random glitch length in picoseconds
                    int glitch_delay_ps  = $urandom_range(0.1*(clk_period_ps - glitch_length_ps), 0.9*(clk_period_ps - glitch_delay_ps)); // generate a random delay before the glitch, ensure it fits between 2 clock edges

                    @(posedge vif.clk_i);                                                                                                 // wait for the clock edge
                    #(glitch_delay_ps * 1ps);                                                                                             // wait for the random delay
                    vif.pin_o = ~vif.pin_o;                                                                                               // invert the pin output to create a glitch
                    #(glitch_length_ps * 1ps);                                                                                            // wait for the glitch length
                    vif.pin_o = ~vif.pin_o;                                                                                               // invert the pin output back to its original state
                end

                FILT_DRV_LEVEL : begin
                    vif.pin_o = req.filt_edge == FILT_RISE_EDGE ? 1 : 0; // drive the pin according to the edge type
                end

                FILT_DRV_VALID : begin
                    vif.pin_o = filt_edge == FILT_RISE_EDGE ? 1 : 0; // drive the pin according to the edge type
                    // HINT - in case of asyncronous reset, the filter will reset on the next clock edge after the driving level change which means that we need 1 clock cycle more to let the filter pass
                    if (vif.pin_o == 1) begin
                        // wait for the filter length in clock cycles
                        repeat (cfg.rise_filt_length_clk + (cfg.filter_reset_sel==FILT_ASYNC_RESET))
                            @(posedge vif.clk_i);
                    end else begin
                        // wait for the filter length in clock cycles
                        repeat (cfg.fall_filt_length_clk + (cfg.filter_reset_sel==FILT_ASYNC_RESET))
                            @(posedge vif.clk_i);
                    end

                    #($urandom_range(0.1*clk_period_ps, 0.9*clk_period_ps) * 1ps); // release the driving asynchronously
                    vif.pin_o = ~vif.pin_o;                                        // toggle the pin output back to its original state
                end

                FILT_DRV_INVALID : begin
                    vif.pin_o = filt_edge == FILT_RISE_EDGE ? 1 : 0; // drive the pin according to the edge type
                    if (vif.pin_o == 1) begin
                        // wait for the filter length in clock cycles
                        repeat (cfg.rise_filt_length_clk-1) @(posedge vif.clk_i);
                    end else begin
                        // wait for the filter length in clock cycles
                        repeat (cfg.fall_filt_length_clk-1) @(posedge vif.clk_i);
                    end
                    #($urandom_range(0.1*clk_period_ps, 0.9*clk_period_ps) * 1ps); // release the driving asynchronously
                    vif.pin_o = ~vif.pin_o;                                        // toggle the pin output back to its original state
                end

                FILT_DRV_PULSE : begin
                    vif.pin_o = req.filt_edge == FILT_RISE_EDGE ? 1 : 0; // drive the pin according to the edge type
                    repeat(req.pulse_length_clk) // wait for the pulse length in clock cycles
                        @(posedge vif.clk_i);

                    #($urandom_range(0.1*clk_period_ps, 0.9*clk_period_ps) * 1ps); // release the driving asynchronously
                    vif.pin_o = ~vif.pin_o;                                        // toggle the pin output back to its original state
                end

                FILT_DRV_TOGGLE : begin
                    vif.pin_o = ~vif.pin_o; // toggle the pin output
                end
            endcase

            // tell the sequence the current item driving has finished
            seq_item_port.item_done();
        end
    endtask

    // automatically measure the clock period without any configuration needed
    task measure_clock_period();
        realtime aux;
        @(posedge vif.clk_i)
            aux = $realtime;
        @(posedge vif.clk_i)
            clk_period_ps = ($realtime - aux)*1000; // calculate the clock period in picoseconds
    endtask

endclass
