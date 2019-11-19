/**
 * Module to test collision_detection on the FPGA
 */
module collision_detection_fpga(
///////////// CLOCK //////////
	input               CLOCK_50,
	input               CLOCK2_50,
	input               CLOCK3_50,
	input               CLOCK4_50,

///////////// SEG7 //////////
	output reg   [6:0]  HEX0,
	output reg   [6:0]  HEX1,
	output reg   [6:0]  HEX2,
	output reg   [6:0]  HEX3,
	output reg   [6:0]  HEX4,
	output reg   [6:0]  HEX5,

//////////// KEY //////////
	input        [3:0]  KEY,

///////////// LED //////////
	output		   [9:0]	LEDR,

///////////// SW //////////
	input        [9:0]  SW
);

logic [1:0] a_x, a_y, a_width, a_height;
logic [1:0] b_x, b_y, b_width, b_height;
logic collision;

collision_detection cd(
	.clk(CLOCK_50),
	.rst_n(KEY[0]),
	.a_x({ 5'h0, a_x }),
	.a_y({ 5'h0, a_y }),
	.a_width({ 5'h0, a_width }),
	.a_height({ 5'h0, a_height }),
	.b_x({ 5'h0, b_x }),
	.b_y({ 5'h0, b_y }),
	.b_width({ 5'h0, b_width }),
	.b_height({ 5'h0, b_height }),
	.collision(collision)
);

assign LEDR = {10{collision}};

// set a
always_ff @(posedge CLOCK_50)
	if(~SW[9]) begin
		a_x <= SW[7:6];
		a_y <= SW[5:4];
		a_width <= SW[3:2];
		a_height <= SW[1:0];
	end

// set b
always_ff @(posedge CLOCK_50)
	if(SW[9]) begin
		b_x <= SW[7:6];
		b_y <= SW[5:4];
		b_width <= SW[3:2];
		b_height <= SW[1:0];
	end

// 7 seg display
// m lt lb b rt rb t
function [6:0] b_to_seg(input [1:0] b);
	case(b)
		'd0: b_to_seg = 7'b1000000;
		'd1: b_to_seg = 7'b1111001;
		'd2: b_to_seg = 7'b0100100;
		'd3: b_to_seg = 7'b0110000;
	endcase
endfunction

assign HEX0 = b_to_seg(~SW[9] ? a_height : b_height);
assign HEX1 = b_to_seg(~SW[9] ? a_width : b_width);
assign HEX2 = b_to_seg(~SW[9] ? a_y : b_y);
assign HEX3 = b_to_seg(~SW[9] ? a_x : b_x);
assign HEX4 = 7'hFF;
assign HEX5 = ~SW[9] ? 7'b0001000 : 7'b0000000;

endmodule
