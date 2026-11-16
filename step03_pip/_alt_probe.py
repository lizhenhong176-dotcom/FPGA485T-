import json, sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

BIT = "/opt/lzh/step03/colscan/c9/ref_C9.bit"
REF = json.load(open("/tmp/alt_payload.json"))
BASE = 31788          # INT_R_X9Y11 的 block_start
Y = 11

fr = frames_from_bit(BIT)
print("frames", len(fr), "type", type(fr).__name__)

def bitval(frame, word, bit):
    """从 frame 数据里取位。frames_from_bit 的返回结构未知，做多形态兼容。"""
    f = fr[frame]
    if isinstance(f, (bytes, bytearray)):
        w = int.from_bytes(f[word * 4:word * 4 + 4], "little")
    elif isinstance(f, (list, tuple)):
        if len(f) > word and isinstance(f[word], int):
            w = f[word]
        else:            # 位列表
            return (f[frame * 0 + word * 32 + bit] > 0) if len(f) > word * 32 + bit else None
    else:
        return None
    return (w >> bit) & 1

def code(family, src_cells, parity):
    bits = []
    for off, bit, sense, _p in src_cells:
        v = bitval(BASE + off, 2 * (Y % 50) + parity, bit)
        if v is None:
            return None
        bits.append(v if sense else (1 - v))
    return tuple(bits)

for parity in (0, 1):
    exact = 0
    total = 0
    for family, srcs in REF.items():
        pats = {s: code(family, cells, parity) for s, cells in srcs.items()}
        if any(v is None for v in pats.values()):
            continue
        total += 1
        hits = [s for s, p in pats.items() if p and all(p)]
        if len(hits) >= 1:
            exact += 1
    print(f"parity={parity}: 有合法源命中 {exact}/{total}")
