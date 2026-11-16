# T2 · family 名字溯源与命名核对（IMUX_L34 / WW4BEG0 / WW4END0）

> 性质：命名核对表 + 溯源证据。定义澄清的合并稿由 T4 负责（`v7re/steps/family_definition.md`），本文件只回答「这个名字是真的还是编的」。
> 三色标注：`【硬件事实】`= 厂商器件数据/工具导出；`【数据事实】`= 本项目实测；`【推断】`= 由数据反推。
> 复核脚本：`v7re/steps/t2_name_verify.py`（输出 `t2_name_verify.out.txt`）、`v7re/steps/t2_scope.py`（输出 `t2_scope.out.txt`）。全部数字可用这两条命令重跑。

## 0. 结论先行

| 问题 | 结论 |
|---|---|
| 三个名字是真的吗 | 真的。三者都出现在 **Vivado 2017.2 自身导出**（`get_pips` / `get_property ROUTE`）以及第三方逆向库 prjxray 中，不是本项目造的字符串 |
| 名字从哪来 | `family` 字段是 prjxray `segbits_int_{l,r}.db` 每条 feature 的**第 2 段（DST 目的线名）逐字照抄**；`all_cells.json` 的 24,336 行与该 db 解析结果**多重集全等**（差值 0/0） |
| `family` 这个词是哪来的 | **词是本项目的**（`AGENTS.md:16` 明确「「家族」不是 Xilinx 官方术语」；Vivado 导出里 `family` 字样出现 0 行）；**值是厂商的** |
| 证据分几级 | 两级，不可混称：**A 级＝厂商工具直接输出**（`tamper/ref/pips_all.txt` = Vivado `get_pips`，`step03_pip/route_*.txt` = Vivado `get_property ROUTE`）；**B 级＝第三方逆向库**（prjxray，sha256 已校验未被改动）。本文件§3 每一行都标注等级，**不把 B 级写成「官方数据」** |
| 为什么不同 tile 有同一个 family | 因为 family 的命名空间是 **tile_type 级**，不是实例级：它描述「INT_L 这个类型里的第几条目的线」，与 col/y 无关。每一个 INT_L 实例都拥有同一套 172 个目的线名 |
| 同名 = 同一布局吗 | 不是定义，是实测结论。`family` 只是簿记键；「相对格集合相同」是另一层被测出来的东西，不能反过来把 family 说成「器件里的等价类结构」 |

## 1. 判定方法（先立判据，再看结果）

A3 要求「不得用看起来像官方命名风格作判据」。本文件用五条互相独立的判据，任一条都不涉及命名风格：

1. **厂商工具自己的导出里有没有这个字符串**（A 级）：`tamper/ref/pips_all.txt` 由 `tamper/ref/build.tcl:15` 的 `get_pips -of_objects $n -quiet` 逐条写成；`step03_pip/route_*.txt` 由 `step03_pip/s8_route.tcl:18` 的 `get_property ROUTE $n` 写成。
2. **第三方逆向库里有没有这个字符串**（B 级）：`prjxray_ref/artix7/*.db`（来源见 §2）。
3. **本项目的脚本是怎么写这个字段的**：读源码行，确认是「解析第 2 段」而不是「按规则拼名字」。
4. **转写是否忠实**：把 db 重解析一遍与 `all_cells.json` 做多重集全等比对；若脚本曾改名/聚类，必然出现差集。
5. **引用文件是否被本项目改过**：对 `prjxray_ref/SHA256SUMS.txt` 校验三个 db 的 sha256（三者全部一致，见 `t2_name_verify.out.txt` §0）。

## 2. 数据来源先立住（否则「命中」可能命中自己造的库）

- 【硬件事实】参考库来自上游开源项目，不是本项目生成：`prjxray_ref/PRJXRAY_COMPARE.md:11` 记录仓库 `f4pga/prjxray-db` @ master、commit `0a0addedd73e7e4139d52a6d8db4258763e0f1f3`（2021-12-14）；`:12` 记录下载方式为 raw.githubusercontent.com（2026-10-24）。
- 【硬件事实】完整性可校验：`prjxray_ref/SHA256SUMS.txt` 记录 14 个 db 的 sha256，其中 `artix7/segbits_int_l.db 0ea44e8dfaf97ed200f30b2afe117e94e1a68bdb26af2e09e69e855414779520`、`artix7/ppips_int_l.db d300ad4128a192e416a958471013b7554f141fd1f816715828b1e5a87838f18d`。
- 【硬件事实】命名方向约定：`prjxray_ref/PRJXRAY_COMPARE.md:20` 写明本地(V7) `SRC->>DST` ↔ prjxray `INT_L.DST.SRC`（**目的在前**）；`:23` 写明 bitindex 的 word 是相对量、需要 tilegrid 的 `offset` 补基址。**该行原写「(RapidWright)」，本轮已改正**：`->>` 这个串形是 Vivado `get_pips` 的 NAME 属性直出（`tamper/ref/build.tcl:15-16`），不是 RapidWright 生成的。
- 【硬件事实】db 行格式实证：`INT_L.BYP_ALT0.BYP_BOUNCE_N3_3 21_07 !22_07 !23_07 24_07 !25_07`（第 1 字段=feature `类型.目的线.源线`，其后 `word_bit`，`!` 表示清 0）。

## 3. 命名核对表

三个名字的命中分两级判定（脚本 `t2_name_verify.py` §2 实测输出，输出文件 `t2_name_verify.out.txt`）：

- **A 级 = 厂商工具直接输出**：`tamper/ref/pips_all.txt`（`tamper/ref/build.tcl:15` `get_pips -of_objects $n -quiet`）、`step03_pip/route_*.txt`（`step03_pip/s8_route.tcl:18` `get_property ROUTE`）。
- **B 级 = 第三方逆向库**：`prjxray_ref/artix7/*.db`（来源与 commit 见 §2，sha256 已核对未被改动）。

**只有 A 级才能说「厂商数据里有」**；B 级只作交叉佐证。旧版本此表把 prjxray 命中写成「官方数据中存在」，是等级混用，已改。

| 名字 | 级 | 命中 文件:行 | 出现位置 | 计数 | 判定 |
|---|---|---|---|---|---|
| `IMUX_L34` | A | `tamper/ref/pips_all.txt:1059` → `INT_L_X32Y156/INT_L.ER1END1->>IMUX_L34` | 箭头右侧 = DST | 作 DST 15 行 / 15 tile，作 SRC 0 行 | 厂商导出中存在，是**目的线** |
| `IMUX_L34` | A | `step03_pip/route_out_o.txt:2`、`route_out_o2.txt:2`、`route_out_o3.txt:2` | ROUTE 路径串里的一级（`… BYP_BOUNCE0 IMUX_L34 IOI_OLOGIC0_D1 …`） | 3 处 | 厂商布线真值中作为已布网络的路径节点存在 |
| `IMUX_L34` | B | `prjxray_ref/artix7/segbits_int_l.db:1305` → `INT_L.IMUX_L34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21` | feature 第 2 段 = DST | DST 24 行 / SRC 0 行 | 第三方库中存在，作 family |
| `IMUX_L34` | B | `prjxray_ref/artix7/ppips_int_l.db:95` → `INT_L.IMUX_L34.VCC_WIRE default` | 第 2 段 = DST | 1 行 | 同上（零配置位伪 PIP 项） |
| `IMUX_L34` | B | `prjxray_ref/artix7/segbits_int_r.db` | — | 0 行 | INT_R 侧**无此名**；INT_R 的对应名是 `IMUX34`（`segbits_int_r.db:1697` `INT_R.IMUX34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21`，与 L 侧 :1305 同源线同图案，仅 `_L` 后缀消失） |
| `WW4BEG0` | A | `tamper/ref/pips_all.txt:16` → `INT_L_X14Y192/INT_L.NW6END0->>WW4BEG0` | 箭头右侧 = DST | 作 DST 48 行，作 SRC 0 行 | 厂商导出中存在，是**目的线** |
| `WW4BEG0` | A | `step03_pip/route_I0.txt:1`、`route_I2.txt:1`、`route_I3.txt:1` | ROUTE 路径串里的一级 | 3 处 | 厂商布线真值中存在 |
| `WW4BEG0` | B | `segbits_int_l.db:3557` → `INT_L.WW4BEG0.LOGIC_OUTS_L0 02_01 04_02` | 第 2 段 = DST | DST 20 行 | 第三方库中存在（INT_L 侧） |
| `WW4BEG0` | B | `segbits_int_r.db:3557` → `INT_R.WW4BEG0.LOGIC_OUTS0 02_01 04_02` | 第 2 段 = DST | DST 20 行 | 第三方库中存在（INT_R 侧，两侧同名） |
| `WW4BEG0` | B | `ppips_int_l.db` / `ppips_int_r.db` | — | 0 行 | 该文件不含此名（不是伪 PIP） |
| `WW4END0` | A | `tamper/ref/pips_all.txt:17` → `INT_L_X10Y192/INT_L.WW4END0->>WW4BEG0` | **箭头左侧 = SRC** | 作 SRC 48 行 / 46 tile，作 DST 0 行 | 厂商导出中存在，但**只作驱动线，不是 family** |
| `WW4END0` | A | 9 个 `route_*.txt` | — | 0 处 | 不作 mux 目的线 |
| `WW4END0` | B | `segbits_int_l.db:1652` → `INT_L.LV_L0.WW4END0 00_05 00_07` | **第 3 段 = SRC** | SRC 10 行 / DST 0 行 | 第三方库中存在，只作源线 |
| `WW4END0` | B | `segbits_int_r.db:444` → `INT_R.NL1BEG_N3.WW4END0 08_01 12_01` | 第 3 段 = SRC | SRC 10 行 / DST 0 行 | 同上 |

**A1 逐名结论（三句，可直接引用）**
- `IMUX_L34`：**厂商导出中存在**（A 级 18 处 = `get_pips` 15 + `ROUTE` 3），且在 `get_pips` 里是**多源汇入**的目的线（15 行来自 **8 个不同源线**：`ER1END1`×6、`SR1BEG_S0`×2、`WW2END0`×2、`BYP_BOUNCE0`、`FAN_BOUNCE7`、`WR1END1`、`SL1END1`、`SW2END1`）。INT_R 侧无此名。
- `WW4BEG0`：**厂商导出中存在**（A 级 51 处 = `get_pips` 48 + `ROUTE` 3），同样是多源目的线（48 行来自 **8 个不同源线**：`WW4END0`×38、`LH12`×3、`NN6END0`×2、`NW6END0`、`NW2END0`、`LOGIC_OUTS8`、`WW2END_N0_3`、`NN2END0`）。
- `WW4END0`：**厂商导出中存在**（A 级 48 处，全部在 `get_pips` 的**源侧**），但**一源多汇**（48 行指向 **5 个不同目的线**：`WW4BEG0`×38、`NL1BEG_N3`×4、`WR1BEG1`×4、`NW2BEG0`、`NN2BEG0`）、**从不作目的线** → 不是 family。

**A3 口径说明（不许用命名风格判）**：上表的判定只用两个可复核的东西——(i) 字符串在 A/B 级文件里是否**逐字出现**；(ii) 它在该行处于**箭头的哪一侧**（右=目的/family，左=源）。判据里没有任何「像不像 Xilinx 命名」的成分。`IMUX_L34` 与 `IMUX34` 这种只差 `_L` 的名字，正是**只能靠命中文件判定、不能靠风格猜**的例子。

补充同族行号（`segbits_int_l.db` 中 `X.WW4END0`）：1664、1720、2216、2356、2436、2596、2676、3436。

**检索范围与口径说明（A2 要求）**

`t2_name_verify.py` §1 打印的检索空间是 **34 个文件 / 26,146 行**，逐行扫描，不是抽样：

| 范围 | 文件 | 行数 |
|---|---|---|
| prjxray 全部 db | `prjxray_ref/artix7/*.db` **22 个**（`segbits_/ppips_/mask_` × `bram/clbll/clblm/dsp/int` × `l/r`） | 21,906 |
| Vivado get_pips | `tamper/ref/pips_all.txt` | 1,812 |
| Vivado ROUTE | `step03_pip/route_I0..I5.txt`、`route_out_o.txt`、`route_out_o2.txt`、`route_out_o3.txt` | 12 |
| 几何/帧数据 | `v7re/tmp/part.yaml`、`v7re/tmp/tilegrid.json` | 2,416 |

- **未命中的口径**：§2b 对 22 个 db 逐个做子串扫描，三个名字的命中文件集分别为 `{ppips_int_l, segbits_int_l}`、`{segbits_int_l, segbits_int_r}`、`{segbits_int_l, segbits_int_r}`——其余 19–20 个 db **确实检索过且为 0 命中**，不是「没搜」。
- **`part.yaml` / `tilegrid.json` 的 0 命中必须限定口径**：这两个文件只含几何与帧信息，**本来就不含任何 wire 名**，所以 0 命中是结构性的，**不能当作「名字不存在」的证据**。这正是本任务风险项「未命中被误读为不存在」的具体形态。
- **一个必须写出来的坑（假阴性来源）**：用 `\.WW4END0\.` 这种「两侧都要点」的模式检索会得到 0 命中，因为它在 feature 串里只出现在**行尾**（`INT_L.LV_L0.WW4END0`），后面没有点。改用 `\.WW4END0\s` 才得到 10 行。若有人只跑一次两侧带点的正则就下结论「这个名字是编的」，就是这个假阴性。
- **箭头语义的口径**：本文按项目既有约定读 `get_pips` 行——`->>` 为互连级 PIP（`TILE/TT.SRC->>DST`，**DST=family**），`->` 为站点内部直连（如 `CLBLL_R.CLBLL_IMUX8->CLBLL_LL_A5`），不参与 family 统计。三条名字在 `get_pips` 里的命中**全部是 `->>`**（15/48/48 行，`->` 均为 0 行）。
  - 该约定有独立证据：`->` 类连接在 prjxray 里是零配置位的 `always` 伪 PIP——`prjxray_ref/artix7/ppips_clbll_l.db:103` `CLBLL_L.CLBLL_LL_A5.CLBLL_IMUX8 always`；而 `->>` 类连接是带位的真 PIP（本项目 T56 用 `->>` 行解出 190 条 PIP 与 Vivado 路由真值 190/190 对齐，见 `v7re/steps/T56_SAME_TYPE_TILE_PIP.md:105-116`）。
  - **但箭头类型不能反推「可配置」**：`->>` 里同时含两类——带位的 mux PIP（如 `LOGIC_OUTS_L18->>NN6BEG0`）与 BEG/END 桥接（如 `NN6END0->>NW6BEG0`，按 `AGENTS.md:16` 是固定连接）。所以本文只用箭头判「哪边是 DST」，不用它判「是否可配置」。
  - 顺带修正：`v7re/steps/t2_scope.py` 早先把 `->` 标为 `pip`、`->>` 标为 `fixed`，标签与上述证据相反，本轮已改为按箭头字形标注并重跑（`t2_scope.out.txt:1` 现为「`'->'` 站点内部直连=204，`'->>'` 互连级 PIP=1608」），数字不变。

## 4. `family` 这个词 vs 这些值（两个层次必须拆开）

- 【数据事实】**词是本项目的**：`AGENTS.md:16` 明写「`BEG→END` 的 tileconn 落点是**固定连接不是 mux**；「家族」不是 Xilinx 官方术语」。
- 【数据事实】**Vivado 导出里没有 `family` 这个词**：`step03_pip/route_*.txt` 九个文件中出现 `family` 字样的行数 = **0**（`t2_name_verify.out.txt` §5）。所以「family」是项目内部的分类用语，不是厂商术语。
- 【数据事实】**值是厂商的**：同批 Vivado ROUTE 导出里，`IMUX_L34` 出现 3 处（`route_out_o.txt:2`、`route_out_o2.txt:2`、`route_out_o3.txt:2`），`WW4BEG0` 出现 3 处（`route_I0.txt:1`、`route_I2.txt:1`、`route_I3.txt:1`）；`WW4END0` 在 ROUTE 串里 **0 处**——它在 `pips_all.txt` 的 48 行里**全部位于源侧**（38 行指向 `WW4BEG0`，`NL1BEG_N3` 4 行、`WR1BEG1` 4 行，`NW2BEG0` / `NN2BEG0` 各 1 行），从不以 mux 目的线出现，所以不可能落在 ROUTE 的 PIP 名位置。它出现的位置是 `WW4END0->>WW4BEG0` 这类 BEG/END 桥接的**驱动侧**；该桥上是否带配置位，本地无 tileconn 表，**未测**（`AGENTS.md:16` 的项目口径是「`BEG→END` 的 tileconn 落点是固定连接不是 mux」，此处按【硬件事实】引用，本文不另作独立证明）。
- 【数据事实】项目自己对 family 的定义只有一句：`step03_pip/REUSE_RULES.md:96` —「family = PIP 的**目的 wire**（mux 名 / BEG 名）」；同文件 `:121` 追加「一个位属于且只属于一个 family（一个目的 wire / 一个 mux）」。

因此正确的读法只有一句：**`family` 是本项目的字段名，它的取值是厂商的线名。** 把「family」当成 Xilinx 的术语是错的；把 `IMUX_L34` 当成项目自造的类名也是错的。

## 5. 为什么不同的 tile 会有同一个 family

【硬件事实】三条结构性证据，说明这是命名空间的必然结果，不是巧合：

1. **segbits 表没有坐标维度**。行格式是 `TILE_TYPE.FAMILY.SRC word_bit...`，**没有 col/y 字段**。一条记录描述的是「该 tile 类型内部的一次连接」，解码器对每个实例施加同一份表（`t2_scope.out.txt` §C）。
2. **每侧恰好 172 个 family**：`step03_pip/all_cells.json` 中 INT_L 172 个、INT_R 172 个（`t2_scope.out.txt` §B），与 `step03_pip/pip_law.py:28` 注释「全部 172 家族 × 两侧」一致。一个类型一套名字，实例之间共享这套名字。
3. **名字确实跨很多实例重复**（`tamper/ref/pips_all.txt` 口径，箭头统一为「左驱动右、DST 在右」）：`IMUX_L34` 作为 DST 出现在 **15 个** INT_L tile 上；`WW4BEG0` 作为 DST 出现在 **48 个** tile 上（INT_L 与 INT_R 都有）；`WW4END0` 作为 SRC 出现在 **46 个** tile 上（`t2_scope.out.txt` §A）。

【硬件事实】**跨 tile_type 就不是同一个名字了**：INT_L 与 INT_R 各有 172 个 family，交集只有 116 个；各侧独有 56 个，且成对镜像——INT_L 侧 `IMUX_L0..L47 / CLK_L0 / CTRL_L0`，INT_R 侧 `IMUX0..47 / CLK0 / CTRL0`（`t2_scope.out.txt` §B）。所以「同名」的边界是 tile_type：同一个 INT_L 类型的所有实例共有 `IMUX_L34`；INT_R 里没有 `IMUX_L34` 这个名字。

镜像的实证（不是命名推测）：`IMUX_L34` 在 L 侧 `segbits_int_l.db:1305` 是 `INT_L.IMUX_L34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21`；R 侧同名位置是 `segbits_int_r.db:1697` `INT_R.IMUX34.BYP_BOUNCE_N3_6 21_21 !22_21 !23_21 !24_21 25_21` —— **源线相同、位图案逐位相同，只有 family 名少了 `_L`**。这说明「名字带不带 `_L`」是 tile_type 命名空间的差异，不是本项目改名；同时也是「不能靠命名风格判、必须靠命中文件判」的又一处证据。

这条对用户那句「为什么不同的 tile 都有同一个」是决定性的：**因为问的是同一个 tile_type 的不同实例**。若跨 tile_type 去比，名字根本对不上（除了 `BYP_ALT*`、`EE2BEG0` 这类 116 个偶合共有的长线/BYP 名）。

## 6. `family` 与「相对格集合等价类」不是同一层

- `family` 是**簿记键**（`law_cells` 表的一列），来源固定：`step03_pip/gen_all_cells.py:39` `_t, family, src = seg`；`v7re/export/law_db.py:187-189` 读 `c["family"]`；`:308/:314` 写进 `law_cells`（`INSERT OR REPLACE INTO law_cells`）；`v7re/scripts/pip_reuse_law.py:46` 只是 `select family,... from law_cells`——**没有任何聚类/改名步骤**。
- 「相对格集合相同」是**测量结果**：`pip_reuse_law.json` 的 `combo_check` 给出「64 个 family / 64 个互异组合 / 每个组合最多 1 个 family」（`families` 键 64 个：BYP_ALT0..7、FAN_ALT0..7、IMUX_L0..L47）。这 64 是 law 模型覆盖的子集，不是全部 172。
- 【推断】所以「我聚出来的类」与「器件里的真实结构」的关系是：**类是被测出来的，名字是抄来的**。名字不能用来证明类；反过来，类相同也不能证明「名字是厂商按这个类起的」。把两者混同，就会把 `family` 说成「厂商的等价类」——这一步没有证据支持。

实测支撑（不是定义）：`step03_pip/REUSE_RULES.md:102` 「域内编码唯一 172 / 172」、`:97` 「cell → family 1598 / 1598 独占」。这两条是本项目实测口径，属于【数据事实】。

## 7. 反例防护：不是所有同名线都是 family

- `WW4END0` 在 segbits 里 as_DST = 0、as_SRC = 10（两侧各 10），在 `all_cells.json` 里 family 行 = 0、src_wire 行 = 40。它**不是** family，是长线的 END 驱动线。
- 【数据事实】但它可以出现在 family 的源集合里：`v7re/steps/beg_families.json` 中 `EE2BEG0` 的 `sources` 含 `EE2END0` 等 END 线，每个源带具体 `[frame, parity, bit]`。
- 结论：**判 family 只看「它在 feature 串里是不是第 2 段（DST）」，不看它是不是一个眼熟的线名。**

## 8. 转写忠实性（A3 的直接检验）

把 `prjxray_ref/artix7/segbits_int_{l,r}.db` 按 `gen_all_cells.py` 的口径重解析，与 `step03_pip/all_cells.json` 做多重集全等比对（`t2_name_verify.out.txt` §3）：

```
prjxray 行解析出的单元数 = 24336
all_cells.json 单元数       = 24336
只在 prjxray 侧 = 0；只在 all_cells 侧 = 0
全等多重集（无任何增删改）: True
```

含义：`all_cells.json` 的 24,336 行是 db 的**逐位转写**，不存在改名、聚类、去重或补造。`family` 字段的每一个取值都必然是 db 里出现过的字符串。

首行对照（人工可核）：
- db：`INT_L.BYP_ALT0.BYP_BOUNCE_N3_3 21_07 !22_07 !23_07 24_07 !25_07`
- json：`{'tile_type':'INT_L','family':'BYP_ALT0','src_wire':'BYP_BOUNCE_N3_3','frame_off':21,'parity':0,'bit':7,'sense':1}`，下一行同源 `frame_off:22, sense:0` —— 与 `!22_07` 逐位对应。

## 9. 证据清单（可复核）

| 结论 | 证据位置 |
|---|---|
| 名字出现在**厂商工具**导出（A 级） | `tamper/ref/build.tcl:15-16`（`get_pips` + `get_property NAME`）→ `tamper/ref/pips_all.txt:1059`、`:16`、`:17`；`step03_pip/s8_route.tcl:18` → `step03_pip/route_out_o.txt:2`、`route_I0.txt:1` |
| 名字出现在第三方逆向库（B 级） | `prjxray_ref/artix7/segbits_int_l.db:1305`、`:3557`、`:1652`；`segbits_int_r.db:3557`、`:444`；`ppips_int_l.db:95` |
| 参考库非本项目生成、字节未改 | `prjxray_ref/PRJXRAY_COMPARE.md:11-12`、`prjxray_ref/SHA256SUMS.txt`；三 db sha256 实测一致（`t2_name_verify.out.txt` §0） |
| 检索空间（A2） | `t2_name_verify.out.txt` §1（34 文件 / 26,146 行）、§2b（22 个 db 逐个命中文件集） |
| 角色判定（DST=family / SRC=驱动线） | `t2_name_verify.out.txt` §2（作DST/作SRC 行数与不同邻居线数）、§4（all_cells `family`/`src_wire` 行数） |
| `family` 字段的写入链 | `step03_pip/gen_all_cells.py:39`、`:50`；`v7re/export/law_db.py:187-189`、`:308`、`:314`；`v7re/scripts/pip_reuse_law.py:46` |
| family 的项目内定义 | `step03_pip/REUSE_RULES.md:96`、`:121`；`AGENTS.md:16` |
| 转写全等 | `v7re/steps/t2_name_verify.out.txt` §3 |
| 名字跨实例/跨类型作用域 | `v7re/steps/t2_scope.out.txt` §A/§B/§C；`tamper/ref/pips_all.txt` |
| `->>`/`->` 语义约定 | `prjxray_ref/artix7/ppips_clbll_l.db:103`（site 侧 `always` 零位）、`v7re/steps/T56_SAME_TYPE_TILE_PIP.md:105-116`（`->>` 行解出 190/190 PIP）；`v7re/steps/t2_scope.out.txt:1` |
| 复跑方式 | `python v7re/steps/t2_name_verify.py`；`python v7re/steps/t2_scope.py` |

## 10. 边界与未验证

- 本地 `v7re/db/v7_law.sqlite` 是 0 字节（真实库在远端 `E:\v7work\model\v7_law.sqlite`），所以本文结论**不依赖**本地 sqlite，只依赖 `all_cells.json` + 脚本源码 + prjxray db + Vivado 导出。
- `tamper/ref/pips_all.txt` 是**部分**导出（1,812 行：204 条 `->`、1,608 条 `->>`），只覆盖 `tamper/ref/top.v` 那一个设计布过的 PIP，不是全器件 PIP 表。所以 §3/§5 的「15/48/46 个 tile」是**这份导出下的实例数**，不是器件总数；**器件级总数未测**（要全器件得跑 `get_pips` 全枚举，不属本子任务）。
- **0 命中不等于不存在**：`v7re/tmp/part.yaml`、`v7re/tmp/tilegrid.json` 三个名字各 0 命中，但这两个文件只有几何/帧信息、本来不含 wire 名，属结构性 0。同理 `ppips_int_*.db` 是「零配置位伪 PIP」表，绝大多数线名不在其中，0 命中无否定力。
- 「172 个 family 的每一个都在本项目里有实测位」未验证：`step03_pip/REUSE_RULES.md:221` 记录有 24 个 IMUX family 完全未测。
- prjxray 数据是 artix7（`xc7a*`）来源，本项目器件是 `xc7vx485t`：名字的**存在性**由本项目的 Vivado 导出直接证实（§3 A 级行），但 db 里每条位坐标迁移到 V7 的等价性不在本子任务范围（见 `step03_pip/P0B_LONG_LINE.md` 与 T2b）。
- 本文只判定「名字是否真实存在、在项目里落在 DST 还是 SRC」。**名字与「相对格集合等价类」是否一一对应，是另一层结论**（见 §6），不能由本节推出。
