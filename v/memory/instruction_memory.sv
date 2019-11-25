module instruction_memory
#(
	WIDTH=16
)(
	input clk,
	input [WIDTH-1:0] address_a,
	input [WIDTH-1:0] address_b,

	output [31:0] data_a,
	output [31:0] data_b
);


instruction_memory_8k instruction_space(
	.address_a(address_a),
	.address_b(address_b),
	.clock(clk),
	.data_a(32'b0),
	.data_b(32'b0),
	.wren_a(1'b0),
	.wren_b(1'b0),
	.q_a(data_a),
	.q_b(data_b)
);


endmodule
