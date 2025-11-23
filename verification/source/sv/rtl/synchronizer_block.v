module synchronizer_block (

	//system clock & reset
	input wire clk_i, 
	input wire rstn_i, 
	
	// configuration bits 
	
	input wire wd_rst_i,
	
	// asynchronous input 
	
	input wire data_in,
	
	// synchronous output  
	output wire data_out
	
	);
	
//Declaration of internal signals 
reg data_in_sync1_s, data_in_sync2_s;
reg data_in_async1_s, dara_in_async2_s;
wire first_stage_async_reset_s;
wire second_stage_input_s;

//Synchronous window reset synchronizer 
always@(posedge clk_i or negedge rstn_i)
begin
	if (!rstn_i) begin
		data_in_sync1_s	<= 1'b0;
		data_in_sync2_s	<= 1'b0;
		
	end else begin 
		data_in_sync1_s   <= data_in;
		data_in_sync2_s   <= data_in_sync1_s;	
	end	
end

//ASynchronous window reset synchronizer 

assign first_stage_async_reset_s  = data_in & rstn_i;
assign second_stage_input_s	  = data_in_async1_s & data_in;

always@(posedge clk_i or negedge first_stage_async_reset_s)
begin
	if (!first_stage_async_reset_s) begin
	
		data_in_async1_s <= 1'b0;
		
	end else begin 
	
		data_in_async1_s   <= data_in;
			
	end	
end

always@(posedge clk_i or negedge first_stage_async_reset_s)
begin
	if (!rstn_i) begin
	
		dara_in_async2_s <= 1'b0;
		
	end else begin 
	
		dara_in_async2_s   <= second_stage_input_s;
			
	end	
end

// Select one of the synchronizers output based on FILTER CTRL configuration 

assign data_out =  wd_rst_i ? data_in_sync2_s : dara_in_async2_s;

endmodule
