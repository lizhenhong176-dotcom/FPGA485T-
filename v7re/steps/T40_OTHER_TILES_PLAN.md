# T40（附）：其它 tile 类型的 PIP 迁移计划 — 第 0/1 批可执行清单

状态：**计划（未执行）**。跑完前任何数字不得写进 STATUS 当结论。
前置文档：`v7re/steps/T40_CLASS_A_PROTOCOL.md`（A 类受控协议，已实测）、`v7re/steps/T41_BUFGCTRL_2BIT.md`（手段 A 首次成功）、`v7re/steps/T39_TILE_PIP_SURVEY.md`（四类普查）、`step03_pip/REUSE_RULES.md`（INT 坐标律/语义/形状律）。

注意命名：本文是 T40 的**续篇**，不覆盖 `T40_CLASS_A_PROTOCOL.md`；两文的协议条款冲突时以已实测的 T40 为准。

## §0 为什么先打这几类

【数据事实】T39 统计（115 模板 / 70 含 PIP / 35,126 条）：A 类「每目的恰好 1 源」7,517 条 = **21.4%**，全在接口/控制 tile；INT_L/R 的 3,737 条只占 21.3%；D 类（密集多源）15,726 条 = 44.8% 完全没有位编码。

【推断】A 类若实测成立「一条布线 PIP ↔ 一个位」，这 21.4% 可由模板**零差分成本**生成位库，并提供一条不依赖 artix7 segbits 的独立来源。

## §1 与既有实测的衔接（三条硬约束，先记住）

1. **手段 A 的定义**（T41）：同一路径只换中间一跳，前置断言「两个设计的 PIP 列表逐行相同（或只差被改的那一条）」。T41 用它在 `BUFGCTRL` 上成功：I0/I1 切换 = **2 位**（帧 13080 word 0 bit 11、帧 13081 word 0 bit 3），PIP 列表 92/92 逐行相同。
2. **换引脚不能测 interface PIP**（T40 §3.3）：换脚同时改 IOB 位、ILOGIC 位、LIOI 与 `IO_INT_INTERFACE` 的 PIP、以及到 LUT 的整条 INT 路径 —— 实测 85 格 / 49 帧，不可解释。
3. **1:1 拓扑 ≠ 1 位**：T41 的 `BUFGCTRL` 是 2 源 mux 却占 2 位；T40 的 `IOSTANDARD` 是 7 位/2 帧。所以「A 类一位一 PIP」是**待证伪假说**，不是前提。

## §2 第 0 批：离线参数化（零构建）

### 2.1 交付物

| 文件 | 作用 | 现状 |
|---|---|---|
| `step03_pip/pip_law_any.py` | 以 `templates/<TT>.json` + `tile_pip_survey.json` 为输入，对任意 tile_type 输出族数（扇入>1 的目的）、域大小分布、源数分布、单源占比 | 缺 |
| `step03_pip/block_info.py` | `block_start(col, region)` + 该 block **帧宽** + 断言 frame_off 落在窗内 | 缺（`pip_law.load_prefix()` 只返回 start） |
| `v7re/steps/T40S_SURVEY_ANY.md` | 70 个含 PIP 的 tile_type 同口径对照表 | 缺 |

### 2.2 判据

- O1（回归门）：对 INT_L / INT_R，`pip_law_any` 必须复现既有 172 族 / 1,598 cell / 3,636 feature。
- O2：A 类每个 tile_type 的 `dst == src == pip`（T39 已给，重算须一致）。
- O3：把 `(族数, 域大小分布, 源数分布)` 印表，供第 1/2/3 批对照。

## §3 第 1 批：A 类接口 tile（主攻，两种设计路线）

### 3.1 目标实例与帧窗（从 `phaseA/frame_index_far.csv` 实算）

| 组 | 实例 | tile 名列号 | region | FAR band | block_start | 帧宽 | 帧窗 | PIP |
|---|---|---|---|---|---|---|---|---|
| G1 | `INT_INTERFACE_L_X14Y349` | 14 | X0Y6 | 4 | 21468 | 28 | 21468–21495 | 24 |
| G2 | `BRAM_INT_INTERFACE_L_X50Y349` | 50 | X0Y6 | 4 | 22692 | 28 | 22692–22719 | 24 |
| G3 | `IO_INT_INTERFACE_L_X32Y349` | 32 | X0Y6 | 4 | 22076 | **42** | 22076–22117 | 24 |
| 位置对照 | `INT_INTERFACE_L_X14Y299` | 14 | X0Y5 | 3 | 16222 | 28 | 16222–16249 | 24 |

- 【数据事实】三个模板的 PIP 名**逐条相同**：`INT_INTERFACE_LOGIC_OUTS_L_B0..B23 -> INT_INTERFACE_LOGIC_OUTS_L0..L23`，各 24 条、每目的恰好 1 源（`pip_defs` 实测）。
- 【推断】帧宽 28 / 28 / **42** 说明帧宽是**列（区块）属性**，不是 tile_type 属性 → 见 P2。
- 【未测】`LIOB18` 在 Y=351..361，超出 7 个 CLB 行带，`pip_law.block_start` 会 `IndexError`；**IOB 边缘 tile 的 block_start 算法尚未建立**，本批不碰。

### 3.2 设计路线（两条，先 a 后 b）

**G1a（最省，先做）**：复用现有 `/opt/lzh/v7re/work/ioif3`（或 `clsa`）的 DCP —— 引脚固定、PIP 列表已知。先 `pip_enum` 枚举，找出它实际占用的 interface PIP（记为 m 条，m 可能只有 1–8）。对其中每一条做 **DCP 内 setPIPs 删除**（`step03_pip/pip_edit.py`），其余不动 → 每个构建只差被删的那一条，正合手段 A。
若 m == 0（路由绕开了接口 tile）→ 直接跳 G1b，并在报告里写明。

**G1b（补齐覆盖）**：一套 24 位总线设计：24 个 `LUT6_2`（`DONT_TOUCH`）→ 24 根网 → 目标接口的 24 条 dst → `BRAM_L_X50Y345` 的 `RAMB18E1.DI[23:0]`（G1/G2）或 24 个 IOB 输出（G3）。源 LUT 的 LOC 放在目标 tile 左侧的 CLB 列（G1/G2 → `SLICE_X12Y*`/`SLICE_X48Y*`，G3 → `SLICE_X30Y*`），沿 Y 错开降拥塞。
**判据不是「位」而是「PIP 覆盖率」**：先只用这一套构建拿到 24 条 PIP 全在场的参考流，再用 setPIPs 逐条删（24 个构建）。禁止用改 RTL / 换引脚的方式制造差分（§1.2）。

### 3.3 构建矩阵（按组）

| 构建 | 内容 | G1a | G1b/G2/G3 |
|---|---|---|---|
| A（参考） | 全部目标 PIP 在场 | 1 | 1 |
| B-k（PURE 删一） | DCP 内删第 k 条 PIP | m | 24 |
| C（负对照） | A 原样重跑 | 1 | 1 |
| 小计 | | 2+m | 26/组 |

G1b+G2+G3 = 78 构建，5 路并行 ≈ 20 分钟（实测 75 秒/构建）。

### 3.4 硬前置门（不过门不许写结论）

1. **穿 tile 证明**：`pip_enum` 输出必须含目标实例的 PIP，条数记 m；m=0 则该路降级 skipped 并记录原因。
2. **手段 A 断言**：A 与 B-k 的 PIP 列表**除被删那一行外逐行相同**，否则该对比作废（T40 §3.1 的协议）。
3. **part 显式**：全部 `-part xc7vx485tffg1157-3` 并断言回读 PART（T20 教训：`locked/mk.tcl` 写的是旧 ffg1761-2）。
4. **窗过滤**：只统计 `[block_start, block_start+帧宽)` 内的位；窗外位单独列出并解释（T20 的 `part_zero` 就是窗外 133 帧）。
5. **manifest**：每构建一条记录过 `step03_pip/check_manifest.py`，PASS 才进 STATUS。

### 3.5 判据（可证伪）

- **P1（一位一 PIP）**：被删的每条 PIP → 恰好 1 位，且 24 条位互不相同。出现「一位两 PIP」或「一 PIP 多位」即假说被反驳 —— 记录分布，这是有价值的负面结果（参考：`BUFGCTRL` 2 源 = 2 位）。
- **P2（帧宽是列属性）**：G1/G2 位全落 28 帧窗内、G3 落 42 帧窗内；越界即帧宽算错。
- **P3（tile-type 常量 + 位置不变性）**：G1（`Y349`, band 4）与位置对照（`Y299`, band 3, block_start 16222）的 `(frame_off, word − word0, bit)` 集合必须完全相等。
- **P4（可读性）**：24 个 `frame_off/bit` 按 k 排序是否单调/分段（INT 是「行帧 one-hot + 列码」）；完全无序就记录「本类型不是网格制」，禁止硬套 INT 定律。
- **P5（跨 tile_type 是否共用编码）**：三模板 PIP 名逐条相同 → 若 G1/G2/G3 的 `(frame_off, word−word0, bit)` 集合也相同，则这套接口位编码全器件只有一份，A 类可一次套用；不同则按 tile_type 逐类做。

## §4 第 2 批：BRAM_L / DSP_L（C/B 类，先做单源 78%）

【数据事实】`BRAM_L` 974 PIP / `DSP_L` 794 PIP，单源目的占 78%。

- **禁止照抄 artix7 列号**：`diff_bram.py` 的 `BLOCK_START=35356`（`BRAM_L_X114Y0`）与 `diff_dsp.py` 的 `34884`（`DSP_L_X100Y0`）是 artix7 坐标；vx485t 的 BRAM 列是 50/119/…，必须用 `block_info.py` 重算。
- **配置位当定位器**：`RAMB18_Y0.IN_USE`、`ZINIT_A[0]`、`ZSRVAL_A[0]`（`diff_bram.py:14-17`）、`DSP_VCC_L`/`DSP_GND_L`（`diff_dsp.py:11-12`）。先用它们确认 block_start 算对，再上 PIP 差分。
- 【数据事实】`STATUS.md` §6.12（685–710 行）已验 12 项特征 / 269 位 / 0 反例；其中 `INIT_A bit0 ↔ ZINIT_A[17]` 是位反转 —— 位顺序不能按朴素索引推。

## §5 第 3 批：HCLK_CMT（D 类最高密度）

982 PIP / 42 目的 / 均 23.38 源 / 最大 48。INT 定律的泛化考验：若 `HCLK_CMT` 也是「k 行格 one-hot + 列码 + parity/phase」，`pip_law.py` 的生成式可推广到 `CLK_HROW_*`（2,840 PIP）。做法：先做一个目的的全族构建（23 条一次占满），再逐条删，看域大小是否落在 7..10。

## §6 工具改造（参数化，不重写）

1. `step03_pip/pip_edit.py` → `pip_edit_any.py --dcp <dcp> --net <net> --pip "<src>-><dst>"`（现硬编码 `/opt/lzh/step03/pip1` 与 `net n1`）。
2. `step03_pip/block_info.py`：暴露 `load_prefix` 的 end 以算帧宽。
3. 差分后处理加窗过滤 + 窗外位单独计数。
4. 每构建落 manifest，过 `check_manifest.py`。

## §7 未测与风险

- 【未测】A 类「一位一 PIP」只是拓扑结论（T39 §7 自述），位映射从未实测；T41 的 2 源→2 位是反例先兆。
- 【未测】24 条 interface PIP 能否在一份设计里全部占用（拥塞）。
- 【未测】IOB 边缘 tile（Y351..361）的 block_start 算法未建立。
- 【未测】`GTX_INT_INTERFACE_*` 168 PIP / 120 目的 / 最大扇入 2 → 属 B 类，不适用一位一 PIP。
- 【未测】无板级 JTAG 回读流，所有结论基于 `write_bitstream` 产物。

## §8 复现命令

```bash
# 离线：算帧窗（0 构建）
python step03_pip/block_info.py --tile INT_INTERFACE_L_X14Y349 --tile INT_INTERFACE_L_X14Y299 \
       --tile BRAM_INT_INTERFACE_L_X50Y349 --tile IO_INT_INTERFACE_L_X32Y349

# 远端：脚本必须 LF，走 bash -s 管道（ssh 落到 Windows 主机 + WSL）
cmd /c 'ssh -o ConnectTimeout=10 fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < step03_pip\_t40_g1.sh'
```

报告自检行（缺任一项即 unverified）：`pred=<24> act=<24> missing=0 extra=0 窗外位=<n> PIP列表一致=<是/否>`。
