"""CLB 位级解码器（V7 实测位表）。

用法：
    python v7re/scripts/clb_decode.py <bitstream> <site> [--base N]

site 形如 SLICE_X12Y20；base 缺省用内置表（grid_col 20 / Y=20 的块基址 31752）。
"""
import sys, json, os, argparse
import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
MAP = os.path.join(HERE, "..", "steps", "clb_init_locked_x12y20_4lut.json")

# --- 站点级位（相对块基址 31752 的 (frame_off, word, bit)） --------------
BITS = {
    "FFSYNC":      (0, 41, 16),   # 1 = 同步复位（FDRE），0 = 异步（FDCE）
    "CLKINV":      (1, 41, 19),   # 1 = 时钟反相（negedge）
    "LATCH":       (30, 41, 0),   # 1 = 锁存器（LDCE）
    "CEUSEDMUX":   (1, 41, 7),    # 1 = 使用 CE（强候选）
    "AFFMUX_O5O6": (30, 40, 0),   # 1 = O5，0 = O6
    "SR_USED":     (1, 41, 2),    # 1 = 使用 SR（三格之一，见 SR_USED_ALL）
    "PRECYINIT_1": (0, 40, 12),   # 1 = 进位初值取常量 1
    "FF_INIT":     (67, 40, 3),   # FF 的 INIT
}
SR_USED_ALL = [(1, 41, 2), (1, 41, 3), (1, 41, 9)]
CE_TARGET   = [(23, 41, 0), (24, 41, 0), (25, 41, 0)]
AOUTMUX_O5  = [(3, 40, 8), (4, 40, 10), (6, 41, 4), (7, 41, 5)]
AOUTMUX_O6  = [(3, 40, 4), (4, 41, 10), (6, 41, 8), (7, 40, 5)]


def load_frames(path):
    sys.path.insert(0, os.path.join(HERE, ".."))
    from bitstream.parser import frames_from_bit
    return np.array(frames_from_bit(path), dtype=np.uint32)


def bit(arr, base, cell):
    fo, w, b = cell
    return (int(arr[base + fo, w]) >> b) & 1


def bit_abs(arr, cell):
    f, w, b = cell
    return (int(arr[f, w]) >> b) & 1


def decode_clb(arr, base, with_init=True):
    out = {"site_base": base}
    for name, cell in BITS.items():
        out[name] = bit(arr, base, cell)
    out["SR_USED_3bit"] = [bit(arr, base, c) for c in SR_USED_ALL]
    out["CE_TARGET_3bit"] = [bit(arr, base, c) for c in CE_TARGET]
    a5 = [bit(arr, base, c) for c in AOUTMUX_O5]
    a6 = [bit(arr, base, c) for c in AOUTMUX_O6]
    out["AOUTMUX"] = "O5" if sum(a5) > sum(a6) else "O6"
    if with_init:
        m = json.load(open(MAP, encoding="utf-8"))
        for lut, cells in m.items():
            v = 0
            for k, cell in cells.items():
                v |= bit_abs(arr, tuple(cell)) << int(k)
            out["INIT_" + lut] = v
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bitstream")
    ap.add_argument("site", nargs="?", default="SLICE_X12Y20")
    ap.add_argument("--base", type=int, default=31752)
    ap.add_argument("--json", action="store_true")
    a = ap.parse_args()
    arr = load_frames(a.bitstream)
    r = decode_clb(arr, a.base)
    if a.json:
        print(json.dumps(r, indent=1, ensure_ascii=False))
        return
    print("site %s  base %d" % (a.site, a.base))
    for k, v in r.items():
        if k.startswith("INIT_"):
            print("  %-12s 0x%016x" % (k, v))
        else:
            print("  %-12s %s" % (k, v))


if __name__ == "__main__":
    main()
