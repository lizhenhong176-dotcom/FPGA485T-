# 提示词：聚焦「PIP 配置位复用」问题的独立评审 / 攻关

> 用法：整段复制给一个**没有本项目上下文**的模型。它会自带全部背景、术语、
> 已测数据与证伪要求。目标不是让它复述结论，而是让它**判定我们的结论是否成立、
> 定位前人工作、指出量化边界、给出下一步可执行实验**。

---

## 1. 你的角色

你是一位同时具备两栖背景的研究者：
- **FPGA 体系结构与 EDA 方向**（时序驱动布局布线、可编程互连的资源图抽象）；
- **比特流逆向工程方向**（Xilinx 7 系列 / Lattice ECP5 / iCE40 的位流文档化实践）。

你熟悉 prjxray、Project Trellis、Project IceStorm、Mistral、fasm2bels、Debit 这一批工作。
你被要求**严格区分「我读过原文的事实」与「我根据常识的推断」**，并且**不许为了让提问者高兴而弱化问题**。

## 2. 任务

有人在一个真实的 FPGA 位流逆向项目里声称解决了「PIP 配置位复用」问题。请你：

1. 判定**这个问题本身是否成立**（是不是伪问题 / 是不是被术语包装的常识）；
2. 判定**前人是否已经解决**（哪些项目/论文碰到过、解决到什么程度、我们的说法有没有重复劳动）；
3. 判定**这个项目的完成度**（六维定级，见 §7）；
4. 指出**证据链最薄弱的一环**与**还没被证伪的假设**；
5. 给出**下一步最小可执行实验清单**（每个实验要能证伪某条结论）。

## 3. 背景事实（均为项目实测，可直接采信为数据；结论部分需你独立评判）

### 3.1 硬件与位流格式
- 器件：**Xilinx Virtex-7 `xc7vx485tffg1761-2`**（75,900 个 SLICE：43,200 SLICEL + 32,700 SLICEM；
  150,380 个 tile；14 个时钟区域）。
- 位流：共 **50,176 帧**（含 28 个 OVERHEAD 帧），每帧 **101 字 × 32 位 = 3,232 位**；
  所有帧**从低地址到高地址顺序存放**，帧地址不跳跃。
- 每个时钟区域（clock region）= 50 行 = **100 帧**（2 帧/行）+ 2 个 OVERHEAD 帧；
  行内字序：`word = 2*(Y % 50) + parity`，`w50` 存放该带 **ECC**。
- 一个 CLB tile 占 **36 帧**（两列 CLB 共享 36 帧，各 18 帧）；INT tile 亦 36 帧；
  BRAM / INT_INTERFACE 等夹缝列占 **28 帧**。
- 配置单元（cell）定位：`(tile_block_base + frame_off, word, bit)`，`frame_off` 为**块内相对帧偏移**，
  `bit ∈ [0,31]`。

### 3.2 项目已有的位级结论
- INT tile 位池：**1,664 位**（26 帧 × 2 字 × 32 位），其中 **1,598 位**被
  **3,636 条 PIP feature** 覆盖，**66 位从未被任何 feature 覆盖**。
- 每条 PIP 的编码只占 **1–4 个 cell**。
- 同一个 mux（下称 **family**）的**多个源（source）共享同一组 cell**，靠 0/1 组合区分；
  N 的分布为 **3..18 源共享一个 cell，平均 5.57 源/cell，最大 18**。
- **cell → family 是独占的**：1,598/1,598 个 cell 只被一个 family 使用，**0 例跨 family 共享**。
- family 内 `(domain_size, source_count)` 组合只有 **5 类形状**：
  `(9,20)×96`、`(10,24)×64`、`(8,16)×6`、`(7,12)×4`、`(9,18)×2`。
- 统计口径：**3,270 条观测，0 反例**（脚本 `verify_reuse.py`）；
  统计必须用 `(frame_off, parity, bit)` 三元组，否则会误合并。
- 全芯片一次解码：**181 条 PIP / 181 family / 0 ambiguous**（`s13_pips.json`）。
- 写位回环：**864/864**（含重算 ECC）payload 一致；同 family 内 **172/172 源编码唯一**。

### 3.3 项目已有的拓扑与结构结论
- `tile → 帧块基址` 映射规则（含夹缝列）已验证；`tileconn.json` 提供 wire 级跨 tile 连接
  （17,928 条，类型级 + 位置增量）。
- 位级「写回 → 重综合 → 逐帧比对」验证过一次完整闭环：CLB 配置位**0 字差异**，
  差异只出现在路由决定的 IMUX 选择区（18 字）与全芯片 53 字（布线 + ECC）。
- IMUX（BEL 输入选择 mux）位表**按 slice 实例形态**（inst0/inst1）跨 tile_type 复用，
  在另一个 tile_type 上解出 2/2 exact+unique，回放原实例 6/6，与独立 CSP 求解一致。

## 4. 核心定义：到底什么是「PIP 配置位复用」

**必须先厘清，因为同一个词在位流逆向里指两件不同的事。**

### A. 位级共享（bit-level sharing）——本项目的核心命题
> 一个配置 cell 的取值，同时参与**多条 PIP feature 的编码**。

精确表述：设某 tile 的配置位集合 `B`。每条 PIP feature `f` 对应一个**部分赋值**
`a_f : S_f → {0,1}`，`S_f ⊆ B`，`|S_f| ∈ [1,4]`。若 `S_f ∩ S_g ≠ ∅` 且 `f ≠ g`，
则称 `f`、`g` 在该 cell 上**共享配置位**。

于是：
- 位流里某 cell 置 1，**不能**推出某条 PIP 被选中；
- 只有当把**整组位拼成 pattern** 并与 `a_f` 逐位比对，才能判定 `f` 是否成立；
- pattern 全 0 也合法时（默认源），"全 0"本身就是一个 feature 的编码。

**本项目实测的结构**：共享只发生在**同一个 mux（family）内部**（N 个源共用一个位池，
靠 `0/1` 组合区分）；**跨 family 零共享**（cell → family 独占）。这条被称为
**family-private bit domain**。

### B. 位模式跨实例复用（pattern reuse）——另一件不同的事
> 同一个 family 的同一条源的编码，在**其它 tile / 其它 band / 其它列 / 其它 slice 实例**上
> 用**相同的块内相对偏移**重复出现，只需按坐标改写基址与 word。

本项目已证：同 `tile_type` 全芯片一次解出 181 条（0 ambiguous）；
跨 `tile_type` 时按 **slice 实例形态**迁移（inst0/inst1 两套表）。

### C. 不是本命题的几种「复用」（请主动排除）
- **布线资源复用**：同一个 PIP 被多条网在第 n 次编译中重复使用——与位流编码无关。
- **工具层的 table 复用**：把 fuzz 结果缓存给别的 tile——属于实现技巧，不是物理命题。

## 5. 术语表（请在你的回答中保持这些定义）

| 术语 | 英文 | 含义 |
|---|---|---|
| 配置单元 | configuration cell / CRAM bit | 一个 SRAM 位，驱动一个 pass-transistor 栅极 |
| 帧 / 字 / 位 | frame / word / bit | 帧=3,232 位；帧内 101 个字；字内 32 位 |
| FAR | frame address register | 帧地址；本项目位流按 FAR 顺序紧凑排列 |
| tile | — | 器件可配置阵列的最小规则单元（CLB/INT/BRAM/DSP/IO…） |
| tile_type | — | 同类 tile 的模板名（如 `INT_L`、`CLBLM_R`） |
| PIP | programmable interconnect point | 一条可编程连线开关，`SRC ->> FAM`：把源 wire 驱动到目标 wire |
| mux / family | mux tree / family | 一组互斥的 PIP（同一目标 wire 的多个候选源）；**位池共享的边界** |
| 源 / 目标 | source wire / sink(FAM) wire | 信号进入/离开一个 mux 的两侧 wire |
| 位池 | bit pool / bit domain | 一个 family 全部源共用的一组 cell |
| sense | positive/negative sense | 该 cell 应置 1 还是应清 0 才使该源成立 |
| 独占 | exclusivity / family-private | 一个 cell 只被一个 family 使用 |
| 别名 | aliasing / ambiguity | 位集可匹配多条 feature，反解不唯一 |
| 一热 fuzz | one-hot differential fuzz | 构造只差一个变量的两份设计，差分定位该变量对应的位 |
| 差分探针 | differential probe | 同上；需配合「绝对值探针」弥补基线已置位的盲区 |
| segbits | — | prjxray 的位数据库格式：`feature bit1 bit2 ...`，`!` 表示该位需为 0 |
| FASM | FPGA Assembly | 位流特征的高级文本表示（prjxray/fasm 生态） |
| BEL | basic element | slice 内的基本单元（A6LUT、AFF、CARRY4…） |
| IMUX | input mux | 把 INT 的 wire 接到 BEL 输入脚的 mux |
| ECC | — | 7 系列每带 2 帧的纠错校验字（`w50`），改写位必须重算 |
| 覆盖 / 唯一 | coverage / uniqueness | 反解可判定性的两个条件：每个观测位被解释；候选源唯一 |

## 6. 可用数据与复现入口（相对路径基于项目根 `E:\DEEPSEEK\FPGA比特流逆向`）

| 文件 | 内容 |
|---|---|
| `step03_pip/REUSE_RULES.md` | 复用规律的最终陈述（本命题目录级结论） |
| `step03_pip/verify_reuse.py` | 3,270 条观测的验证脚本（0 反例） |
| `step03_pip/tilepipe.json` | 48 个 tag 的 IMUX 实测位表 |
| `step03_pip/s13_pips.json` | 全芯片 181 条 PIP 的解码结果（tile/fam/src/base/w0） |
| `step03_pip/s13_solution2.json` | 9 条网的全局互斥解（98/181 PIP 占用） |
| `step03_pip/S13_INT_GLOBAL.md` | 与 Vivado 真值 147 条 PIP / 12 条网的对账 |
| `step03_pip/S15_PURE_DECODE_RESYNTH.md` | 纯解码网表 + 重综合位级验证 |
| `step03_pip/netlist2.v`、`E:\v7work\netlist2.v` | 从位流单独恢复出的网表 |
| `E:\v7work\db\prjxray\xc7vx485t\` | tilegrid / tileconn / per-type wires&pips（静态拓扑） |
| `E:\v7work\model\v7_law.sqlite` | `law_cells`（24,328）、`clb_cells`（3,884）、`v7_verified`（98 条已验证规律） |

## 7. 你要给出的六维定级

对下面每一维给 **A / B / C / D** 并写判据（**不要只给结论，要给可核对的数字或实验**）：

1. **现象刻画**：共享结构是否被完整、量化地描述？
2. **正向映射**（PIP ⇒ 位集）：是否可复现、是否唯一、是否有写位回环证据？
3. **反向映射**（位集 ⇒ PIP）：单 PIP 情形？**多 PIP 同 tile 同时激活**情形？
4. **跨实例泛化**：同 tile_type 多位置？跨 tile_type？跨器件？
5. **跨家族泛化**：INT 之外（BRAM / DSP / IO / 时钟）是否成立？
6. **与既有工具可比**：能否与 prjxray segbits / fasm2bels 做逐行或端到端交叉验证？

## 8. 必须回答的证伪性问题

对每条给出「若成立会推翻什么 + 最小检验办法」：

1. **跨 family 零共享** 是否只是 fuzz 覆盖偏差（只测了可达源）？
2. **172/172 唯一编码** 是否被探针设计人为排除（探针可能从不产生"两源位同时置 1"）？
3. **66 个未覆盖位** 是否在别的上下文中被复用（覆盖偏差的分母问题）？
4. 多 PIP 同时激活时，**单条查表** 是否必然失效？需要集合覆盖还是 CSP？
5. `sense=0` 的 cell 在不同上下文中是否含义漂移（同一 cell 在不同 family 中语义冲突）？

## 9. 输出格式（严格按此六段）

1. **结论先行**：三句话（问题是否成立 / 前人是否解决 / 我们到什么程度）。
2. **前人工作表**：项目或论文、年份、类型（工具/论文/厂商文档/专利）、他们解决了什么、
   **对"多源共享"是"解决/绕过/未涉及"**、与我们重合度。
   **每条标注你实际读了全文还是只看了标题摘要。**
3. **问题成立性判定**：形式化陈述 + 对 §8 五条证伪问题的逐条回答。
4. **六维定级表**：维度 / 分数 / 判据 / 扣分原因。
5. **缺口与实验清单**：每个实验写"假设 / 最小实验 / 反例后果 / 预计工作量"。
6. **术语与定位建议**：我们该用什么词描述该现象（文献通行词 vs 自造词），以及
   **这份工作在学术/工程版图里的位置**（是不是新贡献，还是对已知事实的首次量化）。

## 10. 纪律约束

- 区分**事实**（读了原文/有数据）与**推断**（合理但未验证），用不同措辞标注。
- 不许把"没有找到"写成"不存在"；找不到就写"未找到证据"。
- 不许用"这很常见/众所周知"替代论证。
- 若你认为该命题在学术上价值有限，请直接说明理由，不要绕。
- 若你发现我们某条结论**与公开材料冲突**，优先报告冲突，并给出可复现的核对办法。
