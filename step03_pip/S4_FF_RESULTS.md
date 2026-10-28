# S4-FF — AFFMUX site mux 验证（o5/o6 定论，F7 未驯服）

日期：2026-10-28。方法：4 个 FF 设计（`ff_*.v`），FDRE LOC 到 SLICE_X10Y20/AFF（DONT_TOUCH），
D 从不同源进：ax=顶层端口直连、o5=LUT6_2 O5、o6=LUT6 O6、f7=MUXF7。
每个独立 synth→place→route→bitgen（`ff_build.tcl`，需压掉 NSTD-1/UCIO-1 DRC）。
位流与解码 JSON 在 `step03_pip/s4bits/`。

## 结果

### AFFMUX 布局验证成功（o5/o6）
AFFMUX 表（CLBM_R SLICEM_X0，来自 artix7）：frame_off=30，word=word_of(Y,parity=0)，bits 0-3 四位编码。
实测（SLICE_X10Y20 = CLBM_R_X7 inst0，块基址 31716）：

| 对比 | 变化位 (f=31746, w=40) | 语义 |
|---|---|---|
| ax→o5 | b0 (+), b1 (−), b3 (+) | AX(0100) → O5(1001) ✓ 与表完全一致 |
| ax→o6 | b1 (−), b3 (+) | AX(0100) → O6(0001) ✓ |

**word 公式 parity=0 项对 FF mux 同样成立**；frame_off 30 落在块内 INIT 窗口(32-35)之前，同一 36 帧块。

### 附带验证：LUT INIT 的 2×2 布局再确认
o5/o6 的 ALUT.INIT 变化位全部落在 f=31748-31751 (块内 32-35)、w=40、bits 15..0——
与 decode_clb.py 预测逐位一致（LUT6_2 的 O5=INIT 低 32 位、O6 INIT 位序由 Vivado 交换，见两者 k 序差异）。

### f7 变体：Vivado 不肯走 F7→AFF 直连
- `BEL F7MUX` 在 SLICE 站点里**不存在该名字**（CRITICAL WARNING 12-610），约束失效后布线器自由放置：
  LUT 落 CLUT/DLUT（w=41 的 INIT 变化证实），MUXF7 输出经 **COUTMUX（w41 b8/b11，F7 源）** 出片，
  FF 的 D 仍从 **AX** 进入（AFFMUX 无 w40 变化）——即"出片再回环"，没有用 AFFMUX.F7 源。
- 结论：AFFMUX 的 F7/CY/XOR 三个源**没有拿到实测点**，仍是 artix7 表的迁移值
  （同表同布局已被 o5/o6 + INIT 全面对证，置信度高，但不是实测）。

## 遗留
- 想实测 F7 源需找到 2017.2 里 MUXF7 的合法 BEL 名（或用 LUT6_2 隐式产生 F7 结构）；
  CY/XOR 源需要 CARRY4 设计。优先级低——布局模型本身已闭环。

## 文件
`ff_ax/o5/o6/f7/f7b.v + .xdc + ff_build.tcl + ff_run.sh`（远端 /opt/lzh/step03/s4ff 同名）。
