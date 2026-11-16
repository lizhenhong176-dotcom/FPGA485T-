set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull2
cd $D
cat > b_tpl.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > b_tpl.tcl <<'EOF'
read_verilog ./__TAG__.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y__Y__ [get_cells u0]
set_property BEL __BEL__ [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./__TAG__.bit
puts "DONE___TAG__"
EOF
one() {
  Y=$1; BEL=$2; TAG=base_y${Y}_${BEL}
  [ -f $TAG.bit ] && { echo "SKIP $TAG"; return; }
  sed -e "s/__Y__/$Y/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" b_tpl.v > $TAG.v
  sed -e "s/__Y__/$Y/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" b_tpl.tcl > $TAG.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $TAG.tcl > $TAG.log 2>&1 || true
  if grep -q "DONE_$TAG" $TAG.log; then echo "OK $TAG"; else echo "FAIL $TAG"; fi
  rm -f $TAG.v $TAG.tcl $TAG.log
}
export -f one
for Y in $(seq 0 49); do for BEL in A6LUT B6LUT C6LUT D6LUT; do echo "$Y $BEL"; done; done > bjobs.txt
echo "BJOBS $(wc -l < bjobs.txt)"
xargs -P 30 -L 1 bash -c 'one $0 $1' < bjobs.txt > brun.log 2>&1 || true
echo "BOK $(grep -c '^OK' brun.log || true)"
echo "BFAIL $(grep -c '^FAIL' brun.log || true)"
grep '^FAIL' brun.log | head -n 5 || true
echo BASEDONE
