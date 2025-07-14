module filter (

	//system clock & reset
	input wire clk_i, 
	input wire rstn_i, 
	
	
	
	// configuration bits 
	
	input wire[1:0] filter_type_i, 
	input wire[3:0] window_size_i,
	input wire int_en_i,
	
	// synchronized filter input 
	
	input wire data_in,
	
	// status & output  
	output reg in_int_o,
	output wire  data_out
	
	
	);

// Declaration of internal signals 

reg[10:0] counter_filter_s;
wire start_count_s;
reg data_in_del_s;
reg[10:0] load_value_s; 
wire rise_event_s, fall_event_s, both_event_s;
reg data_out_reg_s;

// Decoding the window size based on FILTER_CTRL configuration
always@(*)
begin
	
	case (window_size_i)

	4'b0000	:  load_value_s <=   11'd3;
	4'b0001	:  load_value_s <=   11'd7;
	4'b0010	:  load_value_s <=   11'd15;
	4'b0011	:  load_value_s <=   11'd31;
	4'b0100	:  load_value_s <=   11'd47;
	4'b0101	:  load_value_s <=   11'd63;
	4'b0110	:  load_value_s <=   11'd127;
	4'b0111	:  load_value_s <=   11'd255;
	4'b0000	:  load_value_s <=   11'd511;
	4'b1001	:  load_value_s <=   11'd639;
	4'b1010	:  load_value_s <=   11'd767;
	4'b1011	:  load_value_s <=   11'd895;
	4'b1100	:  load_value_s <=   11'd1023;
	4'b1101	:  load_value_s <=   11'd1279;
	4'b1110	:  load_value_s <=   11'd1535;
	4'b1111	:  load_value_s <=   11'd2047;
	
		
	default :  load_value_s <=   11'd0;
		
	endcase		
end

//Decoding the start filtering condition based on filter type 
always@(posedge clk_i or negedge rstn_i)
begin
	if (!rstn_i)
		data_in_del_s	<= 1'b0;
	else 
		data_in_del_s   <= data_in;		
end


assign rise_event_s = (data_in & !data_in_del_s)     & (filter_type_i == 2'b01);
assign fall_event_s = (!data_in & data_in_del_s)     & (filter_type_i == 2'b10);
assign both_event_s = (data_in ^ data_in_del_s)      & (filter_type_i == 2'b11);

assign start_count_s = rise_event_s | fall_event_s | both_event_s;

assign reset_filter_s = ((filter_type_i == 2'b01) & !data_in)  | // rise filter type and input is low
			((filter_type_i == 2'b10) &  data_in)  | // fall filter type and input is high
			((filter_type_i == 2'b11) & (data_in == data_out_reg_s)); // rise & fall filter type and input is the 

//Main counter of the filter. LOad window size, Down counting, Reaching 0 means filtering done & change of output . 
always@(posedge clk_i or negedge rstn_i)
begin
	if (!rstn_i)
		counter_filter_s	<= 11'd0;
	else begin
	
		if(filter_type_i == 2'b00) 
		
			counter_filter_s   <= 11'd0; // filtering disable	
		
		else if(reset_filter_s) 
		
			counter_filter_s   <= 11'd0; // filter reset caused by input value 
				
		else if(start_count_s)
		
			counter_filter_s   <= load_value_s; // load window size 
			
		else if (counter_filter_s > 0)
		
			counter_filter_s   <= counter_filter_s - 1; // count 
	end
			
				
end

//OUTPUT FILTER REGISTER 
always@(posedge clk_i or negedge rstn_i)
begin
	if (!rstn_i)
	
		data_out_reg_s	<= 1'b0;
	else
		if (counter_filter_s == 11'd1 & (data_in ^ data_out_reg_s) )  // finished counting and input level is different than the stored filtered value 
		
			data_out_reg_s   <=  !data_out_reg_s;
			
		else if ((filter_type_i == 2'b01) & !data_in)  // rise type filter and input l0w
			
			data_out_reg_s   <=  1'b0;
			
		else if ((filter_type_i == 2'b10) & data_in)  // fall type filter and input high
			
			data_out_reg_s   <=  1'b1;		
end

assign data_out	= data_out_reg_s;

//INTERRUPT REGISTER 
always@(posedge clk_i or negedge rstn_i)
begin
	if (!rstn_i)
	
		in_int_o	<= 1'b0;
	else
		if (counter_filter_s == 11'd1 & (data_in ^ data_out_reg_s) & int_en_i)
		
			in_int_o   <=  1'b1;
		else
			
			in_int_o   <=  1'b0; // 1 clock cycle pulse 	
end
endmodule
