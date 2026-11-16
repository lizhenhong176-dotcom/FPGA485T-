set -e
export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/crcfull
rm -rf $D; mkdir -p $D; cd $D
cat > tpl.v <<'EOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h__INIT__)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
EOF
cat > tpl.tcl <<'EOF'
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
  Y=$1; BEL=$2; K=$3
  if [ "$K" = "base" ]; then TAG=base_y${Y}_${BEL}; INIT=0000000000000000;
  else TAG=y${Y}_${BEL}_k${K}; INIT=$(printf "%016x" $((1 << K))); fi
  sed -e "s/__INIT__/$INIT/" -e "s/__Y__/$Y/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" tpl.v > $TAG.v
  sed -e "s/__Y__/$Y/" -e "s/__BEL__/$BEL/" -e "s/__TAG__/$TAG/g" tpl.tcl > $TAG.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $TAG.tcl > $TAG.log 2>&1 || true
  if grep -q "DONE_$TAG" $TAG.log; then echo "OK $TAG"; else echo "FAIL $TAG"; fi
  rm -f $TAG.v $TAG.tcl $TAG.log
}
export -f one
{
for Y in $(seq 0 49); do echo "$Y A6LUT base"; done
for Y in $(seq 0 49); do for BEL in A6LUT B6LUT C6LUT D6LUT; do for K in $(seq 0 31); do echo "$Y $BEL $K"; done; done; done
} > jobs.txt
wc -l < jobs.txt
xargs -P 32 -L 1 bash -c 'one $0 $1 $2' < jobs.txt > run.log 2>&1 || true
echo "OK count: $(grep -c '^OK' run.log || true)"
echo "FAIL count: $(grep -c '^FAIL' run.log || true)"
grep '^FAIL' run.log | head -n 10 || true
tar czf /tmp/crcfull_out.tgz *.bit
ls *.bit | wc -l
echo CRCFULL_DONE
