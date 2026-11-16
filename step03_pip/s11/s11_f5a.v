module top(input clk, input [5:0] a, input ce, output o, output q);
  wire lo5;
  LUT6_2 #(.INIT(64'h9E3779B97F4A7C15)) uA (.I0(a[0]), .I1(a[1]), .I2(a[2]), .I3(a[3]), .I4(a[4]), .I5(a[5]), .O5(lo5), .O6(o));
  FDRE fA (.C(clk), .D(lo5), .Q(q), .CE(ce), .R(1'b0));
endmodule