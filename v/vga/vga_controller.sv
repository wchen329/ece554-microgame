// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
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
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	VGA_Controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN Peli Li:| 22/07/2010:| Initial Revision
// --------------------------------------------------------------------

module	VGA_Controller(	//	Host Side
						command,
						data,
						consume,
						
						//	VGA Side
						vga_r,
						vga_g,
						vga_b,			
						vga_hs,	//o_hs
						vga_vs,	//o_vs
						vga_sync_n,
						vga_blank_n, 	//o_blanking

						//	Control Signal
						iCLK,
						iRST_N,
						iZOOM_MODE_SW
							);

//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	48;
parameter	H_SYNC_ACT	=	640;	
parameter	H_SYNC_FRONT=	16;
parameter	H_SYNC_TOTAL=	800;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	10;
parameter	V_SYNC_TOTAL=	525; 


//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;


input data, command, consume;


//output	reg			oRequest;
//	VGA Side
output	reg	[9:0]	vga_r;
output	reg	[9:0]	vga_g;
output	reg	[9:0]	vga_b;
output	reg			vga_hs;
output	reg			vga_vs;
output	reg			vga_sync_n;
output	reg			vga_blank_n;


wire		[9:0]	mVGA_R;
wire		[9:0]	mVGA_G;
wire		[9:0]	mVGA_B;
reg				mVGA_H_SYNC;
reg				mVGA_V_SYNC;
wire				mVGA_SYNC;
wire				mVGA_BLANK;

//	Control Signal
input				iCLK;
input				iRST_N;
input 			iZOOM_MODE_SW;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;

wire	[12:0]		v_mask;

logic [12:0] x, y, x_index, y_index;

//create Frame buffer
logic 	[255:0][255:0][11:0]		fb_r	= '0;
logic 	[255:0][255:0][11:0]		fb_g	= '0;
logic 	[255:0][255:0][11:0]		fb_b 	= '0;


//============================================================


assign v_mask = 13'd0 ;//iZOOM_MODE_SW ? 13'd0 : 13'd26;
assign	mVGA_BLANK	=	mVGA_H_SYNC & mVGA_V_SYNC;
assign	mVGA_SYNC	=	1'b0;



//test values
assign fb_r [200][100] = 12'hFFF;
assign fb_g [200][100] = 12'hFFF;
assign fb_b [200][100] = 12'hFFF;

assign fb_g [0][200] = 12'hFFF;
assign fb_r [200][0] = 12'hFFF;
assign fb_g [200][200] = 12'hFFF;
assign fb_b [0][0] = 12'hFFF;


//=============================================================
//Choose Color for each Pixel
//=============================================================


//0,0 is top left of screen 
//positive y is in down direction
//positive x is to the right

//x and y range is relative to entire screen
//x_index and y_index is relative to 256x256 screen

//x range is 0 to H_SYNC_TOTAL-(H_SYNC_CYC+H_SYNC_BACK)
//y range is 0 to V_SYNC_TOTAL-(V_SYNC_CYC+V_SYNC_BACK)


assign x = (H_Cont > X_START) 				? H_Cont - X_START : 13'h0;
assign y = (V_Cont > (Y_START + v_mask)) 	? V_Cont - Y_START + v_mask : 13'h0;

assign x_index = x - 13'd192;
assign y_index = y - 13'd112;

//only write pixels when in 256x256 box
assign	mVGA_R	= 	((x >= 13'd192) & (x <  13'd448) & (y >= 13'd112) & (y < 13'd368)) ? fb_r[x_index][y_index] 	:	0;
assign	mVGA_G	=	((x >= 13'd192) & (x <  13'd448) & (y >= 13'd112) & (y < 13'd368)) ? fb_g[x_index][y_index] 	:	0;
assign	mVGA_B	=	((x >= 13'd192) & (x <  13'd448) & (y >= 13'd112) & (y < 13'd368)) ? fb_b[x_index][y_index] 	:	0;


//============================================================
			
always@(posedge iCLK or negedge iRST_N)
	begin
		if (!iRST_N)
			begin
				vga_r <= 0;
				vga_g <= 0;
            vga_b <= 0;
				vga_blank_n <= 0;
				vga_sync_n <= 0;
				vga_hs <= 0;
				vga_vs <= 0; 
			end
		else
			begin
				vga_r <= mVGA_R;
				vga_g <= mVGA_G;
            vga_b <= mVGA_B;
				vga_blank_n <= mVGA_BLANK;
				vga_sync_n <= mVGA_SYNC;
				vga_hs <= mVGA_H_SYNC;
				vga_vs <= mVGA_V_SYNC;				
			end               
	end



//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)begin
		//oRequest	<=	0;
	end
	else
	begin
		if(	H_Cont>=X_START-2 && H_Cont<X_START+H_SYNC_ACT-2 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT ) begin
		//oRequest	<=	1;
		end
		else begin
		//oRequest	<=	0;
		end
	end
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		mVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC )
		mVGA_H_SYNC	<=	0;
		else
		mVGA_H_SYNC	<=	1;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		mVGA_V_SYNC	<=	0;
	end
	else
	begin
		//	When H_Sync Re-start
		if(H_Cont==0)
		begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC )
			mVGA_V_SYNC	<=	0;
			else
			mVGA_V_SYNC	<=	1;
		end
	end
end

endmodule
