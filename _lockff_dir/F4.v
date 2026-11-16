module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDSE u_ff (.Q(q), .C(clk), .D(o_l), .CE(1'b1), .S(rst));
endmodule