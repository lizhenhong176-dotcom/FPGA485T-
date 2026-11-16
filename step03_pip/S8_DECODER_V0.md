# S8：bit→netlist 解码器 v0 — 单 slice 闭环成功

日期: 2026-10-28
输入: 一个真实 .bit（`/opt/lzh/step03/s8/s8_v0.bit`，LUT6 INIT=0x9E3779B97F4A7C15 + FDRE @ SLICE_X8Y11/CLBLL_L_X6Y11）
解码器: `step03_pip/decode_slice_v0.py`（纯本地，无 Vivado 参与）
闭环真值: `s8_truth.json`（Vivado 自身导出的 INIT / 引脚网 / FF 配置）

## 结果 —— 三层全部命中

1. **LUT INIT 字段解码 38/38**：
   CLBLL_L_X0 A6LUT INIT 布局（本地 `segbits_clbll_l.db`，off 为字段相对= B+32）：
   [0-7]→off0/1 bit15-12、[8-15]→off3/2 bit15-12（注意 2/3 帧序对调）…同 artix7 交错规律。
   实测物理 INIT = 0x937b7471e799fac5（popcount 38 ✓）。
2. **pin-swap 置换恢复（唯一解）**：720 置换搜索恰 1 个解：
   `A6←I3, A5←I0, A4←I1, A3←I2, A2←I4, A1←I5`
   → 重排后 INIT == 0x9E3779B97F4A7C15 **与 ground truth 完全一致**。
3. **FF 解码全中**：AFFMUX.O6=(30,3)=1、ZRST=(30,12)=1、ZINI=(31,3)=1
   = FDRE INIT=0 的精确预测图案（**CLBLL_L/SLICEL_X0 首次实测验证**）。
4. **IMUX pin map 6/6 解析**：A1→IMUX_L7=SW2END3、A2→L2=WW2END0、
   A3→L1=NE2END0、A4→L11=NE2END1、A5→L8=GFAN0、A6→L4=NW2END2。
   （全部是 IO 方向局部线，与 6 个输入来自 IOB 的设计一致。）

## 已知限制（v1 待办）

- **IMUX 源消歧**：A3/A4/A6 三个 mux 有 2-3 个候选源匹配（不同 mux 共用位池，
  非选择源的差分位可被其它 mux 置位）。v0 取第一个非默认匹配；正确解法是
  24-mux 联合约束求解（选中源的位并集 == 观测位集）。
- pin-swap 置换的恢复目前靠 720 搜索 + 已知 ground truth；v1 需从 IMUX 源↔网表
  连线（INT 路由走线）确定每个 pin 承载的逻辑输入，不依赖搜索。
- 固定 LUT6 端口↔物理引脚规范映射（canonical map）需一次 LOCK_PINS 实验测定，
  用于把物理 INIT 规范化输出为 Verilog LUT6 INIT。
- 输出网表目前为 JSON 描述（BEL/INIT/pin 线/FF）；Verilog 化是 v1。

## 复现

```
远端: /opt/lzh/step03/s8/{s8_v0.v,s8_build.tcl,s8_run.sh,s8_dump.py} → s8_v0.bit + s8_truth.json
本地: python step03_pip/decode_slice_v0.py   (需 s8_col.json, tilepipe.json, segbits_clbll_l.db, s8_truth.json)
```

踩坑记录: s8_v0.v 中文注释导致 Vivado 2017.2 Synth 8-2798 unexpected EOF（ASCII 化后正常）；
`output reg o2` 直连 FDRE .Q 触发 Synth 8-685（改 wire）；远端 Vivado 路径
`/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado`（非 /opt/Xilinx）。
