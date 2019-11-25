module data_memory
#(
	parameter WIDTH=16
)(
	input clk,
	input rst_n,
	input [WIDTH-1:0] address,
	input [31:0] data_in,
	input write,
	input read,

	output [31:0] data_out,
	output stall
);


// BRAM current implementation is single-cycle

assign stall = 1'b0;

data_memory_8k user_space(
	.address(address),
	.clock(clk),
	.data(data_in),
	.wren(write),
	.q(data_out)
);


endmodule
