module top(input clk, output q);
  (* DONT_TOUCH = "true" *) BUFG u_bufg (.I(clk), .O(clk2));
  (* DONT_TOUCH = "true" *) wire fb;
  (* DONT_TOUCH = "true" *) wire ck;
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(
    .CLKIN1_PERIOD(10.0), .CLKFBOUT_MULT_F(10.0), .DIVCLK_DIVIDE(1),
    .CLKOUT0_DIVIDE_F(10.0)
  ) u_mmcm (.CLKIN1(clk2), .CLKFBIN(fb), .CLKFBOUT(fb), .CLKOUT0(ck),
            .CLKOUT1(), .CLKOUT2(), .CLKOUT3(), .CLKOUT4(), .CLKOUT5(),
            .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2B(), .CLKOUT3B(),
            .CLKFBOUTB(), .LOCKED(), .PWRDWN(1'b0), .RST(1'b0),
            .CLKINSEL(1'b1), .DADDR(), .DCLK(), .DEN(), .DI(), .DO(), .DRDY(), .DWE());
  (* DONT_TOUCH = "true" *) FDRE u_ff (.C(ck), .CE(1'b1), .R(1'b0), .D(1'b1), .Q(q));
endmodule
