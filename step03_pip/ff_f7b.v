module top(input clk, input d, input [6:0] i, output q);
  (* DONT_TOUCH = "yes" *) wire oa, ob, o7;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h5555555555555555)) u_la
    (.I0(d), .I1(i[0]), .I2(i[1]), .I3(i[2]), .I4(i[3]), .I5(i[4]), .O(oa));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h5555555555555555)) u_lb
    (.I0(d), .I1(i[0]), .I2(i[1]), .I3(i[2]), .I4(i[3]), .I5(i[4]), .O(ob));
  (* DONT_TOUCH = "yes" *) MUXF7 u_mux (.I0(oa), .I1(ob), .S(i[5]), .O(o7));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(o7), .Q(q), .CE(1'b1), .R(1'b0));
endmodule
