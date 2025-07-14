/******************************************************************************
 * (C) Copyright 2019 All Rights Reserved
 *
 * MODULE:
 * DEVICE:
 * PROJECT:
 * AUTHOR:
 * DATE:
 * FILE: ifx_dig_config
 * REVISION:
 *
 * FILE DESCRIPTION:
 *
 *******************************************************************************/
typedef ifx_dig_env;

class ifx_dig_config extends uvm_object;

    `uvm_object_utils(ifx_dig_config)

    //=========================================================================
    // UVC configurations.
    //-------------------------------------------------------------------------
    //=========================================================================

    ifx_dig_data_bus_uvc_config data_bus_uvc_cfg;
    ifx_dig_pin_filter_uvc_config pin_filter_uvc_cfg[`FILT_NB-1:0]; // array of pin filter UVC configurations

    //=========================================================================
    // Pointers.
    //-------------------------------------------------------------------------
    //=========================================================================
    ifx_dig_env   p_env;

    //=========================================================================
    // Interfaces.
    //-------------------------------------------------------------------------
    //=========================================================================
    virtual interface   ifx_dig_interface   dig_vif;

    //=========================================================================
    // Constraints.
    //-------------------------------------------------------------------------
    //=========================================================================

    //=========================================================================
    // Methods.
    //-------------------------------------------------------------------------
    //=========================================================================
    function new( string name = "ifx_dig_config" );
        super.new(name);

        // create sub-configurations
        // HINT --  create here instances for data_bus_uvc config
        data_bus_uvc_cfg        = ifx_dig_data_bus_uvc_config::type_id::create("data_bus_uvc_cfg");
        // create pin filter UVC configurations
        for (int i = 0; i < `FILT_NB; i++) begin
            pin_filter_uvc_cfg[i] = ifx_dig_pin_filter_uvc_config::type_id::create($sformatf("pin_filter_uvc_cfg[%0d]", i));
        end

        initialize_configs();
    endfunction : new


    /*
     * configure the UVCs based on current configuration
     */
    function void initialize_configs();


        data_bus_uvc_cfg.invalid_address = new[(2**`AWIDTH) - `NO_CFG_REGS - `NO_STATUS_REGS];
        for (int addr = `NO_CFG_REGS + `NO_STATUS_REGS; addr < 2**`AWIDTH; addr++) begin
            // set all addresses as invalid, except the ones used for configuration and status
            data_bus_uvc_cfg.invalid_address[addr - `NO_CFG_REGS - `NO_STATUS_REGS] = {addr[`AWIDTH-1:0]};
        end

        for (int i = 0; i < `FILT_NB; i++) begin
            // fixed configuration, would not be changed during the simulation
            pin_filter_uvc_cfg[i].filter_synchronization_stage_sel = FILT_SYNC_DOUBLE; // 2 stage synchronizer
            pin_filter_uvc_cfg[i].id                               = i;                // set filter ID
            // dynamic configuration, can be changed during the simulation through registers
            pin_filter_uvc_cfg[i].filter_reset_sel                 = FILT_ASYNC_RESET;
            pin_filter_uvc_cfg[i].filter_type                      = FILT_DISABLED; // default filter type is disabled
            pin_filter_uvc_cfg[i].rise_filt_length_clk             = 4;
            pin_filter_uvc_cfg[i].fall_filt_length_clk             = 4;
        end

    endfunction

endclass// ifx_dig_config
