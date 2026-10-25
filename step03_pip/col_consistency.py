import collections
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
data = json.load(open(os.path.join(HERE, "tilepipe.json"), encoding="utf-8"))


def decompose(mask):
    """mask: list of [frame, word, bit]; returns (row_key, col_pattern) or None."""
    base_frames = sorted({f for f, w, b in mask})
    f0 = 31696
    rel = sorted({(f - f0, b) for f, w, b in mask})
    # row cell: df in 0..5 (whatever bit), col cells: df 6..9
    rows = [r for r in rel if r[0] <= 5]
    cols = [r for r in rel if r[0] >= 6]
    row = rows[0] if len(rows) == 1 else tuple(rows)
    return row, tuple(sorted(c[0] for c in cols))


per_design = {}
for tag, rec in data.items():
    mux = rec["sink"]
    per_design[mux] = {s: decompose(m) for s, m in rec["sources"].items()}

# which source wires appear in more than one mux?
bymux = collections.defaultdict(list)
for mux, srcs in per_design.items():
    for s in srcs:
        bymux[s].append(mux)

shared = {s: ms for s, ms in bymux.items() if len(ms) > 1}
print("wires appearing in >1 mux:", len(shared))
for s, ms in sorted(shared.items(), key=lambda kv: -len(kv[1]))[:12]:
    print(" %-20s muxes=%d" % (s, len(ms)))
    for m in sorted(ms, key=lambda x: int(x.split("_L")[1])):
        print("     %-9s row/col=%s" % (m, per_design[m][s]))

# column pattern -> distribution per mux
print("\ncolumn patterns seen:")
cnt = collections.Counter()
for mux, srcs in per_design.items():
    for s, rc in srcs.items():
        if rc:
            cnt[rc[1]] += 1
print(cnt)
