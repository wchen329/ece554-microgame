/* Driver
 * The "driver" is a simple interface to the CPU-FSM module
 */
module driver(
    input clk,
    input rst,
    input [1:0] br_cfg,
    output iocs,
    output iorw,
    input rda,
    input tbr,
    output [1:0] ioaddr,
    inout [7:0] databus,
	 output [4:0] get_ops
    );

	// Instantiate CPU to harness
	user_io_cpu CPU0(	.clk(clk),
			.rst(rst),
			.iocs(iocs),
			.iorw(iorw),
			.baud_sel(br_cfg),
			.rda(rda),
			.tbr(tbr),
			.ioaddr(ioaddr),
			.databus(databus),
			.get_ops(get_ops));

endmodule
