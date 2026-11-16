module top(input clk, input [12:0] addr, output [15:0] doa);
  wire c_lat, c_reg;
  (* DONT_TOUCH = "true" *) RAMB18E1 #(.READ_WIDTH_A(1), .READ_WIDTH_B(1), .WRITE_WIDTH_A(1), .WRITE_WIDTH_B(1), .DOA_REG(0), .DOB_REG(0)) u_lo (
    .CLKARDCLK(clk), .CLKBWRCLK(clk),
    .ENARDEN(1'b1), .ENBWREN(1'b1), .REGCEAREGCE(1'b1), .REGCEB(1'b1),
    .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
    .ADDRARDADDR(addr_a), .ADDRBWRADDR(addr_b),
    .DIADI(16'h0), .DIBDI(16'h0), .DIPADIP(2'h0), .DIPBDIP(2'h0),
    .WEA(2'h0), .WEBWE(4'h0),
    .DOADO(doa), .DOBDO(), .DOPADOP(), .DOPBDOP(),
    .CASCADEINLATA(1'b0), .CASCADEINREGA(1'b0), .CASCADEINLATB(1'b0), .CASCADEINREGB(1'b0),
    .CASCADEOUTLATA(c_lat), .CASCADEOUTREGA(c_reg), .CASCADEOUTLATB(c_lat), .CASCADEOUTREGB(c_reg)
  );
endmodule
