module top(input a, b, c, clk, output reg q, output o);
  (* DONT_TOUCH = "true" *) wire l;
  LUT6 #(.INIT(64'h6996966996696996)) u_lut (.O(l), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  always @(posedge clk) q <= l;
  assign o = l;
endmodule
