module convolution_tb();

	logic [8:0] [11:0] data;
	logic [11:0] convolution1;
	logic [11:0] convolution2;
	logic [11:0] vertical_magnitude;
	logic [11:0] horizontal_magnitude;
	
	integer i;

vertical_convolution DUT1 (
	.data(data),
	.convolution(convolution1)
);

horizontal_convolution DUT2 (
	.data(data),
	.convolution(convolution2)
);

assign vertical_magnitude = (-8'd1)*data[0] + (8'd0)*data[1] + (8'd1)*data[2] + 
		     (-8'd2)*data[3] + (8'd0)*data[4] + (8'd2)*data[5] + 
		     (-8'd1)*data[6] + (8'd0)*data[7] + (8'd1)*data[8];

assign horizontal_magnitude = (-8'd1)*data[0] + (-8'd2)*data[1] + (-8'd1)*data[2] + 
		     (8'd0)*data[3] + (8'd0)*data[4] + (8'd0)*data[5] + 
		     (8'd1)*data[6] + (8'd2)*data[7] + (8'd1)*data[8];

initial begin
	
#10;
	
//test simple case
	data[0] = 12'h1;
	data[1] = 12'h1;
	data[2] = 12'h1;
	data[3] = 12'h1;
	data[4] = 12'h1;
	data[5] = 12'h1;
	data[6] = 12'h1;
	data[7] = 12'h1;
	data[8] = 12'h1;
#10;

//test case where result is negative
	data[0] = 12'h1;
	data[1] = 12'h0;
	data[2] = 12'h0;
	data[3] = 12'h1;
	data[4] = 12'h0;
	data[5] = 12'h0;
	data[6] = 12'h1;
	data[7] = 12'h0;
	data[8] = 12'h0;
#10;


	
	for (i =0; i < 10; i = i + 1) begin
		data[0] = $random;
		data[1] = $random;
		data[2] = $random;
		data[3] = $random;
		data[4] = $random;
		data[5] = $random;
		data[6] = $random;
		data[7] = $random;
		data[8] = $random;
		#10;
		
	end


end



endmodule 