module top(input clk, input [3:0] s, input [3:0] di, output q);
  wire [3:0] ob;
  (* DONT_TOUCH = "yes" *) CARRY4 u_c
    (.CI(1'b0), .CYINIT(1'b0), .DI(di), .S(s), .CO(), .O(ob));
  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(ob[0]), .CE(1'b1), .R(1'b0), .Q(q));
endmodule
