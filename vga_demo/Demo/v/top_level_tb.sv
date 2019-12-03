module top_level_tb();

logic [11:0] ired, iblue, igreen, ored, oblue, ogreen;
logic idata_val, odata_val, clk, rst;
logic [1:0] mode;  
integer i,j;



	convolution_buffer cb(
		.ired(ired),
		.iblue(iblue),
		.igreen(igreen),
		.idval(idata_val),
		.ored(ored),
		.oblue(oblue),
		.ogreen(ogreen),
		.odval(odata_val),
		.mode(mode),
		.clk(clk),
		.rst_n(~rst)
	);



initial begin
	//initialize values
	rst = 0;
	clk = 0;
	idata_val = 0;
	ired = 12'h000;
	iblue = 12'h000;
	igreen = 12'h000;
	mode = 2'b01;	// 01 is vertical edge, 10 is horizontal edge, other is greyscale
	
	#10;
	rst = 1;	//reset
	#50;
	rst = 0;
	#10;

	//assign first 2 rows of bits
	
	idata_val = 1;
	
	for(i = 0; i < 2; i = i + 1) begin

		//assign first 3 bits in each rows
		for(j = 0; j < 1; j = j + 1) begin
			ired = 12'hFFF;
			iblue = 12'hFFF;
			igreen = 12'hFFF;
			
			@(posedge clk);
			@(posedge clk);
		end
		
		//push rest of line into buffer
		for(j = 0; j < 639; j = j + 1) begin
			ired = 12'h000;
			iblue = 12'h000;
			igreen = 12'h000;
			
			@(posedge clk);
			@(posedge clk);
		end		
	end

	//push last row of 3 bits to start convolution
	for(i = 0; i < 4; i = i + 1) begin
		
		ired = '0;
		iblue = '0;
		igreen = '0;
		
		@(posedge clk);
		@(posedge clk);
		
	end

	//stop sending data
	idata_val = 0;
	
	repeat(5000) @(posedge clk);
	
	$stop();

end	

always begin
	#5 clk = ~clk;
end

endmodule
