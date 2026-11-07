set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
cd /opt/lzh/v7re/work/t21
cat > /tmp/t21diff.py <<'EOF'
import sys, json
sys.path.insert(0, '/opt/lzh/v7re')
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame

BASE = 31716
pairs = [("neg", "a0_y20", "a0bc"), ("A_y20", "a0_y20", "ar_y20"), ("B_y20", "b0_y20", "br_y20"),
         ("C_y20", "c0_y20", "cr_y20"), ("D_y20", "d0_y20", "dr_y20"),
         ("A_y21", "a0_y21", "ar_y21")]
R = "/opt/lzh/v7re/work/t21"
out = {}
for name, f0, f1 in pairs:
    a = load_frames(f"{R}/{f0}/{f0}.bit")
    b = load_frames(f"{R}/{f1}/{f1}.bit")
    idx = diff_frame_indices(a, b)
    cells = []
    for i in idx:
        for (w, bit) in diff_bits_in_frame(a, b, i):
            cells.append([i - BASE, w, bit])
    out[name] = {"ndiff": len(idx), "frames": idx, "n": len(cells), "cells": sorted(cells)}
print("JSON_BEGIN")
print(json.dumps(out))
print("JSON_END")
EOF
/opt/lzh/venv/bin/python /tmp/t21diff.py 2>&1 | sed -n '/JSON_BEGIN/,/JSON_END/p'
