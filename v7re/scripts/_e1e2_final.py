#!/usr/bin/env python3
"""E1+E2 收尾：定位 payload 起点 -> numpy 快速取 64 个位置与 word50 变化。"""
import json
import os
import numpy as np

DIR = r"E:\DEEPSEEK\FPGA比特流逆向\_crc"
SYNC = bytes.fromhex("aa995566")
FW = 101
FB = FW * 4
FRAMES = [31784, 31785, 31786, 31787]
ECC = 50

base_b = open(os.path.join(DIR, "c_base.bit"), "rb").read()
c00 = open(os.path.join(DIR, "c00.bit"), "rb").read()

i = base_b.find(SYNC)
print("sync @", i, "size", len(base_b))

def w(b, off):
    return int.from_bytes(b[off:off + 4], "big")

# 找 payload 起点：使 frame 31786 除 word40/word50 外全 0，且 word40 popcount==1
cands = []
for s in range(i, i + 4000, 4):
    o = s + FB * 31786
    if o + FB > len(c00):
        continue
    ok = True
    p = 0
    for k in range(FW):
        v = w(c00, o + 4 * k)
        if k == 40:
            if bin(v).count("1") != 1:
                ok = False
                break
            p = v
        elif k == ECC:
            continue
        elif v:
            ok = False
            break
    if ok:
        # 其余三帧基流必须全 0
        same = all(w(base_b, s + FB * f + 4 * k) == 0 for f in FRAMES for k in range(FW))
        if same:
            cands.append((s, p, w(c00, o + 4 * ECC)))

print("候选 payload 起点:", [(s, hex(p), hex(e)) for s, p, e in cands])
if not cands:
    raise SystemExit("未定位到对齐")
start = cands[0][0] if len(cands) == 1 else sorted(cands)[0]
print("采用 start =", start, " 相对 sync+4 的偏移 =", start - (i + 4))

def load(p):
    raw = open(p, "rb").read()
    n = (len(raw) - start) // FB
    a = np.frombuffer(raw, dtype=">u4", count=n * FW, offset=start).reshape(n, FW)
    return a

base = load(os.path.join(DIR, "c_base.bit"))
print("base frames:", base.shape)

pos = {}
eccdelta = []
for k in range(64):
    a = load(os.path.join(DIR, "c%02d.bit" % k))
    ch = []
    for f in FRAMES:
        db = np.flatnonzero(base[f] != a[f])
        for wd in db:
            v = int(base[f, wd] ^ a[f, wd])
            for b in range(32):
                if (v >> b) & 1:
                    ch.append((f, int(wd), b))
    d = [c for c in ch if c[1] != ECC]
    e = [c for c in ch if c[1] == ECC]
    assert len(d) == 1, (k, ch)
    pos.setdefault(d[0][0], set()).add((d[0][1], d[0][2]))
    if e:
        eccdelta.append((k, d[0], int(a[d[0][0], ECC]), int(base[d[0][0], ECC])))

for f in FRAMES:
    print("  frame %d: %d 位 %s" % (f, len(pos[f]), sorted(pos[f])))
tot = sorted(set().union(*pos.values()))
print("总位置 %d，word 集合 %s，bit 集合 %s" % (len(sum((list(v) for v in pos.values()), [])),
      sorted({w for w, _ in tot}), sorted({b for _, b in tot})))

print("\nword50 被同步改写的变体数: %d/64" % len(eccdelta))
for r in eccdelta[:6]:
    print("   c%02d pos=%s ECC %s -> %s" % (r[0], r[1], hex(r[3]), hex(r[2])))
vals = sorted({r[2] for r in eccdelta})
print("ECC 取值数 %d, max=0x%X, 是否全 <2^13: %s" % (len(vals), max(vals), all(v < 8192 for v in vals)))

# E1: 跨帧样本计数
print("\n== E1: 跨帧样本 ==")
for i2 in range(3):
    f0, f1 = FRAMES[i2], FRAMES[i2 + 1]
    n = sum(1 for k in range(64) if pos[f0] and pos[f1])
    print("   pair %d->%d 跨帧样本 %d" % (f0, f1, n))
print("   说明：每个变体只在 1 帧上改 1 位 -> 任一帧对的跨帧样本均为 0")

json.dump({"start": start, "positions": {str(k): sorted(v) for k, v in pos.items()},
           "ecc": [[r[0], list(r[1]), r[3], r[2]] for r in eccdelta]},
          open(r"E:\DEEPSEEK\FPGA比特流逆向\v7re\steps\e1e2_result.json", "w"), indent=1)
print("\n写出 v7re/steps/e1e2_result.json")
