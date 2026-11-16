module top(input clk, output q);
  (* DONT_TOUCH = "true" *) wire fb_a, fb_b, fb_p, ck_a, ck_p, ck_q;
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(
    .CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT_F(10.0), .DIVCLK_DIVIDE(1), .CLKOUT0_DIVIDE_F(10.0))
  u_a (.CLKIN1(clk), .CLKFBIN(fb_a), .CLKFBOUT(fb_a), .CLKOUT0(ck_a),
    .CLKOUT1(), .CLKOUT2(), .CLKOUT3(), .CLKOUT4(), .CLKOUT5(),
    .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2B(), .CLKOUT3B(), .CLKFBOUTB(),
    .LOCKED(), .PWRDWN(1'b0), .RST(1'b0), .CLKINSEL(1'b1),
    .DADDR(), .DCLK(), .DEN(), .DI(), .DO(), .DRDY(), .DWE());
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(
    .CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT_F(10.0), .DIVCLK_DIVIDE(1), .CLKOUT0_DIVIDE_F(10.0))
  u_b (.CLKIN1(ck_a), .CLKFBIN(fb_b), .CLKFBOUT(fb_b), .CLKOUT0(ck_q),
    .CLKOUT1(), .CLKOUT2(), .CLKOUT3(), .CLKOUT4(), .CLKOUT5(),
    .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2B(), .CLKOUT3B(), .CLKFBOUTB(),
    .LOCKED(), .PWRDWN(1'b0), .RST(1'b0), .CLKINSEL(1'b1),
    .DADDR(), .DCLK(), .DEN(), .DI(), .DO(), .DRDY(), .DWE());
  (* DONT_TOUCH = "true" *) FDRE u_ff (.C(ck_q), .CE(1'b1), .R(1'b0), .D(1'b1), .Q(q));
endmodule
