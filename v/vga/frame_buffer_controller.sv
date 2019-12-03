
// ============================================================================
// Copyright (c) 2013 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Jul 11 11:26:45 2013
// ============================================================================

//`define ENABLE_HPS
//`define ENABLE_USB

module frame_buffer_controller(

    ///////// CLOCK /////////
    input              	CLOCK_50, rst,

    ///////// DRAM /////////
    output      [12:0] 	DRAM_ADDR,
    output      [1:0]  	DRAM_BA,
    output             	DRAM_CAS_N,
    output             	DRAM_CKE,
    output             	DRAM_CLK,
    output             	DRAM_CS_N,
    inout       [15:0] 	DRAM_DQ,
    output             	DRAM_LDQM,
    output             	DRAM_RAS_N,
    output             	DRAM_UDQM,
    output             	DRAM_WE_N,

    ///////// VGA /////////
    output      [7:0]  	VGA_B,
    output             	VGA_BLANK_N,
    output             	VGA_CLK,
    output      [7:0]  	VGA_G,
    output             	VGA_HS,
    output      [7:0]  	VGA_R,
    output             	VGA_SYNC_N,
    output             	VGA_VS,
	 
	 input [15:0] pixnum,
	 input display_screen,
	 input write_buffer,
	 input [7:0] red, green, blue
);


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire			[15:0]			Read_DATA1;
wire	       	[15:0]			Read_DATA2;

wire			[11:0]			mCCD_DATA;
wire							mCCD_DVAL;
wire							mCCD_DVAL_d;
wire	       	[15:0]			X_Cont;
wire	       	[15:0]			Y_Cont;
wire	       	[9:0]			X_ADDR;
wire	       	[31:0]			Frame_Cont;
wire							DLY_RST_0;
wire							DLY_RST_1;
wire							DLY_RST_2;
wire							DLY_RST_3;
wire							DLY_RST_4;
wire							Read;
reg		    	[11:0]			rCCD_DATA;
reg								rCCD_LVAL;
reg								rCCD_FVAL;
wire	       	[11:0]			sCCD_R;
wire	       	[11:0]			sCCD_G;
wire	       	[11:0]			sCCD_B;
wire							sCCD_DVAL;

wire							sdram_ctrl_clk;
wire	       	[9:0]			oVGA_R;   				// VGA Red[9:0]
wire	       	[9:0]			oVGA_G;	 				// VGA Green[9:0]
wire	       	[9:0]			oVGA_B;   				// VGA Blue[9:0]

//power on start
wire             				auto_start;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;

assign  VGA_CTRL_CLK = VGA_CLK;

//assign	LEDR		=	Y_Cont;

//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];


//auto start when power on
assign auto_start = ((~rst)&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
//Reset module
Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(~rst),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						);



												
sdram_pll 			u6	(
							.refclk(CLOCK_50),
							.rst(1'b0),
							.outclk_0(sdram_ctrl_clk),
							.outclk_1(DRAM_CLK),
							.outclk_2(D5M_XCLKIN),    //25M
							.outclk_3(VGA_CLK)        //25M
						);

	
//logic [256:0][256:0][4:0] fb_r, fb_g, fb_b;




logic [12:0] vga_x, vga_y;

logic [1:0]  state, nxt_state;
logic write, synced;
logic [9:0] count;


assign LEDR  = state;


//assign synced = (vga_x == 12'd0) && (vga_y == 12'd0) && (read_count == '0);	



assign nxt_state 	= (state == 2'h0) & display_screen & (read_count == 16'hFFFF)? 2'h1 
						: (state == 2'h0) & write_buffer & (read_count == 16'hFFFF)? 2'h3
						: (state == 2'h1) & (write_count == 16'hFFFF)? 2'h2
						: (state == 2'h2) & (vga_x == '0) & (vga_y == '0) ? 2'h0
						: (state == 2'h3) & (write_count == 16'hFFFF)? 2'h2
						: state;



always @ (posedge CLOCK_50) begin
		
	state <= rst ? 1'b0 : nxt_state;
	//count <= (state == 2'h1) ? count + 10'h1 : 10'h0;
		
end		
						
						
						
logic [15:0] write_data, currentw1_addr, currentr1_addr;			
logic [7:0] currentw1_x, currentw1_y;


assign currentw1_x = write_count[7:0];

assign currentw1_y = write_count[15:8];



	

logic dval, dval_nxt;
logic [15:0] write_count, read_count;
	
	
	//count writes
always @(posedge CLOCK_50) begin
	write_count <= (nxt_state != state) & (nxt_state == 2'h1)  ? 16'h0
					: (nxt_state != state) & (nxt_state != 2'h1)? 16'h0
					: (write_count >= 16'hFFFF) ? 16'h0
					: write_count + 16'h1;
end
	
	
	//count reads
always @(posedge VGA_CTRL_CLK) begin
	read_count <= (nxt_state != state) 	? '0
					: (read_count >= (256*256)) | ((vga_x == '0) & (vga_y == '0))? '0	
					: Read ? read_count + 16'h1
					: read_count;
end


logic [15:0] data_to_write, pixel_number;


assign data_to_write = {1'b0, 5'hFF, 5'hFF, 5'h00};
assign pixel_number = 16'd540;
			
			
wire [7:0] red_from_bram, green_from_bram, blue_from_bram;
wire [7:0] red_from_sram, green_from_sram, blue_from_sram, dont_care;
			
			
frame_buffer_bram bram_red(
	.clock(CLOCK_50),
	.data(red),
	.rdaddress({currentw1_y, currentw1_x}),
	.wraddress({pixnum[15:8], pixnum[7:0]}),
	.wren(write_buffer),
	.q(red_from_bram)
);

frame_buffer_bram bram_green(
	.clock(CLOCK_50),
	.data(green),
	.rdaddress({currentw1_y, currentw1_x}),
	.wraddress({pixnum[15:8], pixnum[7:0]}),
	.wren(write_buffer),
	.q(green_from_bram)
);

frame_buffer_bram bram_blue(
	.clock(CLOCK_50),
	.data(blue),
	.rdaddress({currentw1_y, currentw1_x}),
	.wraddress({pixnum[15:8], pixnum[7:0]}),
	.wren(write_buffer),
	.q(blue_from_bram)
);
			
			
//assign write_data = {1'h0, fb_r[currentw1_x][currentw1_y], fb_g[currentw1_x][currentw1_y], fb_b[currentw1_x][currentw1_y]};		
	
//logic [255:0][255:0][1:0] fb_r = '0;
//logic [255:0][255:0][1:0] fb_g = '0;
//logic [255:0][255:0][1:0] fb_b = '0;

	
//always@(posedge CLOCK_50) begin
//	
//	fb_r[pixnum[15:8]][pixnum[7:0]] <= rst ? '0 
//												:write_buffer ? red : fb_r;
//	fb_g[pixnum[15:8]][pixnum[7:0]] <= rst ? '0
//												:write_buffer ? green : fb_g;
//	fb_b[pixnum[15:8]][pixnum[7:0]] <= rst ? '0 
//												:write_buffer ? blue : fb_b;
//
//end
			
			
			
//must initialize all data first
			
			
//SDRam Read and Write as Frame Buffer
Sdram_Control	   u7	(	// HOST Side						
							.RESET_N(~rst),
							.CLK(sdram_ctrl_clk),
							.currentw1_addr(currentw1_addr),
							.currentr1_addr(currentr1_addr),
							
							//used for copy
							// FIFO Write Side 1
							.WR1_DATA({red_from_bram, green_from_bram}),
							//.WR1_DATA({1'b0,RGB_R[11:7],RGB_G[11:7],RGB_B[11:7]}),
							//.WR1(RGB_DVAL),
							.WR1( (state == 2'h1) ),
							.WR1_ADDR(0),
							.WR1_MAX_ADDR(256*256),
							.WR1_LENGTH(8'h40),
							.WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(CLOCK_50),

							//used for write
							// FIFO Write Side 2
							.WR2_DATA({8'b0, blue_from_bram}),
							//.WR1_DATA({1'b0,RGB_R[11:7],RGB_G[11:7],RGB_B[11:7]}),
							//.WR1(RGB_DVAL),
							.WR2( (state == 2'h1) ),
							.WR2_ADDR(256*256),
							.WR2_MAX_ADDR(256*256*2),
							.WR2_LENGTH(8'h40),
							.WR2_LOAD(!DLY_RST_0),
							.WR2_CLK(CLOCK_50),

							// FIFO Read Side 1
							.RD1_DATA({red_from_sram, green_from_sram}),
				        	.RD1( Read && (state == 2'h0) ),
				        	.RD1_ADDR(0),
							.RD1_MAX_ADDR(256*256),
							.RD1_LENGTH(8'h40),
							.RD1_LOAD(!DLY_RST_0),
							.RD1_CLK(~VGA_CTRL_CLK),
							
							// FIFO Read Side 2
							.RD2_DATA({dont_care, blue_from_sram}),
							.RD2((state == 2'h0) && Read),
							.RD2_ADDR(256*256),
							.RD2_MAX_ADDR(256*256*2),
							.RD2_LENGTH(8'h40),
							.RD2_LOAD(!DLY_RST_0),
							.RD2_CLK(~CLOCK_50),
							
							// SDRAM Side
							.SA(DRAM_ADDR),
							.BA(DRAM_BA),
							.CS_N(DRAM_CS_N),
							.CKE(DRAM_CKE),
							.RAS_N(DRAM_RAS_N),
							.CAS_N(DRAM_CAS_N),
							.WE_N(DRAM_WE_N),
							.DQ(DRAM_DQ),
							.DQM({DRAM_UDQM,DRAM_LDQM})
						);
						
						
			//how to reset without taking forever
			//wait until vga is at 0,0 
						
						
//VGA DISPLAY
VGA_Controller	  	u1	(	// Host Side
							.oRequest(Read),
							.ired({red_from_sram, 2'b0}),
							.igreen({green_from_sram, 2'b0}),
							.iblue({blue_from_sram, 2'b0}),
							.vga_x(vga_x),
							.vga_y(vga_y),
						
							// VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC_N),
							.oVGA_BLANK(VGA_BLANK_N),
							// Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST_2),
							.iZOOM_MODE_SW(1'b0)
						);

endmodule
