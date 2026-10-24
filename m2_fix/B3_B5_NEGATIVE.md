# B3/B5: negative attempt, then corrected positive pair

**Status: superseded.**  The original conclusion ("B-side LUT inputs are not
usable") was wrong.  The failure was a `LOCK_PINS` namespace error, not a
device limitation.

## What was tried originally

- source LUT: `SLICE_X8Y10 / A6LUT`
- sink LUT:   `SLICE_X8Y11 / B6LUT`
- B3 LOCK_PINS: `I0:B3 I1:B1 I2:B2 I3:B4 I4:B5 I5:B6`
- B5 LOCK_PINS: `I0:B5 I1:B1 I2:B2 I3:B3 I4:B4 I5:B6`

`get_site_pins` lists `B1..B6` as valid **site** pins, so the first
interpretation was that B3/B5 should be legal.  But `LOCK_PINS` takes **BEL**
pin names, and every 6LUT BEL exposes `A1..A6`, not `B1..B6`:

```
BEL=SLICE_X8Y11/B6LUT PINS=.../B6LUT/A1 ... /B6LUT/A6 ... /B6LUT/O6
```

The original builds therefore emitted:

```
CRITICAL WARNING: [Vivado 12-2497] Could not set property 'LOCK_PINS'
because 'invalid device pin 'B3''.
CRITICAL WARNING: [Vivado 12-2497] Could not set property 'LOCK_PINS'
because 'invalid device pin 'B5''.
```

and silently fell back to `CLBLL_LL_B1`.

## Corrected experiment

Use `BEL B6LUT` with BEL-pin names:

```
set_property LOCK_PINS {I0:A3 I1:A1 I2:A2 I3:A4 I4:A5 I5:A6} [get_cells lut_b]  ;# B3
set_property LOCK_PINS {I0:A5 I1:A1 I2:A2 I3:A4 I4:A3 I5:A6} [get_cells lut_b]  ;# B5
```

Both builds complete with **0 critical warnings** and route cleanly:

```
B3: CLBLL_LL_A -> CLBLL_LOGIC_OUTS12 -> NR1BEG0 -> IMUX_L17 -> CLBLL_LL_B3
B5: CLBLL_LL_A -> CLBLL_LOGIC_OUTS12 -> NR1BEG0 -> IMUX_L24 -> CLBLL_LL_B5
```

They share the first two PIPs and differ only at `NR1END0->IMUX_L17/L24` plus
the site PIP, so `pip_symdiff=4`.  This is valid corpus pair `m2_mcd_0006`:

- diff frames `31696,31697,31700,31701,31702,31703,31704,31705`
- data bits `(22,4),(22,11)`
- frame hashes `1a62ffbe...` (B3) and `e92bd68f...` (B5)

The original fallback builds remain under `data/m2/fam/clbll_l/b3` and `b5` as
negative history; the corrected builds are `b3_fix` and `b5_fix`.

## Lesson

For a B6LUT/C6LUT/D6LUT sink, `LOCK_PINS` still uses `A1..A6` BEL-pin names.
The requested **site** pin (B3) is the routing endpoint, not the `LOCK_PINS`
argument.  Always check `get_bel_pins -of_objects [get_bels <BEL>]` before
blaming the device.
