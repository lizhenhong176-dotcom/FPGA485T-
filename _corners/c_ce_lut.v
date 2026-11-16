module top(input a, b, c, clk, output o, output qo);
  (* DONT_TOUCH = "true" *) wire w6, wce;
  LUT6 #(.INIT(64'h6996966996696996)) u_lut (.O(w6), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  LUT6 #(.INIT(64'h8000000000000000)) u_ce  (.O(wce), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  assign o = w6;
  FDRE #(.INIT(1'b0)) u_ff (.D(w6), .C(clk), .CE(wce), .R(1'b0), .Q(qo));
endmodule
