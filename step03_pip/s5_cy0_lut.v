module top(input [3:0] p, input [3:0] di, output [3:0] o, output [3:0] co);
  wire o6a, o6b, o6c, o6d;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_la
    (.I0(p[0]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O(o6a));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_lb
    (.I0(p[1]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O(o6b));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_lc
    (.I0(p[2]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O(o6c));
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_ld
    (.I0(p[3]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O(o6d));
  (* DONT_TOUCH = "yes" *) CARRY4 u_c
    (.CI(1'b0), .CYINIT(1'b0), .DI(di), .S({o6d, o6c, o6b, o6a}), .CO(co), .O(o));
endmodule
