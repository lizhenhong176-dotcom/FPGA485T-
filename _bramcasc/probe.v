module top(input clk);
  (* DONT_TOUCH = "true" *) RAMB18E1 #(.READ_WIDTH_A(1), .WRITE_WIDTH_A(1)) u_bram ();
endmodule