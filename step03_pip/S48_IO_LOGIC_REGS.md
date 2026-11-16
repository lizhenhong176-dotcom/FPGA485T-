# S48 IO 逻辑寄存器（ILOGIC / OLOGIC）位区实测

日期 2026-11-10。设备 xc7vx485tffg1157-3。设计目录 `E:\v7work\iob3\`（远端 `/opt/lzh/step12/iob3/`）。

## 1. 结论（新的位区边界）

IO pad 的配置字段不是只有 off38/39（属性区），而是 **io72 块内 offsets 0..33，位于该 pad 的行字（wof(Y)/parity 字）上**：

| 变体 | 变化格（剔除 word50）| 主要集中在 |
|---|---|---|
| `ddr_in`（IDDR，ILOGIC DDR 输入）| 236 | **io72 w0/w1 = 34 格**（din, Y50），其余散布 off0..31 |
| `ddr_out`（ODDR，OLOGIC DDR 输出）| 200 | **io72 w16/w17 = 25 格**（o, Y58）+ **clb w14 = 36 格** |

对比：纯属性（PULLTYPE/DRIVE/SLEW/IOSTANDARD）只在 off38/39，1~9 格。

## 2. 与审计空白的关系
`audit2.py` 报的 io72 剩余未知（br_attr 226 / dsp 516）集中在 off28..44 —— 与本节实测的 `ddr_in` 命中的 `off28/29/30/31`（w0/w1）
及 `ddr_out` 的 `off28..33`（w16/w17）**同区**。即：**io72 的剩余未知主要就是 ILOGIC/OLOGIC 配置，而非属性**。

## 3. 失败的探针（记录以免重试）
- `IDELAYE2` 无 `LOAD` 端口（正确的是 `LD`）。
- 只例化 `IDELAYCTRL`（REFCLK 直接来自 IO 引脚）→ `ERROR: [Place 30-574] Poor placement for routing between an IO pin and BUFG`。
- `IDELAYCTRL.REFCLK = BUFG 输出` + 固定 PACKAGE_PIN → `ERROR: [Common 17-69] Placer could not place all instances`。
- `IDELAYE2`（无 IDELAYCTRL，C=IO 时钟）同样 place 失败。
⇒ IDELAY 通路需要“不固定引脚 + 完整 IDELAYCTRL + BUFG”的独立实验环境，本轮未取得位数据（记为未测）。

## 4. 产物
- `E:\v7work\iob3_diff.json`（236 + 200 条 (frame,word,bit) 与 base/new 值）
- 远端 `/opt/lzh/step12/iob3/`：`pass3/ddr_in/ddr_out` 三份 .bit（+ `clkref`）
