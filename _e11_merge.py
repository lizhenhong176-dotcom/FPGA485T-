# -*- coding: utf-8 -*-
"""合并 E9(奇槽 word 1..49) + E10(跨帧复核) 到 E6 的 F 表，并重跑三重自检。"""
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


# ---- E9_lo：25 个奇槽 word ----
e9 = grab(r"_e9_out.txt", "E9JSON_BEGIN", "E9JSON_END")
lo = e9["items"]["e9_lo"]
added = {}
for fr, wd, bit in lo["content"]:
    ecc = lo["ecc"][str(fr)]
    f = ecc ^ bit ^ (0x1000 if par(bit) else 0)
    added[wd] = f
    F[wd] = f
print("E9_lo 新增 %d 项：%s" % (len(added), sorted(added)))

# ---- E10：跨帧复核（同一 word 换个 frame/列，值应相同）----
e10 = grab(r"_e10_out.txt", "E10JSON_BEGIN", "E10JSON_END")
ok = 0
for tag in ("e10_w1", "e10_w41"):
    fr, wd, bit = e10["items"][tag]["content"][0]
    ecc = e10["items"][tag]["ecc"][str(fr)]
    f = ecc ^ bit ^ (0x1000 if par(bit) else 0)
    good = added.get(wd) == f
    ok += good
    print("  %-9s frame=%-6d word=%-3d F=0x%04X  E9 值=0x%04X %s"
          % (tag, fr, wd, f, added.get(wd, -1), "OK" if good else "MISMATCH"))
print("E10 跨帧复核 %d/2" % ok)

# ---- 结构检验：i(word) = (F>>5) & 0x3F 的递推 ----
print("\n[结构] i(word) 递推：i(0)=25，每增一 word 先 +1，若 i%32==0 再 +1")
i = 25
bad = []
for w in range(0, 50):
    if w > 0:
        i += 1
        while i % 32 == 0:
            i += 1
    if w in F:
        got = (F[w] >> 5) & 0x3F
        if got != i % 64:
            bad.append((w, got, i))
print("  不符 %d 项%s" % (len(bad), "" if not bad else "：" + str(bad[:8])))

# ---- 三重自检 ----
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

print("[自检3] E7 三帧 col(8,15)=0x144F -> 0x%04X" % (F[8] ^ 15))

# ---- 落盘 ----
missing = [w for w in range(101) if w != 50 and w not in F]
doc["F"] = {str(k): v for k, v in sorted(F.items())}
doc["words_missing"] = missing
doc["added_by_e9"] = {str(k): v for k, v in sorted(added.items())}
doc["cross_frame_check"] = {"e10": "%d/2" % ok, "frame": 31958, "words": [1, 41]}
doc["origin"] = {
    "parity0_slots": "E6 (SLICE_X12Y0..49 A6LUT, frame 31786)",
    "parity1_slots": "E9_lo (25 列 x C6LUT, frames 31534..32266)",
    "cross_frame": "E10 (SLICE_X20Y0 / X20Y20 C6LUT, frame 31958) + E7 (frame 26540/31786/31958)",
}
doc["self_check"] = {"e3": "%d/4" % h1, "e4e5_mismatch": len(mm), "e10": "%d/2" % ok}
open(TBL, "w", encoding="utf-8").write(json.dumps(doc, indent=1, ensure_ascii=False))
print("\n表 %d 项，缺 %d 项：%s" % (len(F), len(missing), missing))
print("已写", TBL)
