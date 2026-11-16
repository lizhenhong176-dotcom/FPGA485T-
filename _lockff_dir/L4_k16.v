module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000010000)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule