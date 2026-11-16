// P1 级补强设计：d6_muxtree  —— 8 组 × 6 层 2:1 mux 树
`timescale 1ns/1ps
module top(input wire clk, input wire [7:0] din, output wire [7:0] dout);
  wire m0_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEBABE *) LUT6 #(.INIT(64'h00000000CAFEBABE)) m0_0_u (.O(m0_0), .I0(din[0]), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m0_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEBABF *) LUT6 #(.INIT(64'h00000000CAFEBABF)) m0_1_u (.O(m0_1), .I0(m0_0), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m0_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEBAC0 *) LUT6 #(.INIT(64'h00000000CAFEBAC0)) m0_2_u (.O(m0_2), .I0(m0_1), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m0_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEBAC1 *) LUT6 #(.INIT(64'h00000000CAFEBAC1)) m0_3_u (.O(m0_3), .I0(m0_2), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m0_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEBAC2 *) LUT6 #(.INIT(64'h00000000CAFEBAC2)) m0_4_u (.O(m0_4), .I0(m0_3), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m0_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEBAC3 *) LUT6 #(.INIT(64'h00000000CAFEBAC3)) m0_5_u (.O(m0_5), .I0(m0_4), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 0 tail = m0_5
  wire m1_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFECBCF *) LUT6 #(.INIT(64'h00000000CAFECBCF)) m1_0_u (.O(m1_0), .I0(din[1]), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m1_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFECBD0 *) LUT6 #(.INIT(64'h00000000CAFECBD0)) m1_1_u (.O(m1_1), .I0(m1_0), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m1_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFECBD1 *) LUT6 #(.INIT(64'h00000000CAFECBD1)) m1_2_u (.O(m1_2), .I0(m1_1), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m1_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFECBD2 *) LUT6 #(.INIT(64'h00000000CAFECBD2)) m1_3_u (.O(m1_3), .I0(m1_2), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m1_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFECBD3 *) LUT6 #(.INIT(64'h00000000CAFECBD3)) m1_4_u (.O(m1_4), .I0(m1_3), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m1_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFECBD4 *) LUT6 #(.INIT(64'h00000000CAFECBD4)) m1_5_u (.O(m1_5), .I0(m1_4), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 1 tail = m1_5
  wire m2_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEDCE0 *) LUT6 #(.INIT(64'h00000000CAFEDCE0)) m2_0_u (.O(m2_0), .I0(din[2]), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m2_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEDCE1 *) LUT6 #(.INIT(64'h00000000CAFEDCE1)) m2_1_u (.O(m2_1), .I0(m2_0), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m2_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEDCE2 *) LUT6 #(.INIT(64'h00000000CAFEDCE2)) m2_2_u (.O(m2_2), .I0(m2_1), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m2_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEDCE3 *) LUT6 #(.INIT(64'h00000000CAFEDCE3)) m2_3_u (.O(m2_3), .I0(m2_2), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m2_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEDCE4 *) LUT6 #(.INIT(64'h00000000CAFEDCE4)) m2_4_u (.O(m2_4), .I0(m2_3), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m2_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEDCE5 *) LUT6 #(.INIT(64'h00000000CAFEDCE5)) m2_5_u (.O(m2_5), .I0(m2_4), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 2 tail = m2_5
  wire m3_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEEDF1 *) LUT6 #(.INIT(64'h00000000CAFEEDF1)) m3_0_u (.O(m3_0), .I0(din[3]), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m3_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEEDF2 *) LUT6 #(.INIT(64'h00000000CAFEEDF2)) m3_1_u (.O(m3_1), .I0(m3_0), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m3_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEEDF3 *) LUT6 #(.INIT(64'h00000000CAFEEDF3)) m3_2_u (.O(m3_2), .I0(m3_1), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m3_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEEDF4 *) LUT6 #(.INIT(64'h00000000CAFEEDF4)) m3_3_u (.O(m3_3), .I0(m3_2), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m3_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEEDF5 *) LUT6 #(.INIT(64'h00000000CAFEEDF5)) m3_4_u (.O(m3_4), .I0(m3_3), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m3_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEEDF6 *) LUT6 #(.INIT(64'h00000000CAFEEDF6)) m3_5_u (.O(m3_5), .I0(m3_4), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 3 tail = m3_5
  wire m4_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEFF02 *) LUT6 #(.INIT(64'h00000000CAFEFF02)) m4_0_u (.O(m4_0), .I0(din[4]), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m4_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEFF03 *) LUT6 #(.INIT(64'h00000000CAFEFF03)) m4_1_u (.O(m4_1), .I0(m4_0), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m4_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEFF04 *) LUT6 #(.INIT(64'h00000000CAFEFF04)) m4_2_u (.O(m4_2), .I0(m4_1), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m4_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEFF05 *) LUT6 #(.INIT(64'h00000000CAFEFF05)) m4_3_u (.O(m4_3), .I0(m4_2), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m4_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEFF06 *) LUT6 #(.INIT(64'h00000000CAFEFF06)) m4_4_u (.O(m4_4), .I0(m4_3), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m4_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFEFF07 *) LUT6 #(.INIT(64'h00000000CAFEFF07)) m4_5_u (.O(m4_5), .I0(m4_4), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 4 tail = m4_5
  wire m5_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF1013 *) LUT6 #(.INIT(64'h00000000CAFF1013)) m5_0_u (.O(m5_0), .I0(din[5]), .I1(din[5]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m5_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF1014 *) LUT6 #(.INIT(64'h00000000CAFF1014)) m5_1_u (.O(m5_1), .I0(m5_0), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m5_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF1015 *) LUT6 #(.INIT(64'h00000000CAFF1015)) m5_2_u (.O(m5_2), .I0(m5_1), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m5_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF1016 *) LUT6 #(.INIT(64'h00000000CAFF1016)) m5_3_u (.O(m5_3), .I0(m5_2), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m5_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF1017 *) LUT6 #(.INIT(64'h00000000CAFF1017)) m5_4_u (.O(m5_4), .I0(m5_3), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m5_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF1018 *) LUT6 #(.INIT(64'h00000000CAFF1018)) m5_5_u (.O(m5_5), .I0(m5_4), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 5 tail = m5_5
  wire m6_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF2124 *) LUT6 #(.INIT(64'h00000000CAFF2124)) m6_0_u (.O(m6_0), .I0(din[6]), .I1(din[6]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m6_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF2125 *) LUT6 #(.INIT(64'h00000000CAFF2125)) m6_1_u (.O(m6_1), .I0(m6_0), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m6_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF2126 *) LUT6 #(.INIT(64'h00000000CAFF2126)) m6_2_u (.O(m6_2), .I0(m6_1), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m6_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF2127 *) LUT6 #(.INIT(64'h00000000CAFF2127)) m6_3_u (.O(m6_3), .I0(m6_2), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m6_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF2128 *) LUT6 #(.INIT(64'h00000000CAFF2128)) m6_4_u (.O(m6_4), .I0(m6_3), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m6_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF2129 *) LUT6 #(.INIT(64'h00000000CAFF2129)) m6_5_u (.O(m6_5), .I0(m6_4), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 6 tail = m6_5
  wire m7_0;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF3235 *) LUT6 #(.INIT(64'h00000000CAFF3235)) m7_0_u (.O(m7_0), .I0(din[7]), .I1(din[7]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m7_1;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF3236 *) LUT6 #(.INIT(64'h00000000CAFF3236)) m7_1_u (.O(m7_1), .I0(m7_0), .I1(din[0]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m7_2;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF3237 *) LUT6 #(.INIT(64'h00000000CAFF3237)) m7_2_u (.O(m7_2), .I0(m7_1), .I1(din[1]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m7_3;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF3238 *) LUT6 #(.INIT(64'h00000000CAFF3238)) m7_3_u (.O(m7_3), .I0(m7_2), .I1(din[2]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m7_4;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF3239 *) LUT6 #(.INIT(64'h00000000CAFF3239)) m7_4_u (.O(m7_4), .I0(m7_3), .I1(din[3]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  wire m7_5;
  (* DONT_TOUCH = "true", INIT = 64'h00000000CAFF323A *) LUT6 #(.INIT(64'h00000000CAFF323A)) m7_5_u (.O(m7_5), .I0(m7_4), .I1(din[4]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));
  // group 7 tail = m7_5
  assign dout = {m7_5, m6_5, m5_5, m4_5, m3_5, m2_5, m1_5, m0_5};
endmodule
