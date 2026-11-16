module top(input clk, input ena, input wea, input [13:0] addra, input [15:0] dia, output [15:0] doa);
  RAMB18E1 #(
    .READ_WIDTH_A(18),
    .WRITE_WIDTH_A(18),
    .READ_WIDTH_B(0),
    .WRITE_WIDTH_B(0),
    .RAM_MODE("TDP"),
    .INIT_A(18'h00001),
    .SRVAL_A(18'h00000),
    .DOA_REG(0),
    .DOB_REG(0)
  ) u_bram (
    .CLKARDCLK(clk),
    .CLKBWRCLK(clk),
    .ENARDEN(ena),
    .ENBWREN(1'b0),
    .REGCEAREGCE(1'b1),
    .REGCEB(1'b0),
    .RSTREGARSTREG(1'b0),
    .RSTREGB(1'b0),
    .ADDRARDADDR(addra),
    .ADDRBWRADDR(14'b0),
    .DIADI(dia),
    .DIBDI(16'b0),
    .DIPADIP(2'b0),
    .DIPBDIP(2'b0),
    .WEA(2'b11),
    .WEBWE(4'b0),
    .DOADO(doa),
    .DOBDO(),
    .DOPADOP(),
    .DOPBDOP()
  );
endmodule
