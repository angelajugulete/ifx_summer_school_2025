/******************************************************************************
 * (C) Copyright 2019 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT:
 * AUTHOR:
 * DATE:
 * FILE: ifx_dig_coverage
 * REVISION:
 *
 * FILE DESCRIPTION:
 *
 *******************************************************************************/

task collect_coverage();
  forever begin
    @(reg_write_e);
    foreach(p_env.pin_filter_uvc_agt[ifilter]) begin
      cov_filter_reset = regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "WD_RST");
      cov_filter_type = regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "FILTER_TYPE");
      cov_int_en = regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "INT_EN");
     case(regblock.get_field_value($sformatf("FILTER_CTRL%0d", ifilter+1), "WINDOW_SIZE"))
        4'b0000: begin
            cov_window_size = 4;
        end
        4'b0001: begin
            cov_window_size = 8;
        end
        4'b0010: begin
            cov_window_size = 16;
        end
        4'b0011: begin
            cov_window_size = 32;
        end
        4'b0100: begin
           cov_window_size = 48;
        end
        4'b0101: begin
            cov_window_size = 64;
        end
        4'b0110: begin
            cov_window_size = 128;
        end
        4'b0111: begin
            cov_window_size = 256;
        end
        4'b1000: begin
            cov_window_size = 512;
        end
        4'b1001: begin
            cov_window_size = 640;
        end
        4'b1010: begin
            cov_window_size = 768;
        end
        4'b1011: begin
            cov_window_size = 896;
        end
        4'b1100: begin
            cov_window_size = 1024;
        end
        4'b1101: begin
            cov_window_size = 1280;
        end
        4'b1110: begin
            cov_window_size = 1536;
        end
        4'b1111: begin
            cov_window_size = 2048;
        end
     endcase
     `uvm_info("ifx_dig_coverage", $sformatf("Sample for cov_filter_reset %s, cov_filter_type %s, cov_int_en %0b, cov_window_size %0d.", cov_filter_reset.name(), cov_filter_type.name(), cov_int_en, cov_window_size), UVM_DEBUG)
     cg_filter_ctrl.sample();
     `uvm_info("ifx_dig_coverage", $sformatf("Coverage for cg_filter_ctrl %0.9f%%.", cg_filter_ctrl.get_coverage()), UVM_DEBUG)
    end
  end
endtask

covergroup cg_filter_ctrl with function sample();
  option.per_instance = 1;
  option.name = "cg_filter_ctrl";

  cp_filter_reset: coverpoint cov_filter_reset{
    bins async_reset = {FILT_ASYNC_RESET};
    bins sync_reset = {FILT_SYNC_RESET};
  }
  cp_filter_type: coverpoint cov_filter_type{
    bins filter_disabled = {2'b00};
    bins rise_filter = {2'b01};
    bins fall_filter = {2'b10};
    bins rise_fall_filter = {2'b11};
  }
  cp_window_size: coverpoint cov_window_size{
     bins low_range = {[4:32]};
     bins middle_range_0 = {[48:256]};
     bins middle_range_1 = {[512:896]};
     bins high_range = {[1024:2048]};
  }
  cp_int_en: coverpoint cov_int_en{
    bins int_dis = {1'b0};
    bins int_en = {1'b1};
  }

  cx_filter_type_x_window_size: cross cp_filter_type, cp_window_size;
  cx_filter_type_x_int_en: cross cp_filter_type, cp_int_en;
  cx_filter_reset_x_filter_type: cross cp_filter_reset, cp_filter_type;
endgroup

//TODO: Add covergroup to prove interrupt status was set regardless of
// selected filter type
