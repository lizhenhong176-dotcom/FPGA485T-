module top(input clk, input [6:0] i, output o);
  wire lo6;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h9E3779B97F4A7C15)) u_la
    (.I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]), .O(lo6));

  assign o = lo6;
endmodule
