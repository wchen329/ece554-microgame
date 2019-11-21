/* LAB1_SPART Testbench - Toplevel Testbench
 * Testbench allowing for integration test of all portions of the project using
 * the harness (and emulating input that would otherwise be from switches or GPIO ports)
 */
module lab1_spart_tb();

	reg clk;
	reg [19:0] test_data;
	reg [3:0] key;
	reg [1:0] switch_in;
	wire[1:0] switch_bus;
	wire[3:0] key_bus;
	reg rxd;
	wire rxd_net;
	wire txd;
	wire [9:0] LEDR;
	wire [6:0]  HEX0;
    wire [6:0]  HEX1;
    wire [6:0]  HEX2;
    wire [6:0]  HEX3;
    wire [6:0]  HEX4;
    wire [6:0]  HEX5;
	wire [35:0] GPIO_W;

	// 20 MHz Clock
	always #5 clk = ~clk;

	always #24160 begin
		rxd = test_data[0];
		test_data = {test_data[0], test_data[19:1]};
	end

	lab1_spart DUT( .CLOCK_50(clk),
					.CLOCK2_50(clk),
					.CLOCK3_50(clk),
					.CLOCK4_50(clk),
					.KEY(key_bus),
					.SW({switch_bus, {8{1'b0}}}),
					.GPIO({GPIO_W[35:6] , rxd_net, GPIO_W[4], txd, GPIO_W[2:0]}),
					.LEDR(LEDR),
					.HEX0(HEX0),
					.HEX1(HEX1),
					.HEX2(HEX2),
					.HEX3(HEX3),
					.HEX4(HEX4),
					.HEX5(HEX5)
					);

	initial begin
		rxd = 1'b1;
		clk = 1'b0;
		key = 4'd0;
		switch_in = 2'b00;
		test_data = 20'b1101010100_1010101010;
		
		// Wait a cycle, then deactivate reset, allowing for normal execution
		@(posedge clk);
		key = 4'd1;
	end

	// Static assignments for wires to the mocked test values
	assign rxd_net = rxd;
	assign key_bus = key;
	assign switch_bus = switch_in;

endmodule
