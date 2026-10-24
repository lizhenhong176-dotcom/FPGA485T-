# Shared-IMUX candidate search

Source: `routing/v7_routing.db` templates + tileconn.
A candidate has `branch_pips <= 4` after the deepest common INT wire.

| # | type | LUT | pins | branch | LCA |
|---:|---|---|---|---:|---|
| 1 | CLBLL_L | CLBLL_LL_A | A2->A4 | 4 | `NR1END1` |
| 2 | CLBLL_L | CLBLL_LL_A | A3->A5 | 4 | `NR1END0` |
| 3 | CLBLL_L | CLBLL_LL_B | B2->B4 | 4 | `NR1END1` |
| 4 | CLBLL_L | CLBLL_LL_B | B3->B5 | 4 | `NR1END0` |
| 5 | CLBLL_L | CLBLL_LL_C | C2->C4 | 4 | `NR1END2` |
| 6 | CLBLL_L | CLBLL_LL_C | C3->C5 | 4 | `NR1END3` |
| 7 | CLBLL_L | CLBLL_LL_D | D2->D4 | 4 | `NR1END2` |
| 8 | CLBLL_L | CLBLL_LL_D | D3->D5 | 4 | `NR1END3` |
| 9 | CLBLL_L | CLBLL_L_A | A2->A4 | 4 | `NR1END1` |
| 10 | CLBLL_L | CLBLL_L_A | A3->A5 | 4 | `NR1END0` |
| 11 | CLBLL_L | CLBLL_L_B | B2->B4 | 4 | `NR1END1` |
| 12 | CLBLL_L | CLBLL_L_B | B3->B5 | 4 | `NR1END0` |
| 13 | CLBLL_L | CLBLL_L_C | C2->C4 | 4 | `NR1END2` |
| 14 | CLBLL_L | CLBLL_L_C | C3->C5 | 4 | `NR1END3` |
| 15 | CLBLL_L | CLBLL_L_D | D2->D4 | 4 | `NR1END2` |
| 16 | CLBLL_L | CLBLL_L_D | D3->D5 | 4 | `NR1END3` |
| 17 | CLBLL_R | CLBLL_LL_A | A2->A4 | 4 | `NR1END1` |
| 18 | CLBLL_R | CLBLL_LL_A | A3->A5 | 4 | `NR1END0` |
| 19 | CLBLL_R | CLBLL_LL_B | B2->B4 | 4 | `NR1END1` |
| 20 | CLBLL_R | CLBLL_LL_B | B3->B5 | 4 | `NR1END0` |
| 21 | CLBLL_R | CLBLL_LL_C | C2->C4 | 4 | `NR1END2` |
| 22 | CLBLL_R | CLBLL_LL_C | C3->C5 | 4 | `NR1END3` |
| 23 | CLBLL_R | CLBLL_LL_D | D2->D4 | 4 | `NR1END2` |
| 24 | CLBLL_R | CLBLL_LL_D | D3->D5 | 4 | `NR1END3` |
| 25 | CLBLL_R | CLBLL_L_A | A2->A4 | 4 | `NR1END1` |
| 26 | CLBLL_R | CLBLL_L_A | A3->A5 | 4 | `NR1END0` |
| 27 | CLBLL_R | CLBLL_L_B | B2->B4 | 4 | `NR1END1` |
| 28 | CLBLL_R | CLBLL_L_B | B3->B5 | 4 | `NR1END0` |
| 29 | CLBLL_R | CLBLL_L_C | C2->C4 | 4 | `NR1END2` |
| 30 | CLBLL_R | CLBLL_L_C | C3->C5 | 4 | `NR1END3` |
| 31 | CLBLL_R | CLBLL_L_D | D2->D4 | 4 | `NR1END2` |
| 32 | CLBLL_R | CLBLL_L_D | D3->D5 | 4 | `NR1END3` |
| 33 | CLBLM_L | CLBLM_L_A | A2->A4 | 4 | `NR1END1` |
| 34 | CLBLM_L | CLBLM_L_A | A3->A5 | 4 | `NR1END0` |
| 35 | CLBLM_L | CLBLM_L_B | B2->B4 | 4 | `NR1END1` |
| 36 | CLBLM_L | CLBLM_L_B | B3->B5 | 4 | `NR1END0` |
| 37 | CLBLM_L | CLBLM_L_C | C2->C4 | 4 | `NR1END2` |
| 38 | CLBLM_L | CLBLM_L_C | C3->C5 | 4 | `NR1END3` |
| 39 | CLBLM_L | CLBLM_L_D | D2->D4 | 4 | `NR1END2` |
| 40 | CLBLM_L | CLBLM_L_D | D3->D5 | 4 | `NR1END3` |
| 41 | CLBLM_L | CLBLM_M_A | A2->A4 | 4 | `NR1END1` |
| 42 | CLBLM_L | CLBLM_M_A | A3->A5 | 4 | `NR1END0` |
| 43 | CLBLM_L | CLBLM_M_B | B2->B4 | 4 | `NR1END1` |
| 44 | CLBLM_L | CLBLM_M_B | B3->B5 | 4 | `NR1END0` |
| 45 | CLBLM_L | CLBLM_M_C | C2->C4 | 4 | `NR1END2` |
| 46 | CLBLM_L | CLBLM_M_C | C3->C5 | 4 | `NR1END3` |
| 47 | CLBLM_L | CLBLM_M_D | D2->D4 | 4 | `NR1END2` |
| 48 | CLBLM_L | CLBLM_M_D | D3->D5 | 4 | `NR1END3` |
| 49 | CLBLM_R | CLBLM_L_A | A2->A4 | 4 | `NR1END1` |
| 50 | CLBLM_R | CLBLM_L_A | A3->A5 | 4 | `NR1END0` |
| 51 | CLBLM_R | CLBLM_L_B | B2->B4 | 4 | `NR1END1` |
| 52 | CLBLM_R | CLBLM_L_B | B3->B5 | 4 | `NR1END0` |
| 53 | CLBLM_R | CLBLM_L_C | C2->C4 | 4 | `NR1END2` |
| 54 | CLBLM_R | CLBLM_L_C | C3->C5 | 4 | `NR1END3` |
| 55 | CLBLM_R | CLBLM_L_D | D2->D4 | 4 | `NR1END2` |
| 56 | CLBLM_R | CLBLM_L_D | D3->D5 | 4 | `NR1END3` |
| 57 | CLBLM_R | CLBLM_M_A | A2->A4 | 4 | `NR1END1` |
| 58 | CLBLM_R | CLBLM_M_A | A3->A5 | 4 | `NR1END0` |
| 59 | CLBLM_R | CLBLM_M_B | B2->B4 | 4 | `NR1END1` |
| 60 | CLBLM_R | CLBLM_M_B | B3->B5 | 4 | `NR1END0` |
| 61 | CLBLM_R | CLBLM_M_C | C2->C4 | 4 | `NR1END2` |
| 62 | CLBLM_R | CLBLM_M_C | C3->C5 | 4 | `NR1END3` |
| 63 | CLBLM_R | CLBLM_M_D | D2->D4 | 4 | `NR1END2` |
| 64 | CLBLM_R | CLBLM_M_D | D3->D5 | 4 | `NR1END3` |
| 65 | CLBLL_L | CLBLL_LL_A | A2->A3 | 4 | `ER1END0` |
| 66 | CLBLL_L | CLBLL_LL_A | A4->A6 | 4 | `ER1END1` |
| 67 | CLBLL_L | CLBLL_LL_B | B2->B3 | 4 | `ER1END0` |
| 68 | CLBLL_L | CLBLL_LL_B | B2->B5 | 4 | `ER1END0` |
| 69 | CLBLL_L | CLBLL_LL_B | B4->B6 | 4 | `ER1END1` |
| 70 | CLBLL_L | CLBLL_LL_C | C2->C3 | 4 | `ER1END2` |
| 71 | CLBLL_L | CLBLL_LL_C | C3->C4 | 4 | `ER1END2` |
| 72 | CLBLL_L | CLBLL_L_A | A1->A6 | 4 | `ER1END2` |
| 73 | CLBLL_L | CLBLL_L_A | A4->A5 | 4 | `ER1END0` |
| 74 | CLBLL_L | CLBLL_L_B | B1->B6 | 4 | `ER1END2` |
| 75 | CLBLL_L | CLBLL_L_C | C2->C6 | 4 | `ER1END1` |
| 76 | CLBLL_R | CLBLL_LL_A | A2->A3 | 4 | `ER1END0` |
| 77 | CLBLL_R | CLBLL_LL_A | A4->A6 | 4 | `ER1END1` |
| 78 | CLBLL_R | CLBLL_LL_B | B2->B3 | 4 | `ER1END0` |
| 79 | CLBLL_R | CLBLL_LL_B | B2->B5 | 4 | `ER1END0` |
| 80 | CLBLL_R | CLBLL_LL_B | B4->B6 | 4 | `ER1END1` |

## Valid pin names per LUT

- `CLBLL_L` / `CLBLL_LL_A`: A1, A2, A3, A4, A5, A6
- `CLBLL_L` / `CLBLL_LL_B`: B1, B2, B3, B4, B5, B6
- `CLBLL_L` / `CLBLL_LL_C`: C1, C2, C3, C4, C5, C6
- `CLBLL_L` / `CLBLL_LL_D`: D1, D2, D3, D4, D5, D6
- `CLBLL_L` / `CLBLL_L_A`: A1, A2, A3, A4, A5, A6
- `CLBLL_L` / `CLBLL_L_B`: B1, B2, B3, B4, B5, B6
- `CLBLL_L` / `CLBLL_L_C`: C1, C2, C3, C4, C5, C6
- `CLBLL_L` / `CLBLL_L_D`: D1, D2, D3, D4, D5, D6
- `CLBLL_R` / `CLBLL_LL_A`: A1, A2, A3, A4, A5, A6
- `CLBLL_R` / `CLBLL_LL_B`: B1, B2, B3, B4, B5, B6
- `CLBLL_R` / `CLBLL_LL_C`: C1, C2, C3, C4, C5, C6
- `CLBLL_R` / `CLBLL_LL_D`: D1, D2, D3, D4, D5, D6
- `CLBLL_R` / `CLBLL_L_A`: A1, A2, A3, A4, A5, A6
- `CLBLL_R` / `CLBLL_L_B`: B1, B2, B3, B4, B5, B6
- `CLBLL_R` / `CLBLL_L_C`: C1, C2, C3, C4, C5, C6
- `CLBLL_R` / `CLBLL_L_D`: D1, D2, D3, D4, D5, D6
- `CLBLM_L` / `CLBLM_L_A`: A1, A2, A3, A4, A5, A6
- `CLBLM_L` / `CLBLM_L_B`: B1, B2, B3, B4, B5, B6
- `CLBLM_L` / `CLBLM_L_C`: C1, C2, C3, C4, C5, C6
- `CLBLM_L` / `CLBLM_L_D`: D1, D2, D3, D4, D5, D6
- `CLBLM_L` / `CLBLM_M_A`: A1, A2, A3, A4, A5, A6
- `CLBLM_L` / `CLBLM_M_B`: B1, B2, B3, B4, B5, B6
- `CLBLM_L` / `CLBLM_M_C`: C1, C2, C3, C4, C5, C6
- `CLBLM_L` / `CLBLM_M_D`: D1, D2, D3, D4, D5, D6
- `CLBLM_R` / `CLBLM_L_A`: A1, A2, A3, A4, A5, A6
- `CLBLM_R` / `CLBLM_L_B`: B1, B2, B3, B4, B5, B6
- `CLBLM_R` / `CLBLM_L_C`: C1, C2, C3, C4, C5, C6
- `CLBLM_R` / `CLBLM_L_D`: D1, D2, D3, D4, D5, D6
- `CLBLM_R` / `CLBLM_M_A`: A1, A2, A3, A4, A5, A6
- `CLBLM_R` / `CLBLM_M_B`: B1, B2, B3, B4, B5, B6
- `CLBLM_R` / `CLBLM_M_C`: C1, C2, C3, C4, C5, C6
- `CLBLM_R` / `CLBLM_M_D`: D1, D2, D3, D4, D5, D6
