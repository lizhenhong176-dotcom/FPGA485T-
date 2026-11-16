export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/lockff
mkdir -p $D; cd $D || exit 1
build() {  # $1 tag  $2 verilog-body  $3 loc-lines
  TAG=$1
  cat > ${TAG}.v <<V
$2
V
  cat > ${TAG}.tcl <<T
read_verilog ./${TAG}.v
synth_design -top top -part xc7vx485tffg1761-2
$3
place_design
route_design
set c [get_cells -hier -filter {NAME =~ *lut*}]
foreach x \$c { puts "CHK ${TAG} [get_property NAME \$x] SITE=[get_property SITE \$x] BEL=[get_property BEL \$x] INIT=[get_property INIT \$x]" }
set f [get_cells -hier -filter {NAME =~ *ff*}]
foreach x \$f { puts "CHK ${TAG} [get_property NAME \$x] SITE=[get_property SITE \$x] BEL=[get_property BEL \$x] INIT=[get_property INIT \$x]" }
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./${TAG}.bit
puts "DONE_${TAG}"
T
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${TAG}.tcl > ${TAG}.log 2>&1
  if grep -q "DONE_${TAG}" ${TAG}.log; then echo "OK ${TAG}"; else echo "FAIL ${TAG}"; tail -4 ${TAG}.log; fi
}
build L4_k1 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000002)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L4_k2 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000004)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L4_k4 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000010)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L4_k8 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000100)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L4_k16 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000010000)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L4_k32 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000100000000)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L20_k1 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000002)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L20_k2 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000004)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L20_k4 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000010)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L20_k8 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000100)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L20_k16 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000010000)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build L20_k32 'module top(input a0,a1,a2,a3,a4,a5, output o);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000100000000)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign o = o_l;
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build F0 'module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.Q(q), .C(clk), .D(o_l), .CE(1'b1), .R(1'b0));
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build F1 'module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDRE #(.INIT(1'b1)) u_ff (.Q(q), .C(clk), .D(o_l), .CE(1'b1), .R(1'b0));
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build F2 'module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.Q(q), .C(clk), .D(o_l), .CE(ce), .R(1'b0));
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build F3 'module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDRE u_ff (.Q(q), .C(clk), .D(o_l), .CE(1'b1), .R(rst));
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build F4 'module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDSE u_ff (.Q(q), .C(clk), .D(o_l), .CE(1'b1), .S(rst));
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
build F5 'module top(input a0,a1,a2,a3,a4,a5,input clk,input ce,input rst, output q);
  wire o_l;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o_l), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDPE u_ff (.Q(q), .C(clk), .D(o_l), .CE(1'b1), .PRE(rst));
endmodule' 'set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]'
tar czf /tmp/lockff.tgz *.bit && echo LOCKFFDONE
