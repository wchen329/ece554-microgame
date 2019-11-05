module alu  ( result, z, v, n, operand_a, operand_b, opcode);
  output logic 	[31:0]  result;
  output logic	z,v,n;
  input logic	[31:0]  operand_a, operand_b;
  input logic	[4:0]   opcode;
 
  logic       	[31:0] addsub_result;
  logic 	ovfl;
  logic		sub;

  assign	sub = (opcode == 5'h02) ? 1'b1 : 1'b0;

  addsub  addsub1 (.rd(addsub_result), .rs(operand_a), .rt(operand_b),  .sub(sub),    .v(ovfl));

  always_comb begin
    case(opcode)
	5'h05: 	begin //and
			result = operand_a & operand_b;
			n = '0;
			v = '0;
			z = (result == '0);
		end
	5'h06: 	begin //or
			result = operand_a | operand_b;
			n = '0;
			v = '0;
			z = (result == '0);
		end
	5'h07:	begin //xor
			result = operand_a ^ operand_b;
			n = '0;
			v = '0;
          		z = (result == '0);
        	end
      
	5'h08: 	begin //sll
         		result = operand_a << operand_b;
			v = '0;
			n = '0;
          		z = (result == '0);
        	end
	
	5'h09: 	begin //srl
			result = operand_a >> operand_b;
			v = '0;
			n = '0;
			z = (result == '0);
		end

	5'h0A: 	begin //sra
			result = operand_a >>> operand_b;
			v = '0;
			n = '0;
			z = (result == '0);
		end

	default: begin	//add/subract        
         		result = addsub_result;
			n = addsub_result[31];
			v = ovfl;
			z = (result == '0);
        	end
    endcase
  end

endmodule
