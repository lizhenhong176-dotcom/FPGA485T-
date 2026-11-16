module top(
  input  a0, a1, a2, a3, a4, a5,
  output y0, y1, y2, y3, y4, y5, y6, y7,
  output y8, y9, y10, y11, y12, y13, y14, y15,
  output y16, y17, y18, y19, y20, y21, y22, y23
);
  // 24-stage combinational chain, each stage pinned to a distant SLICE by XDC.
  // DONT_TOUCH keeps the chain (and every LUT) alive through opt_design.
  wire [24:0] w;
  assign w[0] = a0;

  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hA5A5_1234_5678_9ABC)) u00 (.O(w[1]),  .I0(w[0]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h5A5A_EDCB_A987_6543)) u01 (.O(w[2]),  .I0(w[1]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hFFFF_0000_FFFF_0000)) u02 (.O(w[3]),  .I0(w[2]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000_FFFF_0000_FFFF)) u03 (.O(w[4]),  .I0(w[3]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hCCCC_3333_CCCC_3333)) u04 (.O(w[5]),  .I0(w[4]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h3333_CCCC_3333_CCCC)) u05 (.O(w[6]),  .I0(w[5]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hFF00_FF00_FF00_FF00)) u06 (.O(w[7]),  .I0(w[6]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h00FF_00FF_00FF_00FF)) u07 (.O(w[8]),  .I0(w[7]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hF0F0_0F0F_F0F0_0F0F)) u08 (.O(w[9]),  .I0(w[8]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0F0F_F0F0_0F0F_F0F0)) u09 (.O(w[10]), .I0(w[9]),  .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hA5A5_5A5A_A5A5_5A5A)) u10 (.O(w[11]), .I0(w[10]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h5A5A_A5A5_5A5A_A5A5)) u11 (.O(w[12]), .I0(w[11]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000_0000_0000_0001)) u12 (.O(w[13]), .I0(w[12]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h7FFF_FFFF_FFFF_FFFE)) u13 (.O(w[14]), .I0(w[13]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h1234_5678_9ABC_DEF0)) u14 (.O(w[15]), .I0(w[14]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hFEDC_BA98_7654_3210)) u15 (.O(w[16]), .I0(w[15]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hCAFE_BABE_DEAD_BEEF)) u16 (.O(w[17]), .I0(w[16]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0BAD_F00D_1DEA_5EED)) u17 (.O(w[18]), .I0(w[17]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hFEED_FACE_CAFE_BEEF)) u18 (.O(w[19]), .I0(w[18]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hA5A5_A5A5_5A5A_5A5A)) u19 (.O(w[20]), .I0(w[19]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h5A5A_5A5A_A5A5_A5A5)) u20 (.O(w[21]), .I0(w[20]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h9669_6996_9669_6996)) u21 (.O(w[22]), .I0(w[21]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h6996_9669_6996_9669)) u22 (.O(w[23]), .I0(w[22]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hF0F0_F0F0_F0F0_F0F1)) u23 (.O(w[24]), .I0(w[23]), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));

  assign y0 = w[1];  assign y1 = w[2];  assign y2 = w[3];  assign y3 = w[4];
  assign y4 = w[5];  assign y5 = w[6];  assign y6 = w[7];  assign y7 = w[8];
  assign y8 = w[9];  assign y9 = w[10]; assign y10 = w[11]; assign y11 = w[12];
  assign y12 = w[13]; assign y13 = w[14]; assign y14 = w[15]; assign y15 = w[16];
  assign y16 = w[17]; assign y17 = w[18]; assign y18 = w[19]; assign y19 = w[20];
  assign y20 = w[21]; assign y21 = w[22]; assign y22 = w[23]; assign y23 = w[24];
endmodule
