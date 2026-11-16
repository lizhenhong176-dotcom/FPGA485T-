module top(input clk, input [5:0] a, input d, output o);
  RAM64X1S #(.INIT(64'h9E3779B97F4A7C15)) rA (.A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .O(o), .WCLK(clk), .WE(1'b0));
endmodule