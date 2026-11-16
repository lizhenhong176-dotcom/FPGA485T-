# 主线进度复盘 + 下一步建议（2026-11-16 现场核对版）

> 本报告按 `PROMPT_PROGRESS_REVIEW.md` 的提示词执行。所有数字来自 `PROJECT_WORK_SUMMARY.md` / `SINGLE_SOURCE_OF_TRUTH.md` / `STATUS.md` / `repro.py`，并已在现场用命令复核。
> **重要**：现场复核发现文档口径与实跑状态不一致，已在 §1.4 和 §2 中如实标出。
> **【2026-11-16 后续更新】** §1.4 的 11/12 失同步**已修复**：`repro.py` 现为 **12/12 PASS**。
> 修复细节、证据强度分级（INT_R 为间接推出）与限制见 `STATUS.md` §212。下文 11/12 相关表述为当时现场快照，保留作为历史记录。

---

## 一、主线进度总结

### 1.1 一句话阶段判断

主线「INT tile PIP 复用编码规律」已从「逐位列表」升级为「可生成的结构」，进入**收口 + 论文交付**阶段（`PROJECT_WORK_SUMMARY.md` §0/§1）；但本次现场自检为 **11/12 PASS**，不是文档记录的 12/12 —— 有一条长线族派生表失同步（§1.4）。

### 1.2 按三类的确切进度

**已闭合（有数字、可复现）**

| 成果 | 数字 | 出处 / 命令 |
|---|---|---|
| 帧系统 | 50,176 帧；器件区块 1,183 块 / 50,148 帧（100%，排除 28 overhead） | `SINGLE_SOURCE_OF_TRUTH.md` §1.11；`repro.py -k frames.full` |
| `site_frames` | 36,799,100 行 / 9,156 帧（全量，本机） | `PROJECT_WORK_SUMMARY.md` §2；`build_site_frames.py` |
| INT 族 / feature | 172 / 3,634（INT_L、INT_R 各一份） | `law_cells`；`repro.py -k verify.INT_L` |
| 24 源 mux | 64 族 / 1,536 feature / 每源 5 格，**1,536/1,536** | `repro.py -k mux.law` |
| BEG | 96 族 / 1,920 feature / 每源 2 格，**32/32 完全二分** | `repro.py -k beg.shape` |
| 行序生成 | 16 码 × 4 族；重建 **32/32**；信息量 147→20 bit | `STATUS.md` §167；`repro.py -k row.generator`（2048/2048） |
| 列序 | 512 槽 → 32 bit（32×）；两侧 64/64 同 | `STATUS.md` §189/§190 |
| 基址律 | `base(tile)=band(y)*5246+offset(col)`；6,667/6,668；右端 433 命中 0 不符 | `STATUS.md` §201/§202 |
| CLB 站内位 | INIT 256/256；FFSYNC/CLKINV/LATCH/AFFMUX/AOUTMUX/SR/PRECYINIT 已定位 | `CLB_BIT_SPEC.md`；`T82–T87` |
| ECC | 154 个位置签名，字节级可复原 Vivado 文件 | `T8`；`bitgen.py` |
| 一键自检 | 现场实跑 **11/12 PASS**（约 9 s），非文档 12/12 | `python repro.py` |

**数据缺口（有数据可补，非原理障碍）**

| 缺口 | 现状 | 依据 |
|---|---|---|
| 长线 82 条 feature | L2 完整 48、L3 查表 34（LV_L0 10 / LV_L18 12 / LH0 12），**无纯公式** | `STATUS.md` §203–§206 |
| `LV_L9` / `LH6` 驱动源 | 2 条，只作源无驱动族 | `STATUS.md` §173 |
| INT 实例覆盖 | **12,565 / 53,100 = 23.66%**，现场复核 residual=0 | `repro.py -k tiles.instances` |
| HCLK_CMT 剩余源 | 32 源未闭合 | `PROJECT_WORK_SUMMARY.md` §6.1 |
| CLB 零星位 | `A5FF`/`A5FFMUX`、SMEM 三位、`PRECYINIT` 另两档，约 6 条 | `T85–T87` |
| 整条流 CRC | 标准多项式反解 64 组全败；按真实包序重建未做 | `STATUS.md` §152 |

**方法上限（原理上够不着，不要投）**

| 上限 | 原因（原文口径） |
|---|---|
| 行轴「类内成员序」 | 布局器自由选择，模板源列表字典序不含引脚序 ⇒ 只能当数据 + S4 链压缩（`PROJECT_WORK_SUMMARY.md` §6.2） |
| BRAM 180 条地址 mux | 档位由布局器按物理邻接自动选，无法受控差分隔离（§6.2） |
| 其它类型的「复用」 | DSP 280 / BRAM 111 / CLB 358 源超大 fan-in，不是 24 源 6×4，行序律不迁移（§6.2） |
| 长线配对由线名导出 | cell 是 `(family, wire)` 函数不是 `wire` 函数；配对靠 tile 内相对位置，名字不含位置（`STATUS.md` §205） |

### 1.3 四个覆盖率口径（不可互相替代）

| 口径 | 分子 / 分母 | 比例 | 含义 |
|---|---|---|---|
| 位级已知 | 3,634 / 3,634 | 100% | 每条 feature 的 cell 全在库、命中 0 不符。`repro.py verify.INT_L/INT_R` |
| 纯定律 | 3,456 / 3,634 | 95.10% | mux 1,536 + BEG 1,920，可由公式直接生成 |
| 可由公式或表重建 | 3,552 / 3,634 | 97.74% | 纯定律 + 长线 L2 乘积 48 + L3 查表 34 中可覆盖部分。`repro.py slots.coverage` |
| 实例级实测 | 12,565 / 53,100 | 23.66% | **实测覆盖的 tile 数**，不是「律成立的 tile 数」。现场命令已复核 |

**为什么不能互相替代**：位级 100% 是「每条 feature 有 cell」；纯律 95.10% 是「cell 能由线名算出来」；97.74% 是「加上查表能重建」；23.66% 是「采到了多少 tile」。论文里若把 23.66% 说成「律只对 23.66% 的 tile 成立」是错的 —— 残差 0 说明观测到的 tile 全部服从同一套规则。

**一个重要旁证（本次现场做的）**：随机抽 8 份小设计做覆盖并集，只有 **306 / 53,100 = 0.58%**，而单份 `cov2.bit` 就有 23.66% ⇒ 提升实例覆盖靠「刻意铺开布局的设计」，不是靠堆位流数量。

### 1.4 现场发现：文档 12/12 已过期，实跑 11/12

```
repro.py OVERALL: FAIL (1/12 failed: verify.INT_L)
不符: ('LV_L18', 'LH12',
      law_cells  =(fo,par,bit): [(0,1,30),(1,1,30)]
      beg_families.json       : [(1,0,2),(1,0,8)])
```

**根因已定位**：`STATUS.md` §207 第 7704–7707 行明确记录 —— `LV_L18 ← LH12` 的旧表值 `(1,0,2)+(1,0,8)` 是**错的**，实测为 bit30（`word0+60`），正样本 41/42、负样本 0/1050。随后 `law_cells` 被更正为 bit30 的新值，但两个**派生表没有同步**：

- `v7re/steps/beg_families.json` → `LV_L18.sources.LH12 = [[1,0,2],[1,0,8]]`（旧值）
- `v7re/steps/longline_lookup_table.json` → `LV_L18.LH12 = [[1,0,2],[1,0,8]]`（旧值）

`verify_all_pip.py:142` 用 `beg_families.json` 当「期望值」与 `law_cells` 比对，因此报 1 条不符。这不是新 bug，是**更正抄 wrote through 没做全**。`STATUS.md` §207 第 7720–7721 行其实已经警告过下游脚本在 LV_L18 上会产出错误位 —— 本次实跑证实该警告成真。

---

## 二、识别真正的下一步

### 2.1 候选清单与筛选

| 候选 | 对论文价值 | 可执行条件 | 成本 | 结论 |
|---|---|---|---|---|
| **A. 同步长线派生表，恢复 12/12** | 高：论文所有数字都基于 `repro.py`，11/12 会让"可复现"失效 | ✅ 零机时、数据全在本地 | 约 5–10 分钟 | **推荐** |
| B. 提升实例覆盖 23.66% | 中高：支撑"全器件通用"表述 | ⚠️ 需新 Vivado 设计刻意铺开布局 | 每批 32 路并发，数小时 | 次选 |
| C. HCLK_CMT 剩余 32 源 | 中：时钟章节完整度 | ⚠️ 需 Vivado 构建 | 数十次构建 | 后置 |
| D. 整条流 CRC | 高（可加载位流）但**非论文主线** | ❌ 需按真实包序重建 + 重拟合，路线 B 已证伪 | 数天 | 不建议现在做 |

### 2.2 为什么是 A 而不是其它

1. **它是唯一一个"现在就是坏的"项**。`PROJECT_WORK_SUMMARY.md` _header 与 §4 都写 `repro.py 12/12 PASS`，但实际是 11/12；论文交付前若不同步，审稿人一跑 `python repro.py` 就会 FAIL，所有引用数字的可信度一起塌。
2. **零机时、零新数据**。不需要碰 Vivado、不需要远端、不需要新构建。
3. **B/C 的前提是先有一个干净的自检基线**。否则改完覆盖表后无法判断"是不是又引入了一个 LV_L18 类失同步"。
4. D 属于方法上限区（`STATUS.md` §152 已标暂停），且不影响任何分析结论。

### 2.3 完成标准（可判定）

1. `v7re/steps/beg_families.json` 和 `v7re/steps/longline_lookup_table.json` 中 `LV_L18.LH12` 更新为 `[[0,1,30],[1,1,30]]`（与 `law_cells` 一致），或让 `verify_all_pip.py` 把长线族路由到 L3 查表并标为「查表」而非「公式」（后者更贴合四级可解释性口径，推荐）。
2. `python repro.py` → `OVERALL: PASS (12/12)`。
3. `python repro.py -k verify.INT_L` → `3634/3634，不符 0`。
4. `SINGLE_SOURCE_OF_TRUTH.md` / `PROJECT_WORK_SUMMARY.md` 的「12/12 PASS」从"文档声明"变成"现场实测"，并在 `STATUS.md` 新增一节记录这次同步（记 §208 或最大号+1，注意 `STATUS.md` §185 有重号待清）。
5. 顺带在 `fasm2bit.py` / `decode_law.py` / `bitwriter.py` 给 LV_L18 加显式告警或走 §206 的 A/B 规则（这是 `STATUS.md` §207 第 7720–7721 行已经提出但未执行的整改）。

**预计耗时**：数据同步 5–10 分钟；三个下游脚本的告警整改 20–30 分钟；总计不超过 1 小时，不耗机时。

---

## 三、诚实边界

### 3.1 方法上限（不建议投入）
见 §1.2「方法上限」表：行轴类内成员序、BRAM 180 条地址 mux、其它类型 111–358 超大 fan-in、6×4 的 LOGIC/GFAN/BOUNCE 行归属、长线配对由线名导出、整条流 CRC 的路线 B。

### 3.2 作废口径（不得引用）
来自 `PROJECT_WORK_SUMMARY.md` §8 / `SINGLE_SOURCE_OF_TRUTH.md` §4：

1. 「48 族 36 种行序」—— 三种口径都复现不出（`STATUS.md` §167）
2. T13 INIT 表 —— 缺 `LOCK_PINS`，索引是当次分配（`T18`）
3. 「24 源接口」 —— 接口是 24 对 1:1 直通（`T90`）
4. word 50 是配置位 —— 实为帧级 ECC（`P1` / e0–e5）
5. 「4.3% 残余可配置 PIP」 —— 接口 342,000 实例不可配置（`T90`）
6. CLB 151 条是可配置 PIP —— 全是 ppip（`T68`/prjxray）
7. 「本机 site_frames 残缺 19,819,900 行」 —— 现场为 36,799,100 行全量
8. 「103 条」 —— 正确 108（44 always + 64 default，`STATUS.md` §198）
9. 「34 条完全无法生成」 —— 正确 48 完全 + 32 近乘积 + 2 孤立（`STATUS.md` §203–206）
10. 「far_bands 覆盖全部 50,176 帧」 —— 只覆盖 FAR_BLOCK_0 的 36,708 帧（73.2%），全量靠 `frame_blocks_full`

### 3.3 本次现场核对的证据
```
$ python v7re/scripts/all_int_tiles_check.py --bit _tilecov2/cov2.bit
累计覆盖 INT tile 实例: 12565 / 53100（23.66%）；落在格宇宙外的: 0；PASS

$ python repro.py
OVERALL: FAIL (1/12 failed: verify.INT_L)
不符: ('LV_L18','LH12',法[(0,1,30),(1,1,30)],查表[(1,0,2),(1,0,8)])

$ 8 份不同布局位流并集
累计覆盖 INT tile 实例: 306 / 53100（0.58%）；residual=0
```

---

## 四、结论

主线科学部分已收口到「四级可解释性」：纯公式 95.10% + 乘积置换 1.32% + 纯查表 0.94% + 零配置位 108 行，边界是「特征是否发生在单 tile 内」。

**当前最该做的不是继续推新科学边界，而是把 `LV_L18/LH12` 的派生表失同步补上，让 `repro.py` 真正回到 12/12**——这是论文交付的前置条件，且是零机时的。之后才是 B（实例覆盖）与 C（时钟源），D 明确不做。

---

*提示词：`PROMPT_PROGRESS_REVIEW.md`（经 prompt-optimizer `user-prompt-professional` 优化，硬数据附录人工补入）*
