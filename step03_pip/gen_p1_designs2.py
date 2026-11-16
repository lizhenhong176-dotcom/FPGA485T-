#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""P1 补强第二轮：修 d8 + 新增 4 个设计（合计 12 个）。

新增设计刻意拉开的维度：
  d8b_dense   96 个 LUT6 密集在同一 clock region（链式，不成环）
  d9_wide     32 个 LUT6，每个都用满 6 个不同输入（IMUX 用量最大）
  d10_long    16 个 LUT 横跨很远列（X10→X200），强制长线（LH/LV 族）
  d11_mix     24 LUT + 16 SRL16E 混用（不同资源类型）
  d12_fanout2 2 个源各驱动 48 个 LUT（超高扇出）

所有 LOC 都取自第一轮**已成功布局布线**的设计（不引入新站点猜测）。
"""
from __future__ import annotations

import io
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "tamper" / "ref" / "p1"
PART = "xc7vx485tffg1761-2"

HEADER = """// P1 补强第二轮：{name} -- {desc}
`timescale 1ns/1ps
module top(input wire clk, input wire [7:0] din, output wire [7:0] dout);
"""

PINS = ["C20", "D20", "E20", "F20", "G20", "H20", "J20", "K20",
        "L20", "M20", "N20", "P20", "R20", "T20", "U20", "V20"]


def harvest():
    """从第一轮 xdc 收集合法 SLICE 站点，展开成互不重复的 (site, BEL) 池。"""
    sites = []
    for f in sorted(OUT.glob("d*_*.xdc")):
        for m in re.finditer(r"LOC (SLICE_X\d+Y\d+)", io.open(f, encoding="utf-8").read()):
            if m.group(1) not in sites:
                sites.append(m.group(1))
    pool = []
    for bel in ("A6LUT", "B6LUT", "C6LUT", "D6LUT"):
        for st in sites:
            pool.append((st, bel))
    return pool


def write(name, desc, body, ios):
    v = HEADER.format(name=name, desc=desc) + body + "endmodule\n"
    io.open(OUT / f"{name}.v", "w", encoding="utf-8", newline="\n").write(v)
    xdc = ["set_property PACKAGE_PIN E19 [get_ports clk]",
           "set_property IOSTANDARD LVCMOS15 [get_ports clk]"]
    for i, p in enumerate(PINS):
        xdc.append("set_property PACKAGE_PIN %s [get_ports {din[%d]}]" % (p, i))
        xdc.append("set_property IOSTANDARD LVCMOS15 [get_ports {din[%d]}]" % i)
    xdc.append("set_property PACKAGE_PIN AK19 [get_ports {dout[0]}]")
    xdc.append("set_property IOSTANDARD LVCMOS15 [get_ports {dout[0]}]")
    for i in range(1, 8):
        xdc.append("set_property PACKAGE_PIN %s [get_ports {dout[%d]}]" % (PINS[i + 6], i))
        xdc.append("set_property IOSTANDARD LVCMOS15 [get_ports {dout[%d]}]" % i)
    for c, l in ios:
        xdc.append("set_property LOC %s [get_cells %s]" % (l, c))
    io.open(OUT / f"{name}.xdc", "w", encoding="utf-8", newline="\n").write("\n".join(xdc) + "\n")
    tcl = ["set part " + PART,
           "catch {close_project} ; catch {remove_files [get_files]}",
           "read_verilog %s.v" % name,
           "read_xdc %s.xdc" % name,
           "synth_design -top top -part %s -flatten_hierarchy none" % PART,
           "opt_design", "place_design", "route_design",
           "set_property SEVERITY {Warning} [get_drc_checks NSTD-1]",
           "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]",
           "set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]",
           "set_property CFGBVS VCCO [current_design]",
           "set_property CONFIG_VOLTAGE 3.3 [current_design]",
           "write_bitstream -force out/%s.bit" % name,
           "set fp [open out/%s.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] \"\\n\"]; close $fp" % name,
           "puts \"BUILD_OK %s\"" % name]
    io.open(OUT / f"build_{name}.tcl", "w", encoding="utf-8", newline="\n").write("\n".join(tcl) + "\n")
    print("wrote", name, "ios", len(ios))


def d8b(locs):
    """96 个 LUT6 密集：链式 t[i] = f(t[i-1], din[i%8])，不成环。"""
    body, ios, init = ["  wire [95:0] n;"], [], []
    for i in range(96):
        x, bel = locs[i]
        v = (0x9E3779B97F4A7C15 ^ (i * 0x2545F4914F6CDD1D)) & ((1 << 64) - 1)
        prev = "n[%d]" % (i - 1) if i else "din[7]"
        body.append("  LUT6 #(.INIT(64'h%016X)) u%d (.O(n[%d]), .I0(din[%d]), .I1(%s), "
                    ".I2(din[%d]), .I3(1'b1), .I4(clk), .I5(din[%d]));"
                    % (v, i, i, i % 8, prev, (i + 3) % 8, (i + 5) % 8))
        ios.append(("u%d" % i, "%s/%s" % (x, "A6LUT")))
    body.append("  assign dout[0] = n[95];")
    body.append("  assign dout[7:1] = 7'b0;")
    write("d8b_dense", "96 LUT6 密集单 region（链式）", "\n".join(body) + "\n", ios)


def d9(locs):
    """32 个 LUT6，每个用满 6 个不同输入（IMUX 用量最大）。"""
    body, ios = ["  wire [31:0] n;"], []
    for i in range(32):
        x, bel = locs[(i * 7) % len(locs)]
        v = (0xD1B54A32D192ED03 ^ (i * 0x9E3779B97F4A7C15)) & ((1 << 64) - 1)
        ins = [(i + k) % 8 for k in range(6)]
        body.append("  LUT6 #(.INIT(64'h%016X)) u%d (.O(n[%d]), .I0(din[%d]), .I1(din[%d]), "
                    ".I2(din[%d]), .I3(din[%d]), .I4(din[%d]), .I5(din[%d]));"
                    % ((v, i, i) + tuple(ins)))
        ios.append(("u%d" % i, "%s/%s" % (x, bel)))
    body.append("  assign dout[0] = n[0];")
    body.append("  assign dout[1] = n[7];")
    body.append("  assign dout[2] = n[13];")
    body.append("  assign dout[3] = n[19];")
    body.append("  assign dout[4] = n[25];")
    body.append("  assign dout[5] = n[29];")
    body.append("  assign dout[6] = n[30];")
    body.append("  assign dout[7] = n[31];")
    write("d9_wide", "32 LUT6 全 6 输入", "\n".join(body) + "\n", ios)


def d10(locs):
    """16 个 LUT 横跨很远列（强制长线）。"""
    ordered = sorted(locs, key=lambda t: (int(re.search(r"X(\d+)", t[0]).group(1)),
                                          int(re.search(r"Y(\d+)", t[0]).group(1)),
                                          t[1]))
    n = len(ordered)
    far = [ordered[(k * (n - 1)) // 15] for k in range(16)]
    body, ios = ["  wire [15:0] n;"], []
    for i in range(16):
        x, bel = far[i]
        v = (0xAC4C1B546AD303E5 ^ (i * 0x1111111111111111)) & ((1 << 64) - 1)
        prev = "n[%d]" % (i - 1) if i else "din[0]"
        body.append("  LUT6 #(.INIT(64'h%016X)) u%d (.O(n[%d]), .I0(%s), .I1(din[%d]), "
                    ".I2(1'b1), .I3(1'b0), .I4(clk), .I5(din[%d]));"
                    % (v, i, i, prev, i % 8, (i + 2) % 8))
        ios.append(("u%d" % i, "%s/%s" % (x, bel)))
    body.append("  assign dout[0] = n[15];")
    body.append("  assign dout[7:1] = 7'b0;")
    write("d10_long", "16 LUT 横跨极远列（长线）", "\n".join(body) + "\n", ios)


def d11(locs):
    """24 LUT + 16 SRL16E 混用。"""
    body, ios = ["  wire [23:0] n;", "  wire [15:0] s;"], []
    for i in range(24):
        x, bel = locs[(i * 11) % len(locs)]
        v = (0x452821E638D01377 ^ (i * 0x0101010101010101)) & ((1 << 64) - 1)
        prev = "n[%d]" % (i - 1) if i else "din[1]"
        body.append("  LUT6 #(.INIT(64'h%016X)) u%d (.O(n[%d]), .I0(%s), .I1(din[%d]), "
                    ".I2(clk), .I3(1'b1), .I4(1'b0), .I5(din[%d]));"
                    % (v, i, i, prev, i % 8, (i + 4) % 8))
        ios.append(("u%d" % i, "%s/%s" % (x, bel)))
    for j in range(16):
        x, bel = locs[(j * 13 + 5) % len(locs)]
        body.append("  SRL16E #(.INIT(16'h%04X)) s%d (.Q(s[%d]), .A0(1'b1), .A1(1'b0), "
                    ".A2(1'b1), .A3(1'b0), .CE(1'b1), .CLK(clk), .D(din[%d]));"
                    % (((0xA5A5 ^ (j * 0x1111)) & 0xFFFF), j, j, j % 8))
        ios.append(("s%d" % j, "%s/%s" % (x, bel)))
    body.append("  assign dout[0] = n[23];")
    body.append("  assign dout[1] = s[15];")
    body.append("  assign dout[7:2] = 6'b0;")
    write("d11_mix", "24 LUT6 + 16 SRL16E 混用", "\n".join(body) + "\n", ios)


def d12(locs):
    """2 个源各驱动 48 个 LUT（超高扇出）。"""
    body, ios = ["  wire [95:0] n;"], []
    for i in range(96):
        x, bel = locs[(i * 5) % len(locs)]
        v = (0x8CB92BA72F3D8DD7 ^ (i * 0x2545F4914F6CDD1D)) & ((1 << 64) - 1)
        src = "din[0]" if i % 2 == 0 else "din[1]"
        body.append("  LUT6 #(.INIT(64'h%016X)) u%d (.O(n[%d]), .I0(%s), .I1(din[7]), "
                    ".I2(clk), .I3(1'b0), .I4(1'b1), .I5(din[3]));"
                    % (v, i, i, src))
        ios.append(("u%d" % i, "%s/%s" % (x, bel)))
    body.append("  assign dout[0] = n[95];")
    body.append("  assign dout[1] = n[0];")
    body.append("  assign dout[7:2] = 6'b0;")
    write("d12_fanout2", "2 源各驱动 48 LUT", "\n".join(body) + "\n", ios)


def main():
    locs = harvest()
    print("harvested slots", len(locs), "unique", len(set(locs)))
    if len(set(locs)) < 96:
        raise SystemExit("pool too small: %d" % len(set(locs)))
    d8b(locs)
    d9(locs)
    d10(locs)
    d11(locs)
    d12(locs)
    names = ["d8b_dense", "d9_wide", "d10_long", "d11_mix", "d12_fanout2"]
    sh = ["#!/bin/bash", "cd /opt/lzh/v7re/work/p1",
          "export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2",
          "export PATH=$XILINX_VIVADO/bin:$PATH",
          "export LANG=C.UTF-8", "export LC_ALL=C.UTF-8", "unset LANGUAGE", "mkdir -p out"]
    for n in names:
        sh.append("echo === %s" % n)
        sh.append("vivado -mode batch -notrace -source build_%s.tcl -log ../p1_%s.log" % (n, n))
        sh.append("echo RC=%s $?" % n)
    io.open(OUT / "run_new.sh", "w", encoding="utf-8", newline="\n").write("\n".join(sh) + "\n")
    print("wrote run_new.sh for", len(names), "designs")


if __name__ == "__main__":
    main()
