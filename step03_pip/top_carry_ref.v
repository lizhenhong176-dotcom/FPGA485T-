// CARRY4 with CI=0 (PRECYINIT=C0)
module top(input [3:0] di, input [3:0] s, output [3:0] o, output co);
  wire [3:0] co_w;
  (* DONT_TOUCH = "true" *) CARRY4 u_carry (
    .CO(co_w), .O(o), .CI(1'b0), .DI(di), .S(s)
  );
  assign co = co_w[3];
endmodule
