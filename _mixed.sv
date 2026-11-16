module top(input clk, input a, output q);
  localparam int NDSP = 48;
  localparam int NBRAM = 48;
  logic [7:0] cnt = 8'd0;
  always_ff @(posedge clk) cnt <= cnt + 8'd1;
  logic [63:0] lchain;
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g000 (.O(lchain[0]), .I0(a), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[2]), .I4(cnt[3]), .I5(cnt[4]));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g001 (.O(lchain[1]), .I0(lchain[0]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g002 (.O(lchain[2]), .I0(lchain[1]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g003 (.O(lchain[3]), .I0(lchain[2]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g004 (.O(lchain[4]), .I0(lchain[3]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g005 (.O(lchain[5]), .I0(lchain[4]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g006 (.O(lchain[6]), .I0(lchain[5]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g007 (.O(lchain[7]), .I0(lchain[6]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g008 (.O(lchain[8]), .I0(lchain[7]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g009 (.O(lchain[9]), .I0(lchain[8]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g010 (.O(lchain[10]), .I0(lchain[9]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g011 (.O(lchain[11]), .I0(lchain[10]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g012 (.O(lchain[12]), .I0(lchain[11]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g013 (.O(lchain[13]), .I0(lchain[12]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g014 (.O(lchain[14]), .I0(lchain[13]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g015 (.O(lchain[15]), .I0(lchain[14]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g016 (.O(lchain[16]), .I0(lchain[15]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g017 (.O(lchain[17]), .I0(lchain[16]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g018 (.O(lchain[18]), .I0(lchain[17]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g019 (.O(lchain[19]), .I0(lchain[18]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g020 (.O(lchain[20]), .I0(lchain[19]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g021 (.O(lchain[21]), .I0(lchain[20]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g022 (.O(lchain[22]), .I0(lchain[21]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g023 (.O(lchain[23]), .I0(lchain[22]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g024 (.O(lchain[24]), .I0(lchain[23]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g025 (.O(lchain[25]), .I0(lchain[24]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g026 (.O(lchain[26]), .I0(lchain[25]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g027 (.O(lchain[27]), .I0(lchain[26]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g028 (.O(lchain[28]), .I0(lchain[27]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g029 (.O(lchain[29]), .I0(lchain[28]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g030 (.O(lchain[30]), .I0(lchain[29]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g031 (.O(lchain[31]), .I0(lchain[30]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g032 (.O(lchain[32]), .I0(lchain[31]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g033 (.O(lchain[33]), .I0(lchain[32]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g034 (.O(lchain[34]), .I0(lchain[33]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g035 (.O(lchain[35]), .I0(lchain[34]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g036 (.O(lchain[36]), .I0(lchain[35]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g037 (.O(lchain[37]), .I0(lchain[36]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g038 (.O(lchain[38]), .I0(lchain[37]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g039 (.O(lchain[39]), .I0(lchain[38]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g040 (.O(lchain[40]), .I0(lchain[39]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g041 (.O(lchain[41]), .I0(lchain[40]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g042 (.O(lchain[42]), .I0(lchain[41]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g043 (.O(lchain[43]), .I0(lchain[42]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g044 (.O(lchain[44]), .I0(lchain[43]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g045 (.O(lchain[45]), .I0(lchain[44]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g046 (.O(lchain[46]), .I0(lchain[45]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g047 (.O(lchain[47]), .I0(lchain[46]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g048 (.O(lchain[48]), .I0(lchain[47]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g049 (.O(lchain[49]), .I0(lchain[48]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g050 (.O(lchain[50]), .I0(lchain[49]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g051 (.O(lchain[51]), .I0(lchain[50]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g052 (.O(lchain[52]), .I0(lchain[51]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g053 (.O(lchain[53]), .I0(lchain[52]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g054 (.O(lchain[54]), .I0(lchain[53]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g055 (.O(lchain[55]), .I0(lchain[54]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g056 (.O(lchain[56]), .I0(lchain[55]), .I1(cnt[0]), .I2(cnt[1]), .I3(cnt[3]), .I4(cnt[5]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g057 (.O(lchain[57]), .I0(lchain[56]), .I1(cnt[1]), .I2(cnt[2]), .I3(cnt[4]), .I4(cnt[6]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g058 (.O(lchain[58]), .I0(lchain[57]), .I1(cnt[2]), .I2(cnt[3]), .I3(cnt[5]), .I4(cnt[7]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g059 (.O(lchain[59]), .I0(lchain[58]), .I1(cnt[3]), .I2(cnt[4]), .I3(cnt[6]), .I4(cnt[0]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g060 (.O(lchain[60]), .I0(lchain[59]), .I1(cnt[4]), .I2(cnt[5]), .I3(cnt[7]), .I4(cnt[1]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g061 (.O(lchain[61]), .I0(lchain[60]), .I1(cnt[5]), .I2(cnt[6]), .I3(cnt[0]), .I4(cnt[2]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g062 (.O(lchain[62]), .I0(lchain[61]), .I1(cnt[6]), .I2(cnt[7]), .I3(cnt[1]), .I4(cnt[3]), .I5(a));
  LUT6 #(.INIT(64'h6E6E6E6E6E6E6E6E)) g063 (.O(lchain[63]), .I0(lchain[62]), .I1(cnt[7]), .I2(cnt[0]), .I3(cnt[2]), .I4(cnt[4]), .I5(a));
  logic [47:0] pd [48:0];
  genvar gi;
  generate
  for (gi = 0; gi < NDSP; gi++) begin : gdsp
    DSP48E1 #(.USE_DPORT("FALSE"), .USE_MULT("MULTIPLY")) u_dsp (
      .CLK(clk), .A(30'h0000_0000 + gi), .B(18'h00001 + gi), .C(48'h0), .D(25'h0), .P(pd[gi]),
      .ALUMODE(4'b0000), .OPMODE(7'b0000101), .CARRYINSEL(3'b000), .CARRYIN(1'b0),
      .CEA1(1'b0), .CEA2(1'b0), .CEAD(1'b0), .CEALUMODE(1'b0), .CEB1(1'b0), .CEB2(1'b0), .CEC(1'b0),
      .CECARRYIN(1'b0), .CECTRL(1'b0), .CED(1'b0), .CEINMODE(1'b0), .CEM(1'b0), .CEP(1'b0),
      .RSTA(1'b0), .RSTALLCARRYIN(1'b0), .RSTALUMODE(1'b0), .RSTB(1'b0), .RSTC(1'b0), .RSTCTRL(1'b0),
      .RSTD(1'b0), .RSTINMODE(1'b0), .RSTM(1'b0), .RSTP(1'b0), .INMODE(5'b00000)
    );
  end
  for (gi = 0; gi < NBRAM; gi++) begin : gbram
    RAMB36E1 #(.DOA_REG(0), .DOB_REG(0), .READ_WIDTH_A(18), .READ_WIDTH_B(18), .WRITE_WIDTH_A(18), .WRITE_WIDTH_B(18), .RAM_MODE("TDP")) u_bram (
      .CLKARDCLK(clk), .CLKBWRCLK(clk), .ENARDEN(1'b1), .ENBWREN(1'b1),
      .REGCEAREGCE(1'b1), .REGCEB(1'b1), .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0),
      .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
      .ADDRARDADDR({1'b1, 5'b0, cnt[7:0], 2'b0}), .ADDRBWRADDR({1'b1, 5'b0, cnt[7:0], 2'b0}),
      .DIADI(32'h0), .DIBDI(32'h0), .DIPADIP(4'h0), .DIPBDIP(4'h0),
      .WEA(4'h0), .WEBWE(8'h0)
    );
  end
  endgenerate
  assign q = lchain[63] ^ cnt[0];
endmodule
