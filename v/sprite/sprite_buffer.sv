`include "../constants.sv"

/**
 * Buffer to store sprite image
 * Handles reading out in correct orientation
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

typedef enum logic [1:0] { IDLE, WRITE, READ } state_t;
state_t state, next_state;

// pixel = row * 8 + col
assign sprite_px_ptr = (ori == `UP || ori == `DOWN) ? { a, b } : { b, a };
assign {o_r, o_g, o_b} = buffer[sprite_px_ptr];

// read ori logic
always_ff @(posedge clk)
	if(state == READ) begin
		// inc b
		if(ori == `UP || ori == `LEFT)
			b = b + 1;
		else
			b = b - 1;
		if(buffer_ptr[2:0] == 'd7) begin
			// inc a
			if(ori == `UP || ori == `RIGHT)
				a = a + 1;
			else
				a = a - 1;
		end
	end else
		case(ori)
			`UP:    { a, b } <= 0;
			`RIGHT: { a, b } <= { 3'd0, 3'd7 };
			`DOWN:  { a, b } <= { 3'd7, 3'd7 };
			`LEFT:  { a, b } <= { 3'd7, 3'd0 };
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

// state machine
always_ff @(posedge clk, negedge rst_n)
	if(!rst_n)
		state <= IDLE;
	else
		state <= next_state;

always_comb begin
	next_state = IDLE;

	case(state)
		IDLE:
			if(write)
				next_state = WRITE;
			else if(read)
				next_state = READ;
		WRITE:
			if(buffer_ptr != 63)
				next_state = WRITE;
		READ:
			if(buffer_ptr != 63)
				next_state = READ;
	endcase
end

endmodule