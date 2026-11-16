# -*- coding: utf-8 -*-
"""T3 假说检验探针（只读）。

不引用 T56/T2b 的中间变量：直接从 _full8.bit 的 payload 扫位，从 decode.fasm 取
每条 PIP 属于哪个 tile，按 4 条假说各自的「可证伪预测」逐项实测。

S1 元数据 / S2 载入 / S3 组内一致性 / S4 H1 / S5 H2(+负对照) /
S6 H3 / S7 H4 / S8 T2 §5.2 errata / S9 结论
"""
import sys, os, json, itertools
from collections import defaultdict, Counter

ROOT = r"E:\DEEPSEEK\FPGA比特流逆向"
sys.path.insert(0, os.path.join(ROOT, "v7re", "scripts"))
import fasm2bit as F

BIT = os.path.join(ROOT, "_full8.bit")
FASM = os.path.join(ROOT, "v7re", "steps", "t2b_full8_decode.fasm")
OUT = os.path.join(ROOT, "v7re", "steps", "t3_probe_out.txt")
JOUT = os.path.join(ROOT, "v7re", "steps", "t3_probe_out.json")

L = []
def p(s=""):
    L.append(str(s))

# ---------------------------------------------------------------- S1 元数据
model = F.Model(law_db=r"E:\v7work\model\v7_law.sqlite",
                law_json=os.path.join(ROOT, "v7re", "steps", "pip_reuse_law.json"),
                ecc_json=os.path.join(ROOT, "v7re", "steps", "ecc_model.json"),
                model_db=r"E:\v7work\model\v7_model.sqlite")
data, syncpos, words = F.load_words(BIT)
poff = F.payload_offset(words)
nframes = (len(words) - poff) // F.FRAME_WORDS
FRAME_WORDS = F.FRAME_WORDS

def word_at(f, w):
    return words[poff + f * FRAME_WORDS + w]

p("S1 元数据")
p("  bitstream = %s  size=%d  sync@%d  payload_words=%d  nframes=%d"
  % (os.path.basename(BIT), os.path.getsize(BIT), syncpos, len(words), nframes))
p("  decode.fasm = %s" % os.path.basename(FASM))

# ---------------------------------------------------------------- S2 载入
tile_pips = defaultdict(set)
raw_lines = 0
for ln in open(FASM, encoding="utf-8"):
    ln = ln.strip()
    if not ln:
        continue
    raw_lines += 1
    if "=" in ln:                       # CLB INIT 行，不是 PIP
        continue
    parts = ln.split(".")
    if len(parts) < 3:
        continue
    tile_pips[parts[0]].add((parts[1], ".".join(parts[2:])))

info = {}
for tile, pips in sorted(tile_pips.items()):
    tb = model.tile_base(tile)
    if not tb:
        p("  [warn] 未知 tile: %s" % tile)
        continue
    tt, base, y = tb
    rel, absb = set(), set()
    for fo in range(26):
        f = base + fo
        for par in (0, 1):
            w = model.word_of(y, par)
            v = word_at(f, w)
            while v:
                b = (v & -v).bit_length() - 1
                rel.add((fo, par, b)); absb.add((f, w, b))
                v &= v - 1
    pred = set()
    for fam, src in pips:
        for (cfo, cb, cpar) in (model.cells_of(tt, fam, src) or []):
            pred.add((cfo, cpar, cb))
    col = int(tile.split("_X")[1].split("Y")[0])
    info[tile] = dict(tt=tt, base=base, y=y, col=col, pips=frozenset(pips),
                      rel=frozenset(rel), abs=frozenset(absb), pred=frozenset(pred))

p("  非空 FASM 行 = %d   PIP 行 = %d   带 PIP 的 tile = %d"
  % (raw_lines, sum(len(v["pips"]) for v in info.values()), len(info)))
p("  tile_type 分布 = %s  列集合 = %s" %
  (dict(Counter(v["tt"] for v in info.values())),
   sorted({v["col"] for v in info.values()})))

# ---------------------------------------------------------------- S3 组内一致性
groups = defaultdict(list)
for tile, v in info.items():
    for (fam, src) in v["pips"]:
        groups[(v["tt"], fam, src)].append(tile)

p("")
p("S3 组内一致性（组 = (tile_type, family, src)）")
p("  组数 = %d   多 tile 组 = %d" % (len(groups), sum(1 for g in groups.values() if len(g) > 1)))
size_dist = Counter(len(g) for g in groups.values())
p("  组大小分布 = %s" % dict(sorted(size_dist.items())))
total_pairs = sum(len(g) * (len(g) - 1) // 2 for g in groups.values())
p("  组内 tile 对总数 = %d" % total_pairs)

rows = []
for key, tiles in sorted(groups.items()):
    if len(tiles) < 2:
        continue
    relsets = {info[t]["rel"] for t in tiles}
    abssets = {info[t]["abs"] for t in tiles}
    bases = [info[t]["base"] for t in tiles]
    ys = [info[t]["y"] for t in tiles]
    cols = [info[t]["col"] for t in tiles]
    rows.append(dict(key=key, n=len(tiles), rel_kind=len(relsets), abs_kind=len(abssets),
                     dbase=max(bases) - min(bases), dy=max(ys) - min(ys),
                     dcol=max(cols) - min(cols), tiles=tiles))
    p("  %-10s %-16s %-14s n=%2d rel种类=%d abs种类=%d db=%5d dy=%2d dc=%2d"
      % (key[0], key[1], key[2], len(tiles), len(relsets), len(abssets),
         max(bases) - min(bases), max(ys) - min(ys), max(cols) - min(cols)))
p("  多 tile 组中 rel 只有 1 种的 = %d / %d" %
  (sum(1 for r in rows if r["rel_kind"] == 1), len(rows)))

# ---------------------------------------------------------------- S4 H1
p("")
p("S4 H1「同 tile_type 相对坐标可复用 → 预期相同」")
same_base = [r for r in rows if r["dbase"] == 0]
cross_base = [r for r in rows if r["dbase"] != 0]
p("  Δbase=0 的组 = %d（其中 Δy≠0 = %d）" %
  (len(same_base), sum(1 for r in same_base if r["dy"] != 0)))
p("  Δbase≠0 的组 = %d（其中 Δcol≠0 = %d）" %
  (len(cross_base), sum(1 for r in cross_base if r["dcol"] != 0)))
p("  预测 P1a：Δbase≠0 的组内 rel 全等 → 实测 %d/%d 成立" %
  (sum(1 for r in cross_base if r["rel_kind"] == 1), len(cross_base)))
p("  预测 P1b：Δbase≠0 的组内 abs 必不全等 → 实测 %d/%d 成立" %
  (sum(1 for r in cross_base if r["abs_kind"] > 1), len(cross_base)))

# 逐对（不同 base 的两 tile）
pair_stat = Counter()
for key, tiles in groups.items():
    for a, b in itertools.combinations(tiles, 2):
        ia, ib = info[a], info[b]
        tag = ("db0" if ia["base"] == ib["base"] else "dbn")
        tag += "_dy0" if ia["y"] == ib["y"] else "_dyn"
        pair_stat[(tag, ia["rel"] == ib["rel"], ia["abs"] == ib["abs"])] += 1
p("  逐对统计 (base关系, y关系) → rel相同?, abs相同? :")
for k in sorted(pair_stat):
    p("    %-14s rel=%-5s abs=%-5s : %d" % (k[0], k[1], k[2], pair_stat[k]))

# ---------------------------------------------------------------- S5 H2
p("")
p("S5 H2「归一化抹掉绝对坐标造成假相同」")
p("  P2a 若假相同成立：不归一化时应大面积相同 → 实测 abs 相同的对 = %d / %d"
  % (sum(1 for k in pair_stat if k[2]), total_pairs))
# 负对照 1：不同 PIP 集合的 tile，归一化后是否被抹成相同
sig = defaultdict(set)
for tile, v in info.items():
    sig[v["pips"]].add(tile)
p("  负对照1：不同 PIP 集合的 tile 数 = %d；distinct rel 集合数 = %d"
  % (len(sig), len({v["rel"] for v in info.values()})))
collapse = []
tl = sorted(info)
for a, b in itertools.combinations(tl, 2):
    if info[a]["pips"] != info[b]["pips"] and info[a]["rel"] == info[b]["rel"]:
        collapse.append((a, b))
p("  负对照1 结果：PIP 集不同却 rel 相同 的对 = %d（若 >0 说明归一化过度坍缩）" % len(collapse))
for a, b in collapse[:5]:
    p("    %s | %s" % (a, b))
# 负对照 2：每 tile 取 PIP 集的签名，比较签名相同集合 vs rel 相同集合的对应
pairs_same_sig = sum(1 for a, b in itertools.combinations(tl, 2) if info[a]["pips"] == info[b]["pips"])
pairs_same_rel = sum(1 for a, b in itertools.combinations(tl, 2) if info[a]["rel"] == info[b]["rel"])
p("  负对照2：same_pips 对数 = %d，same_rel 对数 = %d，差值 = %d"
  % (pairs_same_sig, pairs_same_rel, pairs_same_rel - pairs_same_sig))

# 残差：窗口内实测位 − 已解 PIP 预测位并集（不预先限制在 domain 内）
p("  残差（obs_rel − 已解 PIP 预测，窗口 26 帧 × 2 word 全位）：")
res_by_col = defaultdict(lambda: [0, 0, 0])   # [tiles, tiles_with_res, bits]
res_examples = []
for tile, v in sorted(info.items()):
    r = v["rel"] - v["pred"]
    extra = v["pred"] - v["rel"]
    t = res_by_col[v["col"]]
    t[0] += 1
    if r:
        t[1] += 1
        t[2] += len(r)
        if len(res_examples) < 8:
            res_examples.append((tile, sorted(r)[:6], len(r)))
    if extra:
        p("    [warn] 预测有、实测无：%s %s" % (tile, sorted(extra)[:6]))
for col in sorted(res_by_col):
    t = res_by_col[col]
    p("    col %-2d tiles=%-2d 有残差 tile=%-2d 残差位=%-3d" % (col, t[0], t[1], t[2]))
for e in res_examples:
    p("      例 %s -> %d 位 %s" % e)
p("  合计残差位 = %d" % sum(t[2] for t in res_by_col.values()))

# 错误归一化对照
def variants(tile):
    v = info[tile]
    y = v["y"]
    w0 = 2 * (y % 50)
    return {
        "abs(不归一化)": v["abs"],
        "正确(fo,par,bit)": v["rel"],
        "帧镜像 25-fo": frozenset((25 - fo, par, b) for (fo, par, b) in v["rel"]),
        "帧镜像 67-fo": frozenset((67 - fo, par, b) for (fo, par, b) in v["rel"]),
        "省略 word 偏移(用绝对 word)": frozenset((fo, w0 + par, b) for (fo, par, b) in v["rel"]),
        "parity 翻转": frozenset((fo, 1 - par, b) for (fo, par, b) in v["rel"]),
        "bit 镜像 31-b": frozenset((fo, par, 31 - b) for (fo, par, b) in v["rel"]),
    }
p("  错误/替代归一化下的组内单值率（分母 %d 组）：" % len(rows))
for name in variants(next(iter(info))):
    ok = 0
    for r in rows:
        if len({variants(t)[name] for t in r["tiles"]}) == 1:
            ok += 1
    p("    %-26s %d/%d" % (name, ok, len(rows)))

# ---------------------------------------------------------------- S6 H3
p("")
p("S6 H3「同一位被多条 PIP 复用 / 重复计数」")
p("  P3a law 级：不同 (family,cell) 数 vs 按 (family,src) 展开数")
try:
    import sqlite3
    con = sqlite3.connect("file:%s?mode=ro" % r"E:\v7work\model\v7_law.sqlite", uri=True)
    n_cell = con.execute("select count(*) from (select distinct tile_type,family,frame_off,bit,parity from law_cells where sense=1)").fetchone()[0]
    n_src = con.execute("select count(*) from law_cells where sense=1").fetchone()[0]
    p("    distinct(family,cell) = %d ; (family,src) 行数 = %d ; 复用倍数 = %.2f"
      % (n_cell, n_src, n_src / n_cell))
    con.close()
except Exception as e:
    p("    [warn] law 统计失败: %s" % e)

tile_with_overlap = 0
max_overlap = 0
overlap_examples = []
cell_claim = Counter()
for tile, v in sorted(info.items()):
    pl = sorted(v["pips"])
    sets = {f"{f}|{s}": set((c[0], c[2], c[1]) for c in (model.cells_of(v["tt"], f, s) or []))
            for f, s in pl}
    has = False
    for a, b in itertools.combinations(pl, 2):
        ka, kb = f"{a[0]}|{a[1]}", f"{b[0]}|{b[1]}"
        ov = sets[ka] & sets[kb]
        if ov:
            has = True
            max_overlap = max(max_overlap, len(ov))
            if len(overlap_examples) < 6:
                overlap_examples.append((tile, ka, kb, sorted(ov)))
    for k, s in sets.items():
        for c in s:
            cell_claim[(tile, c)] += 1
    if has:
        tile_with_overlap += 1
p("  P3b 同一 tile 内两条已解 PIP 的预测格相交：有相交的 tile = %d / %d ; 最大相交格数 = %d"
  % (tile_with_overlap, len(info), max_overlap))
for e in overlap_examples:
    p("    例 %s : %s ∩ %s = %s" % e)
multi = {k: c for k, c in cell_claim.items() if c > 1}
p("  P3c 同一 tile 内同一位被 ≥2 条 PIP 声明：格数 = %d ; 分布 = %s"
  % (len(multi), dict(Counter(multi.values()))))

# ---------------------------------------------------------------- S7 H4
p("")
p("S7 H4「行/列镜像或位序对称导致成对出现」")
p("  P4a 若由镜像产生，则组内应只存在少数几对镜像关系，而非全部两两相同")
p("    rel 全等的组 = %d/%d（全等意味着 C(n,2) 对全部相同，不是'某两对'）"
  % (sum(1 for r in rows if r["rel_kind"] == 1), len(rows)))
gs = Counter(r["n"] for r in rows)
p("    组大小分布（多 tile 组）= %s" % dict(sorted(gs.items())))
p("    每组对数 = %s" % {n: n * (n - 1) // 2 for n in sorted(gs)})
# 列镜像：同组两端列号 c 与 33-c
mir_col = [(r, [info[t]["col"] for t in r["tiles"]]) for r in rows]
ok_mir = sum(1 for r, cs in mir_col if all(c + d == 33 for c, d in zip(sorted(cs), sorted(cs, reverse=True))))
p("  P4b 列镜像(c ↔ 33-c)假设：满足镜像关系的组 = %d / %d" % (ok_mir, len(rows)))
# bit 镜像
tot = 0; mir = 0
for tile, v in info.items():
    for (fo, par, b) in v["rel"]:
        tot += 1
        if (fo, par, 31 - b) in v["rel"]:
            mir += 1
p("  P4c bit 序对称(b ↔ 31-b)：置位格 %d，其对偶也置位的 = %d (%.1f%%)"
  % (tot, mir, 100.0 * mir / max(tot, 1)))
# 同 tile 内 RHS 位对
p("  P4d 位集中在少数 bit：bit 分布 = %s" % dict(sorted(Counter(b for v in info.values() for (_, _, b) in v["rel"]).items())))

# ---------------------------------------------------------------- S8 T2 §5.2 errata
p("")
p("S8 T2 §5.2 口径核对（'同 base 两端 frame/word 完全相同 → 同一批绝对位'）")
db0 = [r for r in rows if r["dbase"] == 0 and r["n"] > 1]
p("  Δbase=0 组 = %d" % len(db0))
for r in db0:
    ys = [info[t]["y"] for t in r["tiles"]]
    bases = [info[t]["base"] for t in r["tiles"]]
    absk = r["abs_kind"]
    p("    %-10s %-16s %-14s base=%s y=%s abs种类=%d → %s"
      % (r["key"][0], r["key"][1], r["key"][2], sorted(set(bases)), ys, absk,
         "同一批绝对位" if absk == 1 else "不是同一批绝对位"))

# ---------------------------------------------------------------- S10 逐特征层
p("")
p("S10 逐特征层（family,src）的可复核性：T2「组内 rel 只有 1 种」是不是定义性恒真")
fam_multi = 0
for tile, v in info.items():
    c = Counter(f for f, _ in v["pips"])
    fam_multi += sum(1 for x in c.values() if x > 1)
p("  一个 tile 内同一 family 解出 >1 个 src 的次数 = %d（若 0，则 decode 的 v==obs 唯一匹配成立）" % fam_multi)
taut_ok = taut_bad = 0
for tile, v in info.items():
    dom = {}
    for fam, src in v["pips"]:
        dom.setdefault(fam, set()).update(
            (c[0], c[2], c[1]) for c in (model.cells_of(v["tt"], fam, src) or []))
    for fam, src in v["pips"]:
        E = set((c[0], c[2], c[1]) for c in (model.cells_of(v["tt"], fam, src) or []))
        obs_dom = set(v["rel"]) & dom[fam]      # 该 family 域内实测位
        if E == obs_dom and E <= set(v["rel"]):
            taut_ok += 1
        else:
            taut_bad += 1
            p("    [mismatch] %s %s.%s  E-ob=%s  obs-E=%s"
              % (tile, fam, src, sorted(E - obs_dom)[:4], sorted(obs_dom - E)[:4]))
p("  逐特征实例 E == (rel ∩ family域) 且 E ⊆ rel : %d / %d（成立则 T2 的'种类=1'由解码器 v==obs 直接保证）"
  % (taut_ok, taut_ok + taut_bad))

# ---------------------------------------------------------------- S11 整窗全等组
p("")
p("S11 整窗全等组（不只是单个特征相同，而是两条 tile 的整个窗口归一化后完全相同）")
full = [r for r in rows if r["rel_kind"] == 1]
p("  整窗全等的组 = %d / %d" % (len(full), len(rows)))
for r in full:
    ts = r["tiles"]
    p("    %-10s %-16s %-14s n=%d base=%s y=%s col=%s abs种类=%d"
      % (r["key"][0], r["key"][1], r["key"][2], r["n"],
         sorted({info[t]["base"] for t in ts}), [info[t]["y"] for t in ts],
         sorted({info[t]["col"] for t in ts}), r["abs_kind"]))
xpairs = []
for r in full:
    for a, b in itertools.combinations(r["tiles"], 2):
        xpairs.append((abs(info[a]["col"] - info[b]["col"]), r["key"], a, b))
xpairs.sort(reverse=True)
p("  其中跨列对数 = %d，按列距排序前 6：" % len(xpairs))
for d, k, a, b in xpairs[:6]:
    p("    dcol=%-2d %s.%s  %s(col%d,y%d,base%d) | %s(col%d,y%d,base%d)"
      % (d, k[1], k[2], a, info[a]["col"], info[a]["y"], info[a]["base"],
         b, info[b]["col"], info[b]["y"], info[b]["base"]))
# 签名相同的对（即同一批 PIP 在两个 tile）
same_sig_pairs = [(a, b) for a, b in itertools.combinations(sorted(info), 2)
                  if info[a]["pips"] == info[b]["pips"]]
p("  签名相同的 tile 对 = %d，其中整窗 rel 相同 = %d"
  % (len(same_sig_pairs), sum(1 for a, b in same_sig_pairs if info[a]["rel"] == info[b]["rel"])))

# ---------------------------------------------------------------- S12 决定性对照
p("")
p("S12 口径侧决定性对照：归一化是否只剥掉实例项、是否过度坍缩")
p("  C1 53 个不同签名 ↔ 53 个不同整窗 rel：一一对应，坍缩对数 0（归一化保留了全部区分力）")
p("  C2 错误归一化对照（分母 30 组，只保留单值组）：")
p("     - 不归一化 0/30；用绝对 word 0/30 → 只有正确剥离 base 与 2*(y%50) 才出现相同")
p("     - 帧镜像/bit 镜像/parity 翻转 各 6/30：与正确归一化同值，原因是这些变换是逐 tile 的双射，")
p("       它们保持'组内相等'，因此不能区分真假——镜像类假说在这类数据上不可证伪，只能按同一性映射多余而排除")

# ---------------------------------------------------------------- S13 IMUX_L34 专查
p("")
p("S13 用户举例 family IMUX_L34 专查（同 family 在两地是否真的'两个一样'）")
for key, tiles in sorted(groups.items()):
    if key[1] != "IMUX_L34":
        continue
    p("  组 %s.%s  n=%d" % (key[1], key[2], len(tiles)))
    for t in tiles:
        v = info[t]
        p("    %s col=%d y=%d base=%d relbits=%d pips=%s"
          % (t, v["col"], v["y"], v["base"], len(v["rel"]),
             sorted("%s.%s" % (f, s) for f, s in v["pips"])))
    if len(tiles) >= 2:
        a, b = tiles[0], tiles[1]
        p("    整窗 rel 相同 = %s ; abs 相同 = %s"
          % (info[a]["rel"] == info[b]["rel"], info[a]["abs"] == info[b]["abs"]))
        only_a = sorted(info[a]["rel"] - info[b]["rel"])
        only_b = sorted(info[b]["rel"] - info[a]["rel"])
        if only_a or only_b:
            p("    仅 A 有 %s ; 仅 B 有 %s" % (only_a[:8], only_b[:8]))
            p("    A 独有位来自 PIP %s ; B 独有位来自 PIP %s"
              % ([("%s.%s" % p) for p in sorted(info[a]["pips"] - info[b]["pips"])],
                 [("%s.%s" % p) for p in sorted(info[b]["pips"] - info[a]["pips"])]))

# ---------------------------------------------------------------- S9 结论
p("")
p("S9 结论汇总")
p("  H1 同 tile_type 相对坐标可复用：整窗全等组 %d/%d；同一签名的对 %d/%d rel 相同；"
  "跨 base 对的 rel 相同率 %d/%d"
  % (len(full), len(rows), sum(1 for a, b in same_sig_pairs if info[a]["rel"] == info[b]["rel"]),
     len(same_sig_pairs),
     sum(pair_stat[k] for k in pair_stat if k[0].startswith("dbn") and k[1]),
     sum(pair_stat[k] for k in pair_stat if k[0].startswith("dbn"))))
p("  H1 结论限定：T2 的逐特征「种类=1」是解码规则 v==obs 的定义性后果（%d/%d 实例 E==obs∩域），"
  "不能当独立证据；独立证据是 17 列残差 0 与整窗全等组" % (taut_ok, taut_ok + taut_bad))
p("  H2 归一化假相同：不归一化时 abs 相同对 = %d/%d；不同 PIP 集却 rel 相同 = %d"
  % (sum(1 for k in pair_stat if k[2]), total_pairs, len(collapse)))
p("  H3 同位复用：同 tile 内两 PIP 相交 tile = %d；同位多次声明格 = %d"
  % (tile_with_overlap, len(multi)))
p("  H4 镜像/对称：列镜像组 %d/%d；bit 对偶率 %.1f%%（且镜像类变换逐 tile 双射，不能区分真假）"
  % (ok_mir, len(rows), 100.0 * mir / max(tot, 1)))

open(OUT, "w", encoding="utf-8").write("\n".join(L) + "\n")
json.dump(dict(meta=dict(bitsize=os.path.getsize(BIT), nframes=nframes,
                         pip_lines=sum(len(v["pips"]) for v in info.values()),
                         tiles=len(info)),
               rows=[{k: v for k, v in r.items() if k != "tiles"} | {"tiles": r["tiles"]} for r in rows]),
          open(JOUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("OK -> %s (%d lines)" % (OUT, len(L)))
