export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clbll
mkdir -p "$D"; cd "$D" || exit 1
gen() {  # $1 tag $2 hex
  cat > $1.v <<V
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h$2)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
  cat > $1.tcl <<T
read_verilog ./$1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X8Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
puts "CHK $1 SITE=[get_property SITE [get_cells u0]] BEL=[get_property BEL [get_cells u0]] INIT=[get_property INIT [get_cells u0]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./$1.bit
puts "DONE_$1"
T
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $1.tcl > $1.log 2>&1
  if grep -q "DONE_$1" $1.log; then echo "OK $1"; else echo "FAIL $1"; fi
}
export -f gen 2>/dev/null || true
gen b00 0000000000000000
for k in $(seq 0 63); do
  HEX=$(printf "%016x" $((1 << k)))
  [ ${#HEX} -eq 16 ] || { echo "HEXLENFAIL $k"; continue; }
  echo "build s$(printf %02d $k) $HEX"
done > jobs.txt
i=0
while read -r _ tag hex; do
  [ -z "$tag" ] && continue
  gen "$tag" "$hex" &
  i=$((i+1))
  if [ $((i % 32)) -eq 0 ]; then wait; fi
done < jobs.txt
wait
tar czf /tmp/clbll.tgz *.bit 2>/dev/null
echo "CLBLL_DONE $(ls *.bit | wc -l) bits"