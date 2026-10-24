# M2 evidence gate verification (2026-10-22)

All commands were run in `/data/lzh/v7re` with `/data/lzh/venv/bin/python`.

## Normal gate

```
$ python scripts/check_m2_gate.py
pairs=6 families=3 input_transitions=2 mux_signatures=4 valid=6 failed=0
M2 GATE PASS
$ echo $?
0
```

## Strict transition gate

```
$ python scripts/check_m2_gate.py --min-input-transitions 2
pairs=6 families=3 input_transitions=2 mux_signatures=4 valid=6 failed=0
M2 GATE PASS
$ echo $?
0
```

`m2_mcd_0006` supplies the second transition (`B3 -> B5`) while keeping
`pip_symdiff=4`.

## Negative test (corrupted evidence must fail)

A temporary copy of pair 0001 had `(22,9)` changed to `(22,99)`:

```
FAIL /tmp/m2_bad/m2_mcd_0001.json: data_bits mismatch: declared
[(22, 2), (22, 3), (22, 99)], actual [(22, 2), (22, 3), (22, 9)]
M2 GATE INCOMPLETE ...
$ echo $?
1
```

## Route sink validator (silent fallback must fail)

A temporary copy of pair 0001 declared `sink_pin_b = "B3"` while its actual
route ended at `CLBLM_M_A5`:

```
$ python /tmp/test_route_validator.py
FAIL /tmp/m2_bad_sink/m2_mcd_0001.json: route_log_b does not end at requested sink B3 (actual 'CLBLM_M_A5')
M2 GATE INCOMPLETE ...
$ echo $?
1
```

The gate also rejects any build log containing `CRITICAL WARNING`, so the old
B3/B5 fallback-to-B1 logs cannot be admitted accidentally.

## Unit tests

```
$ python -m unittest discover -s tests -v
Ran 14 tests in 0.163s
OK
```

New tests in `tests/test_frames.py` cover unequal frame counts and the
payload-only `frame_hash`.

## Rebuild reproducibility

`m2_mcd_0002` A-side, `design.bit` vs `design_run1.bit`:

```
frame_hash(design.bit) = 8c3faa90d0e7aa5c154cfbbd048b1e06dd356f459af34edbc41684150e2fa22e
frame_hash(design_run1.bit) = 8c3faa90d0e7aa5c154cfbbd048b1e06dd356f459af34edbc41684150e2fa22e
```

The whole-file `.bit` hashes differ because the header timestamp changed; the
frame payload is identical. This is why the gate treats `frame_sha256_*` as
authoritative and whole-file SHA only as provenance.
