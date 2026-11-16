# -*- coding: utf-8 -*-
"""P1 结果落盘：STATUS 新节 + AMBIGUITY_SOLVABILITY.md 修订。"""
import io, re

ROOT = r"E:\DEEPSEEK\FPGA比特流逆向"
P = ROOT + r"\STATUS.md"
s = io.open(P, encoding="utf-8").read()
n = max(int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)) + 1

body = f"""## {n}. P1：源级可解性的精确判定 —— 源是**唯一可解**的（2026-11-08）

### 一、问法与判据

不要启发式。对单个 tile：观察到的置位集合 `obs`（26 帧 × 2 parity 全池），
去掉未建模标记位后得 `target`；候选池 = 全部格都落在 `obs` 内的 feature
（3,634 条归一化去重后的 `(family, src)` 码字，2 或 4 格）。穷尽枚举
`S ⊆ 候选` 使 `union(S) == target`，解去重。

- **恰 1 解** → 该 tile 的源选择由位流唯一确定（模型口径下）
- **≥2 解** → 同位流、不同源，源级不可解的确证
- **0 解** → `target` 里有任何候选都覆盖不到的格子（模型缺口）

### 二、结果（`step03_pip/out/p1_solvability.json`）

| 位流 | active tile | 唯一解 | 多解 | 零解 | 无 mux 配置 |
|---|---:|---:|---:|---:|---:|
| `tamper/ref/ref.bit` | 982 | **868** | **0** | 0 | 114 |
| `_full8.bit` | 76 | 76 | 0 | 0 | 0 |
| `_b1.bit` | 57 | 57 | 0 | 0 | 0 |
| `_d2.bit` | 27 | 27 | 0 | 0 | 0 |
| `_c0.bit` | 21 | 21 | 0 | 0 | 0 |
| `_g1.bit` | 17 | 17 | 0 | 0 | 0 |

**合计 1,066 个含 mux 配置的 tile，全部唯一解，0 个多解、0 个零解、0 个截断。**

### 三、这推翻了什么（重要）

- `T6B_DISAMBIGUATION.md` 的「53 组多解」「`min-cells 2` 精确率 67.4%」
  **不是信息论限制，是解码器实现的产物**：旧解码器按「一条 feature 的全部格子都置位」独立判定
  （`np.logical_and.reduce`），再用 `min-cells` 启发式过滤；它不要求「解释完所有置位」，
  于是同一个观测能同时满足多条候选 → 多报。
- 换成「union 恰等于观测」的精确判据后，多解消失。原因是**编码本身是分离的**：
  族内每源码字 172/172 互不相同、跨族共享 cell 只有 3/1,598；
  选两个同族源会多出格子使 `union ⊋ target`，于是非法。
- 因此 `STATUS §70` 的 (b) 层「源选择：未证明」升级为 **「在模型口径下证明唯一」**；
  §74/§76 里「2 格歧义」的表述应读作「启发式解码器的歧义」，不是位流的信息论下界。

### 四、能说到哪一步（边界，别越界）

- 【数据事实】上述唯一性是在**已建模的 3,634 条 feature/侧**与「除 3 个已知标记格外无未解释位」的两个前提下测出来的。
- 【推断】若硅片上存在模型里没有的 feature，唯一性可能被高估；但模型已被 `verify_all_pip.py`
  在 INT_L/INT_R 上 3,634/3,634 精确命中、且与 `pips_all.txt` 真值对账（94% 召回）。
- 【未测】跨器件、跨 tile 类型；`block 1` 资源。
- 【未测】在「有条目未解释位」的位流上做同样枚举（本实验的 240 个标记位已被排除）。

### 五、可复算

```
python step03_pip/p1_solvability.py --bit tamper/ref/ref.bit _full8.bit --json step03_pip/out/p1_solvability.json
```

脚本要点：`build_pool()` 先用 `name_variants` 建并查集把 `LV_L0`/`LV0`、
`LOGIC_OUTS_L8`/`LOGIC_OUTS8` 这类同物异名收成一个代表（**不做这一步会凭空造出多解**，
第一版就踩了这个坑）；`enumerate_solutions()` 用「选候选最少的未覆盖格」分支 + 解集合去重 + 节点上限。

### 六、下一步

- 把精确判据接回解码器（替换 `min-cells`），重测 S13/T6B 的精确率/召回 —— 预期两者都到 100%
- 再验证：把「已知标记位」当覆盖物时是否还能构造多解（攻击者视角的歧义）

"""

s = s.rstrip("\n") + "\n\n" + body
io.open(P, "w", encoding="utf-8", newline="\n").write(s)
nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\. ", s, re.M)]
print("STATUS new:", n, "| sections:", len(nums), "| max:", max(nums),
      "| dup:", len(nums) - len(set(nums)), "| lines:", s.count("\n") + 1,
      "| bad:", s.count("\ufffd"))

# --- AMBIGUITY_SOLVABILITY.md 修订 ---
Q = ROOT + r"\step03_pip\AMBIGUITY_SOLVABILITY.md"
t = io.open(Q, encoding="utf-8").read()
amend = """
## 0. 2026-11-08 修订：P1 已做完，(b) 层从「未证明」改为「证明唯一」

用**精确判据**（候选池 = 全部格落在观测内的 feature；穷尽枚举 `union == 观测`，解去重）
在 1,066 个含 mux 配置的 tile 上枚举：**全部唯一解，0 个多解、0 个零解**
（`ref.bit` 868/982 有 mux 配置、其余 114 个无 mux 配置；5 个探针位流 76/57/27/21/17 全唯一；
脚本 `step03_pip/p1_solvability.py`，结果 `step03_pip/out/p1_solvability.json`，
记录见 `STATUS.md §93`）。

结论：`T6B` 的「53 组多解 / `min-cells 2` 精确率 67.4%」是**解码器实现的产物**
（逐 feature 独立判定 + `min-cells` 过滤，不要求解释完所有置位），不是位流的信息论下界。
下文第 1.2 节「联立后是否唯一 = 未证明」按此修订；(b) 层现记为「模型口径下唯一可解」。

前置条件（越界即失效）：模型 = 3,634 条 feature/侧；除 3 个已知标记格外观测全部可解释；
单器件 485T、INT tile。
"""
t = t.lstrip("\ufeff")
i = t.index("\n## ") if "\n## " in t else len(t)
t = t[:i] + "\n" + amend + t[i:]
io.open(Q, "w", encoding="utf-8", newline="\n").write(t)
print("AMBIGUITY_SOLVABILITY.md lines:", t.count("\n") + 1, "| bad:", t.count("\ufffd"))
