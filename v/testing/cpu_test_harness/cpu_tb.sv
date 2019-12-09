module cpu_tb();

reg clk, rst_n;

cpu cpu(
	.clk(clk),
	.rst_n(rst_n),

	.gpio(GPIO),
	.vga_write(FB_WFB),
	.vga_display(FB_DFB),
	.vga_pixnum(PIXNUM),
	.vga_r(R),
	.vga_g(G),
	.vga_b(B),
	
	.sprite_op_a(A),
	.sprite_op_b(BB),
	.sprite_op_c(CC)
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
