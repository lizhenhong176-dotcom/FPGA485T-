export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/harden2
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
set_property LOC SLICE_X2Y3 [get_cells u0]
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
  if grep -q "DONE_${TAG}" ${TAG}.log; then gzip -9 -c ${TAG}.bit | base64 -w 0 > ${TAG}.bit.b64; grep "^CHK" ${TAG}.log | head -1; else echo "FAIL ${TAG}"; tail -5 ${TAG}.log; fi
}
build q0 0000000000000000
build q1 cb622cec2a1f2940
build q2 52fbb575b386b0d9
build q3 6ec789498fba8ce5
build q4 613786b9804a8315
build q5 61c879b980b57c15
build q6 61c886467f4a7c15
build qv 0123456789abcdef
echo QDONE
