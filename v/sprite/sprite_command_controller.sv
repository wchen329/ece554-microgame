`include "../constants.sv"

/**
 * Handles sprite commands
 * Instantiates sprite buffers, sprite command fifo, and frame buffer
 *
 * Sprite fifo command format:
 * WFB: { 3'opcode, 8'x, 8'y, 8'r, 8'g, 8'b }
 * DFB: { 3'opcode }
 * LS:  { 3'opcode, 3'sprite_reg, 2'orientation, 16'address }
 * DS:  { 3'opcode, 3'sprite_reg, 8'x, 8'y }
 * CS:  { 3'opcode, 8'x, 8'y }
 * RS:  { 3'opcode, 3'sprite_reg, 2'orientation }
 */
module sprite_command_controller(
	input clk, rst_n,
	input write_cmd,
	input [2:0] display_op,
	input [2:0] sprite_reg,
	input [1:0] orientation,
	input [7:0] x, y,
	input [15:0] address,
	input [7:0] r, g, b,
	input [31:0] mem_in,
	output logic [15:0] mem_address,
	output logic mem_read
);

// cmd signals
logic [42:0] cmd, curr_cmd;
logic [2:0] cmd_op;
logic [2:0] cmd_sprite_reg;
logic [1:0] cmd_orientation;
logic [7:0] cmd_x, cmd_y;
logic [15:0] cmd_address;
logic [7:0] cmd_r, cmd_g, cmd_b;

assign cmd_op = curr_cmd[42:40];

// frame buffer signals
logic wfb, dfb, fb_busy;
logic [7:0] fb_x, fb_y;
logic [7:0] fb_r, fb_g, fb_b;

// cmd fifo signals
logic fifo_read, fifo_write;

// sprite buffer signals
logic [7:0] sb_read, sb_write, sb_set_ori;
logic [7:0] sb_r, sb_g, sb_b;
logic [7:0] sb_o_r, sb_o_g, sb_o_b;
logic [5:0] sb_px_count;

typedef enum logic [2:0] { IDLE, WFB, DFB, LS, DS, CS, RS } state_t;
state_t state, next_state;

frame_buffer frame_buffer(
	.clk(clk),
	.rst_n(rst_n),
	.x(fb_x),
	.y(fb_y),
	.r(fb_r),
	.g(fb_g),
	.b(fb_b),
	.write(wfb),
	.display(dfb),
	.busy(fb_busy)
);
// DS: read from sprite
// WFB: use cmd
// CS / other: 0
assign { fb_r, fb_g, fb_b } = (state == DS) ? { sb_o_r, sb_o_g, sb_o_b } :
															(state == WFB) ? { cmd_r, cmd_g, cmd_b } :
															0;
// WFB: cmd x/y
// CS/DS: cmd x/y + sprite px
assign { fb_x, fb_y } = (state == WFB) ? { cmd_x, cmd_y } :
												{ cmd_x + sb_px_count, cmd_y + sb_px_count};

cmd_fifo sprite_command_fifo(
	.clk(clk),
	.rst_n(rst_n),
	.cmd(cmd),
	.read(fifo_read),
	.write(write_cmd),
	.curr_cmd(curr_cmd)
);

genvar i;
generate
	for(i = 0; i < `SPRITE_BUFFERS; i = i + 1) begin
		sprite_buffer sprite_buffer(
			.clk(clk),
			.rst_n(rst_n),
			.read(sb_read[i]),
			.write(sb_write[i]),
			.i_r(sb_r),
			.i_g(sb_g),
			.i_b(sb_b),
			.set_orientation(sb_set_ori[i]),
			.orientation(cmd_orientation),
			.o_r(sb_o_r),
			.o_b(sb_o_b),
			.o_g(sb_o_g)
		);
	end
endgenerate

// input to sprite cmd
always_comb begin
	case(display_op)
		`SPRITE_WFB: cmd = { `SPRITE_WFB, x, y, r, g, b };
		`SPRITE_DFB: cmd = { `SPRITE_DFB, 40'h? };
		`SPRITE_LS:  cmd = { `SPRITE_LS, sprite_reg, orientation, address, 10'h? };
		`SPRITE_DS:  cmd = { `SPRITE_DS, sprite_reg, x, y, 12'h? };
		`SPRITE_CS:  cmd = { `SPRITE_CS, x, y, 25'h? };
		`SPRITE_RS:  cmd = { `SPRITE_RS, sprite_reg, orientation, 36'h? };
		default: cmd = { 3'h0, 40'h? };
	endcase
end

// sprite curr_cmd to signals
always_comb begin
	cmd_x = 0;
	cmd_y = 0;
	cmd_r = 0;
	cmd_g = 0;
	cmd_b = 0;
	cmd_sprite_reg = 0;
	cmd_orientation = 0;
	cmd_address = 0;

	case(cmd_op)
		`SPRITE_WFB: {cmd_x, cmd_y, cmd_r, cmd_g, cmd_b } = curr_cmd[39:0];
		// `SPRITE_DFB:
		`SPRITE_LS:  { cmd_sprite_reg, cmd_orientation, cmd_address } = curr_cmd[39:9];
		`SPRITE_DS:  { cmd_sprite_reg, cmd_x, cmd_y } = curr_cmd[39:11];
		`SPRITE_CS:  { cmd_x, cmd_y } = curr_cmd[39:24];
		`SPRITE_RS:  { cmd_sprite_reg, cmd_orientation } = curr_cmd[39:35];
	endcase
end

// sp_px_count for sprite r/w
always_ff @(posedge clk)
	if(state == LS || state == DS)
		sb_px_count <= sb_px_count + 1;
	else
		sb_px_count <= 0;

// read from mem
// colors are stored as { 8'?, 8'r, 8'g, 8'b }
assign mem_address = cmd_address + sb_px_count;
always_ff @(posedge clk)
	if(state == LS)
		{ sb_r, sb_g, sb_b } = mem_in[23:0];
	else
		{ sb_r, sb_g, sb_b } = 0;

always_comb begin
	next_state = IDLE;
	wfb = 0;
	dfb = 0;
	sb_set_ori = 0;
	sb_write = 0;
	sb_read = 0;
	fifo_read = 0;
	mem_read = 0;

	case(state)
		IDLE: begin
			case(cmd_op)
				`SPRITE_WFB: begin
					next_state = WFB;
					wfb = 1;
				end
				`SPRITE_DFB: begin
					next_state = DFB;
					dfb = 1;
				end
				`SPRITE_LS: begin
					next_state = LS;
					sb_set_ori[cmd_sprite_reg] = 1;
					sb_write[cmd_sprite_reg] = 1;
					mem_read = 1;
				end
				`SPRITE_DS: begin
					next_state = DS;
					sb_read[cmd_sprite_reg] = 1;
				end
				`SPRITE_CS: begin
					next_state = CS;
				end
				`SPRITE_RS: begin
					next_state = RS;
					sb_set_ori[cmd_sprite_reg] = 1;
				end
			endcase
		end
		WFB: begin
			// wait 1 clk
			fifo_read = 1;
		end
		DFB: begin
			// wait until frame buffer done being busy
			if(!fb_busy)
				fifo_read = 1;
			else
				next_state = DFB;
		end
		LS: begin
			// wait until done writing to sprite buffer
			if(sb_px_count == 63)
				fifo_read = 1;
			else begin
				next_state = LS;
				mem_read = 1;
			end
		end
		DS: begin
			// wait until done reading/writing from/to sprite/frame buffer
			wfb = 1;
			if(sb_px_count == 63)
				fifo_read = 1;
			else
				next_state = DS;
		end
		CS: begin
			// wait until done writing to frame buffer
			wfb = 1;
			if(sb_px_count == 63)
				fifo_read = 1;
			else
				next_state = CS;
		end
		RS: begin
			// wait one cycle
			fifo_read = 1;
		end
	endcase
end

endmodule
