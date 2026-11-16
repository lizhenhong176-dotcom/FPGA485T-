set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull2
cd $D
cat > w_tpl.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h__INIT__)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > w_tpl.tcl <<'EOF'
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
  BEL=$1; K=$2; TAG=w41_${BEL}_k${K}
  INIT=$(printf "%016x" $((1 << K)))
  sed -e "s/__INIT__/$INIT/" -e "s/__Y__/20/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" w_tpl.v > $TAG.v
  sed -e "s/__Y__/20/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" w_tpl.tcl > $TAG.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $TAG.tcl > $TAG.log 2>&1 || true
  if grep -q "DONE_$TAG" $TAG.log; then echo "OK $TAG"; else echo "FAIL $TAG"; fi
  rm -f $TAG.v $TAG.tcl $TAG.log
}
export -f one
rm -f wjobs.txt
for BEL in C6LUT D6LUT; do
  for K in 0 2 4 6 16 18 20 22 32 34 36 38 48 50 52 54; do echo "$BEL $K"; done
  for K in 1 3 5 7 17 19 21 23 33 35 37 39 49 51 53 55; do echo "$BEL $K"; done
done > wjobs.txt
echo "WJOBS $(wc -l < wjobs.txt)"
xargs -P 32 -L 1 bash -c 'one $0 $1' < wjobs.txt > wrun.log 2>&1 || true
echo "WOK $(grep -c '^OK' wrun.log || true)"
echo "WFAIL $(grep -c '^FAIL' wrun.log || true)"
grep '^FAIL' wrun.log | head -n 5 || true
echo WDONE
