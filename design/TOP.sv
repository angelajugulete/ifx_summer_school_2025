module top
#(parameter N = 8)
(
    input logic  clk_i,
    input logic  rstn_i,
    input logic  acc_en_i,
    input logic  wr_en_i,
    input logic [$clog2(N+N/8)-1:0] addr_i,
    input logic  [7:0]wdata_i,
    input logic  [N-1:0]data_in,
    output logic [7:0]rdata_o,
    output logic [N-1:0]data_out,
    output logic int_pulse_out 
);

// Firele interne pentru conectarea modulelor
logic [N-1:0] wd_rst_top;              // Din register_block catre Sincronizator
logic [N-1:0] sync_data_in;            // Din Sincronizator catre Filter
logic [2*N-1:0]filter_type_top;        // Din register_block catre Filter
logic [4*N-1:0]window_size_top;        // Din register_block catre Filter
logic [N-1:0]int_en_top;               // Din register_block catre Filter
logic [N-1:0]int_pulse_out_filter_top; // Din Filter catre register_block (ca status)

genvar i;

// Instan?ierea blocurilor Sincronizator (N instan?e)
generate
    for(i=0; i< N; i=i+1) begin
        Sincronizator SINCRONIZATOR(
            .clk_i(clk_i),
            .rstn_i(rstn_i),
            .data_in(data_in[i]),
            .wd_rst(wd_rst_top[i]),       
            .data_sync_out(sync_data_in[i]) 
        );
    end
endgenerate

// Instan?ierea blocului Register_block 
register_block
#(.N(N)) REGISTER_BLOCK
(
    .clk_i(clk_i),
    .acc_en_i(acc_en_i),
    .rstn_i(rstn_i),
    .wr_en_i(wr_en_i),
    .addr_i(addr_i),
    .wdata_i(wdata_i),
    .rdata_o(rdata_o),
    .filter_type(filter_type_top),
    .window_size(window_size_top),
    .int_en(int_en_top),
    .wd_rst(wd_rst_top),
    .interrupt_status(int_pulse_out_filter_top)
);
    
// Instan?ierea blocurilor Filter (N instan?e)
generate
    for(i=0; i< N; i=i+1) begin
        Filter FILTER(
            .sync_data_in(sync_data_in[i]),
            .filter_type(filter_type_top[2*i+1:2*i]),
            .window_size(window_size_top[4*i+3:4*i]),
            .int_en(int_en_top[i]),
            .clk_i(clk_i),
            .rstn_i(rstn_i),
            .int_pulse_out_filter(int_pulse_out_filter_top[i]),
            .data_out(data_out[i])
        );
    end
endgenerate

assign int_pulse_out = |int_pulse_out_filter_top;
    
endmodule