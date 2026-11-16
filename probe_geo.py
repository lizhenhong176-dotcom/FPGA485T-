import json,sys,re
tg=json.load(open("tilegrid.json"))
print("tiles",len(tg))
# ? INT_L_X6Y11 ????
def info(n):
    t=tg.get(n)
    if not t: return None
    return (t.get("type"),t.get("grid_x"),t.get("grid_y"),sorted({s.split(".")[-1] if "." in s else s for s in t.get("sites",[])}))
for n in ["INT_L_X6Y11","CLBLL_L_X8Y11","CLBLM_L_X8Y11","CLBLL_L_X9Y11","CLBLM_L_X9Y11","LIOB33_X6Y11"]:
    print(n, info(n))
# ???INT_L ??? CLB ????
print("---- ? grid_x ???? ----")
# tile ????? X ? tile ???INT_L_Xc ?? CLB ????? X(c+?) ? (c+1)
# ???? INT_L_X*Y11 ???????
import collections
byname={n:tg[n] for n in tg}
def east_clb(c,y):
    cands=[]
    for dx in (1,2,3,4):
        for pre in ("CLBLL_L","CLBLM_L"):
            n="%s_X%dY%d"%(pre,c+dx,y)
            if n in byname: cands.append((n,byname[n]["type"]))
    return cands
print("INT_L_X6Y11 east:", east_clb(6,11))
