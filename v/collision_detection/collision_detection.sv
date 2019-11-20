module collision_detection(
	input clk, rst_n,
	input [7:0] a_x, a_y, a_width, a_height,
	input [7:0] b_x, b_y, b_width, b_height,
	output collision
);

//TODO: check screen orientation
/**
 * (x, y)                    (x2 = x + width, y)
 * 
 * 
 * (x, y2 = y + height)      (x2, y2)
 */

logic [7:0] a_x2, a_y2;
logic [7:0] b_x2, b_y2;

always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		a_x2 <= 0;
		a_y2 <= 0;
		b_x2 <= 0;
		b_y2 <= 0;
	end else begin
		a_x2 <= a_x + a_width;
		a_y2 <= a_y + a_height;
		b_x2 <= b_x + b_width;
		b_y2 <= b_y + b_height;
	end
end


assign h_overlap = (a_x <= b_x && a_x2 >= b_x) || (b_x <= a_x && b_x2 >= a_x);
assign v_overlap = (a_y <= b_y && a_y2 >= b_y) || (b_y <= a_y && b_y2 >= a_y);

assign collision = h_overlap && v_overlap;

endmodule
