from pathlib import Path
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame, frame_hash

root = Path('/data/lzh/v7re/data/m2/fam/clbll_l')
a = load_frames(root / 'b3_fix/design.bit')
b = load_frames(root / 'b5_fix/design.bit')
print('frames', len(a), len(b))
print('frame_hash_a', frame_hash(a))
print('frame_hash_b', frame_hash(b))
ds = diff_frame_indices(a, b)
print('diff_frames', ds)
all_bits = set()
aux = set()
for f in ds:
    bits = diff_bits_in_frame(a, b, f)
    print('frame', f, 'bits', bits)
    for w, bit in bits:
        (aux if w == 50 else all_bits).add((w, bit))
print('data_bits', sorted(all_bits))
print('aux_bits', sorted(aux))
