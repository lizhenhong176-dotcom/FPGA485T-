#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""生成 P1 级补强：8 个独立设计的 Verilog + 一个批量构建 tcl。

判据（写在 P1_REPLICATION_PLAN.md 里）：
  - 每个设计独立综合/布局/布线，`get_pips -of_objects [get_nets -hier]` 导出真值
  - 只比对 INT tile（本模型的覆盖范围）
  - 逐设计跑 g2_exact_cover.py，记录 唯一解率 / 精确率 / 召回率 / FN 归因

设计（刻意在"规模/分布/结构"三个维度上拉开）：
  d1_lut_chain   24 级 LUT6 链，跨 3 行带 8 列（与 ref 同型但不同 LOC/INIT）
  d2_lut_big     64 个 LUT6，2 列 × 32 行密集
  d3_carry       16 级 CARRY4 进位链（不同 slice 结构）
  d4_fanout      1 个信号驱动 64 个 LUT（高扇出，IMUX 用量大）
  d5_srl         32 个 SRL16E 移位寄存器（LUT 资源 + 深度布线）
  d6_muxtree     6 层 2:1 mux 树 × 8 组（长链）
  d7_spread      16 个 LUT 分散到 4 个 clock region（长线/跨区）
  d8_dense       一个 clock region 内 96 个 LUT（高局部密度）
"""
from __future__ import annotations

import io
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "tamper" / "ref" / "p1"
OUT.mkdir(parents=True, exist_ok=True)

PART = "xc7vx485tffg1761-2"
HEADER = """// P1 级补强设计：{name}  —— {desc}
`timescale 1ns/1ps
module top(input wire clk, input wire [7:0] din, output wire [7:0] dout);
"""


def loc(x, y, bel="A6LUT"):
    return f"SLICE_X{x}Y{y}/{bel}"


def emit(name, desc, body, ios=()):
    v = HEADER.format(name=name, desc=desc) + body + "endmodule\n"
    (OUT / f"{name}.v").write_text(v, encoding="utf-8")
    xdc = ["set_property PACKAGE_PIN E19 [get_ports clk]",
           "set_property IOSTANDARD LVCMOS15 [get_ports clk]"]
    pins = ["C20", "D20", "E20", "F20", "G20", "H20", "J20", "K20",
            "L20", "M20", "N20", "P20", "R20", "T20", "U20", "V20"]
    for i, p in enumerate(ios[:16]):
        xdc.append(f"set_property PACKAGE_PIN {pins[i]} [get_ports {{{p}}}]")
        xdc.append(f"set_property IOSTANDARD LVCMOS15 [get_ports {{{p}}}]")
    xdc += [f"set_property LOC {l} [get_cells {c}]" for c, l in ios if l]
    (OUT / f"{name}.xdc").write_text("\n".join(xdc) + "\n", encoding="utf-8")
    return name


def d1():
    body, ios = [], []
    for i in range(24):
        x, y = (8 + (i % 8) * 12), (20 + (i // 8) * 50)
        body.append(f"  wire n{i};")
        init = (0x0123456789ABCDEF ^ (i * 0x1111111111111111)) & ((1 << 64) - 1)
        prev = f"n{i-1}" if i else "din[7]"
        body.append(f"  (* DONT_TOUCH = \"true\", INIT = 64'h{init:016X} *) LUT6 #(.INIT(64'h{init:016X})) u{i} (.O(n{i}), .I0(din[{i%8}]), .I1({prev}), .I2(1'b1), .I3(1'b0), .I4(clk), .I5(1'b1));")
        ios.append((f"u{i}", loc(x, y)))
    body.append("  assign dout[0] = n23;")
    body.append("  assign dout[7:1] = 7'b0;")
    return emit("d1_lut_chain", "24 级 LUT6 链（8 列 × 3 行带）", "\n".join(body) + "\n", ios)


def d2():
    body, ios = ["  wire [63:0] n;"], []
    for i in range(64):
        x, y = (30 + (i % 2) * 20), (40 + (i // 2) * 2)
        init = (0xAAAAAAAAAAAAAAAA if i % 2 else 0x5555555555555555)
        body.append(f"  (* DONT_TOUCH = \"true\", INIT = 64'h{init:016X} *) LUT6 #(.INIT(64'h{init:016X})) u{i} (.O(n[{i}]), .I0(din[{i%8}]), .I1(n[{(i+7)%64}]), .I2(n[{(i+13)%64}]), .I3(clk), .I4(1'b0), .I5(1'b1));")
        ios.append((f"u{i}", loc(x, y)))
    body.append("  assign dout = n[7:0];")
    return emit("d2_lut_big", "64 个 LUT6，2 列 × 32 行", "\n".join(body) + "\n", ios)


def d3():
    # 用「32 位级联累加器」触发真实的 CARRY4 进位链（直接实例化 CARRY4 会撞 DRC PDCY-4）
    body = ["  wire [31:0] a0w;", "  assign a0w = {24'b0, din};"]
    ios = []
    for i in range(1, 17):
        x, y = (60 + ((i - 1) % 4) * 10), (60 + ((i - 1) // 4) * 8)
        body.append("  (* DONT_TOUCH = \"true\" *) reg [31:0] a%d;" % i)
        base = "a0w" if i == 1 else ("a%d" % (i - 1))
        body.append("  always @(posedge clk) a%d <= %s + a0w + 32'd%d;" % (i, base, i))
        ios.append(("a%d" % i, "SLICE_X%dY%d" % (x, y)))
    body.append("  wire [31:0] acc1;")
    body.append("  assign acc1 = {24'b0, din};")
    body.append("  assign dout = a16[7:0] ^ a8[7:0];")
    body.append("  initial begin end")
    return emit("d3_carry", "16 级 32 位累加器链（真实 CARRY4 进位链，4 列 × 4 行）", "\n".join(body) + "\n", ios)


def d4():
    body, ios = ["  wire fan;", "  (* DONT_TOUCH = \"true\" *) LUT6 #(.INIT(64'h8000000000000000)) uf (.O(fan), .I0(din[0]), .I1(din[1]), .I2(1'b1), .I3(1'b1), .I4(1'b1), .I5(1'b1));"], [("uf", loc(90, 80))]
    for i in range(64):
        x, y = (90 + (i % 8) * 12), (80 + (i // 8) * 12)
        init = (0xFFFFFFFF00000000 if i % 2 else 0x00000000FFFFFFFF)
        body.append(f"  (* DONT_TOUCH = \"true\", INIT = 64'h{init:016X} *) LUT6 #(.INIT(64'h{init:016X})) u{i} (.O(), .I0(fan), .I1(din[{(i%6)+2}]), .I2(clk), .I3(1'b0), .I4(1'b1), .I5(1'b1));")
        ios.append((f"u{i}", loc(x, y)))
    body.append("  assign dout = 8'b0;")
    return emit("d4_fanout", "1 个信号驱动 64 个 LUT（高扇出）", "\n".join(body) + "\n", ios)


def d5():
    body = ["  wire [31:0] q;"]
    ios = []
    for i in range(32):
        x, y = (120 + (i % 4) * 10), (100 + (i // 4) * 6)
        depth = (i % 4) * 4 + 4
        body.append("  (* DONT_TOUCH = \"true\" *) SRL16E #(.INIT(16'h0001)) s%d (.Q(q[%d]), .A0(1'b1), .A1(1'b%d), .A2(1'b%d), .A3(1'b%d), .CE(1'b1), .CLK(clk), .D(din[%d]));"
                    % (i, i, (depth >> 1) & 1, (depth >> 2) & 1, (depth >> 3) & 1, i % 8))
        ios.append(("s%d" % i, "SLICE_X%dY%d" % (x, y)))
    body.append("  assign dout = q[7:0] ^ q[15:8] ^ q[23:16] ^ q[31:24];")
    return emit("d5_srl", "32 个 SRL16E 移位寄存器（4 列 × 8 行）", "\n".join(body) + "\n", ios)


def d6():
    body, ios = [], []
    for g in range(8):
        prev = f"din[{g}]"
        for lv in range(6):
            x, y = (150 + (g % 4) * 10), (120 + lv * 6)
            name = f"m{g}_{lv}"
            body.append(f"  wire {name};")
            body.append(f"  (* DONT_TOUCH = \"true\", INIT = 64'h{(0xCAFEBABE + g * 0x1111 + lv) & ((1<<64)-1):016X} *) LUT6 #(.INIT(64'h{(0xCAFEBABE + g * 0x1111 + lv) & ((1<<64)-1):016X})) {name}_u (.O({name}), .I0({prev}), .I1(din[{(g+lv)%8}]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));")
            ios.append((f"{name}_u", loc(x, y)))
            prev = name
        body.append(f"  // group {g} tail = {prev}")
    body.append("  assign dout = {m7_5, m6_5, m5_5, m4_5, m3_5, m2_5, m1_5, m0_5};")
    return emit("d6_muxtree", "8 组 × 6 层 2:1 mux 树", "\n".join(body) + "\n", ios)


def d7():
    body = ["  wire [15:0] s;"]
    ios = []
    for i in range(16):
        x, y = (10 + (i % 4) * 40), (30 + (i // 4) * 85)
        init = (0x0123456789ABCDEF ^ (i * 0x0101010101010101)) & ((1 << 64) - 1)
        body.append("  (* DONT_TOUCH = \"true\", INIT = 64'h%016X *) LUT6 #(.INIT(64'h%016X)) u%d (.O(s[%d]), .I0(din[%d]), .I1(din[%d]), .I2(clk), .I3(1'b1), .I4(1'b0), .I5(1'b1));"
                    % (init, init, i, i, i % 8, (i + 3) % 8))
        ios.append(("u%d" % i, loc(x, y)))
    body.append("  assign dout = {s[7:1], s[15]};")
    return emit("d7_spread", "16 个 LUT 分散到 4 个 clock region（跨区/长线）", "\n".join(body) + "\n", ios)


def d8():
    body = ["  wire [95:0] t;"]
    ios = []
    for i in range(96):
        x, y = (200 + (i % 4) * 6), (150 + (i // 4) * 3)
        init = ((0x0123456789ABCDEF * (i + 1)) ^ 0xDEADBEEF) & ((1 << 64) - 1)
        body.append("  (* DONT_TOUCH = \"true\", INIT = 64'h%016X *) LUT6 #(.INIT(64'h%016X)) u%d (.O(t[%d]), .I0(din[%d]), .I1(t[%d]), .I2(t[%d]), .I3(clk), .I4(1'b1), .I5(1'b0));"
                    % (init, init, i, i, i % 8, (i + 1) % 96, (i + 5) % 96))
        ios.append(("u%d" % i, loc(x, y)))
    body.append("  assign dout = t[7:0];")
    return emit("d8_dense", "单 clock region 内 96 个 LUT（4 列 × 24 行）", "\n".join(body) + "\n", ios)


def tcl(names):
    L = [f"set part {PART}"]
    for n in names:
        L += [
            f"puts \"==== BUILD {n}\"",
            "catch {close_project} ; catch {remove_files [get_files]}",
            f"read_verilog {n}.v",
            f"read_xdc {n}.xdc",
            f"synth_design -top top -part {PART} -flatten_hierarchy none",
            "opt_design",
            "place_design",
            "route_design",
            "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]",
            "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]",
            "set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]",
            "set_property CFGBVS VCCO [current_design]",
            "set_property CONFIG_VOLTAGE 3.3 [current_design]",
            f"write_bitstream -force out/{n}.bit",
            f"set fp [open out/{n}.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] \"\\n\"]; close $fp",
            f"puts \"BUILD_OK {n}\"",
        ]
    L.append("puts ALL_DONE")
    return "\n".join(L) + "\n"


if __name__ == "__main__":
    names = [d1(), d2(), d3(), d4(), d5(), d6(), d7(), d8()]
    (OUT / "build_p1.tcl").write_text(tcl(names), encoding="utf-8")
    print("generated:", len(names), "designs ->", OUT)
