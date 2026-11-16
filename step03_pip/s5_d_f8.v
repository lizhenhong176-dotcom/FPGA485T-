function [0:0] f1(input [5:0] x);
  case (x)
    6'b000000: f1=1; 6'b000001: f1=0; 6'b000010: f1=0; 6'b000011: f1=1;
    6'b000100: f1=1; 6'b000101: f1=1; 6'b000110: f1=0; 6'b000111: f1=0;
    6'b001000: f1=0; 6'b001001: f1=1; 6'b001010: f1=1; 6'b001011: f1=0;
    6'b001100: f1=1; 6'b001101: f1=0; 6'b001110: f1=0; 6'b001111: f1=1;
    default: f1 = x[0] ^ x[2] ^ x[3] ^ x[5];
  endcase
endfunction
function [0:0] f2(input [5:0] x);
  case (x)
    6'b000000: f2=0; 6'b000001: f2=1; 6'b000010: f2=1; 6'b000011: f2=0;
    default: f2 = x[1] ^ x[2] ^ x[4];
  endcase
endfunction
function [0:0] f3(input [5:0] x);
  case (x)
    6'b000000: f3=1; 6'b000001: f3=1; 6'b000010: f3=1; 6'b000011: f3=0;
    default: f3 = x[0] ^ x[1] ^ x[3] ^ x[4] ^ x[5];
  endcase
endfunction
function [0:0] f4(input [5:0] x);
  case (x)
    6'b000000: f4=1; 6'b000001: f4=0; 6'b000010: f4=1; 6'b000011: f4=1;
    default: f4 = x[1] ^ x[3] ^ x[5];
  endcase
endfunction

module top(input [7:0] i, output o);
  wire a = f1(i[5:0]);
  wire b = f2(i[5:0]);
  wire c = f3(i[5:0]);
  wire d = f4(i[5:0]);
  assign o = i[7] ? (i[6] ? a : b) : (i[6] ? c : d);
endmodule
