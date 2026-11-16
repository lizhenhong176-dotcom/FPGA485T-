#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""repro.py —— 一键复现 headline 数字。

用法:
    python repro.py            # 跑全部检查
    python repro.py -k mux     # 只跑名字含 mux 的检查

每个检查 = 一条命令 + 一个正则期望。全部 PASS 才打印 OVERALL: PASS。
任何 FAIL 会打印该命令的完整 stdout 尾部，便于定位。
数字的权威登记表见 SINGLE_SOURCE_OF_TRUTH.md。
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
import time
from dataclasses import dataclass


@dataclass
class Check:
    name: str
    cmd: list[str]
    pattern: str          # 必须在 stdout 中出现的正则
    expect: str           # 期望匹配到的文本（只用于显示）
    timeout: int = 3600


CHECKS: list[Check] = [
    Check(
        "slots.coverage",
        [sys.executable, "step03_pip/gen_slots.py"],
        r"3552/3634",
        "3552/3634 = 97.7%",
    ),
    Check(
        "slots.families",
        [sys.executable, "step03_pip/gen_slots.py"],
        r"族数 172",
        "族数 172",
    ),
    Check(
        "verify.INT_L",
        [sys.executable, "v7re/scripts/verify_all_pip.py", "--tile-type", "INT_L"],
        r"精确命中：3634",
        "3634/3634",
    ),
    Check(
        "verify.INT_R",
        [sys.executable, "v7re/scripts/verify_all_pip.py", "--tile-type", "INT_R", "--normalize"],
        r"精确命中：3634",
        "3634/3634",
    ),
    Check(
        "mux.law",
        [sys.executable, "v7re/scripts/pip_reuse_law.py", "--verify"],
        r"1536 / 1536",
        "1536/1536",
    ),
    Check(
        "beg.shape",
        [sys.executable, "v7re/scripts/beg_families.py", "--report"],
        r"32 / 32",
        "32/32 完全二分",
    ),
    Check(
        "row.generator",
        [sys.executable, "step03_pip/gen_mux_rowlaw.py"],
        r"2048\s*/\s*2048",
        "2048/2048",
    ),
    Check(
        "tiles.instances",
        [sys.executable, "v7re/scripts/all_int_tiles_check.py", "--bit", "_tilecov2/cov2.bit"],
        r"residual=0",
        "residual 0 / 23.66%",
    ),
    Check(
        "figs.data",
        [sys.executable, "make_fig_data.py", "--check"],
        r"fig5_clb_bits\s+2,893",
        "figs 6 张图数据",
    ),
    Check(
        "frames.full",
        [sys.executable, "-c",
         "import sqlite3;c=sqlite3.connect(r'E:\\v7work\\model\\v7_law.sqlite');"
         "print(c.execute('select count(*),sum(n_frames) from frame_blocks_full').fetchone())"],
        r"\(1183, 50148\)",
        "1,183 块 / 50,148 帧",
    ),
    Check(
        "figs.sum",
        [sys.executable, "-c",
         "import csv;r=list(csv.DictReader(open('figs/fig6_cells_per_feature.csv')));"
         "print('sum',sum(int(x['cells_per_family'])*int(x['n_families']) for x in r))"],
        r"sum 8900",
        "Σ(格数×族数)=8900",
    ),
    Check(
        "unit.tests",
        [sys.executable, "-m", "pytest", "v7re/tests", "-q", "-p", "no:cacheprovider"],
        r"15 passed",
        "15 passed",
    ),
]


def run(check: Check) -> tuple[bool, str, float]:
    t0 = time.time()
    try:
        p = subprocess.run(
            check.cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=check.timeout,
        )
    except subprocess.TimeoutExpired:
        return False, f"TIMEOUT after {check.timeout}s", time.time() - t0
    out = (p.stdout or "") + (p.stderr or "")
    ok = p.returncode == 0 and re.search(check.pattern, out) is not None
    tail = "\n".join(out.strip().splitlines()[-12:]) if not ok else ""
    return ok, tail, time.time() - t0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("-k", default="", help="只跑名字包含该子串的检查")
    args = ap.parse_args()

    checks = [c for c in CHECKS if args.k in c.name]
    if not checks:
        print(f"no check matches {args.k!r}")
        return 2

    print(f"repro: {len(checks)} check(s)")
    print(f"{'check':22s} {'expect':22s} {'time':>7s}  result")
    print("-" * 70)
    failed: list[str] = []
    for c in checks:
        ok, tail, dt = run(c)
        print(f"{c.name:22s} {c.expect:22s} {dt:6.1f}s  {'PASS' if ok else 'FAIL'}")
        if not ok:
            failed.append(c.name)
            if tail:
                print("  --- output tail ---")
                for line in tail.splitlines():
                    print("  " + line)

    print("-" * 70)
    if failed:
        print(f"OVERALL: FAIL ({len(failed)}/{len(checks)} failed: {', '.join(failed)})")
        return 1
    print(f"OVERALL: PASS ({len(checks)}/{len(checks)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
