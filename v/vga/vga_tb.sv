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

module vga_testbench(

    ///////// ADC /////////
    inout              	ADC_CS_N,
    output             	ADC_DIN,
    input              	ADC_DOUT,
    output             	ADC_SCLK,

    ///////// AUD /////////
    input              	AUD_ADCDAT,
    inout              	AUD_ADCLRCK,
    inout              	AUD_BCLK,
    output             	AUD_DACDAT,
    inout              	AUD_DACLRCK,
    output             	AUD_XCK,

    ///////// CLOCK2 /////////
    input              	CLOCK2_50,

    ///////// CLOCK3 /////////
    input              	CLOCK3_50,

    ///////// CLOCK4 /////////
    input              	CLOCK4_50,

    ///////// CLOCK /////////
    input              	CLOCK_50,

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

    ///////// FAN /////////
    output             	FAN_CTRL,

    ///////// FPGA /////////
    output             	FPGA_I2C_SCLK,
    inout              	FPGA_I2C_SDAT,

    ///////// GPIO /////////
    inout     [35:0]   	GPIO_0,
	
    ///////// HEX0 /////////
    output      [6:0]  	HEX0,

    ///////// HEX1 /////////
    output      [6:0]  	HEX1,

    ///////// HEX2 /////////
    output      [6:0]  	HEX2,

    ///////// HEX3 /////////
    output      [6:0]  	HEX3,

    ///////// HEX4 /////////
    output      [6:0]  	HEX4,

    ///////// HEX5 /////////
    output      [6:0]  	HEX5,

`ifdef ENABLE_HPS
    ///////// HPS /////////
    input              	HPS_CONV_USB_N,
    output      [14:0] 	HPS_DDR3_ADDR,
    output      [2:0]  	HPS_DDR3_BA,
    output             	HPS_DDR3_CAS_N,
    output             	HPS_DDR3_CKE,
    output             	HPS_DDR3_CK_N,
    output             	HPS_DDR3_CK_P,
    output             	HPS_DDR3_CS_N,
    output      [3:0]  	HPS_DDR3_DM,
    inout       [31:0] 	HPS_DDR3_DQ,
    inout       [3:0]  	HPS_DDR3_DQS_N,
    inout       [3:0]  	HPS_DDR3_DQS_P,
    output             	HPS_DDR3_ODT,
    output             	HPS_DDR3_RAS_N,
    output             	HPS_DDR3_RESET_N,
    input              	HPS_DDR3_RZQ,
    output             	HPS_DDR3_WE_N,
    output             	HPS_ENET_GTX_CLK,
    inout              	HPS_ENET_INT_N,
    output             	HPS_ENET_MDC,
    inout              	HPS_ENET_MDIO,
    input              	HPS_ENET_RX_CLK,
    input       [3:0]  	HPS_ENET_RX_DATA,
    input              	HPS_ENET_RX_DV,
    output      [3:0]  	HPS_ENET_TX_DATA,
    output             	HPS_ENET_TX_EN,
    inout       [3:0]  	HPS_FLASH_DATA,
    output             	HPS_FLASH_DCLK,
    output             	HPS_FLASH_NCSO,
    inout              	HPS_GSENSOR_INT,
    inout              	HPS_I2C1_SCLK,
    inout              	HPS_I2C1_SDAT,
    inout              	HPS_I2C2_SCLK,
    inout              	HPS_I2C2_SDAT,
    inout              	HPS_I2C_CONTROL,
    inout              	HPS_KEY,
    inout              	HPS_LED,
    inout              	HPS_LTC_GPIO,
    output             	HPS_SD_CLK,
    inout              	HPS_SD_CMD,
    inout       [3:0]  	HPS_SD_DATA,
    output             	HPS_SPIM_CLK,
    input              	HPS_SPIM_MISO,
    output             	HPS_SPIM_MOSI,
    inout              	HPS_SPIM_SS,
    input              	HPS_UART_RX,
    output             	HPS_UART_TX,
    input              	HPS_USB_CLKOUT,
    inout       [7:0]  	HPS_USB_DATA,
    input              	HPS_USB_DIR,
    input              	HPS_USB_NXT,
    output             	HPS_USB_STP,
`endif /*ENABLE_HPS*/

    ///////// IRDA /////////
    input              	IRDA_RXD,
    output             	IRDA_TXD,

    ///////// KEY /////////
    input       [3:0]  	KEY,

    ///////// LEDR /////////
    output      [9:0]  	LEDR,

    ///////// PS2 /////////
    inout              	PS2_CLK,
    inout              	PS2_CLK2,
    inout              	PS2_DAT,
    inout              	PS2_DAT2,

    ///////// SW /////////
    input       [9:0]  	SW,

    ///////// TD /////////
    input              	TD_CLK27,
    input      	[7:0]  	TD_DATA,
    input              	TD_HS,
    output             	TD_RESET_N,
    input              	TD_VS,

    ///////// VGA /////////
    output      [7:0]  	VGA_B,
    output             	VGA_BLANK_N,
    output             	VGA_CLK,
    output      [7:0]  	VGA_G,
    output             	VGA_HS,
    output      [7:0]  	VGA_R,
    output             	VGA_SYNC_N,
    output             	VGA_VS,
	
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

wire							sdram_ctrl_clk;
wire	       	[9:0]			oVGA_R;   				// VGA Red[9:0]
wire	       	[9:0]			oVGA_G;	 				// VGA Green[9:0]
wire	       	[9:0]			oVGA_B;   				// VGA Blue[9:0]




//=======================================================
//  Structural coding
//=======================================================


assign  VGA_CTRL_CLK = VGA_CLK;


//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];


//Reset module
Reset_Delay			u2	(	
							.iCLK(CLOCK_50),
							.iRST(KEY[0]),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						);
	
	
	/*					
//D5M image capture
CCD_Capture			u3	(	
							.oDATA(mCCD_DATA),
							.oDVAL(mCCD_DVAL),
							.oX_Cont(X_Cont),
							.oY_Cont(Y_Cont),
							.oFrame_Cont(Frame_Cont),
							.iDATA(rCCD_DATA),
							.iFVAL(rCCD_FVAL),
							.iLVAL(rCCD_LVAL),
							.iSTART(!KEY[3]|auto_start),
							.iEND(!KEY[2]),
							.iCLK(~D5M_PIXLCLK),
							.iRST(DLY_RST_2)
						);
//D5M raw date convert to RGB data
wire [11:0] RGB_R,RGB_G,RGB_B;
wire RGB_DVAL;
RAW2RGB				u4	(	
							.iCLK(D5M_PIXLCLK),
							.iRST(DLY_RST_1),
							.iDATA(mCCD_DATA),
							.iDVAL(mCCD_DVAL),
							.oRed(RGB_R),
							.oGreen(RGB_G),
							.oBlue(RGB_B),
							.oDVAL(RGB_DVAL),
							.iX_Cont(X_Cont),
							.iY_Cont(Y_Cont)
						);

						
					);
					
*/		

			

sdram_pll 			u6	(
							.refclk(CLOCK_50),
							.rst(1'b0),
							.outclk_0(sdram_ctrl_clk),
							.outclk_1(DRAM_CLK),
							.outclk_2(D5M_XCLKIN),    //25M
							.outclk_3(VGA_CLK)        //25M
						);

		
//VGA DISPLAY
VGA_Controller	  	u1	(	// Host Side
							.oRequest(Read),
							
						
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
							.iZOOM_MODE_SW(SW[9]),
							//x and y position of current pixel
						);

endmodule
