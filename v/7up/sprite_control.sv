`include "../constants.sv"

module sprite_control(
	input clk, rst_n,
	input [79:0] command,
	input produce,
	input [31:0] sprite_mem_out,
	output logic [31:0] sprite_mem_address,
	output logic vga_write,
	output logic vga_display,
	output logic [7:0] vga_x, vga_y,
	output logic [7:0] vga_r, vga_g, vga_b
);


typedef struct packed {
	logic [2:0] op;
	logic [2:0] register;
	logic [1:0] orientation;
	logic [7:0] red;
	logic [7:0] green;
	logic [7:0] blue;
	logic [7:0] x;
	logic [7:0] y;
	logic [31:0] address;
} sprite_command_t;

logic consume;
sprite_command_t next_command;
logic fifo_empty;

sprite_fifo fifo(
	.clk(clk),
	.rst_n(rst_n),
	.produce(produce),
	.command_in(command),
	.consume(consume),
	.command_out(next_command),
	.empty(fifo_empty)
);


reg [79:0] curr_command_raw;
sprite_command_t curr_command;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		curr_command_raw <= 80'b0;
	end else if(consume) begin
		curr_command_raw <= next_command;
	end
end

assign curr_command = curr_command_raw;


logic [2:0] reg_select;
logic [2:0] reg_x, reg_y;
logic [23:0] reg_rgb_in;
logic [1:0] reg_orientation_in;
logic reg_write;
logic [23:0] reg_rgb_out_raw [7:0];
logic [23:0] reg_rgb_out;
logic [1:0] reg_orientation_out_raw [7:0];
logic [1:0] reg_orientation_out;

genvar g;
generate
	for(g=0; g<8; g=g+1) begin : generate_sprite_registers
		sprite_register register(
			.clk(clk),
			.rst_n(rst_n),
			.x(reg_x),
			.y(reg_y),
			.rgb_in(reg_rgb_in),
			.orientation_in(reg_orientation_in),
			.write(reg_write && reg_select == g),
			.rgb_out(reg_rgb_out_raw[g]),
			.orientation_out(reg_orientation_out_raw[g])
		);
	end
endgenerate

assign reg_rgb_out = reg_rgb_out_raw[reg_select];
assign reg_orientation_out = reg_orientation_out_raw[reg_select];


typedef enum { IDLE, RS, DS, CS, LS, WFB, DFB } state_t;

state_t curr_state;
state_t next_state;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		curr_state <= IDLE;
	end else begin
		curr_state <= next_state;
	end
end


reg [31:0] address_offset;
logic [31:0] next_address_offset;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		address_offset <= 32'b0;
	end else begin
		address_offset <= next_address_offset;
	end
end


always_comb begin
	next_state = IDLE;
	consume = 0;
	vga_write = 0;
	vga_display = 0;
	sprite_mem_address = 0;
	vga_x = 0;
	vga_y = 0;
	vga_r = 0;
	vga_g = 0;
	vga_b = 0;
	reg_select = 0;
	reg_x = 0;
	reg_y = 0;
	reg_rgb_in = 0;
	reg_orientation_in = 0;
	reg_write = 0;
	next_address_offset = 0;

	case(curr_state)
		IDLE:begin
			if(!fifo_empty) begin
				consume = 1;
				case(next_command.op)
					`SPRITE_RS:begin
						next_state = RS;
					end
					`SPRITE_DS:begin
						next_state = DS;
					end
					`SPRITE_CS:begin
						next_state = CS;
					end
					`SPRITE_LS:begin
						next_state = LS;
					end
					`SPRITE_WFB:begin
						next_state = WFB;
					end
					`SPRITE_DFB:begin
						next_state = DFB;
					end
					default:begin
						next_state = IDLE;
					end
				endcase
			end
		end
		RS:begin
			next_state = IDLE;
			reg_select = curr_command.register;
			reg_orientation_in = curr_command.orientation;
			reg_write = 1;
		end
		DS:begin
			if(address_offset == 63) begin
				next_state = IDLE;
				next_address_offset = 0;
			end else begin
				next_state = DS;
				next_address_offset = address_offset + 1;
			end
			vga_write = reg_rgb_out != 24'h000000;
			{vga_y, vga_x} = {curr_command.y + address_offset[5:3], curr_command.x + address_offset[2:0]};
			{vga_r, vga_g, vga_b} = reg_rgb_out;
			reg_select = curr_command.register;
			{reg_y, reg_x} =
				reg_orientation_out == 2'b00 ? address_offset[5:0] :
				reg_orientation_out == 2'b01 ? {~address_offset[2:0], address_offset[5:3]} :
				reg_orientation_out == 2'b10 ? ~address_offset[5:0] :
				{address_offset[2:0], ~address_offset[5:3]};
		end
		CS:begin
			if(address_offset == 63) begin
				next_state = IDLE;
				next_address_offset = 0;
			end else begin
				next_state = CS;
				next_address_offset = address_offset + 1;
			end
			vga_write = 1;
			{vga_y, vga_x} = {curr_command.y + address_offset[5:3], curr_command.x + address_offset[2:0]};
			vga_r = 8'h00;
			vga_g = 8'h00;
			vga_b = 8'h00;
		end
		LS:begin
			if(address_offset == 64) begin
				next_state = IDLE;
				next_address_offset = 0;
			end else begin
				next_state = LS;
				next_address_offset = address_offset + 1;
			end
			sprite_mem_address = curr_command.address + address_offset;
			reg_select = curr_command.register;
			{reg_y, reg_x} = address_offset[5:0] - 1;
			reg_rgb_in = sprite_mem_out[23:0];
			reg_orientation_in = curr_command.orientation;
			reg_write = 1;
		end
		WFB:begin
			next_state = IDLE;
			vga_write = 1;
			vga_x = curr_command.x;
			vga_y = curr_command.y;
			vga_r = curr_command.red;
			vga_g = curr_command.green;
			vga_b = curr_command.blue;
		end
		DFB:begin
			next_state = IDLE;
			vga_display = 1;
		end
	endcase
end


endmodule
