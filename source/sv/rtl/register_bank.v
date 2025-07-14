
module register_block #(parameter N = 8, addr_size = 8)(

	//system clock & reset
	input wire clk_i, 
	input wire rstn_i, 
	
	//communication interface
	input wire acc_en_i, 
	input wire wr_en_i,
	input wire[addr_size-1:0] addr_i,
	input wire[7:0] wdata_i,
	
	output reg[7:0] rdata_o,
	
	// configuration bits 
	
	output wire[2*N-1:0] filter_type_o, 
	output wire[4*N-1:0] window_size_o,
	output wire[N-1:0] int_en_o,
	output wire[N-1:0] wd_rst_o,
	
	
	// status 
	input wire [N-1:0] in_int_i
	
	
	);


localparam NUM_STATUS_REGS = (N + 7) / 8 > 0 ? (N + 7) / 8 : 1; // Ensure at least 1 register

genvar i; 

generate 

	reg[7:0] FILTER_CTRL[0:N-1];
	
	for (i=0; i< N; i=i+1) begin
	
	
		always@(posedge clk_i or negedge rstn_i)
		begin
			if (!rstn_i)
			
				FILTER_CTRL[i]	<= 8'b0000_0000;
				
			else if(acc_en_i && wr_en_i && (addr_i == i))
			
				FILTER_CTRL[i]	<= wdata_i;		
		end

		assign  filter_type_o[2*i +: 2] =  FILTER_CTRL[i][1:0];
		assign  window_size_o[4*i +: 4] =  FILTER_CTRL[i][5:2];
		assign  int_en_o[i]		=  FILTER_CTRL[i][6];
		assign  wd_rst_o[i]		=  FILTER_CTRL[i][7];
		
	end

endgenerate


genvar j; 

generate 

	reg[7:0] INT_STATUS[0:NUM_STATUS_REGS-1];
	
	for (j=0; j< NUM_STATUS_REGS; j=j+1) begin
	
	
		always@(posedge clk_i or negedge rstn_i)
		begin
			if (!rstn_i)
			
				INT_STATUS[j]	<= 8'b0000_0000;
				
			else 
				if(acc_en_i && !wr_en_i && (addr_i == N+j)) //clear command 
			
					INT_STATUS[j]	<= 8'b0000_0000;
				else
					INT_STATUS[j]	<= INT_STATUS[j] | in_int_i; // set when interrupt pulse 	
		end
			
	end

endgenerate


// Read commands 

always@(*)
begin
	if( acc_en_i && !wr_en_i) begin 
	
		if( addr_i < N)
		
			rdata_o <=   FILTER_CTRL[addr_i];
			
		else if (addr_i < N+ NUM_STATUS_REGS)
		
			rdata_o <=   INT_STATUS[N-addr_i];
		
		else 
		
			rdata_o <=   8'b0000_0000;
	end
	else 
		
		rdata_o <=   8'b0000_0000;	
end 

endmodule


