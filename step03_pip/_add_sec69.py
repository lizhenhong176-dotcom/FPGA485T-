# -*- coding: utf-8 -*-
"""给 STATUS.md 追加 §69：row/band/PIP·mux 概念对照的数量对账。"""
import io

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

SEC = """## 69. row / band / 行带 / PIP 与 mux 的数量对账（2026-11-07）

文档 `step03_pip/ROW_BAND_SWITCHBOX_EXPLAINED.md`；提示词 `step03_pip/PROMPT_ROW_BAND_SWITCHBOX_V1.md` → `_V2.md`。

**【数据事实】一个 INT tile（INT_L，26,550 个实例，`tile_types.uniform = 1`）的构成拆分**：

| 项 | 数量 | 来源 |
|---|---|---|
| wire | 600 | `v7_routing.db.tile_types.wires` |
| PIP | 3,737 | `tile_types.pips` |
| 目的 wire | 216 | `out_routing/templates/INT_L.json` 的 `pip_defs` 按目的归组 |
| 扇入 > 1 的目的 wire（= mux 家族） | 172 | 与 `law_cells` 的 172 个 `family` 一一对应 |
| 172 个 mux 含的 PIP | 3,693 | 模板 |
| 扇入 = 1 的直通 PIP | 44 | `BYP_BOUNCE*/BYP_L*/FAN_BOUNCE*/FAN_L*` 各 1 个 |
| `law_cells` 记录 feature（sense=1） | 3,634 | `law_cells`（两侧各 3,634） |

**全账**：`3,634（law 可解释）+ 59（VCC_WIRE 常量输入，59 个族模板扇入 25 / law 24）+ 44（直通）= 3,737`。
复算：`python step03_pip/_q_pip_reconcile.py`、`python step03_pip/_q_pip_gap59.py`。

**概念定论**（供讲解引用）：PIP = 单个受配置位控制的开关；mux = 共用同一目的 wire 的一组 PIP（组内互斥）；
switch box = tile 内全部 mux + 直通的整张网（INT tile = 3,737 个 PIP）；`band` = 帧地址上连续 5,246 帧的窗口，
与 `bank`（I/O / 配置 / 时钟编组）不是同一概念；`region = Y//50` 才是物理 50 行分区，
两者用 `band_by_region = [6,5,0,1,2,3,4]` 关联（region 0 → band 6，即 band 0 装 `Y=100..149`）。
"""

txt = io.open(STATUS, encoding="utf-8").read()
assert "## 69. row / band" not in txt
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(txt.rstrip() + "\n\n" + SEC)
print("appended; lines:", len(io.open(STATUS, encoding="utf-8").read().splitlines()))
