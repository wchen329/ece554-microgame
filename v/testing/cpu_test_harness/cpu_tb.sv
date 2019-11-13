module cpu_tb();

reg clk, rst_n;

cpu cpu(
	.clk(clk),
	.rst_n(rst_n)
);

initial begin
	clk = 0;
	rst_n = 0;

	// time for fake memory setup
	#1000;	

	rst_n = 1;

	#4000;

	$finish();
end

always clk = #20 ~clk;

endmodule
