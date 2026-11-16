"""crc_solve_all.py —— 用全部本地位流联合求解 CRC 各位置贡献（GF(2)）。

原理：CRC 对报文位是仿射函数，`CRC(A)^CRC(B) = XOR_{p in A△B} c(p)`。
同目录内以第一个文件为基准，构造方程；再对 32 个位平面分别做高斯消元。
"""
import sys, os, io, glob, struct, collections
import numpy as np
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from bitstream.parser import frames_from_bit, SYNC


def load_matrix(path):
    """直接按 sync 偏移解析 payload，返回 (帧数, 101) 的 uint32 矩阵。"""
    raw = open(path, "rb").read()
    off = raw.find(SYNC)
    if off < 0:
        return None, None
    words = np.frombuffer(raw[off + 4:], dtype=">u4").astype(np.uint32)
    n = (len(words) // 101) * 101
    m = words[:n].reshape(-1, 101)
    return m, words


def crc_of_words(words):
    idx = np.nonzero(words == 0x30000001)[0]
    if len(idx) == 0:
        return None
    j = int(idx[0]) + 1
    return int(words[j]) if j < len(words) else None


def cells_of_matrix(m):
    mm = m.copy()
    mm[:, 50] = 0
    fi, wi = np.nonzero(mm)
    out = set()
    for f, w in zip(fi.tolist(), wi.tolist()):
        v = int(mm[f, w])
        while v:
            b = (v & -v).bit_length() - 1
            out.add((f, w, b))
            v &= v - 1
    return out


def parse_one(path):
    m, words = load_matrix(path)
    if m is None:
        return None
    return cells_of_matrix(m), crc_of_words(words)


def gf2_solve(eqs, nvars, nbits=32):
    """eqs: list of (mask:int, rhs:int)。返回 (sol, contradicted, rank)。"""
    sol = [0] * nvars
    solved_bits = []
    for bit in range(nbits):
        rows = [(m, (r >> bit) & 1) for m, r in eqs]
        piv = {}
        ok = True
        for m, r in rows:
            mm, rr = m, r
            while mm:
                h = mm.bit_length() - 1
                if h in piv:
                    mm ^= piv[h][0]
                    rr ^= piv[h][1]
                else:
                    piv[h] = (mm, rr)
                    break
            if mm == 0 and rr:
                ok = False
                break
        if not ok:
            return None, True, -1
        # 回代
        vec = {}
        for h in sorted(piv, reverse=True):
            mm, rr = piv[h]
            acc = rr
            rest = mm ^ (1 << h)
            while rest:
                h2 = rest.bit_length() - 1
                acc ^= vec.get(h2, 0)
                rest ^= 1 << h2
            vec[h] = acc
        for h, v in vec.items():
            if v:
                sol[h] |= 1 << bit
        solved_bits.append(len(piv))
    return sol, False, min(solved_bits) if solved_bits else 0


def main(dirs=None, limit_per_dir=None):
    files = sorted(glob.glob("**/*.bit", recursive=True))
    bydir = collections.defaultdict(list)
    for f in files:
        bydir[os.path.dirname(f)].append(f)
    cache = {}
    raw_eqs = []
    used = 0
    sizes = {}
    MAXDIFF = int(os.environ.get('MAXDIFF', '4'))
    for d, fs in sorted(bydir.items()):
        fs = sorted(fs)
        if limit_per_dir:
            fs = fs[:limit_per_dir]
        if len(fs) < 2:
            continue
        # 选「置位格最少」的文件作为基准（即最可能的空白/基线设计）
        scored = []
        for f in fs:
            try:
                r = parse_one(f)
            except Exception:
                continue
            if r is None:
                continue
            scored.append((len(r[0]), f))
        if not scored:
            continue
        scored.sort()
        base = scored[0][1]
        fs = [f for _, f in scored]
        try:
            if base not in cache:
                cache[base] = (parse_one(base)[0], parse_one(base)[1])
            cb, crcb = cache[base]
            if crcb is None:
                continue
        except Exception:
            continue
        for f in fs[1:]:
            try:
                if f not in cache:
                    cache[f] = (parse_one(f)[0], parse_one(f)[1])
                cf, crcf = cache[f]
            except Exception:
                continue
            if crcf is None:
                continue
            diff = cb ^ cf
            if not diff:
                continue
            sizes[len(diff)] = sizes.get(len(diff), 0) + 1
            if len(diff) <= MAXDIFF:
                raw_eqs.append((diff, crcf ^ crcb))
                used += 1
        del cache[base]
    print("diff-size histogram (top):", sorted(sizes.items())[:12], flush=True)
    print("equations:", len(raw_eqs), flush=True)

    universe = sorted({p for diff, _ in raw_eqs for p in diff})
    pos_id = {p: i for i, p in enumerate(universe)}
    print("positions:", len(universe), flush=True)
    eqs = []
    for diff, rhs in raw_eqs:
        m = 0
        for p in diff:
            m |= 1 << pos_id[p]
        eqs.append((m, rhs))
    sol, contra, rank = gf2_solve(eqs, len(universe))
    print("rank:", rank, "contradicted:", contra, flush=True)
    if contra:
        return
    covered = sum(1 for v in sol if v)
    print("learned nonzero signatures:", covered, "of", len(universe), flush=True)

    # 留一法：用解算结果预测最后 5 条方程
    hits = 0
    for m, rhs in eqs[-5:]:
        pred = 0
        mm = m
        while mm:
            h = mm.bit_length() - 1
            pred ^= sol[h]
            mm ^= 1 << h
        hits += (pred == rhs)
    print("holdout(last5): %d/5" % hits, flush=True)


if __name__ == "__main__":
    main()
