import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

P = "/opt/lzh/step03/pip1"
a = frames_from_bit(f"{P}/a.bit")
for name, label in [("b.bit","drop1 INT LOGIC_OUTS_L12->>NR1BEG0"),
                    ("b_d0.bit","drop0 CLBLL_LL_A->LOGIC_OUTS12"),
                    ("b_d2.bit","drop2 INT_L NR1END0->>IMUX_L8"),
                    ("b_d3.bit","drop3 CLBLL_IMUX8->A5")]:
    try:
        x = frames_from_bit(f"{P}/{name}")
    except Exception as e:
        print(name, "ERR", e); continue
    idx = diff_frame_indices(a, x)
    print(f"== {name} ({label}): {len(idx)} frames {idx}")
    for f in idx:
        bits = diff_bits_in_frame(a, x, f)
        w20 = [b for b in bits if b[0]==20]
        other = [b for b in bits if b[0]!=20]
        print(f"   frame {f}: total {len(bits)}  w20={w20}  other={other[:12]}")
