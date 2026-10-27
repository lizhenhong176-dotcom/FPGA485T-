import sys, struct

def read_frames(path):
    data = open(path, 'rb').read()
    # find first packet: FF FF FF FF 00 00 00 65 (word count 101)
    pat = b'\xff\xff\xff\xff\x00\x00\x00\x65'
    start = data.find(pat)
    if start < 0:
        raise SystemExit('no frame pattern in ' + path)
    body = data[start:]
    n = len(body) // 404
    return [body[i*404+4:(i+1)*404] for i in range(n)]

def bits_of(frames):
    out = set()
    for fi, fr in enumerate(frames):
        for w in range(101):
            if w == 50:
                continue
            val = struct.unpack('>I', fr[w*4:w*4+4])[0]
            for b in range(32):
                if (val >> b) & 1:
                    out.add((fi, w, b))
    return out

a, b = sys.argv[1], sys.argv[2]
A = bits_of(read_frames(a))
B = bits_of(read_frames(b))
d = B - A
print(f'{a} vs {b}: frames_a={0} diff={len(d)}')
byframe = {}
for fi, w, bit in sorted(d):
    byframe.setdefault(fi, []).append((w, bit))
for fi in sorted(byframe):
    print('frame', fi, byframe[fi])
