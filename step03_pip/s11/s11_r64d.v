module top(input clk, input we, input [5:0] a, input d, output spo, output dpo);
  RAM64X1D #(.INIT(64'h9E3779B97F4A7C15)) rA (.A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(d), .SPO(spo), .DPO(dpo), .WCLK(clk), .WE(we));
endmodule