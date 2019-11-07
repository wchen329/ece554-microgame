module system_timer(input clk, input rst, output [31:0] t);
reg [31:0] cycle_count;
reg [31:0] ms_count;

assign t = ms_count;

always@(posedge clk) begin
	if (rst) begin
		cycle_count <= 0;
		ms_count <= 0;
	end
	else if (cycle_count == 32'd50000) begin
		ms_count <= ms_count + 1;
		cycle_count <= 1;
	end
	else begin
		cycle_count <= cycle_count + 1;
	end
end
endmodule
