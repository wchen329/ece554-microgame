onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider something
add wave -noupdate /cpu_tb/cpu/instruction_memory/clk
add wave -noupdate /cpu_tb/cpu/instruction_memory/address_a
add wave -noupdate /cpu_tb/cpu/instruction_memory/address_b
add wave -noupdate /cpu_tb/cpu/instruction_memory/data_a
add wave -noupdate /cpu_tb/cpu/instruction_memory/data_b
add wave -noupdate /cpu_tb/cpu/instruction_memory/fd
add wave -noupdate /cpu_tb/cpu/instruction_memory/i
add wave -noupdate /cpu_tb/cpu/instruction_memory/addr
add wave -noupdate -divider instr
add wave -noupdate /cpu_tb/cpu/rst_n
add wave -noupdate /cpu_tb/clk
add wave -noupdate /cpu_tb/cpu/pc_reset
add wave -noupdate /cpu_tb/cpu/pc_stall
add wave -noupdate /cpu_tb/cpu/pc
add wave -noupdate /cpu_tb/cpu/pc_ghost
add wave -noupdate /cpu_tb/cpu/instruction
add wave -noupdate -divider {in ifid btw}
add wave -noupdate /cpu_tb/cpu/op
add wave -noupdate /cpu_tb/cpu/ifid_instruction
add wave -noupdate -divider control
add wave -noupdate /cpu_tb/cpu/id_control
add wave -noupdate /cpu_tb/cpu/ex_control
add wave -noupdate /cpu_tb/cpu/alu_op1
add wave -noupdate /cpu_tb/cpu/alu_op2
add wave -noupdate /cpu_tb/cpu/mem_control.write_memory
add wave -noupdate /cpu_tb/cpu/wb_control
add wave -noupdate -divider stalling
add wave -noupdate /cpu_tb/cpu/ifid_stall
add wave -noupdate /cpu_tb/cpu/idex_stall
add wave -noupdate /cpu_tb/cpu/exmem_stall
add wave -noupdate -divider rf
add wave -noupdate /cpu_tb/cpu/rf_reg1_address
add wave -noupdate /cpu_tb/cpu/rf_reg2_address
add wave -noupdate /cpu_tb/cpu/rf_reg1_data
add wave -noupdate /cpu_tb/cpu/rf_reg2_data
add wave -noupdate /cpu_tb/cpu/rf_write
add wave -noupdate /cpu_tb/cpu/rf_write_address
add wave -noupdate /cpu_tb/cpu/rf_write_data
add wave -noupdate /cpu_tb/cpu/rf
add wave -noupdate /cpu_tb/cpu/rf_write_lower
add wave -noupdate /cpu_tb/cpu/rf_write_upper
add wave -noupdate -divider collision
add wave -noupdate /cpu_tb/cpu/cd_a_x
add wave -noupdate /cpu_tb/cpu/cd_a_y
add wave -noupdate /cpu_tb/cpu/cd_a_width
add wave -noupdate /cpu_tb/cpu/cd_a_height
add wave -noupdate /cpu_tb/cpu/cd_b_x
add wave -noupdate /cpu_tb/cpu/cd_b_y
add wave -noupdate /cpu_tb/cpu/cd_b_width
add wave -noupdate /cpu_tb/cpu/cd_b_height
add wave -noupdate /cpu_tb/cpu/cd_collision
add wave -noupdate /cpu_tb/cpu/ex_control.select_collision
add wave -noupdate /cpu_tb/cpu/ex_stall_request
add wave -noupdate -divider forwarding
add wave -noupdate /cpu_tb/cpu/memwb_fw_ex_enable_op1
add wave -noupdate /cpu_tb/cpu/memwb_fw_ex_enable_op2
add wave -noupdate /cpu_tb/cpu/memwb_fw_ex
add wave -noupdate -divider idex
add wave -noupdate /cpu_tb/cpu/idex_op1
add wave -noupdate /cpu_tb/cpu/idex_op2
add wave -noupdate -divider alu
add wave -noupdate /cpu_tb/cpu/idex_immediate
add wave -noupdate /cpu_tb/cpu/alu/result
add wave -noupdate /cpu_tb/cpu/alu/z
add wave -noupdate /cpu_tb/cpu/alu/v
add wave -noupdate /cpu_tb/cpu/alu/n
add wave -noupdate /cpu_tb/cpu/alu/operand_a
add wave -noupdate /cpu_tb/cpu/alu/operand_b
add wave -noupdate /cpu_tb/cpu/alu/opcode
add wave -noupdate /cpu_tb/cpu/alu/addsub_result
add wave -noupdate /cpu_tb/cpu/alu/ovfl
add wave -noupdate /cpu_tb/cpu/alu/sub
add wave -noupdate /cpu_tb/cpu/execute_result
add wave -noupdate -divider hazards
add wave -noupdate /cpu_tb/cpu/hazard_use_after_load
add wave -noupdate /cpu_tb/cpu/hazard_branch_after_cc_update
add wave -noupdate /cpu_tb/cpu/hazard_rf_read_after_load
add wave -noupdate -divider noop
add wave -noupdate /cpu_tb/cpu/ifid_is_no_op
add wave -noupdate /cpu_tb/cpu/idex_is_no_op
add wave -noupdate /cpu_tb/cpu/exmem_is_no_op
add wave -noupdate /cpu_tb/cpu/memwb_is_no_op
add wave -noupdate -divider memory
add wave -noupdate -expand /cpu_tb/cpu/mem_control
add wave -noupdate /cpu_tb/cpu/mem_stall_request
add wave -noupdate /cpu_tb/cpu/user_memory_address
add wave -noupdate /cpu_tb/cpu/user_memory_data_in
add wave -noupdate /cpu_tb/cpu/user_memory_data_out
add wave -noupdate /cpu_tb/cpu/memwb_fw_mem_enable
add wave -noupdate /cpu_tb/cpu/memwb_fw_mem
add wave -noupdate -divider {data memory}
add wave -noupdate /cpu_tb/cpu/data_memory/clk
add wave -noupdate /cpu_tb/cpu/data_memory/rst_n
add wave -noupdate /cpu_tb/cpu/data_memory/address
add wave -noupdate /cpu_tb/cpu/data_memory/data_in
add wave -noupdate /cpu_tb/cpu/data_memory/read
add wave -noupdate /cpu_tb/cpu/data_memory/write
add wave -noupdate /cpu_tb/cpu/data_memory/data_out
add wave -noupdate /cpu_tb/cpu/data_memory/stall
add wave -noupdate -divider Sprites
add wave -noupdate /cpu_tb/cpu/instruction_memory/clk
add wave -noupdate /cpu_tb/cpu/sc_produce
add wave -noupdate /cpu_tb/cpu/sc_op
add wave -noupdate /cpu_tb/cpu/sc_reg
add wave -noupdate /cpu_tb/cpu/sc_orientation
add wave -noupdate /cpu_tb/cpu/sc_rgb
add wave -noupdate /cpu_tb/cpu/sc_x
add wave -noupdate /cpu_tb/cpu/sc_y
add wave -noupdate /cpu_tb/cpu/sc_address
add wave -noupdate -divider my_sprites
add wave -noupdate /cpu_tb/cpu/sprite_fifo/clk
add wave -noupdate /cpu_tb/cpu/sprite_fifo/rst_n
add wave -noupdate /cpu_tb/cpu/sprite_fifo/command
add wave -noupdate /cpu_tb/cpu/sprite_fifo/produce
add wave -noupdate /cpu_tb/cpu/sprite_fifo/sprite_mem_out
add wave -noupdate /cpu_tb/cpu/sprite_fifo/sprite_mem_address
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_write
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_display
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_x
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_y
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_r
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_g
add wave -noupdate /cpu_tb/cpu/sprite_fifo/vga_b
add wave -noupdate /cpu_tb/cpu/sprite_fifo/consume
add wave -noupdate /cpu_tb/cpu/sprite_fifo/next_command
add wave -noupdate /cpu_tb/cpu/sprite_fifo/fifo_empty
add wave -noupdate /cpu_tb/cpu/sprite_fifo/curr_command_raw
add wave -noupdate /cpu_tb/cpu/sprite_fifo/curr_command
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_select
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_x
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_y
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_rgb_in
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_orientation_in
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_write
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_rgb_out_raw
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_rgb_out
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_orientation_out_raw
add wave -noupdate /cpu_tb/cpu/sprite_fifo/reg_orientation_out
add wave -noupdate /cpu_tb/cpu/sprite_fifo/curr_state
add wave -noupdate /cpu_tb/cpu/sprite_fifo/next_state
add wave -noupdate /cpu_tb/cpu/sprite_fifo/address_offset
add wave -noupdate /cpu_tb/cpu/sprite_fifo/next_address_offset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1360 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 189
configure wave -valuecolwidth 91
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {734 ns} {1866 ns}
