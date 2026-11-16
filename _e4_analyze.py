# -*- coding: utf-8 -*-
"""E4 判读：从 _e4_out.txt 取 diff JSON，算 S(word) 并检验对 word 的线性。

模型（E3 已验证 GF(2) 线性、常数为 0）：
    word50 = XOR over 置位位置 p 的 col(p)
    col(word, bit) = S(word) ^ bit ^ (popcount(bit)%2 ? 0x1000 : 0)      [bit<32]
  S(word) 是 13 位的「字相关常数」，word 40 上已测得 S(40)=0x860。
E4 给 word 8/10/12/14 各一个单比特样本，外加 word8 的两位样本做线性自检。
"""
import json
import re
import sys

PATH = sys.argv[1] if len(sys.argv) > 1 else "_e4_out.txt"
raw = open(PATH, encoding="utf-8", errors="replace").read()

m = re.search(r"E4DIFF_JSON_BEGIN(.*?)E4DIFF_JSON_END", raw, re.S)
if not m:
    print("NO JSON BLOCK")
    print(raw[-3000:])
    raise SystemExit(1)
res = json.loads(m.group(1).strip())

Y_OF = {4: 8, 5: 10, 6: 12, 7: 14}
WORD_OF_TAG = {"e4_y4_1": 8, "e4_y4_3": 8, "e4_y5_1": 10, "e4_y6_1": 12, "e4_y7_1": 14}


def par(x):
    return bin(x).count("1") & 1


rows = []
print("=" * 84)
print("E4 逐变体差分")
print("=" * 84)
for tag, v in res["variants"].items():
    if "error" in v:
        print("%-10s ERROR %s" % (tag, v["error"]))
        continue
    cp = v["content_positions"]
    ecc = v["ecc"]
    print("%-10s base=%-9s frames=%-6d 内容位=%-2d 帧=%s" % (
        tag, v["base"], v["base_frames"], len(cp), v["frames_touched"]))
    for p in cp:
        print("      content  frame=%-6d word=%-3d bit=%-2d" % tuple(p))
    for fr, (old, new) in ecc.items():
        print("      ecc      frame=%-6d old=0x%04X new=0x%04X" % (int(fr), old, new))
    rows.append((tag, cp, ecc))

print()
print("=" * 84)
print("S(word) 反推     col = S(word) ^ bit ^ (par(bit)<<12)")
print("=" * 84)
S = {}
for tag, cp, ecc in rows:
    if len(cp) != 1 or len(ecc) != 1:
        continue
    fr, wd, bit = cp[0]
    new = list(ecc.values())[0][1]
    s = new ^ bit ^ (0x1000 if par(bit) else 0)
    S.setdefault(wd, {})[tag] = s
    print("%-10s word=%-3d bit=%-2d col=0x%04X  ->  S(%d)=0x%04X" % (tag, wd, bit, new, wd, s & 0x1FFF))

print()
print("=" * 84)
print("检验 1：同一 word 的两个样本 S 是否一致（word8 内部自检）")
print("=" * 84)
ok_same = None
if 8 in S and len(S[8]) >= 2:
    vals = list(S[8].values())
    same = all(v == vals[0] for v in vals)
    ok_same = same
    print("S(8) 样本 =", ["0x%04X" % v for v in vals], "一致" if same else "**不一致 → 模型 col=S(word)^bit 不成立**")
else:
    print("样本不足")

print()
print("=" * 84)
print("检验 2：S(8)^S(10)^S(12)^S(14) 是否为 0（word 常数对 word 索引线性）")
print("=" * 84)
need = [8, 10, 12, 14]
if all(w in S and S[w] for w in need):
    first = {w: list(S[w].values())[0] for w in need}
    x = 0
    for w in need:
        print("  S(%-3d)=0x%04X" % (w, first[w]))
        x ^= first[w]
    print("  XOR  = 0x%04X   %s" % (x, "== 0  → 线性假设成立" if x == 0 else "!= 0  → **对 word 索引不线性**"))
else:
    print("缺样本：", [w for w in need if w not in S])

print()
print("=" * 84)
print("检验 3：与已知 S(40)=0x0860 的关系")
print("=" * 84)
S40 = 0x860
for w in need:
    if w in S and S[w]:
        s = list(S[w].values())[0]
        print("  S(%-3d)=0x%04X   S(%-3d)^S(40)=0x%04X" % (w, s, w, s ^ S40))
print()
print("  若 S(word)=M*word（13x8 GF(2) 矩阵），则 S(40)=M*40=M*32^M*8，")
print("  可用 S(8)/S(40) 反推 M*32 的候选，再用 S(10)/S(12)/S(14) 检验。")
if 8 in S and S[8]:
    m32 = list(S[8].values())[0] ^ S40
    print("  M*32 候选 = S(8)^S(40) = 0x%04X" % m32)
    for w, mult in ((10, 2), (12, 4), (14, 6)):
        if w in S and S[w]:
            pred = list(S[w].values())[0] ^ m32  # S(w) ^ M*32 猜测不对，仅示意
            print("   (示意) word=%d" % w)
