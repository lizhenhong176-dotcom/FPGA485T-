module top(input clk, input d, output q);
  (* DONT_TOUCH = "yes" *) LD #(.INIT(1'b0)) u_ff
    (.G(clk), .D(d), .Q(q));
endmodule
