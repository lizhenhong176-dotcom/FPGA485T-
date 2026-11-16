# -*- coding: utf-8 -*-
"""7 系列帧 ECC（word 50 低 13 位）的增量重算。

模型
----
ECC 对 50 个配置字（1600 位）是 GF(2) 线性的：`ecc(x) = M·x`（常数项为 0，空帧 ECC=0 已实测）。
因此改写若干位时不必知道整个 M，只要知道被改写位置的 13 位列：

    ecc_new = ecc_old ^ xor_{pos in changed} col(pos)

`ecc_table.json` 就是 `{"word:bit": 13 位整数}`，目前由 IMUX 写位实验拟合得到
（`fit_ecc.py`）。未收录的位置会抛 `UnknownPosition`，避免静默算错。

用法
----
    from imux_ecc import patch_frames
    patch_frames(frames, old_snapshot, words=None)
"""
from __future__ import annotations

import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TABLE = os.path.join(HERE, "ecc_table.json")
ECC_WORD = 50
ECC_MASK = 0x1FFF


class UnknownPosition(KeyError):
    pass


class EccTable:
    def __init__(self, path=TABLE):
        raw = json.load(open(path, encoding="utf-8"))
        self.col = {}
        for k, v in raw.items():
            w, b = k.split(":")
            self.col[(int(w), int(b))] = int(v)

    def syndrome(self, positions):
        v = 0
        for pos in positions:
            try:
                v ^= self.col[pos]
            except KeyError:
                raise UnknownPosition(pos)
        return v

    def delta(self, old_words, new_words, ecc_old):
        """old_words/new_words: 同一帧的 50 个配置字（不含 ECC）。返回新的 ECC 值。"""
        ch = []
        for w in range(50):
            d = old_words[w] ^ new_words[w]
            while d:
                b = d & -d
                ch.append((w, b.bit_length() - 1))
                d ^= b
        return ecc_old ^ self.syndrome(ch)


def patch_frames(frames, old, table=None, ecc_word=ECC_WORD):
    """frames: [[101 个字], ...]；old: 改动前的同样结构（浅拷贝即可）。

    只处理 50 个配置字有变化的帧；变化位若不在表里会抛 UnknownPosition。
    """
    table = table or EccTable()
    patched = 0
    for i, fr in enumerate(frames):
        o = old[i]
        if fr[:50] == o[:50]:
            continue
        fr[ecc_word] = table.delta(o[:50], fr[:50], fr[ecc_word]) & ECC_MASK
        patched += 1
    return patched
