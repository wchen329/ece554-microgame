/* LFSR 32-bit
 * a.k.a Psuedo-Random Number Generator
 *
 * wchen329
 */
module lfsr_32(input clk, input rst_n, input set_seed, input[31:0] seed_in, output[31:0] out);

	wire[31:0] sbo;
	wire[31:0] next_state;
	reg[31:0] v; // Current "random" value

	// Sequential logics
	always @(posedge clk, negedge rst_n) begin

		// Reset if asserted
		if(!rst_n) begin
			v <= 32'd0;
		end

		// Set seed as necessary
		else if(set_seed) begin
			v <= seed_in;
		end

		// Otherwise, assign based on taps
		else begin
			v <= next_state;
		end
	end

	// Static wire assignments
	assign sbo = {1'b0, v[31:1]}; // logical right shift by one
	assign next_state = {v[0], sbo[30], sbo[29] ^ v[0], sbo[28:26], sbo[25]^ v[0], sbo[24] ^ v[0],sbo[23:0]};
		// correct next state, utilizing Taps are at 32, 30, 26, 25
		// Note that sbo[29] == v[30], sbo[25] == v[26], sbp[24] == v[25]
			
	assign out = v;	

endmodule

