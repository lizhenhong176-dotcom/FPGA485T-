module top(input a, b, c, clk, output o, output o2);
  (* DONT_TOUCH = "true" *) wire [3:0] cout; wire [3:0] s;
  CARRY4 u_c4 (.CO(cout), .O(s), .CI(1'b0), .CYINIT(1'b0), .DI({3'b0,c}), .S({3'b0,c}));
  (* DONT_TOUCH = "true" *) reg q;
  always @(posedge clk) q <= cout[3];
  assign o = cout[3];
  assign o2 = q;
endmodule
