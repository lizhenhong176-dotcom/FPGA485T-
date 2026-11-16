module top(input clk, input [6:0] i, output q);
  wire lo6;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h5555555555555555)) u_la
    (.I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]), .O(lo6));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(lo6), .Q(q), .CE(1'b1), .R(1'b0));
endmodule
