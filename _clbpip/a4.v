module top(input a, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) u_lut (.O(o), .I0(a));
endmodule
