"""R2 扫描执行器：对指定 SLICE LOC 逐个跑 LUT 探针，增量落盘。

用法（在任意目录均可运行）：
    python scan_r2.py --out E:\\v7work\\codex_runs\\r2 --locs SLICE_X10Y50,SLICE_X10Y100

产出：
    <out>/results.csv   列：loc,bel,frames,bit_count,error
    <out>/results.json  完整结果列表（含 bits 明细）
    <out>/probe/<loc>/  每个测点的 Vivado 工作目录

设计约束：
- 只写 --out 指定的目录，绝不修改 v7re / E:\\app / 其它路径。
- 每个测点失败（含超时）只记录 error，继续下一个点。
- 已存在且 frames 非空的测点默认跳过，便于断点续跑。
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
import time
import traceback
from pathlib import Path

# Codex 的沙箱会清洗环境变量；vivado.bat -> loader.bat 用
# %PROCESSOR_ARCHITECTURE% 判断 32/64 位，缺失时会走 win32 分支并直接失败。
# 这里补齐，保证子进程拿到 AMD64。
os.environ.setdefault("PROCESSOR_ARCHITECTURE", "AMD64")
os.environ.setdefault("PROCESSOR_ARCHITEW6432", "AMD64")

V7RE = Path(r"E:\DEEPSEEK\FPGA比特流逆向\v7re")
sys.path.insert(0, str(V7RE))

from vivado.probe import probe  # noqa: E402

CSV_FIELDS = ["loc", "bel", "frames", "bit_count", "error"]


def load_results(out: Path) -> list[dict]:
    path = out / "results.json"
    if path.exists():
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            if isinstance(data, list):
                return data
        except Exception:
            pass
    return []


def save_results(out: Path, rows: list[dict]) -> None:
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").write_text(
        json.dumps(rows, indent=2), encoding="utf-8"
    )
    with (out / "results.csv").open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "loc": row.get("loc", ""),
                    "bel": row.get("bel", ""),
                    "frames": ";".join(str(x) for x in row.get("diff_frames", [])),
                    "bit_count": row.get("bit_count", 0),
                    "error": row.get("error", ""),
                }
            )


def summarize(result: dict) -> dict:
    frames = [int(x) for x in result.get("diff_frames", [])]
    bits = result.get("bits", {}) or {}
    bit_count = sum(len(v) for v in bits.values())
    return {
        "loc": result.get("loc"),
        "bel": result.get("bel"),
        "init_a": result.get("init_a"),
        "init_b": result.get("init_b"),
        "dcp": result.get("dcp"),
        "diff_frames": frames,
        "bit_count": bit_count,
        "bits": bits,
        "error": "",
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--locs", required=True, help="逗号分隔，例如 SLICE_X10Y50,SLICE_X10Y100")
    ap.add_argument("--bel", default="A6LUT")
    ap.add_argument("--init-a", default="0000000000000001")
    ap.add_argument("--init-b", default="0000000000000002")
    ap.add_argument("--part", default="xc7vx485tffg1761-2")
    ap.add_argument("--timeout", type=int, default=900)
    ap.add_argument("--force", action="store_true")
    args = ap.parse_args()

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    rows = load_results(out)
    by_loc = {r.get("loc"): i for i, r in enumerate(rows)}

    locs = [x.strip() for x in args.locs.split(",") if x.strip()]
    for loc in locs:
        existing = by_loc.get(loc)
        if existing is not None and not args.force and rows[existing].get("diff_frames"):
            print(f"POINT {loc} SKIP (already done)", flush=True)
            continue

        started = time.time()
        try:
            result = probe(
                out / "probe" / loc,
                loc,
                args.bel,
                args.init_a,
                args.init_b,
                part=args.part,
                rebuild=args.force,
            )
            row = summarize(result)
            print(
                f"POINT {loc} OK frames={row['diff_frames']} "
                f"bits={row['bit_count']} secs={time.time()-started:.1f}",
                flush=True,
            )
        except Exception as exc:  # noqa: BLE001
            row = {
                "loc": loc,
                "bel": args.bel,
                "diff_frames": [],
                "bit_count": 0,
                "bits": {},
                "error": f"{type(exc).__name__}: {exc}",
            }
            print(f"POINT {loc} FAIL {row['error']}", flush=True)
            traceback.print_exc()

        if existing is None:
            by_loc[loc] = len(rows)
            rows.append(row)
        else:
            rows[existing] = row
        save_results(out, rows)

    print(f"DONE points={len(rows)} out={out}", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
