module data_memory(
	input clk, rst_n,
	input [15:0] address,
	input [31:0] data_in,
	input read,
	input write,
	output logic [31:0] data_out,
	output reg stall
);

assign data_out = 32'h555555555;

always_ff @(posedge clk, negedge rst_n) begin
	if(~rst_n) begin
		stall <= 0;
	end else if((read || write) && ~stall) begin
		stall <= 1;
	end else if(stall) begin
		stall <= 0;
	end
end

endmodule
