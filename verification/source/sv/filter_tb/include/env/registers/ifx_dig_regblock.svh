class ifx_dig_regblock extends uvm_object;
    `uvm_object_utils(ifx_dig_regblock)

    ifx_dig_reg_FILTER_CTRL FILTER_CTRL []; // filter control registers
    ifx_dig_reg_INT_STATUS INT_STATUS [];   // filter interrupt status registers

    int nb_filters_ctrl_regs = `NO_CFG_REGS;    // number of filter control registers
    int nb_int_status_regs   = `NO_STATUS_REGS; // number of interrupt status registers

    function new(string name = "ifx_dig_regblock");
        super.new(name);
    endfunction


    /*
     * Instantiate all registers in the register block.
     */
    function void build();
        `uvm_info(get_name(), $sformatf("Nb_filters %0d.", nb_filters_ctrl_regs), UVM_DEBUG)
        FILTER_CTRL = new[nb_filters_ctrl_regs];
        for(int i = 0; i < nb_filters_ctrl_regs; i++)begin
            FILTER_CTRL[i] = ifx_dig_reg_FILTER_CTRL::type_id::create($sformatf("FILTER_CTRL%0d", i+1));
            `uvm_info(get_name(), $sformatf("Created register FILTER_CTRL%0d.", i+1), UVM_DEBUG)
            FILTER_CTRL[i].configure(.address(i));
            FILTER_CTRL[i].build();
        end

        INT_STATUS = new[nb_int_status_regs];
        for(int i = 0; i < nb_int_status_regs; i++)begin
            INT_STATUS[i] = ifx_dig_reg_INT_STATUS::type_id::create($sformatf("INT_STATUS%0d", i+1));
            `uvm_info(get_name(), $sformatf("Created register INT_STATUS%0d.", i+1), UVM_DEBUG)
            INT_STATUS[i].configure(.address(i + nb_filters_ctrl_regs));
            INT_STATUS[i].build();
        end

    endfunction

    /*
     * TODO: return the register object by its name.
     * If the register is not found, return null.
     */
    function ifx_dig_reg get_reg_by_name(string reg_name);
        string flt_reg;
        string int_reg;
        int k = 0;
    endfunction


    /*
     * return the register object by its address.
     * If the register is not found, return null.
     */
    function ifx_dig_reg get_reg_by_address(int address);
        if(address < nb_filters_ctrl_regs)
            return FILTER_CTRL[address];
        else if(address >= nb_filters_ctrl_regs && address < nb_filters_ctrl_regs + nb_int_status_regs)
            return INT_STATUS[address - nb_filters_ctrl_regs];
        else
            return null; // no register at other addresses
    endfunction


    /*
     * return the register name by its address.
     * If the address is not valid, return an empty string.
     */
    function string get_reg_name_by_address(int address);
        if(address < nb_filters_ctrl_regs)
            return $sformatf("FILTER_CTRL%0d", address+1);
        else if(address >= nb_filters_ctrl_regs && address < nb_filters_ctrl_regs + nb_int_status_regs)
            return $sformatf("INT_STATUS%0d", address - nb_filters_ctrl_regs + 1);
        else
            return "";
    endfunction

    /*
     * sets the value of a given field in a register to a desired value.
     * Takes effect only if the field access type is not RES.
     * NOTE: must be used only in the context of updating the field value as a result of an internal operation (except operation through the data transfer protocol).
     */
    function void predict_field_value(string reg_name, string field_name, int value);
        ifx_dig_reg reg_obj = get_reg_by_name(reg_name);
        if(reg_obj == null) begin
            `uvm_fatal(get_type_name(), $sformatf("Register %s not found.", reg_name))
            return;
        end
        reg_obj.predict_field_value(field_name, value);
    endfunction

    /*
     * sets the value of a given field in a register after a "WRITE" operation through the data transfer protocol.
     * Takes effect only if the field access type is W or RW.
     * NOTE: must be used only in the context of a write operation through the data transfer protocol.
     */
    function void write_field_value(string reg_name, string field_name, int value);
        ifx_dig_reg reg_obj = get_reg_by_name(reg_name);
        if(reg_obj == null) begin
            `uvm_fatal(get_type_name(), $sformatf("Register %s not found.", reg_name))
            return;
        end
        reg_obj.write_field_value(field_name, value);
    endfunction

    /*
     * returns the value of a given field in a register.
     * If the field is not found, it raises an error.
     */
    function int get_field_value(string reg_name, string field_name);
        ifx_dig_reg reg_obj = get_reg_by_name(reg_name);
        if(reg_obj == null) begin
            `uvm_fatal(get_type_name(), $sformatf("Register %s not found.", reg_name))
            return -1; // return an invalid value
        end
        return reg_obj.get_field_value(field_name);
    endfunction

    /*
     * sets the value of a given register to a desired value.
     * Takes effect only to the fields where the access type is not RES.
     * NOTE: must be used only in the context of updating the register value as a result of an internal operation (except operation through the data transfer protocol).
     */
    function void predict_reg_value(string reg_name, int value);
        ifx_dig_reg reg_obj = get_reg_by_name(reg_name);
        reg_obj.predict_reg_value(value);
    endfunction

    /*
     * sets the value to the register after a "WRITE" operation through the data transfer protocol.
     * Takes effect only on the fields where the access type is W or RW.
     * NOTE: must be used only in the context of a write operation through the data transfer protocol.
     */
    function void write_reg_value(string reg_name, int value);
        ifx_dig_reg reg_obj = get_reg_by_name(reg_name);
        if(reg_obj == null) begin
            `uvm_fatal(get_type_name(), $sformatf("Register %s not found.", reg_name))
            return;
        end
        reg_obj.write_reg_value(value);
    endfunction

    /*
     * return the value of a given register.
     * If the register is not found, it raises an error.
     */
    function int get_reg_value(string reg_name);
        ifx_dig_reg reg_obj = get_reg_by_name(reg_name);
        if(reg_obj == null) begin
            `uvm_fatal(get_type_name(), $sformatf("Register %s not found.", reg_name))
            return -1; // return an invalid value
        end
        return reg_obj.get_reg_value();
    endfunction

    /*
     * resets all registers in the register block to their reset values.
     */
    function void reset();
        for(int i = 0; i < nb_filters_ctrl_regs; i++)begin
            FILTER_CTRL[i].reset();
        end

        for(int i = 0; i < nb_int_status_regs; i++)begin
            INT_STATUS[i].reset();
        end
    endfunction

endclass
