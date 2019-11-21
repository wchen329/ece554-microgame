`include "../constants.sv"

/**
 * FIFO to store sprite commands
 */
module sprite_command_fifo(
	input clk, rst_n,
	input [42:0] cmd,
	input read, write,
	output [42:0] curr_cmd
);

logic [0:`SPRITE_CMD_FIFO_SIZE-1] [42:0] buffer;
logic [$clog2(`SPRITE_CMD_FIFO_SIZE)-1:0] read_ptr, write_ptr, next_write_ptr;
logic empty, full;

assign next_write_ptr = write_ptr + 1;
assign full = read_ptr == next_write_ptr;
assign empty = read_ptr == write_ptr;
assign curr_cmd = buffer[read_ptr];

// read_ptr
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		read_ptr <= 0;
	else if(read && !empty)
		read_ptr <= read_ptr + 1;
end

// write_ptr
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		write_ptr <= 0;
	else if(write && !full)
		write_ptr <= write_ptr + 1;
end

// write
always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		buffer <= 0;
	else if(write && !full)
		buffer[write_ptr] <= cmd;
end

endmodule