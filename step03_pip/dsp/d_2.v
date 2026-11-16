(* DONT_TOUCH = "true" *)
module top (
  input  wire        clk,
  input  wire [29:0] a,
  input  wire [17:0] b,
  output wire [47:0] p
);
  (* DONT_TOUCH = "true" *)
  DSP48E1 #(
    .AREG(2), .ACASCREG(1), .BREG(0), .BCASCREG(0),
    .CREG(0), .DREG(0), .MREG(0), .PREG(0), .ADREG(0),
    .ALUMODEREG(0), .INMODEREG(0), .OPMODEREG(0), .CARRYINREG(0),
    .CARRYINSELREG(0), .SEL_MASK("MASK"), .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"), .USE_MULT("MULTIPLY"), .AUTORESET_PATDET("NO_RESET"),
    .MASK(48'h3fffffffffff), .PATTERN(48'h0)
  ) u_dsp (
    .A(a), .B(b), .C(48'b0), .D(48'b0), .CARRYIN(1'b0),
    .OPMODE(7'b0000101), .ALUMODE(4'b0), .INMODE(5'b0), .CLK(clk),
    .CEA1(1'b1), .CEA2(1'b1), .CEB1(1'b1), .CEB2(1'b1), .CEC(1'b1),
    .CED(1'b1), .CEM(1'b1), .CEP(1'b1), .CEAD(1'b1), .CEALUMODE(1'b1),
    .CEINMODE(1'b1), .CECTRL(1'b1), .CARRYINSEL(3'b0),
    .RSTA(1'b0), .RSTB(1'b0), .RSTC(1'b0), .RSTD(1'b0), .RSTM(1'b0),
    .RSTP(1'b0), .RSTALLCARRYIN(1'b0), .RSTALUMODE(1'b0), .RSTCTRL(1'b0),
    .RSTINMODE(1'b0),
    .P(p)
  );
endmodule
