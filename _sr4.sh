export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/single_r4
mkdir -p $D; cd $D || exit 1
build() {
  TAG=$1; INIT=$2
  cat > ${TAG}.v <<V
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h$INIT)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
  cat > ${TAG}.tcl <<T
read_verilog ./${TAG}.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y4 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
place_design
route_design
set c [get_cells u0]
puts "CHK ${TAG} SITE=[get_property SITE \$c] BEL=[get_property BEL \$c] INIT=[get_property INIT \$c]"
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
build s_base 0000000000000000
build s00 0000000000000001
build s01 0000000000000002
build s02 0000000000000004
build s03 0000000000000008
build s04 0000000000000010
build s05 0000000000000020
build s06 0000000000000040
build s07 0000000000000080
build s08 0000000000000100
build s09 0000000000000200
build s10 0000000000000400
build s11 0000000000000800
build s12 0000000000001000
build s13 0000000000002000
build s14 0000000000004000
build s15 0000000000008000
build s16 0000000000010000
build s17 0000000000020000
build s18 0000000000040000
build s19 0000000000080000
build s20 0000000000100000
build s21 0000000000200000
build s22 0000000000400000
build s23 0000000000800000
build s24 0000000001000000
build s25 0000000002000000
build s26 0000000004000000
build s27 0000000008000000
build s28 0000000010000000
build s29 0000000020000000
build s30 0000000040000000
build s31 0000000080000000
build s32 0000000100000000
build s33 0000000200000000
build s34 0000000400000000
build s35 0000000800000000
build s36 0000001000000000
build s37 0000002000000000
build s38 0000004000000000
build s39 0000008000000000
build s40 0000010000000000
build s41 0000020000000000
build s42 0000040000000000
build s43 0000080000000000
build s44 0000100000000000
build s45 0000200000000000
build s46 0000400000000000
build s47 0000800000000000
build s48 0001000000000000
build s49 0002000000000000
build s50 0004000000000000
build s51 0008000000000000
build s52 0010000000000000
build s53 0020000000000000
build s54 0040000000000000
build s55 0080000000000000
build s56 0100000000000000
build s57 0200000000000000
build s58 0400000000000000
build s59 0800000000000000
build s60 1000000000000000
build s61 2000000000000000
build s62 4000000000000000
build s63 8000000000000000
tar czf /tmp/sr4.tgz s_base.bit s[0-9][0-9].bit && echo SR4DONE
