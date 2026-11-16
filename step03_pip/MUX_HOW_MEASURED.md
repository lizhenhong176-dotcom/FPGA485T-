# 多源 mux 的配置位是怎么测出来的（Vivado 受控差分 + 集合级自证）

> 生成：2026-11-11 15:42，按 `PROMPT_MUX_HOW_MEASURED_V2.md` 执行
> 器件：探针实测 `xc7vx485tffg1157-3`；VC707 对齐时才显式 `-part xc7vx485tffg1761-2`
> 帧结构：50,176 帧 × 101 字（`word 50` 是 ECC）
> 标注：【硬件事实】物理结构｜【数据事实】本机实测｜【推断】我的解释，附可推翻条件
> 结论等级：`verified` = 同源自证 + 交叉自证都过；`unverified` = 只过同源自证

**一句话总账**：【数据事实】INT tile 的 3,737 条 PIP 聚成 216 个目的、其中 172 个是多源 mux（扇入 10/12/16/18/20/24），这 172 个 mux 的「哪个 bit 选哪条源」由 3,634 条连接 / 1,598 个物理格承载；3,456 条（95.1%）已能由名字生成且 0 差异，其余 178 条仍查表。

---

## 一、多源 mux 是什么

【硬件事实】PIP 是两段 wire 之间由配置 SRAM 位控制的可编程连接点。**mux = 共用一个目的 wire 的一组 PIP**，组内互斥（同一目的 wire 只能接一个源）——这是电路事实，不是我们的定义。

【数据事实】一个 `INT_L` tile：600 条 wire、**3,737** 条 PIP、216 个目的 wire。其中 172 个目的扇入 >1，合 **3,693** 条 PIP；44 个扇入=1 的直通；`law_cells` 记 3,634 条＝3,693 − 59 条 `VCC_WIRE` 常量输入。对账：`3,634 + 59 + 44 = 3,737` ✔

| 扇入档 | 族数 | 典型族名 |
|---|---|---|
| 24 | 64 | `IMUX_L0..IMUX_L47`、`BYP_ALT0..7`、`FAN_BOUNCE*` |
| 20 | 96 | `EE2BEG0`、`WW6BEG2`、`SE6BEG1`…（方向线起点，每种 4 变体） |
| 18 | 2 | `LVB_L0`、`LVB_L12` |
| 16 | 6 | `CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1` |
| 12 | 3 | `LH0`、`LH12`、`LV_L18` |
| 10 | 1 | `LV_L0` |

【数据事实】每条连接平均占 2.45 个格、每个格平均被 5.57 个族共用；2,818 条 2 格连接 + 816 条 4 格连接 = 3,634。

---

## 二、三条数据链：图 / 码 / 真值

| 链 | 给什么 | 来源与落点 | 错了的症状 |
|---|---|---|---|
| **A 图** | 谁和谁在同一个 mux 里（族集合、3,737 条 PIP） | Vivado 器件库 → RapidWright 2026.1（JPype，`v7re/routing/env.py:95-100`）→ `step1_topology.py export`（`v7re/routing/topology.py:27-54`）→ `templates/INT_L.json`（600 `wire_defs` / 3,737 `pip_defs`）→ 按目的 wire 聚合 172 族 | **不影响自洽性**：族划分错但位流也对，生成器照样 0 差异、真值召回率看不出，只有换器件/换类型才暴露 |
| **B 码** | 哪个 bit 选哪条源 | 受控差分（本文第三节）→ 差分 JSON → 归一化成 `(frame_off, parity, bit)` → `law_cells` | 立刻可见：差分集合对不上、反读自证 `missing/extra≠0`、生成器 0 差异判据直接失败 |
| **C 真值** | 每个设计真实点亮了哪些 PIP | Vivado `get_pips -of_objects [get_nets -hier]` → `tamper/ref/pips_all.txt` | 真假值不可分：召回率与精度同时失真，只能靠交叉支路对比 |

【数据事实】**join 点**：A 给的是 `(族名, 源 wire 名)`，B 给的是 `(tile, frame, word, bit)`；两者按**同一次构建的 `.pips` 与 `.bit` 对齐**才落到具体某族某源。第 3,634 条的最终格式是 `(tile_type, family, src_wire) → {(frame_off, parity, bit)}`，键里不含坐标。

【推断】图与码是**互相独立的两条链**，所以「两边一起错还能自洽」的风险只存在于图这一侧（码侧一错就与差分集合冲突）。要推翻这句：找出一个图错但码侧检验全部通过、且真值召回率不变的例子。

---

## 三、Vivado 精准控制差分

目标：**一次只动一个变量**，让位流差异只可能来自这一个变量。

### 3.1 约束清单（命令 / 为什么 / 失败时看到什么）

| # | 约束 | 为什么 | 失败时的原始报错 |
|---|---|---|---|
| 1 | 构建脚本显式写 `-part xc7vx485tffg1157-3` | 远端 `/opt/lzh/v7re/work/locked/mk.tcl` 默认写的是 `ffg1761-2`，靠默认会静默污染整批 | 不报错，**静默**；只能靠回读 `PART` 断言抓 |
| 2 | 构建后回读并打印 `SITE` / `BEL` / `PART` / 被改属性 | 静默回退无法从产物看出 | 不报错（回读值不符即整组作废） |
| 3 | `set_property LOC SLICE_X8Y11` + `set_property BEL A6LUT` | 位置不固定，差分里会混入 relocation 噪声 | 位流差异跨很多帧，无法归因 |
| 4 | `set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}` | 不锁引脚，placer 会自由重排 `I0..I5`，索引变成当次布局的逻辑顺序 | 无报错但表不可用（T13/T15 因此报废） |
| 5 | 换 BEL 先用 `get_bel_pins` 实测管脚名 | LOCK_PINS 的管脚名不按 BEL 命名，SLICEM 四个 6-LUT 一律 `A1..A6` | `ERROR: [Vivado 12-2497] invalid device pin 'B1'` |
| 6 | 变体由**同一个 routed DCP** 生成 | 重新综合/布局会引入 relocation 噪声 | 差分跨帧、无法归因 |
| 7 | 基线配对：不改的构建重跑一次，差分必须 0 | 负对照，证明流程本身不产生差异 | 差分≠0 → 先查环境，不许判读 |
| 8 | 先声明差分语义：PURE / XOR / FAM | PURE=参考流已删 sink PIP；XOR=参考流仍含旧 PIP；FAM=整族删/加 | 语义不明 → 判读不定论（把 XOR 当 PURE 会误判「形状随 CLB 型变」） |
| 9 | 远端脚本头写 `export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE` | WSL 无 locale 时 Vivado 直接 abort | `terminate called after throwing ... locale::facet::_S_create_c_locale name not valid`，`rc=134` |
| 10 | 脚本 LF 换行 + 走 `bash -s` stdin，不用 scp | CRLF 被读成 `$'\r'`；scp 会挂死 | `bash: ...: $'\r': command not found` |
| 11 | 改完布线用 `route_design -preserve` 再 `write_bitstream` | 保留原布线，只让被改的属性生效 | DRC 报错（见 #12） |
| 12 | 篡改类构建把 DRC 降级：`NSTD-1`/`UCIO-1` → Warning、`CFGBVS VCCO`、`CONFIG_VOLTAGE 3.3` | 这些 DRC 是 run-context 属性、不随 DCP 保存，必须每次重设 | `ERROR: [DRC NSTD-1] ... 30 out of 30 logical ports` / `UCIO-1` |

### 3.2 一次完整实验的命令序列

```tcl
# mk.tcl —— 由同一个 routed DCP 派生变体，只改一个属性
open_checkpoint  {/opt/lzh/v7re/work/locked/routed.dcp}
set_property LOC      SLICE_X11Y20                        [get_cells u_lut]
set_property BEL      A6LUT                               [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
set_property INIT     64'h0000000000000001                 [get_cells u_lut]   ;# 唯一的变量
route_design -preserve
write_checkpoint -force /opt/lzh/v7re/work/exp/routed_v1.dcp
write_bitstream  -force /opt/lzh/v7re/work/exp/v1.bit
report_property  [get_cells u_lut]                          ;# 回读 INIT/LOC/BEL
puts "PART=[get_property PART [current_design]] SITE=[get_property LOC [get_cells u_lut]]"
```

```bash
# 差分（位级，排除头部 102 B 与尾部 CRC；只比 FDRI 载荷）
python v7re/scripts/parse_bit.py  /opt/lzh/v7re/work/exp/v1.bit --json v1.json
python v7re/scripts/parse_bit.py  /opt/lzh/v7re/work/exp/base.bit --json base.json
python v7re/scripts/diff_frames.py v1.json base.json --triplet   # 输出 (frame_off, parity, bit)
```

```bash
# 一次批量构建（本地生成完整脚本后一次性远端执行，禁止逐条交互）
cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < build_all.sh'
```

---

## 四、定位规则：差分格怎么变成「某族某源的位」

| 规则 | 内容 | 违反后的症状 |
|---|---|---|
| 三元组 | 位坐标一律 `(frame_off, parity, bit)` | 只用 `(frame_off, bit)` 会造出假共享（`IMUX_L0` 与 `IMUX_L4` 就是 parity 不同） |
| 地址律 | `frame = far_bands[(band,col)].start_frame + frame_off`；`band = band_by_region[Y//50]`，表 `[6,5,0,1,2,3,4]`；`frame_off` mux 族 16..25、BEG 族 6..15 | 落到错帧，整张表错 |
| word 律 | `word = 2*(Y%50) + parity`，**≥50 则 +1** 让开 ECC | 漏 +1 → 22 个「表外位」（脚本漏位移的经典翻车） |
| ECC 排除 | 差分里 `word == 50` 的格一律剔除 | 混入 → 每个源凭空多 4–20 个「数据格」 |
| 零位三分类 | 位全 0 要分：**默认源** / **互斥族外** / **未覆盖位** | 混写 → 分不清「没选」和「没测到」 |
| 未解释差异 | 禁止用「不影响结论」结案：要么给归因实验，要么写清「本结论不覆盖这 N 帧 / M 位」 | T13 就是这样把错表放过的 |

【数据事实】mux 族位池实测：`frame_off 16..25` × 2 parity × 32 bit = 1,664 位；`IMUX_L40`（24 源）只占 10 个格（`parity 0`、`bit=[6,6,7,7,6,6,6,6,6,6]`）；组选择位在 `frame_row = 16+r`（**384/384 行格 0 例外**），列码位在 `frame 25−i`，合法码只有 `{1,2,7,11}`。

---

## 五、验证阶梯（每级都要能自证有效）

| 级 | 判据（分子/分母） | 反例设计（刻意做错，看是否被抓） | 状态 |
|---|---|---|---|
| 1 集合级反读自证 | 预测集 vs 实测集：`missing=0` 且 `extra=0` | 故意漏掉一个 parity 位 → 预期 `missing≠0` | 已验证 |
| 2 负对照 | 同参重跑差分 = 0 | 故意改一个无关 LUT INIT 位 → 预期差分≠0 | 已验证 |
| 3 交叉自证 | 另一脚本 + 另一批独立构建复核 | 只用同脚本同批构建 → 预期只能标 `unverified` | 已验证（T19 用 T17 的独立构建复核 6/6） |
| 4 外部真值 | 召回 1,155/1,263 = 91.45% | 故意让解码漏一类 PIP → 预期召回率跃变 | 已验证 |
| 5 全器件外推 | 12,565 tile / 64,686 位置外 **0** | 地址律漏 +1 位移 → 预期出现表外位 | 已验证 |
| 6 误报与对抗 | 单 bit 穷举 1,624,720/1,633,808 = 99.4438%；幽灵 mux 0/300；整条删除 8/300；换源 18/300；word50 0/300；LUT INIT 真篡改 0 检出；干净位流误报 120/982 tile（12.22%，白名单后 0） | 把 XOR 差分当 PURE 读 → 预期出现「形状随 CLB 型变」假象 | 已验证/已跑过 |
| 7 跨类型与跨器件 | `INT_R` 命名归一后 172/172；其它 tile 类型 2/115；跨器件 0/1 未测 | 不做命名归一 → 预期 `INT_R` 只到 63.6% | 已跑过（跨器件从未跑过） |

【数据事实】反读自证的四数必须打印：预测集大小、实测集大小、`missing`、`extra`，缺一视为未完成。**禁止只看命中数、禁止抽样。**

---

## 六、失效条件：做法 → 假结论

| 做法 | 会造出的假结论 |
|---|---|
| 不锁 LOCK_PINS、只固定 LOC/BEL | 「同一位置三次测量三张表」；表自洽但解码真实设计全错（索引是当次 placer 的逻辑顺序） |
| 不回读 `PART`/`SITE`/`BEL` | 用了默认 part（`ffg1761-2`）静默污染，整批构建作废都不自知 |
| 重新综合/重新布局生成变体 | 差分跨多帧，把 relocation 噪声当成配置位 |
| 把 XOR 差分当 PURE 读 | 「形状随 CLB 类型变」——实际是旧 PIP 仍留在参考流里 |
| 统计漏 parity | 「每格被两个 family 共用」，实际是 parity 0/1 两套格 |
| 不排除 `word 50` | 每源多出 4–20 个「数据格」，全部是 ECC 重算 |
| 位平面法（整体翻一个位平面） | 优化器会把整个位平面反相，读出的规律是真规律的补集 |
| 抽样看命中、只看命中数 | 集合级 `missing/extra` 掩盖，T14 教训：不许挑选性采纳 |
| 检验器自身没被检验 | 22 个「表外位」连续两轮误导方向（脚本漏 `+1` 位移） |
| 帧级 0 差异就当字节级一致 | 头部时间戳 2 B + 尾部 CRC 4 B 差异被忽略 |

---

## 七、能推广到哪、不能推广到哪

- 【数据事实】**已验证**：`INT_L` / `INT_R` 各 26,550 实例共用一张 172 族表，`verify_all_pip --normalize` 两侧均 172/172、mux 1,536/1,536、beg 2,098/2,098。
- 【数据事实】**已跑过**：跨 tile 类型 2/115（仅 INT 两种）；按 PIP 数算只有 7,474/35,126 = 21.3%。
- 【数据事实】**未测**：跨器件 0/1；其它 113 个 tile 类型一个都没做完整位库；ECC 地址项 `A(frame_addr)` 未解（秩 143、矛盾）。
- 【推断】能推广的边界：只要「族 = 一个目的 wire 的互斥源集合」这个定义成立，分族法就能搬；但**组×码维度、位池帧区、合法码集合**这三样是逐类型实测的，不能假设相同。推翻方式：在 `CLBLL_L` 上跑同一套 `gen_slots`，0 差异率 <50% 即证否。

---

## 八、一次完整实验的端到端时间线（真实构建）

以 2026-11-09 的 `HCLK_CMT` 多源 mux 探测为例（族 `MUX_CLK_13`，48 源，dst wire `HCLK_CMT_MUX_CLK_13`）：

| 步 | 输入 | 产物 | 这一步错了，后面哪步会暴露 |
|---|---|---|---|
| 1 取族与源清单 | `templates/HCLK_CMT.json`（982 `pip_defs` / 72 dst） | `v7re/steps/hclk_sources.json`（982 PIP、42 个多源 dst、`MUX_CLK_0..13` 各 48 源） | 第 5 步差分集合与族对不上 |
| 2 设计单变量构建 | 基线 `k0`（选 `MMCM0`）与变体 `k1..k6`（选 `MMCM2/4/6/8/9/10`） | `/opt/lzh/v7re/work/hclk5/out/k0..k6.bit`、同名 `.pips` | 第 4 步 `.pips` 里 dst 不是 `MUX_CLK_13` |
| 3 受控差分配对 | `k_i` vs `k0` | 差分格数（含 ECC）：`k1=8`、`k2=24`、`k3=24`、`k4=26`、`k5=16`、`k6=10`；帧 22,144 / 22,145 / 22,147 | 若同一源两次测出不同格集合 → 单变量假设破 |
| 4 剔除 ECC | 上表 | 每源 4–6 个数据格（其余是 `word 50` 重算，`k1` 4 个、`k2` 4 个、`k4` 6 个…） | 不剔除会在第 5 步出现「一族被 20 个格表示」的荒谬结果 |
| 5 归一化到 tile 内坐标 | 帧号 + `far_bands`（band4 col33 基址 22,118；band6 col33 基址 32,610） | `(frame_off 26..29, word, bit)` | 落在帧区之外即地址律错 |
| 6 与真值对齐 | `.pips` 行 `HCLK_CMT_MUX_CLK_MMCM0 ->> HCLK_CMT_MUX_CLK_13` | 确认这 4–6 个格确实属于该 PIP | 真值里 dst 不同 → 差分对应错了 mux |
| 7 结构判读 | 上面 13 个源（MMCM 7 + PLL 6） | MMCM 组槽位在 `frame_off 29` 的 word 27/28/29/30（每字两半区：高半 bit25、低半 bit9）＝8 槽一热；PLL 在 `frame_off 28` 的 word 76..79 同构 | 若一热编码不成立（一个源点亮两槽）→ 组结构判断错 |
| 8 跨实例复核 | `band6 col33`（X88Y26）的 `g0..g2` | MMCM0/2/4 的 `off26/27` 字值与 band4 **逐字节相同** | 若不同 → 码字与实例有关，结论只对一个 tile 成立 |
| 9 边界声明 | — | 仅覆盖 `MUX_CLK_13` 的 13/48 源；dst 独立性造不出（`MUX_CLK_k` 按时钟区域分配，14 个区域 ↔ 14 个 dst） | — |

【数据事实】该组的构建号与差分数量：`hclk4` = `g0/g1/g2`（8/24 格）、`hclk5` = `k0..k6`（8/24/24/26/16/10 格）、`hclk6` = `p0..p5`（对 `c_a` 各 1,254–1,262 格 → 说明 PLL 组必须 `p_i vs p0` 受控配对，不能对 `c_a`）。

---

## 附：命令与文件索引

- 位库 / 地址表：`E:\v7work\model\v7_law.sqlite`（`law_cells` / `law_tiles` / `far_bands`）；器件库 `E:\v7work\model\v7_model.sqlite`（`frame_map`）。
- 复算：`python v7re\scripts\verify_all_pip.py --tile-type INT_L --normalize`；`python step03_pip\gen_mux.py`；`python step03_pip\gen_slots.py`。
- 差分与落库流程：`.agents/skills/fpga-bitstream-experiment/SKILL.md`（门 1–8）、`reference/commands.md`（远端所有坑）、`step03_pip/check_manifest.py`（落库机检）。
- 证据链：`v7re/steps/PIP_BIT_REUSE_REPORT.md`（E1–E8，含 12,565 tile / 64,686 位 / 表外 0 与 50,176 帧全等实验）。
