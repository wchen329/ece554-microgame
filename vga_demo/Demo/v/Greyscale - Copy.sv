module Greyscale(clk, rst_n, r, g, b, dval, grey);
input clk, rst_n, dval;
input [11:0] r, g, b;
output logic [11:0] grey;

logic [12:0] avg;
logic [11:0] scaled;

assign avg = (r + g + b) / 3; // average
// assign scaled = avg[12] ? 12'hFFF : avg[11:0]; // saturation
// assign scaled = |avg[12:11] ? 12'h7FF : avg[11:0]; // saturation

always @(posedge clk, negedge rst_n)
	if(!rst_n)
		grey <= 0;
	else if(dval)
		grey <= avg;
		// grey <= scaled;

endmodule
