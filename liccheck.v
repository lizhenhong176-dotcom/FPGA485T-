module top(
    input  wire clk,
    output reg  [3:0] q
);
    always @(posedge clk)
        q <= q + 1'b1;
endmodule
