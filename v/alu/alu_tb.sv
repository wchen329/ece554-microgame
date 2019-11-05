module alu_tb();

logic [31:0] a, b, alu_out;
logic z, n, v, clk;
logic [4:0] op;

initial begin
	clk = 0;
	@ (posedge clk)
	//and

	check_addition(5'h5, 32'hDEADBEEF, 32'h01234567, (32'hDEADBEEF & 32'h01234567));
	//or

	check_addition(5'h6, 32'hDEADBEEF, 32'h01234567, (32'hDEADBEEF | 32'h01234567));
	//xor

	check_addition(5'h7, 32'hDEADBEEF, 32'h01234567, (32'hDEADBEEF ^ 32'h01234567));
	//sll

	check_addition(5'h8, 32'hDEADBEEF, 32'h9, (32'hDEADBEEF << 32'h9));
	//srl
	check_addition(5'h9, 32'hDEADBEEF, 32'h4, (32'hDEADBEEF >> 32'h4));
	//sra
	check_addition(5'hA, 32'hDEADBEEF, 32'h10, (32'hDEADBEEF >>> 32'h10));
	//add
	check_addition(5'h3, 32'hDEADBEEF, 32'h01234567, (32'hDEADBEEF + 32'h01234567));
	//sub
	check_addition(5'h02, 32'h0EADBEEF, 32'h01234567, (32'h0EADBEEF - 32'h01234567));

	$display("All tests passed");



end

always begin
	#5 clk = ~clk;
end

alu dut (
	.operand_a(a),
	.operand_b(b),
	.result(alu_out),
	.v(v),
	.z(z),
	.n(n),
	.opcode(op)
);


task check_addition(
	input [4:0] opcode1,
	input [31:0] a1, b1,
	input [31:0] expected
	);
	
	a = a1;
	b = b1;
	op = opcode1;

	@(posedge clk);
	assert (alu_out == expected)
	else begin
		$display("Error in design");
		$stop();
	end

endtask



endmodule
