import io
import re
from pathlib import Path

p = Path(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\gen_p1_designs2.py")
s = io.open(p, encoding="utf-8").read()

old = '''def harvest():
    """从第一轮 xdc 里取出 (cell_kind, loc) 用过的合法 SLICE 站点。"""
    locs = []
    for f in sorted(OUT.glob("d*_*.xdc")):
        for m in re.finditer(r"LOC (SLICE_X\\d+Y\\d+)/(\\w+)", io.open(f, encoding="utf-8").read()):
            locs.append((m.group(1), m.group(2)))
    return locs'''

new = '''def harvest():
    """从第一轮 xdc 收集合法 SLICE 站点，展开成互不重复的 (site, BEL) 池。"""
    sites = []
    for f in sorted(OUT.glob("d*_*.xdc")):
        for m in re.finditer(r"LOC (SLICE_X\\d+Y\\d+)", io.open(f, encoding="utf-8").read()):
            if m.group(1) not in sites:
                sites.append(m.group(1))
    pool = []
    for bel in ("A6LUT", "B6LUT", "C6LUT", "D6LUT"):
        for st in sites:
            pool.append((st, bel))
    return pool'''

assert old in s
s = s.replace(old, new)

# 所有设计里 "SLICE.../A6LUT" 的拼法改成用池里带 BEL 的项
s = s.replace('ios.append(("u%d" % i, "%s/A6LUT" % x))', 'ios.append(("u%d" % i, "%s/%s" % (x, bel)))')
s = s.replace('ios.append(("s%d" % j, "%s/A6LUT" % x))', 'ios.append(("s%d" % j, "%s/%s" % (x, bel)))')
s = s.replace('        x, _y = far[i % 4]', '        x, bel = far[i % 4]')

# 解包：每个设计统一按池顺序取互不重复的项
s = s.replace('''    for i in range(96):
        x, y = locs[i % len(locs)]
        v = (0x9E3779B97F4A7C15''', '''    for i in range(96):
        x, bel = locs[i]
        v = (0x9E3779B97F4A7C15''')
s = s.replace('''        ios.append(("u%d" % i, "%s/%s" % (x, bel)))
    body.append("  assign dout[0] = n[95];")
    body.append("  assign dout[7:1] = 7'b0;")
    write("d8b_dense"''', '''        ios.append(("u%d" % i, "%s/%s" % (x, bel)))
    body.append("  assign dout[0] = n[95];")
    body.append("  assign dout[7:1] = 7'b0;")
    write("d8b_dense"''')
s = s.replace('''        x, y = locs[(i * 7) % len(locs)]''', '''        x, bel = locs[(i * 7) % len(locs)]''')
s = s.replace('''        x, y = locs[(i * 11) % len(locs)]''', '''        x, bel = locs[(i * 11) % len(locs)]''')
s = s.replace('''        x, y = locs[(j * 13 + 5) % len(locs)]''', '''        x, bel = locs[(j * 13 + 5) % len(locs)]''')
s = s.replace('''        x, y = locs[(i * 5) % len(locs)]''', '''        x, bel = locs[(i * 5) % len(locs)]''')

# d10 的 far 从池里按站点序号挑，仍需 BEL
s = s.replace('''    ordered = sorted(locs, key=lambda t: (int(re.search(r"X(\\d+)", t[0]).group(1)),
                                          int(re.search(r"Y(\\d+)", t[0]).group(1))))''',
              '''    ordered = sorted(locs, key=lambda t: (int(re.search(r"X(\\d+)", t[0]).group(1)),
                                          int(re.search(r"Y(\\d+)", t[0]).group(1)),
                                          t[1]))''')

# main 里打印池大小
s = s.replace('print("harvested locs", len(locs), "unique", len(set(locs)))',
              'print("harvested slots", len(locs), "unique", len(set(locs)))')
s = s.replace('''    if not locs:
        raise SystemExit("no locs")''', '''    if len(set(locs)) < 96:
        raise SystemExit("pool too small: %d" % len(set(locs)))''')

io.open(p, "w", encoding="utf-8", newline="\n").write(s)
print("patched generator: unique (site,BEL) pool")
