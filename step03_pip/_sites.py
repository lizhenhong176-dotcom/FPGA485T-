import json
tg=json.load(open("tilegrid_filled.json"))
if "tiles" in tg: tg=tg["tiles"]
for tn in ["CLBLM_L_X8Y11","CLBLL_L_X10Y11","CLBLM_L_X96Y144","CLBLL_L_X100Y144","CLBLM_L_X98Y144","CLBLL_L_X102Y144"]:
    t=tg.get(tn)
    if not t: print(tn,"MISSING"); continue
    sites=t.get("sites",{})
    print(tn,"type",t.get("type"),"sites",list(sites) if isinstance(sites,dict) else sites)
