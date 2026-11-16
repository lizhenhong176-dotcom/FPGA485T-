# -*- coding: utf-8 -*-
"""把 G 系列结论追加进 PIP_REUSE_STRUCTURE.md，并给 STATUS.md 加一节。"""
import io, re, os, json

DOC = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\PIP_REUSE_STRUCTURE.md"
STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

SEC = """
## §11 源 → 槽位顺序：不是布线邻接，是 16 条配置 + 族序号规则（2026-11-08）

**问题**：缺口账里「源 → 槽位顺序可推 0/1,536 = 0%」这条，到底是布线邻接决定的，还是表数据？

**做法**（`step03_pip/_q_slot_class.py` → `_q_slot_struct.py` → `_q_slot_free.py` → `_q_slot_rule.py` → `_q_slot_period.py` → `_q_slot_split.py`）：
把 24 源族的每个源名解析成 **(线类, 方向)**，再把它在 `law_cells` 里的 cell 解析成 **(行号 r, 列码 c)**，
最后统计 `c = f(线类)`、`r = f(方向)` 在 64 个族里成立多少次。

### 11.1 结构（全部实测，64 个 24 源族）

| 判据 | 结果 |
|---|---|
| 列码 `c = f(线类)`，4 类各占一个码 | **64/64** |
| 行号 `r = f(方向)`，每类 4 向铺满 row 0..3 | **64/64** |
| 斜线族的行号 = 同名主轴方向的行号（NE→N、NW→W、SE→E、SW→S） | **64/64** |
| 8 个非方位源（3×`LOGIC_OUTS` + 4×`BOUNCE` + 1×`GFAN`）占 row 4/5 | **64/64** |
| 每个（族, 码）列里恰有 1 个 row4 + 1 个 row5 旁路源 | **256/256** |
| 64 个族去重后只有 **16 种配置** | 每种配置恰 **4 个族** |

- 列码的物理语义：`1`=斜线组、`2`=主轴短线组、`7`=R 线组、`11`=长线组（同一个码下 4 个方向各一个源）。
  码值 `{1,2,7,11}` 恰好是「短两族各占一位、长两族各占三位」的形状，和 §2 的列重谱型一致。
- 行号的物理语义：row 0..3 = 该线类的 4 个方向，row 4/5 = 不区分方向的旁路线。
- **哪一族拿 `1` 还是 `2`（`7` 还是 `11`）逐族不同**，这是 16 种配置差异的来源之一。

### 11.2 16 种配置由族序号决定（不是随机的）

| 族前缀 | 配置随序号的规律 | 实测 |
|---|---|---|
| `BYP_ALT` 0..7 | 偶数一个配置、奇数另一个，且**互为镜像 `r → 3 − r`** | 4/4 对全镜像 |
| `FAN_ALT` 0..7 | 0,1,2,7 一种；3,4,5,6 另一种 | 64/64 命中 |
| `IMUX_L` 0..47 | 每 8 个一组，组内奇偶交替；6 组 × 2 = **12 种配置** | 64/64 命中 |

- 判据脚本 `_q_slot_period.py`：把「(角标 // 8, 角标 % 2)」当键，**18 个键、0 个冲突**；
  也就是说族名（前缀 + 序号）→ 配置是一个确定的函数。
- 镜像 `r → 3 − r` 在 `axis`、`longL`、`rline` 三类上**都闭合**（`_q_slot_variants.py`：三类的排列集合对镜像封闭）。

### 11.3 判定：可推导，且与布线邻接无关

- **几何部分 1,024/1,024 = 100.00% 可重建**（16 个源 × 64 族，`_q_slot_split.py`）：
  只用「族名 → 16 条配置表」+「源名 → (线类, 方向)」，就能还原每个几何源的 `(r, c)`。
- 旁路部分 512 条只还原了结构（每码一 row4 + 一 row5），**哪一个名字在 row4 仍是逐族数据**（未解）。
- **不是布线邻接**：这张表对 INT_L 的 **26,550 个 tile 完全相同**（`law_cells` 的键是 `(tile_type, family, src_wire)`，不含 tile 坐标），
  与 `tileconn` 的对外连线、与 mux 在 die 上的位置都无关。`_q_tc_geo.py` 只是确认了源线的对外几何，**没有进入槽位判定**。

### 11.4 能讲到哪一步

- 【数据事实】16 种配置、族序号决定配置、几何部分 100% 可重建、镜像闭合。
- 【推断】配置的差异来自布图时这 24 路布线的物理入线顺序（同一族在不同 die 位置用同一张表，说明它是"族级"常量而不是"位置级"）。
- 【未测】为什么恰好 16 种、为什么镜像成对与奇偶绑定；96 个 20 源族（`EE2BEG0` 这类 BEG 族，其位不在 16..25 帧）不在本网格体系内，未展开；
  INT_R 侧需按 §INT_R 归一化后重跑同一套判据（预期一致，未做）。
"""

def append_doc():
    d = io.open(DOC, encoding="utf-8").read()
    if "§11 源 → 槽位顺序" in d:
        print("DOC 已包含 §11，跳过")
        return
    io.open(DOC, "w", encoding="utf-8").write(d.rstrip() + "\n" + SEC)
    print("DOC 追加 §11 完成，行数：", len(io.open(DOC, encoding="utf-8").read().splitlines()))

def append_status():
    s = io.open(STATUS, encoding="utf-8").read()
    nums = [int(m.group(1)) for m in re.finditer(r"^##\s+(\d+)\.", s, re.M)]
    nxt = max(nums) + 1
    body = f"""
## {nxt}. 复用主线：源→槽位顺序判定为「16 条配置 + 族序号规则」（2026-11-08）

短板（此前记为 0/1,536 可推）已判定：**不是布线邻接，也不是 1,536 条任意数据**。

- 【数据事实】64 个 24 源族去重后只有 **16 种配置**，每种 4 个族；配置由族名（前缀 + 序号）确定：
  `BYP_ALT` 奇偶交替且互为镜像 `r→3−r`、`FAN_ALT` 0/1/2/7 与 3/4/5/6 两态、`IMUX_L` 每 8 个一组组内奇偶交替（12 种）。
- 【数据事实】结构：列码 = f(线类)（斜线/主轴短线/R 线/长线 四类）64/64；行号 = f(方向) 64/64；
  斜线行 = 同名主轴方向行 64/64；8 个旁路源占 row 4/5、每码一 row4 + 一 row5 共 256/256。
- 【数据事实】几何部分 **1,024/1,024 = 100% 可重建**（`_q_slot_split.py`）；旁路部分 512 条只还原结构，row4/5 归属仍是逐族数据。
- 【数据事实】该表对 INT_L 全部 26,550 个 tile 相同（`law_cells` 键不含坐标）→ 与 tileconn 连线、与 mux 位置无关。
- 【未测】为什么恰好 16 种、镜像与奇偶的成因；96 个 20 源 BEG 族未展开；INT_R 侧未重跑。
- 文档：`step03_pip/PIP_REUSE_STRUCTURE.md` §11；脚本 `_q_slot_class.py`…`_q_slot_split.py`。
"""
    io.open(STATUS, "a", encoding="utf-8").write(body)
    print("STATUS 追加 §%d 完成" % nxt)

append_doc()
append_status()

s = io.open(STATUS, encoding="utf-8").read()
print("STATUS 行数：", len(s.splitlines()), "| \\ufffd：", s.count("\ufffd"),
      "| 章节数：", len(re.findall(r"^##\s+\d+\.", s, re.M)))
