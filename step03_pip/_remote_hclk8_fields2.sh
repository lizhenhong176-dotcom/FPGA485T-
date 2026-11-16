export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hclk8 || exit 1
python3 - <<'PY'
import sys, json, collections
sys.path.insert(0,'/opt/lzh/v7re')
from bitstream.parser import frames_from_bit
fr = frames_from_bit('out/m_def.bit')
print("frames", len(fr), "words", len(fr[0]))
bases={'band4_col33(X88Y338)':22118,'band6_col33(X88Y26)':32610}
res={}
for name,b in bases.items():
    hits=collections.defaultdict(dict)
    for off in range(26,30):
        row = fr[b+off]
        for wi,v in enumerate(row):
            hi,lo=(v>>16)&0xffff, v&0xffff
            if hi in (0xd800,0xda00) or lo in (0xd800,0xda00):
                hits[f"off{off}"][wi]=(hex(hi),hex(lo))
    res[name]=hits
    print("\n==",name,"命中字数",sum(len(v) for v in hits.values()))
    for off in sorted(hits):
        print(" ",off, sorted(hits[off].items()))
json.dump({k:{o:{str(kk):vv for kk,vv in v.items()} for o,v in d.items()} for k,d in res.items()},
          open('out/hclk_fields.json','w'))
print("\nWROTE out/hclk_fields.json")
PY
