module Greyscale(r, g, b, grey);
input [11:0] r, g, b;
output logic [11:0] grey;

assign grey = (r + g*2 + b) / 4; // average

endmodule
