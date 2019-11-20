// SPART Testbench
// Testbench for spart.v module
module spart_tb();

reg clk;
reg rst;
reg iocs;
reg iorw;
wire rda;
wire tbr;
reg [1:0] ioaddr;
reg [7:0] data_to_wr;
wire [7:0] databus;
wire txd;
reg rxd;

reg [19:0] test_data;

reg [7:0] collect;

assign databus = iorw == 1'b1 ? 8'bz : data_to_wr;

initial begin
	clk = 0;
	rst = 1;
	iocs = 1;
	iorw = 1;
	ioaddr = 2'b01;
	rxd = 1'b1;
	test_data = 20'b1101010100_1010101010;
	#10 rst = 0;
	iorw = 0;
	ioaddr = 2'b10;
	data_to_wr = 8'hFF;
	#10 ioaddr = 2'b11;
	data_to_wr = 8'hFF;
	#10 iorw = 1;
	ioaddr = 2'b01;
end

always #24160 begin
	rxd = test_data[0];
	test_data = {test_data[0], test_data[19:1]};
end

always @(posedge clk) begin
	if (rda && ~(iorw && (ioaddr == 2'b00))) begin
		iorw <= 1;
		ioaddr <= 2'b00;
	end
	else if (rda && iorw && (ioaddr == 2'b00)) begin
		collect <= databus;
		ioaddr <= 2'b01;
	end
end

always #5 clk = ~clk;

spart s1(
    clk,
    rst,
    iocs,
    iorw,
    rda,
    tbr,
    ioaddr,
    databus,
    txd,
    rxd
    );




endmodule
