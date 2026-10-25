set -u
python3 -c '
import json,glob,os
for f in sorted(glob.glob("/opt/lzh/step03/*/*.json")):
    try: d=json.load(open(f))
    except Exception as e: print(f,"ERR",e); continue
    print("=====",f,os.path.getsize(f),"B")
    if isinstance(d,dict):
        print(" keys:",list(d.keys())[:12])
        for k,v in list(d.items())[:3]:
            s=json.dumps(v,ensure_ascii=False)
            print("  ",k,":",s[:300])
    else:
        print(" list len",len(d),"first:",json.dumps(d[0],ensure_ascii=False)[:300])
'