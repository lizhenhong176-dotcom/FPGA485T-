"""R2 拟合：把多个 run 目录的 results.csv/json 合并，拟合帧号公式并做结构校验。

用法：
    python fit_r2.py --runs E:\\v7work\\codex_runs\\r2_a1 E:\\v7work\\codex_runs\\r2_a2 ... \
        --out E:\\v7work\\codex_runs\\r2_fit

模型：
    frame(X, Y) = region_base[Y // 50] + dX_at_Y160[X]
    region_base[0] = 31748（SLICE_X10Y10 已实测）
    region_base[r] = frame(SLICE_X10Y{50*r})，r = 1..5
    dX_at_Y160[X] = frame(SLICE_X{X}Y160) - frame(SLICE_X10Y160)，dX_at_Y160[10] = 0
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

LOC_RE = re.compile(r"SLICE_X(\d+)Y(\d+)")


def load_rows(run: Path) -> list[dict]:
    path = run / "results.json"
    if not path.exists():
        raise FileNotFoundError(f"missing {path}")
    return json.loads(path.read_text(encoding="utf-8-sig"))


def first_frame(row: dict) -> int | None:
    frames = row.get("diff_frames") or []
    if not frames:
        return None
    return int(min(frames))


def structural_checks(row: dict) -> list[str]:
    issues: list[str] = []
    frames = [int(f) for f in row.get("diff_frames") or []]
    bits = row.get("bits") or {}
    if not frames:
        return ["no diff_frames"]

    if sorted(frames) != list(range(min(frames), max(frames) + 1)):
        issues.append(f"frames not contiguous: {frames}")

    counted = sum(len(bits.get(str(f)) or bits.get(f) or []) for f in frames)
    if counted != int(row.get("bit_count") or 0):
        issues.append(f"bit_count mismatch: meta={row.get('bit_count')} counted={counted}")

    per_frame = [len(bits.get(str(f)) or bits.get(f) or []) for f in frames]
    if per_frame and max(per_frame) - min(per_frame) > 1:
        issues.append(f"per-frame bit counts uneven: {per_frame}")

    words = set()
    for f in frames:
        for item in bits.get(str(f)) or bits.get(f) or []:
            if isinstance(item, (list, tuple)) and item:
                words.add(int(item[0]))
    unexpected = sorted(w for w in words if w not in (20, 50))
    if unexpected:
        issues.append(f"unexpected word indices: {unexpected}")

    return issues


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--runs", nargs="+", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    rows: dict[str, dict] = {}
    for run in args.runs:
        for row in load_rows(Path(run)):
            loc = row.get("loc")
            if loc:
                rows[loc] = row

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    measured: dict[tuple[int, int], int] = {}
    for loc, row in rows.items():
        m = LOC_RE.fullmatch(loc)
        if not m or not row.get("diff_frames"):
            continue
        x, y = int(m.group(1)), int(m.group(2))
        frame = first_frame(row)
        if frame is not None:
            measured[(x, y)] = frame

    regions = {0: {"base": 31748, "loc": "SLICE_X10Y10"}}
    for r in range(1, 6):
        frame = measured.get((10, 50 * r))
        if frame is not None:
            regions[r] = {"base": frame, "loc": f"SLICE_X10Y{50 * r}"}

    base160 = measured.get((10, 160))
    dx: dict[int, int] = {}
    if base160 is not None:
        for (x, y), frame in measured.items():
            if y == 160:
                dx[x] = frame - base160
    dx.setdefault(10, 0)

    residuals: dict[str, int] = {}
    anomalies: dict[str, list[str]] = {}
    for loc, row in rows.items():
        issues = structural_checks(row)
        if issues:
            anomalies[loc] = issues
        m = LOC_RE.fullmatch(loc)
        if not m or not row.get("diff_frames"):
            continue
        x, y = int(m.group(1)), int(m.group(2))
        region = y // 50
        if region not in regions:
            anomalies.setdefault(loc, []).append(f"region {region} has no base")
            continue
        if x not in dx:
            anomalies.setdefault(loc, []).append(f"X={x} has no dX at Y160")
            continue
        predicted = regions[region]["base"] + dx[x]
        measured_frame = measured[(x, y)]
        residuals[loc] = abs(measured_frame - predicted)

    pass_ = bool(residuals) and all(v <= 2 for v in residuals.values()) and not any(
        "not contiguous" in i or "mismatch" in i for v in anomalies.values() for i in v
    )

    fit = {
        "part": "xc7vx485tffg1761-2",
        "frames_total": 50176,
        "regions": {str(k): v for k, v in sorted(regions.items())},
        "dX_at_Y160": {str(k): v for k, v in sorted(dx.items())},
        "measured": {f"X{x}Y{y}": f for (x, y), f in sorted(measured.items())},
        "residuals": residuals,
        "anomalies": anomalies,
        "pass": pass_,
    }
    (out / "FIT.json").write_text(json.dumps(fit, indent=2), encoding="utf-8")
    print(json.dumps(fit, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
