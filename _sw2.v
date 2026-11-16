module top(input a, output q);
  (* DONT_TOUCH = "true" *) wire w;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFF)) u1 (.O(w), .I0(a), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u0 (.O(q), .I0(1'b0), .I1(w), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
