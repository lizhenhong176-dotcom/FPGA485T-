// P1 级补强设计：d5_srl  —— 32 个 SRL16E 移位寄存器（4 列 × 8 行）
`timescale 1ns/1ps
module top(input wire clk, input wire [7:0] din, output wire [7:0] dout);
  wire [31:0] q;
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s0 (.Q(q[0]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[0]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s1 (.Q(q[1]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[1]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s2 (.Q(q[2]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[2]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s3 (.Q(q[3]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[3]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s4 (.Q(q[4]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[4]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s5 (.Q(q[5]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[5]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s6 (.Q(q[6]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[6]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s7 (.Q(q[7]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[7]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s8 (.Q(q[8]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[0]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s9 (.Q(q[9]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[1]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s10 (.Q(q[10]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[2]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s11 (.Q(q[11]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[3]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s12 (.Q(q[12]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[4]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s13 (.Q(q[13]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[5]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s14 (.Q(q[14]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[6]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s15 (.Q(q[15]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[7]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s16 (.Q(q[16]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[0]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s17 (.Q(q[17]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[1]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s18 (.Q(q[18]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[2]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s19 (.Q(q[19]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[3]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s20 (.Q(q[20]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[4]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s21 (.Q(q[21]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[5]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s22 (.Q(q[22]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[6]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s23 (.Q(q[23]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[7]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s24 (.Q(q[24]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[0]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s25 (.Q(q[25]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[1]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s26 (.Q(q[26]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[2]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s27 (.Q(q[27]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[3]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s28 (.Q(q[28]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[4]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s29 (.Q(q[29]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[5]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s30 (.Q(q[30]), .A0(1'b1), .A1(1'b0), .A2(1'b1), .A3(1'b1), .CE(1'b1), .CLK(clk), .D(din[6]));
  (* DONT_TOUCH = "true" *) SRL16E #(.INIT(16'h0001)) s31 (.Q(q[31]), .A0(1'b1), .A1(1'b0), .A2(1'b0), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[7]));
  assign dout = q[7:0] ^ q[15:8] ^ q[23:16] ^ q[31:24];
endmodule
