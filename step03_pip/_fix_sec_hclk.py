# -*- coding: utf-8 -*-
"""把 STATUS §114 的槽位字区与 dst 结论就地修正（只改指定字符串，不动编号）。"""
import io

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
t = io.open(P, encoding="utf-8").read()

old1 = "MMCM 组槽位在 `off29` word 27..30、PLL 组在 `off28` word 76..79"
new1 = "MMCM 组槽位在 `off29` word 26..30（长扫 `out/hclk_fields.json` 实测 5 个字带 `0xd800` 半区）、PLL 组在 `off28` word 76..79"

old2 = "### 与 INT 的差异（六维）"
new2 = """### dst 由时钟区域固定（新增实测）

把 BUFH 强约束到同一时钟区域的不同站点（合法站点类型是 `BUFHCE`，MMCM `X0Y6` 区域内为 `BUFHCE_X0Y72..X0Y83`），重建 `BUFHCE_X0Y72 / 73 / 75 / 79 / 81` 五个位流：**`.pips` 的 HCLK PIP 全部是 `MUX_CLK_MMCM0 ->> MUX_CLK_13`，dst 不变**。
【推断】`MUX_CLK_k` 按时钟区域分配（485T 14 个区域 ↔ `MUX_CLK_0..13` 14 个），不是按 BUFH 站点；所以「同源换 dst」需换时钟区域才可能造出，而换区域会同时换列与 tile 类型。

### 与 INT 的差异（六维）"""

assert old1 in t and old2 in t
t = t.replace(old1, new1).replace(old2, new2)
io.open(P, "w", encoding="utf-8").write(t)
print("ok", len(t))
