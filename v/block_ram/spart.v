/* SPART
 * a.k.a. Serial Port
 * This module encapsulates the SPART implementation.
 */
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );

	wire [7:0] rx_data; // data into the spart (write to spart)
	wire [7:0] tx_data; // data going out of the spart (write to connected device)
	wire [7:0] div_in; // value to load into divisor buffer during the initialization sequence (this is a two cycle load)
	wire brg_rst; // baud rate generator SPECIFIC reset signal
	wire [7:0] data; // bus potentially driving databus for BUS INTERFACE, sends received data for receives or sends the "status register" values depending on the I/O address selection
	wire rx_rst; // reset signal for receive buffer and receive shift reg
	
	// Reset signal for baud rate generator
	assign brg_rst = (rst == 1'b1 || (iocs == 1'b1 && iorw == 1'b0 && ioaddr[1] == 1'b1)) ? 1'b1 : 1'b0;
	
	parameter IDLE = 2'b00, ACTIVE = 2'b01;
	
	wire baud_en;
	wire tx_en;
	
	assign data = (ioaddr[0] == 1'b1) ? {6'b0, tbr, rda} : rx_data; // drive with status register or readable data depending on ioaddr
	
	assign databus = (iocs & iorw) ? data : 8'bZ; // drive data, unless a write is signaled from the CPU (or attached device), in which case, let the CPU drive
	
	assign div_hword = (ioaddr == 2'b11) ? 1'b1 : 1'b0; // used only during initialization, if low we are loading to lower halfword of the divisor buffer, otherwise the higher halfword
	
	assign div_in = databus; // ditto, used only during initialization
	
	assign tx_en = ((iocs & ~iorw) && (ioaddr == 2'b00)) ? 1'b1 : 1'b0; // enable signal for transmit block
	
	assign rx_rst = rst | (iocs & iorw & (ioaddr == 2'b00)); // reset signal for receive block
	
	assign tx_data = (iocs & ~iorw) ? databus : 8'b0; // data to drive tx data (potentially)
	
	// Receive and Transmit Logic
	shifter rx_shifter(rxd, clk, rx_rst, baud_en, rx_data, rda);
	
	shift_out tx_shifter(clk, rst, tx_en, baud_en, tx_data, txd, tbr);
	
	// Baud rate generator
	BRG brg(clk, brg_rst, div_hword, div_in, baud_en);

endmodule
