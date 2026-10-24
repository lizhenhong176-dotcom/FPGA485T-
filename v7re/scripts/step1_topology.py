"""Step 1 driver: device routing topology -> artifacts -> database.

    python scripts/step1_topology.py all        # export + verify + manifest + db
    python scripts/step1_topology.py verify     # re-check an existing export
    python scripts/step1_topology.py conns      # inter-tile connectivity stage
    python scripts/step1_topology.py db         # load into SQLite
    python scripts/step1_topology.py manifest   # checksums for the export

Data lives outside the source tree (``E:\\v7work\\routing`` by default) so a
fresh clone does not need 7 MB of generated JSON.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from routing import connections, env, manifest, topology, verify  # noqa: E402
from db import import_routing  # noqa: E402


def _default_root() -> Path:
    return env.work_root() / "routing" / "out_routing"


def _default_db() -> Path:
    return env.work_root() / "routing" / "v7_routing.db"


def cmd_export(args: argparse.Namespace) -> int:
    root = Path(args.root)
    print(f"[export] part={args.part} root={root}")
    result = topology.scan(root, args.part, args.limit)
    result["part"] = args.part
    (root / "summary.json").write_text(json.dumps(result, indent=1) + "\n",
                                       encoding="utf-8")
    n = topology.export_templates(root, args.part)
    print(f"[export] templates: {n}")
    topology.finalize(root, args.part)
    print(f"[export] tiles={result['tiles']} wires={result['wires']} pips={result['pips']}")
    return 0


def cmd_conns(args: argparse.Namespace) -> int:
    root = Path(args.root)
    print(f"[conns] part={args.part} root={root}")
    done = connections.export_connections(root, args.part)
    print(f"[conns] {done}")
    if args.measure:
        stats = connections.measure_uniformity(root, args.part, args.per_type)
        (root / "conns" / "uniformity.json").write_text(
            json.dumps(stats, indent=1) + "\n", encoding="utf-8")
        print(f"[conns] uniform types {stats['exact_types']}/{stats['types']}, "
              f"tiles exact {stats['exact']}/{stats['tiles']}")
    return 0


def cmd_verify(args: argparse.Namespace) -> int:
    root = Path(args.root)
    result = verify.verify_topology(root, args.part, args.samples)
    for c in result["checks"]:
        print(("PASS  " if c["ok"] else "FAIL  ") + c["msg"])
    failures = result["failed"]
    if args.with_conns and (root / "conns").exists():
        cres = verify.verify_connections(root, args.part)
        for c in cres["checks"]:
            print(("PASS  " if c["ok"] else "FAIL  ") + "[conns] " + c["msg"])
        failures += cres["failed"]
    (root / "verify.json").write_text(
        json.dumps({"topology": result["checks"], "failed": failures}, indent=1) + "\n",
        encoding="utf-8")
    print(f"VERIFY {'OK' if failures == 0 else 'FAILED'} ({failures} failure(s))")
    return 0 if failures == 0 else 1


def cmd_manifest(args: argparse.Namespace) -> int:
    root = Path(args.root)
    summary = json.loads((root / "summary.json").read_text(encoding="utf-8"))
    doc = manifest.build(root, "s01_topology", {"part": args.part, "counts": summary})
    print(f"[manifest] {doc['file_count']} files, {doc['total_bytes']:,} bytes")
    check = manifest.verify(root)
    print(f"[manifest] verify {'OK' if check['ok'] else 'FAILED'}")
    return 0 if check["ok"] else 1


def cmd_db(args: argparse.Namespace) -> int:
    root, db = Path(args.root), Path(args.db)
    mpath = root / "manifest.json"
    m = json.loads(mpath.read_text(encoding="utf-8")) if mpath.exists() else None
    result = import_routing.import_topology(root, db, m)
    print(f"[db] {result}")
    return 0


def cmd_all(args: argparse.Namespace) -> int:
    rc = cmd_export(args)
    if rc:
        return rc
    if not args.skip_conns:
        cmd_conns(args)
    rc = cmd_verify(argparse.Namespace(**{**vars(args), "with_conns": not args.skip_conns}))
    if rc:
        return rc
    rc = cmd_manifest(argparse.Namespace(**vars(args)))
    if rc:
        return rc
    return cmd_db(args)


def build_parser() -> argparse.ArgumentParser:
    common = argparse.ArgumentParser(add_help=False)
    common.add_argument("--root", default=str(_default_root()))
    common.add_argument("--db", default=str(_default_db()))
    common.add_argument("--part", default=env.PART)
    common.add_argument("--limit", type=int, default=None,
                        help="export only the first N tiles (smoke tests)")
    common.add_argument("--samples", type=int, default=40)
    common.add_argument("--with-conns", action="store_true")
    common.add_argument("--skip-conns", action="store_true")
    common.add_argument("--measure", action="store_true")
    common.add_argument("--per-type", type=int, default=2)

    p = argparse.ArgumentParser(description=__doc__, parents=[common],
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    for name, fn in (("export", cmd_export), ("conns", cmd_conns),
                     ("verify", cmd_verify), ("manifest", cmd_manifest),
                     ("db", cmd_db), ("all", cmd_all)):
        sp = sub.add_parser(name, parents=[common])
        sp.set_defaults(func=fn)
    return p


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
