export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/initsweep
mkdir -p $D; cd $D || exit 1

# LUT 模板（8 个 LUT，全部 INIT=0）
cat > base8.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l0 (.O(o0), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l1 (.O(o1), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l2 (.O(o2), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l3 (.O(o3), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l4 (.O(o4), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l5 (.O(o5), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l6 (.O(o6), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) l7 (.O(o7), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V

mk_tcl() {  # $1=名字 $2=verilog
  cat > $1.tcl <<T
read_verilog ./$2
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y20 [get_cells l0]
set_property BEL A6LUT [get_cells l0]
set_property LOC SLICE_X12Y20 [get_cells l1]
set_property BEL B6LUT [get_cells l1]
set_property LOC SLICE_X12Y20 [get_cells l2]
set_property BEL C6LUT [get_cells l2]
set_property LOC SLICE_X12Y20 [get_cells l3]
set_property BEL D6LUT [get_cells l3]
set_property LOC SLICE_X13Y20 [get_cells l4]
set_property BEL A6LUT [get_cells l4]
set_property LOC SLICE_X13Y20 [get_cells l5]
set_property BEL B6LUT [get_cells l5]
set_property LOC SLICE_X13Y20 [get_cells l6]
set_property BEL C6LUT [get_cells l6]
set_property LOC SLICE_X13Y20 [get_cells l7]
set_property BEL D6LUT [get_cells l7]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./$1.bit
puts "DONE_$1"
T
}

# 基线
cp base8.v b0.v
mk_tcl b0 b0.v
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source b0.tcl > b0.log 2>&1
grep -q DONE_b0 b0.log && gzip -9 -c b0.bit | base64 -w 0 > b0.bit.b64 && echo "BASE OK $(stat -c %s b0.bit.b64)" || { echo "BASE FAIL"; tail -8 b0.log; exit 1; }

# 8 个 LUT × 6 个位平面
for j in 0 1 2 3 4 5 6 7; do
  for k in 0 1 2 3 4 5; do
    /opt/lzh/venv/bin/python - "$j" "$k" <<'PY'
import sys
j, k = int(sys.argv[1]), int(sys.argv[2])
plane = 0
for i in range(64):
    if (i >> k) & 1: plane |= 1 << i
src = open("base8.v").read()
lines = src.split("\n")
lut_lines = [n for n, L in enumerate(lines) if "l%d (" % j in L]
assert len(lut_lines) == 1, lut_lines
n = lut_lines[0]
old = "64'h0000000000000000"
assert old in lines[n]
lines[n] = lines[n].replace(old, "64'h%016x" % plane)
open("j%d_k%d.v" % (j, k), "w").write("\n".join(lines))
PY
    mk_tcl j${j}_k${k} j${j}_k${k}.v
    /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source j${j}_k${k}.tcl > j${j}_k${k}.log 2>&1
    if grep -q "DONE_j${j}_k${k}" j${j}_k${k}.log; then
      gzip -9 -c j${j}_k${k}.bit | base64 -w 0 > j${j}_k${k}.bit.b64
      echo "OK j=$j k=$k $(stat -c %s j${j}_k${k}.bit.b64)"
    else
      echo "FAIL j=$j k=$k"; tail -5 j${j}_k${k}.log
    fi
  done
done
echo "ALL_DONE"