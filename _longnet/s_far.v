module top(input a, output o);
  (* DONT_TOUCH = "true" *) LUT2 #(.INIT(4'h8)) u_l (.I0(a), .I1(1'b1), .O(w));
  (* DONT_TOUCH = "true", LOC = "SLICE_X2Y101", BEL = "A6LUT" *) LUT6 #(.INIT(64'h0000000000000001)) u_d (.O(o), .I0(w), .I1(1'b1), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
