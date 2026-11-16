#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
mkdir -p /opt/lzh/step03/s5 && cd /opt/lzh/step03/s5

for v in pre_c0 pre_c1 pre_ax pre_cin cy0_lut cy0_di a_o6 a_o5 a_a5q a_xor a_cy a_f7; do
  if [ -f s5_$v.bit ] && [ s5_$v.v -nt s5_$v.bit ]; then rm -f s5_$v.bit; fi
  if [ ! -f s5_$v.bit ]; then
    $VIV -mode batch -notrace -source s5_build.tcl -tclargs $v \
      -log s5_$v.log > s5_$v.out 2>&1
    if [ -f s5_$v.bit ]; then echo "OK $v"; else echo "FAIL $v"; tail -5 s5_$v.out; fi
  else
    echo "SKIP $v (exists)"
  fi
done

/opt/lzh/venv/bin/python - <<'PYEOF'
import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

variants = ["pre_c0", "pre_c1", "pre_ax", "pre_cin", "cy0_lut", "cy0_di",
            "a_o6", "a_o5", "a_a5q", "a_xor", "a_cy", "a_f7"]
pairs = [("pre_c1", "pre_c0"), ("pre_ax", "pre_c0"), ("pre_cin", "pre_c0"),
         ("cy0_lut", "pre_c0"), ("cy0_di", "pre_c0"),
         ("a_o5", "a_o6"), ("a_a5q", "a_o6"), ("a_xor", "a_o6"),
         ("a_cy", "a_o6"), ("a_f7", "a_o6")]

res = {}
for v in variants:
    res[v] = frames_from_bit("s5_%s.bit" % v)

out = {}
for a, b in pairs:
    frames = diff_frame_indices(res[b], res[a])
    cfg = [[x, w, bit] for x in frames for w, bit in diff_bits_in_frame(res[b], res[a], x)
           if w != 50 and x < 50176]
    out["%s_minus_%s" % (a, b)] = cfg
    print("%s - %s ->" % (a, b), cfg)

with open("s5_diff.json", "w") as f:
    json.dump(out, f, indent=1)
print("WROTE s5_diff.json")
PYEOF
