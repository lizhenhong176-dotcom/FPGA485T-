module top(input clk, input d, input ce, input r);
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(d), .CE(ce), .R(r), .Q());
endmodule
