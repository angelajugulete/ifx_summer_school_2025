module top_filter_bank#(parameter N = 8, // number of filters 
			NUM_STATUS_REGS = (N + 7) / 8 > 0 ? (N + 7) / 8 : 1, // Ensure at least 1 register
			ADDR_SIZE = $clog2(N+NUM_STATUS_REGS)
)(
	//system clock & reset
	input wire clk_i, 
	input wire rstn_i, 
	
	//communication interface
	input wire acc_en_i, 
	input wire wr_en_i,
	input wire[ADDR_SIZE-1:0] addr_i,
	//input wire[$clog2(N+(N/8))-1:0] addr_i,
	input wire[7:0] wdata_i,
	output wire[7:0] rdata_o,
	
	//asynchronous inputs 
	input wire[N-1:0] data_in,

	//outputs
	output wire[N-1:0] data_out,
	output wire int_pulse_out
	

);

 


//Declarations of internal signals 

wire[2*N-1:0] filter_type_s;
wire[4*N-1:0] window_size_s;
wire[N-1:0] int_en_s;
wire[N-1:0] wd_rst_s;
wire[N-1:0] in_int_s;
wire[N-1:0] sync_data_out_s;

// One register block to configure all N filters
register_block#(.N(N), .addr_size(ADDR_SIZE)) regs(

	//system clock & reset
	.clk_i(clk_i), 
	.rstn_i(rstn_i), 
	
	//communication interface
	.acc_en_i(acc_en_i), 
	.wr_en_i(wr_en_i),
	.addr_i(addr_i),
	.wdata_i(wdata_i),
	.rdata_o(rdata_o),
	
	// configuration bits 
	
	.filter_type_o(filter_type_s), 
	.window_size_o(window_size_s),
	.int_en_o(int_en_s),
	.wd_rst_o(wd_rst_s),
	
	
	// status 
	.in_int_i(in_int_s)
	
	
	);

// Generate N instances of filter module & synchornizer block  	
genvar i; 

generate 

	for (i=0; i< N; i=i+1) begin
	
	filter FILTER_inst (
	//system clock & reset
	
	.clk_i(clk_i), 
	.rstn_i(rstn_i), 
	
	// configuration bits 
	
	.filter_type_i(filter_type_s[2*i +: 2]), 
	.window_size_i(window_size_s[4*i +: 4]),
	.int_en_i(int_en_s[i]),
	
	// synchronized filter input 
	
	.data_in(sync_data_out_s[i]), 
	
	// status & output  
	.in_int_o(in_int_s[i]),
	.data_out(data_out[i])
		
	);
	
	synchronizer_block SYNC_inst (
	//system clock & reset
	
	.clk_i(clk_i), 
	.rstn_i(rstn_i), 
	
	// configuration bits 
	.wd_rst_i(wd_rst_s[i]),
	
	// asynchronous input 
	
	.data_in(data_in[i]),
	
	// synchronous output  
	.data_out(sync_data_out_s[i])
	
	);

	end 
endgenerate

assign int_pulse_out = |in_int_s ;
endmodule 
