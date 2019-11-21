module PB_rise(rise, PB, rst_n, clk);
output logic rise;
input PB, rst_n, clk;

logic ff1, ff2, ff3;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		ff1 <= 1;
		ff2 <= 1;
		ff3 <= 1;
	end else begin
		ff1 <= PB;
		ff2 <= ff1;
		ff3 <= ff2;
	end
end

// posedge if ff2 is 1 and ff3 is 0
assign rise = !ff3 && ff2;

endmodule

