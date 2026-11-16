set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e8
mkdir -p $D; cd $D || exit 1

gen_v() {  # $1=name  $2=setmask(hex) 鈥?bit i 缃綅鍒欑 i 涓?LUT 鐨?INIT=1
  name=$1; mask=$2
  { echo 'module top(input a0,a1,a2,a3,a4,a5, output dummy);'
    echo '  wire [49:0] o;'
    for i in $(seq 0 49); do
      if [ $(( (mask >> i) & 1 )) -eq 1 ]; then iv="64'h0000000000000001"; else iv="64'h0000000000000000"; fi
      echo "  (* DONT_TOUCH = \"true\" *) LUT6 #(.INIT($iv)) u$i (.O(o[$i]), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));"
    done
    echo '  assign dummy = ^o;'
    echo 'endmodule'; } > $name.v
}

gen_t() {  # $1=name
  name=$1
  { echo "read_verilog ./$name.v"
    echo "synth_design -top top -part xc7vx485tffg1157-3"
    for i in $(seq 0 49); do
      echo "set_property LOC SLICE_X12Y$i [get_cells u$i]"
      echo "set_property BEL C6LUT [get_cells u$i]"
      echo "set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u$i]"
    done
    echo "place_design"
    echo "route_design"
    echo "puts \"CHK_$name PART=[get_property PART [current_design]]\""
    echo "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]"
    echo "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]"
    echo "set_property CFGBVS VCCO [current_design]"
    echo "set_property CONFIG_VOLTAGE 3.3 [current_design]"
    echo "write_bitstream -force ./$name.bit"
    echo "puts \"DONE_$name\"" ; } > $name.tcl
}

# 鍋舵暟 Y锛?5 涓級锛?,2,4,...,48 -> bit 绱㈠紩 0,2,4.. 鐢?mask 鐨勫伓鏁颁綅
MASK_A=0
MASK_B=0
for i in $(seq 0 49); do
  if [ $(( i % 2 )) -eq 0 ]; then MASK_A=$(( MASK_A | (1 << i) )); else MASK_B=$(( MASK_B | (1 << i) )); fi
done

gen_v e8_base 0
gen_v e8_even $MASK_A
gen_v e8_odd  $MASK_B
gen_t e8_base; gen_t e8_even; gen_t e8_odd

export -f gen_v gen_t
runone() {
  n=$1
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $n.tcl > $n.log 2>&1
  if grep -q "DONE_$n" $n.log; then echo "OK $n"; else echo "FAIL $n"; tail -n 6 $n.log; fi
}
export -f runone
printf "e8_base\ne8_even\ne8_odd\n" | xargs -P 3 -I{} bash -c 'runone {}'

cat > diff_e8.py <<'PYEOF'
import json, struct, sys
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
a = fdraws("e8_base.bit")
res = {}
for t in ("e8_even", "e8_odd"):
    b = fdraws(t + ".bit"); content = []; ecc = {}
    for idx in range(min(len(a), len(b))):
        if a[idx] == b[idx]: continue
        fr, wd = idx // FW, idx % FW
        if wd == 50: ecc[fr] = b[idx]
        else:
            x = a[idx] ^ b[idx]
            for bit in range(32):
                if (x >> bit) & 1: content.append([fr, wd, bit])
    res[t] = {"content": content, "ecc": {str(k): v for k, v in ecc.items()}}
print("E8JSON_BEGIN")
print(json.dumps({"base_words": len(a), "items": res}))
print("E8JSON_END")
PYEOF

PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
echo E8DIFF_BEGIN
$PY diff_e8.py
echo E8DIFF_END
echo E8DONE
