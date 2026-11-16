module top(clk, d, q, ce, sr);
  input clk, d, ce, sr;
  output [3:0] q;
  // u_aff: normal clock (NOCLKINV default) — baseline
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_aff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[0]));
  // u_bff: inverted clock → CLKINV active
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0), .IS_C_INVERTED(1'b1)) u_bff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[1]));
  // u_cff: normal clock — control (should match u_aff)
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_cff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[2]));
  // u_dff: normal clock — control
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_dff (.C(clk), .D(d), .CE(ce), .R(sr), .Q(q[3]));
endmodule
