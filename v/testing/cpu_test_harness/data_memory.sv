module data_memory(
	input clk, rst_n,
	input [15:0] address,
	input [31:0] data_in,
	input read,
	input write,
	output [31:0] data_out,
	output stall
);

assign data_out = 31'b0;
assign stall = 1'b0;

// TODO make some dummy lag on read/write

endmodule
