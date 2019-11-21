module shifter_tb();

reg clk;
reg rst;
reg rxd;
reg baud_en;
reg [7:0] collected;
reg [19:0] test_data;

wire [7:0] data;
wire has_data;

initial begin
clk = 0;
rxd = 1;
rst = 1;
baud_en = 0;
collected = 8'b0;
test_data = 20'b1101010100_1010101010;
end

always #5 clk = ~clk;

always #480 begin
	rxd = test_data[0];
	test_data = {test_data[0], test_data[19:1]};
end

always #20 begin 
	baud_en = ~baud_en;
	#10
	baud_en = ~baud_en;
end

always @(posedge clk) begin
	if (has_data && ~rst) begin
		collected <= data;
		rst <= 1;
	end
	else begin
		rst <= 0;
	end
end

shifter s1(rxd, clk, rst, baud_en, data, has_data);

endmodule
