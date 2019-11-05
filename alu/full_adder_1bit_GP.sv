module full_adder_1bit_gp ( sum, g, p, cin, a, b );
   input  cin, a, b;
   output sum, g, p;

   assign p = a ^ b,

          sum = p ^ cin,
          g = a & b;

endmodule
