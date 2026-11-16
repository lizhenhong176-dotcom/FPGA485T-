export LANG=C LC_ALL=C
set -e
WH=/opt/lzh/v7re/work/word50
mkdir -p $WH
cd $WH

mk() {  # $1 = name, $2 = verilog body, $3 = extra tcl constraints
  d=$WH/$1
  mkdir -p $d
  printf '%s\n' "$2" > $d/top.v
  cat > $d/$1.tcl <<EOF
read_verilog $d/top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X10Y10 [get_cells lut]
$3
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force $d/top.bit
puts "BITSTREAM_OK $1"
EOF
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $d/$1.tcl > $d/build.log 2>&1
  grep -q "BITSTREAM_OK $1" $d/build.log && echo "OK $1 $(stat -c %s $d/top.bit)" || { echo "FAIL $1"; tail -20 $d/build.log; }
}

LUT='(* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'"'"'h0000000000000001)) lut (.O(o), .I0(a0), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5));'

mk e0 "module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst,output wire b);
  wire o;
  $LUT
  assign b = o;
endmodule" "set_property LOC SLICE_X10Y10 [get_cells lut]"

mk e1 "module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst,output wire b);
  wire o;
  $LUT
  (* DONT_TOUCH = \"true\" *) FDRE ff (.Q(b), .C(clk), .CE(1'b1), .R(1'b0), .D(o));
endmodule" "set_property LOC SLICE_X10Y10 [get_cells {lut ff}]"

mk e2 "module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst,output wire b);
  wire o;
  $LUT
  (* DONT_TOUCH = \"true\" *) FDRE ff (.Q(b), .C(clk), .CE(ce), .R(1'b0), .D(o));
endmodule" "set_property LOC SLICE_X10Y10 [get_cells {lut ff}]"

mk e3 "module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst,output wire b);
  wire o;
  $LUT
  (* DONT_TOUCH = \"true\" *) FDRE ff (.Q(b), .C(clk), .CE(1'b1), .R(rst), .D(o));
endmodule" "set_property LOC SLICE_X10Y10 [get_cells {lut ff}]"

mk e4 "module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst,output wire b);
  wire o;
  $LUT
  (* DONT_TOUCH = \"true\" *) FDSE ff (.Q(b), .C(clk), .CE(1'b1), .S(rst), .D(o));
endmodule" "set_property LOC SLICE_X10Y10 [get_cells {lut ff}]"

mk e5 "module top(input a0,a1,a2,a3,a4,a5,input clk,input clk2,input ce,input rst,output wire b);
  wire o;
  $LUT
  (* DONT_TOUCH = \"true\" *) FDRE ff (.Q(b), .C(clk2), .CE(1'b1), .R(1'b0), .D(o));
endmodule" "set_property LOC SLICE_X10Y10 [get_cells {lut ff}]"

echo "=== all done ==="
ls -l $WH/*/top.bit
