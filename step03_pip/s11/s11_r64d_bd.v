module top(input clk, input we, input [5:0] a, input d, input [5:0] b, output spo, output dpo, output ob);
  LUT6 #(.INIT(64'h9E3779B97F4A7C15)) uB (.I0(b[0]), .I1(b[1]), .I2(b[2]), .I3(b[3]), .I4(b[4]), .I5(b[5]), .O(ob));
  RAM64X1D #(.INIT(64'h5555555555555555)) rA (.A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .D(ob), .SPO(spo), .DPO(dpo), .WCLK(clk), .WE(we));
endmodule