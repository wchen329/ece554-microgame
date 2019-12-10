module cpu_tb();

reg clk, rst_n;

cpu cpu(
	.clk(clk),
	.rst_n(rst_n),

	.gpio(GPIO),
	.vga_write(FB_WFB),
	.vga_display(FB_DFB),
	.vga_x(X),
	.vga_y(Y),
	.vga_r(R),
	.vga_g(G),
	.vga_b(B)
);

initial begin
	clk = 0;
	rst_n = 0;

	// time for fake memory setup
	#1000;

	rst_n = 1;

	#2000000;

	$finish();
end

always clk = #20 ~clk;

endmodule
