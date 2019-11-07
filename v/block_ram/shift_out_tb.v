/* Testbench for Transmit Control
 */
module shift_out_tb();

reg clk, rst, en, baud_en;
wire out, tbr;
reg [7:0] data;

shift_out s1(clk, rst, en, baud_en, data, out, tbr);

initial begin
	clk = 0;
	rst = 1;
	en = 0;
	baud_en = 0;
	#15
	rst = 0;
end

always #5 clk = ~clk;
always #80 begin
	baud_en = ~baud_en;
	#10;
	baud_en = ~baud_en;
end

always @(posedge clk) begin
	if (tbr && en == 1'b0) begin
		en <= 1'b1;
		data <= $random;
	end
	else begin
		en <= 1'b0;
	end
end

endmodule
