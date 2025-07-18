///******************************************************************************
// * (C) Copyright 2020 All Rights Reserved
// *
// * MODULE:
// * DEVICE:
// * PROJECT:
// * AUTHOR:
// * DATE:
// * FILE:
// * REVISION:
// *
// * FILE DESCRIPTION:
// *
// *******************************************************************************/



// ===========================================================================

// Modeleld outputs of the DUT//pe astea 2 trb sa le modelam in partea de TO DO
bit [`FILT_NB-1:0] data_out_gm; // output value of the filter
bit int_pulse_out_gm;           // interrupt output

// Auxiliary golden model variables
bit [`FILT_NB-1:0] filt_int_req_b; // setam aceasta variabila la TO DO//each bit sets to 1 for 1 clock cycle when the filter is valid

//For coverage
filt_reset_t cov_filter_reset;
filt_type_t cov_filter_type;
int cov_window_size;
bit cov_int_en;

task golden_model();
    fork

        monitor_reset();
            forever begin
                regblock.reset();
                ->regblock_reset_e;
                @(negedge dig_vif.rstn_i);//la negedge se actualizeaza
            end
        update_uvc_config();

        model_interrupt();

        model_data_out();
    join
endtask
//modelam semnalele filtrate


task update_reg_variables();
    forever begin

        @(reg_write_e, regblock_reset_e);
    end
endtask


task monitor_reset();
    forever begin
        regblock.reset();
        ->regblock_reset_e;
        @(negedge dig_vif.rstn_i);
    end
endtask

/*
 * task will update the UVC configuration after register writes
 */
task update_uvc_config();
    forever begin //folosesc forever?
        foreach(p_env.pin_filter_uvc_agt[ifilter]) begin

            case(regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "WD_RST"))//in fct de wd_rst iau val din registru si fac cazurile
                0: p_env.pin_filter_uvc_agt[ifilter].cfg.filter_reset_sel = FILT_ASYNC_RESET;
                1: p_env.pin_filter_uvc_agt[ifilter].cfg.filter_reset_sel = FILT_SYNC_RESET;
            endcase

            case(regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "FILTER_TYPE"))
                0: p_env.pin_filter_uvc_agt[ifilter].cfg.filter_type = FILT_DISABLED;
                1: p_env.pin_filter_uvc_agt[ifilter].cfg.filter_type = FILT_RISING;
                2: p_env.pin_filter_uvc_agt[ifilter].cfg.filter_type = FILT_FALLING;
                3: p_env.pin_filter_uvc_agt[ifilter].cfg.filter_type = FILT_BOTH;
            endcase

            case(regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "WINDOW_SIZE"))
                4'b0000: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 4;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 4;
                end
                4'b0001: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 8;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 8;
                end
                4'b0010: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 16;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 16;
                end
                4'b0011: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 32;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 32;
                end
                4'b0100: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 48;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 48;
                end
                4'b0101: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 64;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 64;
                end
                4'b0110: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 128;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 128;
                end
                4'b0111: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 256;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 256;
                end
                4'b1000: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 512;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 512;
                end
                4'b1001: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 640;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 640;
                end
                4'b1010: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 768;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 768;
                end
                4'b1011: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 896;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 896;
                end
                4'b1100: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 1024;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 1024;
                end
                4'b1101: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 1280;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 1280;
                end
                4'b1110: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 1536;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 1536;
                end
                4'b1111: begin
                    p_env.pin_filter_uvc_agt[ifilter].cfg.rise_filt_length_clk = 2048;
                    p_env.pin_filter_uvc_agt[ifilter].cfg.fall_filt_length_clk = 2048;
                end
            endcase
        end

        @(reg_write_e, regblock_reset_e); // get the new configuration after register changes
    end
endtask


/*
 * get the request from all the filters and set the interrupt output
 * this also predicts the interrupt status in the regblock
 */
task model_interrupt();
    // monitor the interrupt request from all filters and reset the request after 1 clock cycle
    for(int ifilter = 0; ifilter < `FILT_NB; ifilter++) begin
        automatic int ifilter_aux = ifilter; // fiecare thread are variabila lui(variabila dinamica)//in order to be able to start multiple threads based on the index, the variable index must be automatic (local for each thread)
        fork
            forever @(posedge filt_int_req_b[ifilter_aux]) begin
                //TODO: Implement logic modeling the interput status and the intrrupt
                //folosim fct predict_filt_value!! ca sa fac legatura intre nr filtr si nr registr(int status)
               regblock.predict_field_value($sformatf("INT_STATUS%0d", (ifilter_aux+1)%8 ? ((ifilter_aux+1)/8+1) : (ifilter_aux+1)/8), $sformatf("IN%0d_INT", ifilter_aux+1), 1); // set the interrupt status in the regblock
                @(posedge dig_vif.clk_i);
                filt_int_req_b[ifilter_aux] = 0;

                `uvm_info("INTERRUPT_REQUEST", $sformatf("Interrupt request for filter ended. %0d", ifilter_aux), UVM_MEDIUM)
            end
        join_none
    end

    //forever sa se execute mereu ori pe int_request(adk cand se modifica el) ori pe clock
    //fac sau | intre toti bitii vectorului filt_int_req_b

    //HINT: combine all the request into a single interrupt output
endtask


/*
 * model the data output of the DUT by using the sequence items received from the Filter UVC monitor
 */
task model_data_out();
    ifx_dig_pin_filter_uvc_seq_item filt_packet = ifx_dig_pin_filter_uvc_seq_item::type_id::create("filt_packet");
    forever begin//asteptam sa ne vina packet valid in fifo
        pin_filter_uvcs_imp_fifo.get(filt_packet); // the call is blocking, will wait for the item to be available

        `uvm_info("WRITE_PIN_FILTER_UVC", $sformatf("Received packet from PIN_FILTER_UVC monitor. Packet %p\n", filt_packet), UVM_LOW)

        case(filt_packet.filter_validity)
            FILT_VALID: begin
                // TODO: Implement logic for modeling the filter output update and interrupt update (if enabled)
            data_out_gm[filt_packet.id] = filt_packet.filt_edge == FILT_RISE_EDGE ? 1 : 0;//cu id ul stiu ce filtru am si resp pe ce data_out
            if(regblock.get_field_value($sformatf("FILTER_CTRL%0d", filt_packet.id+1), "INT_EN")) begin//get_field-value imi ia val
                    filt_int_req_b[filt_packet.id] = 1; // set the interrupt request for the filter
                end
            end

            FILT_NONE: begin
                fork
                    begin
                        // ATTENTION: remove the clock wait if this behavior is not the case for your DUT
                        // HINT in case there is no filter on an edge, the output is elongated by 1 clock cycle - this is needed to ensure the output will toggle even when the input is the exact same length as the filter length - DUT implementation

                        automatic int id_aux       = filt_packet.id;                                  // in order to be able to start multiple threads based on the index, the variable index must be automatic (local for each thread)
                        automatic bit data_out_aux = filt_packet.filt_edge == FILT_RISE_EDGE ? 1 : 0; // store the current output value

                        if(dig_vif.rstn_i)            // for for 1 more clock cycle if the reset is not active
                            @(posedge dig_vif.clk_i); // wait for the clock edge to update the output
                        // if the is no filter or due to reset just set the output without interrupt
                        data_out_gm[id_aux] = data_out_aux;
                    end
                join_none
            end

            FILT_INVALID: begin
                // there is nothing to be done, the filter keeps its value
            end
        endcase

    end
endtask
