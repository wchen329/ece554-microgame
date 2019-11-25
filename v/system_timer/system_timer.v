module system_timer(input clk, input rst_n, output reg [31:0] ms);

reg [31:0] cycle_count;

always@(posedge clk) begin
	if (!rst_n) begin
		cycle_count <= 0;
		ms <= 0;
	end
	else if (cycle_count == 32'd50000) begin
		ms <= ms + 1;
		cycle_count <= 1;
	end
	else begin
		cycle_count <= cycle_count + 1;
	end
end

endmodule
