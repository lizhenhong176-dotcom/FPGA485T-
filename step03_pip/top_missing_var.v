module top(input [5:0] a, input [5:0] b, input [5:0] c, input [5:0] d, output [3:0] o);
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000001)) lut_a (.I0(a[0]), .I1(a[1]), .I2(a[2]), .I3(a[3]), .I4(a[4]), .I5(a[5]), .O(o[0]));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000001)) lut_b (.I0(b[0]), .I1(b[1]), .I2(b[2]), .I3(b[3]), .I4(b[4]), .I5(b[5]), .O(o[1]));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000001)) lut_c (.I0(c[0]), .I1(c[1]), .I2(c[2]), .I3(c[3]), .I4(c[4]), .I5(c[5]), .O(o[2]));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000001)) lut_d (.I0(d[0]), .I1(d[1]), .I2(d[2]), .I3(d[3]), .I4(d[4]), .I5(d[5]), .O(o[3]));
endmodule
