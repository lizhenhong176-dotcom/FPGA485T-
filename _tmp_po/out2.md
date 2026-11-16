---
name: fpga-bitstream-experiment
description: Use when planning, running, or judging a Xilinx 7-series bitstream differential experiment in this repository — changing one attribute/PIP/LUT INIT on a fixed LOC/BEL, rebuilding with Vivado, diffing .bit files at frame/word/bit level, and deciding what a cell means. Covers LOCK_PINS, the three diff semantics, zero-value states, the self-check gate, and STATUS.md bookkeeping.
---

# 位级差分实验流程（本仓库通用）

目标器件：**xc7vx485tffg1157-3**（本项目全部探针 DCP / bitstream 实测 part；VC707 的 `ffg1761-2` 只在显式要求对齐时才用 `-part xc7vx485tffg1761-2` 构建）。帧结构：50,176 帧 × 101 字。

## 一、何时用 / 何时不用

**用**：要回答「改哪个属性会翻哪些位」「某段差分对应哪条 PIP / 哪个 LUT INIT 位」「这张表能不能用」这类问题。

**不用**：纯读文档、改解码器代码、只跑查询（`pip_query.py`、`decode_clb.py`）而不产生新构建。

## 二、强制门（任一门不过，本轮结论作废）

### 1 入场

- 读 `STATUS.md` 最近 2–3 个 § 与相关 `v7re/steps/*.md`，确认「这件事有没有做过 / 被证伪过」。
- 读 `REMOTE.md` 取当前远端地址（DHCP 会变）、用户、私钥、调用姿势。
- 写下本次实验的器件 part、tile/col/y、帧带；不许沿用旧文档的假定 part。

### 2 假设必须可证伪

写成：「在条件 C 下改 A，应只在集合 S 翻位；否则判失败，因为判据 D」。
缺少「失败如何判定」的假设不得进入构建。

### 3 设计（单变量 + 配对 + 声明）

- 单变量：一次只改一个属性 / 一条 PIP / 一个 INIT。
- 配对：基线（`INIT=0` 或未改动的同 DCP）与变体各一个；基线差分必须为 0。
- 固定 `LOC` / `BEL`，并对 LUT 施加 `LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`。**未施加 LOCK_PINS 的构建只能用于物理格集合，不得用于引脚索引表**（T13/T15 的表因此报废，见 T18）。
- 变体优先由**同一个 routed DCP** 生成，避免重新综合 / 布局引入 relocation 噪声。
- 声明差分语义：**PURE**（参考流已删 sink PIP）/ **XOR**（参考流仍含旧 PIP）/ **FAM**（整族删或加）。语义不明 → 判读不定论。
- 预先写明预期差分：数量级 + 落在哪些 frame_off / parity / word。

### 4 构建（远端三硬约束 + part 硬规则 + 环境/管脚/节奏硬规则）

- 脚本 **LF** 换行（CRLF 会被远端读成 `$'\r'` 形式并报错）。
- 脚本走 **stdin 管道**：`cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < script.sh'`；单条命令里不要放竖线（会被 cmd 抢走）。
- **不用 scp**（会挂死）；取回文件用 `tar czf - … | base64 -w0` 再本地解：base64 文本必须先落地到文件再解码，禁止塞进命令行参数（会超长 `ENAMETOOLONG`）；更省的做法是让远端直接用 bitstream 包做差分，只回传 JSON。
- **part 硬规则**：构建脚本必须显式写 `-part`（写出完整 part 串），禁止依赖默认 part；同时打印 `-part` 声明值，并回读 `PART` 做断言，不一致则该构建作废。原因：`/opt/lzh/v7re/work/locked/mk.tcl` 里默认写的是 `ffg1761-2`，与项目实际 part `ffg1157-3` 不符，靠默认会静默污染整批构建。
- **环境 locale 硬规则**：WSL 内直接跑 Vivado 会因 locale 未安装而 abort（rc=134，报错 `terminate called ... locale::facet::_S_create_c_locale name not valid`）。每个远端脚本开头必须写 `export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE`，缺此三行的脚本不得提交执行。
- **LOCK_PINS 管脚名硬规则**：LOCK_PINS 的 BEL 管脚名不按 BEL 命名，SLICEM 四个 6-LUT 的 BEL 管脚一律是 `A1..A6`；写 `I0:B1` 会 `ERROR: [Vivado 12-2497] invalid device pin 'B1'`。换 BEL 前必须先 `get_bel_pins` 实测该 BEL 的合法管脚名，再写进 LOCK_PINS，禁止凭命名规律臆造。
- **批量构建节奏硬规则**：多构建必须先在本地生成完整脚本，再一次性远端执行；本地工具显式抬高超时（≥300 s）；禁止逐条远端交互式下发命令。
- 每个构建必须回读并打印 `SITE` / `BEL` / `PART` / 被改属性值，进 manifest。

### 5 自校验门（判读前）

- 只采纳「SITE / BEL / 属性回读全部一致」的构建组；不一致的整组丢弃。
- **反读自证（集合级硬判据）**：用该构建族未参与训练的随机值（如 `0xDEADBEEFCAFEBABE`）反读，预测量与实测量必须**按集合比对**，同时满足 `missing=0` 与 `extra=0`；只允许集合级比较，**不许**只看命中数，**不许**抽样看几项。任一条件不满足即整批作废，**不许挑选性采纳**（T14 的教训）。
- **「未参与训练」的可操作定义**：该值不得出现在本构建族的任何设计文件中，也不得由这些值经线性组合或置换得到；若无法保证，改用新造随机值重做。
- **自证报告强制命令**：报告必须打印四个数——预测集大小、实测集大小、`missing` 数、`extra` 数；缺一即视为未完成自证。
- **差分种类归属检查**：内容位变化所属的帧/字集合必须与预期一致；同帧 ECC 字（word 50）的变化单独计数，不得混入内容位统计。
- **负对照最小形式**：同一设计、同参数重跑一次即可，不要求重复多次；但重跑必须用同一脚本、同一 part，且两次都打印回读。无改动构建的差分 = 0；不等 0 先查环境，不许直接判读。
- **交叉自证（hard rule）**：同一张表、同一结论，必须由另一个脚本、另一批独立生成的构建再复核一次；只做同源（同一脚本同一批构建）自证的，结论只能标 `unverified`，不得标 `verified`。
  - **为什么**：同源自证挡不住脚本自身的系统性错误（如 `LOCK_PINS` 写错、`-part` 写错）——两边一起错，命中率照样 100%；T19 可信是因为它用 T17 的独立构建复核了 6/6。
  - **判据**：交叉批次必须由不同脚本生成，且不得从被验证批次复制参数文件。
  - **报告格式**：「交叉批次名 / 构建数 / 一致数 / 不一致列表」，缺任一项即视为未完成交叉自证。

### 6 判读

- 位坐标一律写 `(frame_off, parity, bit)` 三元组；只用 `(frame_off, bit)` 统计会造出假共享（IMUX_L0 与 IMUX_L4 即 parity 不同）。
- 位全 0 必须分类：**默认源** / **互斥族外** / **未覆盖位**，三者不得混写。
- 地址律：`frame = block_start(col, region) + frame_off`；`word = 2*(Y%50)+parity`（≥50 再 +1 让开 ECC 字）；`bit = raw % 32`。
- 结论三色：`【硬件事实】` / `【数据事实】` / `【推断】`，一句一条，不混写。
- 不做无复测的跨位置推广；推广前先在同一方法下换 row / col 各测一次。
- **未解释差异处置纪律**：差分中出现无法归因的位/帧时，禁止用「不影响结论」结案；必须二选一——给出归因实验，或在结论中显式写明「本结论不覆盖这 N 帧 / M 位」。
- 必须报告三项：未解释帧数、未解释位数、这些位所在的帧区间；并说明它们与结论覆盖范围的差集关系。
  - **为什么**：历史翻车（T13）就是「大部分自洽 + 一小块没解释」被当成没问题，最后整张表报废。

### 7 落库

**Hard rule**：任何实验落库时必须同时产出 manifest JSON（schema 见 `reference/manifest.schema.json`），并用 `step03_pip/check_manifest.py` 校验到 PASS；FAIL 或 WARN 未处置的实验不得写进 STATUS.md 当结论。
  - **为什么**：手工抄结论无法机检；T13 的错表正是因为没有可机检的落库格式，一直流到 T19 才发现。

- STATUS.md 追加实验小节：构建清单、差分结果、三色结论、未测项。
- **状态文档编辑硬规则**：禁止 read 全文 + write 全文回写 STATUS.md 一类中文长文档（read 有行数上限，回写必然截断，历史上曾把 1773 行截成 811 行）。追加内容用 Python `open(..., 'a', encoding='utf-8')`；定点修改用 edit；写前先备份；写完必须用「行数 + 标题数」双重校验，与预期不符即视为落库失败并回滚。
- 实验细节写 `v7re/steps/T<n>_*.md`。
- 脚本留在 `step03_pip/`（探针 `_t*.sh` / 解析 `*.py`）。

### 8 交付

- 一句话结论 + **结论等级**（`verified`：同源自证 + 交叉自证都过；`unverified`：只过同源自证）+ 等级判定依据 + 可复现命令（构建 + 差分 + 反读）+ 未测清单。
  - **为什么必须写等级**：不写清，后人会把 `unverified` 当 `verified` 直接用（T13 表被当成可用表即为先例）。
- **适用域**：器件 part、行 / 列范围、构建条件（是否 LOCK_PINS、是否同 DCP）；域外标「未测」。
- 每条结论附「可证伪它的最小实验」；没有下一步实验的结论视为未完成。
- 字节级与帧级对账分开报告：帧级 0 差异 ≠ 字节级 0 差异（头部时间戳、尾部 CRC 是已知噪声）。
- **未解释差异**：未解释差异的帧 / 位区间必须逐条列出，或明确列入「未测」清单并点名；不得静默略过。

## 三、常用入口

| 用途 | 路径 |
|---|---|
| 解帧 / 差分 | `v7re/scripts/parse_bit.py`、`v7re/scripts/diff_frames.py` |
| FASM ↔ bit | `v7re/scripts/fasm2bit.py`（互斥 + 地址 + 增量 ECC） |
| 解码 / 查表 | `step03_pip/decode_clb.py`、`step03_pip/imux_decode.py`、`step03_pip/pip_query.py` |
| 复用规则 | `step03_pip/REUSE_RULES.md` |
| 现状 / 坑 | `STATUS.md`、`CHEATSHEET.md` |
| 远端 | `REMOTE.md` |
| **踩坑与硬约束的唯一外置清单** | **`reference/commands.md`**（ssh / 并行构建 / 差分 / 回传 / 报错；所有远端环境陷阱与命令姿势以该文件为准，门 4 各硬规则如与之冲突，以本 SKILL.md 为准并回补该文件） |
| 落库 manifest 校验 | `step03_pip/check_manifest.py`、`reference/manifest.schema.json`、示例 `v7re/steps/t20_manifest.json` |

## 四、历史翻车对照

| 现象 | 真实原因 | 处置 |
|---|---|---|
| 同一位置三次测量三张表 | 未锁引脚 + 未做 SITE/BEL 回读核对 | 反读自证失败即整批作废 |
| 表自洽但解码真实设计全错 | `LOCK_PINS` 缺失，索引是当次 placer 的逻辑顺序 | 表必须标注引脚分配条件 |
| 「形状随 CLB 类型变」 | 把 XOR 差分当 PURE 解读 | 设计阶段先声明差分语义 |
| 「每格被两个 family 共用」 | 统计漏掉 parity | 一律三元组统计 |
| 帧级完全一致但字节差 11 处 | 头部时间戳 + 尾部 CRC | 分两级报告，CRC 标未解 |
| Vivado rc=134，locale::facet abort | WSL locale 未安装 | 脚本头强制 `LANG/LC_ALL=C.UTF-8` + `unset LANGUAGE` |
| `[Vivado 12-2497] invalid device pin 'B1'` | 按 BEL 命名臆造 LOCK_PINS 管脚 | SLICEM 6-LUT 管脚一律 A1..A6，换 BEL 前 `get_bel_pins` 实测 |
| STATUS.md 从 1773 行被截成 811 行 | read 全文 + write 全文回写中文长文档 | 追加用 append，定点用 edit，写前备份，行数 + 标题数校验 |