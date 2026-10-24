#!/usr/bin/env python3
"""对表4: STEP01 RapidWright 模板 PIP 枚举 vs prjxray artix7 (segbits + ppips) 覆盖率匹配

命名映射: 本地 pip_defs (src, dst, ...) -> prjxray `TILE.DST.SRC`(目的在前)
"""
import json
import re

BASE = r"E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7"
TPL = r"E:\v7work\_curated_20261021\routing\out_routing\templates"


def load_pjx(t):
    seg, pse = set(), {}
    for line in open(f"{BASE}\\segbits_{t.lower()}.db", encoding="utf-8"):
        m = re.match(re.escape(t) + r"\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)\s", line)
        if m:
            seg.add((m.group(1), m.group(2)))
    for line in open(f"{BASE}\\ppips_{t.lower()}.db", encoding="utf-8"):
        m = re.match(re.escape(t) + r"\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)\s+(\w+)", line)
        if m:
            pse[(m.group(1), m.group(2))] = m.group(3)
    return seg, pse


def main():
    print(f"{'tile':10} {'RW枚举':>6} {'有位∩':>6} {'伪∩':>5} {'RW缺':>4} {'pjx多':>4}")
    for t in ["INT_L", "INT_R", "CLBLL_L", "CLBLL_R", "CLBLM_L", "CLBLM_R"]:
        d = json.load(open(f"{TPL}\\{t}.json", encoding="utf-8"))
        rw = {(dst, src) for src, dst, f0, f1 in d["pip_defs"]}
        seg, pse = load_pjx(t)
        print(f"{t:10} {len(rw):>6} {len(rw & seg):>6} {len(rw & set(pse)):>5} "
              f"{len(rw - seg - set(pse)):>4} {len((seg | set(pse)) - rw):>4}")
        miss = rw - seg - set(pse)
        if miss:
            print("   RW缺样例:", sorted(miss)[:4])
        extra = (seg | set(pse)) - rw
        if extra:
            print("   pjx多样例:", sorted(extra)[:4])


if __name__ == "__main__":
    main()
