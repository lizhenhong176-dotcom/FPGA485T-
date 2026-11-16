# S49 OLOGIC 拆解：3-state / 输出寄存器 / DDR / 时钟网络

日期 2026-11-10。基线 `pass3`（din→o、clk→o2 直通），设计目录 `E:\v7work\iob4\`（远端 `/opt/lzh/step12/iob4/`）。全部为 (frame,word,bit) 差分，剔除 word50 校验字。

## 1. 四个变体的位差

| 变体 | 语义 | 总格 | io72 | edge30 | clb | gap28 |
|---|---|---|---|---|---|---|
| `tbuf` | OBUFT，T=din（只用三态） | 66 | **11** | 0 | 0 | 0 |
| `off1` | FDRE + `IOB TRUE`（FF 打入 OLOGIC） | 560 | 51 | 33 | 22 | 4 |
| `off1_fab` | 同一 FF，`IOB FALSE`（FF 在 fabric） | 646 | 42 | 33 | 40 | 4 |
| `oddr_pipe` | ODDR SAME_EDGE_PIPELINED | 230 | 44 | **0** | 36 | 0 |
| `tbuf_ff` | T 由 FDRE 驱动 + `IOB TRUE` | 550 | 52 | 33 | 22 | 4 |

## 2. 关键结论

**(a) 三态使能字段很小**：`tbuf` 只有 11 格 io72 —— (7,12,0)(8,12,0)(10,12,2)(11,12,2)(12,12,1)(13,12,2)(14,12,1)(15,12,2)(16,17,26)(25,17,26)(30,16,3)。`w12` = clk 所在 pad 的行字，`w16/17` = 输出 pad 行字。

**(b) OLOGIC 相关格 = off1 与 off1_fab 的对称差 37 格**（io72 内），即“FF 进不进 OLOGIC”的差别；其余 33 格 edge30 + 22/40 格 clb 是两者共有 → 与 FF 位置无关。

**(c) 决定性：edge30 的 29 格是时钟网络，不是 IO 逻辑。**
`off1`/`off1_fab`/`tbuf_ff`（clk 驱动 fabric 触发器）三者**共有 29 个完全相同的 edge30 格**：
`(3,45,21) (5,45,20) (17,94,4) (23,94,4) (24,94,4) (25,94,4)` + `(27,24,{1,3,15}) (27,73,{1,3,15}) (27,93,{0,2,3,12,14,15})`（覆盖 4 个不同 base 的 edge30 块）。
而 `oddr_pipe`/`tbuf`（时钟由 IO 直接进 ODDR/仅作数据）**edge30 = 0**。
⇒ 这批位是 **IO 时钟进 fabric 的时钟网络（BUFG/时钟布线）配置**，与 ILOGIC/OLOGIC 无关。上一轮“edge30 有 128 个未知格”因此有了归属解释：每一条被使用的时钟在该区留下固定若干位。

**(d) DDR 与单沿输出寄存器不同**：`oddr_pipe` 无 edge30（不占 fabric 时钟网），但多出 36 格 clb（w14）——与 `ddr_out`（SAME_EDGE）的 36 格 clb w14 一致，属 OLOGIC 的 DDR 模式字段。

## 3. 结论对审计的意义
- io72 的 pad 行字区（off0..33）按功能分成：三态使能（~11 格）、输出寄存器（~37 格）、DDR 模式（含 clb w14 36 格）、电气属性（off38/39，1~9 格）。
- edge30 区（off26..29）= 时钟网络，可用“是否有时钟进 fabric”判定是否应出现，从而在审计中按设计静态推断，不必逐位探测。

## 4. 复现要点
- clk 固定到 AM28 且要驱动 fabric 触发器时，placer 报 `[Place 30-574] Poor placement for routing between an IO pin and BUFG`；需 `set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of_objects [get_ports clk]]`。
- `IDELAYE2` 无 `LOAD` 端口；IDELAY 通路在固定引脚下无法 place（S48 已记录）。
