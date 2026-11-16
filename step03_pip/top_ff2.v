module top(clk, d, q, ce, sr);
  input clk, d, ce, sr;
  output [3:0] q;
  // 4 FFs with configurable INIT — base design INIT=0
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_aff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[0]));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_bff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[1]));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_cff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[2]));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_dff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[3]));
endmodule
