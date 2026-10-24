module top(input clk, output b);
  (* DONT_TOUCH = "yes" *) wire n1;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_a (.O(n1), .I0(clk), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_b (.O(b), .I0(n1), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
