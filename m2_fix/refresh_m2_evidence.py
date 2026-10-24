#!/usr/bin/env python3
"""Refresh M2 pair hashes from the actual bitstreams.

Adds frame-payload hashes (stable across .bit header timestamps), records the
auxiliary-word bits, and refreshes the whole-file SHA-256 for provenance.  It
does not change diff_frames/data_bits; a mismatch there is an error.
"""
import argparse
import hashlib
import json
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


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def resolve(value):
    p = Path(value)
    return p if p.is_absolute() else ROOT / p


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--pairs", default=str(ROOT / "data" / "m2" / "pairs"))
    ap.add_argument("--write", action="store_true")
    args = ap.parse_args()

    changed = 0
    for path in sorted(Path(args.pairs).glob("*.json")):
        d = json.load(open(path))
        ev = d.get("evidence") or {}
        a_path = resolve(ev["bitstream_a"])
        b_path = resolve(ev["bitstream_b"])
        fa = load_frames(a_path)
        fb = load_frames(b_path)
        if len(fa) != len(fb):
            raise SystemExit("%s: frame count mismatch" % path)

        diff = diff_frame_indices(fa, fb)
        non50 = set()
        aux = set()
        aux_word = int(d.get("aux_word", 50))
        for frame in diff:
            for word, bit in diff_bits_in_frame(fa, fb, frame):
                (aux if word == aux_word else non50).add((word, bit))

        if diff != d.get("diff_frames"):
            raise SystemExit("%s: diff_frames no longer matches" % path)
        if sorted(non50) != sorted(tuple(x) for x in d.get("data_bits", [])):
            raise SystemExit("%s: data_bits no longer matches" % path)

        d["frame_count"] = len(fa)
        d["frame_sha256_a"] = frame_hash(fa)
        d["frame_sha256_b"] = frame_hash(fb)
        d["aux_bits"] = [list(x) for x in sorted(aux)]
        d["bitstream_a_sha256"] = sha256_file(a_path)
        d["bitstream_b_sha256"] = sha256_file(b_path)
        print(
            "%s frames=%d sha_a=%s frame_a=%s"
            % (
                path.name,
                len(fa),
                d["bitstream_a_sha256"][:12],
                d["frame_sha256_a"][:12],
            )
        )
        if args.write:
            with open(path, "w") as fh:
                json.dump(d, fh, indent=2, ensure_ascii=False)
                fh.write("\n")
            changed += 1

    print("updated=%d" % changed)


if __name__ == "__main__":
    main()
