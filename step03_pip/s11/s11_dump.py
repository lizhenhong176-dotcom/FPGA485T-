import json, sys
sys.path.insert(0, '/opt/lzh/v7re')
from bitstream.parser import frames_from_bit
out = {}
for v in ['r64s','srl32','r128','r256','r64d','r64d_bd','r64s_we0','f5a','f5b']:
    try:
        frames = frames_from_bit('/opt/lzh/step03/s11/s11_%s.bit' % v)
    except Exception as e:
        out[v] = {'error': str(e)}
        continue
    d = {}
    for f, w in enumerate(frames):
        if 31714 <= f < 31752:
            d[str(f)] = {str(i): [int(b) for b in bin(w[i])[2:].zfill(32)] for i in range(38, 42) if w[i]}
    out[v] = d
json.dump(out, open('/opt/lzh/step03/s11/s11_words.json', 'w'))
print('OK', sorted(out.keys()))
