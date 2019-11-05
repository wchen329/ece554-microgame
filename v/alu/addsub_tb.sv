module tADDSUB ( );

  reg  signed  [15:0] Rs, Rt;
  wire signed  [16:0] tRd;
  reg                 mode;
  wire                V, tV;
  wire signed  [15:0] Rd, tRdSat;

  ADDSUB DUT (.Rd(Rd), .V(V), .Rs(Rs), .Rt(Rt), .mode(mode));

  assign tRd    = mode          ? Rs - Rt      :   Rs          +             Rt ;
  assign tRdSat = tRd > 32767   ? 32767        : (tRd < -32768 ? -32768  :  tRd);
  assign tV     = tRd > 32767   ? 1'b1         : (tRd < -32768 ? 1'b1    : 1'b0);

  always begin
    Rs   = $random % 65536;
    Rt   = $random % 65536;
    #5;
    $display("Rs:%d, Rt:%d, Rd:%D, tRdSat:%D, tRd:%d, V:%b, tV:%b, mode:%b", Rs, Rt, Rd, tRdSat, tRd, V, tV, mode);
    #5;
  end

  always #10
    mode = ~mode;

  initial
    mode = 1'b0;

  initial #500
    $finish;

endmodule
