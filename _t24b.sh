export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t24b; mkdir -p $D; cd $D || exit 1
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
for k in $(seq 32 63); do
  HEX=$(printf "%016x" $((1 << k)))
  sed "s/@@INIT@@/$HEX/" base.v > build.v
  grep -q "$HEX" build.v || echo "SEDFAIL $k"
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source base.tcl > log_$k.txt 2>&1
  if grep -q "^DONE" log_$k.txt; then cp build.bit h$(printf "%02d" $k).bit; else echo "FAIL $k"; fi
done
tar czf /tmp/t24b.tgz h*.bit 2>/dev/null
echo "T24BDONE"; ls h*.bit | tail -3