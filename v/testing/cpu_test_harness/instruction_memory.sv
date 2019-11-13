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
reg [31:0] instructions[MAX_INSTRUCTIONS-1:0];

// read in fake instuction memory file
// make sure to add delay so this can complete
initial begin
	fd = $fopen("ece554-microgame/v/testing/cpu_test_harness/instructions.txt", "r");

	if(fd == 0) begin
		$display("Could not open file");
		$finish();
	end

	// clear memory
	for(i=0; i<MAX_INSTRUCTIONS; i=i+1) begin
		instructions[i] = 32'b0;
	end

	i = 0;
	while(i<MAX_INSTRUCTIONS && ~$feof(fd) && $fscanf(fd, "%b\n", instructions[i]) == 1) begin
		$display("loaded instruction: %b", instructions[i]);
		i = i + 1;
	end

	$fclose(fd);
end

assign data = address >= MAX_INSTRUCTIONS ? 32'b0 : instructions[address];

endmodule
