import csv, collections
rows = list(csv.DictReader(open(r"E:\DEEPSEEK\FPGA比特流逆向\codex_review_framemap_20261024\data\frame_index_far.csv")))
blocks = {}
for r in rows:
    if r["kind"] != "block": continue
    a = int(r["block_addr"], 16)
    if a not in blocks: blocks[a] = (int(r["frame_index"]), int(r["row"]))
def dec(a): return ((a>>23)&7, (a>>22)&1, (a>>17)&0x1f, (a>>7)&0x3ff, a&0x7f)
tgt = [ (a,f,row) for a,(f,row) in blocks.items() if 31680 <= f <= 31720 ]
for a,f,row in sorted(tgt, key=lambda x:x[1])[:6]:
    bt,tb,r,col,mi = dec(a); print(hex(a),"frame",f,"csvrow",row,"bt",bt,"tb",tb,"row",r,"col",col,"minor",mi)
print("--- same col windows for a few cols ---")
for col in (6,7,14,15,60,61):
    cands = sorted([(f,a) for a,(f,row) in blocks.items() if dec(a)[3]==col])[:2]
    print("col", col, [(hex(a), f, dec(a)[2], dec(a)[0], dec(a)[1]) for f,a in cands])
print("--- rows available for col 6 ---")
print(sorted({(dec(a)[2], dec(a)[0], dec(a)[1], f) for a,(f,row) in blocks.items() if dec(a)[3]==6}))
