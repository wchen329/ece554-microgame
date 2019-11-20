/**
 * frame buffer + sprite + fake mem
 * btns: LS, DS, RS, rst_n
 * switches for reg,x,y / rotation
 * 
 * need: SW, KEY, LED, VGA
 */
`include "constants.sv"

module sprite_command_controller_fpga(
///////////// CLOCK //////////
	input               CLOCK_50,
	input               CLOCK2_50,
	input               CLOCK3_50,
	input               CLOCK4_50,

///////////// SEG7 //////////
	output reg   [6:0]  HEX0,
	output reg   [6:0]  HEX1,
	output reg   [6:0]  HEX2,
	output reg   [6:0]  HEX3,
	output reg   [6:0]  HEX4,
	output reg   [6:0]  HEX5,

//////////// KEY //////////
	input        [3:0]  KEY,

///////////// LED //////////
	output		   [9:0]	LEDR,

///////////// SW //////////
	input        [9:0]  SW
);

logic rst_n;
logic key3, key2, key1;
// sprite cmd ctrl
logic [79:0] cmd;
logic [2:0] opcode;
logic write_cmd;
// mem
logic [31:0] mem_in;
logic [15:0] mem_address;
logic mem_read;
// frame buffer
logic fb_busy;
logic fb_wfb, fb_dfb;
logic [15:0] fb_px;
logic [7:0] fb_r, fb_g, fb_b;

// use PB_rise to make keys only 1 clock
PB_rise pb1(
	.clk(CLOCK),
	.rst_n(rst_n),
	.PB(KEY[1]),
	.rise(key1)
);

PB_rise pb2(
	.clk(CLOCK),
	.rst_n(rst_n),
	.PB(KEY[2]),
	.rise(key2)
);

PB_rise pb3(
	.clk(CLOCK),
	.rst_n(rst_n),
	.PB(KEY[3]),
	.rise(key3)
);

sprite_command_controller sprite_command_controller(
	.clk(CLOCK_50),
	.rst_n(rst_n),
	.write_cmd(write_cmd),
	.cmd(cmd),
	.mem_in(mem_in),
	.mem_address(mem_address),
	.mem_read(mem_read),
	.fb_busy(fb_busy),
	.fb_wfb(fb_wfb),
	.fb_dfb(fb_dfb),
	.fb_px(fb_px),
	.fb_r(fb_r),
	.fb_g(fb_g),
	.fb_b(fb_b)
);

// TODO: inst frame buffer

// sprite mem
logic [31:0] sprite_mem[0:255];
assign mem_in = sprite_mem[mem_address];

initial $readmemh("sprite_buffer_mem.hex", sprite_mem);

assign rst_n = KEY[0];
always_comb
	case({key3, key2, key1})
		3'b100: begin
			write_cmd = 1;
			opcode = `SPRITE_LS
		end
		3'b010: begin
			write_cmd = 1;
			opcode = `SPRITE_DS
		end
		3'b001: begin
			write_cmd = 1;
			opcode = `SPRITE_RS
		end
		default: begin
			write_cmd = 0;
			opcode = 0;
		end
	endcase

/**
 * addrs are 0, 64, 128, and 192
 * x,y are 0 -> 224, by 32s
 */
assign cmd = {
	opcode,
	SW[9:7], // sprite_reg
	SW[6:5], // orientation
	24'h0, // RGB
	SW[5:3], 5'h0, // x
	SW[2:0], 5'h0, // y
	16'h0, 8'h0, SW[1:0], 6'h0 // addr
};

endmodule