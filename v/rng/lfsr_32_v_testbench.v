/* lfsr_32_testbench
 * Testbench for LFSR
 * wchen329
 */
module lfsr_32_testbench();

	reg clk;
	reg set_seed;
	reg start_count;
	reg[31:0] seed_in;
	reg[31:0] random_count;

	wire clk_w;
	wire set_seed_w;
	wire[31:0] seed_in_w;
	wire[31:0] lfsr_probe;

	// LFSR under test
	lfsr_32 DUT(.clk(clk_w), .set_seed(set_seed_w), .seed_in(seed_in_w), .out(lfsr_probe));

	// Clock Signal
	always #50 clk = ~clk;

	// Termination condition
	always @(posedge clk) begin
		if(start_count && lfsr_probe == seed_in) begin
			$stop;
			$display("Register cycle detected!\nTotal Random Numbers Generated: %d", random_count);
			random_count <= 1;
		end
		else begin
			random_count = random_count + 1;
		end
	end

	initial begin
		random_count = 1;
		start_count = 1'b0;
		clk = 1'b0;
		set_seed = 1'b1;
		seed_in = 89204561;

		@(posedge clk);
		#2 set_seed = 1'b0; // Start Generating
		
		@(posedge clk);
		#2 start_count = 1'b1;
	end

	// Static wires..
	assign set_seed_w = set_seed;
	assign clk_w = clk;
	assign seed_in_w = seed_in;

endmodule
