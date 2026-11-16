module top(input a, b, c, output o);
  (* DONT_TOUCH = "true" *) wire [3:0] co, so;
  (* DONT_TOUCH = "true" *) wire cyo;
  LUT6 #(.INIT(64'h0000000000000001)) u_l2 (.O(cyo), .I0(a), .I1(b), .I2(c), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  CARRY4 u_cy (.CO(co), .O(so), .CI(1'b0), .CYINIT(cyo), .DI({a,b,c,1'b0}), .S({a,b,c,1'b1}));
  assign o = co[3] ^ so[0];
endmodule
