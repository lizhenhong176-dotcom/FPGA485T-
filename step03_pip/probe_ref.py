import glob
import os

R = "/opt/lzh/step03/tilepipe3"
os.chdir(R)
refs = sorted(glob.glob("ref_*.dcp"))
bits = sorted(glob.glob("ref_*.bit"))
print("ref dcp:", len(refs), "ref bit:", len(bits))
for d in refs:
    b = d[:-4] + ".bit"
    if not os.path.exists(b):
        bo = d[:-4] + ".bo"
        print("missing bit for", d, "bo exists:", os.path.exists(bo))
        if os.path.exists(bo):
            txt = open(bo, errors="replace").read().splitlines()
            errs = [l for l in txt if "ERROR" in l.upper()]
            print("  errors:", errs[:3])
        break
