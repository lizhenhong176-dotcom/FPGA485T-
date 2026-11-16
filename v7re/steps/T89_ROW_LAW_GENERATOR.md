# T89 行序生成律落地：4 个基置换 + 步进律，接入生成器

日期 2026-11-13 · `xc7vx485tffg1157-3` · 数据只读 `v7_law.sqlite: law_cells`
脚本：`step03_pip/_row_gen.py`（选项 3）、`step03_pip/row_law.py` + `step03_pip/gen_mux_rowlaw.py`（选项 1）

---

## 一、选项 3 收尾（生成律写成代码并全量对拍）

### 1.1 模型（不存 8 张表）

```
p0: DIAG (2,0,3,1)  ORTH (2,3,0,1)  R (2,0,1,3)  L (3,1,0,2)
p_{j+1} = g_j ∘ p_j,  (a∘b)(k) = a[b[k]]
class ∈ {DIAG,ORTH}: g = [r3, rho, r3, e,   r3, rho, r3]
class ∈ {R,L}:        g = [r,  rho, r,  X2,  r,  rho, r ]
r=(1,2,3,0) rho=(3,2,1,0) e=(0,1,2,3) r3=(3,0,1,2) X2=(3,2,0,1)
primary=S: 每个位置 +2 mod 4
j = (pair // 2) % 8（规范键序，换排序序列则步进律不成立）
```

### 1.2 结果【数据事实】

| 判据 | 分子/分母 | 结果 |
|---|---|---|
| 4 基置换 + 步进律重建 32 个置换 | 32/32 | 与实测逐项相等 |
| 拼成 16 种编码后与 `law_cells` 全量对拍 | 2,048/2,048 | **0 不符**（两侧各 1,024） |
| `p7 == p0` | DIAG/ORTH **成立**，R/L **不成立** | 周期**不是 8** |
| 类别对 vs 线长类别（列码实测） | 2,048 条方向线 | DIAG/ORTH ⊂ {1,2}=DOUBLE；R/L ⊂ {7,11}=SINGLE，**0 例外** |

### 1.3 三条要求的回答

1. **代码与对拍**：见 `_row_gen.py`，末行 `RESULT: PASS (2048/2048)`。
2. **类别对的分界**：步进律的两支（`A=r3/X=e` 与 `A=r/X=X2`）与实测列码的两类
   （{1,2}=DOUBLE 与 {7,11}=SINGLE）是**同一个二分**，2,048 条零例外。
   【推断】行序与列码由同一变量（线长类别）驱动；这是「同一分组」的证据，
   不是因果证明——要证因果需在存在混合线长类别的 tile_type 上重复（选项 2）。
   可证伪条件：若某 tile_type 上出现「同一线长类别走不同步进律」或「同一支覆盖两种线长」，则作废。
3. **p7 结论**：DIAG/ORTH 的 `p7 == p0`；R/L 的 `p7` 是 `p0` 复合 ρ，不等于 `p0`。
   因此整体周期不是 8；只有 DIAG/ORTH 子空间呈 8 周期。

---

## 二、选项 1：接入生成器（去逐族 slots）

### 2.1 实现

- `step03_pip/row_law.py`：只存 **4 个基置换 + 5 个步进置换 + 1 个类别对比特**，
  族名 → `(pair, parity, primary, 列码)` 全用闭式；`direction_slots()` 给出 16 条方向线的 `(row, col)`。
- `step03_pip/gen_mux_rowlaw.py`：用律替换 `pip_reuse_law.json` 的逐族 `slots`，
  行 4/5 的 512 个槽位（LOGIC/GFAN、BOUNCE 的成员→列归属）作为 **residue** 从旧模型带入，单独计数。

### 2.2 验收结果（全部通过）

| # | 判据 | 分子/分母 | 结果 |
|---|---|---|---|
| A | 与旧 `pip_reuse_law.json` 的 1,536 条 slots 逐条比对 | 1,536/1,536 | **差分 0**（方向线 1,024 由律给出，行 4/5 residue 512） |
| B | 方向线确实来自律（不是抄回旧表） | 1,024 | 由 `direction_slots()` 生成 |
| C | 随机 200 个 `(family, source)` 与 `law_cells` 对拍 | 200/200 | **0 不符**（seed 20261113） |
| D | 接回 `predict()` 与 `law_cells` mux 区全量对账 | 1,536/1,536 | **0 不符** |
| E | 两侧方向线各自全量 | 2,048/2,048 | **0 不符**（INT_L 1,024 + INT_R 1,024） |
| F | `verify_all_pip.py --tile-type INT_L` | 3,634/3,634 | 100%，0 不符 |
| G | `verify_all_pip.py --tile-type INT_R --normalize` | 3,634/3,634 | 100%，0 不符 |

### 2.3 量级

| 表示 | 规模 |
|---|---|
| 旧：64 族 × 24 源逐条 slots | 1,536 条（约 3,072 个整数） |
| 新：行序部分 | 4 个基置换（≈18.3 bit）+ 5 个步进置换（≈22.9 bit）+ 1 bit |
| 仍未去表 | 行 4/5 的 512 个槽位（residue） |

---

## 三、边界与未解

- **4 个基置换 `p0` 本身**（≈18.3 bit）仍是数据，未找到出处。
- **行 4/5（LOGIC/GFAN、BOUNCE）**：行号由 `g=i//8` 奇偶决定（64/64），
  但「哪条 LOGIC 线进哪一列」是逐族数据（512 槽），本轮未解。
- **因果**：类别对 = 线长类别只是分组证据；因果需选项 2 的跨类型检验。
- **规范键序依赖**：步进律只在 `j=(pair//2)%8` 下成立，换排序即变，文档必须写明。

## 四、复现

```bash
python step03_pip/_row_gen.py          # 选项 3：期望 RESULT: PASS (2048/2048)
python step03_pip/gen_mux_rowlaw.py    # 选项 1：期望 RESULT: PASS
python v7re/scripts/verify_all_pip.py --tile-type INT_L
python v7re/scripts/verify_all_pip.py --tile-type INT_R --normalize
```
