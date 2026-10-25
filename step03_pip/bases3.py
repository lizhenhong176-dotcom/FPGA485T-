import csv
rows = list(csv.DictReader(open(r"E:\DEEPSEEK\FPGA比特流逆向\codex_review_framemap_20261024\data\frame_index_far.csv")))
b = {}
for r in rows:
    if r["kind"] != "block": continue
    a = int(r["block_addr"],16)
    if a not in b: b[a] = int(r["frame_index"])
for col in (6,8,10):
    a = 0x400000 | (1<<17) | (col<<7)
    print("col", col, hex(a), "base", b.get(a))
