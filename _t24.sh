export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t24; mkdir -p $D; cd $D || exit 1
cat > base.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h@@INIT@@)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > base.tcl <<'T'
read_verilog ./build.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X13Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./build.bit
puts "DONE"
T
n=0
for k in $(seq 0 63); do
  HEX=$(printf "%016x" $((1 << k)) 2>/dev/null)
  if [ "$k" -ge 32 ]; then HEX="0000000$(printf "%08x" $((1 << (k-32))))"; fi
  sed "s/@@INIT@@/$HEX/" base.v > build.v
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source base.tcl > log_$k.txt 2>&1
  if grep -q "^DONE" log_$k.txt; then cp build.bit s$(printf "%02d" $k).bit; n=$((n+1)); else echo "FAIL $k"; fi
done
sed "s/@@INIT@@/0000000000000000/" base.v > build.v
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source base.tcl > log_z.txt 2>&1
cp build.bit s_base.bit
tar czf /tmp/t24.tgz s*.bit 2>/dev/null
echo "T24DONE count=$n"
ls -l /tmp/t24.tgz