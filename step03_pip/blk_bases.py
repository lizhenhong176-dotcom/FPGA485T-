import csv, collections
rows = list(csv.DictReader(open(r"E:\DEEPSEEK\FPGA比特流逆向\codex_review_framemap_20261024\data\frame_index_far.csv")))
blocks = collections.OrderedDict()
for r in rows:
    if r["kind"] != "block": continue
    a = int(r["block_addr"], 16)
    if a not in blocks:
        blocks[a] = (int(r["frame_index"]), int(r["row"]))
print("blocks", len(blocks))
def dec(a):
    bt = (a >> 23) & 7; tb = (a >> 22) & 1; row = (a >> 17) & 0x1f; col = (a >> 7) & 0x3ff; minor = a & 0x7f
    return bt, tb, row, col, minor
items = sorted(blocks.items(), key=lambda kv: kv[1][0])
for a, (f, row) in items[:8]:
    print(hex(a), "frame", f, "col", dec(a)[3], "rowfield", dec(a)[2], "csvrow", row, "bt", dec(a)[0], "tb", dec(a)[1], "minor", dec(a)[4])
print("...")
for a, (f, row) in items:
    if dec(a)[3] in (6, 14) and dec(a)[2] in (6, 7):
        print("COL", dec(a)[3], "row", dec(a)[2], hex(a), "frame", f)
