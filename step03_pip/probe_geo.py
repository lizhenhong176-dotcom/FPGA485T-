import json,re
tg=json.load(open("tilegrid_filled.json"))
if isinstance(tg,dict) and "tiles" in tg: tg=tg["tiles"]
print("tiles",len(tg), "sample keys", list(tg)[:2])
def g(n):
    t=tg.get(n)
    if not t: return None
    return t.get("type"),t.get("grid_x"),t.get("grid_y")
print("INT_L_X6Y11",g("INT_L_X6Y11"))
# ?? CLB ????
byname=set(tg)
def east(c,y):
    r=[]
    for dx in range(1,5):
        for pre in ("CLBLL_L","CLBLM_L"):
            n="%s_X%dY%d"%(pre,c+dx,y)
            if n in byname: r.append((n,tg[n]["type"]))
    return r
print("INT_L_X6Y11 east cols:", east(6,11))
# ???? INT_L tile??????? CLBLM ?
def clbtype(name):  # from tile name prefix
    return "M" if "CLBLM" in name else ("L" if "CLBLL" in name else "?")
cands=[]
for n,t in tg.items():
    m=re.match(r"INT_L_X(\d+)Y(\d+)$",n)
    if not m: continue
    c,y=int(m.group(1)),int(m.group(2))
    e=east(c,y)
    if len(e)>=2:
        # ?????
        two=e[:2]
        types=[clbtype(x[0]) for x in two]
        if types==["M","M"]:
            cands.append((n,two))
print("total INT_L tiles:",sum(1 for n in tg if re.match(r'INT_L_X\d+Y\d+$',n)))
print("CLBLM+CLBLM east INT_L count:",len(cands))
for n,two in cands[:12]:
    print("  ",n,"->",two)
