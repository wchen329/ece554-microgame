module instruction_memory
#(
	parameter MAX_INSTRUCTIONS=64
)(
	input clk, rst_n,
	input [15:0] address,
	output [31:0] data
);

int fd;

integer i;
reg [MAX_INSTRUCTIONS-1:0] instructions[31:0];

// read in fake instuction memory file
// make sure to add delay so this can complete
initial begin
	fd = $fopen("instructions.txt", "r");

	// clear memory
	for(i=0; i<MAX_INSTRUCTIONS; i=i+1) begin
		instructions[i] = 32'b0;
	end

	i = 0;
	while(i<MAX_INSTRUCTIONS && ~$feof(fd) && $fscanf(fd, "%b\n", instructions[i])) begin
		i = i + 1;
	end
end

assign data = address >= MAX_INSTRUCTIONS ? 32'b0 : instructions[address];

endmodule
