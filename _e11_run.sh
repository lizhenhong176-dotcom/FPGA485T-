set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e11
mkdir -p $D; cd $D || exit 1

COLS="1 2 3 4 6 7 8 9 10 12 13 15 16 17 18 19 21 22 24 25 27 28 30 31 34"
YBASE=25

gen() {  # $1=name  $2=set(0/1) —— base 与 variant 的 LOC 完全相同，只改 INIT
  name=$1; set=$2
  if [ "$set" = "1" ]; then iv="64'h0000000000000001"; else iv="64'h0000000000000000"; fi
  { echo 'module top(input a0,a1,a2,a3,a4,a5, output dummy);'
    echo '  wire [24:0] o;'
    i=0
    for c in $COLS; do
      echo "  (* DONT_TOUCH = \"true\" *) LUT6 #(.INIT($iv)) u$i (.O(o[$i]), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));"
      i=$(( i + 1 ))
    done
    echo '  assign dummy = ^o;'
    echo 'endmodule'; } > $name.v
  { echo "read_verilog ./$name.v"
    echo "synth_design -top top -part xc7vx485tffg1157-3"
    i=0
    for c in $COLS; do
      y=$(( YBASE + i ))
      echo "set_property LOC SLICE_X${c}Y${y} [get_cells u$i]"
      echo "set_property BEL C6LUT [get_cells u$i]"
      echo "set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u$i]"
      i=$(( i + 1 ))
    done
    echo "place_design"
    echo "route_design"
    echo "puts \"CHK_$name PART=[get_property PART [current_design]]\""
    echo "puts \"NUMSITES [llength [get_cells -hier -filter {NAME =~ u*}]]\""
    echo "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]"
    echo "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]"
    echo "set_property CFGBVS VCCO [current_design]"
    echo "set_property CONFIG_VOLTAGE 3.3 [current_design]"
    echo "write_bitstream -force ./$name.bit"
    echo "puts \"DONE_$name\"" ; } > $name.tcl
}

gen e11_base 0
gen e11_var 1

runone() {
  n=$1
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $n.tcl > $n.log 2>&1
  if grep -q "DONE_$n" $n.log; then echo "OK $n"; else echo "FAIL $n"; tail -n 6 $n.log; fi
}
export -f runone
printf "e11_base\ne11_var\n" | xargs -P 2 -I{} bash -c 'runone {}'

cat > diff_e11.py <<'PYEOF'
import json, struct
SYNC = b"\xaa\x99\x55\x66"; FW = 101
def fdraws(path):
    raw = open(path, "rb").read(); i = raw.find(SYNC)
    n = (len(raw) - i - 4) // 4
    w = struct.unpack(">%dI" % n, raw[i+4:i+4+n*4]); out = []; k = 0
    while k < n:
        h = w[k]; typ = (h >> 29) & 7; op = (h >> 27) & 3; cnt = h & 0x7FF; k += 1
        if typ == 2:
            c = h & 0x7FFFFFF; out.extend(w[k:k+c]); k += c; continue
        if typ != 1: continue
        if op == 2 and cnt: k += cnt
        elif op == 1: k += 1
    return out
a = fdraws("e11_base.bit")
b = fdraws("e11_var.bit")
content = []; ecc = {}
for idx in range(min(len(a), len(b))):
    if a[idx] == b[idx]: continue
    fr, wd = idx // FW, idx % FW
    if wd == 50: ecc[fr] = b[idx]
    else:
        x = a[idx] ^ b[idx]
        for bit in range(32):
            if (x >> bit) & 1: content.append([fr, wd, bit])
print("E11JSON_BEGIN")
print(json.dumps({"base_words": len(a), "content": content, "ecc": {str(k): v for k, v in ecc.items()}}))
print("E11JSON_END")
PYEOF
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
echo E11DIFF_BEGIN
$PY diff_e11.py
echo E11DIFF_END
echo E11DONE
