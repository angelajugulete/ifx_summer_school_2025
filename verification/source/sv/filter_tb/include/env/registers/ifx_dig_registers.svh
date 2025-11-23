/*
 * base class for the registers. Contains the common methods for all registers.
 */
class ifx_dig_reg extends uvm_object;

    `uvm_object_utils(ifx_dig_reg)

    ifx_dig_field fields_list[];
    protected int address;

    string class_name;
    int nb_filters;
    int left_nb_filters;
    int start_index;

    function new(string name = "ifx_dig_reg");
        super.new(name);
    endfunction

    /*
     * Configures the register with the given address.
     * @param address - address of the register
     * NOTE: must be called only in once during the build phase
     */
    function void configure(int address);
        this.address = address;
    endfunction

    function void build();

    endfunction

     /*
     * sets the value to the field to a desired value.
     * Takes effect only if the field access type is not RES.
     * NOTE: must be used only in the context of updating the field value as a result of an internal operation (except operation through the data transfer protocol).
     */
    function void predict_field_value(string field_name, int value);
        bit found;

        foreach(fields_list[idx]) begin
            if(fields_list[idx].get_name() == field_name) begin
                fields_list[idx].predict_value(value);
                found = 1;
                break;
            end
        end
        if(!found)
            `uvm_fatal(get_type_name(), $sformatf("Invalid field name %s for register %p", field_name, this.get_name()))
    endfunction


     /*
     * sets the value to the field after a "WRITE" operation through the data transfer protocol.
     * Takes effect only if the field access type is W or RW.
     * NOTE: must be used only in the context of a write operation through the data transfer protocol.
     */
    function void write_field_value(string field_name, int value);
        bit found;

        foreach(fields_list[idx]) begin
            if(fields_list[idx].get_name() == field_name) begin
                fields_list[idx].write_value(value);
                found = 1;
                break;
            end
        end
        if(!found)
            `uvm_fatal(get_type_name(), $sformatf("Invalid field name %s for register %p", field_name, this.get_name()))
    endfunction


    /*
     * returns the value of a given field in a register.
     * If the field is not found, it raises an error.
     */
    function int get_field_value(string field_name);
        foreach(fields_list[idx]) begin
            if(fields_list[idx].get_name() == field_name) begin
                return fields_list[idx].get_value();
            end
        end
        `uvm_fatal(get_type_name(), $sformatf("Invalid field name %s for register %p", field_name, this.get_name()))
    endfunction

     /*
     * sets the value of a given register to a desired value.
     * Takes effect only to the fields where the access type is not RES.
     * NOTE: must be used only in the context of updating the register value as a result of an internal operation (except operation through the data transfer protocol).
     */
    function void predict_reg_value(int value);
        foreach(fields_list[idx]) begin
            int mask = (2**fields_list[idx].get_size() -1) << fields_list[idx].get_lsb_possition();
            fields_list[idx].predict_value( (value & mask) >> fields_list[idx].get_lsb_possition());
        end
    endfunction

    /*
     * sets the value to the register after a "WRITE" operation through the data transfer protocol.
     * Takes effect only on the fields where the access type is W or RW.
     * NOTE: must be used only in the context of a write operation through the data transfer protocol.
     */
    function void write_reg_value(int value);
        foreach(fields_list[idx]) begin
            int mask = (2**fields_list[idx].get_size() -1) << fields_list[idx].get_lsb_possition();
            fields_list[idx].write_value( (value & mask) >> fields_list[idx].get_lsb_possition());
        end
    endfunction

    /*
     * Returns the value of the register.
     * If allow_update is set to 1, the value is updated based on the access type.
     */
    function int get_reg_value(bit allow_update = 0);
        int value;
        foreach(fields_list[idx]) begin
            value += (fields_list[idx].get_value(.allow_update(allow_update)) << fields_list[idx].get_lsb_possition());
        end
        return value;
    endfunction

    /*
     * return the address of the register.
     */
    function int get_address();
        return address;
    endfunction

    /*
     * resets the register fields to their reset values.
     */
    function void reset();
        foreach(fields_list[idx]) begin
            fields_list[idx].reset();
        end
    endfunction


    /*
     * return the field object by its name.
     * If the field is not found, it raises an error.
     */
    function ifx_dig_field get_field_by_name(string field_name);
        foreach(fields_list[idx]) begin
            if(fields_list[idx].get_name() == field_name) begin
                return fields_list[idx];
            end
        end
        `uvm_fatal(get_type_name(), $sformatf("Invalid field name %s for register %p", field_name, this.get_name()))
    endfunction

endclass


/*
 * Class for the interrupt status register.
 * Contains an array of interrupt fields, one for each filter.
 * The fiels names are deduced from the register instance name
 */
class ifx_dig_reg_INT_STATUS extends ifx_dig_reg;

    `uvm_object_utils(ifx_dig_reg_INT_STATUS)

    ifx_dig_field in_int [];
    string inst_nb;
    int k = 0;

    function new(string name = "INT_STATUS");
        super.new(name);
    endfunction

    function void build();
        class_name = this.get_name();
        nb_filters = `FILT_NB;
        if(nb_filters <= 8)begin
            in_int = new[nb_filters];
            for(int i = 0; i < nb_filters; i++)begin
                in_int[i] = ifx_dig_field::type_id::create($sformatf("IN%0d_INT", i+1));
                in_int[i].configure(.bit_size(1), .offset(i), .rst_value(0), .acc_type(RC));
                `uvm_info(get_name(), $sformatf("Created field IN%0d_INT.", i+1), UVM_DEBUG)
            end
        end else begin
            inst_nb         = class_name.substr(10, 10);
            start_index     = 8 * (inst_nb.atoi() - 1);
            left_nb_filters = nb_filters - (inst_nb.atoi() - 1)*8;
            if(left_nb_filters >= 8)begin
                in_int = new[8];
                for(int i = start_index; i < start_index + 8; i++)begin
                    in_int[k] = ifx_dig_field::type_id::create($sformatf("IN%0d_INT", i+1));
                    in_int[k].configure(.bit_size(1), .offset(k++), .rst_value(0), .acc_type(RC));
                    `uvm_info(get_name(), $sformatf("Created field IN%0d_INT.", i+1), UVM_DEBUG)
                end
            end
            else begin
                in_int = new[left_nb_filters];
                for(int i = start_index; i < start_index + left_nb_filters; i++)begin
                    in_int[k] = ifx_dig_field::type_id::create($sformatf("IN%0d_INT", i+1));
                    in_int[k].configure(.bit_size(1), .offset(k++), .rst_value(0), .acc_type(RC));
                    `uvm_info(get_name(), $sformatf("Created field IN%0d_INT.", i+1), UVM_DEBUG)
                end
            end
        end

        fields_list = {in_int};
    endfunction
endclass


/*
 * Class for the filter control register.
 * Contains fields for filter type, window size, interrupt enable, and watchdog reset.
 */
class ifx_dig_reg_FILTER_CTRL extends ifx_dig_reg;

    `uvm_object_utils(ifx_dig_reg_FILTER_CTRL)

    // TODO: Declare register fields

    function new(string name = "FILTER_CTRL");
        super.new(name);
    endfunction

    // TODO: Implement build function that creates and configures the registr fields
    function void build();

    endfunction
endclass
