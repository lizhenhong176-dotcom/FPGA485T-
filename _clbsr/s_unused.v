module top(input a, clk, rst, output reg q);
  (* DONT_TOUCH = "true" *) wire l;
  LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_lut (.O(l), .I0(a), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  always @(posedge clk) if (1'b0) q <= 1'b0; else q <= l;
endmodule
