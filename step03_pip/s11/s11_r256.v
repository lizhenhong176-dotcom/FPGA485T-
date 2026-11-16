module top(input clk, input we, input [7:0] a, input d, output o);
  RAM256X1S #(.INIT(64'h9E3779B97F4A7C15)) rA (.A(a), .D(d), .O(o), .WCLK(clk), .WE(we));
endmodule
