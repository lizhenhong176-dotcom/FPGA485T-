# T55 对象判定：上一轮「跨 tile 验证」测的是 CLB 配置位（LUT INIT），不是 PIP 开关盒

日期：2026-11-08　作者：产品（需求澄清）　复核脚本：`v7re/scripts/t55_object_check.py`

标注约定（`AGENTS.md` 纪律）：【硬件事实】= 手册/器件结构级；【数据事实】= 本项目实测；【推断】= 由数据反推。

---

## 1. 判定结论（直接回答用户原话）

用户原话（只读锚点，sha256 56d43e04…）：「我想测试的是同类tile 现在做的不是pip开关盒吗」

**结论：不是 PIP 开关盒。上一轮「同类型通过 / CLBLL 不通过」测的是 LUT6 的 INIT 真值表数据位（CLB 配置位），属于 CLB tile 内部的 LUT 内容存储，与 INT tile 的 PIP mux 选择位是两个不同的配置对象、不同的帧、不同的编码形态。**

| # | 判定项 | 结论 | 证据 |
|---|---|---|---|
| J1 | 实验的自变量是什么 | **只有 LUT6 `INIT`**：`0` → `0xDEADBEEFCAFEBABE` | `_xcheck.sh:8`（`#(.INIT(64'h$INIT))`）、`:30-33`（四个构建只换 INIT）；LOC/BEL/LOCK_PINS 全部固定（`:14-16`） |
| J2 | 差异落在哪些帧 | 每对构建仅 **4 帧**，且全部落在 **CLB 块内 base+32..35** | `_xcheck_local` 四个 .bit 本地复算：c20 → 31956..31959（base 31924）、c08 → 31712..31715（base 31680） |
| J3 | 差异的位形态像不像 PIP | **不像，是 1:1 数据面**：payload 46 位 == popcount(INIT)，word 50 是帧级 ECC | 同上；`popcount(0xDEADBEEFCAFEBABE)=46`，c20 的 word40 位数为 7/14/10/15、c08 为 10/15/14/7，合计均 46；word50 各帧 2–5 位 |
| J4 | 有没有 INT 块帧变化 | **没有**，全片 50,176 帧中仅这 4 帧变化 | 同上；差异帧集合相对两个块基址分别为 +32..+35，无任何 INT 块（26 帧/块）帧进入差异集合 |
| J5 | 该对象在 law 库里是什么形状 | LUT INIT = 64 feature : 64 独立格（**1:1，纯数据**） | `E:\v7work\model\v7_law.sqlite` 的 `clb_cells`：`src_wire like 'INIT%'` 共 2048 行 = 32 个 (tile_type,LUT-family) × 64；例 `CLBLL_L / SLICEL_X0.ALUT` = 64 feature / 64 格 |
| J6 | PIP 在 law 库里是什么形状 | 一个 mux 的「N 选 1」只占 **7–10 个格**，格数 ≪ 源数（小码字段） | `law_cells`（tile_type=INT_L）：172 个 family，source 数 {24:64, 20:96, 16:6, 12:3, 18:2, 10:1}，共用 sense=1 格数 {9:100, 10:64, 8:6, 7:2}；每 feature 的 sense=1 格数仅 2 或 4 |

J5 与 J6 的对比是本节最强的一条：**INIT 是「换一个位就换一格数据」的 1:1 存储面，PIP 是「一个 mux 的 N 条源共享 7–10 个格」的组合编码面。** 二者在 law 库里的形状就不一样，物理上不可能混为一谈。

结论一句话：**这次跨 tile 验证的通过/失败，衡量的是「LUT INIT 索引表能否跨 tile 复用」，不是「PIP 开关盒能否跨 tile 复用」。**

---

## 2. 术语对齐：用户说的「PIP 开关盒」对应哪个对象

【数据事实】本项目已定稿的术语（`v7re/steps/PIP_ADDRESS_ENCODING_LAW.md:41-44`）：

- **family** = PIP 的目的 wire（mux 输出）
- **feature** = (family, source) 一条可选择的连接
- **cell** = (frame_off, parity, bit) 一个配置位
- **grid slot** = (row, colcode)，源在 6×4 网格中的位置

【硬件事实】INT tile 的 PIP 是「布线开关」：一条 `<track>END → IMUXx` 的选择由 mux 的一组配置位决定（7 系列可编程互连点）。它住在 **INT tile 的 26 帧块**里（`step03_pip/CRAM_TERMS_AND_ADDRESSING.md:27`：INT tile frame_off 0..25）。

【数据事实】CLB tile 内部另有一组 site PIP（`IMUXx → A_pin`），住 **CLB tile 的 36 帧块**（`step03_pip/FPGA_UNITS_MUX_FULL.md:254`：以 SLICE_X8Y11 为例，CLB 块基址 31,680，IMUX 位在 off 16–25；其 INT_L_X6Y11 的 PIP 位在另一个块内；实测 181 条 PIP 的 cell 与 48 个 IMUX 的 cell 无交集）。

所以「PIP 开关盒」在数据上至少有两个候选落点（INT mux PIP / CLB site PIP），且**都不在 base+32..35 这 4 帧**里——那 4 帧是 LUT INIT 的存储行。这一点是本判定最硬的结构性隔离。

---

## 3. 逐条证据与可复核路径

### 3.1 实验输入的唯一性（J1）

`_xcheck.sh`（仓库根，1,505 字节）：

- `:8` 模块体 `.INIT(64'h$INIT)`
- `:14-16` `set_property LOC $SL [get_cells u0]` / `set_property BEL A6LUT` / `set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`
- `:30-33` 四个构建：`c20z/c20v` @ SLICE_X20Y20、`c08z/c08v` @ SLICE_X8Y20，INIT 分别 `0` 与 `deadbeefcafebabe`

除 INIT 外没有任何一个自由度被改动。`LOCK_PINS` 把 LUT 的 6 个输入脚固定在 A1..A6（CLB site 内的固定引脚映射），**它本身不锁布线**——布线是否真的没变，由 §3.2 的实测回答：全片只有 4 帧 CLB 帧变化、INT 块零变化，说明两次构建的布线逐位相同。因此「布线/PIP 变化」这一混淆因素是被**实测**排除的，不是被声明排除的。

### 3.2 位形态判据（J2/J3/J4）

复算命令（只读，无 Vivado）：

```
python v7re\scripts\t55_object_check.py
```

输出要点（本机 exit code 0）：

```
INIT = 0xDEADBEEFCAFEBABE, popcount = 46
c20 (CLBLM_R, SLICE_X20Y20) 块基址 31924
  差异帧: [31956, 31957, 31958, 31959] → 相对块基址: [32, 33, 34, 35]
  payload(word 40) 46 位 / ECC(word 50) 14 位
  形状判据（4 帧 @ base+32..35 且 payload==popcount）：PASS
c08 (CLBLL_L, SLICE_X8Y20) 块基址 31680
  差异帧: [31712, 31713, 31714, 31715] → 相对块基址: [32, 33, 34, 35]
  payload(word 40) 46 位 / ECC(word 50) 14 位
  形状判据（4 帧 @ base+32..35 且 payload==popcount）：PASS
```

三条互相独立的判据同时成立：

1. **帧数恒定 4**（一个 LUT 的 64 位 INIT 在 4 个 16 位行里）；
2. **payload 位数 == popcount(INIT)**（46），这是数据面 1:1 的签名；
3. **word 50 = 帧级 ECC**（14 位总量对 4 帧、每帧 2–5 位），说明改的是「数据字」，ECC 跟着重算。

PIP 的签名完全不同：一个 mux 的 N 选 1 只动 7–10 个格、每条 feature 动 2 或 4 个格，且 **sense=0 的位同时被清零**（`PIP_ADDRESS_ENCODING_LAW.md:158-159`：多 PIP 线性叠加 48 条时预测位 56/56 全 1、sense=0 位 48/48 全 0）。本次实验**没有出现任何 sense=0 位的清零**，也没出现「多个 mux 共享格」的形态。

### 3.3 坐标归属（J4）

块基址取自 `clb_blocks`（col16 band0 → 31680、col20 → 31752、col33 → 31924，与 STATUS §100 一致），而不是 `far_bands`。相对偏移 +32..+35 落在 CLB 块 36 帧的后段——这是 LUT INIT 的数据行区（`v7re/steps/clb_init_locked_map.json` 的 `group_off`：SLICEL 26、SLICEM 32；X20/X8 为偶数列 → X0 → inst_group=32）。

INT tile 的块在别的坐标上（每块 26 帧），差异集合与它**零交集**。

---

## 4. 混淆点清单（为什么容易误认为在测 PIP）

| # | 混淆点 | 澄清 |
|---|---|---|
| C1 | 两个实验都叫「跨 tile 验证」，都被说成「同类型/不同类型」 | 「跨 tile」是方法论（同一张表能否搬到另一个 tile），不是对象。对象必须单独声明：INIT 表 / PIP 表。 |
| C2 | 两者都会让「一帧里的若干位」变化 | 区别在**形状**：INIT 4 帧 × word40 数据 + word50 ECC，位数==popcount；PIP 7–10 格共享、含 sense=0 清零。判形状即可分离，无需信任叙述。 |
| C3 | CLBLL FAIL 被读成「PIP 不可移植」的前兆 | 实为 INIT 索引表选错（见 §6），与 PIP 无关。若拿它当 PIP 结论，会得出方向性错误。 |
| C4 | 「PIP 开关盒」在口语里泛指「布线开关」 | 数据上至少两个落点：INT mux PIP（INT 块 26 帧）与 CLB site PIP（CLB 块 off 16–25）。必须先选定一个落点，否则观测位对不上。 |
| C5 | law 库 `law_cells` 只有 INT_L/INT_R，没有 CLB 的 INIT 行 | 所以「用 law 库验证 INIT 表」本身不成立；INIT 表来自 `clb_init_locked_map.json` 的实测。两套数据源不能混用。 |
| C6 | STATUS §100 的「下一步：对 X8Y20 跑 65 个单最小项建 CLBLL 表」 | 这条**已可撤回**：CLBLL 不需要新表（§6）。若继续按它执行，会重复建一张本已存在的表。 |

---

## 5. 待确认项（A2：各自验证方法）

> 判定本身不需要这些项（J1–J6 已闭合）。以下是**执行 PIP 实验前**必须锁定的口径，属「待确认」不是「未知」：

| # | 待确认项 | 为什么必须确认 | 验证方法（可执行） |
|---|---|---|---|
| Q1 | 用户要的「同类 tile」是「同 tile_type」还是「同类型族」（如 CLBLM_R 与 CLBLL_L 都算 CLB） | 口径不同，选定的 tile 对完全不同，实验结论的适用范围也不同 | 取 `clb_blocks`/`law_cells` 的 tile_type 清单，各举一对（同 type：INT_L_X6Y11 + INT_L_X14Y11；同族跨 type：CLBLM_R + CLBLL_L）做一次「源集合/列码」离线比对，把两种口径的结论差异摆给用户选 |
| Q2 | PIP 观测位选 INT mux PIP 还是 CLB site PIP | 两者帧不同、编码不同，判据也不同；选错会把 site PIP 当成 mux PIP | 用 `v7re/scripts/pip_fuzz.py` 的既有协议（fix 两端、sweep 输入脚 A1..A6，见 `pip_fuzz.py:3-13`），差异帧落在 INT 块 = mux PIP；落在 CLB 块 off16–25 = site PIP。一次构建即可判别 |
| Q3 | 目标 tile 对的「源集合」是否同构 | 源集合不同则行映射不可比，实验会得出假阴性 | 离线查 `pip_defs`（字段序 **(src,dst)**，见 STATUS §99）：按 dst 分组比源集合；§99 已给出 166/172 族一致、6 族为时钟常量线差异 |
| Q4 | 行映射是否必须逐族固化 | 若同 tile_type 的两 tile 行映射不同，则「一张表跨 tile」不成立 | 用 `v7re/steps/PIP_ADDRESS_ENCODING_LAW.md` §5 的 36 组行映射表，对选定 tile 对逐族比对 row 序号；命中数应等于「同族 tile 共享版图」的强假设检验 |

其中 Q3、Q4 已有离线基础设施（law 库 + pip_defs），可在不跑 Vivado 的前提下先答；Q1 是产品口径问题，必须由用户/主 Agent 定；Q2 是实验设计问题，T2 应回答。

---

## 6. 附录：顺带更正 T54 的 CLBLL 结论（与 PIP 无关，但影响 §100 的下一步）

用 `clb_init_locked_map.json` 的两套索引表（SLICEM / SLICEL）分别预测四个构建：

```
c20 / SLICEM : 预测 46，missing 0，extra 0  → PASS
c20 / SLICEL : 预测 46，missing 13，extra 13 → FAIL
c08 / SLICEM : 预测 46，missing 13，extra 13 → FAIL
c08 / SLICEL : 预测 46，missing 0，extra 0  → PASS
```

【推断】T54 报告的 CLBLL FAIL「13 缺 / 13 多」，根因是**把 CLBLM 的 SLICEM 顺序套到 CLBLL 的 SLICEL slice 上**：X20Y20 在 CLBLM_R（inst0 = SLICEM，group_off 32），X8Y20 在 CLBLL_L（inst0 = SLICEL，group_off 26）。换成 SLICEL 表后 **46/46 全等，帧号 identity，不需要任何帧置换**。

推论：T54 试过的「帧 XOR2」「帧镜像」两种修法都不是正确方向（错的是位索引不是帧序），`STATUS.md` §100 的「对 X8Y20 跑 65 个单最小项建 CLBLL 表」可以撤回——表已存在，缺的只是选表时按 `bel_rule` + slice kind 分派。

这条更正不改变本判定的结论（对象仍是 INIT），但它把「CLBLL 是另一套布局」这个错误前提清掉了，避免 T5 去重复建表。

---

## 7. 复现命令

```powershell
cd E:\DEEPSEEK\FPGA比特流逆向
$env:PYTHONIOENCODING='utf-8'
python v7re\scripts\t55_object_check.py     # 三段：差异帧形态 / 两套表对账 / PIP vs INIT 形状
```

依赖：`_xcheck_local/{c20z,c20v,c08z,c08v}.bit`（已解包，各 20,273,538 字节）、`v7re/steps/clb_init_locked_map.json`、`E:\v7work\model\v7_law.sqlite`（只读打开）。脚本 exit code 0。

---

## 8. 一句话交接

> **现在做的是「LUT INIT 表能不能跨 tile 复用」，不是「PIP 开关盒能不能跨 tile 复用」。**
> 要测 PIP 开关盒，观测位必须落到 INT 块的 26 帧（mux PIP）或 CLB 块的 off 16–25（site PIP），用 `pip_fuzz.py` 的 fix-both-ends + sweep-pin 协议，而不是 INIT 差分。
