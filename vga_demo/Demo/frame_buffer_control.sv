
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

module frame_buffer_control(

	input [7:0] red,
	input [7:0] green,
	input [7:0] blue,
	input display,
	input write,
	input rst_n,
	input [15:0] pixnum,
	input clk,
	output [15:0] w1data, w2data,
	input [15:0] r1data, r2data,

	output sdram_clk,
	output wrclk, rdclk,
	output r1, r2, w1, w2,
	output wload,
	output [7:0] wlength, rlength,


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
    output      [7:0]  	VGA_B1,
    output             	VGA_BLANK_N1,
    output             	VGA_CLK1,
    output      [7:0]  	VGA_G1,
    output             	VGA_HS1,
    output      [7:0]  	VGA_R1,
    output             	VGA_SYNC_N1,
    output             	VGA_VS1
		

);


logic [15:0] w1addr, w2addr, r1addr, r2addr, w1maxaddr, w2maxaddr, r1maxaddr, r2maxaddr;



assign CLOCK_50 = clk;
assign sdram_clk = sdram_ctrl_clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire			[15:0]			Read_DATA1;
wire	       	[15:0]			Read_DATA2;


wire							DLY_RST_0;
wire							DLY_RST_1;
wire							DLY_RST_2;
wire							DLY_RST_3;
wire							DLY_RST_4;
wire							Read;

wire							sdram_ctrl_clk;
wire	       	[9:0]			oVGA_R;   				// VGA Red[9:0]
wire	       	[9:0]			oVGA_G;	 				// VGA Green[9:0]
wire	       	[9:0]			oVGA_B;   				// VGA Blue[9:0]

//power on start
wire             				auto_start;
//=======================================================
//  Structural coding
//=======================================================


assign  VGA_CTRL_CLK = VGA_CLK;

//assign	LEDR		=	Y_Cont;

//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];




//auto start when power on
assign auto_start = ((rst_n)&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
//Reset module
Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(rst_n),
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




logic [12:0] vga_x, vga_y;

logic [1:0]  state, nxt_state;

logic [9:0] count;		

assign rst = ~rst_n;


assign LEDR  = state;


assign nxt_state 	= (state == 2'h0) & write & (read_count == 16'hFFFF)? 2'h1 
						: (state == 2'h0) & display & (read_count == 16'hFFFF)? 2'h3
						: (state == 2'h1) & (write_count == 16'hFFFF)? 2'h2
						: (state == 2'h2) & (vga_x == '0) & (vga_y == '0) ? 2'h0
						: (state == 2'h3) & (write_count == 16'hFFFF)? 2'h2
						: state;


always @ (posedge CLOCK_50) begin
		
	state <= rst ? 1'b0 : nxt_state;
	
		
end		
						
						
						
//logic [15:0] write_data;			
logic [7:0] currentw1_x, currentw1_y;


assign currentw1_x = write_count[7:0];

assign currentw1_y = write_count[15:8];

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

			
			
//assign write_data = {1'h0, fb_r[currentw1_x][currentw1_y], fb_g[currentw1_x][currentw1_y], fb_b[currentw1_x][currentw1_y]};
//assign write_data = SW[9] ? (currentw1_x <= (10)) && (currentw1_y <= (10)) && (currentw1_x > 0) && (currentw1_y > 0) ? {1'b0,5'h00,5'h7F,5'h00} : {1'b0,5'h00,5'h00,5'h7F}
//						: write_data1;
			
			
			
	
logic [255:0][255:0][4:0] fb_r = '0;	
logic [255:0][255:0][4:0] fb_g = '0;
logic [255:0][255:0][4:0] fb_b = '0;


	
always@(posedge CLOCK_50) begin
	
	fb_r[pixnum[15:8]][pixnum[7:0]] <= rst ? '0 
									: write ? red 
									: fb_r;
	fb_g[pixnum[15:8]][pixnum[7:0]] <= rst ? '0 
									: write ? green
									: fb_g;
	fb_b[pixnum[15:8]][pixnum[7:0]] <= rst ? '0 
									: write ? blue
									: fb_b;

end
			



assign w1data = {1'b0,fb_r[currentw1_x][currentw1_y],fb_g[currentw1_x][currentw1_y],fb_b[currentw1_x][currentw1_y]};
assign w1 = (state == 2'h1);
assign w1addr = '0;
assign w1maxaddr = 256*256;
assign wlength = 8'h40;
assign wload = !DLY_RST_0;
assign wclk = CLOCK_50;
			

//assign w2data = ;
assign w2 = (state == 2'h1);
assign w2addr = '0;
assign w2maxaddr = 256*256;


//assign r1data = Read_DATA1;
assign r1 = (Read & (state == 2'h0)) ;
assign Read_DATA1 = r1data;				
						
//VGA DISPLAY
VGA_Controller	  	u1	(	// Host Side
							.oRequest(Read),
							.ired({Read_DATA1[14:10], 5'h0}),
							.igreen({Read_DATA1[9:5], 5'h0}),
							.iblue({Read_DATA1[4:0], 5'h0}),
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
							
						);

endmodule
