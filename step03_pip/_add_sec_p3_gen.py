# -*- coding: utf-8 -*-
"""把 P3（生成器）结果写进 PIP_REUSE_STRUCTURE.md §13 与 STATUS.md。"""
import io, re, os

BASE = r"E:\DEEPSEEK\FPGA比特流逆向"
DOC = os.path.join(BASE, "step03_pip", "PIP_REUSE_STRUCTURE.md")
STATUS = os.path.join(BASE, "STATUS.md")

SEC13 = """
## 13. P3：把定律写成生成器（`gen_slots.py` / `gen_mux.py`）

### 13.1 判据
「能否反过来生成位库」= 只用**族名 + 源名**（外加每族 3 个数字：bit 对、parity、primary 位），
能否逐条吐出 `law_cells` 里的 `(feature, cell)` 记录，并与之**0 差异**。

### 13.2 两个生成器
| 脚本 | 口径 | 覆盖 |
|---|---|---|
| `step03_pip/gen_mux.py` | **cell 级**：由 (行 r, 列码 c) + 每族 (bit 对, parity) 生成全部 cell | mux 侧 64 个 24 源族 |
| `step03_pip/gen_slots.py` | **槽位级**：由「线类→列、方向→行」生成源到槽位的归属 | mux 64 + BEG 96 族 |

### 13.3 结果

**mux 侧（cell 级，`gen_mux.py`）**
| 项 | 结果 |
|---|---|
| 符合公式的族 | **64 / 64** |
| 行规则（方向令牌 → 行，族内唯一） | **64 / 64** |
| 用规则重建后与真值比对 | **64 / 64 族 0 差异**（3,072 条 (feature,cell) 记录） |
| 配置（方向 → 行的映射）种类 | **16 种，每种恰 4 族**（与 §11 一致） |
| 线类 → 列码 | `axis`/`diag` → {1,2}、`rline` → {7,11}、旁路源 → 任意（它们占 4/5 行） |

**BEG 侧（槽位级，`gen_slots.py`）**
| 轴 | 规则 | 命中 |
|---|---|---|
| P（5 组） | 方向令牌 → 组 | **96 / 96** |
| Q（4 列） | 几何类别 → 列（line 与 logic 共列） | **64 / 96** |
| 剩余 | 32 族需逐族列归属列表 | 32 |

### 13.4 覆盖账
| 口径 | 覆盖 feature | 占 3,634 |
|---|---|---|
| cell 级 0 差异（mux 64 族 × 24） | 1,536 | 42.3% |
| 槽位级 0 差异（BEG 96 族 × 20） | 1,920 | 52.8% |
| **合计由生成器复现** | **3,456** | **95.1%** |
| 未生成（12 个复合/长线族） | 178 | 4.9% |

### 13.5 这套生成器需要多大的表
| 内容 | 规模 |
|---|---|
| 每族 (bit 对, parity, primary 位) | 172 × 3 个数字 |
| mux 配置表 | 16 条 |
| BEG 变体族的列归属 | 32 条 |
| 合计 | 约 6×10² 个数，替代 8,900 条置位记录 |

### 13.6 边界
- cell 级 0 差异只在 mux 64 族上做到；BEG 侧是槽位级（真值 cell 还需 BEG 各自的行帧/列帧窗口，尚未写成公式）。
- `primary` 位方向（行 0 用哪个 bit）每族可能不同，生成器从数据里取，尚未给出「由族名推 primary」的规则。
- 12 个复合/长线族未纳入生成器（P2）。

### 13.7 复算
```
python step03_pip/gen_mux.py        # mux 64 族 cell 级重建，应打印「重建 0 差异: 64」
python step03_pip/gen_slots.py      # 槽位级：mux 64/64、BEG 64/96
```
"""

P3_STATUS = """## {n}. P3：定律 → 生成器（2026-11-08）

**结论一句话**：把定律写成可执行生成器后，**mux 侧 64 个族能用「族名 + 源名」重建出全部 cell，0 差异**（3,072 条记录）；BEG 侧 96 个族在槽位级成立，其中 64 族只靠两条全局规则。生成器合计复现 **3,456 / 3,634 = 95.1%** 的 feature，剩余 178 条属 12 个复合/长线族（P2 未做）。

# 一、判据与脚本

| 脚本 | 口径 | 判据 |
|---|---|---|
| `step03_pip/gen_mux.py` | cell 级 | 生成 cell 集合 == `law_cells` 真值 |
| `step03_pip/gen_slots.py` | 槽位级 | 源 → (行/组, 列/码) 归属一致 |

# 二、mux 侧（64 个 24 源族）

| 项 | 结果 |
|---|---|
| 符合公式 | 64 / 64 |
| 方向令牌 → 行（族内唯一） | 64 / 64 |
| 重建后 0 差异 | **64 / 64**（3,072 条 (feature,cell) 记录） |
| 配置种类 | **16 种 × 4 族**（与 §11 一致） |
| 线类 → 列码 | axis/diag→{{1,2}}、rline→{{7,11}}、旁路源→任意 |

关键修正：**primary 位方向逐族不同**（行 0 用哪个 bit），第一版按「最小 bit 优先」假设，导致恰好一半族（32 个 parity=1 的）被判「公式不符」；改为「行 0 所用的 bit 即 primary」后 64/64 全通。

# 三、BEG 侧（96 个 20 源族）

| 轴 | 规则 | 命中 |
|---|---|---|
| P（5 组） | 方向令牌 → 组 | 96 / 96 |
| Q（4 列） | 几何类别 → 列（line 与 logic 共列） | 64 / 96 |
| 变体 | 32 族需逐族列归属表 | 32 |

# 四、覆盖账

| 口径 | feature | 占比 |
|---|---|---|
| cell 级 0 差异 | 1,536 | 42.3% |
| 槽位级 0 差异 | 1,920 | 52.8% |
| 合计 | **3,456** | **95.1%** |
| 未生成（12 族复合/长线） | 178 | 4.9% |

生成所需表规模 ≈ 6×10² 个数字（172 族 × 3 + 16 配置 + 32 变体），对应 8,900 条置位记录。

# 五、边界（不得越界）

- cell 级 0 差异仅 mux 64 族；BEG 是槽位级，其 cell 坐标（行/列帧窗口）尚未公式化。
- `primary` 位为何逐族不同、【未测】；生成器目前从数据取该值。
- 12 个复合/长线族（178 条 feature）未纳入，属 P2。
- 只验证 INT_L；INT_R 未跑同一套生成器（族名归一化已有，`verify_all_pip.py --normalize` 侧证过 100%）。

# 六、复算

```
python step03_pip/gen_mux.py     # 期望：重建 0 差异: 64
python step03_pip/gen_slots.py   # 期望：mux 64/64、BEG 64/96
```

"""


def main():
    doc = io.open(DOC, encoding="utf-8").read()
    assert "## 13. P3" not in doc
    io.open(DOC, "w", encoding="utf-8", newline="\n").write(doc.rstrip() + "\n" + SEC13)

    st = io.open(STATUS, encoding="utf-8").read()
    nums = [int(m) for m in re.findall(r"^## (\d+)\.", st, re.M)]
    n = max(nums) + 1
    st = st.rstrip() + "\n\n" + P3_STATUS.format(n=n)
    io.open(STATUS, "w", encoding="utf-8", newline="\n").write(st)
    print("DOC lines:", len(io.open(DOC, encoding="utf-8").read().splitlines()))
    print("STATUS §", n, "lines:", len(st.splitlines()), "ufffd:", st.count("\ufffd"))


main()
