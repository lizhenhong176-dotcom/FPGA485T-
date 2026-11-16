module top(input [3:0] s, input [3:0] di, output o);
  wire [3:0] ob;
  (* DONT_TOUCH = "yes" *) CARRY4 u_c
    (.CI(1'b0), .CYINIT(1'b0), .DI(di), .S(s), .CO(), .O(ob));
  assign o = ob[0];
endmodule
