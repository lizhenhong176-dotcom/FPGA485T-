"""CSP joint disambiguation of the 48 IMUX muxes (X8Y11 + X9Y11) on s8_v0.bit.

Variables : 48 muxes (tilepipe.json tags)
Domains   : ~25 sources each (incl. VCC_WIRE default, bits = [])
Constraints:
  C1 (legal):    bits(chosen) ⊆ O_pool   -- one-time domain prefilter
  C2 (complete): every bit in O_pool is covered by >= 1 chosen source
Search    : unit-propagation on uncovered bits (mux-forced coverage) + MRV backtracking.
Output    : solutions count + assignment; unique => decoded IMUX map.
"""
import json, sys
from collections import defaultdict

D = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip'

# ---- observed bits in the pool window (frames off 16-25 from B, words 22/23) ----
col = json.load(open(D + r'\s8_col.json'))
fr = {int(k): v for k, v in col['col'].items()}
B = 31680
POOL_FRAMES = range(B + 16, B + 26)
POOL_WORDS = (22, 23)
O = set()
for f in fr:
    if f in POOL_FRAMES:
        for w in POOL_WORDS:
            word = fr[f][w]
            if word:
                for b in range(32):
                    if word >> b & 1:
                        O.add((f, w, b))
# §5.6 constant baseline bits (set in EVERY bitstream, belong to no mux source;
# stripped from tilepipe during diff cleaning) — must strip from observation too.
CONST_NOISE = {(31696, 23, 0), (31702, 23, 0), (31704, 23, 0), (31705, 23, 0)}
O -= CONST_NOISE
print(f'observed pool bits: {len(O)} (after removing {len(CONST_NOISE)} constant w23 noise bits)')

# ---- variables / domains ----
tj = json.load(open(D + r'\tilepipe.json'))
muxes = sorted(tj)  # 48 tags
dom = {}            # tag -> {src: bitset}
for tag in muxes:
    entry = tj[tag]
    d = {}
    for src, bits in entry['sources'].items():
        bs = frozenset(tuple(x) for x in bits)
        if bs <= O:                 # C1 prefilter
            d[src] = bs
    dom[tag] = d
    dropped = len(entry['sources']) - len(d)
    if dropped:
        print(f'  {tag}: {len(d)}/{len(entry["sources"])} sources survive C1 ({dropped} dropped)')

# ---- bit -> muxes that can cover it ----
cover = defaultdict(set)
for tag in muxes:
    for src, bs in dom[tag].items():
        for bit in bs:
            cover[bit].add(tag)

orphan = [b for b, ms in cover.items() if not ms]
if orphan:
    print(f'!! bits coverable by NO mux: {orphan}')

# ---- search ----
solutions = []
def search(assign, remaining):
    if len(solutions) > 10:      # cap for ambiguity report
        return
    if not remaining:
        solutions.append(dict(assign))
        return
    # unit propagation: bit coverable by exactly one *unassigned* mux
    forced = None
    for bit in remaining:
        cand = [t for t in cover[bit] if t not in assign]
        if len(cand) == 1:
            forced = (cand[0], bit)
            break
        if len(cand) == 0:
            return               # dead end
    # pick forced mux, else MRV
    if forced:
        tag, bit = forced
    else:
        un = [t for t in muxes if t not in assign]
        tag = min(un, key=lambda t: len(dom[t]))
    for src, bs in dom[tag].items():
        if forced and bit not in bs:
            continue
        search({**assign, tag: src}, remaining - bs)

search({}, O)
print(f'\nsolutions: {len(solutions)}')
if len(solutions) == 1:
    sol = solutions[0]
    print('\n=== UNIQUE IMUX assignment ===')
    for tag in muxes:
        if sol.get(tag, 'VCC_WIRE') != 'VCC_WIRE':
            print(f'  {tag}: {sol[tag]}  (mux {tj[tag]["sink"]})')
    json.dump({t: s for t, s in sol.items()}, open(D + r'\s8_csp_solution.json', 'w'), indent=1)
else:
    for s in solutions[:3]:
        print({t: v for t, v in s.items() if v != 'VCC_WIRE'})
