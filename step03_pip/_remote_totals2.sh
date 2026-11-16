set -u
export LANG=C LC_ALL=C
python3 - <<'EOF'
import os
root='/opt/lzh/step03'
tot={'bit':[0,0],'bin':[0,0],'dcp':[0,0],'other':[0,0]}
for dp,dn,fn in os.walk(root):
    for f in fn:
        p=os.path.join(dp,f)
        try: s=os.path.getsize(p)
        except OSError: continue
        if f.endswith('.bit'): k='bit'
        elif f.endswith('.bin'): k='bin'
        elif f.endswith('.dcp'): k='dcp'
        else: k='other'
        tot[k][0]+=1; tot[k][1]+=s
g=1073741824
for k,(n,b) in tot.items():
    print("%-6s n=%-6d %8.2f GB" % (k, n, b/g))
print("sum GB %.2f" % (sum(v[1] for v in tot.values())/g))
EOF
