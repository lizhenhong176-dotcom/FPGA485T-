# -*- coding: utf-8 -*-
"""G12（收口判定）：源→槽位顺序能否由「族名 + 源名 + 16 条配置表 + 20 条旁路亲和表」完全重建？
判据：64 个 24 源族 × 24 个源 = 1,536 条槽位，逐条比对。
"""
import sqlite3, collections, re, json, os

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in rows:
    fam[f][s].add(fo)

def slot(fos):
    r, code = None, 0
    for fo in fos:
        if 16 <= fo <= 21:
            r = fo - 16
        elif 22 <= fo <= 25:
            code |= 1 << (25 - fo)
    return r, code

AX = {"EE": "E", "WW": "W", "NN": "N", "SS": "S"}
DG = {"SE": "E", "SW": "S", "NE": "N", "NW": "W"}
LN = {"EL": "E", "WL": "W", "NL": "N", "SL": "S"}
RN = {"ER": "E", "WR": "W", "NR": "N", "SR": "S"}
def key(name):
    p = name[:2]
    for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
        if p in tab:
            return tag, tab[p]
    return "extra", name

truth = {}
for f, d in fam.items():
    if len(d) != 24:
        continue
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    truth[f] = slots

def num(f): return int(re.search(r"(\d+)$", f).group(1))
def prefix(f): return re.sub(r"\d+$", "", f)

# ---- 学习两张表 ----
def cfg_sig(slots):
    perm, cc = {}, {}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag == "extra":
            continue
        cc.setdefault(tag, set()).add(c)
        if tag != "diag":
            perm.setdefault(tag, {})[dirn] = r
    cc1 = {k: list(v)[0] for k, v in cc.items() if len(v) == 1}
    return (tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
            tuple(sorted(perm["rline"].items())), cc1["axis"], cc1["longL"])

def block_of(f):
    n, p = num(f), prefix(f)
    if p == "FAN_ALT":
        return 0 if n in (0, 1, 2, 7) else 1
    return n // 8

cfg_key = lambda f: (prefix(f), block_of(f), num(f) % 2)
cfgs = {}
for f, slots in truth.items():
    cfgs.setdefault(cfg_key(f), set()).add(cfg_sig(slots))
print("配置键数：", len(cfgs), "| 冲突键：", sum(1 for v in cfgs.values() if len(v) > 1))
CFG = {k: list(v)[0] for k, v in cfgs.items()}

# 旁路源 -> 与哪个线类同码（学 20 条）
aff = collections.defaultdict(collections.Counter)
for f, slots in truth.items():
    cc = {}
    for s, (r, c) in slots.items():
        tag, _ = key(s)
        if tag != "extra":
            cc.setdefault(tag, set()).add(c)
    cc = {k: list(v)[0] for k, v in cc.items() if len(v) == 1}
    inv = {v: k for k, v in cc.items()}
    for s, (r, c) in slots.items():
        if key(s)[0] == "extra":
            aff[s][(inv.get(c), 4 if re.match(r"^(LOGIC_OUTS|GFAN)", s) else 5)] += 1
AFF = {s: v.most_common(1)[0][0] for s, v in aff.items()}
print("旁路源条目：", len(AFF), "| 与行号一致的比例：",
      round(100 * sum(n for _, n in [v.most_common(1)[0] for v in aff.values()]) /
            sum(sum(v.values()) for v in aff.values()), 1), "%")

# ---- 重建并比对 ----
tot = hit = 0
bad_fam = []
for f, slots in truth.items():
    pax, pln, prl, ca, cl = CFG[cfg_key(f)]
    pax, pln, prl = dict(pax), dict(pln), dict(prl)
    code_of = {"axis": ca, "longL": cl,
               "diag": 1 if ca == 2 else 2, "rline": 7 if cl == 11 else 11}
    fh = 0
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag == "extra":
            cls, row = AFF[s]
            pred = (row, code_of[cls])
        elif tag == "diag":
            pred = (pax[dirn], code_of["diag"])
        elif tag == "axis":
            pred = (pax[dirn], ca)
        elif tag == "longL":
            pred = (pln[dirn], cl)
        else:
            pred = (prl[dirn], code_of["rline"])
        tot += 1
        if pred == (r, c):
            hit += 1
            fh += 1
    if fh != len(slots):
        bad_fam.append((f, f"{fh}/{len(slots)}"))

print(f"\n逐条：{hit}/{tot} = {100.0*hit/tot:.2f}%")
print(f"整族 24/24 全对：{len(truth)-len(bad_fam)}/{len(truth)}")
for f, w in bad_fam[:8]:
    print("   失败", f, w)

out = {"cfg": {f"{k[0]}|{k[1]}|{k[2]}": v for k, v in CFG.items()},
       "aff": {s: list(v) for s, v in AFF.items()},
       "hit": hit, "tot": tot, "families_ok": len(truth) - len(bad_fam), "families": len(truth)}
os.makedirs(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out", exist_ok=True)
json.dump(out, open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\slot_derive.json", "w",
                    encoding="utf-8"), ensure_ascii=False, indent=1)
print("已写 step03_pip/out/slot_derive.json")
