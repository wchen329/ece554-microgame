
module soc_audio (
	clk,
	reset,
	address,
	chipselect,
	read,
	write,
	writedata,
	readdata,
	irq,
	AUD_BCLK,
	AUD_DACDAT,
	AUD_DACLRCK);	

	input		clk;
	input		reset;
	input	[1:0]	address;
	input		chipselect;
	input		read;
	input		write;
	input	[31:0]	writedata;
	output	[31:0]	readdata;
	output		irq;
	input		AUD_BCLK;
	output		AUD_DACDAT;
	input		AUD_DACLRCK;
endmodule
