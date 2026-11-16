module top(input a, b, c, clk, rst, output o, output qo);
  (* DONT_TOUCH = "true" *) wire w6;
  LUT6 #(.INIT(64'h6996966996696996)) u_lut (.O(w6), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  assign o = w6;
  FDRE #(.INIT(1'b0)) u_ff (.D(w6), .C(clk), .CE(1'b1), .R(1'b0), .Q(qo));
endmodule
