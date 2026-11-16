// P1 级补强设计：d7_spread  —— 16 个 LUT 分散到 4 个 clock region（跨区/长线）
`timescale 1ns/1ps
module top(input wire clk, input wire [7:0] din, output wire [7:0] dout);
  wire [15:0] s;
  (* DONT_TOUCH = "true", INIT = 64'h0123456789ABCDEF *) LUT6 #(.INIT(64'h0123456789ABCDEF)) u0 (.O(s[0]), .I0(din[0]), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0022446688AACCEE *) LUT6 #(.INIT(64'h0022446688AACCEE)) u1 (.O(s[1]), .I0(din[1]), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h032147658BA9CFED *) LUT6 #(.INIT(64'h032147658BA9CFED)) u2 (.O(s[2]), .I0(din[2]), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h022046648AA8CEEC *) LUT6 #(.INIT(64'h022046648AA8CEEC)) u3 (.O(s[3]), .I0(din[3]), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h052741638DAFC9EB *) LUT6 #(.INIT(64'h052741638DAFC9EB)) u4 (.O(s[4]), .I0(din[4]), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h042640628CAEC8EA *) LUT6 #(.INIT(64'h042640628CAEC8EA)) u5 (.O(s[5]), .I0(din[5]), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h072543618FADCBE9 *) LUT6 #(.INIT(64'h072543618FADCBE9)) u6 (.O(s[6]), .I0(din[6]), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h062442608EACCAE8 *) LUT6 #(.INIT(64'h062442608EACCAE8)) u7 (.O(s[7]), .I0(din[7]), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h092B4D6F81A3C5E7 *) LUT6 #(.INIT(64'h092B4D6F81A3C5E7)) u8 (.O(s[8]), .I0(din[0]), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h082A4C6E80A2C4E6 *) LUT6 #(.INIT(64'h082A4C6E80A2C4E6)) u9 (.O(s[9]), .I0(din[1]), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0B294F6D83A1C7E5 *) LUT6 #(.INIT(64'h0B294F6D83A1C7E5)) u10 (.O(s[10]), .I0(din[2]), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0A284E6C82A0C6E4 *) LUT6 #(.INIT(64'h0A284E6C82A0C6E4)) u11 (.O(s[11]), .I0(din[3]), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0D2F496B85A7C1E3 *) LUT6 #(.INIT(64'h0D2F496B85A7C1E3)) u12 (.O(s[12]), .I0(din[4]), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0C2E486A84A6C0E2 *) LUT6 #(.INIT(64'h0C2E486A84A6C0E2)) u13 (.O(s[13]), .I0(din[5]), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0F2D4B6987A5C3E1 *) LUT6 #(.INIT(64'h0F2D4B6987A5C3E1)) u14 (.O(s[14]), .I0(din[6]), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  (* DONT_TOUCH = "true", INIT = 64'h0E2C4A6886A4C2E0 *) LUT6 #(.INIT(64'h0E2C4A6886A4C2E0)) u15 (.O(s[15]), .I0(din[7]), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  assign dout = {s[7:1], s[15]};
endmodule
