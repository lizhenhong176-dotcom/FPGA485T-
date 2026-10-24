from pathlib import Path
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame, frame_hash

root = Path('/data/lzh/v7re/data/m2/validation/init_word50')
frames = {name: load_frames(root / name / 'design.bit') for name in ('base1', 'base2', 'perturb')}
for name, fr in frames.items():
    print(name, len(fr), frame_hash(fr))

def report(a, b):
    fa, fb = frames[a], frames[b]
    ds = diff_frame_indices(fa, fb)
    print('DIFF', a, b, 'frames', ds)
    data, aux = set(), set()
    for f in ds:
        bits = diff_bits_in_frame(fa, fb, f)
        print(' frame', f, bits)
        for w, bit in bits:
            (aux if w == 50 else data).add((w, bit))
    print(' data_bits', sorted(data))
    print(' aux_bits', sorted(aux))

report('base1', 'base2')
report('base1', 'perturb')
for name in ('base1', 'perturb'):
    print(name, 'pips', (root / name / 'pips.txt').read_text().splitlines())
