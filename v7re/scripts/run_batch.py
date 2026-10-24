"""Run a manifest of LUT probes with resume support."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from config import PART, work_root
from vivado.batch import run_batch


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--manifest", required=True, help="CSV or JSON probe manifest")
    ap.add_argument(
        "--workdir-root",
        default=str(work_root() / "probe"),
        help="base directory when the manifest has no per-item workdir",
    )
    ap.add_argument("--out", default=None, help="batch summary JSON")
    ap.add_argument("--part", default=PART)
    ap.add_argument("--force", action="store_true", help="rebuild and rerun completed items")
    ap.add_argument("--dry-run", action="store_true", help="validate manifest and paths only")
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--stop-on-error", action="store_true")
    ap.add_argument("--jobs", type=int, default=1, help="must be 1; Vivado runs serially")
    args = ap.parse_args()

    if args.jobs != 1:
        ap.error("--jobs must be 1: Vivado license and shared TEMP are not safe in parallel")

    summary = run_batch(
        args.manifest,
        out=args.out,
        workdir_root=args.workdir_root,
        part=args.part,
        force=args.force,
        dry_run=args.dry_run,
        limit=args.limit,
        stop_on_error=args.stop_on_error,
    )

    print(json.dumps(summary["counts"], indent=2))
    out = args.out or str(Path(args.workdir_root) / f"batch_{Path(args.manifest).stem}.json")
    print(f"wrote {out}")
    return 1 if summary["counts"].get("failed") else 0


if __name__ == "__main__":
    raise SystemExit(main())
