# -*- coding: utf-8 -*-
"""在 STATUS 的 154 列那一节末尾追加「154 列口径下的类实验 + 检测器 bug」。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
s = io.open(P, encoding="utf-8").read()
anchor = "\n---\n\n" if False else None
key = "### 六、待办"
assert key in s, "anchor missing"
add = """### 六、154 列口径下重跑的四类篡改（2026-11-08）

| 篡改类 | `ref.bit`（982 tile） |
|---|---|
| 单 bit 穷举 | 1,633,808 次翻转，**99.4438%** 检出（off·mux 100%、off·other 100%、on·mux 99.9589%、on·other 99.1195%） |
| 幽灵 mux（空槽位写合法 2 位） | **0/300** 检出（解码器照单全收，报出从未布线的 PIP） |
| 换源（2–4 bit） | **18/300 = 6.0%**；有共享格 17/112 = 15.2%、无共享 1/188 = **0.5%** |
| 整条已布线 PIP 删除 | **8/300 = 2.67%**（全是共享格附带损伤） |
| 空槽位加整条合法 PIP | **0/300 = 0%** |
| word 50（ECC 字）单 bit | **0/300 = 0%** |
| Vivado 真实 LUT 功能篡改 | 1,092 bit 差异、建模区 **0**、解码 PIP 两边都是 1,886、active tile 两边都是 982、L1/L2 都是 240/0 |

- 真实设计的误报（`--fpstats`）：982 active tile 里 120 个报警（**12.22%**）、240 个未解释位
  （每个报警 tile 恰好 `(fo=1,bit=0)` 与 `(fo=1,bit=1)` 两格）、建模位误报 **146.9 ppm**、
  占建模 setbit 7.34%；白名单后告警 tile 0、未解释位 0。
- **顺带修掉一个检测器 bug（重要）**：`attack_fake_mux` 与 `attack_swap` 原用
  `if un or viol` 判检出，**没有减基线**，于是「该 tile 本来就有两个未解释标记位」被误算成检出
  → 幽灵 mux 在 154 列口径下一度报 300/300 = 100%。改为与基线签名 `_tile_signature()` 比较后
  回到 **0/300**；换源从 18 次里剔除误报后仍是 18 次（这两个函数之外的 `--classes` 一直用
  `_detect()`，未受影响）。两次运行同时留在盘上：`tamper/atk_ref300_154col.json`（未减基线，
  **不要引用**）、`tamper/atk_ref300_154col_fixed.json`（修正版）。
- 已同步更新 `paper/TAMPER_LOCALIZER.md`（全文表按 154 列口径刷新 + 文末修订记录）与
  `tamper/README.md`（JSON 与报告小节的对照表）。

### 七、待办"""
s = s.replace(key, add, 1)
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
print("sections:", len(nums), "max:", max(nums), "dup:", len(nums) - len(set(nums)),
      "| lines:", s.count("\n") + 1, "| bad:", s.count("\ufffd"))
