module top(input clk, input ce, input [4:0] a, input d, output q);
  SRLC32E #(.INIT(32'h9E3779B9)) rA (.A(a), .D(d), .Q(q), .CLK(clk), .CE(ce));
endmodule