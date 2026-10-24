module top(
  input  a,
  output b
);
  (* DONT_TOUCH = "true" *) wire n1;

  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_a (
    .O(n1), .I0(a), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0)
  );

  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_b (
    .O(b), .I0(1'b0), .I1(n1), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0)
  );
endmodule
