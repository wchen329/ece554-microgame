`include "../constants.sv"

/**
 * FIFO to store sprite commands
 */
module sprite_command_fifo(
	input clk, rst_n,
	input [45:0] cmd,
	input read, write,
	output [45:0] next_cmd
);

logic [0:`SPRITE_CMD_FIFO_SIZE-1] [45:0] buffer;
logic [$clog2(`SPRITE_CMD_FIFO_SIZE)-1:0] read_ptr, write_ptr;
logic empty, full;

assign full = read_ptr == write_ptr + 1;
assign empty = read_ptr == write_ptr;
assign next_cmd = buffer[read_ptr];

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		read_ptr <= 0;
	else if(read && !full)
		read_ptr <= read_ptr + 1;
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		write_ptr <= 0;
	else if(write && !full)
		write_ptr <= write_ptr + 1;
end

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		buffer <= 0;
	else if(write && !full)
		buffer[write_ptr] <= cmd;
end

endmodule