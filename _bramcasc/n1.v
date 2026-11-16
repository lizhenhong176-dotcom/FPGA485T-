module top(input clk, input [15:0] addr, input [31:0] di, input [3:0] we,
                 output [31:0] doa, output [31:0] dob, output [3:0] dopa, output [3:0] dopb);
  (* DONT_TOUCH = "true" *) RAMB36E1 #(.READ_WIDTH_A(36), .READ_WIDTH_B(36), .WRITE_WIDTH_A(36), .WRITE_WIDTH_B(36), .DOA_REG(0), .DOB_REG(0)) u_bram (
    .CLKARDCLK(clk), .CLKBWRCLK(clk),
    .ENARDEN(1'b1), .ENBWREN(1'b1), .REGCEAREGCE(1'b1), .REGCEB(1'b1),
    .RSTRAMARSTRAM(1'b0), .RSTRAMB(1'b0), .RSTREGARSTREG(1'b0), .RSTREGB(1'b0),
    .ADDRARDADDR({1'b1, addr[14:0]}), .ADDRBWRADDR({1'b1, addr[14:0]}),
    .DIADI(di), .DIBDI(di), .DIPADIP(4'h0), .DIPBDIP(4'h0),
    .WEA(we), .WEBWE({2{we}}),
    .DOADO(doa), .DOBDO(dob), .DOPADOP(dopa), .DOPBDOP(dopb)
  );
endmodule
