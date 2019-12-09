`define SPRITE_CMD_FIFO_SIZE	64 // keep a power of 2
`define SPRITE_BUFFERS				8
`define SPRITE_W							8
`define SPRITE_H							8

// sprite command opcodes from CPU -> sprite cmd fifo
`define SPRITE_RS							3'b001
`define SPRITE_DS							3'b010
`define SPRITE_CS							3'b011
`define SPRITE_LS							3'b100
`define SPRITE_WFB						3'b101
`define SPRITE_DFB						3'b110

// sprite orientations
`define UP										2'b00
`define RIGHT									2'b01
`define DOWN									2'b10
`define LEFT									2'b11