module button
#(
	parameter CYCLES = 20
)(
	input clk,
	input dirty,
	input pulse,
	output clean
);

logic [15:0] count;

always @(posedge clk) begin
	if(dirty) begin
		if(count < CYCLES + 1) begin
			count <= count + 1;
		end
	end else begin
		count <= 0;
	end
end

assign clean = pulse ? count == CYCLES : count >= CYCLES;

endmodule
