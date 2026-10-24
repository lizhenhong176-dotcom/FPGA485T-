#!/usr/bin/env python3
"""Validate the revised M2 minimal-controlled-difference (MCD) corpus."""
import argparse
import glob
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_PAIRS = os.path.join(ROOT, "data", "m2", "pairs")


def check_pair(d, path):
    errors = []
    if not d.get("id"):
        errors.append("missing id")
    if len(d.get("changed_inputs", [])) != 1:
        errors.append("changed_inputs must contain exactly one input")
    subs = d.get("pip_substitutions")
    sym = d.get("pip_symdiff")
    if not isinstance(subs, int) or subs > 2:
        errors.append("pip_substitutions must be <= 2")
    if not isinstance(sym, int) or sym > 4:
        errors.append("pip_symdiff must be <= 4")
    route_a = d.get("route_a") or []
    route_b = d.get("route_b") or []
    if sym != len(set(route_a) ^ set(route_b)):
        errors.append(
            "pip_symdiff mismatch: declared %r, actual %d"
            % (sym, len(set(route_a) ^ set(route_b)))
        )
    bits = d.get("data_bits") or []
    if not bits:
        errors.append("no data bits")
    for b in bits:
        if not (isinstance(b, list) and len(b) == 2):
            errors.append("bad data_bits entry: %r" % (b,))
        elif b[0] == 50:
            errors.append("word 50 is auxiliary and must not be a data bit")
    if not d.get("tile_family"):
        errors.append("missing tile_family")
    if not d.get("classification"):
        errors.append("missing classification")
    return errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pairs", nargs="?", default=DEFAULT_PAIRS)
    ap.add_argument("--min-pairs", type=int, default=5)
    ap.add_argument("--min-families", type=int, default=3)
    ap.add_argument("--allow-incomplete", action="store_true")
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.pairs, "*.json")))
    seen = set()
    families = set()
    failed = []
    for path in files:
        try:
            d = json.load(open(path))
        except Exception as exc:
            failed.append((path, "invalid JSON: %s" % exc))
            continue
        errs = check_pair(d, path)
        if errs:
            failed.append((path, "; ".join(errs)))
            continue
        if d["id"] in seen:
            failed.append((path, "duplicate id %s" % d["id"]))
            continue
        seen.add(d["id"])
        families.add(d["tile_family"])

    print("pairs=%d families=%d valid=%d failed=%d"
          % (len(files), len(families), len(seen), len(failed)))
    for path, err in failed:
        print("FAIL %s: %s" % (path, err))

    gate_ok = (len(seen) >= args.min_pairs
               and len(families) >= args.min_families
               and not failed)
    if gate_ok:
        print("M2 GATE PASS")
        return 0
    print("M2 GATE INCOMPLETE: need %d pairs across %d families"
          % (args.min_pairs, args.min_families))
    if args.allow_incomplete:
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())

