/* BRG
 * also known as "Baud Rate Generator"
 */
module BRG(input clk, start, div_hword, input[7:0] div_in, output enable);

	localparam HZ_PER_TERAHERTZ = 64'd1000000000000;

	// Frequency Counter
	reg[15:0] down_counter;
	reg[15:0] br; // division buffer

	// Phase Setting
	always @(posedge clk) begin
		
		// Reset the counter state to 0 (i.e. accept a new counter)
		if(start) begin		
			down_counter <= 0;

			///////////////////
			// BASE REGISTER //
			///////////////////
			if(div_hword) begin
				br[15:8] <= div_in;
			end
			else begin
				br[7:0] <= div_in;
			end
		end

		// Otherwise, go set the down counter register and the base register
		else begin		

			///////////////////////////
			// DOWN COUNTER REGISTER //
			///////////////////////////

			// Set it to the maximum value if currently 0
			if(down_counter == 0) begin
				
				if(br == 16'd38400) begin
					down_counter <= (16'd80); // Counter for 38400
				end
				
				if(br == 16'd19200) begin
					down_counter <= (16'd161); // Counter for 19200
				end
				
				if(br == 16'd9600) begin
					down_counter <= (16'd325); // Counter for 9600
				end
				
				if(br == 16'd4800) begin
					down_counter <= (16'd650); // Counter for 4800
				end
				
			end

			// Otherwise, decrement
			else begin
				down_counter <= (down_counter - 1); 
			end
		end
	end

	// Static asignments
	assign enable = down_counter == 32'd1 ? 1'b1 : 1'b0; // enabled to count down again, any time the counter is 0.

endmodule
