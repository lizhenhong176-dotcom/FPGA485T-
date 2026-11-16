# S9 CSP 联合消歧 — 48 IMUX 唯一解码 + Vivado ROUTE 外部真值闭环

日期: 2026-10-30。前置: S8 decoder v0（IMUX 6/6 但 A3/A4/A6 各 2-3 候选歧义）。

## 方法

`csp_imux.py`（纯本地，毫秒级）：
- 变量: 48 mux（X8Y11+X9Y11 两 slice 全部 LUT 引脚），域 ~25 源/ mux；
- C1 合法性: 选中源位集 ⊆ 观测位池 O（帧 off16-25 × word 22/23）→ 一次性预过滤；
- C2 完备性: O 中每个位须被至少一个选中源覆盖（单位传播: 仅一个未定 mux 可覆盖的位强制该 mux）；
- MRV 回溯，解数上限 10。
- **关键修正**: §5.6 的 4 个 w23 常数位 {(31696,23,0),(31702,23,0),(31704,23,0),(31705,23,0)}
  属基线恒置位（位表已剔除），观测端同样必须剔除——首跑 0 解即因它；剔除后 1 解。

## 结果

**唯一解**（6 个实际使用的 mux，其余 42 个全默认 VCC_WIRE）：

| pin | mux | CSP 唯一解 | v0 朴素首选(错误) | Vivado ROUTE 真值 |
|---|---|---|---|---|
| A1 | IMUX_L7 | SW2END3 | SW2END3 ✓ | SW2BEG3→SW2END3 ✓ |
| A2 | IMUX_L2 | WW2END0 | WW2END0 ✓ | WW2BEG0→WW2END0 ✓ |
| A3 | IMUX_L1 | **WL1END0** | NE2END0 ✗ | WL1BEG0→**WL1END0** ✓ |
| A4 | IMUX_L11 | **SR1END1** | NE2END1 ✗ | SR1BEG1→**SR1END1** ✓ |
| A5 | IMUX_L8 | GFAN0 | GFAN0 ✓ | GFAN0 ✓ |
| A6 | IMUX_L4 | **WL1END1** | NW2END2 ✗ | WL1BEG1→**WL1END1** ✓ |

**6/6 与 Vivado ROUTE 完全一致；v0 在全部三个歧义针上原本是错的。**
ROUTE 真值导出: 远端 `s8_route.tcl`（write_checkpoint + 逐引脚 ROUTE 属性 → route_I*.txt，
本地 step03_pip）。注意 2017.2 用 `write_checkpoint` 而非 `write_dcp`；`write_bitstream` 无 `-force` 会中断。

## 附带发现（重要）

1. **INIT 索引 = 标准二进制 A6(MSB)…A1(LSB)，无乱序**。
   早先"artix7 布局乱序"结论是置换搜索脚本 MSB-first 字符串被按 LSB 位序解读所致的
   解读 bug（搜索本身正确）。以路由真值 pin map（A1←I0, A2←I1, A3←I3, A4←I4, A5←I5,
   A6←I2，placer 把 I2/I3 互换）直接换算: 物理 INIT 0x937b7471e799fac5 → 逻辑
   0x9E3779B97F4A7C15，**0/64 mismatch**。
2. M3 锚点的"恒等"其实是其设计的 pin map 恰为恒等（连通性固定）；pin map 因设计而异
   （S7 结论重申），解码端由 IMUX/路由位恢复——本步已闭环验证该路线可行且唯一。
3. route_I*.txt 同时给出 IOB→LIOI→IOI_LOGIC_OUTS→INT→IMUX 全路径，是 v1 INT-walk 的
   第一份真实对照数据。

## 产物

- `csp_imux.py`（求解器）、`s8_csp_solution.json`（唯一解）
- `route_I0..I5.txt`（本地+远端，Vivado ROUTE 真值）
- `decode_slice_v0.py` 已改为调用 CSP（不再朴素首选）
- STATUS.md 条目 12；v7_verified +6 行（s8 CSP/ROUTE 验证记录）

## 下一步 (v1)

INT-walk 网名还原（沿 route 串逆走）→ 多 slice 闭环 → Verilog 输出。
