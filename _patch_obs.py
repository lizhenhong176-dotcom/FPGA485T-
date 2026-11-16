import io

p = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip\p1_replication_cells.py'
s = io.open(p, encoding='utf-8').read()
start = s.index('def obs_from_cells(')
end = s.index('def one_design(')
new = '''BAND = [6, 5, 0, 1, 2, 3, 4]


def word_row(word):
    """word -> (row, parity)；word 50 是 ECC，返回 None。"""
    if word == 50:
        return None
    w = word if word < 50 else word - 1
    return (w // 2, w % 2)


def obs_from_cells(W, path):
    """frame/word/bit -> {tile_index: set((frame_off, word, bit))}

    一帧被同一 (band,col) 的 50 个 tile 共享，各自用不同的 word；
    所以必须按 word -> row 把位分给正确的 tile。
    """
    idx = {}
    spans = []
    seen = set()
    for ti, (name, tt, col, y, base) in enumerate(W.tiles):
        if base is None:
            continue
        band = BAND[y // 50]
        idx[(band, col, y % 50)] = ti
        key = (band, col, base)
        if key not in seen:
            seen.add(key)
            spans.append(key)
    obs = collections.defaultdict(set)
    with io.open(path, encoding="utf-8") as f:
        for line in f:
            parts = line.split()
            if len(parts) != 3:
                continue
            fr, w, b = int(parts[0]), int(parts[1]), int(parts[2])
            rp = word_row(w)
            if rp is None:
                continue
            for band, col, base in spans:
                fo = fr - base
                if 0 <= fo < HI:
                    ti = idx.get((band, col, rp[0]))
                    if ti is not None:
                        obs[ti].add((fo, w, b))
                    break
    return obs


'''
s = s[:start] + new + s[end:]
io.open(p, 'w', encoding='utf-8', newline='\n').write(s)
print('patched obs_from_cells')
