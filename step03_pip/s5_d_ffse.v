module top(input clk, input d, input ce, input s);
  (* DONT_TOUCH = "yes" *) FDSE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(d), .CE(ce), .S(s), .Q());
endmodule
