module Filter
(
    input logic clk_i,
    input logic rstn_i,
    input logic int_en,
    input logic sync_data_in,
    input logic [1:0] filter_type,
    input logic [3:0] window_size,
    
    output logic int_pulse_out_filter, // Pulsul de intrerupere generat de acest filtru
    output logic data_out              // Iesirea filtrata
);

// flip-flop pentru data_sync_delay (il intarzii cu un clock) 
logic data_sync_delay;

always_ff @(posedge clk_i or negedge rstn_i) begin
    if (rstn_i == 0)
        data_sync_delay <= 0;
    else 
        data_sync_delay <= sync_data_in; // Preia valoarea sync_data_in intarziata cu 1 ciclu de ceas
end

// Detectii de fronturi
logic rise, fall, both;
assign rise = sync_data_in & (~data_sync_delay);   // Detecteaza frontul crescator (0 la 1)
assign fall = (~sync_data_in) & data_sync_delay;   // Detecteaza frontul descrescator (1 la 0)
assign both = rise || fall;                        // Detecteaza orice schimbare de front (rise sau fall)

// Declarare si mapare pentru valoarea de incarcare (durata de stabilitate)
logic [10:0] counter, load_value;

always_comb begin
    case (window_size)
        4'd0:  load_value = 11'd4;     // 4
        4'd1:  load_value = 11'd8;
        4'd2:  load_value = 11'd16;
        4'd3:  load_value = 11'd32;
        4'd4:  load_value = 11'd48;
        4'd5:  load_value = 11'd64;
        4'd6:  load_value = 11'd128;
        4'd7:  load_value = 11'd256;
        4'd8:  load_value = 11'd512;
        4'd9:  load_value = 11'd640;
        4'd10: load_value = 11'd768;
        4'd11: load_value = 11'd896;
        4'd12: load_value = 11'd1024;
        4'd13: load_value = 11'd1280;
        4'd14: load_value = 11'd1536;
        4'd15: load_value = 11'd2040;
        default: load_value = 11'd4;
    endcase
end

// Contor care se incarca daca semnalul ramane stabil
always_ff @(posedge clk_i or negedge rstn_i) begin
    if (rstn_i == 0)
        counter <= 0;
    else if (filter_type == 2'b00)
        counter <= 0;
    else if ((filter_type == 2'b01 && sync_data_in == 0) || 
             (filter_type == 2'b10 && sync_data_in == 1))
        counter <= 0;
    else if ((filter_type == 2'b01 && rise == 1) || 
             (filter_type == 2'b10 && fall == 1) || 
             (filter_type == 2'b11 && both == 1))
        counter <= load_value;
    else if (((filter_type == 2'b01 && rise == 0 && sync_data_in == 1 && counter > 0) ||
              (filter_type == 2'b10 && fall == 0 && sync_data_in == 0 && counter > 0) ||
              (filter_type == 2'b11 && both == 0 && data_out == ~sync_data_in && counter > 0)))
        counter <= counter - 1;
end

// Generarea pulsului de întrerupere (int_pulse_out_filter)
always_ff @(posedge clk_i or negedge rstn_i) begin
    if (rstn_i == 0)
        int_pulse_out_filter <= 0; // Reset
    else
        int_pulse_out_filter <= (int_en && counter == 1); // Genereaza puls cand expira
end

// data_out ar trebui sa se schimbe doar dupa ce sync_data_in a ramas stabil
// la un anumit nivel pentru o durata egala cu window_size.
always_ff @(posedge clk_i or negedge rstn_i) begin 
    if (rstn_i == 0)
        data_out <= 0;
    else if (counter == 1)
        data_out <= ~data_out;
    else if (filter_type == 2'b01 && sync_data_in == 0)
        data_out <= 0;
    else if (filter_type == 2'b10 && sync_data_in == 1)
        data_out <= 1;
    else
        data_out <= sync_data_in;
end

endmodule
