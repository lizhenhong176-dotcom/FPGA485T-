#!/bin/bash
cd /opt/lzh/step03/s5
/opt/lzh/venv/bin/python - <<'PYEOF'
import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

variants = ["pre_c0", "pre_c1", "pre_ax", "pre_cin", "cy0_lut", "cy0_di",
            "a_o6", "a_o5", "a_a5q", "a_xor", "a_cy", "a_f7"]
BASE = 31716
# SLICEM_X0 (X10Y20) word rows 40/41; also neighbors 38/39 (Y19) for cascade check
frames_of_interest = [BASE+0, BASE+1, BASE+30, BASE+31, BASE-2, BASE-1]
out = {}
for v in variants:
    fr = frames_from_bit("s5_%s.bit" % v)
    d = {}
    for x in frames_of_interest:
        w = fr[x]
        d[str(x)] = [w[38], w[39], w[40], w[41]]
    out[v] = d
with open("s5_words.json", "w") as f:
    json.dump(out, f)
print("WROTE s5_words.json")
PYEOF
