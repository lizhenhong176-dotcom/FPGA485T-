module top(input a, output q);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u0 (.O(q), .I0(1'b0), .I1(a), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
