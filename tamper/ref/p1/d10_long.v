// P1 补强第二轮：d10_long -- 16 LUT 横跨极远列（长线）
`timescale 1ns/1ps
module top(input wire clk, input wire [7:0] din, output wire [7:0] dout);
  wire [15:0] n;
  LUT6 #(.INIT(64'hAC4C1B546AD303E5)) u0 (.O(n[0]), .I0(din[0]), .I1(din[0]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[2]));
  LUT6 #(.INIT(64'hBD5D0A457BC212F4)) u1 (.O(n[1]), .I0(n[0]), .I1(din[1]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[3]));
  LUT6 #(.INIT(64'h8E6E397648F121C7)) u2 (.O(n[2]), .I0(n[1]), .I1(din[2]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[4]));
  LUT6 #(.INIT(64'h9F7F286759E030D6)) u3 (.O(n[3]), .I0(n[2]), .I1(din[3]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[5]));
  LUT6 #(.INIT(64'hE8085F102E9747A1)) u4 (.O(n[4]), .I0(n[3]), .I1(din[4]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[6]));
  LUT6 #(.INIT(64'hF9194E013F8656B0)) u5 (.O(n[5]), .I0(n[4]), .I1(din[5]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[7]));
  LUT6 #(.INIT(64'hCA2A7D320CB56583)) u6 (.O(n[6]), .I0(n[5]), .I1(din[6]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[0]));
  LUT6 #(.INIT(64'hDB3B6C231DA47492)) u7 (.O(n[7]), .I0(n[6]), .I1(din[7]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[1]));
  LUT6 #(.INIT(64'h24C493DCE25B8B6D)) u8 (.O(n[8]), .I0(n[7]), .I1(din[0]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[2]));
  LUT6 #(.INIT(64'h35D582CDF34A9A7C)) u9 (.O(n[9]), .I0(n[8]), .I1(din[1]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[3]));
  LUT6 #(.INIT(64'h06E6B1FEC079A94F)) u10 (.O(n[10]), .I0(n[9]), .I1(din[2]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[4]));
  LUT6 #(.INIT(64'h17F7A0EFD168B85E)) u11 (.O(n[11]), .I0(n[10]), .I1(din[3]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[5]));
  LUT6 #(.INIT(64'h6080D798A61FCF29)) u12 (.O(n[12]), .I0(n[11]), .I1(din[4]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[6]));
  LUT6 #(.INIT(64'h7191C689B70EDE38)) u13 (.O(n[13]), .I0(n[12]), .I1(din[5]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[7]));
  LUT6 #(.INIT(64'h42A2F5BA843DED0B)) u14 (.O(n[14]), .I0(n[13]), .I1(din[6]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[0]));
  LUT6 #(.INIT(64'h53B3E4AB952CFC1A)) u15 (.O(n[15]), .I0(n[14]), .I1(din[7]), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[1]));
  assign dout[0] = n[15];
  assign dout[7:1] = 7'b0;
endmodule
