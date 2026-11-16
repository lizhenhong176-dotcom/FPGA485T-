export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/hclk8 || exit 1
python3 - <<'PY'
import struct, json, collections
SYNC=b'\xaa\x99\x55\x66'
def payload(path):
    d=open(path,'rb').read(); i=d.find(SYNC); pos=i+4; n=len(d); out=[]
    while pos+4<=n:
        h=struct.unpack(">I",d[pos:pos+4])[0]
        typ=(h>>29)&7; op=(h>>27)&3; cnt=h&0x7fffffff
        pos+=4
        if typ==0: continue
        if typ==1:
            if cnt>4096 or pos+4*cnt>n: break
            pos+=4*cnt; continue
        if typ==2:
            if op&1: continue            # read
            if cnt>6000000 or pos+4*cnt>n: break
            out.extend(struct.unpack(">%dI"%cnt, d[pos:pos+4*cnt])); pos+=4*cnt
            continue
        break
    return out
w=payload('out/m_def.bit')
print("words",len(w), "frames", len(w)//101)
FW=101
def frame_word(base, off, wi):
    return w[(base+off)*FW+wi]
bases={'band4_col33(X88Y338)':22118,'band6_col33(X88Y26)':32610}
res={}
for name,b in bases.items():
    hits=collections.defaultdict(dict)
    for off in range(26,30):
        for wi in range(FW):
            v=frame_word(b,off,wi); hi,lo=(v>>16)&0xffff, v&0xffff
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
