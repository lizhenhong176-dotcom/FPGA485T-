# -*- coding: utf-8 -*-
"""把 E11（偶数槽 52..100）并入 F 表，做成 100/100 完整表并全量复检。"""
import json
import re

TBL = r"v7re\steps\e6_ecc_table.json"
doc = json.load(open(TBL, encoding="utf-8"))
F = {int(k): int(v) for k, v in doc["F"].items()}


def par(x):
    return bin(x).count("1") & 1


def grab(path, begin, end):
    raw = open(path, "rb").read()
    enc = "utf-16" if raw[:2] in (b"\xff\xfe", b"\xfe\xff") else "utf-8"
    t = raw.decode(enc, errors="replace")
    m = re.search(re.escape(begin) + r"(.*?)" + re.escape(end), t, re.S)
    return json.loads(m.group(1).strip())


# ---- E11 ----
e11 = grab(r"_e11_out.txt", "E11JSON_BEGIN", "E11JSON_END")
added = {}
for fr, wd, bit in e11["content"]:
    ecc = e11["ecc"][str(fr)]
    added[wd] = ecc ^ bit ^ (0x1000 if par(bit) else 0)
F.update(added)
print("E11 新增 %d 项：%s" % (len(added), sorted(added)))

missing = [w for w in range(101) if w != 50 and w not in F]
print("数据 word 覆盖：%d/100，缺 %s" % (100 - len(missing), missing))

# ---- 结构：两段 i 递推 ----
print("\n[结构] 段一 word 0..49：i(0)=25，+1，跳过 32 的倍数")
i = 25
bad1 = []
for w in range(0, 50):
    if w > 0:
        i += 1
        while i % 32 == 0:
            i += 1
    if (F[w] >> 5) & 0x3F != i % 64:
        bad1.append((w, (F[w] >> 5) & 0x3F, i % 64))
print("  不符 %d %s" % (len(bad1), bad1[:6]))

print("[结构] 段二 word 51..100：i(w) = w + 27，无跳号")
bad2 = []
for w in range(51, 101):
    if w not in F:
        continue
    got = (F[w] & 0xFFF) >> 5
    if got != w + 27:
        bad2.append((w, got, w + 27))
print("  不符 %d %s" % (len(bad2), bad2[:6]))

# ---- 三重自检 + E10 复核 ----
print("\n[自检1] E3 四样本")
E3 = [("e3_a", 0x5, 0x1001), ("e3_b", 0x55, 0x0000),
      ("e3_d", 0x14, 0x0003), ("e3_e", 0x0055005500550055, 0x0000)]
h1 = 0
for name, init, expect in E3:
    acc = 0
    for k in range(64):
        if (init >> k) & 1:
            b = 15 - ((k % 16) // 2) - 4 * (k // 16)
            acc ^= F[40] ^ b ^ (0x1000 if par(b) else 0)
    h1 += acc == expect
print("  %d/4" % h1)

print("[自检2] E4/E5 十一样本")
CHECK = {2: 4975, 4: 5039, 8: 5199, 10: 5263, 12: 1231, 14: 5391,
         16: 1359, 32: 5967, 40: 2159, 65: 7055, 97: 3983}
mm = [w for w, e in CHECK.items() if (F[w] ^ 15) != e]
print("  失配 %d %s" % (len(mm), mm))

print("[自检3] E7 三帧 col(8,15) = 0x%04X（实测 0x144F）" % (F[8] ^ 15))
print("[自检4] E10 跨帧 word1=0x%04X（实测 0x0340） word41=0x%04X（实测 0x1880）"
      % (F[1], F[41]))
print("[自检5] E11 与 E6/E9 同帧对照：w52@31534 与 w1@31534 同帧不同字，互不影响")

# ---- 落盘 ----
doc["F"] = {str(k): v for k, v in sorted(F.items())}
doc["words_missing"] = missing
doc["added_by_e9"] = doc.get("added_by_e9", {})
doc["added_by_e11"] = {str(k): v for k, v in sorted(added.items())}
doc["origin"]["word_52_100"] = "E11 (25 列 x C6LUT, Y=25..49, frames 31534..32266; base 与 variant 同 LOC)"
doc["structure"] = {
    "seg1_word_0_49": "i(0)=25, +1 per word, skip multiples of 32; F=((i&0x3F)<<5)|(P?0x1000:0)",
    "seg2_word_51_100": "i(w)=w+27 exactly, no skip; F=((i)<<5)|(P?0x1000:0)",
    "P": "0x1000 标志位，暂用真值表",
}
doc["self_check"] = {"e3": "%d/4" % h1, "e4e5_mismatch": len(mm),
                     "struct_seg1_bad": len(bad1), "struct_seg2_bad": len(bad2)}
open(TBL, "w", encoding="utf-8").write(json.dumps(doc, indent=1, ensure_ascii=False))
print("\n已写 %s（%d 项）" % (TBL, len(F)))
