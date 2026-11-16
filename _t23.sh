export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t23; mkdir -p $D; cd $D || exit 1
mk() {
  TAG=$1; INIT=$2
  cat > ${TAG}.v <<V
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h${INIT})) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
  cat > ${TAG}.tcl <<T
read_verilog ./${TAG}.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X13Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set s [get_property SITE [get_cells u0]]
set be [get_property BEL [get_cells u0]]
puts "CHK $TAG SITE=$s BEL=$be"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./${TAG}.bit
puts "DONE_${TAG}"
T
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${TAG}.tcl > ${TAG}.log 2>&1
  if grep -q "DONE_${TAG}" ${TAG}.log; then grep "^CHK" ${TAG}.log; echo "OK ${TAG}"; else echo "FAIL ${TAG}"; tail -8 ${TAG}.log; fi
}
mk p0 0000000000000000
mk p1 5555555555555555
mk p2 cccccccccccccccc
mk p3 f0f0f0f0f0f0f0f0
mk p4 ff00ff00ff00ff00
mk p5 ffff0000ffff0000
mk p6 ffffffff00000000
mk z1 0000000000000001
mk vv a5a5f0f01234abcd
tar czf /tmp/t23.tgz *.bit 2>/dev/null; ls -l /tmp/t23.tgz
echo T23DONE