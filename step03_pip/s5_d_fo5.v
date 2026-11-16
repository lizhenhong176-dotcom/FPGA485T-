module top(input clk, input [6:0] i, input ce, output q);
  wire o5;
  (* DONT_TOUCH = "yes" *) LUT6_2 #(.INIT(64'h5555555555555555)) u_la
    (.I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]), .O5(o5), .O6());
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(o5), .CE(ce), .R(1'b0), .Q(q));
endmodule
