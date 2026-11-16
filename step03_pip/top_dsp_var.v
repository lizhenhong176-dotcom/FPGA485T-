module top(input clk, input [24:0] a, input [17:0] b, input [47:0] c, output [47:0] p);
  DSP48E1 #(
    .USE_MULT("MULTIPLY"),
    .USE_SIMD("ONE48")
  ) u_dsp (
    .CLK(clk),
    .A({{5{1'b0}}, a}),
    .B(b),
    .C(c),
    .D(25'b0),
    .P(p),
    .CEA1(1'b1), .CEA2(1'b1), .CEAD(1'b0), .CEALUMODE(1'b1),
    .CEB1(1'b1), .CEB2(1'b1), .CEC(1'b1), .CECARRYIN(1'b1),
    .CECTRL(1'b1), .CED(1'b1), .CEINMODE(1'b1), .CEM(1'b1), .CEP(1'b1),
    .RSTA(1'b0), .RSTALLCARRYIN(1'b0), .RSTALUMODE(1'b0),
    .RSTB(1'b0), .RSTC(1'b0), .RSTCTRL(1'b0),
    .RSTD(1'b0), .RSTINMODE(1'b0), .RSTM(1'b0), .RSTP(1'b0),
    .ACIN(30'b0), .BCIN(18'b0), .PCIN(48'b0),
    .CARRYIN(1'b0), .CARRYINSEL(3'b000),
    .ALUMODE(4'b0000), .INMODE(5'b00000), .OPMODE(7'b0000000),
    .CARRYCASCIN(1'b0), .MULTSIGNIN(1'b0),
    .OVERFLOW(), .UNDERFLOW(), .CARRYOUT(),
    .PATTERNBDETECT(), .PATTERNDETECT(),
    .ACOUT(), .BCOUT(), .CARRYCASCOUT(), .MULTSIGNOUT()
  );
endmodule
