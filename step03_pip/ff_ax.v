module top(input clk, input d, input [6:0] i, output q);
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(d), .Q(q), .CE(1'b1), .R(1'b0));
endmodule
