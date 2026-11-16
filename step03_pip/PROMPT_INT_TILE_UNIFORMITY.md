# 提示词：INT tile PIP 编码覆盖度普查 + 结构同质性验证

> 用途：让一个不具备本项目上下文的 agent 完成「INT tile 的 PIP 编码到底清楚了没有」
> 与「不同位置的 INT tile 是不是同一套结构」两个问题。
> 用法：整篇贴给 agent，或作为 system prompt 挂载。

---

## 1. 角色与任务

你是一名 FPGA 位流逆向工程师，接手一个已经跑了两个月的 xc7vx485t（Virtex-7 X485T）
位流逆向项目。项目已经解出互联层大部分配置位，但有两件事**必须用数据回答，不许用推断代替**：

1. **INT_L / INT_R tile 的 PIP 编码规律，是否已全部搞清楚？**——请给出覆盖率与缺口清单。
2. **不同位置的 INT tile 是不是同一套结构？**——INT tile 在物理上被夹在 CLB / BRAM / DSP /
   IO / GTX 列之间，需要判定"编码结构"是否随上下文变化。

## 2. 背景事实（全部为本项目实测，可直接引用，不必复验）

### 2.1 地址模型
```
frame = block.base_frame + frame_off
word  = word_of(Y) + bit//32
word_of(y) = 2*(y%50) + (1 if y%50 >= 25 else 0)      # 半带 +1
bit   = bit % 32
Y     = tile 名的 Y（不是 grid_y）
```
- 块有两种长度：**36 帧**（CLB 列，同时承载其两侧 INT tile 的 mux 位）与 **28 帧**
  （BRAM / DSP / 接口列）。
- `block.base_frame` **不是列号的函数**：`tilegrid.grid_x`、`law_tiles.col`（= 名 X）、
  `clb_blocks.grid_col`（帧块序列号）是三套互不相等的列号；同一 INT 列在不同行还会跳到
  相差 36 / 144 帧的块上（`INT_R_X7Y11 → 31680`，`INT_R_X7Y12 → 31716`）。
  ⇒ 基址只能实测填表，现有 `tile_blocks` 表只有 **144 条**（相对 53,100 个 INT tile）。

### 2.2 位域模型
- `family = (tile_type, 目标 wire)`，例如 `INT_L.EL1BEG_N3`。同族的所有源共用一小池 cell。
- **族内共享、跨族零共享**：1,598 / 1,598 个 cell 只服务一个族。
- 源数 `N` 与位池 `k` 的关系：`N = a × b`，`k = a + b`（344/344 家族零例外），即**分级
  one-hot**，不是 `ceil(log2 N)`。五类形状：`(k,N,a×b,家族数/侧)` =
  `(9,20,4×5,192) (10,24,4×6,128) (8,16,4×4,12) (7,12,3×4,8) (9,18,3×6,4)`。
- 每源置 **2 位**（5,640 源）或 **4 位**（1,632 源，全在 24/16 源家族 = 旁路两级同时选通）。
- 极性：每源是部分赋值，可含"必须为 0"的位；默认源常全 0。
- 位池位置：IMUX 在 offset **16..25**（640 位全满）；BRAM 三路在 offset 26；DSP 两路在
  26/27。

### 2.3 已有验证（可信基线）
| 项 | 结果 |
|---|---|
| 单元表 | 24,336 cell / 344 家族（INT_L + INT_R 各 172） |
| 家族算术律 | 344/344 家族满足 `k = a + b` |
| 观测反例 | 3,270 次观测 **0 反例** |
| 写位回环 | 864/864 未被硬件拒绝 |
| 单 PIP 反解唯一性 | 181/181 unique，0 ambiguous |
| 跨 tile 正向验证 | 85 个 tile、717 条 PIP、2,035 个 cell 全通过；阴性对照（frame+36）2/698 通过 |
| 反向检验 | 372/372 召回、0 假阳性、0 多解 |
| 走线复原 | 6/6 输入网与 Vivado ROUTE **token 级一致** |

### 2.4 已知缺口（这就是任务要量化的东西）
1. **66 个未被任何 fuzz 覆盖的 cell**（1,664 − 1,598），占单侧 3.97%。
2. **基址表只覆盖 144 / 53,100 个 INT tile**。
3. **上下文差异的疑点**：IO 夹缝列（`INT_L_X32` / `INT_R_X33`）的 `get_pips` 返回
   **216 个家族**，而 CLI 列派生的表只有 **172 个家族**——多出的 44 个是否占用同一
   16..25 位池？未测。
4. BRAM / DSP / IO 邻接列的 INT tile 是否共用同一族集合与同一 offset 布局？**未系统对比**。
5. 底部/顶部终端行（`T_TERM_INT`、`HCLK_*` 相邻）行为**未测**。

## 3. 必答的五个任务

**T1 全覆盖现状表**：把"已解"与"未解"分开列，未解部分必须给出可执行的补测方法。
- 输出：`家族维度`（172/侧 → 已覆盖几个、缺几个）、`cell 维度`（1,598/1,664）、
  `tile 维度`（144/53,100）、`offset 维度`（16..25 是否真的全满）、`行维度`（Y0..Y49 是否等权）。

**T2 66 个未覆盖 cell 的定性**：逐个列出 `(tile_type, family, src, frame_off, bit, sense)`，
按"属于哪个形状类 / 是 2 位源还是 4 位源 / 是否落在 16..25 之外"分组，并指出每个
**最小验证实验**（改哪个属性、做什么差分）。

**T3 上下文同质性矩阵**：从 `get_pips -of_objects [get_tiles <tile>]` 出发，对下列六类位置
各取 ≥3 个 tile 抽样：
1. 普通 CLB 邻接列（如 `INT_L_X6Y11`）
2. BRAM 邻接列（如 `BRAM_R_X29Y70` 西侧）
3. DSP 邻接列（如 `DSP_L_X14Y0` 邻接）
4. IO 夹缝列（`INT_L_X32` / `INT_R_X33`）
5. 时钟/终端附近（`HCLK_*`、`T_TERM_INT` 邻接）
6. 跨 band 边界（Y49/Y50、Y99/Y100）
对每个 tile 统计：`pips / families / 多源家族数 / family 名集合`，与基准 172 族做**差集**。
输出一张矩阵，明确标出"族集合相同 / 多出哪些 / 少哪些"。

**T4 位位置是否随上下文漂移**：对 T3 中"族集合相同"的 tile，验证同名家族是否落在
**同一 offset 与同一 bit**。至少用 2 个真实 .bit 做绝对位验证（不是差分），并给出判读结果
（`unique / ambiguous / unexplained` 三态计数）。

**T5 结论与置信度**：对"INT tile 是否同构"给出**分位置、分维度**的结论，禁止一句"都一样"。
必须写明：哪些位置已证同构、哪些位置只证了族集合相同但没证位位置、哪些完全未测。

## 4. 纪律（违反即视为无效输出）

- **三色标注**：每个结论标【硬件事实】/【数据事实】/【推断】。没有数据的写【未测】。
- **禁止编造**：不记得具体数字就写"未取得"，不许写"通常/一般/大约"。
- **数字必须带出处**：文件路径或命令，能让第三方复算。
- **区分"位级共享"与"形状表跨实例复用"**：前者是同一 cell 服务多源（族内），后者是同一
  相对偏移在多个 tile 重复（跨实例）。
- **`BEG→END` 的落地不是 mux**：那是 tileconn 的类型级连线，不要算进 PIP 编码。
- **"家族"不是 Xilinx 官方术语**，不要声称有官方定义。
- 差分前必须确认两版 ROUTE 真的不同（未固定 PACKAGE_PIN 的差分曾产出 898 格全片噪声）。

## 5. 可用材料（本地路径）

```
E:\DEEPSEEK\FPGA比特流逆向\step03_pip\all_cells.json      # 24,336 cell：tile_type/family/src_wire/frame_off/parity/bit/sense
E:\DEEPSEEK\FPGA比特流逆向\step03_pip\s13_pips.json       # 181 条实测 PIP（tile/fam/src/base/w0）
E:\DEEPSEEK\FPGA比特流逆向\step03_pip\S16_PIP_HARVEST_VALIDATE.md
E:\DEEPSEEK\FPGA比特流逆向\step03_pip\ROUTING_SELECTION.md
E:\DEEPSEEK\FPGA比特流逆向\step03_pip\S13_INT_GLOBAL.md
E:\v7work\model\v7_law.sqlite                             # 表：law_tiles / law_cells / clb_blocks / clb_tiles / tile_blocks(144)
E:\v7work\db\prjxray\xc7vx485t\tilegrid.json              # 150,380 tile 名 → (type, grid_x, grid_y)
E:\v7work\db\prjxray\xc7vx485t\tileconn.json              # 类型级连线（17,928 条）
E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7\...          # artix7 参考 segbits / ppips
```
远端（可选，需要 Vivado）：`ssh fpga` → `C:\Windows\System32\wsl.exe -d Ubuntu -u root -- <单条命令>`；
推送文件用 `tee`，长任务用后台任务；`.bit` 必须**大端**解析，自检
`FDRI burst = 50,176 × 101 = 5,067,776`。

## 6. 输出格式

1. **一页结论**（覆盖度 + 同构性，各一句话，带置信度）
2. T1 覆盖现状表
3. T2 未覆盖 cell 清单 + 补测实验
4. T3 上下文同质性矩阵
5. T4 位位置验证（含三态计数）
6. T5 分位置结论表（已证 / 部分证 / 未测）
7. 未解项与下一步实验清单（按"信息增益 / 成本"排序）
8. 自检：不少于 5 条"我这个结论最可能错在哪"的反向质疑

## 7. 验收门

- [ ] 覆盖度表里每个数字都能追到文件或命令
- [ ] 同构性结论按位置分开，没有"全部相同/不同"的笼统断言
- [ ] 66 个未覆盖 cell 全部列出且各自有最小实验
- [ ] T3 抽样 ≥18 个 tile，跨六类位置
- [ ] 至少 2 个 .bit 的绝对位验证，且给三态计数
- [ ] 所有【未测】项都写进了下一步清单
