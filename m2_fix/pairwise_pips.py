import json
from pathlib import Path

root = Path('/data/lzh/v7re/data/m2/fam/clbll_l')
dirs = {p.name: p for p in sorted(root.glob('pin_a*')) if (p / 'pips.txt').is_file()}
pips = {name: set((p / 'pips.txt').read_text().split()) for name, p in dirs.items()}

print('available:', ', '.join(dirs))
print('\nactual pairwise pip symdiff:')
for a, b in [('pin_a1','pin_a2'),('pin_a1','pin_a3'),('pin_a1','pin_a4'),('pin_a1','pin_a5'),('pin_a1','pin_a6'),
             ('pin_a2','pin_a3'),('pin_a2','pin_a4'),('pin_a2','pin_a5'),('pin_a2','pin_a6'),
             ('pin_a3','pin_a4'),('pin_a3','pin_a5'),('pin_a3','pin_a6'),
             ('pin_a4','pin_a5'),('pin_a4','pin_a6'),('pin_a5','pin_a6')]:
    if a in pips and b in pips:
        sa, sb = pips[a], pips[b]
        print(f'{a[5:]} vs {b[5:]}: symdiff={len(sa ^ sb)} common={len(sa & sb)}')

cand_path = root.parent.parent / 'search' / 'candidates.json'
if cand_path.is_file():
    rows = json.loads(cand_path.read_text())
    print('\npredicted candidates (same letter pins only):')
    for row in rows:
        pa, pb = row.get('pin_a',''), row.get('pin_b','')
        print(f"{row.get('tile_type')} {pa}->{pb}: branch={row.get('branch_pips')} "
              f"paths={row.get('len_a')}/{row.get('len_b')} lca={row.get('lca')}")
