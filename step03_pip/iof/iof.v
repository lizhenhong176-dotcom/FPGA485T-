(* DONT_TOUCH = "true" *)
module top (input wire din, output wire p);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h9E3779B97F4A7C15)) u_l (.I0(din),.I1(1'b0),.I2(1'b0),.I3(1'b0),.I4(1'b0),.I5(1'b0),.O(p));
endmodule
