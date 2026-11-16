# -*- coding: utf-8 -*-
"""STATUS：给 §3/§4/§5 加过时告示 + 追加 §96 进度总表指针。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
s = io.open(P, encoding="utf-8").read()

banner = (
    "> ⚠ **本节内容截至 2026-10-27，已被 §96「PIP 线进度总表（2026-11-08）」取代**。"
    "真实进度看 §71 / §92 / §94 / §96，以及 `step03_pip/PIP_PROGRESS_20261108.md`。"
    "原文保留作历史，勿据本节判断当前状态。\n"
)
for hdr in ("## 3. 已完成", "## 4. 正在跑 / 最近一轮", "## 5. 待办"):
    i = s.index(hdr)
    if s[i + len(hdr):i + len(hdr) + 4] == "\n\n> ":
        continue
    s = s[:i + len(hdr)] + "\n\n" + banner + s[i + len(hdr):]

n = max(int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)) + 1
body = f"""## {n}. PIP 线进度总表（2026-11-08）

全文：`step03_pip/PIP_PROGRESS_20261108.md`（按 `step03_pip/PROMPT_PIP_PROGRESS_V2.md` 生成，六节结构）。
本节只放索引与最关键的一行结论，细节与复算命令看全文。

### 一句话

INT tile 的位库与复用规律**已收口**（172/172 族、3,634/3,634 feature 精确命中、0 不符）；
**没做完的三件**：ECC 与帧地址耦合未闭合、数据层缺 16,979,200 行、跨 tile 类型除 `BUFGCTRL` 外无实测。

### 索引

| 层 | 关键数字 | 详见 |
|---|---|---|
| 地址 | `far_bands` 1,078 行（7 band × 154 列）；每 band 5,246 帧；50,176 = 36,722 + 13,454 | 全文 §2.1、本节 §77/§78/§85/§87/§90 |
| 位库 | 3,737 = 3,693 多源 + 44 直通；3,634 + 59(VCC) + 44 = 3,737；sense=1 8,900 / sense=0 3,264 | 全文 §2.2、§69/§76/§93 |
| 复用 | 列重 Σw=8,900；7 谱型 172/172；乘积结构 163/172；族内唯一 172/172；子集对 1,632；跨族 3/1,598 | 全文 §2.3、§71/§73/§74/§79 |
| 闭环 | 解码精确 100%/召回 96.0%；FASM 幂等 0 帧改动；从零重建 118 位/13 帧 | 全文 §2.4、§57/§58/§59 |
| 篡改 | 单 bit 99.4438%；整条 PIP 删除 2.67%；空槽添加 / word50 / 幽灵 mux 全 0；LUT 功能篡改 0 检出 | 全文 §2.4、§35、`paper/TAMPER_LOCALIZER.md` |
| 可解性 | 1,066 个 tile **全部唯一解，0 多解** | 全文 §2.4、§94 |
| 跨类型 | 70/115 类型含 PIP，35,126 条 / 16,951 family；A 21.4%、D 44.2%；只有 BUFGCTRL 实测 2 位 | 全文 §2.5、§89/§95 |
| 缺口 | INIT 缺 16,979,200 行、100 个 block、ECC 地址项、A 类位映射、单器件 | 全文 §四 |

### 本轮实测（2026-11-08 复核）

| 项 | 值 |
|---|---|
| `far_bands` | 1,078 行，col 0..153 |
| `law_tiles` | 62,625 |
| `law_cells` INT_L / INT_R | sense=1 8,900、sense=0 3,264、feature 3,634、cell 1,598（两侧相同） |
| `verify_all_pip --normalize` | 两侧均 172/172、3,634/3,634、不符 0、未覆盖 0 |
| `pip_bits` | 3,528（`tilepipe_20261025` 3,504 + `step03_pip_20261024` 24） |
| `site_frames` | 19,819,900（目标 36,799,100） |
| `frame_map` | 50,176（50,148 有 FAR、28 overhead） |

复算：
```
python -c "import sqlite3;c=sqlite3.connect(r'E:\\v7work\\model\\v7_law.sqlite');print(c.execute('select count(*) from far_bands').fetchone())"
python v7re/scripts/verify_all_pip.py --tile-type INT_L --normalize
python step03_pip/_q_pipbits_state.py
```
"""
s = s.rstrip("\n") + "\n\n" + body
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
print("new sec:", n, "| sections:", len(nums), "| max:", max(nums),
      "| dup:", len(nums) - len(set(nums)), "| lines:", s.count("\n") + 1,
      "| bad:", s.count("\ufffd"), "| banners:", s.count("已被 §96"))
