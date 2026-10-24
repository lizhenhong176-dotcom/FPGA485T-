#!/usr/bin/env python3
"""Independent acceptance checker for a Codex execution run.

Re-derives the frame model from the run's own artifacts and compares it with
the measured frames. Never trusts FIT.json's own pass/residual fields.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from pathlib import Path

V7RE = Path(r"E:\DEEPSEEK\FPGA比特流逆向\v7re")
WORK = Path(r"E:\v7work")
V7RE_SUFFIXES = {".py", ".md", ".sql", ".tcl", ".json"}

EXPECTED_A = [
    "SLICE_X10Y50",
    "SLICE_X10Y100",
    "SLICE_X10Y150",
    "SLICE_X10Y200",
    "SLICE_X10Y250",
]
EXPECTED_B = [
    "SLICE_X10Y160",
    "SLICE_X60Y160",
    "SLICE_X80Y160",
    "SLICE_X180Y160",
    "SLICE_X220Y160",
]
EXPECTED = EXPECTED_A + EXPECTED_B
TOLERANCE = 2
LOC_RE = re.compile(r"SLICE_X(\d+)Y(\d+)$")


def parse_loc(loc: str) -> tuple[int, int] | None:
    m = LOC_RE.match(loc.strip())
    return (int(m.group(1)), int(m.group(2))) if m else None


class Report:
    def __init__(self) -> None:
        self.rows: list[tuple[str, bool, str]] = []

    def check(self, name: str, ok: bool, detail: str = "") -> bool:
        self.rows.append((name, ok, detail))
        suffix = f" — {detail}" if detail else ""
        print(f"[{'PASS' if ok else 'FAIL'}] {name}{suffix}")
        return ok

    def advisory(self, name: str, detail: str) -> None:
        print(f"[advisory] {name}: {detail}")

    @property
    def failed(self) -> int:
        return sum(1 for _, ok, _ in self.rows if not ok)


def load_csv(path: Path) -> dict[str, dict[str, str]]:
    rows: dict[str, dict[str, str]] = {}
    if not path.is_file():
        return rows
    with path.open(newline="", encoding="utf-8-sig") as fh:
        for row in csv.DictReader(fh):
            loc = (row.get("loc") or "").strip()
            if loc:
                rows[loc] = {k: (v or "").strip() for k, v in row.items() if k}
    return rows


def load_points(path: Path) -> dict[str, dict]:
    points: dict[str, dict] = {}
    if not path.is_file():
        return points
    try:
        raw = json.loads(path.read_text(encoding="utf-8-sig"))
    except json.JSONDecodeError as exc:
        print(f"[advisory] results.json unreadable: {exc}")
        return points
    items = raw if isinstance(raw, list) else raw.get("points", [])
    for item in items:
        if isinstance(item, dict) and item.get("loc"):
            points[item["loc"]] = item
    return points


def check_structure(rep: Report, points: dict[str, dict], measured: dict[str, list[int]]) -> None:
    bad: list[str] = []
    for loc, frames in measured.items():
        data = points.get(loc, {})
        bits = data.get("bits") or {}
        total = sum(len(v) for v in bits.values())
        if len(frames) > 4 or frames != list(range(frames[0], frames[0] + len(frames))):
            bad.append(f"{loc}:frames-not-consecutive")
        counts = {len(v) for v in bits.values()}
        if len(counts) > 1 and (max(counts) - min(counts)) > 1:
            bad.append(f"{loc}:ragged-bits{counts}")
        words = {w for v in bits.values() for w, _ in v if isinstance(w, int)}
        if words and not words <= {20, 50}:
            bad.append(f"{loc}:unexpected-words{sorted(words)}")
        if total == 0:
            bad.append(f"{loc}:no-bits")
    rep.check("probe structure (consecutive frames, word 20/50, bit counts)", not bad, ", ".join(bad[:6]))


def recompute_fit(
    rep: Report,
    measured: dict[str, list[int]],
    fit: dict,
) -> tuple[dict[str, float], int | None]:
    regions = fit.get("regions") or {}
    dx = fit.get("dX_at_Y160") or {}
    residuals: dict[str, float] = {}
    unresolved: list[str] = []

    for loc, frames in measured.items():
        pos = parse_loc(loc)
        if pos is None:
            continue
        x, y = pos
        region = regions.get(str(y // 50))
        offset = dx.get(str(x))
        if not isinstance(region, dict) or not isinstance(offset, (int, float)):
            unresolved.append(loc)
            continue
        predicted = float(region.get("base", 0)) + float(offset)
        residuals[loc] = abs(min(frames) - predicted)

    if unresolved:
        rep.check("FIT covers every measured point", False, f"no prediction for {unresolved[:5]}")
    else:
        rep.check("FIT covers every measured point", True)

    worst = max(residuals.values()) if residuals else None
    within = worst is not None and worst <= TOLERANCE
    rep.check(
        f"recomputed residual <= {TOLERANCE}",
        within,
        f"max={worst}" if worst is not None else "no residuals",
    )
    return residuals, worst


def run_start_epoch(run: Path) -> int | None:
    env = run / "run.env"
    if env.is_file():
        for line in env.read_text(encoding="utf-8", errors="replace").splitlines():
            if line.startswith("started_epoch="):
                try:
                    return int(line.split("=", 1)[1].strip())
                except ValueError:
                    return None
    return None


def check_untouched(rep: Report, run: Path) -> None:
    start = run_start_epoch(run)
    if start is None:
        rep.check("v7re untouched", False, "no started_epoch in run.env")
        return
    changed: list[str] = []
    if V7RE.is_dir():
        for path in V7RE.rglob("*"):
            if not path.is_file() or path.suffix.lower() not in V7RE_SUFFIXES:
                continue
            if "__pycache__" in path.parts or "codex" in path.parts:
                continue
            if path.stat().st_mtime > start + 120:
                changed.append(str(path.relative_to(V7RE)))
    rep.check("v7re untouched", not changed, ", ".join(changed[:6]))


def check_containment(rep: Report, run: Path) -> None:
    """Nothing outside the run dir may be touched under E:\\v7work."""
    start = run_start_epoch(run)
    if start is None:
        return
    offenders: list[str] = []
    for path in WORK.iterdir():
        if path.name == "codex_runs":
            continue
        try:
            if path.resolve() == run or run.is_relative_to(path.resolve()):
                continue
            if path.stat().st_mtime > start + 120:
                offenders.append(path.name)
        except OSError:
            continue
    rep.check("no writes outside run dir (E:\\v7work)", not offenders, ", ".join(offenders[:6]))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--run-dir", required=True)
    args = ap.parse_args()

    run = Path(args.run_dir).resolve()
    rep = Report()
    print(f"run dir: {run}")

    csv_rows = load_csv(run / "results.csv")
    rep.check("results.csv present", bool(csv_rows), f"{len(csv_rows)} rows")

    missing = [loc for loc in EXPECTED if loc not in csv_rows]
    extra = [loc for loc in csv_rows if loc not in EXPECTED]
    rep.check("point set matches plan", not missing and not extra, f"missing={missing} extra={extra}")

    measured: dict[str, list[int]] = {}
    for loc in EXPECTED:
        row = csv_rows.get(loc)
        if not row or row.get("error"):
            continue
        try:
            frames = [int(v) for v in row["frames"].split(";") if v]
        except ValueError:
            continue
        if frames:
            measured[loc] = frames

    ok_a = sum(1 for loc in EXPECTED_A if loc in measured)
    rep.check("A group >= 4/5", ok_a >= 4, f"{ok_a}/5")
    rep.check("total >= 8/10", len(measured) >= 8, f"{len(measured)}/10")

    points = load_points(run / "results.json")
    rep.check("results.json present", bool(points), f"{len(points)} points")
    check_structure(rep, points, measured)

    fit_path = run / "FIT.json"
    fit: dict = {}
    if fit_path.is_file():
        try:
            fit = json.loads(fit_path.read_text(encoding="utf-8-sig"))
        except json.JSONDecodeError as exc:
            rep.check("FIT.json parses", False, str(exc))
    rep.check("FIT.json present", isinstance(fit, dict) and bool(fit))

    residuals, worst = recompute_fit(rep, measured, fit)
    if worst is not None:
        rep.advisory("residuals", json.dumps(residuals, ensure_ascii=False))

    report_path = run / "REPORT.md"
    text = report_path.read_text(encoding="utf-8", errors="replace") if report_path.is_file() else ""
    covered = [loc for loc in measured if loc in text]
    rep.check(
        "REPORT.md present and covers successful points",
        len(text) >= 400 and len(covered) == len(measured),
        f"{len(text)} chars, {len(covered)}/{len(measured)} points",
    )

    done_path = run / "DONE.json"
    done: dict = {}
    if done_path.is_file():
        try:
            done = json.loads(done_path.read_text(encoding="utf-8-sig"))
        except json.JSONDecodeError:
            done = {}
    status = str(done.get("status", ""))
    rep.check("DONE.json status", status in {"ok", "partial"}, f"status={status!r}")

    check_untouched(rep, run)
    check_containment(rep, run)

    print()
    if rep.failed:
        print(f"RESULT: FAIL ({rep.failed} check(s) failed)")
        return 1
    print("RESULT: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
