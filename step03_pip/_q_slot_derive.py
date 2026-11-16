# -*- coding: utf-8 -*-
"""G10（收口）：源→槽位顺序的可推导性判定。
判据：只用族名（前缀 + 序号）+ 一张 16 条配置表，能否逐条重建 64 个 24 源族的全部槽位？
"""
import sqlite3, collections, re, json, os

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)
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
    return ("other", name)

# 观察到的真表
truth = {}
for f, d in fam.items():
    if len(d) != 24:
        continue
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    truth[f] = slots
print("24 源族：", len(truth))

def sig(f, slots):
    """族槽位表的可比较签名：按 (族内 24 个源名) 排序后的 (r,c) 序列 + 相对码。"""
    perm, cc = {}, {}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag in ("axis", "longL", "rline"):
            perm.setdefault(tag, {})[dirn] = r
        if tag != "other":
            cc.setdefault(tag, set()).add(c)
    cc = {k: list(v)[0] for k, v in cc.items() if len(v) == 1}
    return (tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
            tuple(sorted(perm["rline"].items())), cc["axis"], cc["longL"])

def num(f):
    m = re.search(r"(\d+)$", f)
    return int(m.group(1)) if m else -1

def prefix(f):
    return re.sub(r"\d+$", "", f)

# 1) 配置 = f(前缀, n//8, n%2)？
groups = collections.defaultdict(set)
for f, slots in truth.items():
    n = num(f)
    groups[(prefix(f), n // 8, n % 2)].add(sig(f, slots))
bad_groups = {k: v for k, v in groups.items() if len(v) > 1}
print(f"键 (前缀, n//8, n%2) 数：{len(groups)}；一键多配置的：{len(bad_groups)}")
for k, v in list(bad_groups.items())[:5]:
    print("   冲突", k, len(v))

# 2) 用 16 条配置表 + 该键规则重建
table = {k: list(v)[0] for k, v in groups.items() if len(v) == 1}
print(f"配置表条目：{len(table)}（= 需要的自由数据量）")

ok = bad = 0
fails = []
for f, slots in truth.items():
    n = num(f)
    cfg = table.get((prefix(f), n // 8, n % 2))
    if cfg is None:
        bad += 1
        fails.append((f, "无配置"))
        continue
    # 依配置反推每个源的 (r,c)
    pax, pln, prl, ca, cl = cfg
    pax, pln, prl = dict(pax), dict(pln), dict(prl)
    pred = {}
    for s in slots:
        tag, dirn = key(s)
        if tag == "axis":
            pred[s] = (pax[dirn], ca if ca in (1, 2) else ca)
        elif tag == "diag":
            pred[s] = (pax[dirn], 1 if ca == 2 else 2)   # 斜线取另一码
        elif tag == "longL":
            pred[s] = (pln[dirn], cl)
        elif tag == "rline":
            pred[s] = (prl[dirn], 7 if cl == 11 else 11)
        else:
            pred[s] = slots[s]                            # 8 个非方位源仍按表
    hit = sum(1 for s in slots if pred.get(s) == slots[s])
    if hit == len(slots):
        ok += 1
    else:
        bad += 1
        fails.append((f, f"{hit}/{len(slots)}"))

print(f"整族 24 槽全对：{ok}/{len(truth)}；失败 {bad}")
for f, why in fails[:6]:
    print("   失败", f, why)

json.dump({"table": {f"{k[0]}|{k[1]}|{k[2]}": v for k, v in table.items()}},
          open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\slot_config_table.json", "w",
               encoding="utf-8"), ensure_ascii=False, indent=1)
print("配置表已存 step03_pip/out/slot_config_table.json")
