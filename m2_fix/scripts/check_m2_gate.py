#!/usr/bin/env python3
"""Validate the M2 minimal-controlled-difference (MCD) corpus.

This is an evidence gate, not just a JSON-shape gate.  For every pair it:

* requires the referenced bitstreams, pip files and build logs;
* compares pips.txt with route_a/route_b;
* re-extracts the frames and recomputes diff_frames, data_bits, aux_bits;
* verifies the frame-payload hash (whole-file .bit SHA is only a warning,
  because Vivado rewrites the header timestamp on every build);
* rejects duplicate experiments and checks mux-encoding diversity.
"""
import argparse
import glob
import hashlib
import json
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from bitstream.frames import (  # noqa: E402
    diff_bits_in_frame,
    diff_frame_indices,
    frame_hash,
    load_frames,
)

DEFAULT_PAIRS = ROOT / "data" / "m2" / "pairs"
EVIDENCE_KEYS = (
    "bitstream_a",
    "bitstream_b",
    "pips_a",
    "pips_b",
    "route_log_a",
    "route_log_b",
)


def _resolve(value):
    p = Path(value)
    return p if p.is_absolute() else ROOT / p


def _sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _bitset(values, errors, label):
    out = set()
    for value in values or []:
        if not (isinstance(value, list) and len(value) == 2):
            errors.append("bad %s entry: %r" % (label, value))
            continue
        out.add((int(value[0]), int(value[1])))
    return out


def _mux_leaf(pip):
    """Turn 'INT_R_X7Y11/INT_R.NR1END0->>IMUX8' into 'IMUX8'."""
    match = re.search(r"->>\s*([A-Za-z0-9_]+)\s*$", pip or "")
    return match.group(1) if match else pip


def _route_sink(path):
    """Return the last routed object token from the final ROUTE= line."""
    route = None
    for line in path.read_text().splitlines():
        if line.startswith("ROUTE="):
            route = line.split("=", 1)[1].strip()
    if not route:
        return None
    match = re.search(r"\{([^}]*)\}", route)
    if not match:
        return None
    tokens = match.group(1).split()
    return tokens[-1] if tokens else None


def check_pair(d):
    errors = []
    warnings = []
    aux_word = int(d.get("aux_word", 50))

    if not d.get("id"):
        errors.append("missing id")
    changed = d.get("changed_inputs") or []
    if len(changed) != 1:
        errors.append("changed_inputs must contain exactly one input")
    if not d.get("tile_family"):
        errors.append("missing tile_family")
    if not d.get("classification"):
        errors.append("missing classification")

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

    evidence = d.get("evidence")
    if not isinstance(evidence, dict):
        errors.append("missing evidence object")
        evidence = {}
    paths = {}
    for key in EVIDENCE_KEYS:
        value = evidence.get(key)
        if not value:
            errors.append("missing evidence.%s" % key)
            continue
        path = _resolve(value)
        if not path.is_file():
            errors.append("evidence.%s does not exist: %s" % (key, value))
            continue
        paths[key] = path

    # pips.txt is the genuine route evidence; route_a/route_b must be its
    # contents, not a hand-written summary.
    for side in ("a", "b"):
        key = "pips_%s" % side
        if key not in paths:
            continue
        actual = [
            line.strip()
            for line in paths[key].read_text().splitlines()
            if line.strip()
        ]
        declared = route_a if side == "a" else route_b
        if actual != declared:
            errors.append("%s does not match route_%s" % (key, side))

    # Optional sink-pin assertion.  This turns a silent LOCK_PINS fallback
    # (e.g. requested B3 but routed B1) into a hard gate failure.
    for side in ("a", "b"):
        pin = d.get("sink_pin_%s" % side)
        if not pin:
            continue
        log_key = "route_log_%s" % side
        if log_key not in paths:
            continue
        log_text = paths[log_key].read_text(errors="replace")
        if "CRITICAL WARNING" in log_text:
            errors.append("%s has a CRITICAL WARNING" % log_key)
        sink = _route_sink(paths[log_key])
        if not sink or not (sink.endswith("_" + pin) or sink.endswith("." + pin)):
            errors.append(
                "%s does not end at requested sink %s (actual %r)"
                % (log_key, pin, sink)
            )

    declared_non50 = _bitset(d.get("data_bits"), errors, "data_bits")
    for word, bit in declared_non50:
        if word == aux_word:
            errors.append("word %d is auxiliary and must not be a data bit" % aux_word)
    if not declared_non50:
        errors.append("no data bits")

    if "frame_sha256_a" not in d or "frame_sha256_b" not in d:
        errors.append("missing frame_sha256_a/frame_sha256_b")
    if "frame_count" not in d:
        errors.append("missing frame_count")

    fa = fb = None
    if "bitstream_a" in paths and "bitstream_b" in paths:
        try:
            fa = load_frames(paths["bitstream_a"])
            fb = load_frames(paths["bitstream_b"])
        except Exception as exc:  # noqa: BLE001 - report as gate failure
            errors.append("cannot load bitstreams: %s" % exc)
        else:
            if len(fa) != len(fb):
                errors.append(
                    "frame count mismatch: a=%d b=%d" % (len(fa), len(fb))
                )
            if d.get("frame_count") is not None and d.get("frame_count") != len(fa):
                errors.append(
                    "frame_count mismatch: declared %r, actual %d"
                    % (d.get("frame_count"), len(fa))
                )

            if len(fa) == len(fb):
                actual_diff = diff_frame_indices(fa, fb)
                if actual_diff != d.get("diff_frames"):
                    errors.append(
                        "diff_frames mismatch: declared %r, actual %r"
                        % (d.get("diff_frames"), actual_diff)
                    )

                actual_non50 = set()
                actual_aux = set()
                for frame in actual_diff:
                    for word, bit in diff_bits_in_frame(fa, fb, frame):
                        if word == aux_word:
                            actual_aux.add((word, bit))
                        else:
                            actual_non50.add((word, bit))

                if actual_non50 != declared_non50:
                    errors.append(
                        "data_bits mismatch: declared %r, actual %r"
                        % (sorted(declared_non50), sorted(actual_non50))
                    )

                declared_aux = _bitset(d.get("aux_bits"), errors, "aux_bits")
                if "aux_bits" not in d:
                    warnings.append("aux_bits absent; word %d was not recorded" % aux_word)
                elif actual_aux != declared_aux:
                    errors.append(
                        "aux_bits mismatch: declared %r, actual %r"
                        % (sorted(declared_aux), sorted(actual_aux))
                    )

            for side, frames in (("a", fa), ("b", fb)):
                actual_hash = frame_hash(frames)
                declared_hash = d.get("frame_sha256_%s" % side)
                if declared_hash and declared_hash != actual_hash:
                    errors.append(
                        "frame_sha256_%s mismatch: declared %s, actual %s"
                        % (side, declared_hash, actual_hash)
                    )
                file_key = "bitstream_%s_sha256" % side
                declared_file_hash = d.get(file_key)
                if declared_file_hash and "bitstream_%s" % side in paths:
                    actual_file_hash = _sha256_file(paths["bitstream_%s" % side])
                    if declared_file_hash != actual_file_hash:
                        warnings.append(
                            "%s is stale (whole-file .bit header changed); "
                            "frame hash is authoritative" % file_key
                        )

    mux = d.get("int_mux_substitution") or {}
    mux_sig = (_mux_leaf(mux.get("a")), _mux_leaf(mux.get("b")))
    if not all(mux_sig):
        warnings.append("int_mux_substitution missing; cannot classify mux encoding")

    return (
        errors,
        warnings,
        {
            "id": d.get("id"),
            "family": d.get("tile_family"),
            "experiment": (tuple(route_a), tuple(route_b)),
            "mux_sig": mux_sig if all(mux_sig) else None,
            "input_sig": tuple(changed),
        },
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pairs", nargs="?", default=str(DEFAULT_PAIRS))
    ap.add_argument("--min-pairs", type=int, default=5)
    ap.add_argument("--min-families", type=int, default=3)
    ap.add_argument("--min-mux-signatures", type=int, default=2)
    ap.add_argument("--min-input-transitions", type=int, default=1)
    ap.add_argument("--allow-incomplete", action="store_true")
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.pairs, "*.json")))
    seen = set()
    families = set()
    mux_sigs = set()
    input_sigs = set()
    experiments = set()
    failed = []
    warnings = []

    for path in files:
        try:
            d = json.load(open(path))
        except Exception as exc:  # noqa: BLE001
            failed.append((path, "invalid JSON: %s" % exc))
            continue
        errs, warns, meta = check_pair(d)
        warnings.extend("%s: %s" % (os.path.basename(path), w) for w in warns)
        if errs:
            failed.append((path, "; ".join(errs)))
            continue
        if not meta["id"]:
            failed.append((path, "missing id"))
            continue
        if meta["id"] in seen:
            failed.append((path, "duplicate id %s" % meta["id"]))
            continue
        if meta["experiment"] in experiments:
            failed.append((path, "duplicate route experiment"))
            continue
        seen.add(meta["id"])
        families.add(meta["family"])
        experiments.add(meta["experiment"])
        input_sigs.add(meta["input_sig"])
        if meta["mux_sig"]:
            mux_sigs.add(meta["mux_sig"])

    print(
        "pairs=%d families=%d input_transitions=%d mux_signatures=%d valid=%d failed=%d"
        % (
            len(files),
            len(families),
            len(input_sigs),
            len(mux_sigs),
            len(seen),
            len(failed),
        )
    )
    for path, err in failed:
        print("FAIL %s: %s" % (path, err))
    for warning in warnings:
        print("WARN %s" % warning)

    gate_ok = (
        len(seen) >= args.min_pairs
        and len(families) >= args.min_families
        and len(mux_sigs) >= args.min_mux_signatures
        and len(input_sigs) >= args.min_input_transitions
        and not failed
    )
    if gate_ok:
        if len(input_sigs) < 2:
            print("M2 GATE CONDITIONAL PASS")
            print(
                "WARN independence: only one logical pin transition; add a "
                "non-A3/A5 pair for stronger transition coverage"
            )
        else:
            print("M2 GATE PASS")
        return 0

    print(
        "M2 GATE INCOMPLETE: need %d pairs, %d families, %d mux signatures, "
        "%d input transitions; have %d/%d/%d/%d"
        % (
            args.min_pairs,
            args.min_families,
            args.min_mux_signatures,
            args.min_input_transitions,
            len(seen),
            len(families),
            len(mux_sigs),
            len(input_sigs),
        )
    )
    if args.allow_incomplete:
        return 0
    return 1


if __name__ == "__main__":
    sys.exit(main())
