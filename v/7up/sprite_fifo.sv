module sprite_fifo
#(
	parameter FIFO_SIZE=64
)(
	input clk, rst_n,
	input produce,
	input [79:0] command_in,
	input consume,
	output [79:0] command_out,
	output empty
);

logic full;

reg [79:0] fifo [FIFO_SIZE-1:0];
reg [$clog2(FIFO_SIZE)-1:0] producer, consumer;
reg [$clog2(FIFO_SIZE):0] fill;

assign empty = fill == 0;
assign full  = fill == FIFO_SIZE;

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		fill <= 0;
	end else if(produce && !consume && !full) begin
		fill <= fill + 1;
	end else if(consume && !produce && !empty) begin
		fill <= fill - 1;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		producer <= 0;
	end else if(produce && !full || produce && consume) begin
		producer <= producer + 1;
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		consumer <= 0;
	end else if(consume && !empty || consume && produce) begin
		consumer <= consumer + 1;
	end
end

always_ff @(posedge clk) begin
	if(produce && !full || produce && consume) begin
		fifo[producer] = command_in;
	end
end

assign command_out = empty ? 80'b0 : fifo[consumer];

endmodule
