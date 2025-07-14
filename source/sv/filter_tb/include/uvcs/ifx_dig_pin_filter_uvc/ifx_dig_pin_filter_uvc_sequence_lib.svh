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

/// base sequence, serves as a starting point for all other filter_uvc sequences - not to be used directly
class ifx_dig_pin_filter_uvc_base_sequence extends uvm_sequence #(ifx_dig_pin_filter_uvc_seq_item);

    `uvm_object_utils(ifx_dig_pin_filter_uvc_base_sequence)

    ifx_dig_pin_filter_uvc_sequencer p_sequencer;
    uvm_sequencer_base parent_sequencer_generic;


    ifx_dig_pin_filter_uvc_seq_item seq_item;

    rand filt_drive_t drive_type; // selects the type of driving


    //Constructor
    function new(string name="");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();
        parent_sequencer_generic = get_sequencer();
        $cast(p_sequencer, parent_sequencer_generic);
        // create the item in here to always have seq_item.m_sequencer set automatically to the sequence was started on
        `uvm_create(seq_item)// create the sequence item object
    endtask

    // raise objections before the driving starts
    task pre_body();
        if (starting_phase != null) begin
            starting_phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
        end
    endtask

    task body();
        `uvm_error(get_type_name(), "This is a base sequence, it should not be executed directly. Please extend this sequence and implement the body() method.")
    endtask

    // drop the objections after the driving ends
    task post_body();
        if (starting_phase != null) begin
            starting_phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
        end
    endtask

endclass


// sequence that drives a pulse of a given length in clock cycles
class ifx_dig_pin_filter_uvc_pulse_sequence extends ifx_dig_pin_filter_uvc_base_sequence;

    `uvm_object_utils(ifx_dig_pin_filter_uvc_pulse_sequence)

    rand int pulse_length_clk;         // pulse length in clock cycles for drive_type = FILT_DRV_PULSE
    rand filt_edge_t filt_edge;        // tells if the driving occurs on rising or falling edge
    rand bit driving_edge_auto_select; // if set to 1, the driving level will be automatically selected based on the current interface value for filters with both rising and falling

    constraint pulse_length_constraint {
        soft pulse_length_clk inside {[10:100]};
    }

    constraint level_contrains {
        soft driving_edge_auto_select == 1;
    }

    function new(string name="");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();
    endtask

    virtual task body();
        seq_item.randomize(); // randomize item
        // override necessary fields
        seq_item.drive_type               = FILT_DRV_PULSE;
        seq_item.filt_edge                = filt_edge;
        seq_item.pulse_length_clk         = pulse_length_clk;
        seq_item.driving_edge_auto_select = driving_edge_auto_select;

        `uvm_info(get_type_name(), $sformatf("Executing sequence with parameters drive_type=%p pulse_length_clk=%0d driving_edge_auto_select=%0d", seq_item.drive_type, seq_item.pulse_length_clk, seq_item.driving_edge_auto_select), UVM_MEDIUM)

        `uvm_send(seq_item) // send the object to the sequencer
    endtask
endclass

//TODO: wriet sequence that drives a valid pulse
class ifx_dig_pin_filter_uvc_valid_pulse_sequence extends ifx_dig_pin_filter_uvc_base_sequence;

    `uvm_object_utils(ifx_dig_pin_filter_uvc_valid_pulse_sequence)

   
    function new(string name="");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();
    endtask

    // TODO: Implement logic for driving the requested valid pulse
    virtual task body();
        seq_item.randomize(); // randomize item
        //HINT: override necessary fields

        //HINT: send the object to the sequencer
    endtask
endclass


// generic sequence that is able to drive any type of driving
class ifx_dig_pin_filter_uvc_generic_sequence extends ifx_dig_pin_filter_uvc_base_sequence;
    `uvm_object_utils(ifx_dig_pin_filter_uvc_generic_sequence)

    rand filt_drive_t drive_type;      // selects the type of driving
    rand filt_edge_t filt_edge;        // tells if the filtering occurs on rising or falling edge
    rand bit driving_edge_auto_select; // if set to 1, the driving level will be automatically selected based on the filter lengths (rising or falling)
    rand int pulse_length_clk;         // pulse length in clock cycles for drive_type = FILT_DRV_PULSE

    constraint pulse_length_constraint {
        soft pulse_length_clk inside {[10:100]};
    }
    constraint level_contrains {
        soft driving_edge_auto_select == 1;
    }

    function new(string name="");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();
    endtask

    virtual task body();
        seq_item.randomize() with {
            // HINT we add "local" because the name of the variable is the same as the sequence item which results in the reandomization not taking the value from the sequence
            seq_item.drive_type                == local::drive_type;
            seq_item.filt_edge                 == local::filt_edge;
            seq_item.driving_edge_auto_select  == local::driving_edge_auto_select;
            seq_item.pulse_length_clk          == local::pulse_length_clk;
        };

        `uvm_info(get_type_name(), $sformatf("Executing sequence with parameters drive_type=%p filt_edge=%p driving_edge_auto_select=%0d pulse_length_clk=%0d", seq_item.drive_type, seq_item.filt_edge, seq_item.driving_edge_auto_select, seq_item.pulse_length_clk), UVM_MEDIUM)

        `uvm_send(seq_item) // send the object to the sequencer
    endtask
endclass


// sequence that drives a train of invalid pulses (multiple invalid pulses one after another). The pulses have a minimum of 1 clock cycle and the sum of pulses is greater than the valid filter length.
class ifx_dig_pin_filter_uvc_invalid_pulse_train_sequence extends ifx_dig_pin_filter_uvc_base_sequence;

    `uvm_object_utils(ifx_dig_pin_filter_uvc_invalid_pulse_train_sequence)

    rand int no_pulses;                // number of invalid pulses to drive
    rand int pulse_gap_clk;            // gap between the invalid pulses in clock cycles

    constraint no_pulses_constraint {
        soft no_pulses inside {[2:5]};
    }
    constraint pulse_gap_constraint {
        soft pulse_gap_clk inside {[1:5]}; // at least 1 clock cycle gap between the pulses so they would be seen independently
    }

    function new(string name="");
        super.new(name);
    endfunction

    virtual task pre_start();
        super.pre_start();
    endtask

    virtual task body();
        int pulses_clk[];    // array to hold the clock cycles for each pulse
        int filt_length_clk; // holds filter length in clock cycles

        if(p_sequencer.cfg.filter_type inside {FILT_RISING, FILT_BOTH}) begin
            filt_length_clk = p_sequencer.cfg.rise_filt_length_clk;

            std::randomize(pulses_clk) with {
                pulses_clk.size() == no_pulses; // size of the array is equal to the number of pulses
                foreach (pulses_clk[i]) {
                    pulses_clk[i] inside {[1:filt_length_clk-1]}; // each pulse is at least 1 clock cycle long and smaller than the valid filter length
                }
                pulses_clk.sum() > filt_length_clk; // the sum of all pulses is greater than the valid filter length
            };

            // Set the pin level to 0 before driving the pulses for the rising edge filter
            seq_item.drive_type                = FILT_DRV_PULSE;
            seq_item.filt_edge                 = FILT_FALL_EDGE;
            seq_item.pulse_length_clk          = p_sequencer.cfg.fall_filt_length_clk+1; // wait for at least the falling filter time
            seq_item.driving_edge_auto_select  = 0;
            `uvm_send(seq_item)

            foreach(pulses_clk[ip]) begin
                // invalid pulse
                seq_item.drive_type                = FILT_DRV_PULSE;
                seq_item.filt_edge                 = FILT_RISE_EDGE;
                seq_item.pulse_length_clk          = pulses_clk[ip];
                seq_item.driving_edge_auto_select  = 0;
                `uvm_send(seq_item)

                // pulse gap
                seq_item.drive_type                = FILT_DRV_PULSE;
                seq_item.filt_edge                 = FILT_FALL_EDGE;
                seq_item.pulse_length_clk          = pulse_gap_clk;
                seq_item.driving_edge_auto_select  = 0;
                `uvm_send(seq_item)
            end
        end

        if(p_sequencer.cfg.filter_type inside {FILT_FALLING, FILT_BOTH}) begin
            filt_length_clk = p_sequencer.cfg.fall_filt_length_clk;

            std::randomize(pulses_clk) with {
                pulses_clk.size() == no_pulses; // size of the array is equal to the number of pulses
                foreach (pulses_clk[i]) {
                    pulses_clk[i] inside {[1:filt_length_clk-1]}; // each pulse is at least 1 clock cycle long and smaller than the valid filter length
                }
                pulses_clk.sum() > filt_length_clk; // the sum of all pulses is greater than the valid filter length
            };

            // Set the pin level to 0 before driving the pulses for the rising edge filter
            seq_item.drive_type                = FILT_DRV_PULSE;
            seq_item.filt_edge                 = FILT_RISE_EDGE;
            seq_item.pulse_length_clk          = p_sequencer.cfg.rise_filt_length_clk+1; // wait for at least the falling filter time
            seq_item.driving_edge_auto_select  = 0;
            `uvm_send(seq_item)

            foreach(pulses_clk[ip]) begin
                // invalid pulse
                seq_item.drive_type                = FILT_DRV_PULSE;
                seq_item.filt_edge                 = FILT_FALL_EDGE;
                seq_item.pulse_length_clk          = pulses_clk[ip];
                seq_item.driving_edge_auto_select  = 0;
                `uvm_send(seq_item)

                // pulse gap
                seq_item.drive_type                = FILT_DRV_PULSE;
                seq_item.filt_edge                 = FILT_RISE_EDGE;
                seq_item.pulse_length_clk          = pulse_gap_clk;
                seq_item.driving_edge_auto_select  = 0;
                `uvm_send(seq_item)
            end
        end

    endtask
endclass
