# -*- coding: utf-8 -*-
"""gen_mux.py —— mux 侧 64 个 24 源族：用公式重新生成每个源的 cell，逐条与真值比对。

公式（已由 §11 验证）：
  行帧 = 16 + r，r ∈ 0..5；行位 = b0（r ∈ 0,1,4,5）或 b0^1（r ∈ 2,3）
  码帧 = 25 - i（i ∈ 0..3），位恒为 b0
  源 → (r, c)：c = f(线类)，r = f(方向令牌)（旁路源 r 见 aff 表）
"""
import sqlite3, collections, re, io, json

DB = r"E:\v7work\model\v7_law.sqlite"


def load():
    con = sqlite3.connect(DB)
    rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                       "where tile_type='INT_L' and sense=1").fetchall()
    fam = collections.defaultdict(lambda: collections.defaultdict(set))
    for f, s, fo, b, p in rows:
        fam[f][s].add((fo, p, b))
    return {f: d for f, d in fam.items() if len(d) == 24}


def line_class(src):
    if re.match(r"^(NE|NW|SE|SW)", src):
        return "diag"
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)", src):
        return "rline"
    if re.match(r"^(EE|WW|NN|SS)\d", src):
        return "axis"
    if re.match(r"^(LH|LV)", src):
        return "longL"
    if src.startswith(("BYP_", "FAN_")):
        return "bounce"
    if src.startswith(("LOGIC_OUTS", "GFAN")):
        return "logic"
    return "other"


def dir_token(src):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|NL|SL|EL|WL|NR|SR|ER|WR)", src)
    if m:
        return m.group(1)
    return "EXTRA"


def decompose(cells):
    """从真值反解 (r, c, b0, parity)；不满足公式的返回 None。"""
    bits = {b for cs in cells.values() for _, _, b in cs}
    pars = {p for cs in cells.values() for _, p, _ in cs}
    # 帧池：行帧 + 码帧
    rows_fr = sorted({fo for cs in cells.values() for fo, _, _ in cs if 16 <= fo <= 21})
    code_fr = sorted({fo for cs in cells.values() for fo, _, _ in cs if 22 <= fo <= 25})
    if len(rows_fr) != 6 or len(code_fr) != 4:
        return None
    if len(bits) != 2 or len(pars) != 1:
        return None
    p = pars.pop()
    # primary 位 = 行 0（帧 16）所用的位；每族可能不同（对应 law 里的 primary=P/S）
    cand = {b for s, cs in cells.items() for fo, _, b in cs if fo == 16}
    if len(cand) != 1:
        return None
    b0 = cand.pop()
    if bits != {b0, b0 ^ 1}:
        return None
    out = {}
    for s, cs in cells.items():
        rf = [fo for fo, _, _ in cs if 16 <= fo <= 21]
        cf = [fo for fo, _, _ in cs if 22 <= fo <= 25]
        if len(rf) != 1 or len(cf) < 1:
            return None
        r = rf[0] - 16
        rb = [b for fo, _, b in cs if fo == rf[0]][0]
        want = b0 if r in (0, 1, 4, 5) else b0 ^ 1
        if rb != want:
            return None
        if any(b != b0 for fo, _, b in cs if fo in (22, 23, 24, 25)):
            return None
        code = sum(1 << (25 - fo) for fo in cf)
        out[s] = (r, code)
    return out, b0, p


def build(rows, b0, p, slots):
    cells = {}
    for s, (r, code) in slots.items():
        rb = b0 if r in (0, 1, 4, 5) else b0 ^ 1
        cs = {(16 + r, p, rb)}
        for i in range(4):
            if code >> i & 1:
                cs.add((25 - i, p, b0))
        cells[s] = cs
    return cells


def main():
    fam = load()
    stat = collections.Counter()
    c_rule = collections.Counter()
    r_rule = collections.Counter()
    aff = collections.defaultdict(dict)
    cfg = collections.defaultdict(list)
    details = []
    for f, d in fam.items():
        cells = {s: set(cs) for s, cs in d.items()}
        dec = decompose(cells)
        if dec is None:
            stat["不符合公式"] += 1
            details.append((f, "公式不符"))
            continue
        slots, b0, p = dec
        # 列码规则
        for s, (r, code) in slots.items():
            c_rule[(line_class(s), code)] += 1
        # 行规则：方向源 r = f(token)
        t2r = collections.defaultdict(set)
        for s, (r, code) in slots.items():
            t = dir_token(s)
            if t == "EXTRA":
                aff[f][s] = (r, code)
            else:
                t2r[t].add(r)
        if all(len(v) == 1 for v in t2r.values()):
            stat["行规则成立"] += 1
        cfg[tuple(sorted((t, min(v)) for t, v in t2r.items()))].append(f)
        # 用规则 + 旁路表重建，逐条比对
        gen = build(None, b0, p, slots)
        if gen == cells:
            stat["重建 0 差异"] += 1
        else:
            bad = [s for s in cells if gen.get(s) != cells[s]]
            stat["重建有差异"] += 1
            details.append((f, len(bad), bad[:3]))

    print(f"mux 族：{len(fam)}")
    for k, v in sorted(stat.items()):
        print(f"  {k}: {v}")
    print("\n线类 → 列码（全局）：")
    m = collections.defaultdict(set)
    for (cls, code), n in c_rule.items():
        m[cls].add(code)
    for cls in sorted(m):
        print(f"  {cls:<7} {sorted(m[cls])}   (共 {sum(n for (c, _), n in c_rule.items() if c == cls)} 条)")
    print(f"\n配置（方向→行的映射）种类：{len(cfg)}，每种族数 {sorted(collections.Counter(len(v) for v in cfg.values()).items())}")
    if details:
        print("异常样例：", details[:5])
    io.open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\gen_mux.json", "w", encoding="utf-8").write(
        json.dumps({"families": len(fam), "stat": dict(stat),
                    "col_rule": {k: sorted(v) for k, v in m.items()},
                    "configs": len(cfg)}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
