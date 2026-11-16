module top(input a, b, c, clk, output reg q, output o, output o2);
  (* DONT_TOUCH = "true" *) wire l;
  LUT6 #(.INIT(64'h6996966996696996)) u_lut (.O(l), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "true" *) wire [3:0] cout; wire [3:0] s;
  CARRY4 u_c4 (.CO(cout), .O(s), .CI(1'b0), .CYINIT(1'b0), .DI({3'b0,c}), .S({3'b0,c}));
  always @(posedge clk) q <= cout[3];
  assign o = l;
  assign o2 = cout[3];
endmodule
