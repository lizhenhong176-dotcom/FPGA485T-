"""Build ``E:\\v7work\\model\\v7_model.sqlite`` from P0 + probes + routing metadata."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from db.import_model import (  # noqa: E402
    DEFAULT_OUT,
    DEFAULT_P0_DB,
    DEFAULT_PROBE_DB,
    DEFAULT_ROUTING_DB,
    build,
)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--p0-db", default=str(DEFAULT_P0_DB))
    ap.add_argument("--probe-db", default=str(DEFAULT_PROBE_DB))
    ap.add_argument("--routing-db", default=str(DEFAULT_ROUTING_DB))
    ap.add_argument("--no-hash", action="store_true", help="skip source SHA256 (faster)")
    args = ap.parse_args()
    result = build(
        out=args.out,
        p0_db=args.p0_db,
        probe_db=args.probe_db,
        routing_db=args.routing_db,
        hash_sources=not args.no_hash,
    )
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
