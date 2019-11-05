module addsub ( rd, v, rs, rt, sub );
  output logic 	[31:0] rd;
  output logic	       v;       //Overflow
  input  logic	[31:0] rs, rt;
  input  logic	       sub;    //1=sub, 0=add
  
  logic       	ovfl;
  logic [31:0] 	sum, b;
  logic		cout0, cout1, cout2, cout3, cout4, cout5, cout6;


  assign b        = sub ? ~rt : rt;
  assign v     = (rs[31] ~^  b[31])    &   (b[31] ^ sum[31]);  //operands have same sign AND sign changes
  assign rd       =    sum;
  
  add_4bit_lookahead 	adder0 (.sum(sum[3:0]),   .c4(cout0), .a(rs[3:0]),   .b(b[3:0]),   .c0(sub)),
  			adder1 (.sum(sum[7:4]),   .c4(cout1), .a(rs[7:4]),   .b(b[7:4]),   .c0(cout0)),
 			adder2 (.sum(sum[11:8]),  .c4(cout2), .a(rs[11:8]),  .b(b[11:8]),  .c0(cout1)),
  			adder3 (.sum(sum[15:12]), .c4(cout3), .a(rs[15:12]), .b(b[15:12]), .c0(cout2)),
   			adder4 (.sum(sum[19:16]), .c4(cout4), .a(rs[19:16]), .b(b[19:16]), .c0(cout3)),
 		 	adder5 (.sum(sum[23:20]), .c4(cout5), .a(rs[23:20]), .b(b[23:20]), .c0(cout4)),
			adder6 (.sum(sum[27:24]), .c4(cout6), .a(rs[27:24]), .b(b[27:24]), .c0(cout5)),
  			adder7 (.sum(sum[31:28]), .c4(cout7), .a(rs[31:28]), .b(b[31:28]), .c0(cout6));


endmodule
