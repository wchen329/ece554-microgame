/* CPU
 * A "fake" CPU
 * That just holds an 8-bits of data (a.k.a. a BYTE) and sends them out on a data bus
 *
 */
module user_io_cpu(input clk, input rst, output iocs, iorw, input[1:0] baud_sel, input rda, tbr, output [1:0] ioaddr, inout[7:0] databus, output [4:0] get_ops);

	// Baudrate Codes
	localparam[1:0] BR_4800 = 2'd0;
	localparam[1:0] BR_9600 = 2'd1;
	localparam[1:0] BR_19200 = 2'd2;
	localparam[1:0] BR_38400 = 2'd3;
	
	// Register Names
	localparam[1:0] TRANSMIT = 2'b00;
	localparam[1:0] STATUS = 2'b01;
	localparam[1:0] LOW_DIV_BUF = 2'b10;
	localparam[1:0] HI_DIV_BUF = 2'b11;	

	// Read or Write
	localparam READ = 1'b1;
	localparam WRITE = 1'b0;
	
	// SPART Buffer
	logic[7:0] buffer;
	logic write_read_op;
	reg[15:0] bbr_buf; // this holds the base baud rate value. Set it by multiplexer.	
	reg[1:0] ishhw;
	reg[1:0] received;
	
	assign get_ops[0] = (buffer == 8'h61); //left  :a
	assign get_ops[1] = (buffer == 8'h64); //right :d
	assign get_ops[2] = (buffer == 8'h77); //up    :w
	assign get_ops[3] = (buffer == 8'h73); //down  :s
	assign get_ops[4] = (buffer == 8'h20); //space :_

	always @(posedge clk) begin

		if(rst) begin
			received <= 2'b00;
			write_read_op <= WRITE;
			buffer <= 8'd0;
			ishhw <= 2'b00;
			
			bbr_buf <=	baud_sel == BR_4800 ? 4800 :
					baud_sel == BR_9600 ? 9600 :
					baud_sel == BR_19200 ? 19200 : 38400;
		end

		// Still setting up
		else if(ishhw < 2'b10) begin
			ishhw++;
			if (ishhw == 2'b10) begin
				write_read_op <= READ;
			end
		end

		else begin

			// If RDA is available, then mark read begin
			if(rda) begin 
				received <= 2'b01;
				write_read_op <= READ; // set read for next cycle
				buffer <= databus;
			end

			// Next cycle start reading
			else if(received == 2'b01) begin
				write_read_op <= WRITE; // set write for next cycle
				received <= 2'b10;
			end

			// Finally, start writing (statically), reset to read afterwards
			else if(tbr && received == 2'b10) begin
				received <= 2'b00;
				write_read_op <= READ;
			end
		end
	end

	// Static assignments

	// If just reset, drive data bus with baud rate
	// Afterwards...
	// If reading, then CPU shouldn't be driving the bus.
	// If writing, then CPU should be driving the bus
	assign databus =	ishhw == 2'b00 ? bbr_buf[7:0] : // Low Half Word first
						ishhw == 2'b01 ? bbr_buf[15:8] : // Then High Half Word
						rda ? {8{1'bz}} : // Read Ready
						(tbr && received == 2'b10) ? buffer :	// Write Ready
						{8{1'bz}};

	// Tie chip select to one
	assign iocs = 1'b1;
	assign iorw = write_read_op;

	// Register selection
	assign ioaddr =  	ishhw == 2'b00 ? LOW_DIV_BUF :
						ishhw == 2'b01 ? HI_DIV_BUF : 
						(tbr && received == 2'b10) || rda ? TRANSMIT : STATUS;

endmodule
