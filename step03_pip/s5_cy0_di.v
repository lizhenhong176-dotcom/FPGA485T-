module top(input [3:0] p, input [3:0] s, output [3:0] o, output [3:0] co);
  wire [3:0] di_l;
  (* DONT_TOUCH = "yes" *) LUT6_2 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_la
    (.I0(p[0]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O5(di_l[0]), .O6());
  (* DONT_TOUCH = "yes" *) LUT6_2 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_lb
    (.I0(p[1]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O5(di_l[1]), .O6());
  (* DONT_TOUCH = "yes" *) LUT6_2 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_lc
    (.I0(p[2]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O5(di_l[2]), .O6());
  (* DONT_TOUCH = "yes" *) LUT6_2 #(.INIT(64'hAAAAAAAAAAAAAAAA)) u_ld
    (.I0(p[3]), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0), .O5(di_l[3]), .O6());
  (* DONT_TOUCH = "yes" *) CARRY4 u_c
    (.CI(1'b0), .CYINIT(1'b0), .DI(di_l), .S(s), .CO(co), .O(o));
endmodule
