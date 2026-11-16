module top(clk, d, q);
  input clk;
  input d;
  output [3:0] q;
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_aff (.C(clk), .D(d), .CE(1'b1), .R(1'b0), .Q(q[0]));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_bff (.C(clk), .D(d), .CE(1'b1), .R(1'b0), .Q(q[1]));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_cff (.C(clk), .D(d), .CE(1'b1), .R(1'b0), .Q(q[2]));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_dff (.C(clk), .D(d), .CE(1'b1), .R(1'b0), .Q(q[3]));
endmodule
