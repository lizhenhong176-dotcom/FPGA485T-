module top(input a, b, c, clk, output o, output reg q);
  (* DONT_TOUCH = "true" *) wire w6, w5;
  LUT6_2 #(.INIT(64'h6996966996696996)) u_lut (.O6(w6), .O5(w5), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  always @(posedge clk) q <= w5;
  assign o = w6;
endmodule
