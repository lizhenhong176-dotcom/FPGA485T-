import os, glob, json, re, collections
R="/opt/lzh/step03"
print("=== reach results.txt ===")
rp=os.path.join(R,"reach","results.txt")
if os.path.exists(rp):
    lines=[l.split() for l in open(rp) if l.strip()]
    bytile=collections.Counter(l[2] for l in lines if len(l)>=4 and l[1]=="SINKOK")
    print("SINKOK by tile:", dict(bytile))
    print("total SINKOK", sum(bytile.values()), "lines", len(lines))
    # INT_L mux index -> tag
    lm=collections.defaultdict(list)
    for l in lines:
        if len(l)>=5 and l[1]=="SINKOK" and l[2]=="INT_L_X6Y11":
            m=re.match(r"IMUX_L(\d+)", l[4])
            if m: lm[int(m.group(1))].append((l[3],l[4]))
    missing=[22,28,29,31,32,35,38,40,43,44,45,47]
    print("INT_L_X6Y11 reached mux idx", sorted(lm))
    for x in missing:
        print("  missing",x,"->", lm.get(x))
print("=== tilepipe dirs ===")
for d in ["tilepipe","tilepipe2","tilepipe3","tilepipe4","right"]:
    p=os.path.join(R,d)
    if os.path.isdir(p):
        sinks=glob.glob(os.path.join(p,"*.sink"))
        mux=set()
        for s in sinks:
            t=open(s,errors="ignore").read()
            m=re.search(r"(IMUX_L?\d+)",t)
            if m: mux.add(m.group(1))
        print(d,"sinks",len(sinks),"distinct mux",len(mux),"tile", collections.Counter(re.search(r"(INT_[LR])",open(sinks[0]).read()).group(1) for s in sinks[:1]) if sinks else {})
print("=== which INT_R muxes already done (right) ===")
for d in ["right"]:
    p=os.path.join(R,d)
    mux=set()
    for s in glob.glob(os.path.join(p,"*.sink")):
        m=re.search(r"(IMUX_?L?\d+)", open(s,errors="ignore").read())
        if m: mux.add(m.group(1))
    idx=sorted(int(re.sub(r"\D","",x)) for x in mux)
    print("right INT_R idx done", idx, "count", len(idx))
    allidx=set(range(48))
    print("right INT_R MISSING", sorted(allidx-set(idx)))
print("=== DONE ===")
