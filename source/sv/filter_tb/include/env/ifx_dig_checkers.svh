////////////////////////////////////////////////////////////////////////////////
// (C) Copyright 2019 <Infineon Technologies Romania> All Rights Reserved
//
// MODULE:
// COMPLIANCE:
// AUTHOR:
// DATE:
// UPDATE:
// ABSTRACT:
// COMMENTS:
////////////////////////////////////////////////////////////////////////////////

/*
 * TODO: Implement function checks that the data received from the address is the same as the one stored in the register block.
 * NOTE: This function should always be called after a read access to a register.
 */
function void check_read_data(int address, int read_data);
    ifx_dig_reg reg_obj = regblock.get_reg_by_address(address);

endfunction

task do_checkers();

    wait(dig_vif.rstn_i == 0); // wait for reset, otherwise DUT signals are not initialized
    `WAIT_NS(1)                // wait for the reset to propagate

    fork

        forever begin
            /*
             * Compare directly the int_pulse_out_gm signal with the int_pulse_out signal from the digital interface.
             * This is executed at simulation start and after each change of the DUT or the expected output value
             */
            dchk_01_int_pulse_out: assert (int_pulse_out_gm === dig_vif.int_pulse_out)
            else
                `uvm_error("dchk_01_int_pulse_out", $sformatf("int_pulse_out_gm (%b) does not match dig_vif.int_pulse_out (%b)", int_pulse_out_gm, dig_vif.int_pulse_out));

            @(int_pulse_out_gm, dig_vif.int_pulse_out);
            `WAIT_NS(1) // delay needed to allow the update of int_pulse_out_gm and avoid race conditions with the DUT
        end

        for(int ifilt=0; ifilt < `FILT_NB; ifilt++) begin
            automatic int ifilt_aux = ifilt; // each thread below must
            fork
                forever begin
                    /*
                     * Compare the data_out_gm signal with the data_out signal from the digital interface.
                     * This is executed at simulation start and after each change of the DUT or the expected output value
                     */
                    dchk_02_data_out: assert (data_out_gm[ifilt_aux] === dig_vif.data_out[ifilt_aux])
                    else
                        `uvm_error("dchk_02_data_out", $sformatf("data_out_gm[%0d] (%b) does not match dig_vif.data_out[%0d] (%b)", ifilt_aux, data_out_gm[ifilt_aux], ifilt_aux, dig_vif.data_out[ifilt_aux]));
                    @(data_out_gm[ifilt_aux], dig_vif.data_out[ifilt_aux]);
                    `WAIT_NS(1) // delay needed to allow the update of data_out_gm and avoid race conditions with the DUT
                end
            join_none
        end

    join
endtask
