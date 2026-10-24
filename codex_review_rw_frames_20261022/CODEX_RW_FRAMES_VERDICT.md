# Codex verification: RapidWright row-overhead frames

Date: 2026-10-22
Model: `gpt-6.1-sol` (high)
Mode: closed-book; no network/GitHub/javadoc fetch
Bundle: `E:/DEEPSEEK/FPGA比特流逆向/codex_review_rw_frames_20261022`
Command: `codex exec -C <bundle> --skip-git-repo-check --dangerously-bypass-approvals-and-sandbox -m gpt-6.1-sol -o CODEX_RW_FRAMES.md -`

## Verdict

```text
VERDICT: PARTIAL
```

## Confirmed

- `50,176 - 50,148 = 28 = 14 * 2` is arithmetically exact.
- The javadoc wording for `FRAME_OVERHEAD_COUNT_PER_ROW`
  ("extra frames at the end of a configuration row") supports the
  two-overhead-per-row interpretation.
- The insertion test gives `total=50,176` and places `0x4203A0` at index
  `31,748`, matching the stated M3 anchor.
- `word_size = 5,067,776 = 50,176 * 101`, consistent with 50,176 frames of
  101 words.
- The target `CLBLM_R_X7Y10` is in row 7; six preceding rows contribute
  `6 * 2 = 12`, explaining the earlier shift from 31,736 to 31,748. The row
  position/explanation is inference from the insertion model, not directly
  established by the javadoc.

## Not confirmed by the public API

- That overhead frames have `Frame` objects.
- That their FAR values are last block FAR + 1 / + 2.
- That they belong to any `Block` or `ConfigRow`, or have a tile association.
- Support for block types beyond `CLB` and `BRAM_CONTENT`.
- Null/unconfigured frame export semantics.

Codex's exact conclusion:

> For Phase A, the supplied evidence does not document an API that returns
> overhead frames or their FARs. Inserting two entries per row and incrementing
> FAR by one for each is therefore an unverified construction, not a documented
> result. Do not treat those generated FARs, or tile associations inferred from
> them, as confirmed without an independent frame-address map or equivalent
> validation.

## Project decision

- Accept the **index/count model** (14 × 2 overhead) as confirmed.
- Do **not** accept the overhead FAR values as confirmed.
- `frame_map` entries for overhead frames must carry
  `frame_address_source='rapidwright-overhead-inferred'` and
  `verified=0` until an independent frame-hash/address check passes.
- `site_frames` must not use inferred overhead FARs.
- Next validation: compare M3 frame 31,748 with the frame at FAR `0x4203A0`
  by frame hash, and independently recover overhead FARs.
