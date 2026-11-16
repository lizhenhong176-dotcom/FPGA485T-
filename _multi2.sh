export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/multi2
mkdir -p $D; cd $D || exit 1
cat > base.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output [15:0] o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_0_A (.O(o_u_4_0_A), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_0_B (.O(o_u_4_0_B), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_0_C (.O(o_u_4_0_C), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_0_D (.O(o_u_4_0_D), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_1_A (.O(o_u_4_1_A), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_1_B (.O(o_u_4_1_B), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_1_C (.O(o_u_4_1_C), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_4_1_D (.O(o_u_4_1_D), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_0_A (.O(o_u_8_0_A), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_0_B (.O(o_u_8_0_B), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_0_C (.O(o_u_8_0_C), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_0_D (.O(o_u_8_0_D), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_1_A (.O(o_u_8_1_A), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_1_B (.O(o_u_8_1_B), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_1_C (.O(o_u_8_1_C), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u_8_1_D (.O(o_u_8_1_D), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule

V
cat > base.tcl <<'T'
read_verilog ./m.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y4 [get_cells u_4_0_A]
set_property BEL A6LUT [get_cells u_4_0_A]
set_property LOC SLICE_X12Y4 [get_cells u_4_0_B]
set_property BEL B6LUT [get_cells u_4_0_B]
set_property LOC SLICE_X12Y4 [get_cells u_4_0_C]
set_property BEL C6LUT [get_cells u_4_0_C]
set_property LOC SLICE_X12Y4 [get_cells u_4_0_D]
set_property BEL D6LUT [get_cells u_4_0_D]
set_property LOC SLICE_X13Y4 [get_cells u_4_1_A]
set_property BEL A6LUT [get_cells u_4_1_A]
set_property LOC SLICE_X13Y4 [get_cells u_4_1_B]
set_property BEL B6LUT [get_cells u_4_1_B]
set_property LOC SLICE_X13Y4 [get_cells u_4_1_C]
set_property BEL C6LUT [get_cells u_4_1_C]
set_property LOC SLICE_X13Y4 [get_cells u_4_1_D]
set_property BEL D6LUT [get_cells u_4_1_D]
set_property LOC SLICE_X12Y8 [get_cells u_8_0_A]
set_property BEL A6LUT [get_cells u_8_0_A]
set_property LOC SLICE_X12Y8 [get_cells u_8_0_B]
set_property BEL B6LUT [get_cells u_8_0_B]
set_property LOC SLICE_X12Y8 [get_cells u_8_0_C]
set_property BEL C6LUT [get_cells u_8_0_C]
set_property LOC SLICE_X12Y8 [get_cells u_8_0_D]
set_property BEL D6LUT [get_cells u_8_0_D]
set_property LOC SLICE_X13Y8 [get_cells u_8_1_A]
set_property BEL A6LUT [get_cells u_8_1_A]
set_property LOC SLICE_X13Y8 [get_cells u_8_1_B]
set_property BEL B6LUT [get_cells u_8_1_B]
set_property LOC SLICE_X13Y8 [get_cells u_8_1_C]
set_property BEL C6LUT [get_cells u_8_1_C]
set_property LOC SLICE_X13Y8 [get_cells u_8_1_D]
set_property BEL D6LUT [get_cells u_8_1_D]
place_design
route_design
set chk ""
foreach c [get_cells -hier -filter {NAME =~ u_*}] { append chk "[get_property NAME $c]:[get_property SITE $c]/[get_property BEL $c] " }
puts "CHK $chk"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./m.bit
puts "DONE_M"

T
build() {
  TAG=$1; INIT=$2
  sed "s/@@INIT@@/$INIT/" base.v > ${TAG}.v
  sed "s#./m.v#./${TAG}.v#; s#./m.bit#./${TAG}.bit#" base.tcl > ${TAG}.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${TAG}.tcl > ${TAG}.log 2>&1
  if grep -q DONE_M ${TAG}.log; then echo "OK ${TAG} $(grep -c CHK ${TAG}.log)"; else echo "FAIL ${TAG}"; tail -4 ${TAG}.log; fi
}
build m_base 0000000000000000
build m00 0000000000000001
build m01 0000000000000002
build m02 0000000000000004
build m03 0000000000000008
build m04 0000000000000010
build m05 0000000000000020
build m06 0000000000000040
build m07 0000000000000080
build m08 0000000000000100
build m09 0000000000000200
build m10 0000000000000400
build m11 0000000000000800
build m12 0000000000001000
build m13 0000000000002000
build m14 0000000000004000
build m15 0000000000008000
build m16 0000000000010000
build m17 0000000000020000
build m18 0000000000040000
build m19 0000000000080000
build m20 0000000000100000
build m21 0000000000200000
build m22 0000000000400000
build m23 0000000000800000
build m24 0000000001000000
build m25 0000000002000000
build m26 0000000004000000
build m27 0000000008000000
build m28 0000000010000000
build m29 0000000020000000
build m30 0000000040000000
build m31 0000000080000000
build m32 0000000100000000
build m33 0000000200000000
build m34 0000000400000000
build m35 0000000800000000
build m36 0000001000000000
build m37 0000002000000000
build m38 0000004000000000
build m39 0000008000000000
build m40 0000010000000000
build m41 0000020000000000
build m42 0000040000000000
build m43 0000080000000000
build m44 0000100000000000
build m45 0000200000000000
build m46 0000400000000000
build m47 0000800000000000
build m48 0001000000000000
build m49 0002000000000000
build m50 0004000000000000
build m51 0008000000000000
build m52 0010000000000000
build m53 0020000000000000
build m54 0040000000000000
build m55 0080000000000000
build m56 0100000000000000
build m57 0200000000000000
build m58 0400000000000000
build m59 0800000000000000
build m60 1000000000000000
build m61 2000000000000000
build m62 4000000000000000
build m63 8000000000000000
tar czf /tmp/multi2.tgz m_base.bit m[0-9][0-9].bit && echo M2DONE && stat -c %s /tmp/multi2.tgz
