set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e10
mkdir -p $D; cd $D || exit 1

gen() {  # $1=name $2=init_y0 $3=init_y20
  name=$1; i0=$2; i20=$3
  [ "$i0" = 1 ] && a="64'h0000000000000001" || a="64'h0000000000000000"
  [ "$i20" = 1 ] && b="64'h0000000000000001" || b="64'h0000000000000000"
  cat > $name.v <<VEOF
module top(input a0,a1,a2,a3,a4,a5, output dummy);
  wire [1:0] o;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT($a)) u0 (.O(o[0]), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT($b)) u1 (.O(o[1]), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  assign dummy = ^o;
endmodule
VEOF
  cat > $name.tcl <<TEOF
read_verilog ./$name.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X20Y0 [get_cells u0]
set_property BEL C6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
set_property LOC SLICE_X20Y20 [get_cells u1]
set_property BEL C6LUT [get_cells u1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u1]
place_design
route_design
puts "CHK_$name PART=[get_property PART [current_design]]"
puts "S0 [get_property SITE [get_cells u0]] INIT=[get_property INIT [get_cells u0]]"
puts "S1 [get_property SITE [get_cells u1]] INIT=[get_property INIT [get_cells u1]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./$name.bit
puts "DONE_$name"
TEOF
}

gen e10_base 0 0
gen e10_w1 1 0
gen e10_w41 0 1

runone() {
  n=$1
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $n.tcl > $n.log 2>&1
  if grep -q "DONE_$n" $n.log; then echo "OK $n"; else echo "FAIL $n"; tail -n 6 $n.log; fi
}
export -f runone
printf "e10_base\ne10_w1\ne10_w41\n" | xargs -P 3 -I{} bash -c 'runone {}'

cat > diff_e10.py <<'PYEOF'
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
a = fdraws("e10_base.bit")
res = {}
for t in ("e10_w1", "e10_w41"):
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
print("E10JSON_BEGIN"); print(json.dumps({"base_words": len(a), "items": res})); print("E10JSON_END")
PYEOF
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
echo E10DIFF_BEGIN
$PY diff_e10.py
echo E10DIFF_END
echo E10DONE
