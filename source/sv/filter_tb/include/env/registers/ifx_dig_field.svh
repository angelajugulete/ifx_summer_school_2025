
typedef enum int {
    R,   // allows only read operation - writing to this field has no effect
    W,   // allows only write operation - reading from this field returns 0
    RW,  // allows both read and write operations
    RES, // allows only read operation - writing to this field has no effect. Always returns reset value
    RC   // allows only read operation - writing to this field has no effect. After a read the value is reset to 0
} field_access_type_t;

class ifx_dig_field extends uvm_object;

    `uvm_object_utils(ifx_dig_field)

    protected int rst_value;                // holds the reset value of the field
    protected int value;                    // holds the current value of the field
    protected field_access_type_t acc_type; // holds the access type of the field (R, W, RW, RES, RC)
    protected int bit_size;                 // holds the number of bits in the field
    protected int offset;                   // holds the offset of the field in the register

    function new(string name="");
        super.new(name);
    endfunction

    /*
     * Configures the field with the given parameters.
     * @param bit_size - number of bits in the field
     * @param offset - offset of the field in the register
     * @param rst_value - reset value of the field
     * @param acc_type - access type of the field (R, W, RW, RES, RC)
     * NOTE: must be called only in once during the build phase
     */
    function void configure(
            int bit_size,
            int offset,
            int rst_value,
            field_access_type_t acc_type
        );
        this.bit_size  = bit_size;
        this.offset    = offset;
        this.rst_value = rst_value;
        this.value     = rst_value; //register starts with reset value
        this.acc_type  = acc_type;
    endfunction

    /*
     * return the least significant bit position in the field
     */
    function int get_lsb_possition();
        return offset;
    endfunction

    /*
     * returns the most significant bit position in the field
     */
    function int get_msb_possition();
        return offset+bit_size-1;
    endfunction

    /*
     * returns the number of bits in the field.
     */
    function int get_size();
        return bit_size;
    endfunction

    /*
     * sets the field value to the reset value.
     */
    function void reset();
        value = rst_value;
    endfunction

    /*
     * sets the value to the field to a desired value.
     * Takes effect only if the field access type is not RES.
     * NOTE: must be used only in the context of updating the field value as a result of an internal operation (except operation through the data transfer protocol).
     */
    function void predict_value(int value);
        if(!(acc_type inside {RES}))
            this.value = (2**bit_size -1) & value;
    endfunction

    /*
     * sets the value to the field after a "WRITE" operation through the data transfer protocol.
     * Takes effect only if the field access type is W or RW.
     * NOTE: must be used only in the context of a write operation through the data transfer protocol.
     */
    function void write_value(int value);
        if(acc_type inside {W, RW})
            this.value = (2**bit_size -1) & value;
    endfunction

    /*
     * return the value of the field.
     * If allow_update is set to 1, the value is updated based on the access type
     */
    function int get_value( bit allow_update = 0);
        int value_to_return;

        if(acc_type == W)
            return 0;
        else if(acc_type == RC)begin
            value_to_return = value;
            if(allow_update)
                value = 0; // reset the value to 0 after reading
            return value_to_return;
        end else
            return value;
    endfunction

endclass
