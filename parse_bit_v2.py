#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
parse_bit_v2.py —— Xilinx 7 系列 .bit 解析器（修正版）

相比原版 parse_bit.py：
  1. 修掉 READ 包多跳一个字的 bug（Type1/op=01 没有数据字）；
  2. 记录每一段 FDRI 的起始 FAR，输出 frames.json 索引，便于定位帧；
  3. Type2 包必须紧跟“字数=0 的 FDRI 写包”，否则报错而不是静默吞掉；
  4. 未知包类型直接报错，不静默截断；
  5. 统计出现的寄存器、IDCODE、CRC 写入值，便于判断器件与流结构；
  6. 输出格式仍是“每帧 101 个大端 32 bit 字”，与原版 / prjxray 思路兼容。

注意（必须知道）：
  - 7 系列一帧 = 101 个 32 bit 字；本脚本按此硬编码，不改器件需改 FRAME_WORDS；
  - 每帧末尾含 ECC，改数据后回写必须处理 ECC；
  - 整条流末尾有 CRC，改数据后回写必须重算；
  - 如果 .bit 是用 -compress 生成的，FDRI 里是压缩流，本脚本会切出垃圾帧，
    此时应当先解压（本脚本不做）。判断方法见文档。

用法：
  python parse_bit_v2.py design.bit design.frames [--json design.frames.json]
"""

import argparse
import json
import struct
import sys
from pathlib import Path

SYNC = b"\xAA\x99\x55\x66"

FRAME_WORDS = 101          # 7 系列：101 x 32bit = 3232 bit

REG_NAMES = {
    0x00: "CRC",
    0x01: "FAR",
    0x02: "FDRI",
    0x03: "FDRO",
    0x04: "CMD",
    0x05: "CTL0",
    0x06: "MASK",
    0x07: "STAT",
    0x08: "LOUT",
    0x09: "COR0",
    0x0A: "MFWR",
    0x0B: "CBC",
    0x0C: "IDCODE",
    0x0D: "AXSS",
    0x0E: "COR1",
    0x10: "WBSTAR",
    0x11: "TIMER",
    0x16: "BOOTSTS",
    0x18: "CTL1",
    0x1F: "BSPI",
}

# 只保留确定无争议的几个；其余按十六进制打印，避免误标
CMD_NAMES = {
    0x00: "NULL",
    0x01: "WCFG",
    0x04: "RCRC",
    0x0D: "DESYNC",
    0x0F: "IPROG",
}


class BitError(Exception):
    pass


def parse_words(data: bytes, sync_pos: int):
    """把同步字之后的字节切成 32bit 大端字。"""
    body = data[sync_pos + 4:]
    if len(body) % 4:
        body = body[: len(body) // 4 * 4]

    if not body:
        raise BitError("同步字之后没有数据")

    return struct.unpack(f">{len(body) // 4}I", body)


def parse_packets(words, strict=True):
    """
    解析包流，返回：
      segments : [ {far, words:[...]}, ... ]   每段 FDRI 数据
      info     : 统计信息
    """
    segments = []
    info = {
        "idcode": None,
        "cmd": [],
        "crc_writes": [],
        "reg_hist": {},
        "packets": 0,
        "nop": 0,
    }

    far = 0
    i = 0
    n = len(words)
    pending_type2 = False          # 上一个包是不是“FDRI 且字数=0”

    def need(k, what):
        if i + k > n:
            raise BitError(f"{what} 数据不足：需要 {k} 字，只剩 {n - i} 字")

    while i < n:
        header = words[i]
        i += 1
        info["packets"] += 1

        ptype = (header >> 29) & 0x7
        opcode = (header >> 27) & 0x3
        addr = (header >> 13) & 0x3FFF
        count = header & 0x7FF

        # ---------- Type 2：大块数据，只能跟着“字数=0 的写包” ----------
        if ptype == 2:
            if not pending_type2:
                msg = f"偏移 {i-1}: 出现孤立的 Type2 包（前一个包不是 FDRI 且字数=0）"
                if strict:
                    raise BitError(msg)
                print(f"[warn] {msg}", file=sys.stderr)
            pending_type2 = False
            cnt2 = header & 0x7FFFFFF
            need(cnt2, "Type2")
            segments.append({"far": far, "words": list(words[i:i + cnt2])})
            i += cnt2
            continue

        if ptype != 1:
            raise BitError(f"偏移 {i-1}: 未知包类型 {ptype}（header=0x{header:08X}）")

        # ---------- Type 1 ----------
        if opcode == 0:                        # NOP：只有包头
            info["nop"] += 1
            pending_type2 = False
            continue
        if opcode == 1:                        # READ：只有包头，没有数据字
            pending_type2 = False
            continue
        if opcode == 3:
            raise BitError(f"偏移 {i-1}: 保留的 opcode=3")

        # opcode == 2：WRITE，后面跟 count 个数据字
        pending_type2 = False
        need(count, f"寄存器 0x{addr:02X} 写")
        payload = words[i:i + count]
        i += count

        info["reg_hist"][addr] = info["reg_hist"].get(addr, 0) + 1

        if addr == 0x01:                       # FAR
            if count == 0:
                continue
            far = payload[-1]
        elif addr == 0x02:                     # FDRI
            if count == 0:
                pending_type2 = True           # 后面应当跟 Type2
            else:
                segments.append({"far": far, "words": list(payload)})
        elif addr == 0x04:                     # CMD
            for w in payload:
                info["cmd"].append(w)
        elif addr == 0x0C:                     # IDCODE
            if count:
                info["idcode"] = payload[0]
        elif addr == 0x00:                     # CRC
            if count:
                info["crc_writes"].append(payload[0])
        # 其它寄存器：只统计，不处理

    if pending_type2:
        raise BitError("流在 FDRI 写包之后结束，缺少 Type2 数据包")

    return segments, info


def build_frames(segments):
    """按 101 字切帧；返回 (frames, per_segment_stats)。"""
    frames = []
    stats = []
    for seg in segments:
        ws = seg["words"]
        n_frames = len(ws) // FRAME_WORDS
        for k in range(n_frames):
            frames.append(ws[k * FRAME_WORDS:(k + 1) * FRAME_WORDS])
        stats.append({
            "far": f"0x{seg['far']:08X}",
            "words": len(ws),
            "frames": n_frames,
            "leftover_words": len(ws) % FRAME_WORDS,
        })
    return frames, stats


def main():
    ap = argparse.ArgumentParser(description="Xilinx 7 系列 .bit 解析器（切帧）")
    ap.add_argument("bit", help="输入 .bit 文件")
    ap.add_argument("out", help="输出 .frames 文件")
    ap.add_argument("--json", dest="json_out", help="输出帧索引 json")
    ap.add_argument("--no-strict", action="store_true", help="遇到异常包只告警不退出")
    args = ap.parse_args()

    bit_path = Path(args.bit)
    if not bit_path.is_file():
        sys.exit(f"找不到文件：{bit_path}")

    data = bit_path.read_bytes()
    pos = data.find(SYNC)
    if pos < 0:
        sys.exit("错误：没找到同步字 AA995566，可能不是 .bit 或已加密")

    words = parse_words(data, pos)
    segments, info = parse_packets(words, strict=not args.no_strict)
    frames, seg_stats = build_frames(segments)

    if not frames:
        sys.exit("错误：没有解析到任何 FDRI 帧数据（是否开了 -compress，或不是 7 系列）")

    out_path = Path(args.out)
    with out_path.open("wb") as f:
        for fr in frames:
            f.write(struct.pack(f">{FRAME_WORDS}I", *fr))

    total_words = sum(len(s["words"]) for s in segments)
    leftover = sum(s["leftover_words"] for s in seg_stats)

    print(f"{bit_path.name}: {len(frames)} frames, "
          f"{total_words} words, leftover={leftover}")
    print(f"  同步字偏移 : 0x{pos:X}")
    print(f"  包数       : {info['packets']}（NOP {info['nop']}）")
    if info["idcode"] is not None:
        print(f"  IDCODE     : 0x{info['idcode']:08X}")
    if info["crc_writes"]:
        print("  CRC 写入   : " + ", ".join(f"0x{c:08X}" for c in info["crc_writes"]))
    if info["cmd"]:
        names = [f"{CMD_NAMES.get(c, '?')}(0x{c:02X})" for c in info["cmd"]]
        print("  CMD        : " + ", ".join(names))
    print("  寄存器命中 : " + ", ".join(
        f"{REG_NAMES.get(a, hex(a))}x{c}" for a, c in sorted(info["reg_hist"].items())))

    for s in seg_stats:
        print(f"  FDRI 段    : FAR={s['far']} words={s['words']} "
              f"frames={s['frames']} leftover={s['leftover_words']}")

    if leftover:
        print(f"[warn] 有 {leftover} 个字不构成整帧：可能压缩、或有的段被截断",
              file=sys.stderr)
    if len(seg_stats) > 1:
        print(f"[note] 共 {len(seg_stats)} 段 FDRI：段之间 FAR 不连续，"
              f"按段切帧而不是简单拼接", file=sys.stderr)

    # 实验性提示：本脚本不重算 ECC / CRC
    print("[note] 本脚本只读不写：回写需重算帧尾 ECC 与整条流 CRC", file=sys.stderr)

    if args.json_out:
        doc = {
            "bit": bit_path.name,
            "idcode": None if info["idcode"] is None else f"0x{info['idcode']:08X}",
            "frame_words": FRAME_WORDS,
            "total_frames": len(frames),
            "total_words": total_words,
            "leftover_words": leftover,
            "segments": seg_stats,
            "registers": {REG_NAMES.get(a, f"0x{a:02X}"): c
                          for a, c in sorted(info["reg_hist"].items())},
        }
        Path(args.json_out).write_text(
            json.dumps(doc, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"  索引已写入 : {args.json_out}")


if __name__ == "__main__":
    main()
