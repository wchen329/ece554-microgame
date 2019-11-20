module collision_detection_tb();
logic clk, rst_n;
logic [7:0] a_x, a_y, a_width, a_height;
logic [7:0] b_x, b_y, b_width, b_height;
logic collision;

collision_detection collision_detection(
	.clk(clk),
	.rst_n(rst_n),
	.a_x(a_x),
	.a_y(a_y),
	.a_width(a_width),
	.a_height(a_height),
	.b_x(b_x),
	.b_y(b_y),
	.b_width(b_width),
	.b_height(b_height),
	.collision(collision)
);

always #20ns clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	a_x = 0;
	a_y = 0;
	a_width = 0;
	a_height = 0;
	b_x = 0;
	b_y = 0;
	b_width = 0;
	b_height = 0;

	@(posedge clk);
	@(negedge clk);
	rst_n = 1;

	// verify collisions
	check_collision(10, 10, 10, 10, 11, 11, 10, 10, 1);
	check_collision(10, 10, 10, 10, 9, 9, 10, 10, 1);
	check_collision(10, 10, 10, 10, 11, 11, 2, 2, 1);
	check_collision(10, 10, 10, 10, 0, 0, 20, 20, 1);
	check_collision(10, 10, 10, 10, 0, 10, 10, 10, 1);
	check_collision(10, 10, 10, 10, 10, 20, 10, 10, 1);
	// verify non-collisions
	check_collision(10, 10, 10, 10, 30, 30, 10, 10, 0);
	check_collision(10, 10, 10, 10, 21, 10, 10, 10, 0);
	check_collision(10, 10, 10, 10, 10, 21, 10, 10, 0);
	
	$display("All tests passed.");
	$stop();
end

task check_collision(
		input [7:0] ax, ay, aw, ah,
		input [7:0] bx, by, bw, bh,
		input expected
	);
	a_x = ax;
	a_y = ay;
	a_width = aw;
	a_height = ah;
	b_x = bx;
	b_y = by;
	b_width = bw;
	b_height = bh;

	repeat(2) @(posedge clk);
	assert (collision === expected)
	else begin
		$display("Expected collision to be %d for (%d, %d, %d, %d) (%d, %d, %d, %d)",
			expected, ax, ay, aw, ah, bx, by, bw, bh);
		$stop();
	end
endtask

endmodule