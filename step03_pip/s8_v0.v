module top(
    input  wire [5:0] i,
    input  wire clk,
    input  wire ce,
    input  wire rst,
    output wire o,
    output wire o2,
    output wire o3
);
    wire lo6;
    (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h9E3779B97F4A7C15)) u_l (
        .I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]),
        .O(lo6));
    (* DONT_TOUCH = "true" *) FDRE #(.INIT(1'b0)) u_f (
        .C(clk), .D(lo6), .CE(ce), .R(rst), .Q(o2));    assign o  = lo6;
    assign o3 = i[0] & i[5];  // extra small logic
endmodule
