# T20：通用流程 skill 实测 —— part 对差分 + T19 表反读自证

日期：2026-11-06
数据：远端 `/opt/lzh/v7re/work/partpair`，5 个构建（5 路并行，全部 rc=0）。
脚本：`step03_pip/_t20_partpair.sh`（构建）、`step03_pip/_diff_pair.sh` / `_diff_pair2.sh` / `_diff_pair3.sh`（差分）。

## 0. 这次实验的目的是「试 skill 本身」

按 `.agents/skills/fpga-bitstream-experiment/SKILL.md` 的八道门走一遍真实流程，看门是否真的挡得住、判读是否真的收敛。
选这个题目是因为它同时踩到门 1（器件 part）、门 3（单变量 + 配对 + 差分语义）、门 5（负对照 + 反读自证）、门 6（三元组统计）、门 8（适用域）。

| 构建 | INIT | part | 作用 |
|---|---|---|---|
| `b0_1157` | `0x0` | `xc7vx485tffg1157-3` | 基线 A |
| `b0b_1157` | `0x0` | `xc7vx485tffg1157-3` | 重复基线（负对照） |
| `b0_1761` | `0x0` | `xc7vx485tffg1761-2` | 基线 B（只改 part） |
| `r_1157` | `0xDEADBEEFCAFEBABE` | `xc7vx485tffg1157-3` | 随机值（未参与 T19 训练） |
| `r_1761` | `0xDEADBEEFCAFEBABE` | `xc7vx485tffg1761-2` | 随机值 + 另一封装 |

共同条件（全部构建）：`LOC SLICE_X12Y20`、`BEL A6LUT`、`LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`、`DONT_TOUCH`。

## 1. 门 4 / 门 5：回读与负对照

五个构建的 `build.log` 全部打印，且逐项一致：

```
RB_PART=xc7vx485tffg1157-3 / xc7vx485tffg1761-2      （与 -part 一致）
RB_SITE=SLICE_X12Y20   RB_BEL=SLICEM.A6LUT
RB_INIT=64'hDEADBEEFCAFEBABE （随机组） / 64'h0000000000000000 （基线组）
RB_LOCK=I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6
```

**负对照**：`b0_1157` vs `b0b_1157`（同设计、同 part、重跑一次）→ **差分帧数 = 0**。
环境自证通过，后续差分可信。

## 2. 门 5：反读自证（关键的一步）

把 `0xDEADBEEFCAFEBABE`（**不在 T19 的 64 个单最小项构建里**）烧进去，与 `INIT=0` 基线差分：

```
差异帧：4 个（31784, 31785, 31786, 31787）
差异位：60 个 = word 40 的 46 位 + word 50 的 14 位
```

其中 word 40 的 46 位用 T19 的闭式公式独立预测（`B = 31716`）：

```
frame = B + 70 + (k & 1) - 2 * ((k >> 3) & 1)
word  = 40
bit   = 15 - 4 * (k >> 4) - ((k >> 1) & 3)
```

预测量 **46**，实测 **46**，**missing 0 / extra 0** —— 集合级精确相等，不是「大致对上」。

【数据事实】T19 闭式公式对未参与训练的值成立 → 该表可用于反读真实设计的 INIT 物理真值。

## 3. word 50 的 14 位

差异位里 word 50 恰 **14 位**，全部落在 bit 0..12（即低 13 位 ECC 域内）：

```
(31784, 0/2/5/6/11)  (31785, 3/12)  (31786, 2/3)  (31787, 0/1/5/6/11)
```

【数据事实】改 INIT 内容后，同帧 word 50 必然跟着变，且落在 ECC 域 —— 再次印证「word 50 是 ECC，不是配置位」。

## 4. 门 1 / 门 6：part 是不是变量

同 netlist、同 LOC/BEL/LOCK_PINS、同 INIT，只改 `-part`：

| 差分对 | part | 差异帧 | 差异位 |
|---|---|---|---|
| `part_zero` | `b0_1157` vs `b0_1761` | 133 | 1,210 |
| `part_rand` | `r_1157` vs `r_1761` | 133 | 1,210 |

两对帧集合完全相同（27189…32607），说明差异与 INIT 内容无关，是 part 造成的固定差。

**关键**：这 133 帧**不含** 31784–31787。
即：本 BEL 的 CLB INIT 帧（word 40）在两个封装下**逐字节相同**。

- 【数据事实】T19 的 INIT 映射在本设计域内**与封装 part 无关**；这为 `STATUS.md` 附「fabric 层不受影响」提供了第一条直接实测（此前的论据是键合 IOB 数 600 vs 700 的间接推理）。
- 【推断】31784–31787 之外那 133 帧差异，最可能来自**未约束端口** `a0..a5/o` 的默认 IOB 分配（两封装可用引脚不同），其中 21 帧落在同一 block（base 31716）内，word 50 占 766 位（内容变了 → ECC 重算）。
- 【未测】上述 133 帧/1,210 位的成因**没有实测确认**。最小验证实验：给所有端口加 `PACKAGE_PIN` 约束到两封装都存在的 IOB，重跑该对；若差分降为 0，则确认成因是默认 IOB 分配。

## 5. 顺带发现：T19 那批构建的 part 写的是 ffg1761-2

`/opt/lzh/v7re/work/locked/mk.tcl` 里是 `synth_design -top top -part xc7vx485tffg1761-2`，
与 `STATUS.md` 器件修正里「本项目实际 part = `xc7vx485tffg1157-3`」不一致。

按 skill 门 1（不许沿用旧文档的假定 part），本次全部显式写 `ffg1157-3`，并同时跑 `ffg1761-2` 作对照：

- 两边都是同样的 4 帧 / 46 + 14 位结构；
- 且 word 40 的 46 格与公式 46/46 一致。

【数据事实】所以 T19 表本身没有被 part 污染，仍可用；但**后续构建必须显式声明 part**，不能靠默认。

## 6. 这个 skill 在本次实测里的表现

| 门 | 是否真的起了作用 |
|---|---|
| 1 入场（器件 part） | **是** —— 直接暴露出 T19 构建写的是 ffg1761-2 |
| 2 可证伪假设 | 是 —— 判据 D 写成「若 CLB INIT 帧出现非零差异则 H1 失败」 |
| 3 单变量 + 配对 + 宣言 | 是 —— part / INIT 两个变量被拆成三对独立差分 |
| 4 回读（SITE/BEL/INIT/LOCK） | 是 —— 五个构建全部打印并核对 |
| 5 负对照 + 反读自证 | **是** —— 重跑 0 差异；随机值 46/46 集合精确相等 |
| 6 判读（三元组 / 三色 / 适用域） | 是 —— 结论全部写了 part、BEL、行号与「未测」 |
| 7 落库 | 本文 + `STATUS.md` §50 |
| 8 交付（适用域 + 最小实验） | 是 —— §4 末给出降为 0 的最小实验 |

**已应用的改进（skill V2，均经 `iterate-prompt` 生成后落盘）**：

- 门 5：反读自证升级为**集合级硬判据**（同时 `missing=0` 与 `extra=0`，禁止只看命中数/抽样）；补「未参与训练」的可操作定义；自证报告强制打印预测集大小、实测集大小、missing、extra 四个数；ECC 字变化单独计数。
- 门 4：新增 **part 硬规则**（构建脚本必须显式写 `-part`，并断言回读 PART 与声明一致；靠默认会静默污染整批构建）；补 base64 必须先落地成文件再解码（否则 `ENAMETOOLONG`）；建议远端直接差分只回传 JSON。

## 7. 尚未做

- 未约束端口的 IOB 归因实验（§4 的最小实验）；
- T19 表在 B6/C6/D6 与别的行上的交叉验证；
- `part_zero` 那 40 个 word 40 差异位的归属（是否邻近 slice 的默认 INIT）。

## 8. 本次实验的 manifest 机检

落库按 skill V2 门 7 的硬规则执行，产出两份 manifest 并用 `step03_pip/check_manifest.py` 校验：

| 文件 | 结论等级 | 校验结果 |
|---|---|---|
| `v7re/steps/t20_manifest.json`（INIT 映射，含 4 个构建的回读） | `verified` | PASS（15 ok / 0 warn / 0 fail） |
| `v7re/steps/t20_manifest_partpair.json`（封装对拍，133 帧差异走 `coverage_exclusion`） | `unverified` | PASS（14 ok / 1 warn / 0 fail） |

封装对拍必须声明 `parts_allowed`，否则校验器会把 `ffg1761-2` 判成「part 与 part_declared 不一致」——这个字段是校验器第一次跑时逼出来的。

下一步（T21，约 8 个构建）：B6LUT / C6LUT / D6LUT 各自的 `INIT=0` vs `0xDEADBEEFCAFEBABE`，加 `SLICE_X12Y21` A6LUT 一对，验 bel 与位置不变性；通过后才能把 T19 锁引脚表替换进 `build_site_frames.py`。详见 `STATUS.md` §51.3。
