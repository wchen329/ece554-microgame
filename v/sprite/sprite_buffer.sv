`include "../constants.sv"

/**
 * Buffer to store sprite image
 * Handles reading out in correct orientation
 * TODO: make sure r/w state logic works (otherwise need to change front end)
 *
 * UP:          RIGHT:
 * r 0 -> 8     c 0 -> 8
 * 	c 0 -> 8    	r 8 -> 0
 * 0..7         48..0
 * 8..15        49..1
 * 48..63       63..7
 *
 * DOWN:        LEFT:
 * r 8 -> 0     c 8 -> 0
 * 	c 8 -> 0    	r 0 -> 8
 * 7..0         63..7
 * 15..8        62..6
 * 63..48       48..0
 *
 * a is outer loop
 * b is inner loop
 */
module sprite_buffer(
	input clk, rst_n,
	input read, write,
	input [7:0] i_r, i_g, i_b,
	input set_orientation,
	input [1:0] orientation,
	output logic [7:0] o_r, o_g, o_b
);

logic [1:0] ori;
logic [0:63] [23:0] buffer;
logic [5:0] buffer_ptr, sprite_px_ptr;
logic [2:0] a, b;
logic signed [1:0] a_inc, b_inc;

typedef enum logic [1:0] { IDLE, WRITE, READ } state_t;
state_t state, next_state;

assign a_inc = (ori == `UP || `RIGHT) ? 1 : -1;
assign b_inc = (ori == `UP || `LEFT) ? 1 : -1;
assign sprite_px_ptr = (ori == `UP || `DOWN) ? (a << 3) + b : (b << 3) + a;

// read ori logic
always_ff @(posedge clk)
	if(state == READ) begin
		b = b + b_inc;
		if(buffer_ptr[2:0] == 'd7)
			a = a + a_inc;
	end else
		case(ori)
			`UP:    { a, b } <= 0;
			`RIGHT: { a, b } <= { 8'd0, 8'd7 };
			`DOWN:  { a, b } <= { 8'd7, 8'd7 };
			`LEFT:  { a, b } <= { 8'd7, 8'd0 };
		endcase

// orientation flop
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		ori <= 0;
	else if(set_orientation)
		ori <= orientation;

// buffer_ptr
always_ff @(posedge clk)
	if(state == WRITE || state == READ)
		buffer_ptr <= buffer_ptr + 1;
	else
		buffer_ptr <= 0;

// buffer writing
always_ff @(posedge clk)
	if(state == WRITE)
		buffer[buffer_ptr] <= { i_r, i_g, i_b };

// buffer reading
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		{ o_r, o_g, o_b } <= 0;
	else if(state == READ)
		{o_r, o_g, o_b} <= buffer[sprite_px_ptr];

// state machine
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;

always_comb begin
	next_state <= IDLE;

	case(state)
		IDLE:
			if(write)
				next_state <= WRITE;
			else if(read)
				next_state <= READ;
		WRITE:
			if(buffer_ptr != 63)
				next_state = WRITE;
		READ:
			if(buffer_ptr != 63)
				next_state = READ;
	endcase
end

endmodule