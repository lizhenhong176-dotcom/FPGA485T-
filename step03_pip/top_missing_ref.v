module top(input [5:0] a, input [5:0] b, output [1:0] o);
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000001)) lut_a (.I0(a[0]), .I1(a[1]), .I2(a[2]), .I3(a[3]), .I4(a[4]), .I5(a[5]), .O(o[0]));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h0000000000000001)) lut_b (.I0(b[0]), .I1(b[1]), .I2(b[2]), .I3(b[3]), .I4(b[4]), .I5(b[5]), .O(o[1]));
endmodule
