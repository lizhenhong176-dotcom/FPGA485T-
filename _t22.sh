export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t22; mkdir -p $D; cd $D || exit 1
mk() {
  TAG=$1; SL=$2; INIT=$3
  cat > ${TAG}.v <<V
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h${INIT})) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
  cat > ${TAG}.tcl <<T
read_verilog ./${TAG}.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC ${SL} [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set c_site [get_property SITE [get_cells u0]]
set c_bel  [get_property BEL  [get_cells u0]]
set c_init [get_property INIT [get_cells u0]]
puts "CHK $TAG SITE=$c_site BEL=$c_bel INIT=$c_init"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./${TAG}.bit
puts "DONE_${TAG}"
T
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source ${TAG}.tcl > ${TAG}.log 2>&1
  if grep -q "DONE_${TAG}" ${TAG}.log; then grep "^CHK" ${TAG}.log; echo "OK ${TAG} $(stat -c %s ${TAG}.bit)"; else echo "FAIL ${TAG}"; tail -8 ${TAG}.log; fi
}
mk x1z SLICE_X13Y20 0000000000000000
mk x1v SLICE_X13Y20 deadbeefcafebabe
tar czf /tmp/t22.tgz *.bit 2>/dev/null; ls -l /tmp/t22.tgz
echo T22DONE