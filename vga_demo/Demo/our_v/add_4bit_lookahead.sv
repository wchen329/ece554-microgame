module add_4bit_lookahead ( sum, c_out, a, b, c_in );
   input logic [3:0] a, b; //Input values
   input logic       c_in;
   output logic [3:0] sum; //sum output
   output logic       c_out;

   logic	      g0,  g1,  g2,  g3,  p0,  p1,  p2,  p3,  c1,  c2,  c3;

   assign  c1 = g0 | p0 & c_in;
   assign  c2 = g1 | g0 & p1 | c_in & p0 & p1;
   assign  c3 = g2 | g1 & p2 | g0 & p1 & p2 | c_in & p0 & p1 & p2;
   assign  c_out = g3 | g2 & p3 | g1 & p2 & p3 | g0 & p1 & p2 & p3 | c_in & p0 & p1 & p2 & p3;

   full_adder_1bit_gp adders [3:0] (.sum(sum), .g({g3, g2, g1, g0}), .p({p3, p2, p1, p0}), .cin({c3, c2, c1, c_in}), .a(a), .b(b));

endmodule
