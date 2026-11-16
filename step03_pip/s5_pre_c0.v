module top(input [3:0] s, input [3:0] di, output [3:0] o, output [3:0] co);
  (* DONT_TOUCH = "yes" *) CARRY4 u_c
    (.CI(1'b0), .CYINIT(1'b0), .DI(di), .S(s), .CO(co), .O(o));
endmodule
