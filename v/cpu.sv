`include "constants.sv"

module cpu
#(
	parameter INSTRUCTION_ADDRESS_WIDTH=11,
	parameter USER_ADDRESS_WIDTH=11,
	parameter NUM_INPUT_BITS=5
)(
	input clk, rst_n,
	input [35:0] gpio,
	
	output vga_write,
	output vga_display,
	output [15:0] vga_pixnum,
	output [7:0] vga_r,
	output [7:0] vga_g,
	output [7:0] vga_b,
	
	// TODO
	output logic [15:0] addr,
	output reg [2:0] sprite_op_a, sprite_op_b, sprite_op_c,
	output [7:0] the_time,
	input border_en
	// TODO
);


// forwarding declarations

// EX to EX forwarding
logic exmem_fw_ex_enable_op1;
logic exmem_fw_ex_enable_op2;
logic [31:0] exmem_fw_ex;

// MEM to EX forwarding
logic memwb_fw_ex_enable_op1;
logic memwb_fw_ex_enable_op2;
logic [31:0] memwb_fw_ex;

// MEM to MEM forwarding
logic memwb_fw_mem_enable;
logic [31:0] memwb_fw_mem;


// stall request declarations

logic ex_stall_request;
logic mem_stall_request;


///////////////////////////////////////////////////////////////////////////////
// Instruction Fetch
/////////////////////////////////////////////////////////////////////////////


logic pc_stall;


// linking register

logic link;
logic [INSTRUCTION_ADDRESS_WIDTH-1:0] link_address;
reg [INSTRUCTION_ADDRESS_WIDTH-1:0] link_reg;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		link_reg <= 0;
	end else if(link) begin
		link_reg <= link_address;
	end
end


// program counter

// have to flop this to make sure that reset is applied

reg pc_reset;

always_ff @(posedge clk, negedge rst_n) begin
	if(~rst_n) begin
		pc_reset <= 1;
	end else begin
		pc_reset <= 0;
	end
end

logic branch;
logic link_return;
logic [INSTRUCTION_ADDRESS_WIDTH-1:0] branch_address;
logic [INSTRUCTION_ADDRESS_WIDTH-1:0] pc;

// need to track PC in BRAM

reg [INSTRUCTION_ADDRESS_WIDTH-1:0] pc_ghost;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pc_ghost <= 0;
	end else begin
		pc_ghost <= pc;
	end
end

always_comb begin
	if(pc_reset) begin
		pc = 0;
	end else if(branch) begin
		pc = branch_address;
	end else if(link_return) begin
		pc = link_reg;
	end else if(~pc_stall) begin
		// instruction memory is word-addressable
		pc = pc_ghost + 1;
	end else begin
		pc = pc_ghost;
	end
end


// instruction memory

logic [31:0] instruction;

logic [31:0] mem_sprite_out;
logic [INSTRUCTION_ADDRESS_WIDTH-1:0] mem_sprite_address;

instruction_memory #(INSTRUCTION_ADDRESS_WIDTH) instruction_memory(
	.clk(clk),
	.address_a(pc),
	.data_a(instruction),
	.address_b(mem_sprite_address),
	.data_b(mem_sprite_out)
);


///////////////////////////////////////////////////////////////////////////////


// IF/ID register

logic ifid_flush;
logic ifid_stall;

reg [31:0] ifid_instruction;
reg [INSTRUCTION_ADDRESS_WIDTH-1:0] ifid_pc;
reg ifid_is_no_op;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ifid_instruction <= 0;
		ifid_pc <= 0;
		ifid_is_no_op <= 1;
	// pc_reset is also an edge case for startup
	end else if(ifid_flush || pc_reset) begin
		ifid_instruction <= 0;
		// empty edge case, but neat
		ifid_pc <= pc_ghost;
		ifid_is_no_op <= 1;
	end else if(~ifid_stall) begin
		ifid_instruction <= instruction;
		ifid_pc <= pc_ghost;
		// a bit of a bandaid
		ifid_is_no_op <= instruction == 32'b0;
	end
end


///////////////////////////////////////////////////////////////////////////////
// Instruction Decode
/////////////////////////////////////////////////////////////////////////////


// status register

logic cc_update;
logic cc_next_zero, cc_next_sign, cc_next_overflow;
reg cc_zero, cc_sign, cc_overflow;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		cc_zero <= 0;
		cc_sign <= 0;
		cc_overflow <= 0;
	end else if(cc_update) begin
		cc_zero <= cc_next_zero;
		cc_sign <= cc_next_sign;
		cc_overflow <= cc_next_overflow;
	end
end


// register file

logic [4:0] rf_reg1_address;
logic [4:0] rf_reg2_address;
logic [31:0] rf_reg1_data;
logic [31:0] rf_reg2_data;
logic [4:0] rf_write_address;
logic [31:0] rf_write_data;
logic rf_write_lower;
logic rf_write_upper;
logic rf_write;
logic [31:0] rf_rgb;

reg [31:0][31:0] rf;

integer itter_rf_i;
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for(itter_rf_i=0; itter_rf_i<32; itter_rf_i=itter_rf_i+1) begin
			rf[itter_rf_i] <= 0;
		end
	end else if(rf_write || rf_write_lower || rf_write_upper) begin
		// zero register is tied to zero
		if(rf_write_address != 5'b00000) begin
			if(rf_write_lower) begin
				rf[rf_write_address][15:0] <= rf_write_data[15:0];
			end else if(rf_write_upper) begin
				rf[rf_write_address][31:16] <= rf_write_data[15:0];
			end else begin
				rf[rf_write_address] <= rf_write_data;
			end
		end
	end
end

// register file outputs
always_comb begin
	// normal behavior
	rf_reg1_data = rf[rf_reg1_address];
	rf_reg2_data = rf[rf_reg2_address];

	// write-through functionality
	if(rf_write_lower && rf_write_address == rf_reg1_address) begin
		rf_reg1_data = {rf[rf_reg1_address][31:16], rf_write_data[15:0]};
	end else
	if(rf_write_lower && rf_write_address == rf_reg2_address) begin
		rf_reg2_data = {rf[rf_reg2_address][31:16], rf_write_data[15:0]};
	end else
	if(rf_write_upper && rf_write_address == rf_reg1_address) begin
		rf_reg1_data = {rf_write_data[15:0], rf[rf_reg1_address][15:0]};
		end else
	if(rf_write_upper && rf_write_address == rf_reg2_address) begin
		rf_reg2_data = {rf_write_data[15:0], rf[rf_reg2_address][15:0]};
	end else
	if(rf_write && rf_write_address == rf_reg1_address) begin
		rf_reg1_data = rf_write_data;
	end else
	if(rf_write && rf_write_address == rf_reg2_address) begin
		rf_reg2_data = rf_write_data;
	end
end

// register 32 is RGB register, otherwise general-purpose
assign rf_rgb = rf[31];


// TODO REMOVE
assign the_time = rf[1];
// TODO


// control signals for all stages here and beyond

typedef struct packed {
	logic branch;
	logic link;
	logic link_return;
	logic use_dest_as_op2;
} id_control_t;

id_control_t id_control;

typedef struct packed {
	logic select_random;
	logic select_time;
	logic select_input;
	logic select_collision;
	logic select_immediate;
	logic set_tone;
	logic set_seed;
	logic zero_as_op2;
	logic [2:0] alu_op;
	logic alu_use_immediate;
	logic update_conditionals;
	logic seed_random;
	logic [4:0] source1;
	logic [4:0] source2;
} ex_control_t;

ex_control_t init_ex_control;

typedef struct packed {
	logic write_memory;
	logic use_memory_result;
	logic [4:0] source;
} mem_control_t;

mem_control_t init_mem_control;

typedef struct packed {
	logic [4:0] dest_reg;
	logic write_reg;
	logic write_lower;
	logic write_upper;
	logic [2:0] sprite_op;
	logic sprite_produce;
	logic [23:0] rgb;
} wb_control_t;

wb_control_t init_wb_control;


logic [4:0] op;

always_comb begin
	id_control = 0;
	init_ex_control = 0;
	init_mem_control = 0;
	init_wb_control = 0;

	init_ex_control.source1 = rf_reg1_address;
	init_ex_control.source2 = rf_reg2_address;
	init_mem_control.source = rf_reg2_address;

	// decode destination register from instruction
	// furthermore, recall that dest = { sprite_reg, sprite_orientation }
	init_wb_control.dest_reg = ifid_instruction[26:22];

	init_wb_control.rgb = rf_rgb[23:0];

	op = ifid_instruction[31:27];

	// switch on opcode
	case(op)
		5'b00000:begin
			// add
			init_ex_control.alu_op = 3'b000;
			init_ex_control.update_conditionals = 1;

			init_wb_control.write_reg = 1;
		end
		5'b00001:begin
			// addi
			init_ex_control.alu_op = 3'b000;
			init_ex_control.update_conditionals = 1;
			init_ex_control.alu_use_immediate = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00010:begin
			// sub
			init_ex_control.alu_op = 3'b001;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00011:begin
			// and
			init_ex_control.alu_op = 3'b010;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00100:begin
			// andi
			init_ex_control.alu_op = 3'b010;
			init_ex_control.update_conditionals = 1;
			init_ex_control.alu_use_immediate = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00101:begin
			// or
			init_ex_control.alu_op = 3'b011;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00110:begin
			// ori
			init_ex_control.alu_op = 3'b011;
			init_ex_control.update_conditionals = 1;
			init_ex_control.alu_use_immediate = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00111:begin
			// xor
			init_ex_control.alu_op = 3'b100;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01000:begin
			// sll
			init_ex_control.alu_op = 3'b101;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01001:begin
			// srl
			init_ex_control.alu_op = 3'b110;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01010:begin
			// sra
			init_ex_control.alu_op = 3'b111;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01011:begin
			// lli
			init_ex_control.select_immediate = 1;

			init_wb_control.write_lower = 1;
		end
		5'b01100:begin
			// lui
			init_ex_control.select_immediate = 1;

			init_wb_control.write_upper = 1;
		end
		5'b01101:begin
			// lw
			init_mem_control.use_memory_result = 1;

			init_ex_control.select_immediate = 1;

			init_wb_control.write_reg = 1;
		end
		5'b01110:begin
			// sw
			id_control.use_dest_as_op2 = 1;

			init_ex_control.select_immediate = 1;

			init_mem_control.write_memory = 1;
		end
		5'b01111:begin
			// lwo
			init_ex_control.alu_use_immediate = 1;

			init_mem_control.use_memory_result = 1;

			init_wb_control.write_reg = 1;
		end
		5'b10000:begin
			// swo
			id_control.use_dest_as_op2 = 1;

			init_ex_control.alu_use_immediate = 1;

			init_mem_control.write_memory = 1;
		end
		5'b10001:begin
			// b
			id_control.branch = 1;
		end
		5'b10010:begin
			// bl
			id_control.branch = 1;
			id_control.link = 1;
		end
		5'b10011:begin
			// ret
			id_control.link_return = 1;
		end
		5'b10100:begin
			// lk
			init_ex_control.select_input = 1;

			init_wb_control.write_reg = 1;
		end
		5'b10101:begin
			// wfb
			init_ex_control.zero_as_op2 = 1;

			init_wb_control.sprite_op = `SPRITE_WFB;
			init_wb_control.sprite_produce = 1;
		end
		5'b10110:begin
			// dfb
			init_wb_control.sprite_op = `SPRITE_DFB;
			init_wb_control.sprite_produce = 1;
		end
		5'b10111:begin
			// ls
			init_ex_control.select_immediate = 1;

			init_wb_control.sprite_op = `SPRITE_LS;
			init_wb_control.sprite_produce = 1;
		end
		5'b11000:begin
			// ds
			init_ex_control.zero_as_op2 = 1;

			init_wb_control.sprite_op = `SPRITE_DS;
			init_wb_control.sprite_produce = 1;
		end
		5'b11001:begin
			// cs
			init_ex_control.zero_as_op2 = 1;

			init_wb_control.sprite_op = `SPRITE_CS;
			init_wb_control.sprite_produce = 1;
		end
		5'b11010:begin
			// rs
			init_wb_control.sprite_op = `SPRITE_RS;
			init_wb_control.sprite_produce = 1;
		end
		5'b11011:begin
			// sat
			id_control.use_dest_as_op2 = 1;

			init_ex_control.set_tone = 1;
		end
		5'b11100:begin
			// dc
			init_ex_control.select_collision = 1;
			init_ex_control.update_conditionals = 1;
		end
		5'b11101:begin
			// tim
			init_ex_control.select_time = 1;

			init_wb_control.write_reg = 1;
		end
		5'b11110:begin
			// r
			init_ex_control.select_random = 1;

			init_wb_control.write_reg = 1;
		end
		5'b11111:begin
			// sr
			id_control.use_dest_as_op2 = 1;

			init_ex_control.set_seed = 1;
		end
	endcase
end


// branch logic

logic [2:0] branch_case;

assign branch_case = ifid_instruction[26:24];

logic should_branch;

always_comb begin
	should_branch = 0;

	case(branch_case)
		3'b000:begin
			// bne
			should_branch = ~cc_zero;
		end
		3'b001:begin
			// beq
			should_branch = cc_zero;
		end
		3'b010:begin
			// bgt
			should_branch = ~cc_zero && ~cc_sign;
		end
		3'b011:begin
			// blt
			should_branch = ~cc_zero && cc_sign;
		end
		3'b100:begin
			// bge
			should_branch = cc_zero || ~cc_sign;
		end
		3'b101:begin
			// ble
			should_branch = cc_zero || cc_sign;
		end
		3'b110:begin
			// bover
			should_branch = cc_overflow;
		end
		3'b111:begin
			// unconditional
			should_branch = 1;
		end
	endcase
end


// immediate and register operands

logic [31:0] immediate;

assign immediate = {{16{ifid_instruction[15]}}, ifid_instruction[15:0]};

assign rf_reg1_address = ifid_instruction[21:17];
assign rf_reg2_address = id_control.use_dest_as_op2 ? ifid_instruction[26:22] : ifid_instruction[16:12];


// branching control

assign link           = id_control.link && should_branch && ~ifid_stall;
assign link_address   = ifid_pc + 1;
assign branch         = id_control.branch && should_branch && ~ifid_stall;
assign branch_address = ifid_pc + 1 + immediate[INSTRUCTION_ADDRESS_WIDTH-1:0];
assign link_return    = id_control.link_return && ~ifid_stall;
assign ifid_flush     = branch || link_return;


///////////////////////////////////////////////////////////////////////////////


// ID/EX register

logic idex_stall;

reg [31:0] idex_op1;
reg [31:0] idex_op2;
reg [31:0] idex_immediate;
reg idex_is_no_op;

reg [$bits(ex_control_t)-1:0] idex_ex_control;
reg [$bits(mem_control_t)-1:0] idex_mem_control;
reg [$bits(wb_control_t)-1:0] idex_wb_control;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		idex_op1 <= 0;
		idex_op2 <= 0;
		idex_immediate <= 0;
		idex_is_no_op <= 1;

		idex_ex_control <= 0;
		idex_mem_control <= 0;
		idex_wb_control <= 0;
	end else if(~idex_stall && (ifid_is_no_op || ifid_stall)) begin
		idex_op1 <= 0;
		idex_op2 <= 0;
		idex_immediate <= 0;
		idex_is_no_op <= 1;

		idex_ex_control <= 0;
		idex_mem_control <= 0;
		idex_wb_control <= 0;
	end else if(~idex_stall) begin
		idex_op1 <= rf_reg1_data;
		idex_op2 <= rf_reg2_data;
		idex_immediate <= immediate;
		idex_is_no_op <= 0;

		idex_ex_control <= init_ex_control;
		idex_mem_control <= init_mem_control;
		idex_wb_control <= init_wb_control;
	end
end


///////////////////////////////////////////////////////////////////////////////
// Execute
/////////////////////////////////////////////////////////////////////////////


ex_control_t ex_control;

assign ex_control = idex_ex_control;


// ALU

logic [31:0] alu_op1, alu_op2;
logic [31:0] alu_result;
logic alu_zero, alu_sign, alu_overflow;

alu alu(
	.opcode(ex_control.alu_op),
	.operand_a(alu_op1),
	.operand_b(alu_op2),
	.result(alu_result),
	.z(alu_zero),
	.n(alu_sign),
	.v(alu_overflow)
);

assign alu_op1 =
	exmem_fw_ex_enable_op1 ? exmem_fw_ex :
	memwb_fw_ex_enable_op1 ? memwb_fw_ex :
	idex_op1;

assign alu_op2 =
	ex_control.alu_use_immediate ? idex_immediate :
	ex_control.zero_as_op2 ? 32'b0 :
	exmem_fw_ex_enable_op2 ? exmem_fw_ex :
	memwb_fw_ex_enable_op2 ? memwb_fw_ex :
	idex_op2;


// collision detector

logic [7:0] cd_a_x, cd_a_y, cd_a_width, cd_a_height;
logic [7:0] cd_b_x, cd_b_y, cd_b_width, cd_b_height;
logic cd_collision;

collision_detection cd(
	.clk(clk),
	.rst_n(rst_n),
	.a_x(cd_a_x),
	.a_y(cd_a_y),
	.a_width(cd_a_width),
	.a_height(cd_a_height),
	.b_x(cd_b_x),
	.b_y(cd_b_y),
	.b_width(cd_b_width),
	.b_height(cd_b_height),
	.collision(cd_collision)
);

// we use alu op instead of raw register as forwarding applies here too
assign cd_a_x = alu_op1[31:24];
assign cd_a_y = alu_op1[23:16];
assign cd_a_width = alu_op1[15:8];
assign cd_a_height = alu_op1[7:0];
assign cd_b_x = alu_op2[31:24];
assign cd_b_y = alu_op2[23:16];
assign cd_b_width = alu_op2[15:8];
assign cd_b_height = alu_op2[7:0];

reg collision_state;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		collision_state <= 0;
	end else if(ex_control.select_collision) begin
		collision_state <= ~collision_state;
	end
end


// user input

logic [NUM_INPUT_BITS-1:0] user_input;

user_input_buffer stimulus(
	.clk(clk),
	.clr(ex_control.select_input),
	.GPIO(gpio),
	.up(user_input[4]),
	.right(user_input[3]),
	.down(user_input[2]),
	.left(user_input[1]),
	.space(user_input[0]),
	.rst_n(rst_n)
);


// audio control

logic set_tone;
logic [31:0] tone;

audio_controller audio(
	.clk(clk),
	.rst_n(rst_n),
	.set_tone(ex_control.set_tone),
	.tone(alu_op2)
);


// random number generator

logic set_seed;
logic [31:0] seed;
logic [31:0] random;

lfsr_32 randy(
	.clk(clk),
	.rst_n(rst_n),
	.set_seed(ex_control.set_seed),
	// alu op for forwarding
	.seed_in(alu_op2),
	.out(random)
);


// system time

logic [31:0] time_ms;

system_timer timer(
	.clk(clk),
	.rst_n(rst_n),
	.ms(time_ms)
);


// control

logic [31:0] execute_result;

assign execute_result =
	ex_control.select_random ? random :
	ex_control.select_time ? time_ms :
	ex_control.select_input ? {{(32-NUM_INPUT_BITS){1'b0}}, user_input} :
	ex_control.select_immediate ? idex_immediate :
	alu_result;

assign ex_stall_request = ~collision_state && ex_control.select_collision;

assign cc_update = ex_control.update_conditionals && (ex_control.select_collision ^~ collision_state) && ~idex_stall && ~idex_is_no_op;

assign cc_next_zero = ex_control.select_collision ? cd_collision : alu_zero;
assign cc_next_sign = ex_control.select_collision ? 0 : alu_sign;
assign cc_next_overflow = ex_control.select_collision ? 0 : alu_overflow;


///////////////////////////////////////////////////////////////////////////////


// EX/MEM register

logic exmem_stall;

reg [31:0] exmem_result;
reg [31:0] exmem_store_data;
reg exmem_is_no_op;

reg [$bits(mem_control_t)-1:0] exmem_mem_control;
reg [$bits(wb_control_t)-1:0] exmem_wb_control;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		exmem_result <= 0;
		exmem_store_data <= 0;
		exmem_is_no_op <= 1;

		exmem_mem_control <= 0;
		exmem_wb_control <= 0;
	end else if(~exmem_stall && (idex_is_no_op || idex_stall)) begin
		exmem_result <= 0;
		exmem_store_data <= 0;
		exmem_is_no_op <= 1;

		exmem_mem_control <= 0;
		exmem_wb_control <= 0;
	end else if(~exmem_stall) begin
		exmem_result <= execute_result;
		exmem_store_data <= idex_op2;
		exmem_is_no_op <= 0;

		exmem_mem_control <= idex_mem_control;
		exmem_wb_control <= idex_wb_control;
	end
end


///////////////////////////////////////////////////////////////////////////////
// Memory
/////////////////////////////////////////////////////////////////////////////


mem_control_t mem_control;

assign mem_control = exmem_mem_control;


// data memory

logic [USER_ADDRESS_WIDTH-1:0] user_memory_address;
logic [31:0] user_memory_data_in;
logic [31:0] user_memory_data_out;

assign user_memory_address = exmem_result[USER_ADDRESS_WIDTH-1:0];

assign user_memory_data_in =
	memwb_fw_mem_enable ? memwb_fw_mem :
	exmem_store_data;

data_memory #(USER_ADDRESS_WIDTH) data_memory(
	.clk(clk),
	.rst_n(rst_n),
	.address(user_memory_address),
	.data_in(user_memory_data_in),
	.read(mem_control.use_memory_result),
	.write(mem_control.write_memory),
	.data_out(user_memory_data_out),
	.stall(mem_stall_request)
);


// control

logic [31:0] memory_result;
logic [31:0] memory_secondary_result;

assign memory_result =
	mem_control.use_memory_result ? user_memory_data_out :
	exmem_result;

assign memory_secondary_result = exmem_store_data;


///////////////////////////////////////////////////////////////////////////////


// MEM/WB register

reg [31:0] memwb_result1;
reg [31:0] memwb_result2;
reg memwb_is_no_op;

reg [$bits(wb_control_t)-1:0] memwb_wb_control;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		memwb_result1 <= 0;
		memwb_result2 <= 0;
		memwb_is_no_op <= 1;

		memwb_wb_control <= 0;
	end else if(exmem_is_no_op || exmem_stall) begin
		memwb_result1 <= 0;
		memwb_result2 <= 0;
		memwb_is_no_op <= 1;

		memwb_wb_control <= 0;
	end else begin
		memwb_result1 <= memory_result;
		memwb_result2 <= memory_secondary_result;
		memwb_is_no_op <= 0;

		memwb_wb_control <= exmem_wb_control;
	end
end


///////////////////////////////////////////////////////////////////////////////
// Write Back
/////////////////////////////////////////////////////////////////////////////


wb_control_t wb_control;

assign wb_control = memwb_wb_control;


// register writing

assign rf_write_address = wb_control.dest_reg;
assign rf_write_data = memwb_result1;
assign rf_write = wb_control.write_reg && ~memwb_is_no_op;
assign rf_write_lower = wb_control.write_lower;
assign rf_write_upper = wb_control.write_upper;


// sprite command issue

// { command, reg, orientation, rgb, x, y, address }
logic [79:0] sprite_command;

logic [2:0]  sc_op;
logic [2:0]  sc_reg;
logic [1:0]  sc_orientation;
logic [23:0] sc_rgb;
logic [7:0]  sc_x;
logic [7:0]  sc_y;
logic [31:0] sc_address;

assign sc_op          = wb_control.sprite_op;
assign sc_reg         = wb_control.dest_reg[4:2];
assign sc_orientation = wb_control.dest_reg[1:0];
assign sc_rgb         = wb_control.rgb;
assign sc_x           = memwb_result1[7:0];
assign sc_y           = memwb_result2[7:0];
assign sc_address     = memwb_result1;

assign sprite_command = {
	sc_op,
	sc_reg,
	sc_orientation,
	sc_rgb,
	sc_x,
	sc_y,
	sc_address
};

logic sc_produce;

assign sc_produce = wb_control.sprite_produce && ~memwb_is_no_op;

sprite_command_controller sprite_fifo(
	.clk(clk),
	.rst_n(rst_n),
	.cmd(sprite_command),
	.write_cmd(sc_produce),
	.mem_in(mem_sprite_out),
	.mem_address(mem_sprite_address),
	.fb_wfb(vga_write),
	.fb_dfb(vga_display),
	.fb_px(vga_pixnum),
	.fb_r(vga_r),
	.fb_g(vga_g),
	.fb_b(vga_b),
	.border_en(border_en)
);


// TODO TODO REMOVE ME

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		addr <= 0;
	end else if(wb_control.sprite_produce && ~memwb_is_no_op && wb_control.sprite_op == `SPRITE_LS) begin
		addr <= memwb_result1;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		sprite_op_a <= 3'b000;
		sprite_op_b <= 3'b000;
		sprite_op_c <= 3'b000;
	end else if(wb_control.sprite_produce && ~memwb_is_no_op) begin
		sprite_op_a <= wb_control.sprite_op;
		sprite_op_b <= sprite_op_a;
		sprite_op_c <= sprite_op_b;
	end
end

// TODO TODO REMOVE ME


///////////////////////////////////////////////////////////////////////////////
// Stalling, Forwarding, and Hazards
/////////////////////////////////////////////////////////////////////////////


wb_control_t check_wb_in_idex;
wb_control_t check_wb_in_exmem;

assign check_wb_in_idex = idex_wb_control;
assign check_wb_in_exmem = exmem_wb_control;


// forwarding logic

assign exmem_fw_ex = exmem_result;
assign memwb_fw_ex = memwb_result1;
assign memwb_fw_mem = memwb_result1;

assign exmem_fw_ex_enable_op1 = (check_wb_in_exmem.dest_reg == ex_control.source1) && check_wb_in_exmem.write_reg && ~exmem_is_no_op;
assign exmem_fw_ex_enable_op2 = (check_wb_in_exmem.dest_reg == ex_control.source2) && check_wb_in_exmem.write_reg && ~exmem_is_no_op;

assign memwb_fw_ex_enable_op1 = (wb_control.dest_reg == ex_control.source1) && wb_control.write_reg && ~memwb_is_no_op;
assign memwb_fw_ex_enable_op2 = (wb_control.dest_reg == ex_control.source2) && wb_control.write_reg && ~memwb_is_no_op;

assign memwb_fw_mem_enable = (wb_control.dest_reg == mem_control.source) && wb_control.write_reg && ~memwb_is_no_op;


// hazard detection

logic hazard_use_after_load;
logic hazard_branch_after_cc_update;
logic hazard_rf_read_after_load;
logic hazard_rgb_read_after_load;

// for when ex is using operand just read from data memory
assign hazard_use_after_load =
	((ex_control.source1 == check_wb_in_exmem.dest_reg) || (ex_control.source2 == check_wb_in_exmem.dest_reg)) && check_wb_in_exmem.write_reg && ~exmem_is_no_op && mem_control.use_memory_result;
// for when a branch occurs immediately after a conditional update
assign hazard_branch_after_cc_update =
	id_control.branch && ex_control.update_conditionals && ~idex_is_no_op;
// for when the register file is read after a lui or lli
assign hazard_rf_read_after_load = 
	((check_wb_in_idex.dest_reg == rf_reg1_address || check_wb_in_idex.dest_reg == rf_reg2_address) && (check_wb_in_idex.write_lower || check_wb_in_idex.write_upper)) ||
	((check_wb_in_exmem.dest_reg == rf_reg1_address || check_wb_in_exmem.dest_reg == rf_reg2_address) && (check_wb_in_exmem.write_lower || check_wb_in_exmem.write_upper));
// for when DFB is issued after a lui or lli
assign hazard_rgb_read_after_load =
	(check_wb_in_idex.dest_reg == 5'b11111 && (check_wb_in_idex.write_lower || check_wb_in_idex.write_upper) && init_wb_control.sprite_op == `SPRITE_WFB) ||
	(check_wb_in_exmem.dest_reg == 5'b11111 && (check_wb_in_exmem.write_lower || check_wb_in_exmem.write_upper) && init_wb_control.sprite_op == `SPRITE_WFB);


logic hazard;

assign hazard =
	hazard_use_after_load ||
	hazard_branch_after_cc_update ||
	hazard_rf_read_after_load ||
	hazard_rgb_read_after_load;


// stalling logic

assign exmem_stall = mem_stall_request && ~exmem_is_no_op;
assign idex_stall = (ex_stall_request || exmem_stall) && ~idex_is_no_op;
assign ifid_stall = (hazard || idex_stall) && ~ifid_is_no_op;
assign pc_stall = ifid_stall;


endmodule
