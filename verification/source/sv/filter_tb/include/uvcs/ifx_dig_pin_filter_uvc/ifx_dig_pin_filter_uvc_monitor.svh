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

class ifx_dig_pin_filter_uvc_monitor extends uvm_monitor;

    `uvm_component_utils(ifx_dig_pin_filter_uvc_monitor)

    string agent_name;
    virtual interface ifx_dig_pin_filter_uvc_interface vif;
    ifx_dig_pin_filter_uvc_config cfg;

    ifx_dig_pin_filter_uvc_seq_item mon_item;

    bit filt_out_b; // output value of the filter

    // internal counters for rising and falling edge filters
    int filt_rise_cnt = 0; // counter for the rising edge filter
    int filt_fall_cnt = 0; // counter for the falling edge filter

    uvm_analysis_port #(ifx_dig_pin_filter_uvc_seq_item) mon_port;

    function new(string name,uvm_component parent);
        super.new(name,parent);
        mon_port=new("mon_port",this);
    endfunction

    function void build_phase(uvm_phase phase);
        mon_item = ifx_dig_pin_filter_uvc_seq_item::type_id::create("mon_item", this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name(), "Starting the run() phase", UVM_MEDIUM)

        mon_item.id = cfg.id; // set the ID from the config
        filt_out_b  = 0;      // default output

        fork
            filter_level();
            track_uvc_config();
        join

    endtask

    /*
     * update interface variables with values from configuration
     */
    task track_uvc_config();
        fork
            forever begin
                vif.filt_reset_type = cfg.filter_reset_sel == FILT_SYNC_RESET;
                @(cfg.filter_reset_sel);
            end
            forever begin
                vif.synch_stage_select = cfg.filter_synchronization_stage_sel == FILT_SYNC_DOUBLE;
                @(cfg.filter_synchronization_stage_sel);
            end
        join

    endtask

    /*
     * monitor pin level activity and send items on the analysis port
     */
    task filter_level();
        forever begin
            // wait for reset to be released
            wait(vif.rstn_i == 1 & cfg.filter_type != FILT_DISABLED); // wait for reset to be released and filter to be enabled
            filt_fall_cnt = 0;                                        // reset the falling edge counter
            filt_rise_cnt = 0;                                        // reset the rising edge counter


            fork

                begin // filter rising edge
                    wait(vif.pin_monitor_s == 1 && filt_out_b == 0) begin // wait for a rising edge
                        fork // needed because if the threads below finish at the same time, the disable fork below will disable the upper fork
                            fork
                                begin // filtering
                                    // in case we have a filter
                                    if(cfg.filter_type inside {FILT_RISING, FILT_BOTH}) begin
                                        while (filt_rise_cnt < cfg.rise_filt_length_clk) begin
                                            filt_rise_cnt++;
                                            @(posedge vif.clk_i);
                                        end
                                        mon_item.filter_validity = FILT_VALID;
                                    end else
                                    // if we don't have a filter send the item immediately
                                    begin
                                        mon_item.filter_validity = FILT_NONE;
                                    end

                                    filt_out_b = 1;
                                end
                                begin // filtering reset
                                    @(negedge vif.pin_monitor_s);
                                    mon_item.filter_validity = FILT_INVALID;
                                end
                            join_any
                            disable fork;
                        join
                        mon_item.filt_edge = FILT_RISE_EDGE;
                        mon_port.write(mon_item);
                    end
                end

                begin // filter falling edge
                    wait(vif.pin_monitor_s == 0 & filt_out_b == 1) begin // wait for a falling edge
                        fork
                            fork
                                begin // filtering
                                    // in case we have a filter
                                    if(cfg.filter_type inside {FILT_FALLING, FILT_BOTH}) begin
                                        while (filt_fall_cnt < cfg.fall_filt_length_clk) begin
                                            filt_fall_cnt++;
                                            @(posedge vif.clk_i);
                                        end
                                        mon_item.filter_validity = FILT_VALID;
                                    end else
                                    // if we don't have a filter send the item immediately
                                    begin
                                        mon_item.filter_validity = FILT_NONE;
                                    end

                                    filt_out_b = 0;
                                end
                                begin // filtering reset
                                    @(negedge vif.pin_monitor_s);
                                    mon_item.filter_validity = FILT_INVALID;
                                end
                            join_any
                            disable fork;
                        join
                        mon_item.filt_edge = FILT_FALL_EDGE;
                        mon_port.write(mon_item);
                    end
                end

                begin // detect reset or when filter gets disabled
                    @(negedge vif.rstn_i, cfg.filter_type iff cfg.filter_type == FILT_DISABLED);
                    filt_out_b               = 0;
                    mon_item.filter_validity = FILT_NONE;
                    mon_item.filt_edge       = FILT_FALL_EDGE;
                    mon_port.write(mon_item);
                end
            join_any
            disable fork;

        end
    endtask

endclass
