export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/ysweep
mkdir -p $D; cd $D || exit 1
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
PY=/opt/lzh/venv/bin/python

# 基线：无逻辑
mkdir -p base
cat > base/top.v <<'V'
module top(output o);
  assign o = 1'b0;
endmodule
V
cat > base/b.tcl <<'T'
read_verilog ./top.v
synth_design -top top -part xc7vx485tffg1761-2
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./top.bit
puts "OK base"
T
( cd base && $VIV -mode batch -notrace -source b.tcl > b.log 2>&1 )
grep -q "OK base" base/b.log && echo "baseline ok" || { echo "baseline FAIL"; tail -5 base/b.log; exit 1; }

for inst in 0 1; do
  for r in $(seq 0 49); do
    sx=$((8 + inst))
    d=$D/w_${inst}_${r}
    mkdir -p $d
    cat > $d/top.v <<V
module top(output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) lut
    (.O(o), .I0(1'b0), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
V
    cat > $d/b.tcl <<T
read_verilog ./top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X${sx}Y${r} [get_cells lut]
set_property BEL A6LUT [get_cells lut]
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./top.bit
puts "OK ${inst} ${r}"
T
    ( cd $d && $VIV -mode batch -notrace -source b.tcl > b.log 2>&1 )
    if grep -q "OK ${inst} ${r}" $d/b.log; then echo "built ${inst} ${r}"; else echo "FAIL ${inst} ${r}"; fi
  done
done
echo "=== build done ==="
ls $D/w_0_* -d | wc -l