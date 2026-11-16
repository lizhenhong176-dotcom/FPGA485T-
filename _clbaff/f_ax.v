module top(input a, b, c, clk, output reg q, output o6);
  (* DONT_TOUCH = "true" *) wire o6w;
  LUT6_2 #(.INIT(64'h6996966996696996)) u_lut (.O6(o6w), .O5(), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  always @(posedge clk) q <= a;
  assign o6 = o6w;
endmodule
