# -*- coding: utf-8 -*-
"""E6 判读：F(word) 全表 + 线性递推 T 的存在性检验。

模型（E4/E5 已定）：
    col(word, bit) = F(word) ^ bit ^ (popcount(bit)%2 ? 0x1000 : 0)     (bit<16)
    F(word) = col ^ bit ^ (par<<12)
E6 给 word 0,2,...,98 的 F 值（全部落在 frame 31786、bit 15）。
检验：
    H1  col 只依赖 (word,bit)，与 frame 无关          → 全部 frame 必须是 31786
    H2  F(word+2) = T * F(word)，T 为固定 13x13 GF(2) 矩阵（CRC/幂次结构）
    H3  F(word+2) = T * F(word) ^ c（仿射版）
    H4  F(2w) = Q * F(w)（Frobenius/平方结构）
"""
import json
import re
import sys

PATH = sys.argv[1] if len(sys.argv) > 1 else "_e6_out.txt"
raw = open(PATH, encoding="utf-8", errors="replace").read()
m = re.search(r"E6JSON_BEGIN(.*?)E6JSON_END", raw, re.S)
if not m:
    print("NO JSON BLOCK; tail:")
    print(raw[-2000:])
    raise SystemExit(1)
res = json.loads(m.group(1).strip())

print("base_words =", res["base_words"], " expected 5067776")


def par(x):
    return bin(x).count("1") & 1


F = {}
odd = {}
bad = []
for tag, v in sorted(res["items"].items(), key=lambda kv: int(kv[0].replace("e6_y", ""))):
    y = int(tag.replace("e6_y", ""))
    if "error" in v:
        bad.append((tag, v["error"]))
        continue
    cp = v["content"]
    ecc = v["ecc"]
    if len(cp) != 1 or len(ecc) != 1:
        bad.append((tag, "content=%d ecc=%d %s" % (len(cp), len(ecc), cp)))
        continue
    fr, wd, bit = cp[0]
    fr2, vals = list(ecc.items())[0]
    if str(fr) != str(fr2):
        bad.append((tag, "frame mismatch %s %s" % (fr, fr2)))
        continue
    new = vals[1]
    f = new ^ bit ^ (0x1000 if par(bit) else 0)
    if par(new & 0x1FFF) and False:
        pass
    (F if wd % 2 == 0 else odd)[wd] = f

if bad:
    print("\n!! 异常项：")
    for b in bad:
        print("   ", b)

print("\n=== F(word) 全表（偶数 word） ===")
print("Y   word  col      F         k=F>>5")
keys = sorted(F)
for y, w in enumerate(range(0, 99, 2)):
    if w in F:
        f = F[w]
        print("%-3d %-5d 0x%04X   0x%04X   0x%02X" % (y, w, f ^ 15, f, f >> 5))
print("\n奇数 word 样本：", {w: "0x%04X" % v for w, v in odd.items()})

frames = set()
print("\n所有样本帧集合检查：见各 content 帧（应仅 31786）")


def gf2_solve(rows, rhs, nvars):
    """rows/rhs 为 int；返回 (sol_list_or_None, rank, contradiction)。"""
    a = [[(r >> i) & 1 for i in range(nvars)] + [(b & 1)] for r, b in zip(rows, rhs)]
    n = len(a)
    rank = 0
    piv = []
    for col in range(nvars):
        p = None
        for r in range(rank, n):
            if a[r][col]:
                p = r
                break
        if p is None:
            continue
        a[rank], a[p] = a[p], a[rank]
        for r in range(n):
            if r != rank and a[r][col]:
                a[r] = [x ^ y for x, y in zip(a[r], a[rank])]
        piv.append(col)
        rank += 1
    for r in range(n):
        if all(x == 0 for x in a[r][:nvars]) and a[r][nvars]:
            return None, rank, True
    sol = [0] * nvars
    for i, col in enumerate(piv):
        sol[col] = a[i][nvars]
    return sol, rank, False


def apply_T(t, v, nvars=13):
    out = 0
    for j in range(nvars):
        b = par(v & t[j]) if isinstance(t, list) else 0
        out |= b << j
    return out


print("\n=== H2/H3：F(word+2) = T*F(word) ? ===")
ws = [w for w in keys if w + 2 in F]
print("可用步长2 的对数：", len(ws))
rows_per_j = [[], [], [], [], [], [], [], [], [], [], [], [], []]
rhs_per_j = [[], [], [], [], [], [], [], [], [], [], [], [], []]
consts = []
for w in ws:
    v = F[w]
    tgt = F[w + 2]
    for j in range(13):
        rows_per_j[j].append(v)
        rhs_per_j[j].append((tgt >> j) & 1)
t_full = []
ok_T = True
for j in range(13):
    sol, rank, contra = gf2_solve(rows_per_j[j], rhs_per_j[j], 13)
    if contra:
        ok_T = False
        print("  j=%-2d 矛盾（rank=%d/%d）→ H2 否" % (j, rank, len(rows_per_j[j])))
        t_full.append(None)
    else:
        t_full.append(sol)
        print("  j=%-2d rank=%-2d/%d 解出" % (j, rank, len(rows_per_j[j])))

if ok_T:
    print("  → H2 成立：存在固定 T")
    bad_pred = []
    for w in ws:
        pred = 0
        for j in range(13):
            pred |= (par(F[w] & t_full[j])) << j
        if pred != F[w + 2]:
            bad_pred.append((w, "%04X" % pred, "%04X" % F[w + 2]))
    print("  自检失配：", bad_pred if bad_pred else "无（49/49 全中）")
    # 外推到步长 4（T^2）
    errs = 0
    for w in [x for x in keys if x + 4 in F]:
        v = F[w]
        for _ in range(2):
            nv = 0
            for j in range(13):
                nv |= (par(v & t_full[j])) << j
            v = nv
        if v != F[w + 4]:
            errs += 1
    print("  步长4 外推错误数：", errs, "/", len([x for x in keys if x + 4 in F]))
else:
    print("  → H2 否证（至少一个输出位矛盾）")

print("\n=== H4：F(2w) = Q*F(w) ? ===")
pairs = [(w, 2 * w) for w in keys if 2 * w in F]
print("可用对数：", len(pairs))
ok_Q = True
q_full = []
for j in range(13):
    rows, rhs = [], []
    for a_, b_ in pairs:
        rows.append(F[a_])
        rhs.append((F[b_] >> j) & 1)
    sol, rank, contra = gf2_solve(rows, rhs, 13)
    if contra:
        ok_Q = False
        print("  j=%-2d 矛盾 rank=%d/%d" % (j, rank, len(rows)))
        q_full.append(None)
    else:
        q_full.append(sol)
if ok_Q:
    print("  → H4 成立：存在固定平方映射 Q")
else:
    print("  → H4 否证")

print("\n=== 序列 k=F>>5 一览（看有无明显周期/幂次） ===")
ks = [(w, F[w] >> 5) for w in keys]
print(" ".join("%d:%02X" % (w, k) for w, k in ks))
