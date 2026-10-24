import json, os, sys
sys.path.insert(0, "/opt/lzh/v7re")
import rapidwright
from com.xilinx.rapidwright.device import Device
from com.xilinx.rapidwright.bitstream import ConfigArray
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

dev = Device.getDevice("xc7vx485tffg1761-2")
ca = ConfigArray(dev)
ser = dev.getSeries()
entries = []
for r_idx, row in enumerate(ca.getConfigRows()):
    for b in row.getBlocks():
        base = int(b.getAddress()); n = int(b.getFrameCount())
        for k in range(n):
            entries.append((base + k, b, r_idx))
    entries.append((None, None, r_idx)); entries.append((None, None, r_idx))

def far_of(t):
    far, b, r = entries[t]
    if b is None:
        return {"frame": t, "overhead_row": r}
    return {"frame": t, "far": hex(far), "row": r,
            "col": int(b.getColumn(ser)), "bottom": str(b.getBottomTile().getName()),
            "offset_in_block": far - int(b.getAddress())}

out = {"total_linear_frames": len(entries), "points": []}
P1, P2 = "/opt/lzh/step03/pip1", "/opt/lzh/step03/pip2"
cases = [(P1, "a.bit", "b.bit", "Y10", "LOGIC_OUTS_L12->>NR1BEG0")]
for y in [20,22,30,31,32,40,41,42,50,52,60]:
    if y == 20:
        cases.append((P2, "a20.bit", "b20.bit", "Y20", "LOGIC_OUTS_L20->>NR1BEG2"))
    else:
        cases.append((P2, f"a_y{y}.bit", f"b_y{y}.bit", f"Y{y}", "LOGIC_OUTS_L20->>NR1BEG2"))
for d, ab, bb, tag, pip in cases:
    a, b = frames_from_bit(f"{d}/{ab}"), frames_from_bit(f"{d}/{bb}")
    idx = diff_frame_indices(a, b)
    rec = {"point": tag, "pip": pip, "frames": idx, "bits": []}
    for f in idx:
        bits = diff_bits_in_frame(a, b, f)
        rec["bits"].append({"frame": f, "config_bits": [list(x) for x in bits if x[0] != 50],
                            "ecc_bits": [list(x) for x in bits if x[0] == 50]})
    rec["map"] = [far_of(f) for f in idx]
    out["points"].append(rec)
print(json.dumps(out, indent=1))


