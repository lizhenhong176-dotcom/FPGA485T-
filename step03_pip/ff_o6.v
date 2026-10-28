module top(input clk, input d, input [6:0] i, output q);
  (* DONT_TOUCH = "yes" *) wire lo6;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h5555555555555555)) u_lut
    (.I0(d), .I1(i[0]), .I2(i[1]), .I3(i[2]), .I4(i[3]), .I5(i[4]),
     .O(lo6));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(lo6), .Q(q), .CE(1'b1), .R(1'b0));
endmodule
