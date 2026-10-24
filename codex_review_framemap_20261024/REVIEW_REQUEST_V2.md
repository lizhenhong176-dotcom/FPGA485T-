# Re-review Request (v2): frame_map import after CONDITIONAL_PASS fixes

## v1 verdict

CONDITIONAL_PASS (P1-1, P1-2, P2-3, P2-4) — see `CODEX_FRAME_MAP_VERDICT.md`.

## Fixes applied in v2

**P1-1 (import robustness)** — `import_frame_map.py` was rewritten:
- `validate_csv()` performs full pre-DB validation with row-numbered errors:
  header columns exact-match, frame_index integer/range, kind enum, far hex
  syntax/bounds, row range 1-14, block_addr hex, overhead-at-row-end,
  FAR uniqueness, block continuity (block_addr+offset==far, no intra-block
  FAR jumps), 14 config rows, total/counts.
- Bitstream hash-anchor verification moved BEFORE the DB write (abort on
  mismatch, no partial state).
- DB insert is transactional: BEGIN → CREATE (CHECK constraints) → DELETE →
  INSERT → post-insert count check → COMMIT; any error rolls back.

**P1-2 (audit completeness)** — added audits: 14-row structure, overhead
position at each of 14 row ends (from CSV groups AND post-insert DB query),
FAR uniqueness, block continuity, frame_index monotonicity, plus the
original invariants (5.1–5.11). See `data/v2_run_log.txt` for the full
green run.

**P2-3 (schema CHECK constraints)** — frame_map table now has CHECK
constraints on frame_index range, frame_address_source enum, confidence
enum, is_overhead enum. Schema in script matches `data/schema_model.sql`
(please verify).

**P2-4 (status doc wording)** — `FRAME_MAP_STATUS_v2.md` (synced from
`v7re/steps/FRAME_MAP_STATUS.md`):
- "cannot be recovered" → "not recoverable via the RapidWright public API
  as currently documented … a future channel could still resolve them".
- Audit section now states explicitly what the audits DO verify
  (structure/order/uniqueness/provenance/anchors) and what they do NOT
  (independent re-derivation of all 50,148 FARs from a second source —
  not currently available).

## Files in this bundle

- `data/import_frame_map_v2.py` — rewritten script (P1-1, P1-2, P2-3)
- `data/v2_run_log.txt` — actual run output, all checks PASS
- `data/FRAME_MAP_STATUS_v2.md` — updated status doc (P2-4)
- `data/import_frame_map.py` — v1 script (for diff reference)
- `data/FRAME_MAP_STATUS.md` — v1 status doc (for diff reference)
- `data/frame_index_far.csv` — unchanged input (50,176 rows)
- `data/FRAME_INDEX_MAP.md` — derivation doc, unchanged
- `data/schema_model.sql` — project schema incl. frame_map DDL

## Question for the reviewer

Given the v2 fixes and the attached run log, should the verdict be upgraded
from CONDITIONAL_PASS to PASS? If not, what specific additional evidence or
code changes are required? Please be adversarial: check the validation
logic for holes (e.g. fields not validated, checks that can be vacuously
true, transaction gaps), and whether the status-doc claims are now
accurately scoped.
