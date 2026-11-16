#!/usr/bin/env python3
"""诊断 sweep 的 MIX：把每个设计的 obs 相对 pred1/pred0 分类，定位是哪条 PIP 造成。"""
import json, os, sys
sys.path.insert(0, "/opt/lzh/verify/step03_pip")
import pip_law

R = "/opt/lzh/step03/sweep1"
ECC = 50

def frames_from(p):
    sys.path.insert(0, "/opt/lzh/v7re")
    from bitstream.parser import frames_from_bit
    return frames_from_bit(p)

def diff_dir(ref, var):
    out = []
    for i in range(min(len(ref), len(var))):
        a, b = ref[i], var[i]
        if a == b:
            continue
        for w in range(len(a)):
            if w == ECC:
                continue
            d = a[w] ^ b[w]
            while d:
                bit = (d & -d).bit_length() - 1
                d &= d - 1
                out.append((i, w, bit, (b[w] >> bit) & 1))
    return out

tags = sorted(x[5:-5] for x in os.listdir(R) if x.startswith("pips_"))
grand = {"in_pred1":0,"in_pred0_only":0,"truly_extra":0,"pred1_missing":0}
for tag in tags:
    ref = frames_from(os.path.join(R, "ref_%s.bit" % tag))
    var = frames_from(os.path.join(R, "%s.bit" % tag))
    rows = diff_dir(ref, var)
    obs1 = {(f,w,b) for f,w,b,v in rows if v==1}
    obs0 = {(f,w,b) for f,w,b,v in rows if v==0}
    pips = json.load(open(os.path.join(R,"pips_%s.json"%tag)))
    pred1, pred0 = set(), set()
    owner1 = {}   # cell -> list of (tile,sink,src)
    noshape = []
    for p in pips:
        t=p["tile"]
        if not (t.startswith("INT_L_X") or t.startswith("INT_R_X")):
            continue
        pr = pip_law.predict_family(t,p["sink"],p["src"])
        if not pr:
            noshape.append((t,p["sink"],p["src"])); continue
        for f,w,b,s in pr:
            if s==1:
                pred1.add((f,w,b)); owner1.setdefault((f,w,b),[]).append((t,p["sink"],p["src"]))
            else:
                pred0.add((f,w,b))
    in_pred1   = obs1 & pred1
    pred0_only = obs1 - pred1            # 置位但只在 pred0 或完全没预测
    in_pred0   = pred0_only & pred0
    truly_extra= pred0_only - pred0
    pred1_miss = pred1 - obs1
    grand["in_pred1"]+=len(in_pred1); grand["in_pred0_only"]+=len(in_pred0)
    grand["truly_extra"]+=len(truly_extra); grand["pred1_missing"]+=len(pred1_miss)
    status = "EXACT" if not (in_pred0 or truly_extra or pred1_miss) else "MIX"
    if status=="MIX" or truly_extra or in_pred0:
        print("== %s  %s  obs1=%d pred1=%d  置位∈pred0=%d 真extra=%d pred1漏=%d noshape=%d"
              % (tag,status,len(obs1),len(pred1),len(in_pred0),len(truly_extra),len(pred1_miss),len(noshape)))
        for c in sorted(truly_extra)[:6]:
            print("    TRULY_EXTRA %s  (该格无 sense=1 owner)" % (c,))
        for c in sorted(in_pred0)[:6]:
            print("    SET_BUT_pred0 %s" % (c,))
        for c in sorted(pred1_miss)[:6]:
            ow = owner1.get(c,[])
            print("    pred1_MISSING %s  owner=%s" % (c, ow[:2]))
        if obs0:
            print("    清零位 %d 个（示例 %s）" % (len(obs0), sorted(obs0)[:4]))
        if noshape:
            print("    no_shape PIP: %s" % noshape[:4])
print("\nGRAND:", json.dumps(grand,ensure_ascii=False))
