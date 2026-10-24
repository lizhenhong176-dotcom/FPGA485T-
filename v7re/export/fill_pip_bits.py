"""Fill pip_bits / bit_map from the STEP03 PIP-drop experiments.

Data source: step03_pip/RESULTS.md (files on the remote WSL, /opt/lzh/step03).
Only configuration bits are stored; word 50 (ECC/aux) is deliberately excluded.
"""

from __future__ import annotations

import sqlite3

DB = r"E:\v7work\model\v7_model.sqlite"
DEV = "xc7vx485t"
SRC = "step03_pip_20261024"

# (tile, wire_a, wire_b, [(frame, word, bit), ...])
PIP_BITS = []

# variant LOGIC_OUTS_L12->>NR1BEG0 at Y10
PIP_BITS.append(
    ("INT_L_X6Y10", "LOGIC_OUTS_L12", "NR1BEG0", [(31690, 20, 7), (31693, 20, 7)])
)

# variant LOGIC_OUTS_L20->>NR1BEG2, Y = 20..60
for y, word, frames in [
    (20, 41, (31688, 31694)),
    (22, 45, (31688, 31694)),
    (30, 62, (31688, 31694)),
    (31, 64, (31688, 31694)),
    (32, 66, (31688, 31694)),
    (40, 82, (31688, 31694)),
    (41, 84, (31688, 31694)),
    (42, 86, (31688, 31694)),
    (50, 1, (26442, 26448)),
    (52, 5, (26442, 26448)),
    (60, 21, (26442, 26448)),
]:
    PIP_BITS.append(
        ("INT_L_X6Y%d" % y, "LOGIC_OUTS_L20", "NR1BEG2", [(f, word, 7) for f in frames])
    )

# variant NR1END0->>IMUX_L8 at Y11 (4 frames, different bit per frame)
PIP_BITS.append(
    ("INT_L_X6Y11", "NR1END0", "IMUX_L8", [(31699, 22, 3), (31702, 22, 2), (31704, 22, 2), (31705, 22, 2)])
)


def main() -> None:
    con = sqlite3.connect(DB)
    con.execute("PRAGMA journal_mode=WAL")
    n_pip = n_map = 0
    for tile, wa, wb, bits in PIP_BITS:
        feature = "%s.%s->>%s" % (tile, wa, wb)
        for frame, word, bit in bits:
            if word == 50:
                raise SystemExit("refusing to store ECC word 50")
            con.execute(
                "INSERT OR REPLACE INTO pip_bits"
                "(device,tile,wire_a,wire_b,frame,word,bit,value,source)"
                " VALUES(?,?,?,?,?,?,?,1,?)",
                (DEV, tile, wa, wb, frame, word, bit, SRC),
            )
            con.execute(
                "INSERT OR REPLACE INTO bit_map(device,frame,word,bit,feature,value,source)"
                " VALUES(?,?,?,?,?,1,?)",
                (DEV, frame, word, bit, feature, SRC),
            )
            n_pip += 1
            n_map += 1
    con.commit()

    print("pip_bits rows:", con.execute("select count(*) from pip_bits").fetchone()[0])
    print("bit_map rows :", con.execute("select count(*) from bit_map").fetchone()[0])
    print("inserted     :", n_pip, n_map)
    for row in con.execute(
        "select tile, wire_a, wire_b, frame, word, bit from pip_bits order by tile, frame limit 5"
    ):
        print("  ", row)


if __name__ == "__main__":
    main()
