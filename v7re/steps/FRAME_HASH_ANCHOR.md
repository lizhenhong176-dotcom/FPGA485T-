# Frame/FAR anchor validation (M3)

Date: 2026-10-22
Part: `xc7vx485tffg1761-2`
Bitstreams: `data/fasm_shell/a.bit`, `data/fasm_shell/b.bit`
RapidWright: 2026.1.1 standalone + `xc7vx485t` device data

## M3 difference

`a.bit` vs `b.bit`:

```text
frame_count = 50,176 (both)
differing frames = [31750]
bits = (20,14), (20,15), (50,0), (50,12)
```

Frame 31748 is zero in both; 31748 is the **base** of the four-frame M3 group,
not the frame that carries the observed M3 change.

## Hash comparison

Python (`bitstream.frames.load_frames`, raw big-endian words) and RapidWright
(`Bitstream.readBitstream(...).configureArray().getFrame(FAR).getWords()`) were
hashed with the same canonical rule: 101 words, 4 bytes each, SHA-256.

```text
frame 31748  FAR 0x004203A0
  Python      0441772f66559a1c71f4559dc4405438fc9b8383ce1229139257a7fe6d7b8de9
  RapidWright 0441772f66559a1c71f4559dc4405438fc9b8383ce1229139257a7fe6d7b8de9
  MATCH

frame 31750  FAR 0x004203A2
  Python      d44f0364fa633f70021e4662b7da08ebd5c228c1d14e4982fdf1dd3ab209069e
  RapidWright d44f0364fa633f70021e4662b7da08ebd5c228c1d14e4982fdf1dd3ab209069e
  MATCH
```

## Conclusion

- `frame 31748 <-> 0x004203A0` is a valid **group-base** mapping.
- `frame 31750 <-> 0x004203A2` is the actual M3 changed frame.
- The approved plan's golden anchor `31748 / 0x004203A0` remains correct; no
  plan-wide replacement to 31750 is needed.
- This validates RapidWright block-frame indexing against the project parser.
- It does **not** validate the 28 row-overhead FAR values; Codex's `PARTIAL`
  verdict on those remains in force.

## Commands used

```text
# Python
PYTHONPATH=/data/lzh/v7re /data/lzh/venv/bin/python frame_hash_check.py a.bit 31750 0x4203A2

# RapidWright
RAPIDWRIGHT_PATH=/data/lzh/tools/rapidwright-data \
  java -cp rapidwright-standalone.jar:. FrameCompare a.bit 0x4203A2
```
