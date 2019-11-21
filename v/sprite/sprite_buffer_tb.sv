module sprite_buffer_tb();
// sprite_buffer signals
logic clk, rst_n;
logic read, write;
logic [7:0] i_r, i_g, i_b;
logic set_orientation;
logic [1:0] orientation;
logic [7:0] o_r, o_g, o_b;

// sprite mem
logic [31:0] sprite_mem[0:255];

sprite_buffer sprite_buffer(
	.clk(clk),
	.rst_n(rst_n),
	.read(read),
	.write(write),
	.i_r(i_r),
	.i_g(i_g),
	.i_b(i_b),
	.set_orientation(set_orientation),
	.orientation(orientation),
	.o_r(o_r),
	.o_g(o_g),
	.o_b(o_b)
);

always #20ns clk = ~clk;

initial begin
	$readmemh("sprite/sprite_buffer_mem.hex", sprite_mem);
	clk = 0;
	rst_n = 0;
	read = 0;
	write = 0;
	{ i_r, i_g, i_b } = 0;
	set_orientation = 0;
	orientation = 0;

	@(posedge clk);
	@(negedge clk);
	rst_n = 1;

	// write to sprite, then change orientation and verify the correct pixels are
	// read out in the correct order
	$display("Writing sprite...");
	write_sprite(0);
	$display("Reading sprite at 0...");
	read_sprite(0);
	set_ori(1);
	$display("Reading sprite at 1...");
	read_sprite(64);
	set_ori(2);
	$display("Reading sprite at 2...");
	read_sprite(128);
	set_ori(3);
	$display("Reading sprite at 3...");
	read_sprite(192);

	$display("All tests passed.");
	$stop();
end

task write_sprite(input integer start_addr);
	integer i;

	write = 1;
	@(posedge clk);
	@(negedge clk);
	write = 0;

	for(i = 0; i < 64; i++) begin
		{ i_r, i_g, i_b } = sprite_mem[i+start_addr][23:0];
		@(posedge clk);
		@(negedge clk);
	end

	// repeat(10) @(posedge clk);
	// @(negedge clk);
endtask

task read_sprite(input integer start_addr);
	integer i;

	read = 1;
	@(posedge clk);
	@(negedge clk);
	read = 0;

	for(i = 0; i < 64; i++) begin
		assert ({ o_r, o_g, o_b } == sprite_mem[i+start_addr][23:0])
		else begin
			$display(
				"Expected buffer[%d] to be %d,%d,%d not %d,%d,%d",
				i,
				sprite_mem[i+start_addr][23:16], sprite_mem[i+start_addr][15:8], sprite_mem[i+start_addr][7:0],
				o_r, o_g, o_b
			);
			$stop();
		end
		@(posedge clk);
		@(negedge clk);
	end

	// repeat(10) @(posedge clk);
	// @(negedge clk);
endtask

task set_ori(input [1:0] ori);
	orientation = ori;
	set_orientation = 1;
	@(posedge clk);
	@(negedge clk);
	set_orientation = 0;

	// repeat(10) @(posedge clk);
	// @(negedge clk);
endtask

endmodule