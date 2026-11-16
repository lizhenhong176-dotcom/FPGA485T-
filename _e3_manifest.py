# -*- coding: utf-8 -*-
"""生成 E3 的 manifest（schema 见 .agents/skills/fpga-bitstream-experiment/reference/manifest.schema.json）。"""
import json
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
PART = "xc7vx485tffg1157-3"
LOCK = {"I0": "A1", "I1": "A2", "I2": "A3", "I3": "A4", "I4": "A5", "I5": "A6"}


def rb(init):
    return {"part": PART, "site": "SLICE_X12Y20", "bel": "SLICEM.A6LUT",
            "init": init, "lock": "I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6"}


def b(bid, role, init, note):
    return {"build_id": bid, "role": role, "part": PART, "site": "SLICE_X12Y20",
            "bel": "A6LUT", "lock_pins": dict(LOCK), "init": init, "rb": rb(init),
            "note": note}


builds = [
    b("e3_base", "baseline", "0x0", "INIT 全零"),
    b("e3_a2", "negative_control", "0x5", "与 e3_a 同参数重跑，差分必须为 0"),
    b("e3_a", "variant", "0x5", "同帧 2 位 word40 w15,w14"),
    b("e3_b", "variant", "0x55", "同帧 4 位 w15..w12"),
    b("e3_c", "variant", "0x3", "跨帧控制 31786:w15 + 31787:w15"),
    b("e3_d", "variant", "0x14", "同帧 2 位 w14,w13"),
    b("e3_e", "variant", "0x55_0055_0055_0055", "同帧整 16 位 w15..w0"),
]

man = {
    "experiment_id": "E3_ECC_LINEARITY",
    "date": "2026-11-11",
    "env": {"host": "fpga (WSL Ubuntu, Vivado 2017.2)", "vivado": "2017.2"},
    "part_declared": PART,
    "diff_semantics": "PURE",
    "builds": builds,
    "self_check": {
        "predicted_n": 4,
        "actual_n": 4,
        "missing": 0,
        "extra": 0,
        "negative_control_diff_frames": 0,
        "content_bits": 26,
        "ecc_bits": 4,
        "unexplained_frames": 0,
        "unexplained_bits": 0,
        "unexplained_ranges": [],
    },
    "cross_check": {
        "batch": "E1E2_c_corpus(_crc) 单比特表 c(w)",
        "script": "v7re/scripts/_e1e2_final.py 得到的 c(w) 作为 XOR 预测输入；只计 4 个判别性图案（控制项不计入）",
        "builds": 4,
        "agree": 4,
        "disagree": [],
    },
    "conclusion_level": "verified",
    "notes": (
        "4 个判别性图案（e3_a/b/d/e）观测 word50 与 c(w) 按位异或全部一致，与算术求和全部不符；"
        "e3_c 跨帧控制两帧各自独立。结论：word50 = XOR of 13-bit columns of set positions，"
        "仿射常数为 0。负对照 e3_base 与上批 crcgen/c_base 逐字差 0。"
        "更正 STATUS.md §147『word50 非线性』。"
    ),
    "parts_allowed": [PART],
}

out = os.path.join(ROOT, "v7re", "steps", "e3_manifest.json")
open(out, "w", encoding="utf-8", newline="\n").write(
    json.dumps(man, ensure_ascii=False, indent=1))
print("wrote", out)
