# -*- coding: utf-8 -*-
"""P1g：96 个 20 源 BEG 族的 Q 轴（4 列）逐族明细 + 纯净/变体分类。
Q 列 = 被 5 个源共享的 cell（每列恰 5 源）。
"""
import sqlite3, collections, re, json, io

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
beg = {f: d for f, d in fam.items() if len(d) == 20}


def geo(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", s)
    if m:
        return "len" + m.group(2)
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)", s):
        return "line"
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    return "long"


def dirn(s):
    for tok in ("EE", "WW", "NN", "SS", "NE", "NW", "SE", "SW",
                "EL", "ER", "NL", "NR", "SL", "SR", "WL", "WR"):
        if s.startswith(tok):
            return tok
    if s.startswith("LH"):
        return "LH"
    if s.startswith("LV"):
        return "LV"
    if s.startswith("LOGIC_OUTS"):
        return "LOGIC" + s.replace("LOGIC_OUTS", "")
    return s


def columns(d):
    deg = collections.Counter()
    for cs in d.values():
        for c in cs:
            deg[c] += 1
    cols = collections.defaultdict(list)
    for s, cs in d.items():
        for c in cs:
            if deg[c] == 5:
                cols[c].append(s)
    return [c for c in deg if deg[c] == 5], cols


pure, variant, detail = [], [], {}
PURE_SIG = {frozenset(["line", "logic"]), frozenset(["len4", "len6"]),
            frozenset(["len2"]), frozenset(["logic"])}
for f in sorted(beg):
    Q, cols = columns(beg[f])
    assert len(Q) == 4, (f, len(Q))
    colsig = [frozenset({geo(s) for s in cols[c]}) for c in sorted(Q)]
    rec = {
        "family": f,
        "colsigs": sorted(sorted(x) for x in colsig),
        "cols": [{"cell": list(c),
                  "srcs": [{"n": s, "g": geo(s), "d": dirn(s)} for s in sorted(cols[c])]}
                 for c in sorted(Q)],
    }
    ok = all(x in PURE_SIG for x in colsig) and len(set(colsig)) == 4
    rec["pure"] = ok
    detail[f] = rec
    (pure if ok else variant).append(f)

print("纯净:", len(pure), " 变体:", len(variant))
print("\n== 变异族的列签名 ==")
sigc = collections.Counter()
for f in variant:
    sigc[tuple(tuple(x) for x in detail[f]["colsigs"])] += 1
for k, v in sigc.most_common():
    print(f"  {v:>2} 族  ", k)

print("\n== 变体逐族逐列 ==")
for f in variant:
    print(f"\n{f}")
    for col in detail[f]["cols"]:
        print("   cell", tuple(col["cell"]), "->",
              [(s["n"], s["g"]) for s in col["srcs"]])

io.open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\beg_qaxis.json", "w", encoding="utf-8").write(
    json.dumps({"pure": pure, "variant": variant, "detail": detail}, ensure_ascii=False, indent=1))
print("\nwrote out/beg_qaxis.json")
