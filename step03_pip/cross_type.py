import json
a = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8-sig"))
r = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tp2.json", encoding="utf-8-sig"))
def norm(sources):
    frames = [f for m in sources.values() for f, w, b in m]
    if not frames: return {}
    f0 = min(frames); b0 = min(b for m in sources.values() for f, w, b in m)
    return {s: tuple(sorted((f-f0, b-b0) for f, w, b in m)) for s, m in sources.items()}
A = {v["sink"].replace("IMUX_L", ""): norm(v["sources"]) for v in a.values()}
R = {v["sink"].replace("IMUX", ""): norm(v["sources"]) for v in r.values()}
print("L idx:", len(A), "R idx:", len(R))
same = diff = 0; examples = []
for k in sorted(set(A) & set(R), key=int):
    for w in set(A[k]) & set(R[k]):
        if A[k][w] == R[k][w]: same += 1
        else:
            diff += 1
            if len(examples) < 5: examples.append((k, w, A[k][w], R[k][w]))
print("same", same, "diff", diff)
for e in examples: print("DIFF", e)
