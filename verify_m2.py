#!/usr/bin/env python3
"""Read-only verification of the five M2 pair JSONs against their bitstreams."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

ROOT = Path("/data/lzh/v7re")
sys.path.insert(0, str(ROOT))
from bitstream.frames import diff_bits_in_frame, diff_frame_indices, load_frames  # noqa: E402


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    pairs = sorted((ROOT / "data/m2/pairs").glob("m2_mcd_*.json"))
    print(f"pairs={len(pairs)}")
    bad = 0
    for jp in pairs:
        d = json.loads(jp.read_text())
        ev = d["evidence"]
        a = ROOT / ev["bitstream_a"]
        b = ROOT / ev["bitstream_b"]
        print(f"\n{d['id']} family={d['tile_family']} transition={d['changed_inputs']}")
        print(f"  a_exists={a.is_file()} b_exists={b.is_file()}")
        if not (a.is_file() and b.is_file()):
            bad += 1
            continue
        sa, sb = sha256(a), sha256(b)
        print(f"  sha_a={sa == d.get('bitstream_a_sha256')} sha_b={sb == d.get('bitstream_b_sha256')}")
        fa, fb = load_frames(a), load_frames(b)
        print(f"  frames={len(fa)}/{len(fb)} equal={len(fa) == len(fb)}")
        actual_frames = diff_frame_indices(fa, fb)
        declared_frames = d.get("diff_frames", [])
        print(f"  frames_declared={len(declared_frames)} actual={len(actual_frames)} match={actual_frames == declared_frames}")
        bits_all = set()
        for fr in actual_frames:
            for w, bit in diff_bits_in_frame(fa, fb, fr):
                bits_all.add((w, bit))
        declared_bits = {tuple(x) for x in d.get("data_bits", [])}
        non50 = {x for x in bits_all if x[0] != 50}
        print(f"  bits_all={len(bits_all)} non50={len(non50)} declared={len(declared_bits)}")
        print(f"  declared_equals_non50={declared_bits == non50}")
        print(f"  missing_from_declared={sorted(non50 - declared_bits)[:8]}")
        print(f"  extra_in_declared={sorted(declared_bits - non50)[:8]}")
        print(f"  word50_bits={sorted(x for x in bits_all if x[0] == 50)[:10]}")
        if not (actual_frames == declared_frames and declared_bits == non50):
            bad += 1
    print(f"\nBAD={bad}")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
