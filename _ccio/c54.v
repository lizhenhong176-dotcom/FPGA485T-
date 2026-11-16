module top(input clk, output q);
  (* DONT_TOUCH = "true" *) wire c, i, g, fb;
  (* DONT_TOUCH = "true" *) IBUF u_ibuf (.I(clk), .O(i));
  (* DONT_TOUCH = "true" *) BUFHCE u_bh (.I(i), .CE(1'b1), .O(c));
  (* DONT_TOUCH = "true" *) MMCME2_ADV #(.CLKOUT0_DIVIDE_F(10.0), .CLKFBOUT_MULT_F(10.0),
        .CLKIN1_PERIOD(10.0), .DIVCLK_DIVIDE(1))
        u_mmcm (.CLKIN1(c), .CLKFBIN(fb), .CLKFBOUT(fb), .CLKOUT0(g),
                .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(),
                .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6(),
                .CLKFBOUTB(), .LOCKED(), .PWRDWN(1'b0), .RST(1'b0),
                .CLKIN2(1'b0), .CLKINSEL(1'b1), .DADDR(7'b0), .DCLK(1'b0),
                .DEN(1'b0), .DI(16'b0), .DO(), .DRDY(), .DWE(1'b0),
                .PSDONE(), .PSCLK(1'b0), .PSEN(1'b0), .PSINCDEC(1'b0));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.C(g), .CE(1'b1), .R(1'b0), .D(1'b1), .Q(q));
endmodule
