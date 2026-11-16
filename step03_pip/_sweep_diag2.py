#!/usr/bin/env python3
"""sweep MIX 的严格归因：把 pred1_missing 按 owner(family,src) 分类，
把 in_pred1 按 family 分类，证明失配 100% 落在长线/bounce 家族。"""
import json, os, sys, collections
sys.path.insert(0, "/opt/lzh/verify/step03_pip")
sys.path.insert(0, "/opt/lzh/v7re")
import pip_law
from bitstream.parser import frames_from_bit

R = "/opt/lzh/step03/sweep1"
ECC = 50

def diff_dir(ref, var):
    out = []
    for i in range(min(len(ref), len(var))):
        a, b = ref[i], var[i]
        if a == b: continue
        for w in range(len(a)):
            if w == ECC: continue
            d = a[w] ^ b[w]
            while d:
                bit = (d & -d).bit_length() - 1; d &= d - 1
                out.append((i, w, bit, (b[w] >> bit) & 1))
    return out

LONG_PREFIX = ("LV_L", "LV", "LH", "LVB_L", "LVB")   # 长线家族前缀

miss_by_fam = collections.Counter()
inpred_by_fam = collections.Counter()
extra_frames = collections.Counter()
noshape_fam = collections.Counter()
tags = sorted(x[5:-5] for x in os.listdir(R) if x.startswith("pips_"))
for tag in tags:
    ref = frames_from_bit(os.path.join(R, "ref_%s.bit" % tag))
    var = frames_from_bit(os.path.join(R, "%s.bit" % tag))
    rows = diff_dir(ref, var)
    obs1 = {(f,w,b) for f,w,b,v in rows if v==1}
    pips = json.load(open(os.path.join(R,"pips_%s.json"%tag)))
    pred1, owner1 = set(), {}
    for p in pips:
        t=p["tile"]
        if not (t.startswith("INT_L_X") or t.startswith("INT_R_X")): continue
        pr = pip_law.predict_family(t,p["sink"],p["src"])
        if not pr:
            noshape_fam[(p["sink"],p["src"])] += 1; continue
        for f,w,b,s in pr:
            if s==1:
                pred1.add((f,w,b)); owner1.setdefault((f,w,b),set()).add((p["sink"],p["src"]))
    for c in obs1 & pred1:
        for fam in owner1[c]: inpred_by_fam[fam]+=1
    for c in pred1 - obs1:
        for fam in owner1.get(c,{("?","?")}): miss_by_fam[fam]+=1
    for c in obs1 - pred1:
        extra_frames[c[0]//5246]+=1   # 按块行归类 truly_extra 落点

def is_long(fam): return fam[0].startswith(LONG_PREFIX) or "BOUNCE" in fam[0]

print("== pred1_MISSING 按 (sink,src) 家族 ==")
tot_miss=0; long_miss=0
for fam,n in miss_by_fam.most_common():
    L = is_long(fam); tot_miss+=n; long_miss += n if L else 0
    print("   %-28s %4d  %s" % ("%s<-%s"%fam, n, "LONG" if L else "*** CLB-COLUMN ***"))
print("   合计 missing=%d, 其中长线/bounce=%d, CLB列家族=%d" % (tot_miss,long_miss,tot_miss-long_miss))

print("\n== in_pred1（命中）按家族 top ==")
for fam,n in inpred_by_fam.most_common(12):
    print("   %-28s %4d  %s" % ("%s<-%s"%fam, n, "LONG" if is_long(fam) else "clb"))

print("\n== no_shape PIP（形状表里没有）==")
for fam,n in noshape_fam.most_common():
    print("   %-28s %4d" % ("%s<-%s"%fam, n))

print("\n== truly_extra 落在哪些块行（frame//5246）==")
for blk,n in sorted(extra_frames.items()):
    print("   block_row=%d  count=%d" % (blk,n))
