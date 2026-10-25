import json, re
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\holdout.json", encoding="utf-8"))
def f(L):
    return 22 + ((L // 4) % 2), 1 + 8 * (L % 4) + (L // 8)
hit = miss = 0
for tag, rec in sorted(d.items()):
    m = re.search(r"IMUX(?:_L)?(\d+)", rec["sink"] or "")
    if not m:
        print("NO SINK", tag); continue
    L = int(m.group(1))
    w, b = f(L)
    obs = {(x, y) for _f, x, y in rec["config"]}
    ok = (w, b) in obs or (w, max(0, b - 1)) in obs or (w, b + 1) in obs
    if ok: hit += 1
    else:
        miss += 1
        print("MISS", tag, "IMUX", L, "pred", (w, b), "obs", sorted(obs))
print("holdout hit %d / %d" % (hit, hit + miss))
