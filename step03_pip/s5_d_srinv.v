module top(input clk, input d, input r, output q);
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(d), .CE(1'b1), .R(~r), .Q(q));
endmodule
