module top(input [6:0] i, output o);
  (* DONT_TOUCH = "yes" *) wire oa, ob;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h5555555555555555)) u_la
    (.I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]), .O(oa));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h5555555555555555)) u_lb
    (.I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]), .O(ob));
  (* DONT_TOUCH = "yes" *) MUXF7 u_mux (.I0(ob), .I1(oa), .S(i[6]), .O(o));
endmodule
