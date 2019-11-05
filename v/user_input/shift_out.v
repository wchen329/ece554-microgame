/* Transmit Control, Shift Register, and Buffer
 * Important to generate signal that can be used in handshaking with CPU (i.e. TBR) based on count of 
 * baud rate generator.
 */
module shift_out(input clk, input rst, input en, input baud_en, input [7:0]data, output out, output tbr);
	reg [9:0] buffer;
	reg [3:0] bit_counter;
	reg [3:0] counter;
	reg r_tbr;
	reg r_out;
	
	assign out = r_out;
	assign tbr = r_tbr;
	
	always @(posedge clk) begin
		// Initialize all necessary registers
		if (rst) begin
			buffer <= 10'b0;
			counter <= 4'b0;
			bit_counter <= 4'b0;
			r_tbr <= 1'b1;
			r_out <= 1'b1;
		end

		// Enable the transmit logic, and load the data we want to transmit into the buffer. This means we will read in data from the CPU
		// and will begin to send this data bit-by-bit down TxD back to the target device.
		else if (en) begin
			buffer <= {1'b1, data, 1'b0};
			bit_counter <= 4'd10; // begin counting
			counter <= 4'd15;
			r_tbr <= 1'b0;
		end

		// Now, start relaying information back bit-by-bit
		// In the meanwhile, we will be counting down every bit we read.
		// (kind of combine shift register and shift buffer)
		else if (bit_counter > 4'b0) begin
			if (baud_en) begin
				if (counter > 4'd0) begin
					counter <= counter - 4'd1;
				end
				else begin
					bit_counter <= bit_counter - 4'd1;
					counter <= 4'd15;
					r_out <= buffer[0];
					buffer <= {buffer[0], buffer[9:1]};
				end
			end
		end

		// Okay, at this point there's no data being transferred, so now the transmit buffer is ready again (if it wasn't before)
		else begin
			r_out <= 1'b1;
			r_tbr <= 1'b1;
		end
	end
	
endmodule
