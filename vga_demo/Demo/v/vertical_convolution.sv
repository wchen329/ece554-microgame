module vertical_convolution(

	input [11:0] data_0,
	input [11:0] data_1,
	input [11:0] data_2,
	input [11:0] data_3,
	input [11:0] data_4,
	input [11:0] data_5,
	input [11:0] data_6,
	input [11:0] data_7,
	input [11:0] data_8,
	output [11:0] convolution
	
);


logic [11:0] result;

//add weighted sum 
assign result = (-12'd1)*data_0 + data_2 + 
		(-12'd2)*data_3 + (12'd2)*data_5 + 
		(-12'd1)*data_6 + (12'd1)*data_8;

//output the absolute value
assign convolution = result[11] ? (~result) + 1 : result; 


endmodule
