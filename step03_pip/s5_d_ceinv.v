module top(input clk, input d, input ce, output q);
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(d), .CE(~ce), .R(1'b0), .Q(q));
endmodule
