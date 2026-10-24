# Y51 boundary validation (A3/A5)

Small validation run on the lab machine.

## Design

- source: `SLICE_X8Y50 / A6LUT`
- sink:   `SLICE_X8Y51 / A6LUT`
- same two-LUT OR design, only the sink pin changes

## Routes

A3:

```
CLBLL_L_X6Y50/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12
INT_L_X6Y50/INT_L.LOGIC_OUTS_L12->>NR1BEG0
INT_L_X6Y51/INT_L.NR1END0->>IMUX_L1
CLBLL_L_X6Y51/CLBLL_L.CLBLL_IMUX1->CLBLL_LL_A3
```

A5:

```
CLBLL_L_X6Y50/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12
INT_L_X6Y50/INT_L.LOGIC_OUTS_L12->>NR1BEG0
INT_L_X6Y51/INT_L.NR1END0->>IMUX_L8
CLBLL_L_X6Y51/CLBLL_L.CLBLL_IMUX8->CLBLL_LL_A5
```

`pip_symdiff=4`; both designs completed with `rc=0` and 20,273,538-byte
`design.bit`.

## Frames

```
diff_frames = [26450, 26453, 26454, 26455, 26456, 26457, 26458, 26459]
```

Non-word-50 bits (8 total):

```
frame 26450: (2,9)
frame 26453: (2,3)
frame 26454: (2,9)
frame 26455: (2,2)
frame 26456: (2,2)
frame 26457: (2,9)
frame 26458: (2,2)
frame 26459: (2,9)
```

Word 50 has 50 differing bits across the eight frames, typically 6-8 bits per
frame, e.g. frame 26450 has bits `0,3,5,6,8,9,12`.

## What this validates

At target row 51 the data word is **word 2**, not the `2*51+1=103` that a
global-row interpolation would give.  Row 51 is the second row of the next
clock region, so the frame word index resets at the clock-region boundary.
This confirms the clock-region reset and gives a boundary test point for the
word model.

The word-50 bits are still present and still not explained.  This experiment
does not prove they are ECC/auxiliary; it only shows they continue across the
boundary.

Do not add this to `data/m2/pairs/`: it is a boundary validation of the same
A3/A5 transition, not an independent transition.
