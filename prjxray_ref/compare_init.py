#!/usr/bin/env python3
"""对表3: 本地 V7 实测 CLBLM_R LUT6 INIT (256条) vs prjxray artix7 segbits_clblm_r.db

映射规则:
  本地:  CLBLM_R.SLICEM_X0.<X>6LUT.INIT[i] <frame>_<bitidx_abs>   (bitidx_abs = word_abs*32+bit, word 基址 20, Y10 行)
  prjxray: CLBLM_R.SLICEM_X0.<X>LUT.INIT[i]   <frame>_<bitidx_rel>  (word 相对)
  判定: frame 相等 且 bitidx_abs - 640 == bitidx_rel
"""
import re
import sys

LOCAL = r"E:\v7work\m2\clb_shell\segbits_CLBLM_R.db"
PJX = r"E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7\segbits_clblm_r.db"
WORD_BASE = 20  # CLBLM_R_X7Y10, r=10 -> word = 2*10 = 20

def parse_local(path):
    d = {}
    rx = re.compile(r"CLBLM_R\.(SLICE[LM]_X\d)\.([A-D])6LUT\.INIT\[(\d+)\]\s+(\d+)_(\d+)")
    for line in open(path, encoding="utf-8"):
        m = rx.match(line.strip())
        if m:
            site, lut, idx, fr, bit = m.groups()
            d[(site, lut, int(idx))] = (int(fr), int(bit))
    return d

def parse_pjx(path):
    d = {}
    rx = re.compile(r"CLBLM_R\.(SLICE[LM]_X\d)\.([A-D])LUT\.INIT\[(\d+)\]\s+(\d+)_(\d+)")
    for line in open(path, encoding="utf-8"):
        m = rx.match(line.strip())
        if m:
            site, lut, idx, fr, bit = m.groups()
            d.setdefault((site, lut, int(idx)), []).append((int(fr), int(bit)))
    return d

def main():
    local = parse_local(LOCAL)
    pjx = parse_pjx(PJX)
    print(f"本地条目: {len(local)}  prjxray INIT 条目: {sum(len(v) for v in pjx.values())}")
    ok = frame_bad = bit_bad = missing = multi = 0
    fails = []
    for key, (lf, lb) in sorted(local.items()):
        if key not in pjx:
            missing += 1
            fails.append(("MISSING", key, (lf, lb)))
            continue
        ents = pjx[key]
        if len(ents) > 1:
            multi += 1
        rel = lb - WORD_BASE * 32
        # 任一 prjxray 位组合命中即算匹配
        if any(pf == lf and pb == rel for pf, pb in ents):
            ok += 1
        else:
            best = ents[0]
            if best[0] != lf:
                frame_bad += 1
            else:
                bit_bad += 1
            fails.append(("MISMATCH", key, (lf, lb), "期望 rel=%d 实际 %s" % (rel, ents)))
    print(f"匹配: {ok}/{len(local)}  帧不匹配: {frame_bad}  位不匹配: {bit_bad}  缺失: {missing}  多位条目: {multi}")
    for f in fails[:20]:
        print(" ", f)
    # 附加: prjxray SLICEM_X0 覆盖哪些 LUT/位段
    for lut in "ABCD":
        bits = sorted(b for (s, l, i), v in pjx.items() if s == "SLICEM_X0" and l == lut for _, b in v)
        frames = sorted(f for (s, l, i), v in pjx.items() if s == "SLICEM_X0" and l == lut for f, _ in v)
        if bits:
            print(f"prjxray SLICEM_X0.{lut}LUT: 帧范围 {frames[0]}-{frames[-1]}, 位段 {min(bits)}-{max(bits)}")
    return 0 if not fails else 1

if __name__ == "__main__":
    sys.exit(main())
