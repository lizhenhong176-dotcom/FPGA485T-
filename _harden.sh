export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/harden
mkdir -p $D; cd $D || exit 1
build() {  # $1 row $2 tag $3 init
  R=$1; TAG=$2; INIT=$3
  cat > ${TAG}.v <<V
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h$INIT)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
  cat > ${TAG}.tcl <<T
read_verilog ./${TAG}.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X2Y${R} [get_cells u0]
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
  if grep -q "DONE_${TAG}" ${TAG}.log; then
    gzip -9 -c ${TAG}.bit | base64 -w 0 > ${TAG}.bit.b64
    grep "^CHK" ${TAG}.log | head -2
  else echo "FAIL ${TAG}"; tail -6 ${TAG}.log; fi
}
build 3 h0 0000000000000000
build 3 h1 5555555555555555
build 3 h2 cccccccccccccccc
build 3 h3 f0f0f0f0f0f0f0f0
build 3 h4 ff00ff00ff00ff00
build 3 h5 ffff0000ffff0000
build 3 h6 ffffffff00000000
build 3 h7 0000000000000001
build 3 hv a5a5f0f01234abcd
echo HARDENDONE