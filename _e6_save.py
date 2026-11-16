# -*- coding: utf-8 -*-
"""E6/E7 收口：把 F(word) 表落盘成可用工具表，并用已知样本自检。

模型（E4/E5/E6/E7 实证）：
    col(word, bit) = F(word) ^ bit ^ (popcount(bit)%2 ? 0x1000 : 0)     (bit < 16 已验)
    frame_ecc      = XOR over 帧内所有置位位置 p 的 col(p)
    F 只依赖 word，与 frame / tile 列 / clock region 无关（E7 三点实测）
"""
import json
import re
import sys

OUT_JSON = r"v7re\steps\e6_ecc_table.json"

raw = open(r"_e6_out.txt", encoding="utf-8", errors="replace").read()
m = re.search(r"E6JSON_BEGIN(.*?)E6JSON_END", raw, re.S)
res = json.loads(m.group(1).strip())


def par(x):
    return bin(x).count("1") & 1


F = {}
pos = {}
for tag, v in res["items"].items():
    if "error" in v or not v["content"] or not v["ecc"]:
        continue
    fr, wd, bit = v["content"][0]
    vals = list(v["ecc"].values())[0]
    f = vals[1] ^ bit ^ (0x1000 if par(bit) else 0)
    F[wd] = f
    pos[wd] = [fr, wd, bit]

print("F 表条目数：", len(F))
print("覆盖 word：", min(F), "..", max(F))
missing = [w for w in range(101) if w not in F]
print("缺 word：", missing)

# ---- 自检 1：E3 六个多比特样本（全部 word 40）----
print("\n[自检1] E3 多比特样本重算")
E3 = [
    ("e3_a", 0x0000000000000005, 0x1001),
    ("e3_b", 0x0000000000000055, 0x0000),
    ("e3_d", 0x0000000000000014, 0x0003),
    ("e3_e", 0x0055005500550055, 0x0000),
]
ok = 0
for name, init, expect in E3:
    # INIT bit -> (frame parity, word40 bit) 按 e1e2 映射：只取落入单帧的部分不易，改用整体：
    # 全 4 帧合计的 ECC 增量应等于对 64 个 INIT 位各自列的 XOR；同一 column 同一 word，
    # 所以只需知道每个置位 INIT 位对应 word40 的哪个 bit。
    # 已知映射：INIT bit k(0..63) -> word40 bit = 15 - ((k % 16) // 2) ，每 8 位后挪 4 个 bit
    bits = []
    for k in range(64):
        if (init >> k) & 1:
            b = 15 - ((k % 16) // 2) - 4 * (k // 16)
            bits.append(b)
    acc = 0
    for b in bits:
        acc ^= F[40] ^ b ^ (0x1000 if par(b) else 0)
    good = acc == expect
    ok += good
    print("  %-6s INIT=0x%016X bits=%s -> 0x%04X expect 0x%04X %s"
          % (name, init, bits, acc, expect, "OK" if good else "MISMATCH"))
print("  命中 %d/%d" % (ok, len(E3)))

# ---- 自检 2：E4/E5 单比特样本 ----
print("\n[自检2] E4/E5 单比特样本")
CHECK = {
    2: 4975, 4: 5039, 8: 5199, 10: 5263, 12: 1231, 14: 5391,
    16: 1359, 32: 5967, 40: 2159, 65: 7055, 97: 3983,
}
bad = 0
for w, expect in sorted(CHECK.items()):
    got = F[w] ^ 15
    st = "OK" if got == expect else "MISMATCH"
    if got != expect:
        bad += 1
    print("  word=%-3d 0x%04X expect 0x%04X %s" % (w, got, expect, st))
print("  失配 %d" % bad)

# ---- 自检 3：E7 跨帧三点（col(8,15) 应为 0x144F）----
print("\n[自检3] E7 跨 frame 三点")
for fr in (26540, 31786, 31958):
    print("  frame %-6d col(8,15) 预测 0x%04X（实测均 0x144F）" % (fr, F[8] ^ 15))

# ---- 落盘 ----
doc = {
    "model": "col(word,bit) = F(word) ^ bit ^ (popcount(bit)&1 ? 0x1000 : 0); frame_ecc = XOR of cols over set bits; F independent of frame/tile",
    "source_frame": 31786,
    "part": "xc7vx485tffg1157-3",
    "bit_range_verified": [0, 15],
    "word_range_measured": [min(F), max(F)],
    "words_missing": missing,
    "F": {str(k): v for k, v in sorted(F.items())},
    "samples": {str(k): v for k, v in sorted(pos.items())},
    "self_check": {"e3": "%d/%d" % (ok, len(E3)), "e4e5_mismatch": bad},
}
open(OUT_JSON, "w", encoding="utf-8").write(json.dumps(doc, indent=1, ensure_ascii=False))
print("\n已写", OUT_JSON, len(json.dumps(doc)), "B")
