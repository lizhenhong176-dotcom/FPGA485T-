module top(input clk, output q);
  (* DONT_TOUCH = "true" *) PLLE2_ADV #(
    .CLKOUT0_DIVIDE(10), .CLKOUT1_DIVIDE(10), .CLKOUT2_DIVIDE(10),
    .CLKOUT3_DIVIDE(10), .CLKOUT4_DIVIDE(10), .CLKOUT5_DIVIDE(10),
    .CLKFBOUT_MULT(10), .DIVCLK_DIVIDE(1), .STARTUP_WAIT("FALSE")
  ) u_prim (
    .CLKIN1(clk), .CLKFBIN(fb), .CLKFBOUT(fb), .CLKOUT0(p0), .CLKOUT1(p1), .CLKOUT2(p2),
    .CLKOUT3(p3), .CLKOUT4(p4), .CLKOUT5(p5), .LOCKED(), .PWRDWN(1'b0), .RST(1'b0));
  (* DONT_TOUCH = "true" *) BUFH u_bufh (.I(p5), .O(ck));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.Q(q), .C(ck), .CE(1'b1), .R(1'b0), .D(q));
endmodule
