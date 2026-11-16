module top(input clk, output q);
  wire i;
  (* DONT_TOUCH = "true" *) IBUF u_ibuf (.I(clk), .O(i));
  (* DONT_TOUCH = "true" *) BUFGCE u_bgc (.I(i), .CE(1'b1), .O(g));
  (* DONT_TOUCH = "true" *) BUFHCE u_bh (.I(g), .CE(1'b1), .O(c));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.C(c), .CE(1'b1), .R(1'b0), .D(1'b1), .Q(q));
endmodule
