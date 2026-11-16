module top(input a, b, c, output o);
  (* DONT_TOUCH = "true" *) wire [3:0] co, so;
  CARRY4 u_cy (.CO(co), .O(so), .CI(1'b1), .CYINIT(1'b0), .DI({a,b,c,1'b0}), .S({a,b,c,1'b1}));
  assign o = co[3] ^ so[0];
endmodule
