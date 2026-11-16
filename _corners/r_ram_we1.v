module top(input a, b, c, d, clk, we, output o);
  (* DONT_TOUCH = "true" *) wire [1:0] doa, dob, doc, dod;
  wire [4:0] ad = {a,b,c,d,1'b0};
  RAM32M #(.INIT_A(64'h0), .INIT_B(64'h0), .INIT_C(64'h0), .INIT_D(64'h0)) u_ram (
    .DOA(doa), .DOB(dob), .DOC(doc), .DOD(dod),
    .ADDRA(ad), .ADDRB(ad), .ADDRC(ad), .ADDRD(ad),
    .DIA({a,b}), .DIB({b,c}), .DIC({c,d}), .DID({d,a}),
    .WCLK(clk), .WE(1'b1));
  assign o = doa[0] ^ dob[1];
endmodule
