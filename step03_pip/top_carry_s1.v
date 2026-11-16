// CARRY4 with S[0]=1 (forces DI[0] as carry source → should set ACY0)
module top(input [3:0] di, input [2:0] s_hi, input ci, output [3:0] o, output co);
  wire [3:0] co_w;
  wire [3:0] s = {s_hi, 1'b1};  // S[0] always 1
  (* DONT_TOUCH = "true" *) CARRY4 u_carry (
    .CO(co_w), .O(o), .CI(ci), .DI(di), .S(s)
  );
  assign co = co_w[3];
endmodule
