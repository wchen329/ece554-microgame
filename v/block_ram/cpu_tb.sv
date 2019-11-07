/* CPU Unit Testbench
 * Tests the CPU output signals
 */
module cpu_tb();

	logic clk;
	logic rst;
	reg[2:0] baud_sel;
	reg rda;
	reg tbr;
	wire rda_net;
	wire tbr_net;
	wire[1:0] baud_sel_bus;

	// Probe wires
	wire probe_IOCS;
	wire probe_IO_RnW;
	wire[1:0] probe_IO_addr;
	wire[7:0] probe_IO_databus;

	reg read_sig;

	always #100 clk = ~clk;

	cpu DUT(	.clk(clk),
			.rst(rst),
			.iocs(probe_IOCS),
			.iorw(probe_IORW),
			.baud_sel(baud_sel_bus),
			.rda(rda_net),
			.tbr(tbr_net),
			.ioaddr(probe_IO_addr),
			.databus(probe_IO_databus)
		);

	initial begin

		clk = 0;

		for (baud_sel = 3'd0; baud_sel < 3'd4; baud_sel++) begin
			read_sig = 1'b0;
			rst = 1;
			rda = 1'b0;
			tbr = 1'b0;
			@(posedge clk) rst = 0;
			
			repeat(4) @(posedge clk);			
			rda = 1'b1;
			tbr = 1'b1;
			read_sig <= 1'b1;

			@(posedge clk);
			rda = 1'b0;
			tbr = 1'b1;

			repeat(3) @(posedge clk);
		end
		$stop; // Allow further probing
	end

	 // Wires
	assign baud_sel_bus = baud_sel[1:0];
	assign rda_net = rda;
	assign tbr_net = tbr;
	assign probe_IO_databus = read_sig ? 8'd100 : 8'dz;

endmodule
