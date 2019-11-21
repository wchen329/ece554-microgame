/* Receive Shift Register, Control, and Buffer
 * Responsible for reading data into SPART
 */
module shifter(input rxd, input clk, input rst, input baud_en, output [7:0]data, output has_data);
	reg [7:0] shifter_data;
	reg [7:0] buffer;
	reg [3:0] count;
	reg [3:0] bit_count;
	reg full;
	
	assign data = buffer;
	assign has_data = full;
	
	always @(posedge clk) begin
		// Initialize all necessary registers
		if (rst) begin
			shifter_data <= 8'b0;
			buffer <= 8'b0;
			full <= 1'b0;
			count <= 4'b0;
			bit_count <= 4'b0;
		end

		// BRG has raised enable signal now, so now start counting bits we've received
		else if (baud_en) begin

			// Check if we can afford to read another bit or not, if we can't, don't corrupt what we have.
			if (full == 1'b0) begin

				// Begin counting bits				
				if (count < 4'd8 && bit_count == 4'b0) begin
					if (rxd == 1'b0) begin
						count <= count + 4'd1;
					end
					else begin
						count <= (count == 4'b0) ? 4'b0 : (count - 4'd1);
					end
				end

				// Count and continue counting to know when we've reached a byte (and which point we can move data into the buffer)
				else if (bit_count == 4'b0) begin
					bit_count <= bit_count + 4'd1;
					count <= 4'd0;
				end

				else if (bit_count > 4'b0 && count < 4'd15) begin
					count <= count + 4'd1;
				end

				// Read yet another bit of rxd if we've counted enough
				else if (bit_count > 4'b0 && bit_count < 4'd9 && count == 4'd15) begin
					count <= 4'b0;
					shifter_data <= {rxd, shifter_data[7:1]};
					bit_count <= bit_count + 4'd1;
				end

				// So now we've read all the data necessary for this byte. Now, we will reset the read shift register
				// and prepare to read another, while moving the data we just constructed into the read buffer.
				else if (bit_count == 4'd9 && count == 4'd15) begin
					if (rxd == 1'b1) begin
						buffer <= shifter_data;
						full <= 1'b1;
						count <= 4'b0;
						bit_count <= 4'b0;
						shifter_data <= 8'b0;
					end
				end
				else begin
					$display("Getting into Nowhere!");
				end
			end
		end
	end

endmodule