module data_memory
#(
	parameter JUNK=16'b0
)(
	input clk, rst_n,
	input [15:0] address,
	input [31:0] data_in,
	input read,
	input write,
	output logic [31:0] data_out,
	output reg stall
);

assign data_out = 32'h555555555;

reg state;

always_ff @(posedge clk, negedge rst_n) begin
	if(~rst_n) begin
		state <= 0;
	end else if((read || write) && ~state) begin
		state <= 1;
	end else begin
		state <= 0;
	end
end

assign stall = ~state && (read | write);

endmodule
