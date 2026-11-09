# S24 —— IO 入口拓扑补齐后，6 条输入网 token 级全对（bitstream-only）

日期：2026-11-08 深夜 ｜ 目标：S23 结论（IO 数据通路无配置位）落地后，把 S10 的 6 网走线从 5/6 推到 6/6。

## 1 新增图边（S23 实测拓扑，不占配置位）

| 边 | 类型级 tileconn | 位 |
|---|---|---|
| LIOI → IO_INT_INTERFACE_L (dx=+1) | `IOI_LOGIC_OUTS{k}_0 → INT_INTERFACE_LOGIC_OUTS_L_B{k}` k=0..23 | 无（固定连线）|
| 同 tile (0,0) | `_B{k} → _L{k}` | 无 |
| IO_INT_INTERFACE_L → INT_L (+1) | `INT_INTERFACE_LOGIC_OUTS_L{k} → LOGIC_OUTS_L{k}` | 无 |
| IO_INT_INTERFACE_L → INT_R (−1) | `→ LOGIC_OUTS{k}` | 无 |
| LIOB18 → LIOI (+1) | `IOB_PADOUT{0,1} → LIOI_I{0,1}` | 无 |

依据 S23：`get_pips` 在 IO_INT_INTERFACE/LIOB18 上是 24/24、10/10 全单源；LIOI 30 个多源家族全是时钟。即**入口段是固定走线，缺的是拓扑而不是位表**。

## 2 求解器（`s13_solve3.py`）

- 在 `s13_solve2.py` 基础上加入上表 96 条类型级连接（grid 坐标解析具体 tile）。
- 目标仍是「9 条网（6 入 + 3 出）PIP 互斥 + 覆盖最大」；候选枚举：A1 2 / A2 12 / A3 1 / A4 13 / A5 48 / A6 2 / o 7 / o2 2 / o3 4，BEST 占用 **98/181**，1.8 s。

## 3 与 Vivado ROUTE 真值对账（BEG 序列，源→汇）

| 网 | 端口 | 解码 | 真值 | 结论 |
|---|---|---|---|---|
| A1 | i_IBUF[0] | 14 | 14 | EXACT |
| A2 | i_IBUF[1] | 12 | 12 | EXACT |
| A3 | i_IBUF[3] | 11 | 11 | EXACT |
| A4 | i_IBUF[4] | 13 | 13 | EXACT |
| A5 | i_IBUF[5] | 12 | 13 | EXACT(真值含第二条网) |
| A6 | i_IBUF[2] | 13 | 13 | EXACT |

**6/6 全部 token 级一致**。A5 的真值文件尾部多出的 `ER1BEG1 IMUX3 CLBLM_L_A2` 属同 `PACKAGE_PIN` 的第二条网（`route_I5.txt` 内两个 `ROUTE {...}` 块），解码链在其之前已结束于 `GFAN0`。

## 4 完整链条（A5，最典型的纯 SW6 长链）

```
IOB AF24 → IOB_IBUF1 → LIOI_I1 → LIOI_ILOGIC1_D → IOI_ILOGIC1_O → IOI_LOGIC_OUTS18_0
→ INT_INTERFACE_LOGIC_OUTS_L_B18 → INT_INTERFACE_LOGIC_OUTS_L18 → LOGIC_OUTS_L18
→ SW6BEG0 ×11（每跳 +1 行/列） → WW4BEG1 → GFAN0 → IMUX_L8 → CLBLL_LL_A5
```
前 4 段是固定连线（无配置位），`LOGIC_OUTS_L18` 之后才是配置位编码的 routing，正是本项目的位表覆盖区。

## 5 状态更新

- 走线层（INT + IO 入口）**闭环**：6/6 输入网、token 级；3 条输出网（o/o2/o3）在 98/181 覆盖解内，但 IOI/OLOGIC 侧末端仍需同样的拓扑补齐（下一步）。
- 新增拓扑边 96 条应并入 `tileconn` 的本地补丁（目前只存在于 `s13_solve3.py`），建议落成 `step03_pip/tileconn_v7_patch.json` 供 walk/decode 复用。
- 产物：`s13_solve3.py`、`s13_solution3.json`、本报告。