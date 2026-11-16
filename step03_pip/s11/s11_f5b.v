module top(input clk, input ax, input ce, output q);
  FDRE fA (.C(clk), .D(ax), .Q(q), .CE(ce), .R(1'b0));
endmodule