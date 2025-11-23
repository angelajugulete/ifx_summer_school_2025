module Sincronizator // pentru a evita meta-stabilitatea
(
    input  logic clk_i,      // ceas
    input  logic rstn_i,     // reset asincron, activ pe 0
    input  logic wd_rst,     // semnal de selectie (echivalent cu 'sel')
    input  logic data_in,    // datele de intrare asincrone
    output logic data_sync_out // datele sincronizate la iesire
);

// registre interne
logic sinc1_out, sinc2_out;
logic r1, r2;

// primul sincronizator (clasic flip-flop dublu)
always_ff @(posedge clk_i or negedge rstn_i) begin // Resetarea este asincron?
    if (rstn_i == 0) begin
        r1 <= 0;
        sinc1_out <= 0;
    end else begin // Altfel, pe frontul pozitiv al ceasului
        r1 <= data_in;        // primul flip-flop
        sinc1_out <= r1;      // al doilea flip-flop
    end
end

// reset condi?ionat - dependent ?i de data_in
logic rstn_new;
assign rstn_new = (rstn_i && data_in);

// al doilea sincronizator, folosit când wd_rst = 0
always_ff @(posedge clk_i or negedge rstn_new) begin
    if (rstn_new == 0) begin
        r2 <= 0;
        sinc2_out <= 0;
    end else begin
        r2 <= data_in;
        sinc2_out <= r2;
    end
end    

// selectarea ie?irii în func?ie de wd_rst
always_comb begin
    if (wd_rst == 0)
        data_sync_out = sinc2_out;
    else
        data_sync_out = sinc1_out;
end

endmodule
