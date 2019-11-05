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
logic ex_mem_fw_ex_enable_op_1;
logic ex_mem_fw_ex_enable_op_2;
logic [31:0] ex_mem_fw_ex;

// MEM to EX forwarding
logic mem_wb_fw_ex_enable_op_1;
logic mem_wb_fw_ex_enable_op_2;
logic [31:0] mem_wb_fw_ex;

// MEM to MEM forwarding
logic mem_wb_fw_mem_enable;
logic [31:0] mem_wb_fw_mem;

// stall request declarations
logic id_stall_request;
logic ex_stall_request;
logic mem_stall_request;

///////////////////////////////////////////////////////////////////////////////
// Instruction Fetch
/////////////////////////////////////////////////////////////////////////////

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
		pc <= linking_register;
	end else begin
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


// linking register

logic link;
logic [INSTRUCTION_ADDRESS_WIDTH-1:0] link_address;
reg [INSTRUCTION_ADDRESS_WIDTH-1:0] linking_register;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		linking_register <= 0;
	end else if(link) begin
		linking_register <= next_link;
	end
end

///////////////////////////////////////////////////////////////////////////////

// IF/ID register

logic if_id_flush;
logic if_id_stall;
reg [31:0] if_id_encoded_instruction;
reg [INSTRUCTION_ADDRESS_WIDTH-1:0] if_id_pc;
reg if_id_is_no_op;

always_ff @(posedge clk or negedge rst_n) begin : if_id_reg
	if(~rst_n) begin
		if_id_encoded_instruction <= 0;
		if_id_pc <= 0;
		if_id_is_no_op <= 1;
	end else if(if_id_flush) begin
		if_id_encoded_instruction <= 0;
		if_id_pc <= 0;
		if_id_is_no_op <= 1;
	end else if(~if_id_stall) begin
		if_id_encoded_instruction <= instruction;
		if_id_pc <= pc;
		if_id_is_no_op <= 0;
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

logic [4:0] rf_read_reg_1, rf_read_reg_2;
logic [31:0] rf_reg_1, rf_reg_2;
logic rf_write;
logic [4:0] rf_write_reg;
logic [31:0] rf_write_reg_data;

reg [32][31:0] rf;

integer itter_rf_i;
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		for(itter_rf_i=0; itter_rf_i<$size(rf); itter_rf_i=itter_rf_i+1) begin
			rf[itter_rf_i] <= 0;
		end
	end else if(rf_write) begin
		if(rf_write_reg != 5'b00000) begin
			// zero register is tied to zero
			rf[rf_write_reg] <= rf_write_reg_data;
		end
	end
end

assign rf_reg_1 = rf[rf_read_reg_1];
assign rf_reg_2 = rf[rf_read_reg_2];


// sign extension for immediate

logic [15:0] immediate;
logic [31:0] extended_immediate;

assign immediate = if_id_encoded_instruction[15:0];
assign extended_immediate = {16{immediate[15]}, immediate};


// control

logic id_branch;
logic id_link;
logic id_return;
logic id_use_destination_as_op_2;

logic ex_select_random;
logic ex_select_time;
logic ex_select_input;
logic [3:0] ex_alu_op_code;
logic ex_alu_use_immediate;
logic ex_update_cc;
logic ex_enable_collision;

logic mem_write_memory;

always_comb begin
	id_branch = 0;
	id_link = 0;

	ex_select_random = 0;
	ex_select_time = 0;
	ex_select_input = 0;
	ex_alu_op_code = 4'b0000;
	ex_alu_use_immediate = 0;
	ex_update_cc = 0;
	ex_enable_collision = 0;

	mem_write_memory = 0;

	// switch on opcode
	case(if_id_encoded_instruction[31:27])
		5'b00000:begin
			// add
			ex_alu_op_code = 4'b0000;
			ex_update_cc = 1;
		end
		5'b00001:begin
			// addi
			ex_alu_op_code = 4'b0001;
			ex_alu_use_immediate = 1;
			ex_update_cc = 1;
		end
		5'b00010:begin
			// sub
			ex_alu_op_code = 4'b0010;
			ex_update_cc = 1;
		end
		5'b00011:begin
			// and
			ex_alu_op_code = 4'b0011;
			ex_update_cc = 1;
		end
		5'b00100:begin
			// andi
			ex_alu_op_code = 4'b0100;
			ex_alu_use_immediate = 1;
			ex_update_cc = 1;
		end
		5'b00101:begin
			// or
			ex_alu_op_code = 4'b0101;
			ex_update_cc = 1;
		end
		5'b00110:begin
			// ori
			ex_alu_op_code = 4'b0110;
			ex_alu_use_immediate = 1;
			ex_update_cc = 1;
		end
		5'b00111:begin
			// xor
			ex_alu_op_code = 4'b0111;
			ex_update_cc = 1;
		end
		5'b01000:begin
			// sll
			ex_alu_op_code = 4'b1000;
			ex_update_cc = 1;
		end
		5'b01001:begin
			// srl
			ex_alu_op_code = 4'b1001;
			ex_update_cc = 1;
		end
		5'b01010:begin
			// sra
			ex_alu_op_code = 4'b1010;
			ex_update_cc = 1;
		end
		5'b01011:begin
			// lli
		end
		5'b01100:begin
			// lui
		end
		5'b01101:begin
			// lw
		end
		5'b01110:begin
			// sw
			id_use_destination_as_op_2 = 1;
			mem_write_memory = 1;
		end
		5'b01111:begin
			// lwo
			ex_alu_use_immediate = 1;
		end
		5'b10000:begin
			// swo
			ex_alu_use_immediate = 1;
			id_use_destination_as_op_2 = 1;
			mem_write_memory = 1;
		end
		5'b10001:begin
			// b
			id_branch = 1;
		end
		5'b10010:begin
			// bl
			id_branch = 1;
			id_link = 1;
		end
		5'b10011:begin
			// ret
			id_return = 1;
		end
		5'b10100:begin
			// lk
			ex_select_input = 1;
		end
		5'b10101:begin
			// wfb
		end
		5'b10110:begin
			// dfb
		end
		5'b10111:begin
			// ls
		end
		5'b11000:begin
			// ds
		end
		5'b11001:begin
			// cs
		end
		5'b11010:begin
			// rs
		end
		5'b11011:begin
			// sat
		end
		5'b11100:begin
			// dc
			ex_update_cc = 1;
			ex_enable_collision = 1;
		end
		5'b11101:begin
			// tim
			ex_select_time = 1;
		end
		5'b11110:begin
			// r
			ex_select_random = 1;
		end
		5'b11111:begin
			// sr
		end
	endcase
end


// branch checking logic

logic [2:0] branch_case;
logic should_branch;

assign branch_case = if_id_encoded_instruction[26:24];

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

// conditional dependencies are hazard detected and stalled
assign link = id_link && should_branch;
assign link_address = if_id_pc + 1;
assign branch = id_branch && should_branch;
assign branch_address = if_id_pc + 1 + extended_immediate;
assign link_return = id_return;

assign if_id_flush = branch || link_return;


// operand locations

assign rf_read_reg_1 =
	if_id_encoded_instruction[21:17];
assign rf_read_reg_2 =
	id_use_destination_as_op_2 ? if_id_encoded_instruction[26:22] :
	if_id_encoded_instruction[16:12];

///////////////////////////////////////////////////////////////////////////////

// ID/EX register

logic id_ex_stall;
reg [31:0] id_ex_reg_1, id_ex_reg_2;
reg [31:0] id_ex_immediate;
reg id_ex_is_no_op;

reg ctrl_ex_select_random;
reg ctrl_ex_select_time;
reg ctrl_ex_select_input;
reg [3:0] ctrl_ex_alu_op_code;
reg ctrl_ex_alu_use_immediate;
reg ctrl_ex_update_cc;
reg ctrl_ex_enable_collision;

reg ctrl_mem_ex_write_memory;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		id_ex_reg_1 <= 0;
		id_ex_reg_2 <= 0;
		id_ex_immediate <= 0;
		id_ex_is_no_op <= 1;

		ctrl_ex_select_random <= 0;
		ctrl_ex_select_time <= 0;
		ctrl_ex_select_input <= 0;
		ctrl_ex_alu_op_code <= 0;
		ctrl_ex_alu_use_immediate <= 0;
		ctrl_ex_update_cc <= 0;
		ctrl_ex_enable_collision <= 0;

		ctrl_mem_ex_write_memory <= 0;
	end else if(~id_ex_stall) begin
		id_ex_reg_1 <= rf_reg_1;
		id_ex_reg_2 <= rf_reg_2;
		id_ex_immediate <= extended_immediate;
		id_ex_is_no_op <= if_id_is_no_op;

		ctrl_ex_select_random <= ex_select_random;
		ctrl_ex_select_time <= ex_select_time;
		ctrl_ex_select_input <= ex_select_input;
		ctrl_ex_alu_op_code <= ex_alu_op_code;
		ctrl_ex_alu_use_immediate <= ex_alu_use_immediate;
		ctrl_ex_update_cc <= ex_update_cc;
		ctrl_ex_enable_collision <= ex_enable_collision;

		ctrl_mem_ex_write_memory <= mem_write_memory;
	end
end

///////////////////////////////////////////////////////////////////////////////
// Execute
/////////////////////////////////////////////////////////////////////////////

// ALU

logic [31:0] alu_operand_1, alu_operand_2;
logic [31:0] alu_result;
logic alu_zero, alu_sign, alu_overflow;

alu alu(
	.alu_op(ctrl_ex_alu_op_code),
	.operand_a(alu_operand_1),
	.operand_b(alu_operand_2),
	.result(alu_result),
	.zero(alu_zero),
	.sign(alu_sign),
	.overflow(alu_overflow)
);


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

assign cd_a_x = alu_operand_1[31:24];
assign cd_a_y = alu_operand_1[23:16];
assign cd_a_width = alu_operand_1[15:8];
assign cd_a_height = alu_operand_1[7:0];
assign cd_b_x = alu_operand_2[31:24];
assign cd_b_y = alu_operand_2[23:16];
assign cd_b_width = alu_operand_2[15:8];
assign cd_b_height = alu_operand_2[7:0];

reg collision_state;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		collision_state <= 0;
	end else if(ctrl_ex_enable_collision) begin
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
	.set_tone(set_tone),
	.tone(tone)
);


// random number generator

logic set_seed;
logic [31:0] seed;
logic [31:0] random;

random randy(
	.clk(clk),
	.rst_n(rst_n),
	.set_seed(set_seed),
	.seed(seed),
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

logic [31:0] ex_result;

assign ex_result =
	ctrl_ex_select_random ? random :
	ctrl_ex_select_input ? time_ms :
	ctrl_ex_select_input ? {(32-NUM_INPUT_BITS){0}, user_input} :
	alu_result;

assign alu_operand_1 =
	ex_mem_fw_ex_enable_op_1 ? ex_mem_fw_ex :
	mem_wb_fw_ex_enable_op_1 ? mem_wb_fw_ex :
	id_ex_reg_1;

assign alu_operand_2 =
	ctrl_ex_alu_use_immediate ? id_ex_immediate :
	ex_mem_fw_ex_enable_op_2 ? ex_mem_fw_ex :
	mem_wb_fw_ex_enable_op_2 ? mem_wb_fw_ex :
	id_ex_reg_2;

assign ex_stall_request = collision_state;

assign cc_update =
	ctrl_ex_update_cc && (ctrl_ex_enable_collision ^~ collision_state) && ~id_ex_stall && ~id_ex_is_no_op;

assign cc_next_zero = ctrl_ex_enable_collision ? cd_collision : alu_zero;
assign cc_next_sign = ctrl_ex_enable_collision ? 0 : alu_sign;
assign cc_next_overflow = ctrl_ex_enable_collision ? 0 : alu_overflow;

///////////////////////////////////////////////////////////////////////////////

// EX/MEM register

logic ex_mem_stall;
reg [31:0] ex_mem_result;
reg [31:0] ex_mem_store_source;
reg ex_mem_is_no_op;

reg ctrl_mem_write_memory;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		ex_mem_result <= 0;
		ex_mem_store_source <= 0;
		ex_mem_is_no_op <= 1;

		ctrl_mem_write_memory <= 0;
	end else if(~ex_mem_stall) begin
		ex_mem_result <= ex_result;
		ex_mem_store_source <= id_ex_reg_2;
		ex_mem_is_no_op <= id_ex_is_no_op;

		ctrl_mem_write_memory <= ctrl_mem_ex_write_memory;
	end
end

///////////////////////////////////////////////////////////////////////////////
// Memory
/////////////////////////////////////////////////////////////////////////////

// data memory

logic [USER_ADDRESS_WIDTH-1:0] user_memory_address;
logic [31:0] user_memory_data;

assign user_memory_address = ex_mem_result[USER_ADDRESS_WIDTH-1:0];

memory data_memory(
	.clk(clk),
	.rst_n(rst_n),
	.address(ex_mem_result),
	.data_in(ex_mem_store_source),
	.write(ctrl_mem_write_memory),
	.data_out(user_memory_data),
	.stall(mem_stall_request)
);


///////////////////////////////////////////////////////////////////////////////

// MEM/WB register

reg mem_wb_is_no_op;

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		mem_wb_is_no_op <= 1;
	end else begin
		mem_wb_is_no_op <= ex_mem_is_no_op;
	end
end

///////////////////////////////////////////////////////////////////////////////
// Write Back
/////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////

// forwarding logic

assign ex_mem_fw_ex = ex_mem_result;
assign mem_wb_fw_ex = 
assign mem_wb_fw_mem = 


// stalling logic

assign ex_mem_stall = mem_stall_request;
assign id_ex_stall = ex_stall_request || (mem_stall_request && ~id_ex_is_no_op);
assign if_id_stall = id_stall_request || (ex_stall_request && ~if_id_is_no_op);


endmodule
