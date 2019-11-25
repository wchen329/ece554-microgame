
`define CODE_OFF 7'b1111111
`define CODE_0 7'b1000000
`define CODE_1 7'b1111001
`define CODE_2 7'b0100100
`define CODE_3 7'b0110000
`define CODE_4 7'b0011001
`define CODE_5 7'b0010010
`define CODE_6 7'b0000010
`define CODE_7 7'b1111000
`define CODE_8 7'b0000000
`define CODE_9 7'b0011000
`define CODE_A 7'b0001000
`define CODE_B 7'b0000011
`define CODE_C 7'b1000110
`define CODE_D 7'b0100001
`define CODE_E 7'b0000110
`define CODE_F 7'b0001110

module hexdecode(
	input [3:0] code,
	output [6:0] seven
);

always_comb begin
	seven = `CODE_OFF;
	
	case(code)
		4'b0000:seven=`CODE_0;
		4'b0001:seven=`CODE_1;
		4'b0010:seven=`CODE_2;
		4'b0011:seven=`CODE_3;
		4'b0100:seven=`CODE_4;
		4'b0101:seven=`CODE_5;
		4'b0110:seven=`CODE_6;
		4'b0111:seven=`CODE_7;
		4'b1000:seven=`CODE_8;
		4'b1001:seven=`CODE_9;
		4'b1010:seven=`CODE_A;
		4'b1011:seven=`CODE_B;
		4'b1100:seven=`CODE_C;
		4'b1101:seven=`CODE_D;
		4'b1110:seven=`CODE_E;
		4'b1111:seven=`CODE_F;
	endcase
end

endmodule
