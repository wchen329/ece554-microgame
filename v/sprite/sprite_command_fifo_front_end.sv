`include "../constants.sv"

/**
 * Handles sprite commands
 * Instantiates sprite buffers, sprite command fifo, and frame buffer
 * 
 * Sprite fifo command format:
 * WFB: { 3'opcode, 8'x, 8'y, 8'r, 8'g, 8'b }
 * DFB: { 3'opcode }
 * LS:  { 3'opcode, 3'sprite_reg, 2'orientation, 16'address }
 * DS:  { 3'opcode, 3'sprite_reg, 8'x, 8'y, 8'r, 8'g, 8'b }
 * CS:  { 3'opcode, 8'x, 8'y }
 * RS:  { 3'opcode, 3'sprite_reg, 2'orientation }
 */
module sprite_command_fifo_front_end(
	input clk, rst_n,
	input [2:0] display_op,
	input [2:0] sprite_reg,
	input [1:0] orientation,
	input [7:0] x, y,
	input [15:0] address,
	input [7:0] r, g, b
);

logic [45:0] cmd;

frame_buffer frame_buffer(
	.clk(clk),
	.rst_n(rst_n),
	.x(),
	.y(),
	.r(),
	.g(),
	.b(),
	.write(),
	.display(),
	.busy()
);

always_comb begin
	case(display_op)
		`SPRITE_WFB: cmd = { `SPRITE_WFB, x, y, r, g, b, 'h0 };
		`SPRITE_DFB: cmd = { `SPRITE_DFB, 'h0 };
		`SPRITE_LS:  cmd = { `SPRITE_LS, sprite_reg, orientation, address, 'h0 };
		`SPRITE_DS:  cmd = { `SPRITE_DS, sprite_reg, x, y, r, g, b };
		`SPRITE_CS:  cmd = { `SPRITE_CS, x, y, 'h0 };
		`SPRITE_RS:  cmd = { `SPRITE_RS, sprite_reg, orientation, 'h0 };
		default: cmd = 'h0;
	endcase
end

endmodule
