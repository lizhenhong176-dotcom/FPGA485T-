set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull2
cd $D
cat > h_tpl.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h__INIT__)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > h_tpl.tcl <<'EOF'
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
  Y=$1; BEL=$2; K=$3; TAG=hz${Y}_${BEL}_k${K}
  INIT=$(printf "%016x" $((1 << K)))
  sed -e "s/__INIT__/$INIT/" -e "s/__Y__/$Y/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" h_tpl.v > $TAG.v
  sed -e "s/__Y__/$Y/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" h_tpl.tcl > $TAG.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $TAG.tcl > $TAG.log 2>&1 || true
  if grep -q "DONE_$TAG" $TAG.log; then echo "OK $TAG"; else echo "FAIL $TAG"; fi
  rm -f $TAG.v $TAG.tcl $TAG.log
}
export -f one
rm -f hjobs.txt
for Y in 20 30; do for BEL in A6LUT B6LUT C6LUT D6LUT; do for K in 1 3; do echo "$Y $BEL $K"; done; done; done > hjobs.txt
echo "HJOBS $(wc -l < hjobs.txt)"
xargs -P 16 -L 1 bash -c 'one $0 $1 $2' < hjobs.txt > hrun.log 2>&1 || true
echo "HOK $(grep -c '^OK' hrun.log || true)"
echo "HFAIL $(grep -c '^FAIL' hrun.log || true)"
echo HDONE
