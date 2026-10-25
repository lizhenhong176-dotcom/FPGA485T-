import json
a = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8-sig"))
b = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tp3.json", encoding="utf-8-sig"))
def base_bit(L): return 1 + 8*(L%4) + (L//8)
def norm(sources, L):
    frames = [f for m in sources.values() for f, w, bb in m]
    words = [w for m in sources.values() for f, w, bb in m]
    if not frames: return {}
    f0, w0 = min(frames), min(words)
    bb0 = min(bb for m in sources.values() for f, w, bb in m)
    return {s: tuple(sorted((f-f0, w-w0, bb-bb0) for f, w, bb in m)) for s, m in sources.items()}
A = {v["sink"]: norm(v["sources"], int(v["sink"].split("_L")[1])) for v in a.values()}
B = {v["sink"]: norm(v["sources"], int(v["sink"].split("_L")[1])) for v in b.values()}
print("tile1 muxes:", sorted(A, key=lambda s: int(s.split("_L")[1]))[:8])
print("tile3 muxes:", sorted(B, key=lambda s: int(s.split("_L")[1])))
same = diff = 0
for mux in B:
    if mux not in A: continue
    for w, m in B[mux].items():
        if w in A[mux]:
            if A[mux][w] == m: same += 1
            else:
                diff += 1
                if diff <= 5: print("DIFF", mux, w, "tile1", A[mux][w], "tile21", m)
print("same", same, "diff", diff)
