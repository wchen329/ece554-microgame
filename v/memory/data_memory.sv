module data_memory
#(
	parameter USER_ADDRESS_WIDTH=16
)(
	input clk,
	input rst_n,
	input [31:0] data_in,
	input write,
	input read,

	output [31:0] data_out,
	output stall
);


// BRAM current implementation is single-cycle

assign stall = 1'b0;

data_memory_8k user_space(
	
);


endmodule
