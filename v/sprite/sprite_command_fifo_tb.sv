module sprite_command_fifo_tb();
logic clk, rst_n;
logic [42:0] cmd;
logic read, write;
logic [42:0] curr_cmd;

`include "../constants.sv"

sprite_command_fifo sprite_command_fifo(
	.clk(clk),
	.rst_n(rst_n),
	.cmd(cmd),
	.read(read),
	.write(write),
	.curr_cmd(curr_cmd)
);

always #20ns clk = ~clk;

initial begin
	integer i;
	clk = 0;
	rst_n = 0;
	cmd = 0;
	read = 0;
	write = 0;

	@(posedge clk);
	@(negedge clk);
	rst_n = 1;

	// write more than fifo can hold
	for (i = 0; i < `SPRITE_CMD_FIFO_SIZE+2; i++) begin
		write_cmd(i);
	end

	// check cmds
	for (i = 0; i < `SPRITE_CMD_FIFO_SIZE-1; i++) begin
		assert_curr_cmd(i);
		read_cmd();
	end

	// write one more and make sure thats the next command
	// to verify it wraps properly
	write_cmd('d70);
	assert_curr_cmd('d70);

	// read more than fifo entries
	repeat(20) read_cmd();

	// verify one more write is curr cmd
	write_cmd('d71);
	assert_curr_cmd('d71);

	$display("All tests passed.");
	$stop();
end

task write_cmd(input [42:0] val);
	cmd = val;
	write = 1;
	@(posedge clk);
	@(negedge clk);
	write = 0;
endtask

task read_cmd();
	read = 1;
	@(posedge clk);
	@(negedge clk);
	read = 0;
endtask

task assert_curr_cmd(input [42:0] val);
	assert(curr_cmd == val)
	else begin
		$display("Expected curr_cmd to be %d, not %d", val, curr_cmd);
		$stop();
	end
endtask

endmodule