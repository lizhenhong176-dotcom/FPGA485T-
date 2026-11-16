module top(input clk, output q);
  wire c, fb;
  (* DONT_TOUCH = "true" *) PLLE2_ADV #(.CLKOUT0_DIVIDE(10), .CLKFBOUT_MULT(10), .DIVCLK_DIVIDE(1), .CLKIN1_PERIOD(10.0)) u_cmt (.CLKIN1(clk), .CLKOUT0(c), .CLKFBIN(fb), .CLKFBOUT(fb), .CLKOUT1(), .CLKOUT2(), .CLKOUT3(), .CLKOUT4(), .CLKOUT5(), .RST(1'b0), .PWRDWN(1'b0), .LOCKED());
  (* DONT_TOUCH = "true" *) BUFHCE u_bh (.I(c), .O(qb), .CE(1'b1));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.D(qb), .C(qb), .CE(1'b1), .R(1'b0), .Q(q));
endmodule
