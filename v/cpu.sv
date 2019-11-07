module cpu
#(
	parameter INSTRUCTION_ADDRESS_WIDTH=16,
	parameter USER_ADDRESS_WIDTH=16,
	parameter NUM_INPUT_BITS=5
)(
	input clk, rst_n
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

logic id_stall_request;
logic ex_stall_request;
logic mem_stall_request;


///////////////////////////////////////////////////////////////////////////////
// Instruction Fetch
/////////////////////////////////////////////////////////////////////////////


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

logic branch;
logic link_return;
logic [INSTRUCTION_ADDRESS_WIDTH-1:0] branch_address;
reg [INSTRUCTION_ADDRESS_WIDTH-1:0] pc;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pc <= 0;
	end else if(branch) begin
		pc <= branch_address;
	end else if(link_return) begin
		pc <= link_reg;
	end else begin
		// instruction memory is word-addressable
		pc <= pc + 1;
	end
end


// instruction memory

logic [31:0] instruction

memory instruction_memory(
	.clk(clk),
	.rst_n(rst_n),
	.address(pc),
	.data(instruction)
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
		ifid_pc <= 1;
	end else if(ifid_flush) begin
		ifid_instruction <= 0;
		ifid_pc <= 0;
		ifid_is_no_op <= 1;
	end else if(~ifid_stall) begin
		ifid_instruction <= instruction;
		ifid_pc <= pc;
		ifid_is_no_op <= 0;
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

reg [32][31:0] rf;

integer itter_rf_i;
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for(itter_rf_i=0; itter_rf_i<32; itter_rf_i=itter_rf_i+1) begin
			rf[itter_rf_i] <= 0;
		end
	end else if(rf_write) begin
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

assign rf_reg1_data = rf[rf_reg1_address];
assign rf_reg2_data = rf[rf_reg2_address];
// register 32 is RGB register, otherwise general-purpose
assign rf_rgb = rf[31];


// control signals for all stages here and beyond

typedef struct packed {
	logic branch,
	logic link,
	logic link_return,
	logic use_dest_as_op2
} id_control_t;

id_control_t id_control;

typedef struct packed {
	logic select_random,
	logic select_time,
	logic select_input,
	logic select_collision,
	logic select_immediate,
	logic zero_as_op2,
	logic [3:0] alu_op,
	logic alu_use_immediate,
	logic update_conditionals,
	logic seed_random
} ex_control_t;

ex_control_t init_ex_control;

typedef struct packed {
	logic write_memory,
	logic use_memory_result
} mem_control_t;

mem_control_t init_mem_control;

typedef struct packed {
	logic [4:0] dest_reg,
	logic write_reg,
	logic write_lower,
	logic write_upper,
	logic [2:0] sprite_op,
	logic sprite_produce,
	logic [23:0] rgb
} wb_control_t;

wb_control_t init_wb_control;


always_comb begin
	id_control <= 0;
	init_ex_control <= 0;
	init_mem_control <= 0;
	init_wb_control <= 0;

	// switch on opcode
	case(if_id_encoded_instruction[31:27])
		5'b00000:begin
			// add
			init_ex_control.alu_op = 4'b0000;
			init_ex_control.update_conditionals = 1;

			init_wb_control.write_reg = 1;
		end
		5'b00001:begin
			// addi
			init_ex_control.alu_op = 4'b0001;
			init_ex_control.update_conditionals = 1;
			init_ex_control.alu_use_immediate = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00010:begin
			// sub
			init_ex_control.alu_op = 4'b0010;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00011:begin
			// and
			init_ex_control.alu_op = 4'b0011;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00100:begin
			// andi
			init_ex_control.alu_op = 4'b0100;
			init_ex_control.update_conditionals = 1;
			init_ex_control.alu_use_immediate = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00101:begin
			// or
			init_ex_control.alu_op = 4'b0101;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00110:begin
			// ori
			init_ex_control.alu_op = 4'b0110;
			init_ex_control.update_conditionals = 1;
			init_ex_control.alu_use_immediate = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b00111:begin
			// xor
			init_ex_control.alu_op = 4'b0111;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01000:begin
			// sll
			init_ex_control.alu_op = 4'b1000;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01001:begin
			// srl
			init_ex_control.alu_op = 4'b1001;
			init_ex_control.update_conditionals = 1;
			
			init_wb_control.write_reg = 1;
		end
		5'b01010:begin
			// sra
			init_ex_control.alu_op = 4'b1010;
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

			init_wb_control.write_reg = 1;
		end
		5'b01110:begin
			// sw
			id_control.use_dest_as_op2 = 1;

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

			init_wb_control.sprite_op = 3'b000;
			init_wb_control.sprite_produce = 1;
		end
		5'b10110:begin
			// dfb
			init_wb_control.sprite_op = 3'b001;
			init_wb_control.sprite_produce = 1;
		end
		5'b10111:begin
			// ls
			init_ex_control.select_immediate = 1;

			init_wb_control.sprite_op = 3'b010;
			init_wb_control.sprite_produce = 1;
		end
		5'b11000:begin
			// ds
			init_ex_control.zero_as_op2 = 1;

			init_wb_control.sprite_op = 3'b011;
			init_wb_control.sprite_produce = 1;
		end
		5'b11001:begin
			// cs
			init_ex_control.zero_as_op2 = 1;

			init_wb_control.sprite_op = 3'b100;
			init_wb_control.sprite_produce = 1;
		end
		5'b11010:begin
			// rs
			init_wb_control.sprite_op = 3'b101;
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

			init_ex_control.seed_random = 1;
		end
	endcase
end


// branch logic

logic [2:0] branch_case;

assign branch_case = if_id_encoded_instruction[26:24];

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


// operand locations

logic [31:0] op1, op2;

assign op1 = ifid_instruction[21:17];
assign op2 = id_control.use_dest_as_op2 ? ifid_instruction[26:22] : ifid_instruction[16:12];


// immediate

logic [31:0] immediate;

assign immediate = {16{ifid_instruction[15]}, ifid_instruction[15:0]};


// decode destination register from instruction
// furthermore, recall that dest = { sprite_reg, sprite_orientation }

assign init_wb_control.dest_reg = ifid_instruction[26:22];


// special rgb propagation

assign init_wb_control.rgb = rf_rgb[23:0];


// branching control

assign link           = id_control.link && should_branch && ~ifid_stall;
assign link_address   = ifid_pc + 1;
assign branch         = id_control.branch && should_branch && ~ifid_stall;
assign branch_address = ifid_pc + 1 + immediate;
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
reg [$bits(wb_control_t)-1:0] ides_wb_control;

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
		idex_op1 <= op1;
		idex_op2 <= op2;
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
	.alu_op(ctrl_ex_alu_op_code),
	.operand_a(alu_op1),
	.operand_b(alu_op2),
	.result(alu_result),
	.zero(alu_zero),
	.sign(alu_sign),
	.overflow(alu_overflow)
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

collision_detectection cd(
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

input_buffer user_input_buffer(
	.clk(clk),
	.rst_n(rst_n),
	.clear(ctrl_ex_select_input),
	.up(user_input[4]),
	.right(user_input[3]),
	.down(user_input[2]),
	.left(user_input[1]),
	.space(user_inpu[0])
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

random randy(
	.clk(clk),
	.rst_n(rst_n),
	.set_seed(ex_control.set_seed),
	// alu op for forwarding
	.seed(alu_op2),
	.random(random)
);


// system time

logic [31:0] time_ms;

system_time timer(
	.clk(clk),
	.rst_n(rst_n),
	.ms(time_ms)
);


// control

logic [31:0] execute_result;

assign execute_result =
	ex_control.select_random ? random :
	ex_control.select_time ? time_ms :
	ex_control.select_input ? {(32-NUM_INPUT_BITS){0}, user_input} :
	ex_control.select_immediate ? idex_immediate :
	alu_result;

assign ex_stall_request = ~collision_state && ex_control.select_collision;

assign cc_update = ex_control.update_conditionals && (ex_control.select_collision ^~ collision_state) && ~idex_stall && ~idex_is_no_op;

assign cc_next_zero = ctrl_ex_enable_collision ? cd_collision : alu_zero;
assign cc_next_sign = ctrl_ex_enable_collision ? 0 : alu_sign;
assign cc_next_overflow = ctrl_ex_enable_collision ? 0 : alu_overflow;


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

assign user_memory_address = exmem_result[$min(USER_ADDRESS_WIDTH, 32)-1:0];

assign user_memory_data_in =
	memwb_fw_mem_enable ? memwb_fw_mem :
	exmem_store_data;

memory data_memory(
	.clk(clk),
	.rst_n(rst_n),
	.address(ex_mem_result),
	.data_in(user_memory_data_in),
	.write(ctrl_mem_write_memory),
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

assign sprite_command = {
	wb_control.sprite_command,
	wb_control.sprite_reg,
	wb_control.sprite_orientation,
	wb_control.rgb,
	memwb_result1[7:0],
	memwb_result2[7:0],
	memwb_result1
};

sprite_command_fifo_front_end sprite_fifo(
	.clk(clk),
	.rst_n(rst_n),
	.cmd(sprite_command),
	.write(wb_control.sprite_produce && ~memwb_is_no_op)
);


///////////////////////////////////////////////////////////////////////////////


// forwarding logic

assign exmem_fw_ex = exmem_result;
assign memwb_fw_ex = memwb_result1;
assign memwb_fw_mem = memwb_result1;


// stalling logic

assign exmem_stall = mem_stall_request;
assign idex_stall = ex_stall_request || (mem_stall_request && ~idex_is_no_op);
assign ifid_stall = id_stall_request || (ex_stall_request && ~ifid_is_no_op);


endmodule
