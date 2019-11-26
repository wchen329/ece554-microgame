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


// BRAM has one-cycle delay on both reads and writes
// so simple state machine to reflect this

reg state;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		state <= 0;
	end else if(~state && (read || write)) begin
		state <= 1;
	end else begin
		state <= 0;
	end
end

assign stall = ~state && (read || write);


data_memory_8k user_space(
	.address(address),
	.clock(clk),
	.data(data_in),
	.wren(write),
	.q(data_out)
);


endmodule
