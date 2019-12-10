module sprite_register(
	input clk, rst_n,
	input [2:0] x, y,
	input [23:0] rgb_in,
	input [1:0] orientation_in,
	input write,
	output [23:0] rgb_out,
	output reg [1:0] orientation_out
);

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		orientation_out <= 0;
	end else if(write) begin
		orientation_out <= orientation_in;
	end
end

reg [23:0] register [7:0][7:0];

integer i, j;
always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		for(i=0; i<8; i=i+1) begin
			for(j=0; j<8; j=j+1) begin
				register[i][j] <= 24'b0;
			end
		end
	end else if(write) begin
		register[y][x] <= rgb_in;
	end
end

assign rgb_out = register[y][x];

endmodule
