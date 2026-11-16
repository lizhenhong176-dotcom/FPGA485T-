# 单一真源表（SINGLE SOURCE OF TRUTH）

> 目的：论文/报告里出现的**每一个数字**都在本表登记一次，带口径、命令、状态。
> 写论文、交给外部 Agent、对外汇报，一律只引用本表的行号。
> 最后更新：2026-11-13 22:35（全部数字为当日重跑结果）

## 0. 状态标记

| 标记 | 含义 |
|---|---|
| ✅ | 已用命令现场验证，可复现 |
| 📊 | 数据事实（从库/文件读出），不是推导 |
| 🧩 | 推断/模型，有证据但未闭合 |
| ❌ | **作废**，禁止引用（见 §4） |

---

## 1. 器件与位流基础

| # | 数字 | 值 | 口径 | 命令/出处 | 状态 |
|---|---|---|---|---|---|
| 1.1 | 目标器件 | `xc7vx485tffg1157-3` | 全项目唯一器件 | `STATUS.md` 首节 | 📊 |
| 1.2 | 配置帧总数 | **50,176** | `frame_index` 0..50,175 | `select count(*) from frame_map` | ✅ |
| 1.3 | 行开销帧 | **28** | `far IS NULL`、`is_overhead=1` | `select count(*) from frame_map where far is null` | ✅ |
| 1.4 | 每帧数据字 | **101**（word 0..100） | 32 bit/word | `frames_from_bit()` 返回 50176×101 | ✅ |
| 1.5 | `word 50` | **帧级 ECC/校验字**，不是配置位 | 数据字变则同帧 word50 变（e0–e5 六设计） | `STATUS.md` §17 | 🧩 |
| 1.6 | `site_frames` 行数 | **36,799,100** | 763 block × 12 frame_off × 各 site | `select count(*) from site_frames` | ✅ |
| 1.7 | `site_frames` 覆盖帧 | **9,156** | `count(distinct frame)` | 同上 | ✅ |
| 1.8 | 全器件可配置 PIP 实例 | **207,253,149** | 按 tile 实例 × PIP 数累加 | `STATUS.md` §170 | 📊 |
| 1.9 | 其中 INT 占比 | **198,434,700 = 95.7%** | INT_L/INT_R 各 26,550 × 3,737 | 同上 | 📊 |
| 1.10 | `far_bands` 覆盖（历史口径） | 1,078 区块 / 36,708 帧 = **73.2%** | 仅 `FAR_BLOCK_0`；**已被 1.11 取代，勿单独引用** | `select count(*), sum(frames) from far_bands` | ❌ 作废 |
| 1.11 | 全器件区块表 `frame_blocks_full` | **1,183 区块 / 50,148 帧 = 100%**（+28 overhead = 50,176） | 类：CLB 777 / INT 245 / CLOCK 28 / BOUNDARY 14 / UNDETERMINED 14 / **BT1 105**；`band → (top,row)`：0..4→(0,0..4)、5→(1,0)、6→(1,1) | `python v7re/scripts/build_frame_blocks_full.py --check` | ✅ |
| 1.12 | `FAR_BLOCK_1` 内容 | **13,440 帧在 36 份采样位流中恒为 0** | 30 随机 + 6 定向设计逐帧统计，非零字合计 0；用途未定 | `STATUS.md` §186 | ✅ 观测 |

## 2. INT 路由 PIP 复用规律（主线）

| # | 数字 | 值 | 口径 | 命令 | 状态 |
|---|---|---|---|---|---|
| 2.1 | INT tile 实例 | **53,100** | INT_L 77×350 + INT_R 77×350 | `select tile_type,count(*) from law_tiles group by 1` | ✅ |
| 2.2 | family 数 | **172 / 侧** | family = PIP 的目的 wire | `verify_all_pip.py --tile-type INT_L` | ✅ |
| 2.3 | feature 数 | **3,634 / 侧** | feature = (family, source) | 同上 | ✅ |
| 2.4 | (feature,cell) 记录 | **8,900** | sense=1 | `select count(*) from law_cells where tile_type='INT_L' and sense=1` | ✅ |
| 2.5 | 不同 cell 数 | **1,598** | `(frame_off,parity,bit)` 去重，sense=1 | 同上 `count(distinct ...)` | ✅ |
| 2.6 | sense=0 行 / 不同 cell | **3,264 行 / 280 格** | 与 sense=1 的 280 格**完全重合** ⇒ 无独立清除位 | `STATUS.md` §142 | ✅ |
| 2.7 | mux 区族数 | **64** | 每族 24 源 | `gen_slots.py` | ✅ |
| 2.8 | BEG 区族数 | **96**（含 32 个变体规则） | `K(4,5)×14 + K(5,4)×18` | `beg_families.py --report` | ✅ |
| 2.9 | BEG 形状 | **32/32 完全二分且可重建**，cover **640** feature | 源=边、格=节点 | 同上 | ✅ |
| 2.10 | 覆盖（按槽位表可生成） | **3,552 / 3,634 = 97.7%** | 定律 3,456 + 复合组模型 96；余 **82** 条无公式 | `gen_slots.py` 末三行 | ✅ |
| 2.11 | 覆盖（按整体校验无不符） | **3,634 / 3,634 = 100%** | 表+定律联合预测 vs 实测格 | `verify_all_pip.py` | ✅ |
| 2.12 | 不含 mux/BEG 的族 | **12**（6 长线 + 6 其它） | 长线 82 个 feature | `gen_slots.py` 首行 | ✅ |
| 2.13 | mux 区精确命中 | **1,536 / 1,536，0 不符** | 64 族 × 24 源 | `pip_reuse_law.py --verify` | ✅ |
| 2.14 | 两侧一致性 | INT_L 与 INT_R `3,634/3,634` 相同 | 需 `--normalize` 去 `_L/_R` | `verify_all_pip.py --normalize` | ✅ |
| 2.15 | 实例级覆盖率（抽样） | **12,565 / 53,100 = 23.66%**，64,686 位，残差 **0** | 单 bitstream `cov2.bit` | `all_int_tiles_check.py --bit _tilecov2/cov2.bit` | ✅ |
| 2.16 | 行序生成律 | **16 种编码 × 4 族**；`p_{j+1}=g_j∘p_j`；**2,048/2,048**，随机 200 对 0 不符 | S4 置换生成 | `step03_pip/gen_mux_rowlaw.py` | ✅ |
| 2.17 | 位坐标公式 | `minbit = 8*(i%4)+2*(i//16)+2*((i//8)%2)`；`parity = 1 if (i%8)>=4` | i = 族内源序号 | `STATUS.md` §53 | ✅ |
| 2.18 | 列码 = 线长类别 | `1/2 → DOUBLE`、`7/11 → SINGLE`；**744/744** 与 **5,832/5,832** 全中 | 两个独立样本集 | `STATUS.md` §175 | ✅ |
| 2.19 | 行 = 类内成员序 | **不可导出**（16 种/36 种历史口径已作废，见 §4） | 逐 mux 数据 | — | 🧩 |
| 2.20 | 「6×4」的含义 | **6 = 4 线源槽 + 1 旁路槽 + 1 本地槽**；每组 4 含一个长度类（**256/256 组零异常**） | 64 族实测 | `STATUS.md` §174/§175 | ✅ |
| 2.21 | 长线族 | 6 族 / **82 源 / 每源恰好 2 格**；**48/82 = 58.5%** 落在完整乘积网格（`LH12` 4×3、`LVB_L0` 6×3、`LVB_L12` 3×6） | 2-着色二分 | `step03_pip/_q_longline_pairs.py` | ✅ |
| 2.22 | 长线族验证 | 反解基址后 **23/23** 长线 PIP 预测格在位流中为 1 | `_n1.bit` | `int_base_solve.py` | ✅ |
| 2.23 | 长线续接边 | **26 条**（去重）；无「段数/跨度」独立编码 | 跨 N tile = N 次续接 | `STATUS.md` §173 | 📊 |
| 2.24 | tile 基址反解 | `_n1` 的 392 个 INT tile 中 **258 个唯一解**（2 多解 / 5 无解）；行间差 **5,246** | 真实位流反解 | `int_base_solve.py` | ✅ |

## 3. 其它 tile 类型（边界，不是主线）

| # | 数字 | 值 | 口径 | 状态 |
|---|---|---|---|---|
| 3.1 | `INT_INTERFACE_L/R` | 各 **24 条 PIP、24 目的、每目的 1 源 = 1:1 直通**，**无配置位**（`law_cells` 0 行、`ppips` 0 行、prjxray 无此文件） | 4,550 + 3,850 实例 | ✅ |
| 3.2 | `INT_FEEDTHRU_1/2` | PIP 数 **0** | 525 + 600 实例 | ✅ |
| 3.3 | 接口类实例合计 | **342,000 个 = 纯 1:1 直通（不可配置）** ⇒「还有 4.3% 可配置 PIP 没做」不成立 | — | ✅ |
| 3.4 | DSP | 基本 one-hot（1–2 格）；`CECTRL/CEM/CEP/CEC` 为零值默认 | 79 族 | 📊 |
| 3.5 | BRAM | EN/RST 各 2 格、REGCE 各 4 格（RAMB36 = 两 RAMB18 半区配对）；**180 条地址 mux 无法隔离** | 63 族 | 📊 |
| 3.6 | CLB ppip | `CLBLM_L 151`（hint 58 / always 93）、`CLBLL_L 146`、`BRAM 794`、`DSP 560` — 全为 ppip | `ppips` 表 2,958 行 | ✅ |
| 3.7 | 各类型多源 fan-in | INT 最大 **24**；BRAM 111、DSP 280、CLBLM 358、CLBLL 338 ⇒ **24 源 mux 是 INT 独有** | 636 族普查 | ✅ |
| 3.8 | `HCLK_L` | 20 目的 / 200 PIP = 8 个 1:1 + **12 个 16 源 crossbar**；工具只用过 4 个源 | T91 | 📊 |
| 3.9 | `HCLK_CMT` | 编码 **per 列 + per 类型常量**（MMCM X0 列 30/30、X1 列 30/30、跨列 4/30；PLL X0 292/292、跨列 0/292）⇒ 全器件 4 套布局 | T70 | ✅ |
| 3.10 | `CK_BUFHCLK` | 12 个 `BUFHCE_X0Y72..Y83` ↔ `CK_BUFHCLK0..11` **严格一一对应**；编码 = 半区位 `(base+2,48,21)` + 6 槽位 one-hot | T71 | ✅ |
| 3.11 | CCIO | 96 个时钟脚里只有 **8 个**走 CCIO；索引 = `bit(base+1,51,27) \| bit(base+1,51,28)<<1`（**8/8 精确**） | T72/T73 | ✅ |
| 3.12 | 链式 `MUX_CLK_k → CK_IN_j` | 264 份位流中 **0 次使用 ⇒ 不可达** | 模板有、工具不用 | ✅ |

## 4. 作废清单（禁止引用）

| # | 作废内容 | 原因 | 取代者 |
|---|---|---|---|
| 4.1 | 「48 族 36 种行序」 | 三种口径都复现不出（IMUX 单独 12 组、含 BYP/FAN 16 组） | §2.16 的 16 种 × 4 族 |
| 4.2 | T13 的 y=20 八 LUT INIT 表 | 缺 `LOCK_PINS`，索引是当次分配 | T19/T21 带锁引脚表 + 闭式公式 |
| 4.3 | 「INIT 表随行变化」 | 实为 LOCK_PINS 缺失导致的索引置换 | 行不变性已验证 |
| 4.4 | 「24 个未测 IMUX 是 CLBLM 专属」 | 48/48 IMUX 全可达 | — |
| 4.5 | 「INT_INTERFACE 是 24 源 mux」 | 实为 1:1 直通 | §3.1 |
| 4.6 | 「word 50 是配置位」 | 帧级 ECC | §1.5 |
| 4.7 | 「还有 4.3% 可配置 PIP 未做」 | 接口类 342,000 实例全为 1:1 直通 | §3.3 |
| 4.8 | 「CLB 站内 151 条是可配置 PIP」 | 全是 ppip | §3.6 |
| 4.9 | 本机 `site_frames` 残缺（19,819,900 行 / 6,104 帧） | 该状态已不存在，现为全量 | §1.6 |

## 5. CLB 位级规格（可直接给解码器用）

| # | 项目 | 值 | 状态 |
|---|---|---|---|
| 5.1 | INIT 公式（4 LUT × 64 位 = 256 格） | `frame_off = 34+(k&1)-2*((k>>3)&1)`；`word = 40(A/B)/41(C/D)`；`bit = B_L-4*(k>>4)-((k>>1)&3)`；`B_A=B_C=15, B_B=B_D=31`；对表 **256/256 相符** | ✅ |
| 5.2 | 解码器对拍 | **6/6** 与设计意图一致 | ✅ |
| 5.3 | `FFSYNC` | `(0,41,16)`：同步=1 / 异步=0 | ✅ |
| 5.4 | `CLKINV` | `(1,41,19)` | ✅ |
| 5.5 | `LATCH` | `(30,41,0)` | ✅ |
| 5.6 | `AFFMUX`（FF.D 源） | `(30,40,0)`：bit=1→O5 / 0→O6（**不是 4 位 one-hot**） | ✅ |
| 5.7 | `AOUTMUX`（LUT 输出选择） | 4 位字段，两码全不同：O5 `(3,40,8)(4,40,10)(6,41,4)(7,41,5)`；O6 `(3,40,4)(4,41,10)(6,41,8)(7,40,5)` | ✅ |
| 5.8 | SR 使用 | 3 位 `(1,41,2)(1,41,3)(1,41,9)` | ✅ |
| 5.9 | CE 使用 | `(1,41,7)`（强候选）+ 目标 `(23/24/25,41,0)` | 🧩 |
| 5.10 | `PRECYINIT` 常量 1 档 | `(0,40,12)` | ✅ |
| 5.11 | 零配置位 | LUT 输入 mux、BYP 旁路、CE/CLK/SR 的**源选择** | ✅ |
| 5.12 | 未拿到 | `A5FF/A5FFMUX`、SMEM 的 `WEMUX/WA7USED/WA8USED`、`PRECYINIT` 另两档 | ⏳ |

## 6. CRC / ECC

| # | 项目 | 值 | 状态 |
|---|---|---|---|
| 6.1 | `crc_table.json` 条目 | **64** | ✅ |
| 6.2 | 单帧签名 | **3,200 条**（`(0..15) × word × 50 行`），全 `add=1, rem=0` | ✅ |
| 6.3 | 签名依赖 | **绝对帧位置**（`SLICE_X12Y200` 的 `0x6d7922f5` ≠ anchor `0xcc97191d`） | ✅ |
| 6.4 | 张成空间维数 | **31 维**（留一 96/96、跨帧 13/13 与 14/14） | ✅ |
| 6.5 | 标准多项式反解 | **失败**：8 poly × 2 方向 × 4 下标约定 = 64 组全败 | ❌ |
| 6.6 | UG470 CRC 语义 | 覆盖自 RCRC 后；尾部第二 CRC 包恒为 **`E3AD7EA5`** | ✅ |
| 6.7 | ECC 位置签名 | **154 个**（T8）；`ecc_table.json` 54 条 | 🧩 |

---

## 7. 待对账（已知不一致，写论文前必须处理）

| # | 问题 | 现状 | 处理 |
|---|---|---|---|
| 7.1 | 不同 cell 数 **1,602 vs 1,598** | `gen_slots.py` 报 1,602；`law_cells` sense=1 去重 1,598（差 4 格） | 二选一并标注来源；优先用库查询值 1,598 |
| 7.2 | 小节编号重复 | **实测只有 2 处真重复**（`173` 两次、`180` 两次），已改为 `173a` / `180a`；现状 206 个数字小节、编号唯一，索引见 `STATUS_SECTION_INDEX.md`。~~此前记的「38 个重复」是统计 bug：正则只抓整数前缀，把 `87.1`/`88.2` 这类小数节误算成 `87`/`88`。~~ | 已修 |
| 7.3 | 两个「覆盖率」口径 | 97.7%（可生成）vs 100%（无不符） | 论文必须同时给出并解释差集 82 |
| 7.4 | `column_offsets.x`（420 行，0..120 步长 20）命名空间未定 | 与 `far_col`/`grid_x` 关系未查 | 纸面上不要引用 |
| 7.5 | INT 块帧 26/27 未归属 | 帧 1019 恒 190 位、帧 1018 0..52 位随设计变；三个接口用量相同的设计位不同 ⇒ 非接口 | 写进 limitation |

## 8. 一键复跑（复现入口）

**主入口（推荐）**：`python repro.py` —— 跑 12 项检查，逐项打印 expect / 耗时 / PASS-FAIL，末行 `OVERALL: PASS (12/12)`。
2026-11-16 实测：**12/12 PASS，总耗时约 9 s**（`tiles.instances` 占 6–7 s）。`python repro.py -k mux` 可只跑子集。
> 2026-11-16 一度为 11/12（`verify.INT_L` 的 `LV18/LH12` 派生表失同步），已按 §212 修复；
> 其中 INT_R 的同名行由 T66「两侧格集合全等」间接推出、非直接位流实测，详见 `STATUS.md` §212。

单项命令（`repro.py` 内部就是跑这些）：

```bash
# 槽位生成 + 覆盖率
python step03_pip/gen_slots.py

# 两侧整体校验（应输出 3634/3634、0 不符）
python v7re/scripts/verify_all_pip.py --tile-type INT_L
python v7re/scripts/verify_all_pip.py --tile-type INT_R --normalize

# mux 区对账（应 1536/1536）
python v7re/scripts/pip_reuse_law.py --verify

# BEG 形状（应 32/32 完全二分）
python v7re/scripts/beg_families.py --report

# 行序生成律（应 2048/2048）
python step03_pip/gen_mux_rowlaw.py

# 实例级抽样（应 23.66%、residual 0）
python v7re/scripts/all_int_tiles_check.py --bit _tilecov2/cov2.bit

# 单元测试（应 15 passed）
python -m pytest v7re/tests -q -p no:cacheprovider
```

## 9. 术语表（外部 Agent 必读）

| 术语 | 定义 | 易错点 |
|---|---|---|
| `family` | **PIP 的目的 wire**（Vivado/prjxray 真名），不是自造概念 | 命名空间是 **tile_type 级**，不含 col/y |
| `feature` | `(family, source)` 二元组 | 一个 family 有多个 feature |
| `cell` | `(frame_off, parity, bit)` 三元组 | 整数帧号 ≠ `frame_off`；INIT 表用**绝对帧** |
| `frame_index` | 0..50,175 的全局帧号 | 一切结论最终回到这里 |
| `grid_x / grid_y` | Vivado tile 坐标（412 × 365） | **不是列号**；`(grid_x,grid_y,type)` 才唯一 |
| `far_col / far_band` | `far_bands` 的 154 列 × 7 带 | 与 `grid_x` **不是 1:1**，禁止混用 |
| `clb_col` | `clb_blocks` 的 111 列 | 与 `far_col` 是 **111↔111 严格 1:1**（已验证） |
| `band` | 三套含义（`clb_blocks.band` / `far_bands.band` / `band_by_region`） | **实证撞名**，映射 0→6、1→5、2→0… |
| `word 50` | 帧级 ECC，不是配置位 | 解码时跳过，重写时必须重算 |
| `ppip` | 硬连线/暗示连接，**没有配置位** | 不要计入「可配置 PIP」 |

## 2.9 INT 配置位的可解释性分级

| 级 | 含义 | 数 | 命令/文件 | 状态 |
|---|---|---|---|---|
| L1 纯公式 | 槽位由线名（方向+长度）决定 | 3,456 / 3,634 = 95.10% | `python step03_pip/gen_slots.py` | ✅现场验证 |
| L2 乘积 + 置换 | `A×B` 结构成立，配对需置换表 | 48 条（`LH12` 12 / `LVB_L0` 18 / `LVB_L12` 18） | `v7re/steps/longline_product_model.json` | ✅现场验证 |
| L3 纯查表 | 只能存 feature→2 cell | 34 条（`LV_L0` 10 / `LV_L18` 12 / `LH0` 12），21 个不同 cell | `v7re/steps/longline_lookup_table.json` | ✅现场验证 |
| L4 零配置位 | ppip / 单扇入 | 108 行（44 always + 64 default） | `v7_law.sqlite:law_ppips` | 📊数据事实 |
| 位级已知 | 每条 feature 的 cell 全在库、命中 0 不符 | 3,634 / 3,634 = 100% | `python repro.py -k verify` | ✅现场验证 |

判定标准：**槽位能否由线名确定**。BEG 一跳在 tile 内完成（方向+长度足够）⇒ 公式；长线是跨 tile 续接，配对取决于段在 tile 内的相对位置（名字不含位置）⇒ 最少要置换表，部分连 `A×B` 都不成立。把 BEG 的 `geo_class`/`dir_token` 预测器套到 6 个长线族，6/6 失效（§205）。
