module top(input clk, output q);
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(
    .CLKOUT0_DIVIDE_F(10.0), .CLKOUT1_DIVIDE(10), .CLKOUT2_DIVIDE(10),
    .CLKOUT3_DIVIDE(10), .CLKOUT4_DIVIDE(10), .CLKOUT5_DIVIDE(10), .CLKOUT6_DIVIDE(10),
    .CLKFBOUT_MULT_F(10.0), .DIVCLK_DIVIDE(1), .STARTUP_WAIT("FALSE")
  ) u_prim (
    .CLKIN1(clk), .CLKFBIN(fb), .CLKFBOUT(fb), .CLKFBOUTB(), .CLKOUT0(c0), .CLKOUT0B(),
    .CLKOUT1(c1), .CLKOUT1B(), .CLKOUT2(c2), .CLKOUT2B(), .CLKOUT3(c3), .CLKOUT3B(),
    .CLKOUT4(c4), .CLKOUT5(c5), .CLKOUT6(c6),
    .LOCKED(), .PWRDWN(1'b0), .RST(1'b0));
  (* DONT_TOUCH = "true" *) BUFH u_bufh (.I(c0), .O(ck));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.Q(q), .C(ck), .CE(1'b1), .R(1'b0), .D(q));
endmodule
