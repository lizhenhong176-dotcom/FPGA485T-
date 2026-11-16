# -*- coding: utf-8 -*-
"""V7 (7vx485t) 帧校验字 word50 的编解码。

实证来源（详见 STATUS.md §148–§150）：
  E3  col(word,bit) = F(word) ^ bit ^ (popcount(bit)&1 ? 0x1000 : 0)   —— 位索引方向 GF(2) 线性
  E4-E6  F 表 51 构建实测（A6LUT，frame 31786）
  E7  F 与 frame 号 / tile 列号 / clock region 无关（三帧点实测一致）

用法：
    from ecc_v7 import F_TABLE, ecc_col, frame_ecc, patch_bit
    f = bytearray(frame_bytes)          # 101*4 = 404 B，大端
    patch_bit(f, word=40, bit=15)       # 翻转一位并同步修正 word50
"""
import json
import os

_HERE = os.path.dirname(os.path.abspath(__file__))
_TABLE_PATH = os.path.join(_HERE, "..", "steps", "e6_ecc_table.json")

FRAME_WORDS = 101
ECC_WORD = 50
MASK_BITPOS = 0x1000  # 奇校验位（bit 索引的 popcount 奇偶）

with open(_TABLE_PATH, encoding="utf-8") as _f:
    _doc = json.load(_f)
F_TABLE = {int(k): int(v) for k, v in _doc["F"].items()}
MISSING_WORDS = _doc["words_missing"]

# 相邻 parity 槽可通过 C6LUT 实测补齐；未补齐前这些 word 不可编码。
DATA_WORDS = [w for w in range(FRAME_WORDS) if w != ECC_WORD]


def _parity(x):
    return bin(x).count("1") & 1


def ecc_col(word, bit):
    """某位置上单个置位对 word50 的贡献（13 位）。"""
    if word == ECC_WORD:
        raise ValueError("word 50 是校验字本身，不参与编码")
    if word not in F_TABLE:
        raise KeyError("word %d 的 F 未实测（见 words_missing）" % word)
    if not 0 <= bit < 32:
        raise ValueError("bit 越界: %d" % bit)
    return F_TABLE[word] ^ bit ^ (MASK_BITPOS if _parity(bit) else 0)


def frame_ecc(dwords):
    """dwords: 100 个 32 位数据字（顺序为 word 0..49, 51..100）→ word50。"""
    if len(dwords) != len(DATA_WORDS):
        raise ValueError("需要 100 个数据字，收到 %d" % len(dwords))
    acc = 0
    for word, v in zip(DATA_WORDS, dwords):
        b = 0
        while v:
            if v & 1:
                acc ^= ecc_col(word, b)
            v >>= 1
            b += 1
    return acc & 0x1FFF


def words_of_frame(frame_bytes):
    """404 B（大端）→ 101 个 32 位字。"""
    if len(frame_bytes) != FRAME_WORDS * 4:
        raise ValueError("帧长度应为 404 B，收到 %d" % len(frame_bytes))
    return [int.from_bytes(frame_bytes[i * 4:i * 4 + 4], "big") for i in range(FRAME_WORDS)]


def frame_from_words(words):
    return b"".join(w.to_bytes(4, "big") for w in words)


def patch_bit(frame_bytes, word, bit, recompute=True):
    """翻转一位，返回新帧字节串；recompute=True 时同步重算 word50。"""
    words = words_of_frame(frame_bytes)
    words[word] ^= 1 << bit
    if recompute:
        data = words[:ECC_WORD] + words[ECC_WORD + 1:]
        words[ECC_WORD] = frame_ecc(data)
    return frame_from_words(words)


def verify_frame(frame_bytes):
    """返回 (ok, 期望值, 实际值)。"""
    words = words_of_frame(frame_bytes)
    data = words[:ECC_WORD] + words[ECC_WORD + 1:]
    exp = frame_ecc(data)
    return exp == words[ECC_WORD], exp, words[ECC_WORD]


if __name__ == "__main__":
    print("F 表 %d 项，缺 %d 项（parity 另一槽）" % (len(F_TABLE), len(MISSING_WORDS)))
    # 自检：E3 的 e3_a —— INIT 0x5 落在 frame 31786 的 word40 bit15/14
    print("col(40,15)=0x%04X col(40,14)=0x%04X xor=0x%04X（E3 实测 0x1001）"
          % (ecc_col(40, 15), ecc_col(40, 14), ecc_col(40, 15) ^ ecc_col(40, 14)))
    print("col(8,15)=0x%04X（E7 实测 0x144F）" % ecc_col(8, 15))
