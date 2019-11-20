`timescale 1ns/1ns
module system_timer_tb();
reg clk;
reg rst;
wire [31:0] t;
initial begin
clk = 0;
rst = 1;
#20 rst = 0;
#3000075 rst = 1;
#20 rst = 0;
end

always #10 clk = ~clk;

system_timer timer( clk,  rst, t);

endmodule
