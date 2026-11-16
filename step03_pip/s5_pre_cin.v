module top(input [3:0] s, input [3:0] di, output [3:0] o, output [3:0] co, output [3:0] ol);
  wire [3:0] col;
  (* DONT_TOUCH = "yes" *) CARRY4 u_cl
    (.CI(1'b0), .CYINIT(1'b1), .DI(di), .S(s), .CO(col), .O(ol));
  (* DONT_TOUCH = "yes" *) CARRY4 u_c
    (.CI(col[3]), .DI(di), .S(s), .CO(co), .O(o));
endmodule
