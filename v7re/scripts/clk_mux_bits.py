#!/usr/bin/env python3
"""clk_mux_bits.py -- BUFGCTRL 输入选择位的编解码（T43 实测公式）。

    f0 = 7834 + 5246 * (Y // 16)
    w  = (93 + Y // 2) mod 101
    偶数 Y：A=(f0, w, 11)  B=(f0+1, w,  3)
    奇数 Y：A=(f0, w, 27)  B=(f0+1, w, 19)

编码（实测）：
    SEL=I1 → A=1, B=0
    SEL=I0 → A=0, B=1
两对位是 one-hot；另一对的位应全为 0。
"""
ROW_FRAMES = 5246
FRAME_WORDS = 101
BASE_FRAME = 7834
BASE_WORD = 93
SITES = 32


def bits_of(Y):
    f0 = BASE_FRAME + ROW_FRAMES * (Y // 16)
    w = (BASE_WORD + Y // 2) % FRAME_WORDS
    if Y % 2 == 0:
        return (f0, w, 11), (f0 + 1, w, 3)
    return (f0, w, 27), (f0 + 1, w, 19)


def decode(M):
    """M[frame][word] -> int。返回 {Y: 'I0'|'I1'|None}（None = 两位都没设）。"""
    out = {}
    for Y in range(SITES):
        a, b = bits_of(Y)
        va = (int(M[a[0]][a[1]]) >> a[2]) & 1
        vb = (int(M[b[0]][b[1]]) >> b[2]) & 1
        if va and not vb:
            out[Y] = "I1"
        elif vb and not va:
            out[Y] = "I0"
        elif not va and not vb:
            out[Y] = None
        else:
            out[Y] = "AMBIG"
    return out


def encode(M, Y, sel):
    """返回该 site 的两个目标位及其取值 [(frame, word, bit, value)]；
    M 参数保留以兼容调用方，可为 None（不看当前值，直接给目标）。"""
    a, b = bits_of(Y)
    return [(a[0], a[1], a[2], 1 if sel == "I1" else 0),
            (b[0], b[1], b[2], 1 if sel == "I0" else 0)]
