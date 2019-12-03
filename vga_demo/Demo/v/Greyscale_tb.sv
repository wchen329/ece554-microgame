module Greyscale_tb();
logic clk, rst_n, dval;
logic [11:0] r, g, b, grey;

Greyscale greyscale(.clk(clk), .rst_n(rst_n), .r(r), .g(g), .b(b), .dval(dval), .grey(grey));

always #5 clk = ~clk;

initial begin
	clk = 0;
	rst_n = 0;
	dval = 1;
	r = 0;
	g = 0;
	b = 0;

	@(posedge clk)
	@(negedge clk)
	rst_n = 1;

	@(posedge clk)
	testGreyscale(10, 10, 10, 10);
	testGreyscale(10, 20, 30, 20);
	testGreyscale(2047, 2047, 2047, 2047);
	testGreyscale(4095, 4095, 4095, 4095);
	testGreyscale(0, 0, 0, 0);

	$display("TEST PASSED!!!");
	$stop;
end

task testGreyscale(input logic [11:0] r_in, g_in, b_in, expected);
	r = r_in;
	g = g_in;
	b = b_in;

	@(negedge clk)
	@(posedge clk)
	@(negedge clk)
	assert(grey === expected)
	else begin
		$display("ERROR: grey was %d, not %d (r %d, g %d, b %d)", grey, expected, r, g, b);
		$stop;
	end

endtask

endmodule
