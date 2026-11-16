module top(input clk, input [5:0] a, output [3:0] o, output q1, q2, q3, q4);
  (* DONT_TOUCH *) wire w1,w2,w3,w4;
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h1111111111111111)) L1 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w1));
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h2222222222222222)) L2 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w2));
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h3333333333333333)) L3 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w3));
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h4444444444444444)) L4 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w4));
  (* DONT_TOUCH *) FDRE F1(.Q(q1),.C(clk),.CE(1'b1),.R(1'b0),.D(w1));
  (* DONT_TOUCH *) FDRE F2(.Q(q2),.C(clk),.CE(1'b1),.R(1'b0),.D(w2));
  (* DONT_TOUCH *) FDRE F3(.Q(q3),.C(clk),.CE(1'b1),.R(1'b0),.D(w3));
  (* DONT_TOUCH *) FDRE F4(.Q(q4),.C(clk),.CE(1'b1),.R(1'b0),.D(w4));
  assign o = {w1,w2,w3,w4};
endmodule
