# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

更新：2026-11-11（最新：S47–S50 —— IOB 属性位、IO pad 字段、OLOGIC 非家族、时钟网定位）

目标：XC7VX485T-2FFG1761（VC707）比特流逆向。
主线（2026-11-08 起，用户口径）：**PIP 复用分析** —— 复用发生在哪几层、复用规律是什么、这套规律能否反过来生成/判定位库（见 §97）。
**第一优先度（2026-11-11 决策）**：主线即唯一第一优先度；优先序与「明确不做」清单见 §161。
前序（RapidWright 拓扑 → PIP→bit 差分 → frame/bit 数据库）已完成，作为支撑；
**旁支**（不在主线）：ECC 与帧地址耦合、`site_frames` 补全、跨 tile 类型位库迁移、篡改定位器上板。

> 本文件是正常 UTF-8。2026-10-25 曾因 PowerShell 5.1 以 ANSI 读取再写回出现一次双重编码，已重写修复；
> 之后确认过：用 `Get-Content` 直接读会显示乱码，那是控制台按 GBK 解码造成的**显示**问题，文件本身没坏。
> **编辑中文文档仍请用 `[IO.File]::WriteAllText(..., UTF8)` 或带 `-Encoding utf8` 的方式。**


---

## 0. 当前进度总览（2026-11-11）

### 0.1 子系统覆盖

| 子系统 | 规模 | 位表状态 | 验证强度 | 缺口 |
|---|---|---|---|---|
| **INT 互连** | 53,100 tile | 172 族/侧，1,598/1,664 格（96.03%） | 6/6 输入网 token 级与 Vivado ROUTE 一致；181 PIP 解码 0 歧义；S16 逐位 2,035/2,035（含 421 sense=0），负对照 2/698 | off0..3 的 66 格（GCLK 直通/BYP 旁路族）；END 侧位表（Vivado 多出 111 族，已证**不占位**） |
| **CLB 逻辑** | 75,900 slice | 62 特征；INIT 4 帧 off32..35；FF 30/31 | e0/e7 解出 INIT 64/64 精确；s8 网表复原 | CE/SR/CLKINV mux、A5FFMUX、DI1MUX、CARRY4 CY0 |
| **BRAM** | 1,030 tile | 60 三路 mux（off26，三态码 `C=A&!B` 全验证）；INIT_xx → 帧 46716+xx（36 位宽，步长 1） | 三态 60/60 直接观测；FIFO 属性 5 族 + ZEMPTY/ZFULL 13/13 | 29 个 FIFO 属性位（EN_SYN/FWFT 已验证，余下按码表补） |
| **DSP** | 1,400 tile | 78 三态族（GND/VCC/走线），基址 31960，28 帧 | **78/78** 绝对态判读通过（单 site 39 + 双 site 78） | 280 个属性位（AREG 等已验 4 条） |
| **IO pad** | 700 pad | 属性：`law_iob` 37 行（PULLTYPE/DRIVE/SLEW/IOSTANDARD）；逻辑：io72 off0..33 @ pad 行字 | 9 个变体差分；OLOGIC 6 变体矩阵 | IDELAY/ISERDES/OSERDES（placement 受限未测）；其余 pad 属性（IN_TERM/ODT） |
| **IO↔fabric 通路** | 700 通路 | **无配置位**（纯 tileconn） | `get_pips` 单源全固定；A4 缺口已补齐后 6/6 | — |
| **时钟网络** | edge30/HCLK | edge30 off26..29 = 29 格（时钟进 fabric 时固定出现） | 三设计共有、两设计为 0 | BUFG/BUFH/CMT/CLK_FEED 未测 |
| **GTX / PCIE** | 1,120 + 700 | 未开始 | — | 全部 |

### 0.2 编码形态（全片最终四类）

| 形态 | 对象 | 判据 | 反解 |
|---|---|---|---|
| 家族（one-hot 网格） | INT PIP、IMUX、AFFMUX、DSP GND/VCC、BRAM CASCIN | `N=a×b`、`K=a+b`、每源 2 位 | C1/C2 + CSP |
| 单位开关 | OLOGIC INIT、ZINI/ZRST、BYP/FAN 旁路、GCLK 直通 | 1 位 = 1 特征、可共现 | 直接读位 |
| 码字 | PULLTYPE/DRIVE/SLEW/IOSTANDARD、ZALMOST_*、LUT INIT | 每值一组固定位、无网格律 | 码表比对 |
| 时钟网络 | edge30 off26..29 | 与“是否有时钟进 fabric”相关 | 静态推断 |

### 0.3 地址模型（已三次独立印证）

```
frame = 块基址 + frame_off
word  = wof(Y) + parity ,  wof(y) = 2*(y%50) + (1 if y%50 >= 25 else 0)
bit   = raw % 32
块清单：frame_blocks 1,038 块 / 36,260 帧 = 7 × 5,180（每 band 精确闭合）
```

`tile_blocks` 53,102 行（INT 全量派生 + 实测锚点）；`tile_block_gt` 45 条地面真值。

### 0.4 已验证的闭环（可引用的“硬证据”）

1. **6/6 输入网**：bitstream → 解码 → 走线复原，token 级与 Vivado `ROUTE` 完全一致（含 IO 入口段）。
2. **写回 864/864**：按表写位后硬件不报错、载荷与理论一致（含 ECC 位）。
3. **181 PIP / 0 歧义**；S16 反向检验 366 TP / 0 FP / 0 AMBIG / 6 FN（全为 always ppip）。
4. **LUT INIT 64/64**：e0/e7 两份 bitstream 解出 `0x9E3779B97F4A7C15` 与设计真值逐位一致。
5. **DSP 78/78**、**BRAM 三态 60/60**、**FIFO 阈值 26/26**（ZEMPTY 13 + ZFULL 13）。
6. **审计**：clb 未知格 = 0；io72 残差已归属为 IOB 属性/逻辑 + 时钟网，非 PIP 位。

### 0.5 关键文件

| 内容 | 文件 |
|---|---|
| 路由/选择律总表 | `step03_pip/ROUTING_SELECTION.md`（§6 位域边界含四类形态） |
| 解码器 | `v7re/tilemap.py`、`step03_pip/decode_clb.py`、`emit_netlist2.py`、`csp_imux.py`、`s13_solve2.py` |
| 最新报告 | `S47_IOB_ATTR.md`、`S48_IO_LOGIC_REGS.md`、`S49_OLOGIC_SPLIT.md`、`S50_OLOGIC_NOT_FAMILY.md` |
| 律库 | `E:\v7work\model\v7_law.sqlite`（`v7_verified` 126、`law_iob` 37、`io_features` 5、`frame_blocks` 1,038） |

---

## 1. 位置

| 内容 | 位置 |
|---|---|
| 项目代码 | `E:\DEEPSEEK\FPGA比特流逆向`（`v7re/`、`step03_pip/`、`tools/`） |
| 路由模型 | `E:\v7work\_curated_20261021\routing\v7_routing.db`（1.2 GB） |
| 模型库 | `E:\v7work\model\v7_model.sqlite`（`pip_bits` 3,528 行 = `tilepipe_20261025` 3,504 + `step03_pip_20261024` 24；`imux_codes` 2,304 行；`bit_map` 28 行） |
| prjxray 导出 | `E:\v7work\db\prjxray\xc7vx485t\`（tilegrid / tileconn / tile_type / ppips） |
| 远端机器 | **`172.17.70.41`**（DHCP，会变；旧 `172.17.71.129` 已失效）；用户 **`s.tschai`**；私钥 `C:\Users\i\.ssh\v7remote`；别名 `ssh fpga`。**完整记录与重连流程见 [REMOTE.md](REMOTE.md)** |
| 远端 WSL | Ubuntu 20.04（`C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root`）；Vivado 2017.2 `/opt/lzh/Xilinx/Vivado/2017.2`；venv `/opt/lzh/venv`（Python 3.8.10 + RapidWright） |
| 远端实验 | `/opt/lzh/step03/`（26 个目录，清单见 [REMOTE.md](REMOTE.md) §5） |
| 仓库 | https://github.com/lizhenhong176-dotcom/FPGA485T-.git（origin 已配） |

---

## 2. 远端环境用法

> **权威版本在 [REMOTE.md](REMOTE.md)**（当前地址/用户/私钥、三种调用姿势、DHCP 换址后的重连流程、远端数据清单）。
> 这里只留最常用的两行。

```bash
"C:\Program Files\WSL\wsl.exe" -d Ubuntu -u root -- bash -lc "<命令>"   # System32 下的 wsl.exe 是 stub

export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source x.tcl
```

从本机跑远端脚本（**推荐姿势**，2026-10-27 实测）：

```powershell
cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < "E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_recon.sh"' 2>&1 | Out-String
```

坑：

- SSH 默认 shell 是 **cmd.exe**，嵌套引号会被吃、`|` 会被 cmd 抢走 → 脚本走 stdin 管道（上面那条），
  单条命令里**不要放管道**。
- 脚本必须 **LF**：`Out-File -Encoding ascii` 产生 CRLF，远端报 `$'\r'`；用 write 工具或 `newline='\n'`。
- PowerShell 不支持 `<` 重定向，所以外面要套 `cmd /c`；PowerShell 自己的 `>` 写出 UTF-16，解码要按 `utf-16`。
- **scp 会挂死**，取文件用 `tar czf - … | base64 -w0` 再本地解。
- 远端 PowerShell 没有 `tail`，用 `Select-Object -Last N`。
- RapidWright 的 pip 包会去 github.com 下 jar（不通），已用本机 `rapidwright-2026.1.1-standalone-win64.jar` 改名 `lin64` 放进 site-packages。
- 中文文件读写一律走 .NET API（见文首）。

---

## 3. 已完成

> ⚠ **本节内容截至 2026-10-27，已被 §96「PIP 线进度总表（2026-11-08）」取代**。真实进度看 §71 / §92 / §94 / §96，以及 `step03_pip/PIP_PROGRESS_20261108.md`。原文保留作历史，勿据本节判断当前状态。


### STEP01 拓扑
150,380 tiles / 115 类型 / 56.8M wires / 207M PIPs；`Tile.getWireConnections` 提供跨 tile 连接。

### STEP02 跨 tile 连接
corridor 规则（全设备 0 conflict）+ 精确边表 `edges_exact` 39,923,710 行，全量校验缺失/多余均为 0。

### prjxray 对齐
`tilegrid.json`(150,380)、`tileconn.json`(17,928 条 / 148,622 pair)、115 个 `tile_type_*.json`、39 个 `ppips_*.db`。
差异：坐标系是 RapidWright 全局网格；ppips 语义是 site pin→BEL，不是官方 site-wire 伪 PIP。

### STEP03 PIP→bit（核心）

**帧地址**：`frame = base_address + 偏移`；每 config row 末尾 2 个 overhead 帧；总计 50,176 帧。
FAR：`[25:23] type / [22] top / [21:17] row / [16:7] col / [6:0] minor`。
`word 50` 是 ECC/校验区，**不是配置位**。

**IMUX 字段地址公式（36/36 拟合 + 24 留出全中）**：

```
word = 22 + ((L // 4) % 2)
bit  = 1 + 8 * (L % 4) + (L // 8)      # L = IMUX 编号
```

**每个 mux 的位池**：固定帧窗口（左列 31696–31705，右列 31732–31741）× 该 mux 的 2 bit 列 = 20 格。
25 个源共享这 20 格；跨 mux 位池不相交（6 个 mux 验证过）。

**两层结构（2026-10-25 发现）**：

1. 每个 mux 有 **2 个使能单元**（任何非默认源都置位）：L8 是 cell 7 / cell 12；L2/L7 在窗口尾部。
2. 其余是**选择单元**，每个源置 0~2 个 → 掩码大小 0（默认源 NR1END0）、2、4。
3. L2 与 L7 掩码形状相近但存在**每 mux 帧基址偏移**。

**已否定的假设**：

| 假设 | 结论 |
|---|---|
| 同名 wire → 相同相对格 | ❌ GFAN0 在 L8/L2 不同 |
| 字母序序号 → 相同格 | ❌ 0/25 |
| PIP 声明顺序 → 相同格 | ❌ 0/25 |

**IMUX 物理输入序号（2026-10-25 解出，原 §5 待办 1）**：

- 24 个输入 = **6 行 × 4 列**：行 = `word 16..21` one-hot（行号 = 置位字 − 16）；
  列 = `word 22..25` 的四选一码 `0001 / 0010 / 1011 / 0111`（顺序即 col 0/1/2/3）。
- 依据：`prjxray_ref/artix7/segbits_int_{l,r}.db`（7 系列 INT 同构），48 mux × 24 输入/侧。
- 交叉验证：本机 485T 实测 36 mux × 24 源 = **864 条，行 864/864、列 864/864 全等**。
- 表：`imux_codes`（2,304 行 = INT_L 1,152 + INT_R 1,152；本地与远端库均已建），
  工具 `pip_query.py imux [IMUX_Lx]`；文档 `step03_pip/IMUX_INDEX_SOLVED.md`。
- 边界：INT_R 那 1,152 行尚无硅片实测对照；`idx=row*4+col` 是我们自己的编号，硅片只认 `(row, col_code)`。

**其他**：改 DCP 里的 site 内 PIP 不生效（bitgen 从网表+布局重推站点路由）；跨 tile PIP 生效。

### STEP03 收尾（2026-10-25 19:00–19:30）

- `tilepipe` 完成：36 mux × 25 源 = 900 个变体位流，`tilepipe.json`（131 KB）。
  - 2026-10-28 补齐 INT_L 侧 12 个 IMUX（详见 §5.5）→ INT_L_X6Y11 现 48 mux；INT_R_X7Y11 亦 48 mux（§5.5）。
- 入库：`pip_bits` 新增 2,628 行（`source=tilepipe_20261025`），本地与远端同步。
- 表结构统一整理（2026-10-25 晚，`step03_pip/migrate_pip_bits.py`）：
  - 坐标列 `frame/word/bit` 改为**可空**（原来被主键锁成 NOT NULL，只能塞 `-1` 魔数）；
    主键换成 `UNIQUE(device,tile,wire_a,wire_b,frame,word,bit)` 索引。
  - 新增 `kind`（`route` / `default`）与 `note` 列：**36 条「默认源」= `kind='default'` + 坐标 NULL**，
    不再用 `(-1,-1,-1)` 占位。
  - 旧观测的 tile 归属更正：`INT_L_X6Y11` 的 `NR1END0->>IMUX_L8` 4 行其实是 `CLBLL_L_X6Y11`
    （IMUX 属于 CLB tile）；与 tilepipe 结果完全重合，去重后保留一条。
  - 加 `(tile,wire_b)` 索引 + 视图 `pip_bits_mapped`（只看有位坐标的行）。
  - 结果：2,656 → **2,652 行**（2,616 route + 36 default），`PRAGMA integrity_check = ok`，远端同样迁移。
  - 注：12 个 `INT_L_X6Y*` 只有 1 条点测量（`LOGIC_OUTS->NR1BEG`），不是完整 mux 扫描，所以没有 default 行；
    36 个完整 mux（`CLBLL_L_X6Y11`）各恰好 1 个 default 源，符合预期。
- 导出：`step03_pip/export_pip_csv.py` → `out/pip_bits.csv`（2,652 行，含 kind/note）、`out/bit_map_tilepipe.csv`（2,616 行）。
- 迁移前备份：本地 `E:\v7work\model\v7_model.sqlite.bak-migrate`；
  远端 `v7_model.sqlite.bak-20261025`（注意那是入库前的版本，含 2,628 行的中间态只在本机备份里）。
- 工具：`step03_pip/pip_query.py`（`mux` / `pip` / `decode` / `stats`）。
- **端到端验证通过**：用 `ref_X8Y11_A6LUT_A1.bit` 反解，`CLBLL_L_X6Y11` 的 5 个 mux
  与 Vivado route 报告 **5/5 一致**：

  ```
  route: GFAN1->>L4  GFAN0->>L8  GFAN0->>L11  GFAN0->>L1  GFAN0->>L2
  decode: L4->GFAN1  L8->GFAN0  L11->GFAN0  L1->GFAN0  L2->GFAN0   (全部 EXACT)
  ```

**注意**：`bit_map` 的 `UNIQUE(device,frame,word,bit)` 与「一个 tile 内多 mux 共用帧窗口」冲突，
不要再把 PIP 位写 `bit_map`（1:1 放不下），全量保留在 `pip_bits` + `bit_map_tilepipe.csv`。

---

**写位验证（2026-10-25 晚）**：`step03_pip/imux_codec.py` 已能替代 Vivado 写 IMUX 配置位。
用 tilepipe 的 36 个 mux × 24 个源（864 个变体）逐字比对，配置位 word 0..49 **864/864 全等**；
右半 `CLBLM_R_X7Y11/IMUX6` 新做 24 个变体，与 `INT_R|IMUX6` 表**逐位相等 24/24**。
ECC（word 50 低 13 位）在 864 个变体里全部被 Vivado 重算，必须由我们补：用全部 2592 组样本拟合出
**54 个位置的 13 位列向量**（秩 54/54、残差 0，`step03_pip/ecc_table.json` + `fit_ecc_all.py`），
右半 24 个变体上 **72/72 帧预测正确**；`imux_codec.py write` 已默认调用 `imux_ecc.patch_frames()`。

**端到端**：读 `ref_*.bit`、用我们的编码器改写（清域+置源+补 ECC）、与 Vivado 的 `v_*.bit` 逐帧比对，
**18/18 变体 PAYLOAD-IDENTICAL**（帧区完全一致；文件头的时间戳本来就每次不同）。详见 `step03_pip/IMUX_WRITE_VERIFIED.md`。

---

## 4. 正在跑 / 最近一轮

> ⚠ **本节内容截至 2026-10-27，已被 §96「PIP 线进度总表（2026-11-08）」取代**。真实进度看 §71 / §92 / §94 / §96，以及 `step03_pip/PIP_PROGRESS_20261108.md`。原文保留作历史，勿据本节判断当前状态。


最近一轮（2026-10-27 晚）：**tilegrid bits 批量填充**。
用 PIP 侧地址律（`block_start` + `_word`）批量填了 91,050/91,050 个 tile 的 `bits` 字段
（INT_L/INT_R/CLBLL_L/CLBLL_R/CLBLM_L/CLBLM_R 六类），本地与远端各一份输出。
同时修复了 `pip_law.py` 的右半列折叠 bug（`col = (ba>>7)&0x7F` → 含 half 位）。
详见 §6.9。

上一轮（2026-10-27 下午）：**PIP 复用规则收尾 + 远端重连**。
产出 `step03_pip/REUSE_RULES.md`（总纲）+ `verify_reuse.py`（一条命令复现 3,270 条观测判定）
+ `reuse_stats.py`（复用度/分区/覆盖率）。详见 §6.7。

**远端已重新连上**（本轮前半段 `ssh fpga` 超时，原因是机器 DHCP 换址：`172.17.71.129` → `172.17.70.41`；
`~/.ssh/config` 的 `Host fpga` 已改指新地址/用户 `s.tschai`/私钥 `v7remote`，旧条目留档为 `fpga-old`）。
详见 §6.8 与 [REMOTE.md](REMOTE.md)。

已盘点 `/opt/lzh/step03` 全部 26 个目录（清单在 [REMOTE.md](REMOTE.md) §5）。**尚未拉回本地**的小文件：
`sweep1/pips_S_*.json`（24 个，每个 sweep 设计实际选用的 PIP 名单）、`fam/spec.json`、`fam/expected.json`、
`famr/spec.json`、`reuse3/p3_bits.json`、`reuse5/mux32_fields.json`。
其中 `sweep1/pips_S_*.json` + 本地 `sweep_obs.json` 可以做**多 PIP 线性叠加**验证（§6.1 的未覆盖项），
不需要跑任何新的 bitgen。

下一步实验（尚未开始）：见 §5 第 2、5、6、7 条。

---

## 5. 待办

> ⚠ **本节内容截至 2026-10-27，已被 §96「PIP 线进度总表（2026-11-08）」取代**。真实进度看 §71 / §92 / §94 / §96，以及 `step03_pip/PIP_PROGRESS_20261108.md`。原文保留作历史，勿据本节判断当前状态。


1. ~~**第 6 层：mux 内「物理输入序号」**~~ **已解（2026-10-25）**：见 §3 与 `step03_pip/IMUX_INDEX_SOLVED.md`；编码规则 = 行 one-hot(`word 16..21`) × 列四码(`word 22..25`)，864/864 实测对齐。INT_R 已完成硅片对照（IMUX6，24/24）。
1b. **ECC 全表**：现在只拟合了 IMUX 字段用到的位置；要写任意帧（LUT INIT、BRAM/DSP 配置）需要把 `ecc_table.json` 扩到全部 1600 位。
2. **BEL 级位**（下一个主战场）：`reuse4` 已铺好 BEL 级 DCP 的路（`synth_design -top top`）。待测 F7/F8、CE/SR/CLK 选择 mux、CARRY4、BRAM/DSP 配置位。
3. ~~批量扩展：tilepipe 流程推到更多 tile（跨列 / 跨 clock region）~~ **已完成**：
   7 个 clock region 全测（§6.6）、列扫描 6 列 + INT_R 4 列（§6.7）、
   `tilepipe`/`tp2`/`tp3` 三个 tile 共 1,872 条 PURE 观测全 EXACT。
4. STEP04：frame/bit 数据库生成器（含 `site_frames` 表）。
5. **补齐 12 个未测 IMUX / 侧**（`IMUX_L22/28/29/31/32/35/38/40/43/44/45/47`）：**INT_R 侧已完成（2026-10-27）/ INT_L 侧已完成（2026-10-28）→ 两侧 48/48 IMUX 全覆盖**
   - **INT_R_X7Y11 侧：已定位 base 并在跑 tilepipe。** 12 个缺口全部由 `SLICE_X10Y11` 的
     `C6LUT`(A1..A6→IMUX32/29/22/28/31/35) 与 `D6LUT`(A1..A6→IMUX40/45/38/44/47/43) 到达
     （X10 是 SLICEM）。`tilepipe_r/` 300 变体 + 12 ref 生成中，`_tp_diff.py` 后台 bitgen+diff。**已完成（2026-10-27）**：12 个 IMUX（22/28/29/31/32/35/38/40/43/44/45/47）全部补齐，184 源测量；清洗到 IMUX 字段（frame<50176、word 16..25）后 184 源 → 184 组互不相同 bit 集，0 冲突、0 空位；加上此前 36 个 → INT_R_X7Y11 的 48 个 IMUX 全有数据。产物 `tilepipe_r/tilepipe_r.json`（115KB）。分析陷阱：diff 含 frame-50176 的 CRC/帧尾位（每源约 15 位、word 1），按位分析须先过滤 word 16..25。
   - **INT_L_X6Y11 侧：已完成（2026-10-28），非"没测到"。** 已建 reach 探针确认：那 12 个 mux 其实由 `SLICE_X8Y11` 的 `C6LUT`(A1..A6→IMUX32/29/22/28/31/35) 与 `D6LUT`(A1..A6→IMUX40/45/38/44/47/43) 到达（X8Y11 实为带 C/D 的 SLICEM，非之前假设的 CLBLL_L，故早前"结构性未暴露"判断作废）。走同一 build_bel→p6_make→bitgen→tilepipe_diff 管线补齐：`tilepipe/` 现 48 个 INT_L tag、300 个新变体（12 mux × 25 源）。清洗到 IMUX 字段（frame<50176、word 16..25）后 **300 源 → 300 组互不相同 bit 集，0 冲突**；每 mux 恰 1 个空源 = `VCC_WIRE`（常量源，36 个旧 mux 同样各 1 个），非缺数据。产物 `tilepipe/tilepipe.json`。**→ INT_L_X6Y11 与 INT_R_X7Y11 两侧 48 个 IMUX 现已全有数据。** 已入库：`ingest_tilepipe.py` 以 48-tag `tilepipe.json` 重灌 `pip_bits` source=`tilepipe_20261025`（3,504 行 = 3,456 route + 48 default，48 个不同 mux，integrity ok，本地 `E:\v7work\model\v7_model.sqlite`；**远端已同步（2026-10-28 上午）**：gzip+base64+`tee` 通道推 `pip_bits_tilepipe.csv` 到远端 `/opt/lzh/v7re/data/model/v7_model.sqlite`，重灌 `tilepipe_20261025` 3,504 行（3,456 route + 48 default），远端核验 total=3,528 / wire_b=48 / default=48 / integrity ok，与本地完全一致；推送前远端旧库备份为 `v7_model.sqlite.bak_pre_push`（2,628 行中间态）。传输坑：`wsl -- bash -c "带空格/管道的字符串"` 会被 wsl 二次拆分（引号失效），远端命令只能是单条无引号命令——数据用 `tee /tmp/xxx` 走 stdin、逻辑写脚本先 `tee /tmp/x.sh` 再 `bash /tmp/x.sh`；~380KB 裸 heredoc 会截断在 ~1.3KB。
6. **非 IMUX 家族的多源覆盖**：**已完成（2026-10-27）**。每族测 4 个源，两侧各 496 变体
   （`spec_multi_INT_L/R.json`），驱动 `_fam_multi2.py`（famr_run.py 参数化版），后台跑
   `fam_multi/`+`famr_multi/`。6 变体端到端测试已通过：同族 4 源产生 4 组互不相同 bit 集（域内唯一）。
   完成后用 `v_bits.py fam` 对 `all_cells.json` 预测做 EXACT 校验并入库。
   - **INT_R 侧已完成（2026-10-27，490/496 变体，6 个 spec 源被 RapidWright 判 MISS）**：
     **域内唯一性 PASS——124 族 × ~4 源 0 冲突**（同族不同源 bit 集互不相同），V7 硅片实测证实了
     此前仅由 prjxray 表假设的唯一性。模型覆盖度 = SUB(396)/MIX(94)/EXACT(0)：实测 cells ⊇
     `pip_law.predict_family` 预测，即 V7 每个 PIP 实际位集比 prjxray 派生形状多出未建模位
     （源线自身配置位等）。→ 唯一性成立；`all_cells.json` 按族形状需针对 V7 精修（prjxray 无 V7 表，属预期）。
     产物 `famr_multi/famdiff_r_multi.json`（380KB）。INT_L 侧同法在跑。
   - **INT_L 侧已完成（2026-10-27，486/496 变体）**：同样 **域内唯一性 PASS——124 族 × ~4 源 0 冲突**，
     模型覆盖度 SUB(395)/MIX(90)/SUBSET_ACT(1)/EXACT(0)，与 INT_R 一致（实测 ⊇ prjxray 预测）。
     产物 `fam_multi/famdiff_l_multi.json`（306KB）。
   - **§5.6 总结论（两侧合计 976 变体 / 248 族次）：域内编码唯一性 V7 实测确认，0 冲突。**
     唯一性不再依赖 prjxray 表假设。遗留：`all_cells.json` 按族形状是 prjxray 派生的下界，
     V7 实测多出未建模位（源线自身配置位等），后续做 bit→netlist 时需按 V7 精修（记为 §5.6-followup）。**[followup 已完成 2026-10-28]** 976 变体对照 all_cells：剔除 INT_R 侧 4 个恒定副产物位（word 23、bit 17、frame_off 17/22/24/25，490 变体逐位相同、族内 4 源一致 → ref 基线噪声非 PIP 位）后 **EXTRA=0、MIX=0（两侧）→ prjxray 形状是 V7 可靠超集**；**EXACT=791 / SUBSET=185**（INT_R 396/94、INT_L 395/91）。SUBSET 缺失位族内逐源不同（23/24、24/24 differ）= 差分盲区（预测位在 ref 对该源已置 1），非形状错误，故不缩形状。产物 `step03_pip/v7_overlay.json`（976 条 observed/predicted/missing+status）+ `v7_overlay_meta.json`（INT_R 4 常量位排除表+用法）。净结论：all_cells 作候选位窗、忽略 4 个 INT_R 常量位、EXACT 已证实、SUBSET 保留完整形状；彻底解决 SUBSET 需绝对值探针 → §5.6-followup2。
    - **[§5.6-followup2 已完成 2026-10-28] 绝对值探针坐实 185 个 SUBSET。** 取两侧 ref 位流（base64 通道，避开 PowerShell `>` 的 UTF-16 破坏），用与 famdiff 驱动完全一致的坐标（payload 帧索引、`(frames[f][w]>>b)&1`）读每个"预测有、diff 没见到"的缺失位的绝对值。判据：`ref==sense` → 差分盲区（V7 不反驳，保留）；`ref==1−sense` → V7 明确不用（可精修）。**387 个缺失位：383 个差分盲区（INT_L 190 / INT_R 193），仅 4 个 V7 反驳。** 4 个反驳位高度同源：GFAN0/GFAN1 家族、源 `GCLK_B2_EAST`(R)/`GCLK_L_B2`(L)、word 20、bit 11/13、sense=0、ref=1（PIP 想拉 0 未拉动）。→ **prjxray 形状在 V7 上被逐位证实为可靠超集，全 248 族次仅 GFAN GCLK_B2 一处 4 位过预测**；净用法不变（all_cells 作候选位窗，EXACT 已证实、383 盲区保留、4 个 GFAN 位可标注精修）。产物 `step03_pip/followup2_absprobe.py` + `followup2_absprobe.json`。
7. **长线家族的块归属——已解决（2026-10-28，P0b）**：`P0B_LONG_LINE.md`。
   262/262 extra 位归因成功：**frame = block_start(col, Y) + off（off ∈ {0,1}）、
   word = 2*(Y%50)+(Y%50≥25)、LV 驱动=(0,b9)+(1,b6)、LH 驱动=(0,b2)+(1,b6)**；
   与 CLB 族同块、偏移在 0/1。远端 24/24 EXACT（out_sweep2.json），
   本地 law_db 已写 LL_OVERRIDE（4 条正方向）+ LL_DELETE（4 条反方向，
   artix7 反方向值与实测正方向重复 → 必然假阳性，删除待补测）。
8. ~~**S5：CARRY4 / PRECYINIT / AOUTMUX 实测**~~ **已完成（2026-10-28）**：
   见 `step03_pip/S5_CARRY_AOUTMUX.md`。SLICE_X10Y20（CLBLM_R/SLICEM_X0，base 31716，word 40/41）：
   - **PRECYINIT 4/4 全验证含 sense**（C0/C1/AX/CIN，C1−C0 差分恰 1 位；级联 CIN 同时置位下片 Y19）。
   - **AOUTMUX 6/6 解码**（@ base+30, word 40）：O6=∅（默认全零，artix7 预测 bit11 在 V7 不成立）、
     O5={6,11}、XOR={8}、CY={6,8}、F7={6,7}、A5Q={12}（ZINI 对照实验坐实：FDRE INIT 0/1
     唯一差分在 (31,40,3)=ZINI 类状态位，(30,40,12) 稳定 → ~~AOUTMUX.A5Q~~【已更正:该位是 AFF.ZRST,见下第 9 条 S6】）。
     隔离教训：a_xor/a_cy 原设计同时导出 O0+CO0 → 比特流完全相同；b_xor/b_cy 单输出后码型与预测吻合。
   - **LUT INIT 帧布局确认**：INIT 位在 off34/35 帧（31750/31751）word 2*(Y%50) —— 与 M3 锚点一致；
     早前只 dump off0/1/30/31 是盲区（a_o6 "全空"假象）。
   - **CARRY4 CY0 族（ACY0 30_15 等 4 位）未触发**：S/DI 源切换（LUT O6/O5 vs 直通）不置位，
     语义存疑，保持原预测不动，待不同实验（如 LUT 双输出同用）。
   - 落库：v7_law.sqlite.clb_cells 修正 O6 bit11、A5Q bit7→bit12；新表 `v7_verified` 28 行实测记录。
   远端产物 `/opt/lzh/step03/s5`（s5/s5b/s5c 三批 20+ 比特流）；本地 s5_diff/s5b_words/s5c_words.json。
 9. **S6：FF/AOUTMUX-A5Q/AFFMUX/F8 实测 — 已完成（2026-10-28）**：
    见 `step03_pip/S6_FF_OUTMUX.md`。同一锚点 SLICE_X10Y20：
    - **[S5 更正] (30,40,12) = AFF.ZRST（复位族 FF/锁存器类型位），不是 AOUTMUX.A5Q** ——
      FDRE/FDCE 族与 LD 置位、FDSE（置位族）清零、与 Q 是否使用无关；artix7 raw `AFF.ZRST 30_12` 一致。
    - **A5Q 无编码位**：决定性实验 e_both（同一 slice 内 LUT O6→o1 + FDRE Q→o2）可布线，
      AOUTMUX 无任何变化 → V7 上 FF.Q 走专用/默认路径（ppip 风格），无需 CLB 位。
      解码规则：AOUTMUX=∅ + FF 存在且 Q 被使用 → A5Q，否则 O6（Q 是否使用由 INT 路由恢复）。
    - **AOUTMUX.O6=∅ 为 V7 真实偏差**（artix7 为 30_11）。O5={6,11}/XOR={8}/CY={6,8}/F7={6,7} 维持。
    - **BOUTMUX.F8={22,23} 全验证**（d_f8：4×LUT6+2×MUXF7+MUXF8；XDC 不支持 foreach 会被静默忽略，
      必须用 post-synth Tcl 约束）。
    - **AFFMUX 5/6 实测**：AX={1}、O6={3}、O5={0,3}、XOR={2}；F7/CY 未测保持 artix7 预测。
    - **ZINI sense 反相**：(31,40,3) 置位 ⇔ FDRE INIT=0（artix7 为正 sense）。
    - **FF 类型标记**：边沿 FF (0,41,16)；LD 锁存器 (30,41,0)+(1,41,{19}) 替代 FDRE 族的 (1,41,{3,7,9})。
    - 未解决：CARRY4 CY0 族仍未触发；CE/SR/CLK 反相 mux 无干净单位差分；SLICEL_X1 位形未实测。
    - v7_verified 现 38 行；clb_cells A5Q 行恢复 artix7 形状（bit7 sense=1）+ V7 偏差记在 v7_verified。
    远端产物 `/opt/lzh/step03/s5`（s5_d_*、s5_e_both、s6_*）；本地 s6_words/s6_col/s6_e.json。

---

 10. **S7：跨 tile 位格式预测检验 — 已完成（2026-10-28）**：
     见 `step03_pip/S7_CROSS_TILE_PREDICTION.md`。4 个全新实例（A=X3Y10 CLBLM_L/SLICEL_X1 B=31544、
     B=X5Y10 CLBLL_R/SLICEL_X1 B=31580、C=X0Y10 CLBLL_R/SLICEL_X0 B=31508、
     D=X10Y300 CLBLM_R/SLICEM_X0 B=21224 远端 band6 w=0）× LUT6 / LUT6+FDRE（INIT=0x9E37..7C15 非退化，
     首轮 0x5555 被综合化简作废）：
     - **地址层 4/4 完美**：B、行字、INIT 字段帧位（X0 off32-35 / X1 off26-29，V7 首次实测 X1 字段）。
     - **Mux/FF 规律 12/12 完美**：AFFMUX.O6/ZRST/ZINI，X0=(30,3)/(30,12)/(31,3)，
       X1=(30,4)/(31,15)/(31,4) —— artix7 X0/X1 位形 4 种 tile 类型 + 近/远区全部移植成立。
     - **LUT INIT 位级排列非常量 = pin-swap 依赖**：每个目标存在唯一 38/38 置换，但 A/B/C/D 互不相同
       → placer 按 I0-I5→A1-A6 pin-swap 重写物理 INIT。逆向不受影响（INIT 字段+IMUX 路由位恢复 pin map
       → 真值表完全确定，fasm2bels 路线）；正向预测需 LOCK_PINS 固定 pin map。
 11. **S8：bit→netlist 解码器 v0 — 单 slice 闭环成功（2026-10-28）**：
     见 `step03_pip/S8_DECODER_V0.md`。输入真实 .bit（LUT6+FDRE @ SLICE_X8Y11/CLBLL_L_X6Y11），
     纯本地解码（无 Vivado）：INIT 字段 38/38 + pin-swap 置换唯一解恢复 ground-truth INIT 0x9E37..7C15；
     FF 解码全中（CLBLL_L_X0 首次实测：O6=(30,3)/ZRST=(30,12)/ZINI=(31,3)）；IMUX pin map 6/6 解析。
     v1 待办：24-mux 联合约束消歧（不同 mux 共用位池）、INT 走线↔网名映射、LOCK_PINS 定 canonical
     LUT6 端口映射、输出 Verilog 化。


 12. **S9：CSP 联合消歧 — 48 IMUX 唯一解 + Vivado ROUTE 外部真值闭环（2026-10-30）**：
     见 `step03_pip/S9_CSP_DISAMBIG.md`。`csp_imux.py`（C1 合法性预过滤 + C2 覆盖完备性
     + 单位传播 + MRV 回溯，纯本地毫秒级）对 s8_v0.bit 得 48 mux 唯一解；与远端
     `s8_route.tcl` 导出的 Vivado ROUTE 真值（route_I0..I5.txt）比对 **6/6 全中**，
     v0 朴素首选在全部三个歧义针（A3/A4/A6）上原本是错的（NE2END0/NE2END1/NW2END2 →
     实为 WL1END0/SR1END1/WL1END1）。附带修正：INIT 索引=标准二进制 A6(MSB)..A1(LSB)
     无乱序（先前"乱序"结论是 MSB/LSB 解读 bug）；§5.6 的 4 个 w23 常数位
     {(31696,23,0),(31702,23,0),(31704,23,0),(31705,23,0)} 观测端也须剔除。
     decode_slice_v0.py 已集成 CSP。v1 下一步：INT-walk 网名还原（route_I*.txt
     已是第一份真实对照）→ 多 slice 闭环 → Verilog 输出。

## 6. 常用命令

```bash
# 远端跑一个 mux 的 25 源实验（脚本走 stdin 管道，别用 scp / /mnt/c 路径）
#   本机 PowerShell：
#   cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < "step03_pip\p6_run.sh"'
#   脚本里第一行 export LANG=C LC_ALL=C，再 cd /opt/lzh/step03/reuse6 && bash run.sh

# 本地分析
D:\Anaconda3\python.exe E:\DEEPSEEK\FPGA比特流逆向\step03_pip\p6_analyze.py

# 查询位表 / 反解比特流
python step03_pip\pip_query.py mux CLBLL_L_X6Y11:IMUX_L7
python step03_pip\pip_query.py pip "GFAN0->>IMUX_L8"
python step03_pip\pip_query.py decode step03_pip\ref_X8Y11_A6LUT_A1.bit
python step03_pip\pip_query.py stats

# 表结构迁移（幂等）/ 导出 CSV
python step03_pip\migrate_pip_bits.py --db E:\v7work\model\v7_model.sqlite
python step03_pip\export_pip_csv.py

# 远端跑 Vivado 必须修 locale，否则 locale::facet 崩溃
printf '#!/bin/bash\nexport LANG=C\nexport LC_ALL=C\nexport HOME=/root\n/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source /tmp/x.tcl\n' > /tmp/run_viv.sh
bash /tmp/run_viv.sh
```

## 5.1. 跨类型（INT_L vs INT_R）—— 已完成（2026-10-25）

比对方式：按「mux 编号相同 + wire 名相同」配对，(frame, word, bit) 各减最小值归一化后逐条比。

| 项目 | INT_L（INT_L_X6Y11） | INT_R（INT_R_X9Y11 等） |
|---|---|---|
| 设计数 | 36 | 36 |
| 位流数 | 900 | 900 |
| 每 mux 源数 | 25 | 25 |
| 掩码大小 | 0x1 / 2x12 / 4x12 | 0x1 / 2x12 / 4x12 |
| word 取值 | 22 / 23（按 L//4） | 22 / 23（同规则） |
| 帧窗口 | 31696-31705 | 31804-31813（+108） |

**结果：same = 792，diff = 0。**

结论：形状表（mux 编号 + wire → cell 集合）与 tile 实例、甚至 tile 类型都无关；类型/位置的差别只体现在块地址（帧窗口整体平移）。

数据：step03_pip/tp2.json；脚本：step03_pip/cross_type.py；文档：step03_pip/CROSS_TYPE_RESULTS.md。

## 6.1. PIP 复用规律（可执行形式，2026-10-25）

`frame = block_start(col, band) + 16 + df`，`word = 2*(Y%50) + ((L//4)%2)`，
`bit`/`sense` 取形状表。`block_start` 读 `phaseA/frame_index_far.csv`（154 列 × 7 带）。

- 回归：INT_L_X6Y11 2,592/2,592、INT_L_X6Y21 3,024/3,024、INT_R_X9Y11 2,592/2,592，合计 100%。
- 列不变性：6 个列扫描（列 6/8/9/12/13/15）唯一格 10/10 全中 → **列只改 block_start，不改形状**。
  先前「奇偶列两套形状」是归一化假象（最小帧当原点 + 公共使能格污染）。
- 布点陷阱：`SLICE_X(2*col-4)` 反推列会偏 1~2 列（col=11/12/13 实际落在 INT 列 12/13/15），
  受控实验必须从 DCP 读真实 tile 名。

代码：`step03_pip/pip_law.py`（`--check` 自检，`--tile/--mux/--src` 查询）；说明：`step03_pip/PIP_LAW.md`。

### 6.1 行带 1 与全家族扩展（2026-10-26）

- 行带 1 实测：`SLICE_X8Y61` 的 25 个变体落在 26,450–26,459，word 22
  （= 2*(61%50) + 0）。预测 `block_start(6, band1) = 26230 + 204 = 26434`，
  +16…+25 完全吻合 → `block_start` 的行带项成立。
- 布点注意：`SLICE_X8Y61` 归属 INT 列 **6**（不是 8）。slice X ÷ 2 不能直接当 tile 列，
  必须从 DCP 读 tile 名。
- `gen_all_cells.py` → `all_cells.json`：24,336 单元 / 228 家族，覆盖 IMUX 之外的
  BYP_ALT、FAN_ALT、BEG/END、CLK 家族；`frame = block_start + frame_off`。
  这些家族的行内字奇偶未实测，`pip_law.py --family ... --parity N` 显式给。

### 6.2 非 IMUX 家族的字奇偶（2026-10-26）

`parity` 不再需要手填：prjxray 把一行两个 32 位字 (2Y, 2Y+1) 打包进 bit 0..63，
`bit // 32` 即 parity。对 96 个 IMUX 家族逐一核对，`bit//32` 与实测的 `(L//4)%2`
完全一致（0 个反例），于是 132 个其它家族（BYP_ALT/FAN_ALT/CLK/BEG…）沿用同规则。

`all_cells.json` 每条记录带 `parity`、`frame_off`、`bit`、`sense`；每个家族内部 parity
唯一（无混合）。查询：`pip_law.py --tile ... --family BYP_ALT2 --src ...`（parity 自动取）。

注意：这是**推断**，尚未对 IMUX 之外的家族做变体实测；证伪成本低（任一 BYP_ALT 家族一次差分）。

---

## 7. 远端数据刷新（2026-10-26 05:40 UTC，DSH 会话）

远端 `172.17.70.41` / `s.tschai` / `C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root`，可达。

### 7.1 `/opt/lzh/step03` 现状（files/bits）

| 目录 | files | bits | 用途 |
|---|---|---|---|
| pip1 / pip2 | 83 / 170 | 9 / 24 | 首个 PIP 差分实验 |
| reuse / reuse3 | 144 / 280 | 25 / 60 | P1 绝对位集 |
| reuse4/5/6 | 7 / 418 / 598 | 0 / 72 / 124 | P2/P6 编码与留出 |
| tilepipe | 3,914 | 936 | col6 全 36 mux |
| tilepipe2 | 3,945 | 936 | INT_R 跨类型 |
| tilepipe3 | 668 | 156 | col6 同类型换行 |
| tilepipe4 | 3,907 | 936 | col9（奇列）全 36 mux |
| band1 / lutmap / right | 126 / 88 / 133 | 26 / 65 / 26 | 行带1、LUT 映射、右列 |
| blkcol / blkcol2 / blkcol3 | 128 / 127 / 127 | 26 each | 换列块基址 |

合计 **~1,700 个位流**（每个 20,273,538 B）。

### 7.2 模型库 `/opt/lzh/v7re/data/model/v7_model.sqlite`（635,883,520 B）

| 表 | 行数 |
|---|---|
| tiles | 150,380 |
| sites | 86,022 |
| site_pins | 5,489,706 |
| probe_bits | 1,248 |
| probes | 72 |
| **imux_codes** | **2,304** |
| **pip_bits** | **2,652** |
| bit_map | 28 |

小表已导出到 `step03_pip/remote_data/model_tables.json`（1.2 MB）。
注意远端 `v7re` **不是 git 仓库**，代码同步靠本机 `step03_pip/` 为准。

### 7.3 磁盘

`/` = 1007G，已用 201G（21%），剩 756G。
### 7.4 本机与远端模型库一致性核对（2026-10-26）

逐表比对了 21 张表（行数 + 全量行内容）：

| 表 | 行数 |
|---|---|
| tiles | 150,380 |
| sites | 86,022 |
| site_pins | 5,489,706 |
| site_bel_pins / site_bels / site_wires / site_types | 7,107 / 3,439 / 3,252 / 30 |
| imux_codes | 2,304 |
| pip_bits | 2,652 |
| bit_map / probe_bits / probes | 28 / 1,248 / 72 |
| column_offsets / region_bases / tile_types | 420 / 14 / 115 |
| site_type_pips / meta / stages / artifacts / site_frames | 583 / 17 / 1 / 0 / 0 |

结论：**21 张表行数与内容完全一致**，本机 `E:\v7work\model\v7_model.sqlite`
（635,883,520 B）与远端 `/opt/lzh/v7re/data/model/v7_model.sqlite` 已同步，无需合并。
行数快照存 `step03_pip/remote_data/table_counts.json`。


### 6.3 早期行带抽测（2026-10-26）

第一轮只测了三个点：Y=11（区域 0）预测 31,696 起、Y=61（区域 1）预测 26,450 起、
Y=161（区域 3）预测 5,466 起，三处窗口与 GFAN0 的格子都逐位一致。当时把它记成
「行带 0/1/5」，其实第三个点是区域 3 —— 正是它提示行带与时钟区域不是简单反向，
于是有了 §6.6 的七区全测。

非 IMUX 家族的 parity 已由 §6.4/§6.5 的 248 个变体实测确认（62/62 分列 word 22/23，
左右两侧一致），不再是推断。早期用 `ref_C9.bit` 做的静态盲扫 0 命中，原因是该参考设计
里 ALT 家族未被使用（全零码），静态探针没有区分力——必须造变体。

### 6.4 非 IMUX 家族全量实测（2026-10-26）

方法：取已布通的 `SLICE_X8Y11_A6LUT_A1.dcp`，在 net `n1` 的 PIP 列表末尾**追加**
`src ->> 家族`，写 DCP → bitgen → 与 ref.bit 逐位差分。124 个 INT_L 非 IMUX 家族
每族一个变体（124 次 bitgen，8 并发约 20 分钟），判定为「观测到的 1 位翻转必须全部
落在 law 预测的 sense=1 格内」。

结果：**124/124 PASS，0 EXTRA，0 EMPTY**。`pip_law.py --check` 已把该回归并入自检。

结构发现：word 恰好 62 族在 22、62 族在 23（= bit//32 打包奇偶）；frame_off 按家族类
分区——BYP/FAN 16..25，6 步长 BEG 2..7，2 步长 BEG 6/9..15，1 步长 BEG 7/8/10..15，
直通/时钟类 0..1。不存在统一偏移。

未覆盖：BRAM 行带 8–14（CLB 行带 0–6 已在 §6.6 全测）。

### 6.5 非 IMUX 家族右侧（INT_R）全量实测（2026-10-26）

基座换成 `step03/right/rA1.dcp`（lut @ `SLICE_X11Y10`，tile `INT_R_X7Y10`），同样
「追加 PIP → bitgen → 差分」，124 个 INT_R 非 IMUX 家族逐一跑（8 并发约 20 分钟）。

结果：**124/124 PASS，0 EXTRA，0 EMPTY**（`famdiff_r.json`）。`pip_law.py --check`
现在同时回归 `famdiff.json` 与 `famdiff_r.json`。

踩坑记录（对后续有用）：
1. `rA1.dcp` 直接 bitgen 会被 4 个 DRC 拦下（PDCN-1568/1569、NSTD-1、UCIO-1），
   前两个必须 `IS_ENABLED false`，后两个可降级为 Warning 或 `-no_drc`。
2. 基线必须用**同一份 DCP 现生成**（`ref_now.bit`），不能拿旧的 `ref_C9/ref_rA1.bit`
   ——旧基线与新变体差 3 个固定位（31733/31738/31740 的 w23），会把判定污染成 EXTRA。
3. 7 系列位流的 FDRI 载荷固定从字节 **338** 起、`50,176 × 404 B`；Type2 包头里的
   count 是 27 位（`0x504D5400` → 5,067,776 词），别按 13 位解。


### 6.6 七个 clock region 全测：行带映射修正（2026-10-26）

七个区域各造一组变体（`INT_L_X6Y`，四个家族 BYP_ALT6 / EE2BEG1 / SE6BEG0 / GFAN0，
仍是「追加 PIP → bitgen → 逐位差分」），40 项判定里 **32 EXACT、8 SUB、0 FAIL**。

真实映射（此前 `band = 6 - Y//50` 只在 Y<100 时凑巧对）：

| region | Y | FAR 行带 | col6 起帧 | 观测 word |
|---|---|---|---|---|
| 0 | 0–49 | 6 | 31,680 | 51/52 |
| 1 | 50–99 | 5 | 26,434 | 40/41 |
| 2 | 100–149 | 0 | 204 | 51/52 |
| 3 | 150–199 | 1 | 5,450 | 51/52 |
| 4 | 200–249 | 2 | 10,696 | 40/41 |
| 5 | 250–299 | 3 | 15,942 | 51/52 |
| 6 | 300–349 | 4 | 21,188 | 51/52 |

`region → 行带 = [6,5,0,1,2,3,4]`；FAR 表把 Y=0 那半边放在最后两带且内部再倒一次，
所以「Y=0 在最上」不能外推到全器件。

字号规则修正：`word = 2*(Y%50) + parity`，**结果 ≥ 50 时再 +1**（让开第 50 字的 ECC）。
区域 0 的 BYP_ALT6 落在 word 52、EE2BEG1 落在 51，正是 `2*25+0→51`、`2*25+1→52`。

`pip_law.py` 已把 `BAND_BY_REGION = [6,5,0,1,2,3,4]` 与 `_word()` 写进代码，
`python pip_law.py --check` 自检全绿；`check_bands2.py` 可复跑这 40 项。

### 6.7 复用规则收尾：三种差分语义 + 位域独占（2026-10-27）

纯本地复核（远端 ssh 超时），把散在 10 多个 JSON 里的观测全部对到同一张形状表上，
产出总纲 `step03_pip/REUSE_RULES.md`。

**① 差分有三种语义**，取决于参考流怎么生成——这是之前若干「反例」的唯一来源：

| 语义 | 参考流 | 差分 | 文件 |
|---|---|---|---|
| PURE | `p6_make2.py` 写出的 `ref_$TAG.dcp`（sink PIP 已删） | 单条 PIP 的位集 = `sense=1` 格 | `tilepipe`/`tp2`/`tp3` |
| XOR | 原始 dcp（sink PIP 还在） | `code(S0) △ code(w)` | `col_*`/`rep_*`/`t1*`/`tp4b` |
| FAM | 原设计再追加一条 PIP | 置位 ∪ 清零，都落在该 PIP 的格内 | `famdiff`/`famdiff_r`/`_famexp` |

由此 **`BLOCK_ADDR_CHECK.md` 结论 3「形状随 CLBLL/CLBLM 变」已证伪**：col6 与 col8/10 的
差别是 PURE vs XOR，不是 CLB 类型。10 个列扫描文件每个都被**唯一**一组 `(mux, S0)` 解释
（`IMUX_L8←NR1END0`、`IMUX8←NE2END0`、`col_B1` 是 `IMUX_L8←NL1END0`），
`tp4b.json` 36/36 个 mux 各自唯一命中。跨 col 6/8/10/12 逐 wire 完全一致 → 形状与列无关。

顺带订正一个坑：实验脚本用 `SX=$((2*COL-4))` 从 SLICE_X 反推列是错的（SLICE 编号跳过非 CLB 列）。
真实映射（`sites.tile` 查得）：`X8→CLBLL_L_X6`、`X10→CLBLM_R_X7`、`X12→CLBLM_L_X8`、
`X14→CLBLM_R_X9`、`X16→CLBLL_L_X10`、`X18→CLBLM_L_X12`、`X20→CLBLM_R_X13`、`X22→CLBLM_R_X15`。
所以 `col_11.json` 其实是第 12 列、`col_12.json` 是 13、`col_13.json` 是 15。

**② 位域按 family 独占**（统计必须用 `(frame_off, parity, bit)` 三元组）：

- 每侧 1,598 个 cell、3,636 个 feature、172 个 family；**cell→family 1598/1598 独占，跨 family 零共享**。
- 每个 cell 被同 family 的 3..18 个源置 1（均值 5.57）；每 feature 平均置 2.45 位。
- family 域 7..10 格、源 12..24 个，**域内编码唯一 172/172**；组合只有 5 种：
  `(9,20)×96`、`(10,24)×64`、`(8,16)×6`、`(7,12)×4`、`(9,18)×2`。
- 块内分区（两侧相同）：off 0..1 时钟/控制/GFAN/LVB（12 族，73.4% 密度）；2..5 长线 BEG（32 族，87.5%）；
  6..9 短线 BEG（96 族，100%）；10..15 短线（64 族，100%）；**16..25 mux 区（64 族 × 10 格 = 640 位，100% 满装）**。
  26 帧合计 1,598/1,664 = **96.0%** 位密度。
- 假象警告：漏掉 parity 会看到「每格被 2 个 family 共用、95 对成对复用」
  （`IMUX_L0` vs `IMUX_L4` 其实是 parity 0 vs 1），已排除。

**③ sense 语义定死**：`_famexp.json`（124 变体，带方向）292 次置位、22 次清零，
**124/124 的清零格都落在该 PIP 的 `sense=0` 格上**（集中在 `BYP_ALT*`/`FAN_ALT*` 互斥源与 `CLK_L*`/`CTRL_L*`）。
推论：差分 ⊆ 该 PIP 自己的格集合；且因位域独占，**SUB 只可能是基线里已有同 family 的另一条 PIP**
（4 个 SUB 全是 `*_NR1END1`，两侧缺格相同）。

**④ 实测规模与覆盖率**：

- `verify_reuse.py`：PURE 1,872 EXACT（`tilepipe` 864 + `tp2` 864 + `tp3` 144，另 78 条 `VCC_WIRE` 无形状记录）
  + XOR 1,150 条全部唯一解释 + FAM 244 EXACT/4 SUB + 清零 124/124 → **合计 3,270 条观测、0 反例**。
- 覆盖率：2,048/7,272 feature = **28.2%**（两侧对称）。`IMUX` 1800/2304 = **78.1%**；
  `*BEG` 192/3840 = 5.0%；`BYP_ALT`/`FAN_ALT` 各 4.2%。`(tile_type,family)` 层面 320/344 测过 ≥1 源，
  72/344 源全覆盖。**完全未测的 24 个 family 全是 IMUX**（每侧 12 个），疑为 CLBLM 专属（待办 §5.5）。
- 未覆盖：154 列只验 7 列；BRAM 行带没碰；长线家族块归属未解；多 PIP 线性叠加未系统验证；
  没有板子回读的真实比特流。

新增/改动文件：`step03_pip/REUSE_RULES.md`、`verify_reuse.py`、`reuse_stats.py`（+`reuse_stats.json`）；
订正 `BLOCK_ADDR_CHECK.md`（结论 3 证伪 + 列映射）、`PIP_LAW.md`（§7.3 SUB 成因、新增 §8）；
删除 `audit_shape.py`（列映射写错，已被 `col_xor_model.py` + `verify_reuse.py` 取代）。

### 6.8 远端重连：DHCP 换址（2026-10-27 17:45）

本轮前半段 `ssh fpga` 报 `connect to host 172.17.71.129 port 22: Connection timed out`。
根因不是网络故障，是**机器换了 IP，而 `~/.ssh/config` 里的 `Host fpga` 还指着旧地址**
（正确信息其实早已记在本文件 §1，只是 config 没跟着改）。

诊断过程（可复用，已写进 [REMOTE.md](REMOTE.md) §4）：

| 步骤 | 命令 | 结果 |
|---|---|---|
| 本机网络 | `ping 172.17.64.1`（网关）/ `ping 8.8.8.8` | 都 **Success** → 本机没问题 |
| 旧地址 | ICMP + TCP 22/445/3389/80/5900/8080 全探 | 全 **timeout** → 机器不在这个地址 |
| ARP 陷阱 | `Get-NetNeighbor` 显示 `172.17.71.129 → 00-00-5E-00-01-1F (Reachable)` | **不算证据**：本网段 ARP 由 VRRP 虚拟 MAC 代答，所有 IP 都"可达" |
| 找候选 | `known_hosts` 里出现过的同网段 IP | `172.17.70.41`（另有旧条目 `172.17.71.129`） |
| 探端口 | TCP 22 on `172.17.70.41` | **OPEN**（ICMP 被墙，但 TCP 通） |
| 认机器 | 读 SSH banner | `SSH-2.0-OpenSSH_for_Windows_9.5` → Windows+WSL，正是那台 |
| 认用户 | `lzh`/`root` × `id_ed25519`/`v7remote` | 全部 `Permission denied (publickey,…)` |
| 成功 | **`s.tschai` + `v7remote`** | `DESKTOP-47NHOKA`，Windows 11 build 26200 |

连上后核对：WSL Ubuntu 里 `/opt/lzh` 完好（磁盘 216G/1007G，741G 可用）；
Vivado `/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado` + `Vivado_license_2037.lic` 在；
`/opt/lzh/venv/bin/python` = 3.8.10 且 site-packages 里有 rapidwright。
（`uptime` 显示 `up 0 min` 是正常的——WSL 按需启动。）

**改动**：

- `~/.ssh/config`：`Host fpga` 改指 `172.17.70.41` / `s.tschai` / `v7remote`，加 `ConnectTimeout 10`；
  旧条目降级留档为 `Host fpga-old`。
- 新建 [REMOTE.md](REMOTE.md)：远端连接的**唯一权威记录**（地址/用户/私钥、三种调用姿势、
  Vivado 必备细节、换址后的重连流程、`/opt/lzh/step03` 26 个目录的 bit/json/dcp 清单与「本地是否已有」）。
- [AGENTS.md](AGENTS.md) 与 [README.md](README.md) 加入指向 `REMOTE.md` 的入口；
  README 里过时的 `bash /mnt/c/Users/S.tschai/run_ymore.sh` 换成本轮实测通过的 stdin 管道写法；
  本文件 §1/§2/§6 同步订正（旧的 `/mnt/c/Users/S.tschai/x.sh` + scp 流程已废弃）。
- 新增 `step03_pip/_recon.sh`：远端盘点脚本（host/vivado/python/disk/step03 各目录计数/所有 json 清单），
  下次换址后直接跑它就能确认环境完好。

**盘点发现的两个小问题**：`/opt/lzh/step03` 下有个名字带 `\r` 的 `bands2` 垃圾目录（0 bit/0 json/0 dcp，
早期 CRLF 事故产物，可删）；`reuse4` 是半成品（1 个 dcp、0 bit）。
另外 `/opt/lzh/README.md` 里写的路径全是 `/data/lzh/...`，那是旧路径，**实际都在 `/opt/lzh/...`**。

### 6.9 tilegrid bits 批量填充：91,050/91,050（2026-10-27）

用 PIP 侧推出的地址律批量填 V7 tilegrid.json 的 `bits` 字段，让 **artix7 segbits 库可直接复用**。

**生成器**：`step03_pip/gen_tilegrid_bits.py`
- 输入：tilegrid.json + `phaseA/frame_index_far.csv`（50,176 条）
- 对 INT_L/INT_R/CLBLL_L/CLBLL_R/CLBLM_L/CLBLM_R 六类 tile，从名字解析 `(col, Y)`，
  用 `block_start(col, Y)` 算基址帧、`_word(Y, 0)` 算 offset，反查 fi2far 得 baseaddr（minor 0）。
- 约定（**artix7-native**）：INT frames=28, CLB frames=36, offset=`_word(Y,0)`, words=2。
  artix7 segbits 里 CLB LUT INIT 在 frame cols 32-35（相对 minor 0），与 V7 实测 `block_start+32` 完全对齐。

**修复的 bug**：`pip_law.py:65` 的 `col = (block_addr >> 7) & 0x7F` 把右半 cols 128..153
折叠到 0..25，与左半碰撞。改为 `col = (((ba >> 14) & 1) << 7) | ((ba >> 7) & 0x7F)`
（half*128 + col_local = tile X 0..153）。修复后 `_STARTS[band]` 有 154 keys，
`pip_law.py --check` 仍全绿。

**结果**：

| 输出 | tiles | filled | missing | 锚点 |
|---|---|---|---|---|
| 本地 `tilegrid_filled.json`（16.8 MB） | 150,380 | 91,050 (60.5%) | 0 | 3/3 OK |
| 远端 `tilegrid.json.filled`（30.9 MB） | 150,380 | 91,050 (60.5%) | 0 | 3/3 OK |

六类 tile 全部填满：INT_L 26,550 + INT_R 26,550 + CLBLL_L 3,100 + CLBLL_R 2,150 +
CLBLM_L 15,700 + CLBLM_R 17,000 = 91,050。offset min=0 max=99（ECC 让位）。

**关键验证**：
- 3 个独立实测 CLB 锚点全中：CLBLL_L_X6Y10->0x00420320/36/20、CLBLL_L_X10Y303->0x00080500/36/6
  （held-out, region 6, 芯片另一端）、CLBLM_R_X7Y10->0x00420380/36/20。
- 右半验证：INT_L_X128Y10->0x00424000/28/20、INT_R_X129Y10->0x00424080（delta=0x80）、
  CLBLM_L_X150Y69->0x00404B00/36/38（=2*19，region 1）。
- INT 与 CLB 同列共享 baseaddr（minor 0），frames 不同（28 vs 36）——与 artix7 完全一致。
- 远端输出保留了 clock_region/sites/prohibited_sites 字段。

**与 fasm_shell 的差异（已解决）**：fasm_shell 手动建的 3 个 tile 用绝对地址（baseaddr = minor 32，
frames=4，只覆盖 LUT INIT）；我们用 artix7 约定（baseaddr = minor 0，frames=36，覆盖全 tile），
artix7 segbits 可直接复用，无需调整。

**产物路径**：
- 生成器：`step03_pip/gen_tilegrid_bits.py`
- 本地输出：`step03_pip/tilegrid_filled.json`（16.8 MB）
- 远端输出：`/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled`（30.9 MB）

**意义**：两条完全独立的实验路径（INT PIP 删位差分 vs CLB one-hot INIT 探测）在地址律上互相验证；
91,050 个 tile 的 bits 字段现已可被 prjxray 工具链（bit2fasm / fasm2bel）直接使用——
一旦恢复或自研 bit->FASM 解码器，INT+CLB 侧即可立即解码。

### §6.10 CLB 特征位验证 + bit2fasm_py ZINI 极性（2026-10-29）

**10 项 artix7 CLB segbits 特征在 V7 全部位置命中（267 位 0 反例）：**

| 特征 | 位 | 位置命中 | 极性 |
|---|---|---|---|
| LUT INIT ×256 | cols 32-35 | 256/256 ✅ | 一致 |
| FF ZINI ×4 | col 31 | 4/4 ✅ | **反转**（V7 bit=1→INIT=0） |
| CLKINV | 01_51 | 1/1 ✅ | 一致 |
| CEUSEDMUX | 01_39 | 1/1 ✅ | 一致 |
| SRUSEDMUX | 01_35 | 1/1 ✅ | 一致 |
| FFSYNC | 00_48 | 1/1 ✅ | 一致 |
| LATCH | 30_32 | 1/1 ✅ | 一致 |
| PRECYINIT.C1 | 00_12 | 1/1 ✅ | 一致 |
| PRECYINIT.AX | 30_14 | 1/1 ✅ | 一致 |
| CARRY4.ACY0 | 30_15 | 1/1 ✅ | 一致 |

地址模型：`frame=block_start(col,Y)+col`, `word=offset+bitidx//32`, `bit=bitidx%32`。

**ZINI 极性处理**：artix7 segbits 的 ZINI 位位置正确，但极性反转。
- 不能在 segbits 层翻转（未配置 tile 的 ZINI 位也 CLEAR，翻转后对每个 tile 的每个 FF 都误发射 ZINI）
- 正确做法：解码器保持 artix7 极性（bit SET → 发射 ZINI），在 `fasm_to_rw.py` 网表重建时处理
  （ZINI present → V7 INIT=0；ZINI absent → V7 INIT=1 或未放置 FF）

**解码器验证**：
- a.bit（LUT only）：67 features（1 INIT + 66 PIP），0 ZINI ✅
- ref.bit（4FF INIT=0）：65 features，4 ZINI 全发射 ✅（V7 bit SET = INIT=0）
- v_u_aff_1.bit（AFF INIT=1）：64 features，**缺 AFF.ZINI**，其余 3 个在 ✅（V7 bit CLEAR = INIT=1）

详见 `step03_pip/CLB_VERIFY.md`。

### §6.11 端到端 FF 重建测试通过（2026-10-30）

管线全通：`.bit → bit2fasm_py(50176帧) → FASM → fasm_to_rw.py → RapidWright EDIF → DCP(1.38MB) → Vivado funcsim → Verilog(4.7KB)`

**Test 1: ref.bit (4 FDRE, all INIT=0)**
- FASM: 65 features (4 ZINI + 1 FFSYNC + 60 PIP)
- funcsim: 4× `FDRE #(.INIT(1'b0))` + shared clk/ce/sr per slice
- ZINI present → INIT=0 ✅

**Test 2: v_u_aff_1.bit (AFF INIT=1, others INIT=0)**
- FASM: 64 features (3 ZINI — BFF/CFF/DFF, NOT AFF)
- funcsim: AFF `.INIT(1'b1)`, BFF/CFF/DFF `.INIT(1'b0)` ✅
- ZINI absent → INIT=1 ✅

关键修复：(1) 移除 "No LUT6 → exit" 早退；(2) 同 slice FF 共享 clock/CE/SR net；(3) 3-part slice 级特征正确解析。

### §6.12 BRAM/DSP 特征位验证（2026-10-30）

**DSP48E1（DSP_L_X100Y0, block_start=34884）**：

| 特征 | 预测 | ref(CEAD=1) | var(CEAD=0) | 结果 |
|------|------|-------------|-------------|------|
| DSP_VCC_L_CEAD | (34911,1,30) | 1 | 0 | ✅ TOGGLE |
| DSP_GND_L_CEAD | (34910,1,31) | 0 | 1 | ✅ TOGGLE |

总差分=2，0 非预期。极性一致。CEAD=1→VCC_L=1，CEAD=0→GND_L=1。

**RAMB18E1（BRAM_L_X114Y0, block_start=35356）**：

| 特征 | 预测 | ref(INIT_A=0) | var(INIT_A=1) | 结果 |
|------|------|-------------|-------------|------|
| ZINIT_A[17] | (35383,0,1) | 1 | 0 | ✅ TOGGLE |
| ZINIT_A[0] | (35383,2,9) | 1 | 1 | SAME ✅ |
| IN_USE_0/1 | (35383,3,3/4) | 1 | 1 | SAME ✅ |

总差分=1（仅 ZINIT_A[17]），0 非预期。

**关键发现——INIT_A 位反转**：INIT_A=0x00001（bit 0 set）→ 只有 ZINIT_A[17] 翻转，证实 segbits ZINIT_A 索引与 INIT_A 参数位是位反转的（ZINIT_A[17]↔bit 0, ZINIT_A[0]↔bit 17）。这是 Xilinx BRAM 已知特性。极性：ZINIT_A[k]=1→对应 INIT_A 位=0。

**总结**：artix7 segbits 对 V7 的 INT/CLB/DSP/BRAM 四大类 tile 均可直接复用。验证总计 12 项特征、269 个位，0 反例。地址模型 `frame=block_start(col,Y)+col, word=offset+bitidx//32, bit=bitidx%32` 适用于全部 tile 类型。

详见 `step03_pip/CLB_VERIFY.md`（DSP/BRAM 段）。

### §6.13 INT_R 12 缺失 IMUX 补齐——IMUX 覆盖率 100%（2026-10-31）

**问题**：INT_R tilepipe 只用了 SLICE_X15Y11（SLICEL，24 IMUX）+ SLICE_X14Y11（SLICEM，仅 A+B LUT = 12 IMUX），缺 12 个 IMUX 索引：22/28/29/31/32/35/38/40/43/44/45/47，对应 SLICE_X14 的 C6LUT 和 D6LUT。

**实验**：ref.bit（A6LUT+B6LUT in SLICE_X14Y11）vs var_cd.bit（A+B+C+D LUT in SLICE_X14Y11），差分检查 12 个预测位置。

**结果**：12/12 word/bit 位置全部在差分中找到 ✅。帧号因路由器选不同源线而异（预测基于特定源线），但 word 和 bit（由 IMUX 索引决定）完全正确。

| IMUX | word | bit | 差分帧 |
|------|------|-----|--------|
| 22 | 23 | 19 | 31808, 31812 |
| 28 | 23 | 4 | 31811, 31812, 31813 |
| 29 | 23 | 12 | 31805, 31811, 31812, 31813 |
| 31 | 23 | 28 | 31805, 31811, 31812, 31813 |
| 32 | 22 | 5 | 31804, 31810, 31812, 31813 |
| 35 | 22 | 29 | 31812 |
| 38 | 23 | 21 | 31810, 31812, 31813 |
| 40 | 22 | 6 | 31800, 31812 |
| 43 | 22 | 30 | 31810, 31812, 31813 |
| 44 | 23 | 6 | 31812 |
| 45 | 23 | 14 | 31804, 31811, 31812, 31813 |
| 47 | 23 | 30 | 31805, 31812 |

**覆盖率更新**：
- INT_L：48/48 IMUX = **100%**（tilepipe 直接覆盖）
- INT_R：36/48 直接 + 12/48 本轮 = **100%**
- 跨类型偏移 +108：792/792 验证
- IMUX 总覆盖率：2304/2304 = **100%**（从 78.1% 提升）

实验目录：远端 `/opt/lzh/step03/missingtest/`（ref.bit + var_cd.bit + diff_missing.py）。

13. **S10 INT 全芯片解码 + 反向走线（2026-10-30 深夜）**：发现 INT 行字
    「半带 +1」规则 `2*(Y%50)+(Y%50>=25)`（artix7 tilegrid offset 佐证 +
    V7 SW6 中继位实测），修正解码后 119 个激活 INT PIP 全部解出；6 根输入网
    仅凭比特流反向走线到 IO 边界，5/6 与 route 真值逐 token 一致（A4 入口
    半段差一跳，IO 侧 tileconn 缺失所致）。报告
    `step03_pip/S10_INT_WALK.md`，脚本 `step03_pip/int_walk_v1.py`。
    v7_verified 65→68。**bit→netlist 的 INT 走线层就此闭环**（IO 入口段
    与输出网为残余缺口）。

14. **S10b IO 入口段解码（2026-10-31 上午）**：补上 IO 侧盲区——die 中心 IO 界面区
    （X31 CLB 块 27286 之后 72 帧缺口）内 `INT_L_X32` 用基址 27322、`INT_R_X33`
    用 27354，入口 PIP 直接解出：`NW2BEG0/SW6BEG0/SS6BEG0 <- LOGIC_OUTS_L18`
    （IF 线名）。A2 全链闭环（入口 SW6BEG0@X32Y51 → X30Y47 → WW4@X28Y43 …
    与 route I1 十个 SW6 token 完全吻合）；A4 入口结构确认
    （SS6@X32Y57 → WW4@X32Y51 → SW6@X28Y51←WW4END1 = route I4 前四 token），
    中段奇偶行混合跳（dy 4/5 变体 + NW6 备选源）留待 INT-PIP CSP 联立求解。
    `step03_pip/s8_io_entries.json`；v7_verified 68→72。

15. **S10c 输入网全链闭环（2026-10-31）**：从比特流单独出发，IO 入口 PIP
    （X32Y50-55：NW2/SW6×2/WW4×2/SS6）+ 119 个 INT PIP + tileconn 落点，
    正向 DFS（只走有 PIP 驱动的落点）恢复全部 6 根输入网的完整走线链，
    与 route_I0..I5.txt 的 fabric token 序列 **6/6 完全一致**（A4 关键中继
    SW6BEG0@X32Y48←SS6END0 在 band0 IO 块 base 32568 w97；A3 含 LV_L18 跨带）。
    产物：`step03_pip/s8_final_chains.json`；v7_verified 72→74。

16. **S11 SLICEM RAM/SRL 模式位验证（2026-10-31）**：RAM64X1S/SRLC32E/RAM128/
    RAM256/RAM64X1D 双设计 + f5a/f5b，9 个设计位级对账 **9/9 与 artix7
    预测一致**（ALUT/BLUT.RAM 31_16/17 @ w40，CLUT/DLUT.RAM 31_46/47 →
    (31,41,14/15)——bit>=32 ⇒ word+1 规则 V7 实证成立；WA7USED (0,41,8)、
    WA8USED (1,40,27)、WEMUX.CE (1,40,23)、ALUT.SRL (30,40,16)）。
    A/B LUT 字段在 w40、C/D 在 w41 的对仗结构确认。报告
    `step03_pip/S11_SLICEM_MUX.md`；v7_verified 74→82。
17. **S12 输出网正向走线（2026-10-31）**：夹缝列 INT tile 基址规则通用化
    （西侧最近 CLB 块 +36(INT_L)/+68(INT_R)），解码 PIP 119→**152**，补出
    INT_L_X32 列 NN6/NE2/NN2 中继。三条输出网：**o2 fabric 13/13 全等**
    （NE6×12+EE2）、o 10/14（EE4×3+NE6×7+NN6×2）、o3 1/3。剩余缺口 =
    IO 收尾段（WR1BEG1←NE2END0、BYP_ALT/BYP_BOUNCE 位于 off16..24 的 byp 位池，
    需与 IMUX 同域 CSP 判定；IMUX_L34 段需 INT_INTERFACE segbits）。
    152 PIP 下输入侧倒走出现分支噪声（A1 5 节点 undriven）→ 下一步必须做
    **INT PIP 全局 CSP**。报告 `step03_pip/S12_OUTPUT_WALK.md`。

### 13. S13 · INT PIP 真值闭合（2026-10-31）

- **tile_block 四级规则**（新，替换旧的“夹缝列一刀切”）：CLB 邻列 → 西侧 CLB+36 → 西侧 CLB+68 → 下一 CLB−28。
  解码覆盖 152 → **181 PIP / 181 family / 0 ambiguous**，13.5 s。
- **真值通道**：`get_pips -of_objects [get_tiles $tn]` + `get_nets -of_objects $pip` 反查占用网，
  必须包含 CLB tile（`LOGIC_OUTS->>BEG` 挂在 CLBL/CLBLM 上），否则输出网全缺。148 tile → 147 条 PIP 真值。
- **对账**：解码与真值交集 **134 条，src 不一致 0 条**；decode-only 47 条全在 die 中心 IO 列（同一批帧被
  INT_L_X32Y5x / INT_R_X33Y5x 双映射的 Ghost 重复）；truth-only 13 条为 IMUX*(8)/FAN(2)/GCLK(2)/WR1(1)。
- **全局最大覆盖求解**（`s13_solve2.py`，9 网互斥，目标=占用 PIP 最大）：**98/181**；
  逐网真值命中：A1 14/16、A2 12/13、A6 13/14、A3 12/13、A4 13/14、A5 13/16、o 9/16、o2 12/13，
  **错误 0、未知 0**。
- **token 级**：6 条输入网与 Vivado ROUTE 序列 **6/6 EXACT**（A1 NW2/WW4/SS6/SW6×8/WW2×2/SW2 …）；
  o/o2 前段一致，末段 NN6→NE2→WR1→IMUX_L34→IOI 未走通（输出网提前终止在 LIOB）。
- 报告：`step03_pip/S13_INT_GLOBAL.md`；数据：`s13_pips.json`、`s13_solution.json`、`s13_solution2.json`；
  真值：`E:\v7work\pip_net4.tsv`（UTF-16）；DB `v7_verified` 86 → 91。
- 待办：多 sink fanout（i[0]/i[5] 同时扇出到 o3 的 LUT2）、FAN/GCLK 族解码、IO 列 Ghost 去重、o3 seed 记账。

## 13. S14 —— bitstream → 网表首个闭环（2026-10-31）

全芯片 CLB 扫描（75,900 slice / 3,884 条位规律）命中 62 条特征，落在 `SLICE_X8Y11` 与 `SLICE_X47Y51`，
与 Vivado 真值 slice 集合 2/2 一致。INIT 解出物理值 `0x937b7471e799fac5`（38 位）/`0xc0c0...`（LUT2 AND），
FF 解出 FDRE + INIT 1'b0 + D=A6LUT.O，48-IMUX CSP 给出 6 个 pad 的线网归属（未解析 0），
INT 链（S13，6/6 token-exact）给出网络名。发射 `netlist.json` 与 `netlist_recovered.v`，
并把「恢复网表」与原设计在全部 64 组输入上逐点比对：**0 mismatch**。
报告: `step03_pip/S14_BIT_TO_NETLIST.md`；v7_verified 91→95。

## 14. S15 —— 纯解码网表 + 重综合位级验证（2026-10-31）

IMUX 位表证明**按 slice 实例形态通用**（CLBLL_L 实测 → CLBLM_R_X31Y51 直接命中，2 个活跃 mux 全 exact+unique）。
端口身份由 IO 入口行 Y50..55 反推（207 节点 0 冲突），X47Y51 的两个输入靠反向走线补齐。
恢复网表重综合后与原 bitstream 比对：`SLICE_X47Y51` 整块 **0 字差异**、X8Y11 的 LUT INIT 与 FF 区 **0 字差异**，
全芯片仅 53 字差异（全部为布线 IMUX 选择 + ECC）。报告 `step03_pip/S15_PURE_DECODE_RESYNTH.md`；v7_verified 95→98。

## 16. Phase A frame_map 入库（2026-11-02）

**背景**：Codex v6 已 PASS 的 `frame_map`（50,176 行 = 50,148 block 帧 + 28 overhead 帧）此前只存在于
`phaseA/frame_index_far.csv` 与评审包里，**模型库中没有该表**（本地 `E:\v7work\model\v7_model.sqlite`
与远端 `/opt/lzh/v7re/data/model/v7_model.sqlite` 都只有 21 张表、无 `frame_map`，本地那份是远端同名库副本）。

**本轮动作**：
1. 本地用 `codex_review_framemap_20261024/data/import_frame_map_v6.py`（无参数，默认指向模型库）导入：
   CSV 校验 PASS、两条 bitstream 锚点 PASS（frame 31748/31750）、事务内审计全 PASS、提交 50,176 行。
   导入前备份 `E:\v7work\model\v7_model.sqlite.bak-20261102-pre-framemap`（636,133,376 B）。
2. 导出为 CSV（3,761,839 B）→ gzip（260,299 B）→ base64（319,176 B），走 `tee` stdin 通道推到远端，
   远端建同构 CHECK 约束表并事务导入，审计 8 项全 PASS，提交。
   远端备份 `/opt/lzh/v7re/data/model/v7_model.sqlite.bak-20261102-pre-framemap`（636,133,376 B）。

**验收结果（本地 + 远端一致）**：
- `frame_map` 行数 **50,176**，`frame_index` 0..50175 连续；
- `far IS NULL` = **28**（全部 `is_overhead=1`、`frame_address_source='unresolved'`）；
- `COUNT(DISTINCT far)` = **50,148**（无重复）；
- 锚点 frame 31748 → **0x4203A0**、31750 → **0x4203A2**；
- overhead = **14 个配置行 × 每行末尾 2 帧相邻**（行 1 在 5244/5245，行 14 在 50174/50175）；
- `block_addr % 128 == 0` 全部成立；远端库 22 张表、大小 639,496,192 B。

**仍未完成**：`site_frames` 本地与远端均 **0 行**（Phase B 未开始，待办第 4 条 STEP04 仍开）。

## 17. Phase B / P1 site_frames + word 50 定性（2026-11-02）

**生成器**：`v7re/scripts/build_site_frames.py`（`--site-addr` / `--site-frames` / `--validate`）。
数据源 `E:\v7work\model\v7_law.sqlite`（11 MB：clb_tiles 75,900 / clb_blocks 763 / clb_cells 3,884 / v7_verified 98）。

**地址公式**：
```
band  = y // 50 ;  base = clb_blocks[(grid_col, band)]
frame = base + frame_off
word  = 2*(y % 50) + (1 if y % 50 >= 25 else 0) + parity   # 帧长实测 101 word
bit   = law.bit                                            # CLB 恒 0..31
inst  = slice 名 X 的奇偶（偶→X0，奇→X1）
```

**结果**：
- `site_addr` 75,800 行（75,900 个 slice 中 100 个 CLBLM_L 缺 block，样例 `SLICE_X13Y299`/`SLICE_X12Y299`，grid_col 20 band 5）；
- `site_frames` **36,799,100 行**，全量生成 679.9 s，库 7,949.3 MB；单 slice 488–498 行；
- `--validate` 全 PASS：结构、锚点 `SLICE_X10Y20`（base 31716 / word0 40 / INIT 四帧 31748..31751）、
  `v7_verified` 对账（命中 49、恒 0 池 1、已登记偏差 1、未命中 0、跳过 47 / 共 98）。

**位级对账（`SLICE_X10Y10/A6LUT`，INIT=64'h…01）**：`bit_base` vs `a` 差 10 bit，全在 frame 31750：
`(w20,b15)` = `ALUT.INIT[00]` ✔；`(w50,b{0,1,2,3,6,7,8,10,12})` = **帧校验字，非配置特征**。

**word 50 定性（原"缺失 tile 级特征"判断已证伪）**：
1. 相关性 100%——"含数据字的帧"与"word 50 非零的帧"完全同一集合（79/79、80/80、80/80），全零帧 word50 恒 0；
2. 值域 13 位——239 个非零样本最大位 12、`0x1e91 < 0x2000`，位 11 仅 3/239，符合 12 位 Hamming + 1 位总校验；
3. 远端成对实验——固定 LOC 造 `e0..e5`（LUT / +FDRE(CE=1) / +CE / +R / FDSE / 换时钟），
   以 `e0` 为基准差分，每处数据字变化都伴随同帧 word50 变化，块外 word50 差分条数（200/347/327/327/200）
   等于块外有数据变化的帧数。产物 `/opt/lzh/v7re/work/word50/e0..e5`（20,273,538 B/个），
   差分脚本 `word50/diff.py`（远端 `/opt/lzh/venv/bin/python`）。
   **结论**：word 50 跳过是正确的，不需要补 law；但"从零写 bitstream"必须能重算它，
   算法未解出（CRC32 变体不匹配；简单线性假设在三组单比特样本上不自洽 → 输入可能含帧地址）。

**A5Q 偏差登记**：`V7_EMPTY_OVERRIDES` 剔除 `("*","AOUTMUX","A5Q")`（artix7 有位 (30,7)，V7 实测无位）；
实测点仅 CLBLM_R.SLICEM_X0，按 `*` 通配，待横向复验后收紧。

**新发现的可用数据**：`e0→e1`（插入一个 FDRE）在 CLB 块 6 个帧组
（31716/31717/31736/31737/31746/31747）的 word 20/21 上有干净差分，可直接用作 FF law 的最小对照集。

文档：`v7re/steps/SITE_FRAMES_STATUS.md`。

**远端同步（2026-11-02 16:09）**：law 库仅 11 MB，故不打数据，改为把 `v7_law.sqlite`
（gzip 2.97 MB → base64）与 `build_site_frames.py` 推过去在远端**重算**：
产物在 `/opt/lzh/v7re/work/word50/`（`v7_law.sqlite`、`build_site_frames.py`、`e0..e5/`），335.8 s，`36799100` 行，库 7,948.2 MB，`--validate` 同样全 PASS。
两侧内容校验和逐项一致：

| 项 | 本地 | 远端 |
|---|---|---|
| count | 36,799,100 | 36,799,100 |
| sum(frame) | 680,502,413,700 | 680,502,413,700 |
| sum(word) | 1,845,567,050 | 1,845,567,050 |
| sum(bit) | 565,232,000 | 565,232,000 |
| sum(len(site/bel/feature)) | 485,792,400 / 188,305,600 / 199,075,100 | 同 |
| `SLICE_X10Y20` | 498 行 / 31716..31751 | 498 行 / 31716..31751 |

**CLB 块帧结构旁证**：`clb_cells` 只用到 12 个 `frame_off`
（0、1、26–35），763 个 block × 12 = **9,156** 个被使用的帧，与实际 `COUNT(DISTINCT frame)` 完全吻合；
即每个 CLB 块的 36 帧里只有 12 帧承载 slice 级特征。

**踩坑**：远端 WSL 里 `nohup ... &` 起的后台进程会随 ssh 会话结束被杀（日志 0 字节、进程消失），
长任务必须让 ssh 前台阻塞（本地用 `run_in_background` 挂住即可）。

## §18 T1：24 个未测 IMUX family 的成因（2026-11-02，假设证伪）

`REUSE_RULES.md` §6 曾假设「每侧 12 个未测 IMUX（22/28/29/31/32/35/38/40/43/44/45/47）
是 CLBLM(SLICEM) 专属输入」。**已证伪**。

方法：一个设计内 `SLICE_X12Y20`(X0) 与 `SLICE_X13Y20`(X1) 各放 4 个 LUT6
（A6/B6/C6/D6），8×6=48 个输入脚全部驱动，`DONT_TOUCH` + 不同 INIT 防合并，
route 后导出每条 net 的全部 PIP。

结果：**48/48 个 IMUX 全部被使用**。此前"未测"的 12 个对应
`CLBLM_M_C1..C6` + `CLBLM_M_D1..D6`——即 M 侧 slice 的 C/D 全部 LUT 输入。
基座只用了 `A6LUT` 的 `A1`，所以不是够不着，是没碰到。

副产品：权威 `IMUX ↔ site pin` 全表 → `v7re/steps/imux_pin_map_clblm_l_x8y20.json`；
文档 `v7re/steps/T1_IMUX_REACH.md`。另注意到 `IMUX 编号 → 引脚` 呈 12 个一组、
L/M 交替、且各段起点有相位偏移——这是 T3（pattern 生成函数）的候选线索。

补齐路径：用这个 8-LUT 基座跑 tilepipe，逐 sink 做 PURE 变体，IMUX 覆盖 78.1% → 100%。
## 19. T3 —— PIP 复用规律的生成式表述（2026-11-02）

**目标**：把 mux 区的 PIP 规律从「查表」推到「算出来」。**结果：L2 达成。**

脚本 `v7re/scripts/pip_reuse_law.py`（`--build` 生成 `v7re/steps/pip_reuse_law.json`，
`--verify` 对账）：**1,536 / 1,536** 条 `(family, src)` 的 cell 集合精确命中，0 不符。

定律（mux 区，帧 16–25，64 个 family）：

| 层次 | 内容 |
|---|---|
| 网格 | 所有 mux 区 family 共用 6×4 网格：`row∈0..5`，`colcode∈{0001,0010,0111,1011}`；24 源占满 24 格，只有一种网格模式 |
| 帧 | 行帧 `16+row`；列帧 `25-i`（`colcode` 第 i 位为 1） |
| 位 | 每族一对相邻位 `(B,B+1)` + `parity` + `phase`；列帧恒用 primary `P`，行帧在 row∈{0,1,4,5} 用 `P`、row∈{2,3} 用配对位 `S` |
| 闭合 | 16 位对 × 2 parity × 2 phase = 64 = family 数，**一一对应**（`distinct_combos=64, max_per_combo=1`） |

同一位对同一 parity 的两个 family 靠 phase 互补：`BYP_ALT0`(pair 6, p0, primary=7) 与
`IMUX_L40`(pair 6, p0, primary=6) 源集合相同、cell 集合互斥 —— 这就是复用的几何本质。

跨类型：几何定律 INT_L / INT_R 通用。直接用 INT_L 定律预测 INT_R 得 336/1536，
线名归一化（`LOGIC_OUTS0`→`LOGIC_OUTS_L0`）后 **384/1536 且「名字对得上时算错 = 0」**；
其余 1,152 条是 INT_R 独有源（`GFAN0/GFAN1`、`BYP_BOUNCE_N3_6`…）。

仍属数据：**源 → 槽位排列**（64×24 = 1,536 条）。已排除名称字典序（48 个 mux 全不符）
与基名归类（22 个基名跨族占不同槽位）；它是布线邻接顺序，需用 `v7_routing.db` 重建。

文档：`v7re/steps/T3_PIP_REUSE_LAW.md`；`step03_pip/REUSE_RULES.md` 新增 §3.2。

**下一步顺序**：帧 0–15 的 family（`CLK_L0`/`CTRL_L0` 等）用同一脚本跑一遍 → T2（域内唯一在
mux 区外是否成立）→ T4（多 PIP 线性叠加）→ T1 收尾（8-LUT 基座补 12 个 family，IMUX 78.1%→100%）。

## 20. T3 续 —— 帧 0–15 的 family 结构（2026-11-02）

`pip_reuse_law.py --stats` 把同一套分析跑遍 INT_L 全部 **172 个 family**：

| 帧窗 | family | 每源格数 | 网格判定 | 结论 |
|---|---|---|---|---|
| 0–1 clk/ctrl | 12 | 2 或 4 | 全 None | 位池 6–8 位，非网格，待专门分析 |
| 2–7 BEG6/4 | 32 | 2 | 全 None | 位池 4 位（两个位对），非简单网格 |
| 6–15 BEG2/1 | 64 | 2 | **全 (5,4)** | **5×4 网格，已生成化** |
| 16–25 mux | 64 | 2–4 | （6×4，因格数可变未计入判定） | 已生成化（§19） |

**第二定律（帧 6–15）**：每族 20 源 = 5×4 网格；axis1 = 帧 12–15 固定一位，
axis0 = 帧 6–11 两位组合。组合自检：16 位对 × 2 parity = 32 种，每种恰好 2 个族
（`最大族数/种=2`，对应 phase 二选一）→ **32×2 = 64**，与 mux 区同一套编址体制。

**全域可逆性**：172/172 个 family 内没有任何两个源的 cell 集合相同 → L4 在整个 INT tile 成立。

仍非生成化：帧 0–1 的 12 族与帧 2–7 的 32 族（像「多节点图上的路径」编码，
样例 `EE4BEG0`：`EE2END0=(3,8)+(3,9)` 同帧两位、`SS2END0=(3,8)+(5,11)` 跨帧跨位）；
以及所有族的「源 → 槽位」排列。

文档：`v7re/steps/T3_PIP_REUSE_LAW.md` §8；脚本新增 `--stats` 模式，`--verify` 回归仍 1,536/1,536。


## 21. T3 收尾 —— 帧 2–7 与 0–1 的 44 个 family（2026-11-02）

**帧 2–7 的 32 个 BEG 族已定性**：每源 2 格 = 图上一条边，图是 **完全二分图 K(4,5)**
（9 个位池格、20 条边全用满、A 侧度 5、B 侧度 4、无三角形、直径 2），
即 **源 = 一个 A 格 × 一个 B 格，20 = 4×5**，与帧 6–15 的 5×4 同构。
几何签名只有 2 种（各 16 族，互为镜像）：A=`(2,+1)(3,0)(5,0)(6,0)`/B=`(3,+1)(4,+1)(4,+2)(5,+3)(7,+1)`
与 A=`(2,+3)(3,+2)(4,+3)(7,+3)`/B=`(2,+2)(4,0)(5,+1)(5,+2)(6,+2)`。
族编号规律：编号奇偶选位窗（偶→位基 8，奇→位基 24），parity = 编号 div 2。

**帧 0–1 的 12 个时钟/控制族未闭合**：每族 16 源、8 个位池格；8 源=2 格（2-of-8 选择码），
8 源=4 格且 8/8 都包含某个 2 格码 → 4 格 = 主码 + 附码（附码仅 4 种、各用 4 次）；
4 格源不是任意两个 2 格源之并（0/8）。`LH*`/`LV*`/`LVB*` 同时跨 parity 0/1（cell 落在 4 个字上），
不符合“一族一字 parity”体制；`--stats` 给出的 (4,3)/(6,3)/(3,6) 因边集不连通，只是分量内局部二分。
结论：需仪器化实验（切换时钟源/BUFG/CE 组合看成组翻转）才能定语义。

**INT_L 172 族的最终分类**：网格族 160（64 mux + 64 BEG2/1 + 32 BEG6/4，全生成化）、
复合码族 12（时钟/控制，未闭合）、源→槽位排列仍是数据。

脚本 `pip_reuse_law.py --stats` 的网格判定已改为“按边集二分 + 完全性校验”；
`--verify` 回归仍 1,536/1,536。文档 `v7re/steps/T3_PIP_REUSE_LAW.md` §9。


## 22. T4 —— 多 PIP 线性叠加验证（2026-11-02）

脚本 `v7re/scripts/verify_superposition.py`；输入 `_full8.bit` + `_full8.pips`
（8 个 LUT6、48 个输入全驱动的设计）。

**方法**：不做差分，直接用 T3 定律「先预测、再核对」——把 `(family, src)` 按定律算成
`(frame_off, bit, parity)`，折算绝对地址后在真实 bitstream 里逐位验证。

| 检查 | 结果 |
|---|---|
| 在用 PIP 的预测位全为 1 | **56 / 56**（`INT_L_X8Y20` 48 条 + `INT_L_X32Y6..13` 8 条） |
| 在用 PIP 的 `sense=0` 位全为 0 | **48 / 48 无违例** |
| 负对照：1,104 条未用候选中「预测位也全 1」 | 60 |
| 其中 4 格 pattern 误命中 | **0 / 546** |
| 其中 2 格 pattern 误命中 | 60 / 558（10.8%） |

**结论**：PIP 的位是**线性叠加**的（逐条独立置位、互不清零）→ 写入方向可直接按 pattern 逐位 OR；
读出方向**4 格及以上 pattern 唯一可判**（0 误命中），**2 格 pattern 有歧义**（10.8%），
这为 `decode_law.py --min-cells 4` 的阈值提供了独立证据。

文档：`v7re/steps/T4_SUPERPOSITION.md`。下一步：把它推成 FASM → bitstream 写入器（T5）。


## 23. T5 v1 —— 由 PIP 列表写出配置位（mux 区，2026-11-02）

脚本 `v7re/scripts/bitwriter.py`（`--selftest`）。做法是**清空后重建**：
把位流中某 tile 的帧 16–25 清零，只用 Vivado 路由导出的 PIP 列表按 T3 定律重写，再逐位比对。

结果：**9/9 tile PASS，往返差异位 = 0**，其中 `INT_L_X8Y20` 一次写入 **52 条 PIP**
（48 IMUX + 4 其他），未知源 0 条。

能力边界：只覆盖帧 16–25 的 64 个网格族（地址与位由定律算出，只写 `sense=1`）；
帧 0–15 的 12 个时钟/控制族与帧 2–7 的 32 个 BEG6/4 族仍走查表；CLB 特征位走 `site_frames`。

未宣称：没有做“空位流生成 → 器件/Vivado 等价性”的端到端验证；
当前证据是“与 Vivado 产出的位图逐位一致”。

文档：`v7re/steps/T5_BITWRITER.md`。下一步：接进 FASM 管线输出端；用 M2 语料做跨设计验证；
补齐时钟族实验。


## 24. 时钟/控制族实验 —— 12 个“复合码”族已在 V7 上验证（2026-11-02）

远端 `/opt/lzh/v7re/work/clk/` 造 6 个同 FF、只改时钟/控制来源的设计（c0–c5），
另加 3 个改 BUFG site 的（c6–c8）。

**关键修正**：之前记为“未闭合的 12 个复合码族”，实测表明 **law_cells 对它们是正确的**：
- c0 路由 `GCLK_L_B11 ->> GCLK_L_B11_WEST ->> CLK_L1` → 表中唯一满足的是 `(CLK_L1, GCLK_L_B11_WEST)`（16 候选中唯一）；
- c4 路由 `WW4END1 ->> GFAN0 ->> CTRL_L1` → 表中 `(CTRL_L1, GFAN0)` 与 `(GFAN0, WW4END1)` 同时满足；
- c3 的 CE 走 `WR1END2 ->> FAN_ALT7`（mux 区，已被定律覆盖）。

`bitwriter.py` 加 `--with-table`（非 mux 区走 `law_cells`）与 `--frames 0:26` 后做往返：
c0/c1/c2 = 20 PASS + 1 FAIL，c4 = 26 PASS + 1 FAIL，c3/c5 = 29/26 PASS + 1 FAIL；
失败永远是带时钟的 `INT_L_X8Y20`，差异位固定为 **帧 0 / parity 1 / 位 16**。

反查：**没有任何 tile_type 的 law_cells 行使用该格** → 它属于 `GCLK_L_B11 ->> GCLK_L_B11_WEST`
这条直通 PIP，即 prjxray INT 表**未覆盖 INT tile 内的 GCLK 直通族**（`GCLK_L_B0..B11`）。
该位只在有 GCLK 路径的 tile 上为 1（`INT_L_X32Y*`、`INT_R_X9Y20` 均为 0）。

另：把 BUFG 约束到 `BUFGCTRL_X0Y8/16/24` 后路由仍是 `GCLK_L_B11`
—— GCLK 编号由 slice 所在列决定，不由 BUFG 位置决定。

文档：`v7re/steps/T5_BITWRITER.md` §7。


## 25. GCLK 直通位定位与 T5 收口（2026-11-02）

**测不出线号，但测出了使能位。** 换列（g1–g4）与双时钟（d2）都证明 Vivado 恒走 `GCLK_L_B11`，
所以 B0–B11 各自的位无法用设计变换区分；但三个设计的时钟 tile 位图案完全一致：
`帧0 par0=[27] / 帧0 par1=[16] / 帧1 par0=[25,26,29]`，其中唯一无法被 `CLK_L1` 定律解释的
就是 **`(frame_off=0, bit=16, parity=1)`** → 判定为「每 tile 一位的 GCLK 接入使能」，
线号已由 `CLK_L1 / GCLK_L_B11_WEST` 表达。

`bitwriter.py` 加 `GCLK_PASS_BIT=(0,16)` 后：**c0/c1/c2 = 21/21、d2 = 27/27 tile 全 PASS，0 差异**。

残留：c3/c4/c5 各差 1 位，位在 `(帧1, word41, bit7)` 与 `(帧1, word41, bit3)`，
`law_cells` 中 0 条候选（表外族），只在 tile 用了 bounce 驱动的 `BYP_ALT`/`FAN_ALT` 时出现。
写位无法区分 BYP_ALT 与 FAN_ALT 各自的位，需专门旁路实验。

文档：`v7re/steps/T5_BITWRITER.md` §8（实验、判定、代码、往返表、残留位、能力边界）。


## 26. 残留位定性：b1 反证（2026-11-02）

造 b1（同 tile 内 LUT→FF→LUT 旁路 + 两个 FAN_ALT 送 IMUX）：`FAN_ALT3/FAN_ALT1/BYP_ALT0` 全用上，
但**帧 1 par1 一位都没置**。而 c3（`FAN_ALT7->>FAN_L7` 进 CE 脚）、
c4（两跳 `BYP_ALT0->>BYP_BOUNCE0->>BYP_ALT1->>BYP_L1` 进 D 脚）各多 1 位（bit7 / bit3）。

→ 该位不是 BYP_ALT / FAN_ALT 的选通位，而是**「旁路链最终落到 CLB 站点引脚」这一路的标记位**，
prjxray INT 表未覆盖；且按「链的跳数/形态」编码，不按目标引脚编码（c3 两条链只多 1 位）。

文档：`v7re/steps/T5_BITWRITER.md` §9–§11。写入器对这类设计保持「已知差 1 位」声明，不猜测填位。


## 27. T6 —— 端到端闭环（2026-11-02）

`v7re/scripts/roundtrip.py`：**不喂 Vivado 路由结果**，PIP 列表由位流自身解码
（mux 区 T3 定律 + 帧 0–15 查表），再用同规则重写，逐位比对。

**位级：往返精确。** c0 = 31 条 PIP，漏 0 / 多 0；full8 = 282 条，漏 0 / 多 0；
c3/c4 各漏 1 位（已知表外旁路位）。GCLK 使能位也已可解码并写回。

**符号级：2 格 pattern 有歧义。** 与 Vivado 真实路由（仅 INT tile）对账：
full8 解码 282 / 真值 198 / 命中 190 / 多 92 / 漏 8；**92 条误判全部是 2 格 pattern**；
4 格及以上在整芯片尺度 0 误判。c0：24 命中 / 7 多（6 条 2 格）/ 3 漏。

**为什么并存**：位是线性叠加的，2 格 PIP 的位常被邻居顺带点亮 → 重写时写多了同样的位，
位图不变；但解读时信息不足 → 无法判定是哪条 PIP。

**消歧方向**：①按 net 链连通性剪枝（最有效）；②只信 4 格以上；③族内互斥做精确覆盖。

文档：`v7re/steps/T6_ROUNDTRIP.md`。仍缺：帧级 ECC（第 50 字）重算，生成可加载 bitstream 前必须补。


## 28. T6b —— 2 格 pattern 消歧实测（2026-11-03）

脚本 `v7re/scripts/prune_chains.py`（templates + `conn_rules` 做连通性）。

**歧义性质**：按 `(tile, family)` 分组，多解的 53 组里真值恰好 1 个源且真源都在候选中
（53/53）→ **mux 是否配置可判对，选哪个源不可判**。

| 策略（full8，真值 198） | 解码 | 命中 | 多 | 漏 | 精确率 | 召回 |
|---|---|---|---|---|---|---|
| min-cells 2 全收 | 282 | 190 | 92 | 8 | 67.4% | 96.0% |
| 2 格 + 链剪枝 | 270 | 180 | 90 | 18 | 66.7% | 90.9% |
| 2 格 + 每族选链支持最高 | 190 | 159 | 31 | 39 | **83.7%** | 80.3% |
| min-cells 4 | 39 | 39 | 0 | 159 | 100% | 19.7% |

**纯剪枝无效**（templates 入度太大，判据恒真）；**排序有效**（+17 个百分点精确率）。
下一步：把「每根线至多一个驱动」做成精确覆盖求解。

⚠️ 现有 `decode_law.py` 默认 `--min-cells 4`，在真实设计上只解出 19.7% 的 PIP，默认值偏保守。

文档：`v7re/steps/T6B_DISAMBIGUATION.md`。


## 29. T7 —— 帧级 ECC 线性性证明（2026-11-03）

数据：本地 13 个 bitstream 的 50,176 帧。

**已证明：ECC 是数据位的线性函数。** 例：帧 31769 只有 (w40,b7) 置位 → ECC `0x1867`；
帧 31773 只有 (w40,b15) → `0x086f`；帧 31776 两位同时置位 → `0x1008`，
而 `0x1867 ^ 0x086f = 0x1008` 精确相等。9 个多 bit 帧里 8 个按 XOR 命中。

**单 bit 签名规律**：556 个单数据位样本显示低 12 位 = `32*g(word) + bit`，
`g(w)=w+c(w)`，c 从 25 起、在 w≈8 与 w≈38 处各 +1（25/26/27）。
已覆盖 23 个 word（0/2–5/8/12–16/20/24/27–33/38–42/49）。

**未闭合**：(1) 其余 77 个 word 的 g(w) 未采样（需让设计落在不同 y 上）；
(2) bit12 行为不明（与数据位奇偶无关，偶/奇都可能为 1）；(3) 2 个样本 ECC 高位置位。

**影响**：写入器目前只能对「改动落在已采样 word」的情况做正确 ECC 修正，
还不能生成任意可加载 bitstream。

文档：`v7re/steps/T7_FRAME_ECC.md`。下一步：造覆盖 y=0..49 的设计补全 g(w)，再定 bit12。


## 30. T7b —— y 扫描（设计缺陷→已停）与 g(w) 双候选（2026-11-03）

**y=0..49 扫描（已中途中止）**：远端 `/opt/lzh/v7re/work/ysweep/`，零逻辑基线 `base/top.bit`
+ 每个 (inst,row) 一个单 LUT 设计（`LOC SLICE_X{8+inst}Y{r}`，`BEL A6LUT`，INIT=…01）。
inst=0 的 49 个已完成。**但该设计不能隔离单 bit**：每个设计在自己 row 的字上有
9–29 处差异（帧 31680/31681/31683/31684/31686/31691/31692…，都是同一 CLB 块的不同特征组），
因为 LUT 直连输出脚会连带改动该行的 IMUX/输出 MUX 等位。故中止，不能用于补 g(w)。

**g(w) 双候选（现有 20 个可确定 word 全部符合，且互相不可区分）**：

| 公式 | 表达式 | 在 w=34–37 的取值 |
|---|---|---|
| 公式1 | `g = w + 25 + (w>=6) + (w>=34)` | 61,62,63,64 |
| 公式2 | `g = w + 25 + floor((w+26)/32)` | 60,61,62,63 |

两者只在 **w=34,35,36,37** 上分歧（其余全同），已观测 word 不含这 4 个 → 未决。

**判别实验（下一步）**：照搬 2020 探针 `a.bit` 的结构（源 LUT → 中间 LUT → 输出），
在 `SLICE_X8Y17`（w=34）与 `Y18`（w=36）各做一个「单 INIT 位」设计；
该结构已证明能产生单 bit 帧（`a.bit` 的 word20 只差 1 位），
测出 g(34)/g(36) 即可定式。约 4 个 bitgen，10 分钟。


## 31. T7c —— 单 bit 隔离实验失败：ECC 模型改走线性代数（2026-11-03）

在 `SLICE_X8Y17/A6LUT`(INIT=…01) + `SLICE_X9Y17/A6LUT`(反相) 上做「a.bit 同构」设计，
与零逻辑基线 `ysweep/base/top.bit` 差分：word 34（row 17, parity 0）上出现 **23 处单 bit 差异**，
但同一 bit 位对应多个不同 ECC（例：diff=0x00000002 → ECC 0x1749 与 0x781 并存）。

原因：这些帧**并非只有该一位改变**，同一帧内还有其它特征（IMUX/FF/输出 MUX）同时变化，
ECC 是整帧数据位的异或，因此拿不到「单 bit 签名」。结论：**靠设计变换隔离单 bit 不可行**
（要构造只改一位的帧，先得知道位映射，循环依赖）。

**改走线性代数（下一步的正式方案）**：
ECC 已证线性，故对每一帧有 `XOR_{b∈data(frame)} S_b = ECC(frame)`，`S_b` 是 3,200 个未知 13 位向量。
只要收集足够多「数据位集合已知、ECC 已知」的帧（现有 13 个 bitstream 已有 739 个非零帧，
再做 ~30 个随机 INIT/随机布局设计可到数千帧），就能用 GF(2) 高斯消元直接解出全部 `S_b`，
再用留出帧验证。**不需要**猜 g(w) 或 bit12 的生成函数。

已作废的中间结论：`g(w)` 双候选（分段 25+(w>=6)+(w>=34) 与 25+floor((w+26)/32)）
在已观测 20 个 word 上等价，仅在 w=34–37 分歧；既然改走线性代数，该分歧不再阻塞。


## 32. T7d —— GF(2) 求解结果：ECC 不是「数据的纯函数」（2026-11-03）

实现了 `v7re/scripts/ecc_solve.py`（把每帧的置位位置集合作方程、ECC 作为右端，GF(2) 消元 + 回代）。

**求解结果**（训练 8 个 bitstream，留出 `_full8.bit`）：

```
方程 615 条，涉及位置 246 个
消元：秩 143 / 未知数 246，矛盾=True
训练集：一致 492，不符 13，缺签名 110
留出集：一致 43，不符 2，缺签名 79
```

出现**矛盾行**，说明「ECC = 各位置签名的异或」这个模型不成立。

**根因已定位（决定性证据）**：`_c0.bit` 的帧 31754 与 31759 **数据字完全相同**（差异只有 word50），
但 ECC 分别是 `0x1011dd` 与 `0x869`：

```
frame 31754 vs 31759 差异字: [50]
    word 50: 001011dd vs 00000869 (xor 001019b4)
```

即 **ECC 依赖帧的地址/位置，不只是数据内容**。这与 T7 早期观察到的「同一 (word,bit) 出现两个签名」
（(40,9) → 0x869 / 0x1011dd、(49,23) → 0x997 / 0x200022）完全吻合——当时误判为「异常样本」，
实际是地址项。

统计：259 种不同数据模式中，255 种的数据→ECC 是唯一映射，4 种出现两个 ECC 变体；
变体的差值低位都接近 0x9B3/0x9B4/0x9B5，提示地址项是「帧在块内位置」的函数。

**修正后的模型**：`ECC(frame) = L(data) ⊕ A(frame_addr)`。
下一步需要「同一份数据、不同位置」的成对样本（把同一逻辑放到不同 slice/row），
用它们直接测出 A 的地址依赖，再回到 GF(2) 求解 L。


## 33. T7e —— 三个线性模型全部证伪（2026-11-03）

在 §32 的「ECC = L(data) ⊕ A(addr)」框架下依次试了三种地址项，都被数据否掉：

| 模型 | 方程 | 秩 | 矛盾 | 训练一致 | 留出一致 |
|---|---|---|---|---|---|
| A ≡ 0（纯数据） | 615 | 143 | **是** | 492/615 | 43/45 |
| A = 块内偏移 o（36 项） | 615 | 178 | **是** | 497/615 | 42/124 |
| A = FAR 各位线性（32 项） | 615 | 158 | **是** | 400/615 | 29/124 |

（FAR 模型里所有 far 位都被解成同一个值 `0x1019b4`，说明秩不足、无法分离。）

**异常帧的分布很集中**：739 个有数据帧中，只有 35 个的 ECC 超出 13 位；它们全部位于
row 7，且块内偏移只取 **{0, 2, 8, 21}** 四个值（例：`_c0` 帧 31752/31754/32637/34064）。
偏移 2 的解算结果恰好是 `0x1019b4`（= §32 里 31754 与 31759 的 ECC 差），说明「偏移项」
确实捕捉到了这一部分，但不足以解释全部矛盾。

**当前状态判定**：`ECC = L(data) ⊕ A(addr)` 这一模型族（A 取常值/块内偏移/FAR 线性）
**均不成立**。需要新的假设，而不是继续在这族里调参。

可能的方向（未验证）：
1. 这 35 个帧可能是**被 Vivado 重写过两次**的帧（同一 FAR 写入多次），
   我们读到的是最后一次数据 + 该次的 ECC，需按写入次数重新解析；
2. 帧级 ECC 的覆盖范围可能**不是整帧 100 个数据字**（例如按 32 字分组各自校验）；
3. word50 超出 13 位的部分本就不是 ECC，而是 Vivado 写入的**帧标记**，
   低 13 位才是 ECC——但 31754/31759 的对比显示低 13 位也不一致，故此项也被削弱。

下一步应先用「同一 FAR 在 bitstream 中被写了几次」这条线索做解析层检查，
这比继续拟合更快给出判定。


## 34. T7f —— 「重写」假设证伪；ECC 的地址项只是少量边界帧的标记（2026-11-03）

**1) 重写假设不成立**：`_c0.bit` 只有一个 FDRI 段（`far_starts` 长度 1，far 从 0 开始），
payload 5,067,776 字 = 50,176 帧 × 101，`leftover = 0`；被写多次的 FAR 数 = 0。
即每帧只写一次，读取的数据与 ECC 一定配对。

**2) 地址项只出现在极少数边界帧**：全零数据但 ECC 非零的帧（跨 9 个 bitstream）只有这些位置：

| 帧内偏移 `fi % 5246` | ECC | 说明 |
|---|---|---|
| 2590（每行最后一帧） | `0x8019b7` | 在所有 bitstream、所有行都相同 |
| 280 | `0x4009b6` | |
| 208 / 1168 | `0x4009b6` | |
| 1169 | `0x1019b4` | |

关键：`0x8019b7` 对 far = `0x259c / 0x2259c / 0x40259c` 完全相同（三者低位都是 `0x59c`），
说明地址项只依赖 **far 低位**，且**只在行/块边界帧上非零**。

**3) 数据的线性项确实存在且很小**：`_b1` 帧 31754（无数据）ECC = `0x1019b4`，
`_c0` 同帧（1 个数据位）ECC = `0x1011dd`，两者异或 = `0x69` —— 即单个数据位的贡献。

**结论（可执行）**：`word50 = ECC(data) ⊕ marker(far_low)`，且 `marker ≠ 0` 只发生在
每行最后一帧等边界位置。因此：

- **改写非边界帧** → 只需按数据的线性项重算 ECC（这是绝大多数帧）；
- **改写边界帧** → 必须保留原 marker（原值异或掉数据项再加回新数据项）；
- 两者都不需要对 marker 的生成函数建模。

这条已经足够支撑「生成可加载 bitstream」的工程需求，ECC 建模到此收口。

## 35. TM2 —— 无参考篡改定位：单 bit 99.4% 可检出，2 bit 完全不可见（2026-11-03）

新脚本 `v7re/scripts/tamper_localize.py`，报告 `paper/TAMPER_LOCALIZER.md`，
原始结果 `tamper/{res_*,ex_ref,atk_ref300,ver_*}.json`。

**1) 找到一条新的结构不变量（L2）**：把物理 mux 槽位定义为 `(tile, bit b, parity)`，
则合法编码只有「6 行 one-hot × 列码 ∈ {1,2,7,11}」：

```
rows = [r for r in (0,1,4,5) if M[base+16+r, word, b]] + [r for r in (2,3) if M[base+16+r, word, b^1]]
code = sum(M[base+25-i, word, b] << i for i in range(4))
```

三条不变量（最多 1 行 / 有行⇒码合法 / 有码⇒有行）在 **73,152 个非平凡槽位、6 个位流上 0 违例**
（含真实设计 `tamper/ref/ref.bit`：945 tile、1,812 条 PIP、60,480 槽位）；
再对 `E:\v7work` 下全部 **34 个探针位流**跑同一校验：1,516 tile、**97,024 槽位、0 违例**
（扫描结果 `tamper/scan_all_probes.txt`），合计 40 个位流、170,176 槽位零违例。
注意 `T4` 的「一 (tile,family) 一源」在真实位流上恒有命中（cell 复用导致 phantom 命中），
只能当诊断不能当判据 —— 这是 L2 必须按物理槽位定义的原因。

**2) 单 bit 穷举（解析式，`--verify` 真翻转 120/120 校验）**：真实设计 1,572,246 个单点翻转
检出 **99.44%**；清位方向 mux 区 100%（因为 `{1,2,7,11}` 在 1 bit 距离下不封闭）；
漏检全部是「2 格长线驱动候选的最后一格」——补上它解码器会多报一条合法 PIP（`ref` 上 8,831 个，
占空位 0.56%），L1 自解释、L2 合法，故沉默。

**3) 2 bit 攻击完全不可见**：空槽位写「1 行位 + 1 码位」即合成合法幽灵 mux，
`ref` 200/200、`_full8` 100/100 **零检出**，且解码器会报出一条从未布线过的 PIP
（样例 `INT_R_X17Y222` `BYP_ALT0 ← SW2END0`）。换源攻击（2–4 bit）检出 29%，
且检出完全来自共享格的附带损伤（有共用 49.6% / 无共用 15.9%），精心选格可近乎 0 检出。

**4) 与 T6b 对偶**：读出侧 2 格 pattern 不可判 ↔ 写入侧 2 bit 自由改动，同一个字距事实。

**覆盖**：45.25% 配置位（INT tile 帧 0..25 的两个 word）；CLB/DSP/BRAM/word50 等不在内。
**ECC 已不构成防线**（见 §34），所以这条线量的就是「攻击者能重算 ECC」时的真实可检出性。
**4) 整类篡改矩阵（穷举/固定种子，`tamper/classes_*.json`）**：

| 篡改类 | `ref` | `_full8` |
|---|---|---|
| 删除一条已布线 PIP（全格子清 0） | 17/834 = **2.04%** | 5/76 = 6.58% |
| 向空槽位添加一条合法 PIP | 0/945 = **0%** | 0/76 = 0% |
| word50（ECC 字）单 bit 翻转 | 0/945 = **0%** | 0/76 = 0% |

删除的 2.04% 全部是「共享格附带损伤」（邻居 PIP 残格变 L1 + L2 `code-no-row`），
孤立 PIP 删除 0 检出，且定位指向受害邻居而非被删那条。
`ref` 里 42.9% 的 PIP（768/1,789）与别的 PIP 共享格子，但检出只有 2.04% ——
「共享」是必要非充分条件，可预测模型仍未闭合。

**5) 误报率（`--fpstats`，干净位流）**：L2 违例 6/6 位流为 0；`ref` 的 L1 未解释位
234 个，集中在 117/945 tile（12.38%），固定为 `(fo=1,bit=0)` 与 `(fo=1,bit=1)` 两格；
建模位误报 148.8 ppm。加白名单（`KNOWN_UNMODELED={(1,0,0),(1,1,0),(0,16,1)}`）后
告警 tile 0、未解释位 0 —— **未标定时 FP 不是 0，必须声明这一前提**。

**6) 真实 LUT 功能篡改（Vivado 造，`tamper/ref/tamper_init.{tcl,bit,log}`）**：
打开 `routed.dcp`，24 个 LUT6 的 INIT 全改，`route_design -preserve` 重写位流
（DRC NSTD-1/UCIO-1 需在 tcl 里降级，run-context 属性不随 dcp 保存）。
结果：与 `ref.bit` 差 **1,092 bit，落在建模区 0 个**；解码 PIP 数两边都是 1,789，
**945/945 tile 的 PIP 集合完全相同**；L1/L2 输出逐字等价（234/0）。
→ **功能被改、布线不变的位流，结构检测器 0 报警**，这是本方法的适用边界。

**7) 与 T6b 对偶**：读出侧 2 格 pattern 不可判 ↔ 写入侧 2 bit 自由改动，同一个字距事实。

**覆盖**：45.25% 配置位（INT tile 帧 0..25 的两个 word）；CLB/DSP/BRAM/word50 等不在内。
**定位精度**：单 bit 检出即精确定位 `(tile,frame,word,bit)`；mux 槽位违例可定位到槽位
（`(bit,parity)` → law 的 pair 映射）；附带损伤型检出必然指向受害邻居（换源 19 次检出中
**0 次**落在被改格子上：被清的格已变 0，不可能出现在 L1；新置的格正好补全合法 PIP）。
**检出 ≠ 定位准**，论文必须写清。
**ECC 已不构成防线**（见 §34），所以这条线量的就是「攻击者能重算 ECC」时的真实可检出性。


## 35.1. T8 —— 位流改写器闭环（2026-11-04）

新增 `v7re/scripts/ecc_model.py` 与 `v7re/scripts/bitgen.py`；模型 `v7re/steps/ecc_model.json`。

**ECC 数据项模型**：739 方程迭代剔除 marker 污染 → 收敛为 124 个位置签名（秩 124，无矛盾）。
跨设计验证（预测同一帧的 ECC 差）：c0↔c3 59/59、c0↔c4 46/46、c0↔full8 56/56 全对；
c0↔d2 62 对 1 错（错的是边界 marker 帧）。

**改写器能力**：`--set frame:word:bit=v` 直接改 payload 字节 + 自动重算受影响帧的 word50
（低 13 位 XOR `L[p]`，高位 marker 保留）；未知位置拒绝写入。

**验证**：
- 无改动 → 输出与输入 sha256 完全相同（`B777B900…DFCC6F`）；
- 删除 `INT_L_X8Y20` 的 `WR1END2->>IMUX_L5` → 文件差异恰为 4 数据位 + 4 个 word50，无其它帧波及；
- 反解码：`_full8.bit` 有该 PIP（108 条 IMUX），`_full8_edit.bit` 没有（105 条）。

**边界**：未在真实器件加载验证（无硬件）；ECC 模型目前覆盖 124 个位置，
mux 区 PIP 增删够用，CLB INIT 全量与长线族仍需扩充（扩模型已自动化）。

文档：`v7re/steps/T8_BITGEN.md`。


## 36. T8b —— 用 c0 生成 c3：50,172/50,176 帧与 Vivado 逐字节一致（2026-11-04）

把 ECC 模型扩到 154 个位置（新增 2020 探针 a/b/bit_base 三份位流训练；

```
初始方程 978 → 秩 236（矛盾）保留 787 → 秩 163 保留 771 → 秩 155 保留 756 → 秩 154 收敛
```

决定性验证：c0 与 c3 逐帧比较有 94 个数据位不同，其中 78 位在模型覆盖内。
用 `bitgen.py` 把 78 位写进 `_c0.bit`，与 Vivado 的 `_c3.bit` 比较：

| 指标 | 结果 |
|---|---|
| 改动位数 / 受影响帧 | 78 / 64 |
| 与 Vivado 产物不同的帧 | **4**（32500/32574/32606/32607） |
| 其中属「含未覆盖位」的帧 | **4（全部）** |
| **模型算错的帧** | **0** |
| 逐帧完全相同 | **50,172 / 50,176 = 99.99%** |

即：ECC 模型覆盖到的改动，生成结果与 Vivado **逐字节一致**（含 64 帧的 word50）。
剩余 16 个未覆盖位置在 word 2/3/4/5/14/16 的若干 bit，补全后可达 100%。


## 37. T9 —— FASM 层打通（2026-11-04）

新增 `v7re/scripts/fasm2bit.py`：`tile.family.source` 文本 ↔ 位流双向。

**语义**：族内互斥（先清该 mux 全部候选源，再点亮目标源）、地址按
`frame = far_bands[band][col] + frame_off`、`word = 2*(y%50)+parity`（≥50 再 +1）；
ECC 只对实际变化的位做增量（同 `bitgen.py` 口径），未覆盖位置拒绝写入。

**验证一：幂等性**。把 `_full8.pips` 翻成 56 行 FASM 写回原位流 →

```
_full8.bit        FAE4412F1916B55FF7C7BA7FFF85CABCF9F6C653BF9E05A723A94439E45A52A1
_full8_idem.bit   FAE4412F1916B55FF7C7BA7FFF85CABCF9F6C653BF9E05A723A94439E45A52A1
```

逐字节相同 → 「互斥 + 地址 + ECC」组合无损。

**验证二：换 mux 源**。`INT_L_X8Y20.IMUX_L5.WR1END2` → `.NR1END2`，写出后反解码：
`_full8.bit` 读出 `IMUX_L5.WR1END2`，`_full8_swap.bit` 读出 `IMUX_L5.NR1END2`。

**边界**：`--decode` 只解 4 格及以上（full8 48 条里解出 33 条）；
写入受 ECC 覆盖限制（把 48 行套到 c0 上被拒，帧 31768 w41 若干位未覆盖）；
CLB 特征与 BEG 长线族尚未接入。

文档：`v7re/steps/T9_FASM.md`。


## 38. T10 —— CLB 写入：ECC 对，INIT 位映射错（2026-11-04）

`fasm2bit.py` 增加 CLB 路径（`SITE.BEL.INIT=0x…`），位映射取自 `site_frames`。
内部闭环自洽：改 `SLICE_X12Y20/ALUT` INIT 0x1→0x3，读回 0x3、只动 1 帧、ECC 已重算。

**但拿 Vivado 对照发现表错**：同一 RTL 把 INIT 改成 3 重新实现（`full8_i3.bit`）后对比：

```
frame 31786 word40: 我方 0x8000  Vivado 0x8080
frame 31787 word40: 我方 0x8000  Vivado 0x0000
```

Vivado 的 INIT[01] 在 **frame 31786 word40 bit7**（与 INIT[00] 同帧），
而 `site_frames` 说在 frame 31787 word40 bit15。→ **CLB LUT INIT 的 cell 定义错了**
（成对 INIT 位同帧不同 bit：15 与 7），3,679 万行里 CLB INIT 部分需重做。

**ECC 顺带被独立验证**：Vivado 该帧 ECC 由 0x086f → 0x1008，
而模型给出 `L[(40,15)]^L[(40,7)] = 0x86f^0x1867 = 0x1008`，完全一致，
且 (40,7) 从未参与训练。

修正方向：用 `INIT=2^k`（k=0..63）的单点设计 + 空基线直接测出每个 INIT 位的绝对位置，
重建 `clb_cells` 中 INIT 族；地址公式（frame=base+off、word=2*(y%50)+parity）可保留。

文档：`v7re/steps/T10_CLB_WRITE.md`。


## 39. T11 —— CLB INIT 位映射重建（2026-11-04）

**位平面法**：不造 64 个单点设计，只造 6 个（INIT = 0x5555…/0xCCCC…/0xF0F0…/0xFF00…/0xFFFF0000…/0xFFFFFFFF00000000），
与基线 `_full8.bit`（INIT=1）差分，用 6 位二进制索引还原每个 INIT 位的绝对位置。约 20 分钟完成。

**结果**：`v7re/steps/clb_init_map_x12y20.json`，64 条无重。
所有 INIT 位都在 **word 40**（y=20 parity 0），分布在 **frame 31784/31785/31786**（base+68/69/70）。
旧 `site_frames` 说的 frame 31786/31787 是错的。

**验收**：`INIT=0xDEADBEEFCAFEBABE` 预测 vs 实测 —— 预测 46 格，实测 47 格
（多出的 1 格是 INIT[0] 被清零），**误报 0、漏报 0**。

**逐字节对账**：`bitgen.py` 把 `_full8.bit` 的 INIT 从 1 改成 3，与 Vivado 的 `full8_i3.bit` 比：
- 帧级差异 **0 / 50,176**；
- 字节级差异 **11 个**：7 个是头部时间戳（2026/11/02 18:43:26 → 2026/11/04 21:02:34），
  4 个是尾部 CRC 值（`0x4e6c4350` vs `0xb3b04c17`）。
  → **配置数据完全一致**。

**未解**：尾部 CRC 算法（试过 MSB/LSB、字节序、位序、初值/终值、zlib，均不匹配）。
两条路：①把 CRC 也当 GF(2) 线性函数学；②省略 CRC 包（需硬件验证）。

文档：`v7re/steps/T11_CLB_INIT_MAP.md`。


## 40. T12 —— 解码链重建：表有效性清单与当前准确率（2026-11-05）

用户决定暂不处理 CRC，先把「位流 → 网表」用实测定律重做。已落清单与实测数字。

**表有效性**：PIP 定律（1,536/1,536 精确）、GCLK 位、CLB INIT-ALUT（64 位）、ECC 数据项（154 位签名）
均为实测定律；`law_cells` 帧 0–15 时钟族与实测一致；`site_frames` 的**地址公式正确、CLB cell 定义部分错误**。

**解码实测**：
- LUT INIT（ALUT，X12Y20）：`_full8.bit`→0x1、`_v.bit`→0xdeadbeefcafebabe、`_full8_i3.bit`→0x3，**3/3 精确**；
- INT PIP：full8 召回 190/198、c0 24/27；多出的 92/7 条全为 2 格 pattern 歧义；4 格以上 0 假阳。

**未覆盖**：同 slice 的 B6/C6/D6 三个 LUT（旋转位平面实验未解出一致分组）、其它 y/列、FF 属性、进位链、BEG 长线族。

**下一步**：对每个 BEL 单独做 6 个位平面实验（8×6=48 次综合，约 2 小时），
避免依赖「帧 → LUT 归属」的猜测，然后整段重建 `site_frames` 的 CLB 部分。

文档：`v7re/steps/T12_DECODE_REBUILD.md`。


## 41. T13 —— CLB 全 8 个 LUT 的 INIT 映射（2026-11-05）

逐 BEL 位平面法：每个 BEL 独立 6 个位平面 + 1 个 `INIT=0x1`（补 index 0），8 个 BEL 共 57 次综合。
产物 `v7re/steps/clb_init_map_8lut.json`（8 × 64 位）。

**结构**（块基址 31716，`SLICE_X12Y20`=X0、`SLICE_X13Y20`=X1）：

| BEL | 相对帧 | 字 | 位段 |
|---|---|---|---|
| X0.A/B/C/D6LUT | +68…+71 | 40 (A/B) / 41 (C/D) | A/C:0–15, B/D:16–31 |
| X1.A/B/C/D6LUT | +62…+65 | 40 (A/B) / 41 (C/D) | 同上 |

每 LUT = **4 帧 × 16 位**；旧表 `clb_cells` 的 `frame_off 32..35` 是错的。

**验证**：造 `X0.D6LUT=0xDEADBEEFCAFEBABE`、`X1.C6LUT=0x0123456789ABCDEF` 的设计反读，
两个随机值全对，未用 LUT 读 0（无串扰）。

**未验证**：映射是否随行/列平移（只验 y=20 单列）；FF/进位链未重测；`site_frames` 未重生成。

**踩坑**：z 系列首跑用 `sed` 替换 `base8.v`，但 tcl 里是 `b0.v`，未命中 → 8 个设计全跑成基线，差分全 0。

文档：`v7re/steps/T13_CLB_INIT_ALL8.md`。


## 42. T14 —— INIT 映射平移性检验（2026-11-05）

在 `grid_col=6, y=8` 重做位平面实验（8 次综合），与 T13 的 `y=20` 对比：

**通用成立的部分**：帧偏移 inst1 = base+26…29、inst0 = base+32…35；`word = 2*(y%50)+parity`。
**SLICEL 的 64 位排列也通用**：用 T13 的 SLICEL 表按 base 平移，解 `SLICE_X3Y8` 的
A6LUT=0x00000000FFFFFFFF / B6LUT=0xFFFFFFFF00000000，结果逐位精确。
**SLICEM 的排列不通用**：同一实验里 `SLICE_X2Y8`（inst0/SLICEM）用 y=20 的表解不出；
重测后与 y=20 表「完全相同条目 0/64」（帧与字一致，帧内位排列不同）。

**影响**：CLBLL 全是 SLICEL → 一张表通吃；CLBLM 的 X0 是 SLICEM → 需额外规律或按位置建表。
也解释了 T11 为何得到「自洽但错」的表：不同 slice 实例的排列本来就不同。

**下一步**：在 3–4 个不同行的 SLICEM 上各做一次位平面，看排列是否是行号的周期函数；
否则按「行 mod N」分别建表。

文档：`v7re/steps/T14_INIT_TRANSLATION.md`；数据 `clb_init_map_8lut.json`、`clb_init_map_y8_x2y8.json`。


## 43. T14 更正 —— INIT 映射跨位置推广失败（2026-11-05 晚）

收回 T14 第 2、3 节的结论，原因三条：

1. 「SLICEL 平移成功」的证据无效：当时用的 `0x00000000FFFFFFFF` / `0xFFFFFFFF00000000`
   是半区全 1 的值，对位排列不敏感；
2. col 6 的 row 3 / 8 / 9 三次位平面测量得到三张不同的表（相同条目 7/63、2/63、4/63），
   但帧起点（base+32）与字（2y）都一致 —— 只有位排列不同；
3. **自校验失败**：用 row 3 自己的表解 `SLICE_X2Y3` 的随机 INIT `0xA5A5F0F01234ABCD`，
   解出 `0x5A5AF0F0213857CE`，不符。

第 3 条说明测量流程在这些位置不可靠，最可能是不同构建里 placer 把 cell 放到了不同 slice
（`INIT=0` 与 `INIT=1` 的优化路径不同）。

**仍成立的**：帧偏移 inst0 = base+32…35 / inst1 = base+26…29；`word = 2*(y%50)+parity`；
y=20 / `SLICE_X12Y20` 的 8 个 BEL 表（随机值验证 3/3）。

**修正做法**：每个构建必须打印并校验 `SITE` 与 `BEL`，只采纳全部一致的构建组；
在此之前不做任何跨位置推广。

文档：`v7re/steps/T14_INIT_TRANSLATION.md` §7–§9。


## 44. T15 —— 单最小项法与行间位序置换（2026-11-06）

**方法换血**：位平面法在 row 3 上系统性失败（连 SITE/BEL 回读 + 掩码重跑都过不了自校验），
改用**单最小项法**：每个 truth-table 索引 k 单独一个设计（`INIT = 1<<k`），
与全零基线差分，出现的那一格即该索引的位。

**row 3（`SLICE_X2Y3`/A6LUT）结果**：65 个构建全部 `SITE/BEL/INIT` 回读一致；
每次构建恰好 1 个新格（64/64），64 格互不相同；
反读 `0xA5A5F0F01234ABCD` **精确命中**（同一文件在位平面表下解错），全零设计读 `0x0`。

**结构**：row 3 的 INIT 在 base+0…3 帧、字 6；row 20 在 base+68…71 帧、字 40
（帧组随行变化，字按 `2*(y%50)+parity`）。

**关键发现**：row3 与 row20 的 64 个物理格**完全相同**，差异是索引位的**纯位置换**
`(0 4)(1 2)(3 5)`（已在全部 64×64 组合验证 `perm(x^y)=perm(x)^perm(y)` 且 `perm(0)=0`）。

**进行中**：row 4 / row 8 同法扫描（每设计 16 LUT，65 构建），用于判断置换是否只随帧组变化。

文档：`v7re/steps/T15_SINGLE_MINERM.md`。


## 45. 两行 16 LUT 合并扫描（2026-11-06）

row 4 / row 8 各放 A6/B6/C6/D6（共 16 个 LUT6），`INIT=1<<k` 逐轮替换，65 个构建。
每次构建恰好新增 **16 格**（每 LUT 一格），涉及 word 8/9（row4）与 16/17（row8），
每 word 256 格 = 4 LUT × 64，分布于 8 个帧（31778–31781、31784–31787），每帧 32 格。

**关键**：4 个 word 的 `(帧, 位)` 位置集合**完全相同** —— 同行 block 内不同 row/parity
只改 word、不改帧与位。minterm 样例显示位成对出现（`b` 与 `b+16`）。

LUT 之间的格分配仍需额外约束，已启动 `SLICE_X12Y4`/A6LUT 的单 LUT 对照扫描（65 构建）。


## 46. T16 —— INIT 布局全局统一（2026-11-06）

单 LUT 最小项法在 row 3 / row 4 / row 20 各测一张 A6LUT 表（帧归一化后都是 +0..+3，4 帧 × 16 位）。
三者**位置集合完全相同**；索引映射只差一个仿射置换：

| 对比 | 解 |
|---|---|
| row4 → row20 | `perm=(0,4,2,1,3,5)`, `c=0` |
| row4 → row3 | `perm=(4,0,1,2,5,3)`, `c=0` |

原因：INIT 扫描脚本没加 `LOCK_PINS`，router 自由重排 `I0..I5` → truth-table 索引被置换。
早期 PIP 实验（`build_bel.tcl`）是加了 `LOCK_PINS` 的，所以没这个问题。

**结论**：物理布局与行/列无关，`site_frames` 的 CLB INIT 可用一张表覆盖全器件（取
`v7re/steps/clb_init_row4_a6.json`）。T14 里「布局随行变化」的判断作废。
后续所有特征位构建必须加 `LOCK_PINS`；FF/进位需同样复查。

文档：`v7re/steps/T16_INIT_LAYOUT_UNIVERSAL.md`。


## 47. T17 —— LOCK_PINS 确认通过 + FF.INIT 定位（2026-11-06）

18 个构建（`/opt/lzh/v7re/work/lockff`），每构建回读 SITE/BEL/INIT。

**LOCK_PINS 确认**：两行（`SLICE_X12Y4` / `SLICE_X12Y20`）同 BEL 加 `LOCK_PINS {I0:A1 … I5:A6}`，
k=1,2,4,8,16,32 的归一化位置 **5/5 逐项相同**（差异只在 word：8 vs 40，符合 `2*(y%50)+parity`）。
→ T16 结论成立：物理布局全局统一，之前差异全部来自未锁引脚。

**FF.INIT**：`FDRE` 的 `INIT=1` 相对基线 **只清掉 1 格** —— `(帧+67, word 40, bit 3)`。
这是 FF 的第一条可靠映射，单比特、可逆。

**FF CE/SR 未测出**：CE/R/S 改接真实引脚会同时改变布线，差分混入 47–49 个 INT 布线位，
无法分离。下一步用「只换原语、不动布线」的对照（`FDRE(.CE(1),.R(0))` vs `FDSE(.CE(1),.S(0))`）。

文档：`v7re/steps/T17_LOCKFF.md`。


## 48. T18 —— T13 的 INIT 表不能用于真实设计（2026-11-06）

用 T13 的表解 T17 里 `LOCK_PINS` 的设计：`k=2/4/8/32` 全部不符（解出 `0x100000000`/`0x100`/`0x4`/`0x2`），
只有 `k=16` 巧合正确。

**原因**：T13 的 64 次构建没加 `LOCK_PINS`，Vivado 自由分配 I0..I5 → 记下的索引是那次分配的逻辑索引，
不是固定引脚顺序。真实设计的分配由 placer 决定，所以该表**不能用于解码真实设计**。
（T13 随机值 3/3 之所以通过，是因为测试设计共享了同一分配。）

**仍然成立**：物理格集合（64 个）、布局与行/列无关（T17 的 L4/L20 5/5 一致）。

**处置**：以 LOCK_PINS 版本为准重做索引映射。已启动 65 个构建（`/opt/lzh/v7re/work/locked`，约 80 分钟）。

文档：`v7re/steps/T18_LOCKPINS_REQUIRED.md`。


---

## 附：器件修正（2026-11-06）

**本项目全部探针 DCP / bitstream 的实际 part = `xc7vx485tffg1157-3`**，不是文档长期假定的 VC707 `xc7vx485tffg1761-2`。

证据三条（互相独立）：
1. routed DCP：`get_property PART` = `xc7vx485tffg1157-3`（远端 `part2.tcl` → `part.txt`）；
2. `.bit` 头部 150 B ASCII 段器件名 = `7vx485tffg1157`；
3. 键合 IOB 数：ffg1157 = **600**，ffg1761 = **700**（`pins/pins_map_ffg1157.csv` / `pins_map_ffg1761.csv`）。

影响面：**fabric 层（帧/tile/site/BEL/CLB·INT 位图/家族位池/IMUX/pin-swap/走线）全部不受影响**；所有 `PACKAGE_PIN` 结论属 ffg1157，若上 VC707 需重映射（12 个已用 IOB 的两套引脚对照见 `step03_pip/PART_CORRECTION_FFG1157.md`）。

结论：位级逆向结论保持有效；引脚结论限定封装。后续构建若要求与 VC707 对齐，须显式 `-part xc7vx485tffg1761-2`。


## 49. T19 —— LOCK_PINS 版 INIT 映射建成并双路验证通过（2026-11-06）

65 个构建（`/opt/lzh/v7re/work/locked`，全部带 `LOCK_PINS {I0:A1 … I5:A6}`，回读 SITE/BEL）。
每个 `INIT=1<<k` 相对基线只多 1 格，64 格互不相同、无缺失。

**闭式公式（64/64 全对）**，`B` = 块基址（本例 31716）：

```
frame = B + 70 + (k & 1) - 2 * ((k >> 3) & 1)
word  = 40
bit   = 15 - 4 * (k >> 4) - ((k >> 1) & 3)
```

**验证**：自洽 64/64；跨构建（T17 独立脚本造的 `L20_k1/2/4/8/16/32`）**6/6 精确**。
表存 `v7re/steps/clb_init_locked_x12y20_a6lut.json`。

**对 T18 的更正**：T18 里我把 `L20_k2` 的期望值写成了 `0x2`（实际 INIT 是 `0x4`），
这不影响 T18 的核心结论——T13 表（无 LOCK_PINS）解 `LOCK_PINS` 设计仍不符；
两张表的**物理格集合完全相同**，差别只在索引空间。

**解码真实设计的含义**：本表给的是物理真值表（索引位 = `A1..A6` 组合），
要得到逻辑函数还需按实际引脚分配做一次置换（布线信息在 `site_pins`/PIP 里已有）。

文档：`v7re/steps/T19_LOCKED_INIT_MAP.md`。

## 50. T20 —— 用 skill 实测 part 对差分：INIT 映射与封装无关，但 part 差分不为零（2026-11-06）

按 `.agents/skills/fpga-bitstream-experiment` 的八道门跑了一遍真实流程（5 个构建，`/opt/lzh/v7re/work/partpair`，5 路并行，全部 rc=0，全部 `LOCK_PINS`，回读 part/SITE/BEL/INIT/LOCK 一致）。

**负对照**：同 part 同设计重跑的 `b0_1157` vs `b0b_1157` → 差分帧 **0**。

**反读自证**：`INIT=0xDEADBEEFCAFEBABE`（**不在 T19 的 64 个单最小项里**）相对 `INIT=0` → 4 帧（31784–31787），word 40 共 **46 位**；T19 闭式公式独立预测 46 位，**集合相等：missing 0 / extra 0**。同帧 word 50 恰变 **14 位**（bit 0..12，ECC 域内）。

**part 对**（同 netlist、同 LOC/BEL/LOCK_PINS、同 INIT，仅 `-part` 不同：`ffg1157-3` vs `ffg1761-2`）：

| 差分对 | 差异帧 | 差异位 |
|---|---|---|
| `b0_1157` vs `b0_1761` | 133 | 1,210 |
| `r_1157` vs `r_1761` | 133 | 1,210 |

两对帧集合完全相同（27189…32607），**不含 31784–31787** —— 本 BEL 的 CLB INIT 帧（word 40）两封装下逐字节相同。

【数据事实】T19 的 INIT 映射在本设计域内**与封装无关**；这是 `STATUS.md` 附「fabric 层不受影响」的第一条直接实测（此前只有键合 IOB 数 600 vs 700 的间接论据）。
【未测】那 133 帧 / 1,210 位的成因未确认。
【推断】最可能来自未约束端口 `a0..a5/o` 的默认 IOB 分配（两封装可用引脚不同）；21 帧落在同一 block（base 31716），word 50 占 766 位（内容变 → ECC 重算）。
最小验证实验：给所有端口加 `PACKAGE_PIN` 约束到两封装共有的 IOB 后重跑该对，若差分降为 0 即确认成因。

**顺带发现**：`/opt/lzh/v7re/work/locked/mk.tcl` 里写的是 `-part xc7vx485tffg1761-2`，与器件修正（实际 part `ffg1157-3`）不符。本次两边都跑，结构同为 4 帧 / 46+14 位，故 **T19 表未被 part 污染、仍可用**；但后续构建必须显式声明 part。

文档：`v7re/steps/T20_PART_PAIR.md`。

## 51. Skill V2 升级落地 + manifest 机检 + site_frames 债的可行性分析（2026-11-06）

T20 跑完后按实测缺口把 `.agents/skills/fpga-bitstream-experiment` 升级到 V2（110 行）。改动的每一段都经 prompt-optimizer（`iterate-prompt`，template=`iterate`）生成后落盘，没有手写规则正文。

### 51.1 skill 新增的硬条款

| 门 | 新增条款 | 触发它的实测事实 |
|---|---|---|
| 4 构建 | 显式 `-part` 并断言回读；base64 落地成文件；远端差分只回 JSON | T20 顺带发现 `locked/mk.tcl` 写的是 `ffg1761-2`；回传 base64 被终端污染 |
| 5 自校验 | 集合级自证（`missing=0` 且 `extra=0`，禁抽样）；自证须打印四个数；word 50 ECC 单独计数；**交叉自证（另一脚本 + 另一批独立构建）** | T19 的 46 位是拿 T17 独立构建复核的 6/6 才算数 |
| 6 判读 | **未解释差异处置纪律**：不许用「不影响结论」结案，必须归因或显式写「本结论不覆盖 N 帧 / M 位」 | T20 的 133 帧 / 1,210 位至今未归因 |
| 7 落库 | 必须产出 manifest JSON 并经 `step03_pip/check_manifest.py` 校验 PASS；FAIL / WARN 未处置不得写入 STATUS 当结论 | T13 的错表无格式可机检 |
| 8 交付 | 结论等级 `verified` / `unverified` + 判定依据；未解释区间必须列出 | 同上 |

新增 `reference/commands.md`：ssh 调用姿势、远端并行构建骨架、远端差分只回 JSON、base64 落地、增量 ECC、错误对照（CRLF / ENAMETOOLONG / tar 无成员 / scp 挂死 / license）。

### 51.2 manifest 机检（新脚本）

- schema：`.agents/skills/fpga-bitstream-experiment/reference/manifest.schema.json`（含 `parts_allowed`，封装对拍实验必须显式列白名单，否则校验器判 FAIL —— 这是校验器第一次跑就抓出来的建模漏洞）。
- 校验器：`step03_pip/check_manifest.py`（Windows 控制台 GBK 会 UnicodeEncodeError，已 `reconfigure(encoding='utf-8')`）。
- 示例：`v7re/steps/t20_manifest.json`（INIT 映射，`verified`，PASS 15 ok）、`v7re/steps/t20_manifest_partpair.json`（封装对拍，`unverified` + `coverage_exclusion`，PASS 14 ok / 1 warn）。

【数据事实】校验器不是橡皮章：对 T20 manifest 做了 8 个变异，全部被抓。

| 变异 | 校验器输出 |
|---|---|
| `missing=3` | FAIL 集合级自证未过 |
| `extra=1` | FAIL 集合级自证未过 |
| 负对照差分帧=2 | FAIL 环境有问题 |
| 交叉不一致但仍标 verified | FAIL ×2（不一致项 + 等级不成立） |
| 删 `cross_check.batch` 仍标 verified | FAIL ×2 |
| 少锁 `I5` | FAIL LOCK_PINS 未锁全 I0..I5 |
| 封装对拍缺 `parts_allowed` | FAIL part 不在白名单 |
| 有未解释差异且无处置 | FAIL 禁止「不影响结论」结案 |

### 51.3 T19 表接进 site_frames：现在接不了（两条未测）

`v7re/scripts/build_site_frames.py:109-123` 的 INIT 映射来自 `v7_law.sqlite` 的 `clb_cells`（T13 血统的表），落库时用 `frame = base + off`、`word = w0 + parity`。

【数据事实】`v7re/steps/clb_init_locked_x12y20_a6lut.json` 覆盖 **64/64** 个 INIT 索引（0..63 全在，frame_off 落在 `base+68..base+71`、word 40），所以「表不全」不是障碍；T20 自证只动 46 位是因为 `0xDEADBEEFCAFEBABE` 的 popcount 正好 46，不是索引缺失。

【未测】接进去还缺两条实测：
1. **bel 不变性**：B6LUT / C6LUT / D6LUT 的 frame_off / word 是否与 A6LUT 同构（每 word 装哪个 LUT 未测）。
2. **位置不变性**：frame_off 是否真按 block 相对地址走（T14 的跨位置推广就翻过车），只测了 `SLICE_X12Y20`。

最小实验（T21，约 8 个构建 / 2 分钟）：`SLICE_X12Y20` 的 B6LUT / C6LUT / D6LUT 各跑 INIT=0 与 `0xDEADBEEFCAFEBABE` 对（管脚前缀 B/C/D、`LOCK_PINS {B1:B1 … B6:B6}` 形式），再加 `SLICE_X12Y21` 的 A6LUT 一对验位置不变性；四组 frame_off 集合若与 A6LUT 的 `{68,69,70,71}` 同构，才能把该表替换进 `emit_site_frames`。在此之前用 T13 血统的表生成 site_frames 属**已知风险**：风险成立与否取决于上面两条未测项，先跑 T21 再决定替换或保留。

### 51.4 结论等级

【数据事实】本次 skill 升级与校验器均已跑通（示例 manifest PASS + 8 变异全被抓）。
【未测】skill 的行为验证（正例 / 近例 / 压力场景）未跑，按 `writing-skills` 只能报 needs-verification，不宣称 deployment-ready。

## 52. T21 —— SLICE 内四个 6-LUT 的 INIT 落位不变性 + 行位置不变性（2026-11-06）

**目的**：T19 的锁引脚 INIT 表（`v7re/steps/clb_init_locked_x12y20_a6lut.json`，64 个单最小项，`SLICE_X12Y20`/A6LUT）能否推广到同 SLICE 的 B/C/D6LUT 与其它行 —— 这是把它接进 `v7re/scripts/build_site_frames.py` 的前置条件。文档：`v7re/steps/T21_BEL_ROW_INVARIANCE.md`。

**构建**（11 个，part 全部 `xc7vx485tffg1157-3`，全部回读 PART 一致）：每个 bel 一对 `INIT=0` / `0xDEADBEEFCAFEBABE`，LOC 固定 `SLICE_X12Y20`，`LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}`，另加 `SLICE_X12Y21`/A6LUT 一对与一个同设计重跑负对照。

**【数据事实】bel 不变性成立**：四个 6-LUT 的落位帧全为 `base+68..71`（base=31716），归一化（B/D 位 −16、C/D 字 −1）后位图与 A6LUT 逐位相同（对称差 0）：

| BEL | 数据字 | 位区间 |
|---|---|---|
| A6LUT | `2*(Y%50)` | 0–15 |
| B6LUT | `2*(Y%50)` | 16–31 |
| C6LUT | `2*(Y%50)+1` | 0–15 |
| D6LUT | `2*(Y%50)+1` | 16–31 |

**【数据事实】行不变性成立**：`SLICE_X12Y21` 的帧集合同 y=20，数据字 40 → 42（= 2×21，事前预测命中），位区间与位图不变。

**【数据事实】负对照与附带宽**：同设计重跑差分帧 0；变化字只有 {数据字, 50}，word 50 为 ECC（14–18 位，随数据变化），未解释差异 0 帧 / 0 位。

**【数据事实】交叉自证**：用 T19 的 64 个单最小项表按上表规则平移，预测 46 个内容位 → 五个 pair 全部 pred 46 / act 46 / missing 0 / extra 0（`step03_pip/t21_crosscheck.py`，交叉批次 `T19_closed_form`，5/5 一致）。

**结论等级 verified**（manifest `v7re/steps/t21_manifest.json`，`step03_pip/check_manifest.py` 校验 PASS 15 ok）。

**【未测】本结论不覆盖**：
1. `Y%50 >= 25` 的 word 让位边界（`2*(Y%50)+1` 会撞 word 50 的 ECC 字）；最小实验：`SLICE_X12Y25` 的 A6LUT 一对。
2. B/C/D6LUT 在 y≠20 的行（当前属规则外推）。
3. SLICEL 站点（本次全部回读为 `SLICEM.*`）。
4. 跨 block / 跨 clock region 的 `block_start` 与 frame_off 关系。

**对 site_frames 的含义**：INIT 落位可以写成纯函数 `(bel, Y) -> (frame_off 集, word, bit 区间)`，不必再依赖 T13 血统的表；替换时须把上面 4 条未测条目保留为显式覆盖边界。

**本次新踩的坑（已进 skill `reference/commands.md`）**：
1. WSL 里跑 Vivado 必须先 `export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE`，否则 `locale::facet::_S_create_c_locale name not valid` 直接 abort（rc=134）。
2. `LOCK_PINS` 的管脚名不按 BEL 命名：`SLICEM.B6LUT` 的 BEL 管脚仍是 `A1..A6`，写 `I0:B1` 会 `ERROR: [Vivado 12-2497] invalid device pin 'B1'`。
3. 本地 run_code 默认 120 s 短于 11 个构建的墙钟（约 3 分钟），必须显式抬高 timeoutMs。


## 52.1. T21 —— 四个 LUT 的 INIT 映射同构 + 行不变性（2026-11-06，verified）

11 个构建（`/opt/lzh/v7re/work/t21b|t21c|t21n`），全部显式 `-part xc7vx485tffg1157-3` 并断言 `PART=` 回读。
manifest `v7re/steps/t21_manifest.json` → `check_manifest.py` **PASS 15 ok / 0 warn / 0 fail**。

【数据事实】INIT 0 → `0xDEADBEEFCAFEBABE`，四个 LUT 各翻 **46 个内容位**（+ 同帧 word 50 的 14 位 ECC），
集合级 `missing=0 / extra=0`（A6/B6/C6/D6 四组 + X12Y21 一组，共 5 组）。负对照同参数重跑差分 **0 格**。

统一公式（`B` = 块基址）：

```
frame = B + 70 + (k & 1) - 2 * ((k >> 3) & 1)
word  = 40 (A/B) | 41 (C/D)
bit   = (15 if A/C else 31) - 4 * (k >> 4) - ((k >> 1) & 3)
```

【数据事实】行方向不变：`SLICE_X12Y21` 与 `X12Y20` 归一化后完全相同（word 40 vs 42）。
【未测】X1 slice（`SLICE_X13Y20`）四个 LUT、跨 block、跨 part 的 B/C/D。
【未解释】本批 0 帧 / 0 位。

全表：`v7re/steps/clb_init_locked_x12y20_4lut.json`；文档：`v7re/steps/T21_BEL_INVARIANCE.md`。
结论等级 **verified**（同源自证 + 交叉自证 + manifest PASS）。

## 53. Skill V3 —— 环境陷阱与「禁止全量回写长文档」入规（2026-11-07）

**触发**：T20/T21 与 STATUS.md 截断事故暴露的 6 条实测坑，此前只记在聊天里，未入 skill。

**做法**（AGENTS.md 硬规则）：提示词一律过 prompt-optimizer。本轮 MCP 服务进程已死（`127.0.0.1:8081` 无监听），重启 `E:\DEEPSEEK\tools\prompt-optimizer\start-prompt-optimizer.ps1` 后，DSH 的 mcp-client 已达到重连上限仍显示 disconnected，故直接对同一个 MCP 端点 `http://127.0.0.1:8081/mcp` 走 JSON-RPC（initialize → notifications/initialized → tools/call），实际调用的仍是 `optimize-user-prompt`（template=`user-prompt-professional`）与 `iterate-prompt`（template=`iterate`）。

**产物**：
- `reference/commands.md` 追加「## 踩坑与硬约束（2026-11-06 实测）」6 条（locale abort rc=134 / LOCK_PINS 管脚名实为 A1..A6 / 本地超时短于构建墙钟 / base64 禁塞命令行 / 禁止 read 全文 + write 全文回写长文档 / ssh 唯一姿势），文件 94 → 126 行。
- `SKILL.md` 升 V3（109 → 116 行，旧版备份 `SKILL.md.bak-20261107-174113`）：门 4 增 3 条硬规则（locale 三行 export、换 bel 前 `get_bel_pins` 实测、批量构建先本地生成脚本且超时 ≥300 s）；门 7 增「状态文档编辑」硬规则（append / edit / 写前备份 / 行数与标题数校验）；入口表把 `reference/commands.md` 标为踩坑清单唯一外置来源；历史翻车对照表补 3 行（locale、12-2497、STATUS 截断）。

**未变**：八道门结构不变，未新增第九门；结论等级判定（verified/unverified）与交叉自证规则沿用 V2。

**【未测】skill 行为验证**（正例 / 近例 / 压力场景对照）仍未跑，故 skill 自身只能标 `needs-verification`，不得称 deployment-ready。

## 54. T22 —— word 让位边界实测（Y%50=26）+ skill 行为验证（2026-11-07）

**目的**：T21 留的第一条未测项 —— `2*(Y%50)+parity >= 50` 时「再 +1 让开 word 50 的 ECC 字」。

**构建**（3 个，`/opt/lzh/v7re/work/t22/`，part 全部 `xc7vx485tffg1157-3`）：`SLICE_X12Y26` A6LUT，`INIT=0`、`INIT=0xDEADBEEFCAFEBABE`、同设计重跑负对照。全部回读 `PART/SITE/BEL/INIT/LOCK_PINS` 一致，rc=0。

**事前预测（构建前写下）**：翻位只在 4 帧 `31784..31787`；内容位在 **word 53（= 52+1）bit 0..15** 共 46 位；`word 52` 必须零变化。

**【数据事实】预测全部命中**：4 帧 `31784..31787`，46 个内容位全在 word 53 bit 0..15，word 50 有 14 位 ECC，**word 52 零变化**；负对照差分 0 帧 / 0 位。

**【数据事实】交叉自证**：`step03_pip/t22_crosscheck.py` 用 T19 的 64 单最小项表只做 `word 40 → 53` 平移 → `pred=46 act=46 missing=0 extra=0`，`RESULT PASS`。

**结论等级 verified**（manifest `v7re/steps/t22_manifest.json` 过 `check_manifest.py`：PASS 15 ok / 0 warn / 0 fail）。地址律覆盖到 `Y%50 = 20, 21, 26`。

**未测**：`Y%50 = 25`（原始字 50 → 51）与 `Y%50 = 49` 两个端点；跨 50 行的 band 切换；B/C/D6LUT 在其它行；SLICEL 与其它 col / region。

**skill 行为验证**（`v7re/steps/SKILL_VERIFICATION.md`）：正例 = 上文的 T22 真实执行，八门逐条命中，且 V3 新增的 locale 三行 export 与「先本地生成脚本再一次性远端执行」直接避免了 T21 踩过的 rc=134 与逐条交互失败；近例（只查 PIP，不应触发）= 路由正确，实测 `pip_query.py` 为纯查询；压力（要求跳过反读自证直接接 T13 表）= 被门 3/5/7/8 拦住。

**【未测】独立性验证**：本 runtime 无 subagent 派生工具，三个场景都由带上下文的我执行，存在「已知答案」偏差；故 skill 状态仍为 `needs-verification (partial)`，需在无上下文的新会话/子代理里重跑（另含误导场景与 `missing>0` 失败路径）。

## 55. 远端 step03 清理 A+B 档执行完毕（2026-11-07）

**触发**：用户「远端的脏数据可以清理一下」（11-06），先出只读清单 `step03_pip/REMOTE_CLEANUP_PLAN.md`，确认 `a＋b` 后执行。

**清理前账**（`du -sm` 226,730 MB = 221.4 GiB）：`.bit` 5,765 个 / 108.8 GB、`.bin` 5,570 个 / 105.2 GB、`.dcp` 5,834 个 / 7.1 GB、文本产物（json/log/txt/py/tcl，7,954 个文件）合计 0.23 GB。

**【数据事实】关键判据**：同名 `X.bin` 不是另一次实验，而是 `X.bit` 去掉 102 字节 Vivado 头后的逐字节副本 —— `band1/ref_B1.bit`（20,273,538 B）与 `.bin`（20,273,436 B）执行 `cmp -s -i 102:0` → MATCH，`tilepipe` 另抽一对同样 MATCH。故 A 档清垃圾、B 档逐文件自证后删 `.bin`：
- 删除命令是自证型：`[ -f "$b" ] && cmp -s -i 102:0 "$b" "$f"` 才 `rm`，否则打印 `KEPT` 保留。脚本 `step03_pip/_remote_cleanup_AB.sh`，日志 `/root/cleanup_20261107.log`。

**执行结果**：
- **B 档 deleted=5,566 / kept=4**，保留的 4 个是 `fam/` 下无 `.bit` 双胞胎的孤本（`v_FAN_ALT3_BYP_BOUNCE3.bin`、`v_BYP_ALT6_BYP_BOUNCE3.bin`、`v_EE2BEG1_LOGIC_OUTS_L1.bin`、`v_SE6BEG0_LOGIC_OUTS_L0.bin`）
- 磁盘 299 G → **194 G**（可用 657 G → **762 G**），回收 **105 G**
- `step03` 226,730 MB → **118,914 MB**；`.bit` **5,765 未变**；`.dcp` 5,834 → 5,833（`reuse4` 半途目录随 A 档删除）；`.bin` 剩 4
- A 档另清：`.Xil/`（188 M + 各目录 37 M）、`*.backup.log` / `*.jou`（2.5 M）、两个 CRLF 脏目录 `bands2\r` `dsptest\r`、`/tmp` 残留（仅留 `FLEXnet`）
- 重建性抽验：`tail -c +103` 任一 `.bit` 得 20,273,436 B，与原 `.bin` 尺寸一致

**未做（需另行决定）**：C 档删 `.dcp`（7.1 G，丢 checkpoint）、D 档删已消化目录的 `.bit`（108.8 G，不可恢复）。`s8/`、`part/` 为当日在用目录，未触碰。

## 56. T23 —— LUT INIT 索引顺序随 slice 种类不同 + T19 表接入 `build_site_frames`（2026-11-07）

**触发**：用户 m00667 的 A 档 —— 把 T19（`SLICE_X12Y20` A6LUT 锁引脚）的 INIT 表接进 `v7re/scripts/build_site_frames.py`，并要求把覆盖边界写成「`Y%50 ∈ {20,21,26}` 已实测，其余按公式外推」。

**先纠错（重要）**：`clb_blocks[(19,0)] = 31716` 覆盖 `SLICE_X10Y20/X11Y20`（`grid_col 19`）；`clb_blocks[(20,0)] = 31752` 覆盖 `SLICE_X12Y20/X12Y26/X13Y20`（`grid_col 20`）。T19/T21/T22 的绝对帧 `31784..31787` 实为 `31752 + 32..35`，故 **`frame_off = 32..35`**，早期文档写的「`base = 31716`，故 `frame_off = 68..71`」是 base 标错（帧号本身正确）。已在 `v7re/steps/T21_BEL_ROW_INVARIANCE.md`（第 45 行后的勘误段）与 `v7re/steps/T22_ROW_BOUNDARY.md`（第 11 行）就地修正；T19 闭式公式里的 `B = 31716` 只作常数、不影响结论。`T13/T15/T19/T20` 里的同类表述尚未逐处改写（一并留给下次文档轮）。

**law 库 INIT 数据的真相（推翻旧工作假设）**：`v7_law.sqlite` 的 `clb_cells` 里 INIT 行只有 12 个 family，`frame_off` 落在 26..35；按 `(tile_type, inst)` 分 8 组 —— `CLBLL_L/CLBLL_R` 两个 inst 都是 SLICEL，`CLBLM_L/CLBLM_R` 的 inst0 是 SLICEM、inst1 是 SLICEL。组基址：SLICEM_X0 与 SLICEL_X0 占 `frame_off 32..35`，SLICEL_X1 占 `26..29`。**SLICEM 的索引顺序与 T19 实测表 0 差异；SLICEL 的索引顺序与 T19 表差 64/64，但 T23 实测证明 law 的 SLICEL 顺序才是对的**。两套顺序互为仿射输入置换 `p(k) = 0x8 ^ (b0*0x1 ^ b1*0x2 ^ b2*0x4 ^ b3*0x9 ^ b4*0x10 ^ b5*0x20)`，且两种切片的 `(rel, bit)` 位池完全相同 —— 唯一变量就是索引顺序。

**T23 实验（3 构建，`/opt/lzh/v7re/work/t23/`，part 全部 `xc7vx485tffg1157-3`）**：`SLICE_X11Y20`（`CLBLM_R` inst1 = SLICEL）A6LUT，`INIT=0` / `INIT=0xDEADBEEFCAFEBABE` / 同设计重跑负对照，`LOCK_PINS {I0:A1..I5:A6}` + `DONT_TOUCH`，全部 rc=0、bit 20,273,538 字节、回读 `PART/SITE/BEL/INIT/LOCK` 一致（`RB_BEL = SLICEL.A6LUT`）。

- **【数据事实】** 差分 4 帧 `31742..31745`（= `31716 + 26..29`）；46 个内容位全在 word 40 的 bit 0..15（每帧 10/15/14/7）；word 50 有 14 位 ECC；负对照 0 帧 0 位。
- **【数据事实】** 与 law SLICEL 顺序预测 46/46 全等（对称差 0）；与 T19 SLICEM 顺序预测不等（帧集合相同、位分布不同）。
- **结论（verified）**：LUT INIT 索引顺序**随 slice 种类不同**，SLICEM = T19 顺序、SLICEL = law 顺序，两者各由实测确认。**【推断】** 成因是 SLICEM/SLICEL 的 LUT6 输入到 BEL 引脚对应不同，law 表并没有写错。
- manifest `v7re/steps/t23_manifest.json` → `check_manifest.py` **PASS 15 ok / 0 warn / 0 fail**；文档 `v7re/steps/T23_SLICEL_INIT_ORDER.md`。

**代码落地**（工作区，未提交）：
1. 新建 `step03_pip/gen_locked_init_map.py`：由 T19 JSON + law 生成权威表 `v7re/steps/clb_init_locked_map.json`（`orders.{SLICEM,SLICEL}` 各 64 条、`bel_rule`、`group_off`、仿射 `permutation`、`measurements`），并校验 64 索引全覆盖、`(rel,bit)` 互异、跨 tile_type 一致、置换关系成立；T23 的集合级复核写入 `measurements.SLICEL.matched = true`。
2. 改 `v7re/scripts/build_site_frames.py`（499 行）：`load_law` 给每个 `(tile_type, inst)` 打 slice 种类标签（同一组合出现两种切片直接报错）；`emit_site_frames` 对 INIT 特征改用按种类的实测表（`source` 标 `+locked:T19`），非 INIT 特征仍走 law；新增 `validate_locked_init()`（T19 锚点 64 条 + T23 锚点 46 点 + 全库 8 组顺序对账）；`validate()` 变四条校验；新增 `--locked-init / --no-locked-init / --dry-run`。
3. 新建 `step03_pip/test_locked_init_map.py`：T1 映射一致；T2 负对照（两套表互换后自检必须 FAIL）；T3 接入前后 `(site,bel,feature,frame,word,bit)` 集合差异 0（1,024 条锁定 INIT 行被走到）；T4 交叉佐证 T21/T22（word 40/42/53、四 bel 同帧组 `31784..31787`）。

**实跑**：`python v7re/scripts/build_site_frames.py --validate` → 全项 PASS（结构 / 锚点 `X10Y20` base=31716 word0=40 INIT 四帧 `[31748..31751]` / `v7_verified` 对账 49+1+1 / law INIT 顺序 SLICEM 2 组、SLICEL 6 组全等 / T19 锚点 0 不符 / T23 锚点 46=46）→ `VALIDATE: PASS`，rc=0；`python step03_pip/test_locked_init_map.py` → `RESULT: PASS`，rc=0。

**等价性结论**：接入实测表**不改变任何输出行**（T3 差异 0 条）—— 因为 law 本来就对。此次改动的价值是把「实测」变成权威来源、把顺序假设变成可机检断言（T2 互换即 FAIL），而不是修正数据。

**skill 行为验证补完**：`v7re/steps/SKILL_VERIFICATION.md` 新增 §4.1 失败路径（临时件改 `missing=3` / `predicted_n=49` → `check_manifest.py` 报 2 个 FAIL、`rc=1`，其余 14 项仍 ok），故 §4 三条欠缺只剩「独立性」与「误导场景」两条。

**覆盖边界（未测照写）**：SLICEL 顺序只在 `SLICE_X11Y20` 一个 block / 一个 clock region / 一个 BEL 测过，跨列跨 band 未直接测（仅靠 law 全库顺序对账间接支持）；`CLBLL_*` 的 SLICEL 未单独构建；SLICEM 沿 T19/T21/T22 三处；`word = 2*(Y%50)+parity`（≥50 再 +1）只实测 `Y%50 ∈ {20,21,26}`，其余外推；全库 `site_frames` 生成尚有 100 个缺 block（`Y≈298/299`，band 5）未覆盖。


## 57. T30 —— 精确匹配消 2 格歧义（2026-11-07）

旧判据「候选源的 sense=1 格全为 1」允许**子集命中**；同族内真子集关系实测 1,632 对、涉及 70/172 族，
full8 的 92 条误判全部由此产生。由于跨 family 零共享（1,598/1,598 独占），
family 位域内只含本族位，因此「位域读数 == 候选 pattern」既充分又必要。

新增 `v7re/scripts/decode_exact.py`。结果（精确率 100%、误判 0）：
`_full8` 190/198（96.0%）、`_c0` 25/27、`_c3` 36/39、`_c4` 36/39、`_d2` 36/39。

坐标序约定：对外/文档/JSON 一律 `(frame_off, parity, bit)`，代码内部高频数组用
`(frame_off, bit, parity)`，跨接口转序必须显式。文档 `v7re/steps/T30_EXACT_MATCH.md`。

## 58. T31 —— 精确判据接入主解码器（2026-11-07）

`v7re/export/decode_law.py` 的 INT PIP 判据改为族内精确匹配；新增 GCLK 直通还原；
旧判据降级为 `--legacy-allones`。三口径对照（`_full8.bit`，真值 198）：

| 口径 | 解码 | 命中 | 误判 | 漏 | 精确率 | 召回 |
|---|---|---|---|---|---|---|
| 旧 EXACT+WEAK | 268 | 190 | 78 | 8 | 70.9% | 96% |
| 旧仅 EXACT | 39 | 39 | 0 | 159 | 100% | 19.7% |
| **新精确匹配** | **190** | **190** | **0** | **8** | **100%** | **96%** |

与 `decode_exact.py` 逐条一致（两套实现交叉验证）。文档 `v7re/steps/T31_DECODE_LAW_EXACT.md`。

## 59. T32 —— 位流 → FASM → 位流 端到端回归（2026-11-07）

`v7re/scripts/fasm2bit.py` 的 `--decode` 改为族内精确匹配，补 GCLK 直通双向，
解码改为预计算 `family → {src: pattern}` + 跳过空 tile（十多分钟 → 秒级），
新增 `--ignore-ecc-coverage`（产物不可加载，仅用于数据字保真度测量）。

**幂等回归**（解码 → 回写，逐字节比对）：

| 设计 | FASM 行数 | 改动帧 | 结果 |
|---|---|---|---|
| `_full8.bit` | 190 | **0** | sha256 相同 `FAE4412F…45A52A1` |
| `_c0.bit` | 25 | **0** | 与原件相同 |
| `_c3.bit` | 36 | **0** | 与原件相同 |
| `_c4.bit` | 36 | **0** | 与原件相同 |

**从零重建**（`--blank`）：数据字差异 **119 位 / 14 帧**（共 50,176 帧），
全部可归因为两类已知缺口（8 个旁路直通族未建模、`--decode` 未输出 CLB 特征），
无不明来源的位。接入 CLB 后降为 **118 位 / 13 帧**。文档 `v7re/steps/T32_FASM_ROUNDTRIP.md`。

## 60. T33 —— PIP 定律覆盖 165/172（2026-11-07）

BEG 扩到 **96 族**（`v7re/steps/beg_families.json` 重写）+ 时钟树 5 族。
形状：`K(4,5)` 45 族、`K(5,4)` 51 族（早期 32 族的 14/18 统计作废）。
帧跨度三组各 32 族：(2,7)、(6,15)、(7,15)。

**坐标序坑**：`beg_families.json` 必须写 `(frame_off, parity, bit)`；
写成 `(frame_off, bit, parity)` 会报 **1,893 条假「不符」**。

`verify_all_pip.py --tile-type INT_L`：家族 165/172、feature 3,528/3,634 = **97.1%**、**0 不符**；
剩余 106 条为 `CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`（各 16 源，2/4 格混合）+ `LV_L0`。

复用统计（INT_L，sense=1）：每 cell 被 1→4、2→5、3→26、4→909、5→384、6→134、12→12、18→128 个源共用，
平均 5.56，最大 18；每族源数 24（mux 64 族）、20（BEG 96 族）、10–18（时钟树 5 族）。
文档 `v7re/steps/T33_PIP_LAW_COVERAGE.md`。

## 61. T34 —— 复合码族破解，覆盖率 172/172（2026-11-07）

**结构**：`CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1` 各 16 源 = 8 个 2 格源 + 8 个 4 格源；
2 格源两两求并得 **4 个 3 格 core**，每组满足「2 个源 = core 去一格、2 个源 = core 加一个附加位」。
6 族 × 4 组 = 24 组全部成立。附加位是**每族固定 2 个**、与第一级正交的第二级选择编码。

**覆盖**（`verify_all_pip.py --tile-type INT_L`）：

```
模型覆盖 feature：3634（100.0%）  精确命中：3634（100.0%）
覆盖家族：172 / 172   未覆盖 0
```

**边界**：前 160 族（mux + BEG + 时钟树）生成式；后 7 族「结构已知、槽位查表」。
文档 `v7re/steps/T34_COMPOSITE_FAMILIES.md`。

## 62. T35 —— 复合族组模型（2026-11-07）

组模型：每族 4 组，每组 = 3 格 core C + 族内共享的 2 个附加位 e1/e2；
组内 4 源 = `C\{c1}`、`C\{c2}`、`C∪{e1}`、`C∪{e2}`。
用组模型重建 **96/96 feature，不符 0**；产物 `v7re/steps/composite_groups.json`。

**「源→组」不可推导**：三族分组边界互不相同（`GFAN0` 为 B0–B3/B4–B7/B8–B11 整齐四分，
`CLK_L0` 把 B11 与三条 end 线同组、`FAN_BOUNCE5` 塞进第一组）——
缺位由相邻端线/bounce 线补位，属**物理邻接**，与 BEG 源→边映射同一性质。


**口径硬规则（2026-11-07 实测补记）**：`law_cells` 同时存 `sense=1`（必须置位）与
`sense=0`（必须为 0）两类行 —— INT_L 侧 8,900 条 `sense=1` + 3,264 条 `sense=0`，
`sense=0` 覆盖 1,632 个 `(family,src)`（70/172 族）。**任何集合比对必须先过滤 `sense=1`**：
把两类行混在一起会得到「模型集 ≠ 观测集、需再并 3–4 个恒定格」的假象
（本会话实测踩过：`CLK_L0/GCLK_L_B1` 的 5 行里只有 2 行是 `sense=1`，混算即误判）。
按 `sense=1` 口径复算：6 个复合族 24 组 **96/96 精确命中、不符 0、无需任何恒定格**。

**`LV_L0` 归档（T33 遗留项）**：它不是缺失，而是「结构已知、槽位查表」——`v7re/steps/beg_families.json`
里 `LV_L0` 为 `kind=composite`、`complete=true`、10 个源各 2 格（共 7 个不同 cell，无恒定位）；
`composite_groups.json` 里 `LV_L0` 是空列表，即**组模型不适用**（无 core/附加位分解），
故不计入「96 条」口径。`verify_all_pip.py` 的 3,634/3,634、未覆盖 0 已包含它。
## 63. 环境陷阱：禁止用 PowerShell 读写含中文的 UTF-8 文件（2026-11-07）

**事故**：用 `(Get-Content STATUS.md -Raw) -replace ... | Set-Content -Encoding UTF8` 修一个错别字，
PS 5.1 的 `Get-Content` 默认按 ANSI(GBK) 解码 UTF-8 字节 → 全文件 mojibake，且部分字符被替换成 `?`（不可逆）。

**规则**：任何含中文、需要回写的文件，一律走 Python（`io.open(..., encoding="utf-8")`），
或 `git checkout -- <file>` 恢复后再用 Python 追加。**不要**用 `Get-Content`/`Set-Content`/`-replace` 管道。


## 64. T36 —— 攻坚方案评审：Codex 方案 × 本地离线反证（2026-11-07）

用 `v7re/prompts/PIP_REUSE_MAINLINE_V2.md` 让 Codex 独立出方案（4.3K 字），
同时本地用 routing 模板 + `law_cells` 做离线反证。文档 `v7re/steps/T36_PLAN_REVIEW.md`。

**离线反证（0 个构建）**：

1. **H1「槽位 = 器件线序」证伪**：`templates/INT_L.json` 的 3,737 条 PIP 中，
   每个目的 wire 的源列表是**严格字典序**（`IMUX_L40` 依次为 BYP_BOUNCE_N3_2 … WW2END_N0_3），
   不携带引脚序号；按模板索引与实测槽位比对，64 个 mux 族「完全对齐」**0 族**。
2. **H2「8 方向 × 最近端线」强反证**：同一方向类别横跨 4–8 个槽位；
   更硬的是**同一条导线换槽**：122 个互斥源名中，**始终同槽 0 个、跨族变槽 122 个**
   （如 `EE2END0` 在 12 个 mux 族里跨 (0,0)/(0,1)/(1,0)…）→ 槽位是 `f(family, source)` 而非 `f(source)`。
3. **正面结果**：每个 family 的**源集合可离线从 routing 模板取到** —— 去掉 `VCC_WIRE`/`GND_WIRE` 后，
   172 族中 **166 族**与 `law_cells` 完全一致，剩下 6 族只差时钟树常量线（`LH12`/`LVB_L12`/`LH0`）。

**与 Codex 的分歧**：它按「每构建 0.5–1.5 小时」估 4–8 小时机时，实测我们是 **75 秒/构建**；
它把 INT 槽位当待测项，而 INT 的槽位表已实测并 1,536/1,536 反证过。
**执行顺序修正**：先做离线（源集合离线化 + 槽位表统计），Vivado 留给未测 tile 类型（BRAM/DSP/IOI）。



## 65. T37 —— 槽位表判定：per-mux 数据，不可闭式推导（2026-11-07）

**新增反证**：48 个 mux 族按源集合分成 **16 组 × 3 族**（如 `IMUX_L0/L8/L16` 共用 24 源），
组内三族的槽位表**全部不同**（0/32 相同）；行映射 10 种对应、列映射 4 种，既非整表平移也非行列独立置换。

**指纹统计**：48 个 mux 的不同槽位表指纹 **42 个**（36 个各 1 族、6 个各 2 族）；
16 组的指纹三元组有 14 种 —— 不存在「少数几张表轮换」的压缩空间。

**四条假设全部排除**：模板顺序（字典序，0/64）、方向+最近端线（同方向跨 4–8 槽位）、
`f(source)`（122 个源名始终同槽 0 个）、`f(源集合)`（组内全不同）。

**结论**：槽位表 = `f(mux 实例, source)`，属器件布线事实，应像布线图一样固化存储；
`law_cells` 已提供且被 1,536/1,536 反证，无需再测。

**「PIP 复用」问题至此完整回答**：复用发生在**族内格级**；结构分三类（6×4 网格 / 完全二分 / 组-核心-附加位）；
位坐标由几何公式生成（3,634/3,634），源集合由 routing 模板离线可得（166/172），
引脚归属为 per-mux 数据（42/48 互异）。文档：`v7re/steps/T37_SLOT_TABLE_FINAL.md`。

## 66. T38 —— PIP「多位」机理与可判定性（2026-11-08）

**形态**：mux 族 10 格 = 6 行格（帧 16–21，1-of-6）+ 4 列格（帧 25/24/23/22）；源 = 1 行格 + 列码。
全器件 **768 源用 2 格（列码重 1）、768 源用 4 格（列码重 3）**；列码只有 4 种：`{25}{24}{25,24,23}{25,24,22}`。
BEG 族 8–9 格、每源 2 格。

**为什么多位**：10 个格要区分 24 个源（信息论下界 log2(24)=4.58 位），必然多对一；
一个格被 4–18 个源共用（[4,4,4,4,4,4,6,6,18,18]）。**多位是压缩的必然结果，不是缺陷。**

**麻烦**：族内真子集 **1,632 对**、部分重叠 21,707 对 → 「包含」判据必误判（full8 实测 2 格 pattern 误命中 60/558=10.8%）。

**可判定性**：族内码字两两互异 + 族间位域互不相交（**仅 5 个时钟树族有 3 处共用格，且是级联**：
`LH0` 的源含 `LV_L0`，`LV_L0` 的源含 `LH12/LH6`）⇒ **按族取域 + 等值比较**可唯一反解；
实测 `_full8.bit` 190/190 全对、0 误判（包含判据 268 条 / 误判 78）。

文档：`v7re/steps/T38_MULTIBIT_PIP.md`。

## 67. T39 —— 全器件 PIP 结构普查（2026-11-08）

数据源 `out_routing/templates/*.json`（115 模板 / 70 个含 PIP / 35,126 条 PIP）。产物
`v7re/steps/tile_pip_survey.json` + `v7re/steps/T39_TILE_PIP_SURVEY.md`。

按「每目的源数」分四类：

| 类 | 含义 | PIP | 占比 | tile_type |
|---|---|---|---|---|
| A | 每目恰好 1 源 | 7,517 | 21.4% | 23 |
| B | ≥85% 目单源 | 8,135 | 23.2% | 25 |
| C | 稀疏多源（<4） | 3,748 | 10.7% | 12 |
| D | 密集多源（≥4） | 15,726 | 44.8% | 10 |

- **A 类**：PCIE_BOT/TOP、GTX_CHANNEL_0..3、CFG_CENTER_*、MONITOR_*、INT_INTERFACE_*、BRAM_INT_INTERFACE_*、
  BRKH_INT、LIOB18/RIOB18 —— 每目的唯一源，是「一条 PIP = 一位」的最佳验证样本。
- **B 类**：CLB 内部旁路（`CLBLM_L/R` 151、`CLBLL_L/R` 146，单源 90–91%）+ CMT/PLL/MMCM（单源 96–98%）。
- **C 类**：BRAM_L/R（974，78% 单源）、CLK_BUFG_*、HCLK_IOI、GTX/PCIE_INT_INTERFACE_*、BRKH_GTX。
- **D 类**（编码型）：`CLK_HROW_*`（2,840，12.68 源/目，最大 62）、`HCLK_CMT`（982，**23.38**，最大 48）、
  `HCLK_L/R`（200，10.0）、`HCLK_*_UTURN`（104，7.43）、`INT_L/R`（3,737，17.30）。INT 是唯一已解析的 D 类。

结论：INT 仅占 21.3%；44.8% 的 PIP 在密集多源 tile 上且 9/10 未解析；编码密度呈 A(1)→D(23) 分级，
说明「多位」程度与功能密度正相关。优先级：先验 A 类「一位一 PIP」，再攻 D 类中密度最高的 `HCLK_CMT`。

## 68. INT_L / INT_R 命名不对称 —— 归一化后两侧都是 100%（2026-11-07）

**现象**：`python v7re/scripts/verify_all_pip.py --tile-type INT_R` 只报
`覆盖 2312/3634（63.6%） 命中 1666（45.8%） 未覆盖 1274`，看起来「定律只对左半边成立」。
**原因不是定律，是线名**：同一根 mux 输入线在两侧叫法不同 —

| 侧 | mux 族 | 源线 |
|---|---|---|
| INT_L | `IMUX_L40`、`CLK_L0`、`CTRL_L0` | `LOGIC_OUTS_L0`、`GCLK_L_B0`、`GCLK_L_B10_WEST` |
| INT_R | `IMUX40`、`CLK0`、`CTRL0` | `LOGIC_OUTS0`、`GCLK_B0_EAST`、`GCLK_B10` |

`law_cells` 里两侧各 172 族、各 12,164 行，族集经归一化后**完全相等**（172/172，无差集）；
源集同理（例 `BYP_ALT0` 两侧 24 源，归一化后集合相等）。

**修法**（已改 `v7re/scripts/verify_all_pip.py`）：新增 `name_variants()` / `norm_name()` / `norm_key()`，
查表前把名字展开成候选写法（去 `_L`、数字前插 `_L`、`_EAST`↔`_WEST`、`GCLK_B<n>` ↔ `GCLK_L_B<n>`），
取第一个能查到的写法。`--normalize` 现在同时对族名和源线名生效。

**【数据事实】归一化后重跑**：

```
INT_R --normalize: 覆盖 3634（100.0%） 精确命中 3634（100.0%）
                    mux 1536/1536 不符 0 · beg 2098/2098 不符 0 · 未覆盖 0 · 家族 172/172
INT_L（无 flag）:   覆盖 3634（100.0%） 精确命中 3634（100.0%）   # 未受影响
```

**结论**：所谓「3,634 feature 的定律」是**器件级**的，左右两侧同一套；此前 63.6% 只是没做名字归一化。
**B 轨（用定律替换 `site_frames`）因此可覆盖 INT_L 和 INT_R 两侧的 53,100 个 INT tile**，
不必按侧分别建表——但**写入端仍要按侧还原线名**（落库的 `feature` 字段应保留器件原名）。

## 69. row / band / 行带 / PIP 与 mux 的数量对账（2026-11-07）

文档 `step03_pip/ROW_BAND_SWITCHBOX_EXPLAINED.md`；提示词 `step03_pip/PROMPT_ROW_BAND_SWITCHBOX_V1.md` → `_V2.md`。

**【数据事实】一个 INT tile（INT_L，26,550 个实例，`tile_types.uniform = 1`）的构成拆分**：

| 项 | 数量 | 来源 |
|---|---|---|
| wire | 600 | `v7_routing.db.tile_types.wires` |
| PIP | 3,737 | `tile_types.pips` |
| 目的 wire | 216 | `out_routing/templates/INT_L.json` 的 `pip_defs` 按目的归组 |
| 扇入 > 1 的目的 wire（= mux 家族） | 172 | 与 `law_cells` 的 172 个 `family` 一一对应 |
| 172 个 mux 含的 PIP | 3,693 | 模板 |
| 扇入 = 1 的直通 PIP | 44 | `BYP_BOUNCE*/BYP_L*/FAN_BOUNCE*/FAN_L*` 各 1 个 |
| `law_cells` 记录 feature（sense=1） | 3,634 | `law_cells`（两侧各 3,634） |

**全账**：`3,634（law 可解释）+ 59（VCC_WIRE 常量输入，59 个族模板扇入 25 / law 24）+ 44（直通）= 3,737`。
复算：`python step03_pip/_q_pip_reconcile.py`、`python step03_pip/_q_pip_gap59.py`。

**概念定论**（供讲解引用）：PIP = 单个受配置位控制的开关；mux = 共用同一目的 wire 的一组 PIP（组内互斥）；
switch box = tile 内全部 mux + 直通的整张网（INT tile = 3,737 个 PIP）；`band` = 帧地址上连续 5,246 帧的窗口，
与 `bank`（I/O / 配置 / 时钟编组）不是同一概念；`region = Y//50` 才是物理 50 行分区，
两者用 `band_by_region = [6,5,0,1,2,3,4]` 关联（region 0 → band 6，即 band 0 装 `Y=100..149`）。


## 70. 歧义/复用可解性评估：三层判定 + 最大阻碍（2026-11-07）

文档 `step03_pip/AMBIGUITY_SOLVABILITY.md`；提示词 `step03_pip/PROMPT_AMBIGUITY_SOLVABILITY_V1.md` → `_V2.md`。

**三层判定**：

| 层 | 判定 | 证据 |
|---|---|---|
| (a) mux 是否启用 | 条件可解 | `min-cells 2` 精确 67.4% / 召回 96.0%；`min-cells 4` 精确 100% / 召回 19.7%（`T6B_DISAMBIGUATION.md`） |
| (b) 选了哪个源 | 单 feature 独立判定**不可解**；联立后**未证明** | 同族严格子集对 **1,632**；2,818 个 2 格 feature 中 **816** 个被同族另一 feature 严格包含，跨族包含 **0**（`step03_pip/_q_subset_pairs.py`） |
| (c) 整条路径唯一 | **未证明** | 无构造性反例，也无唯一性证明 |

**关键区分**：位集嵌套说明「只看本 mux 的格子不够」，**不等于**信息论下界——观测里仍有额外信息（不属于小 feature 的那些格是 0 还是 1），
把 172 个 mux 的互斥约束联立后是否唯一，尚未求解。
**已确证的物理事实**：1,598 个 cell 被 3,634 个 feature 共用（均值 5.57），所以「读一位即知谁选中」不成立，必须全局一致性求解。

**最大阻碍 = ECC 与帧地址耦合未闭合**（`STATUS.md` §32/§34：`ECC = L(data) ⊕ A(frame_addr)`，`A` 未定）。
它挡住三件事：生成任意可加载位流、TM2 的上板端到端验证、全芯片重综合残差收敛（现差 53 字）。
数据层缺 16,979,200 行 `site_frames` 排第二：只影响 CLB 侧广度，不阻断 INT 侧闭环。

**三条互斥路径**：P1 联立求解打歧义（2–3 人日，纯本地，**唯一能产出「歧义下界」实证**：必须给出逐位相同的两条合法配置对，只给多解组计数不算下界）；
P2 闭合 ECC 地址项（5–7 人日，需远端 Vivado + 板卡）；P3 补数据层（4–6 人日，先 `VACUUM INTO` 备份）。

## 71. 主线收口：PIP 复用发生在哪几层 + 复用规律（2026-11-08）

文档 `step03_pip/PIP_REUSE_WHERE_AND_LAW.md`；提示词 `step03_pip/PROMPT_REUSE_MAINLINE_V1.md` → `_V2.md`（MCP 生成）；复算 `step03_pip/_q_reuse_mainline.py`。

**复用分四层，只有一层是真共享**：

| 层 | 数量（INT_L 单侧） | 共享情况 |
|---|---|---|
| 位池 cell `(frame_off,parity,bit)` | **1,598** | 真共享：1,595 个 cell 只服务 1 族，2 个服务 2 族，1 个服务 3 族；每 cell 被 **5.57** 个 feature 共用（分布 `{2:2,3:28,4:910,5:384,6:134,12:12,18:128}`） |
| feature | **3,634** | 不共享：2 格 2,818 个（77.5%）+ 4 格 816 个（22.5%），均值 2.45 |
| family | **172** | 几乎不共享：跨族 cell **3/1,598 = 0.19%** |
| tile / 器件 | 26,550 INT_L、150,380 tile | 共用地址模板与线名规则，不共用位 |

**新发现（本节首次定量）**：跨族共享的 3 个格全部落在长线族之间 —— `(1,0,6)` 属 `LH0`/`LV_L0`/`LV_L18`，`(0,0,2)` 属 `LH0`/`LV_L0`，`(0,0,9)` 属 `LV_L0`/`LV_L18`；其余 169 族严格独占。即「复用被族边界封住」，唯一缺口是 6 个长线族。

**172 族构成（已闭合，帧窗与形状一一对应）**：64 mux（`(10,24)`，帧 16–25，6×4 网格 = 48 IMUX + 8 BYP_ALT + 8 FAN_ALT）+ 64 BEG2/1（`(9,20)`，帧 6–15，5×4 网格）+ 32 BEG6/4（`(9,20)`，帧 2–7，K(4,5) 二分图）+ 6 时钟/控制（`(8,16)`，帧 0–1，组模型）+ 6 长线族（`(9,18)×2`、`(9,12)×2`、`(7,12)×1`、`(7,10)×1`）。

**七条规律**（细节见文档）：①族内唯一 172/172；②形状 7 类（96/64/6/2/2/1/1）；③网格生成律 `frame_row=16+row`、`frame_col={25-i}`、16 位对×2 parity×2 phase=64 一一对应；④BEG6/4 = K(4,5)（9 节点/20 边/度 4 与 5）；⑤时钟控制 6 族组模型（过滤 sense=1 后 96/96 精确、恒定格 0）；⑥跨族共享 3 格；⑦160 网格 + 12 非网格 = 172，两侧同构（INT_R 需线名归一化，否则仅 2,312/3,634 = 63.6%，归一化后 3,634/3,634 = 100%）。

**一处自查更正**：V1 提示词草稿写的「174 条定律」不存在，实测 **160 + 12 = 172**；已在本节与文档改正。

## 72. 进度汇报材料（2026-11-08）

文档 `step03_pip/PROGRESS_REPORT_20261108.md`；提示词 `step03_pip/PROMPT_PROGRESS_REPORT_V1.md` → `_V2.md`（MCP 生成）。
内容：一页纸结论（148 字）/ 里程碑表（10 条，各带复算入口）/ 核心数字表（13 项，全带分母）/ 已完成 vs 未完成（未完成写清挡住什么）/ 「只能展示一张表」= 172 族构成表 / 三条风险与应答 / 三档下一步 / 已作废与不可靠清单 / 口头版（540 汉字，约 2 分半）/ 三个追问与应答 / 「首次/唯一」不使用声明。

口径要点：①覆盖率两侧 3,634/3,634，INT_R 必须先归一化（否则 2,312/3,634 = 63.6%）；②位库形状沿用 prjxray artix7，原创是地址律 + 160/172 生成式压缩 + 闭环 + 歧义量化；③已作废数据必须主动交代（sense 混算那一组）。


## 73. 复用结构：复用度 = 码字列重，7 种谱型（2026-11-08）

文档 `step03_pip/PIP_REUSE_STRUCTURE.md`；复算 `step03_pip/_q_reuse_structure.py`。

**度量定义**：码字矩阵 `A[feature, cell]`，列重 `w(c) = Σ_f A[f,c]` = 该格被几个源共用；`Σ w = 8,900`（= 总置位置，可作自检）。

**列重直方图**（按「族-格」对计，合计 1,602；去重后物理格 1,598，差 4 = 3 个跨族格多计）：
`w=18: 128`（8.0%，只在 64 个 mux 族）、`w=12: 12`、`w=6: 134`、`w=5: 384`（24.0%）、`w=4: 909`（56.9%）、`w=3: 26`、`w=2: 5`、`w=1: 4`。
即**4–5 源档占 1,293/1,602 = 80.7%**，18 源档 8.0%，中间几乎为空 —— 「平均 5.57」是一阶矩，不能用来描述复用。

**7 种谱型（列重降序元组）与编码体制一一对应，172/172 命中**：

| 源数 | 谱型 | 族数 | 来源 |
|---|---|---|---|
| 20 | `(5,5,5,5,4,4,4,4,4)` | 96/96 | K(4,5) 节点度（A 侧 5、B 侧 4） |
| 24 | `(18,18,6,6,4,4,4,4,4,4)` | 64/64 | 列码 24×3/4=18、24×1/4=6；行帧 24/6=4 |
| 16 | `(12,12,4,4,4,4,4,4)` | 6/6 | 16×3/4=12、16/4=4 |
| 18 | `(6,6,6,3,3,3,3,3,3)` | 2 | 长线 `LVB_L0`/`LVB_L12`，未生成化 |
| 12 | `(4,4,3,3,3,3,2,1,1)` | 2 | 长线 `LH0`/`LV_L18`，未生成化 |
| 12 | `(4,4,4,3,3,3,3)` | 1 | 长线 `LH12` |
| 10 | `(4,4,3,3,2,2,2)` | 1 | 长线 `LV_L0` |

**推论**：复用度不是统计规律，是**编码体制的直接读出**（知道族属于哪种体制就能算每个位的复用度）。跨族 3 格的列重在各自族里只有 1–2（长线族谱型末尾），是「边缘位」而非编码位 —— 即「编码位族内共享、族间严格独占」。

**与 §70 的关系**：1,632 对严格子集与列重谱型是同一件事的两种说法（每源 2 格 × 9 格池的稀疏性）。

**口头版**见文档 §6（约 1 分 40 秒，只讲复用）。

## 74. row 的三种含义 + 复用还差多少（2026-11-08）

文档 `step03_pip/PIP_REUSE_STRUCTURE.md` §7/§8；复算 `step03_pip/_q_grid_check.py`。

**row 三义**：①**网格行** r∈0..5，帧 = **16+r**（帧 16..21），只存在于 64 个 mux 族（其余 108 族该区为 0）；②**tile 的 Y** 0..349，决定 word（`word=2*(Y%50)+parity`）；③帧内 word 槽位 0..100。①与②正交，互不决定。

**6×4 网格实测（IMUX_L40，24 源）**：每行 4 个源共用 1 个行格；4 个列码为 `{25}`、`{24}`、`{25,24,23}`、`{25,24,22}`，故**前 2 列 4 格、后 2 列 2 格**（与「前 2 列 2 格」的表述相反，已按数据更正）。行格用位：r∈{0,1,4,5}→bit6，r∈{2,3}→bit7（配对位 S）。每族 2 格源/4 格源各 12 个（64 族一致，`(12,12)×64`），全 mux 区 768/768。

**缺口账（三种口径）**：
| 口径 | 进度 | 剩余 |
|---|---|---|
| A 地址可公式化 | **160/172 = 93.0%** | 12 族 = 7.0%（6 时钟/控制 + 6 长线），覆盖 178/3,634 = 4.9% feature |
| A+B 源→槽位顺序可推 | **0/1,536 = 0%** | 槽位顺序由布线邻接决定，是数据不是规律，须用 `v7_routing.db` 重建 |
| A+B+C 跨 tile 类型 | 0/4 类 | CLB/DSP/BRAM 未做同口径列重统计 |
| A+B+D 跨器件 | 未测 | 只有 XC7VX485T-2 |

**推论**：说「复用已解 93%」只对「地址律」成立；说「复用已解决」则不成立——槽位顺序 0% 可推，跨类型/器件未测。


## 75. mux 族行号 r 与 `frame_row = 16 + r` 的来源（2026-11-08）

问题：为什么「选哪一行」的位落在帧 `16 + r`？不是先猜公式再拟合，顺序是从数据往公式走。

**推导链（五步，每步可复算）**

1. 取一个 mux 族的 24 个源的完整 cell 集合（`v7_law.sqlite.law_cells`，`sense=1`）。
2. 对每个格算列重 `w(c)` = 该格被几个源共用。只有三类值：`4`、`6`、`18`。
3. 按列重分类：列重 `4` 的格恰 **6 个**，每个被该行 4 个源共享 → **行选择位**；列重 `18/18/6/6` 的格恰 **4 个** → **列码位**。
4. 读这 6 个行格的帧号：`16,17,18,19,20,21`，与「哪 4 个源共享它」一一对应 → 行号 r 由此定义，得 `frame_row = 16 + r`。
5. 列码位第 i 位（LSB=0）→ 帧 `25 − i`（`0001→{25}`、`0010→{24}`、`0111→{25,24,23}`、`1011→{25,24,22}`）。

统一表述：mux 族占帧块最后 10 帧（16..25）；**行格从 16 往上数**（r=0..5），**列码位从 25 往回数**（第 i 位 → 25−i）。

**反驳测试（若公式是硬凑，跨 64 族必漂移）**——脚本 `step03_pip/_q_row_law.py`

| 检查项 | 实测 |
|---|---|
| mux 族数 | 64/64 帧集合 = `{16..25}` |
| 行格数/族 | 6/6，每个行格列重恰为 4 |
| 行格位置 | **384 个行格全部 `frame=16+r`，0 例外** |
| 位对/parity | 每族恰 1 对相邻位、1 个 parity（16×2×2 = 64 铺满） |
| 行格用位 | r∈{0,1,4,5} 用 primary 位、r∈{2,3} 用配对位（384/384） |

**「为什么是 16 而不是 12/15」能说到哪一步**

- 【数据事实】mux 族帧集合恰为 `{16..25}`，是 26 帧块里连到最后一帧的一段；10 = 6 行 + 4 列码，帧数刚好够。
- 【推断】起点 `16 = 25 − 9`，从最后一帧往回数；谁占最后一段由区域边界决定。
- 【未测】更底层的硅片原因（配置行内部物理对齐、bitgen 写入顺序）——无证据，不得讲成必然。

详细推导、30 秒讲法与完整表见 `step03_pip/PIP_REUSE_STRUCTURE.md` §9。

## 76. PIP 复用发生在哪一层（含统计口径纠错）（2026-11-07，原 §65，因 T37–T39 占号顺延）

解释文档 `step03_pip/PIP_REUSE_LAYER_EXPLAINED.md`（191 行，本行即丢失指针的重挂）；
提示词 `step03_pip/PROMPT_PIP_REUSE_LAYER_V1.md`。

**层次**：`tile`（类型 + col + Y）→ `family`（目的 wire，INT 侧 172 个）→ `feature`（`family, src_wire`，3,634 条）
→ `cell`（`(frame_off, parity, bit)`，1,598 个）。**复用发生在 feature 之间**：同一个 cell 被多个 feature 置 1；
`family` 是复用的边界单位，跨 family 共享只有 **3/1,598** 个 cell。

**【数据事实】按 `sense=1`（置位集）口径实测**（`law_cells`，INT_L）：

| 量 | 值 |
|---|---|
| feature 数 / 不同 cell 数 | 3,634 / 1,598 |
| 每 feature 的 cell 数 | 2 格 × 2,818、4 格 × 816，均值 **2.45** |
| 每 cell 被几个 feature 置 1 | 2→2、3→28、4→910、5→384、6→134、12→12、18→128，均值 **5.57** |
| `(cell 数, 源数)` 形状 | `(9,20)×96`、`(10,24)×64`、`(8,16)×6`、`(9,12)×2`、`(9,18)×2`、`(7,12)×1`、`(7,10)×1`（共 7 类） |
| 族内「每源 pattern 互不相同」 | **172/172** |
| 族内严格子集对 | **1,632**（与 `v7re/steps/T30_EXACT_MATCH.md` 一致） |

**口径纠错（本会话自纠）**：同一批数据若把 `sense=0` 行也并进观测集，会算出「每源恒 5 格、
cell share `[4,4,4,4,4,4,24,24,24,24]`、平均 3.35 格/feature、70/172 族 4:1 合并」
—— 那些不是位流的置位事实，而是「置位 + 清零」两类约束混算的结果。
**对外一律用 `sense=1` 口径；引用任何复用数字必须写明口径。**

**未查清项（照写不隐瞒）**：本表低位族（`(9,12)×2`、`(7,12)×1`、`(7,10)×1`）与
`step03_pip/REUSE_RULES.md:94-99` 的旧表（`(7,12)×4`、`(9,18)×2`）不完全一致，族总数同为 172，
差异来源未查（疑为 `law_cells` 在校验轮中重建所致）；引用形状类时以本表 + 复算命令为准。

## 77. `(frame_off, parity, bit)` 是什么 + 地址换算链（2026-11-07，原 §66，因 T37–T39 占号顺延）

完整解释见 `step03_pip/CRAM_TERMS_AND_ADDRESSING.md`（217 行：术语表 / 物理四层 / 101 word 解剖 /
地址链路 / 真实演算 / 术语对照）；**可视化**见 `step03_pip/CRAM_LAYOUT_DIAGRAM.html`
（两段内联 SVG：帧-word-tile 共享关系 + `IMUX_L40` 位域；生成脚本 `step03_pip/_build_diagram.py`）；
提示词 `step03_pip/PROMPT_CRAM_ADDRESS_V1.md`。

- `frame_off`：**tile 内部的帧偏移**（INT tile 0..25；位池 = 26 × 2 × 32 = 1,664 位），`frame = base + frame_off`。
- `parity`：**帧内字对的一半**，`word = 2*(Y%50) + parity`（≥50 则 +1，跳过 word 50 的 ECC 字）。
- `bit`：**word 内第几位**（0..31）。三者合起来 = 一个 tile 内某一位的「tile 内相对坐标」。
- 已验证演算：`INT_L_X8Y20`（col=8、Y=20 ⇒ band 6、base 31,752）→ frame 31,768、word 40/41；
  `INT_R_X37Y199`（col=37、Y=199 ⇒ band 1、base 6,510、`Y%50=49`）→ word 99/100、frame 6,521/6,523。
- 容器：`ref.bit` = 102 字节头 + SYNC `AA995566` + 包流 + FDRI 5,067,776 word = 50,176 帧 × 101 word；
  解析后 `bits.shape = (50176, 101, 32)`；`.bit` 不能线性寻址，必须先解析 Type1/2 包取 FDRI 载荷。

## 78. band / row / tile 的区分与换算（2026-11-07，原 §67，因 T37–T39 占号顺延）

完整解释与自检清单见 `step03_pip/BAND_ROW_TILE_EXPLAINED.md`；提示词
`step03_pip/PROMPT_BAND_ROW_TILE_V2.md`（V1 同名，V2 末尾附改动清单）。

- **tile**：配置阵列里的块实例，唯一标识是 `tile_name`（类型 + col + Y）。**【数据事实】**同一 `(col,Y)`
  上可并存多个 tile（`col=20` 的 700 个 tile 全是 `INT_L_X20Yn` 与 `INT_INTERFACE_L_X20Yn` 成对）。
- **band**：**帧地址上连续的 5,246 帧**。**【数据事实】**band 0 = 帧 0..5245、band 1 = 5246..10491、…、
  band 6 = 31476..36721，7×5246 = 36,722；器件 50,176 帧，差额 13,454 帧属非 INT 列。
- **region vs band**：`region = Y//50`（物理纵向，0..6），`band = band_by_region[region]`，
  置换表 `[6,5,0,1,2,3,4]`（`v7re/scripts/bitwriter.py:56`）。band 号跟**帧地址顺序**，不跟 Y 顺序，
  故 band 0 对应 Y=100..149。
- **row 三义**：①tile 的 `Y`（0..349）②band 内行号 `Y%50`（0..49，一行 2 个 word）③帧内 config row（101 word）。
- **共享边界**：同一帧只装同一 band 内的 50 个 tile 行（各占不同 word）；**跨 band 必然换帧**（base 差 5,246）。

## 79. 「行和列」里哪层是数据、哪层是我的命名（2026-11-08）

被人当面质疑过「列和行是你自己构建的」，这里把它拆成三层，避免把命名当发现、也避免把真结构说成臆造。

**第一层：无模型硬事实**（只用列重 + 共享关系，不引入几何）。对每个族只做：算每个格被几个源共用 → 取最轻一档 → 看它怎么分源。观察：mux 族列重 ∈ {`4`,`6`,`18`}，最轻档恰 **6 个**格、每源恰含 **1** 个；BEG 族列重 ∈ {`4`,`5`}，最轻档恰 **5** 个。最轻档把源分成 **6×4**（24 源族）或 **5×4**（20 源族），且**每组复现同一套码字**（组内 4 个源 4 种模式，各组模式集合完全相同）→ 24 = 6×4 的**完全叉积**。

**第二层：可证伪断言 + 实测**。断言＝源的配置 = 组选择 × 码字，二者独立。检验不按族名、不按帧号，只用列重二分（`step03_pip/_q_grid_is_real.py`）：**163/172 族通过**；维度 `(6 组, 4 源/组, 4 码位)×64`、`(5,4,4)×96`、`(6,3,3)×2`、`(4,3,3)×1`。**9 个例外全部落在已知难族**（`_q_grid_exceptions.py`）：6 个时钟/控制族 `CLK_L0/L1、CTRL_L0/L1、GFAN0/1`（16 源，每源含 **1 或 2** 个组格 → T34 的 core+drops+extras 复合模型）+ 3 个长线族 `LH0`(12)、`LV_L0`(10)、`LV_L18`(12)（每源含 **0 或 2/1** 个组格 → 编码位与边缘位混在一起，三族还共享 3 个边缘格）。若网格是我硬套的，失败会随机散布；实际精确落在早已独立确认特殊的 9 族上。

**第三层：真正属于命名的部分**。①「行/列」二词与那张 6×4 示意图是我加的——换成「组轴/码轴」「横/纵」结论不变，唯一约束是 `6` 必配组轴、`4` 必配码轴（组数与模式数由数据给）。②`r=0..5` 的顺序取自帧号 16..21，换编号只改变写法。③**没有证据说硅片上这 6 组物理排成 6 行**，讲的时候说「组选择轴/码字轴」，别把示意网格说成硬件版图。

一句话：**乘积结构是数据里的（163/172 完全叉积，例外正好是已知复合族与长线族）；「行/列」这两个词和网格图是我加的。**

详见 `step03_pip/PIP_REUSE_STRUCTURE.md` §10；复算 `step03_pip/_q_grid_is_real.py`、`step03_pip/_q_grid_exceptions.py`。



## 80. PIP / mux 的物理形态 + 「家族长度」的两种口径（2026-11-08）

【硬件事实】PIP = 两段 wire 之间由配置 SRAM 位控制的可编程连接点（传输门/缓冲开关），不是软件路由表项。mux = **共用一个目的 wire 的一组 PIP**，组内互斥是电路事实（一个目的 wire 同时只能被一条源驱动），不是工具约定。家族（本项目术语）= 一个目的 wire + 其全部候选源 ≡ 一个 mux。switch box = tile 内全部 mux + 直通。

【数据事实】INT_L tile（`uniform=1`）：600 wire / **3,737 PIP** / 216 目的 wire；其中 172 个目的 wire 扇入>1（= 172 个家族）含 **3,693** PIP，44 个扇入=1 直通 PIP；`3,693+44 = 3,737` ✔；`law_cells` 3,634 = 3,693 − 59 个 `VCC_WIRE` 常量输入（§69）。

**「家族的长度」有两种，必须分开说**：

1. **扇入长度**（多少候选源，`law_cells` sense=1 按 `(family,src)` 去重 3,634 条）：`24 → 64 族`（`IMUX_L0..L47` 48 + `BYP_ALT0..7` 8 + `FAN_BOUNCE*` 8，即 6×4 网格那批）、`20 → 96 族`（方向线族 `EE2/WW2/EE4/WW4/NE6/NW6/SE6/SW6/NN2/SS2/NL1/SL1/EL1/ER1…` 各 4 变体）、`18 → 2`（`LVB_L0/L12`）、`16 → 6`（`CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`）、`12 → 3`（`LH0`、`LV_L18`、另一 `LH`）、`10 → 1`（`LV_L0`）；合计 172 族 / 3,634 feature ✔。

2. **线长等级**（命名自带，数字 = 跨几个 tile）：`…1…`=1（单线）、`…2…`=2（双线）、`…4…`=4（四线）、`…6…`=6（六线）、`LV/LVB`=长竖线、`LH`=长横线。【数据事实】`tileconn.json` 实测：`LV_L0` 自连偏移到 (0,11)、对外到 `INT_L` **17 行**；`LVB_L0` 到 11 行；`LH0` 到 **14–23 列**；`SE6BEG0`→`INT_R` (1,1)(1,2)(1,3)；`EE2BEG0`→(1,0)；`EE4BEG0`→(2,0)；而 `IMUX_L40`/`BYP_ALT0`/`FAN_BOUNCE7` **无自连**（目的 wire 不出本 tile）。

**结论**：172 族里只有 **4 族**（`LV_L0`、`LV_L18`、`LVB_L0`、`LVB_L12`）的目的 wire 是长线；其余 168 族的 mux 都只在本 tile 工作，「长度」体现在**它接收的源线是 1/2/4/6 档还是长线**。`band = 50 行 = 一个 clock region`（`band_rows=50`、5,246 帧/band）正是长线的活动尺度。

【未测/禁讲】INT tile 内 mux 是传输门树还是多级缓冲树、几级、24 个源的物理相邻关系；`6×4` 只是组合逻辑上的乘积，不保证硅片排成 6 行 4 列（§79.3）。

详见 `step03_pip/PIP_MUX_PHYSICAL_AND_SPAN.md`；复算 `_q_fanin3.py`、`_q_family_span.py`、`_q_span_examples.py`、`_q_pip_reconcile.py`。

## 81. 并行机时与首批跨 tile 实测（2026-11-08，原 §68，因 §68/§69 已被命名不对称与数量对账占用而顺延）

**远端资源**：56 核 / 62 GB 内存。单次 vivado 构建峰值 RSS ≈ 2.1–2.2 GB、CPU ≈ 134%（1.35 核）、墙钟 84 s；
4 并发时 2.7 GB/进程、1.8 核/进程、墙钟 105 s（比单次只慢 25%）。
约束在内存：62 GB ÷ 3 GB ≈ 20 路；建议 **16–18 路**并发，吞吐约 680–760 构建/小时。

**并行编排实测**：8 个设计 `xargs -P 8` → 墙钟 **94 s**（单次 84 s），即 8 倍任务只多花 12% 时间。

**首批跨 tile 差分（`/opt/lzh/v7re/work/survey1`、`survey2`）**：

| 对比 | 意图 | 结果 |
|---|---|---|
| d0 vs d1 | 输入脚 IOSTANDARD 18↔25 | 214 格（含 word50 79），**不含 word50 135 格 / 81 帧** |
| d0 vs d3 | 加一级 FF + 引脚时钟 | 285 格，不含 word50 **162 格 / 124 帧** |
| d4 vs d5 / b0 vs b1 | RAMB18 `INIT_00` 0 ↔ 256'hDEAD… | **仅 10 格 / 2 帧**（帧 46716/46717，word 10–14） |

**判读**：朴素「一对设计对比」**无法隔离单条 PIP**——
IOSTANDARD 与时钟那两组各自牵连布线（81/124 帧），
BRAM 那组反而几乎不变（说明该设计过于退化，INIT 大部分未被真正写入）。
结论：跨 tile 的「一条 PIP 占几位」不能靠这种批量对比得出，
每类 tile 必须像 INT 那样做**受控单特征改动 + 自校验**。

脚本：`_survey1.sh`/`_survey1b.sh`/`_survey2.sh`（远端 `/opt/lzh/v7re/work/survey1`、`survey2`），
本地位流解包在 `_survey1/`、`_survey2/`。已知坑：RAMB18E1 无 `RSTRAMBR` 端口、DSP48E1 的 `ALUMODE`/`AMULTSEL` 是端口不是参数。


## 82. 远端机器资源复核（2026-11-08，更正 §68 的内存口径）

用三层口径复核（WSL 内 `lscpu/nproc`、`/proc/cpuinfo` 拓扑、Windows 侧 `Win32_Processor`/`Win32_ComputerSystem`）：

| 项 | 实测 |
|---|---|
| 机型 | Dell Precision 7920 Tower |
| CPU | **2 × Intel Xeon Gold 5120 @2.20GHz** |
| 物理核 | **28**（14 核/颗 × 2） |
| 逻辑线程 | **56**（HT 开，`siblings=56 / cpu cores=28`） |
| Windows 物理内存 | **127.7 GB** |
| WSL 可见内存 | **62 GB**（无 `.wslconfig`，WSL2 默认取 50%） |
| WSL 可见 CPU | 56（未受限） |

即：**不是 100+ 核**，是 28 核 56 线程；但**内存被 WSL 默认砍掉一半**（62 / 127.7 GB）。

推论：§68 的并发上限（62 GB ÷ 3 GB ≈ 20 路）是 WSL 默认配置造成的，不是机器上限。
写 `C:\Users\<user>\.wslconfig` 把 `memory` 提到 ~104 GB 后，安全并发可到 **30–35 路**。



### 69.1 已应用（2026-11-08 11:20）

`C:\Users\S.tschai\.wslconfig`（注意 Windows 账户是 `S.tschai`，不是 `i`）：
```ini
[wsl2]
memory=100GB
processors=44
swap=16GB
```
`wsl --shutdown` 后实测：**nproc=44、MemTotal=102,994,360 kB（98 GiB）、swap=16 GB**。
留存量：CPU 12/56 线程（21.4%）、内存 27.7/127.7 GB（21.7%），符合「各留 20%」要求。

并发上限重算：98 GiB ÷ 3 GB ≈ **32 路**（此前 62 GB 时是 20 路）。


## 83. row 0..49 是什么意思、50 是怎么来的（2026-11-08）

**含义**：`row = Y % 50` 是**这个 tile 在本 band 内的第几个器件行**（0..49），不是整片 y 坐标。整片 y 坐标 `Y = 50 × region + row`，`region = Y // 50`（0..6）。band ↔ region 是实测排列 `band_by_region = [6,5,0,1,2,3,4]`（`bitwriter.py:56`），所以 `band0` 装的是 `Y=100..149`（region 2）。

**50 从哪来——三条独立证据指向同一个数**：

1. 【数据事实】`law_tiles` 62,625 行，Y 只有 **350 个值（0..349）**，`Y//50` 恰好切成 **7 桶、每桶正好 50 个 Y**（`_q_row50.py`）→ 50 是行轴上的真实分割，不是随便取的。
2. 【算术必然】一帧 **101 word**；每个 row 要 2 个 word（parity 0/1），另 1 个 word 是 ECC → 可用 `100 = 2 × 50` → **一帧正好装 50 个 row**。反过来：`101 = 25×2 + 1 + 25×2`。
3. 【硬件事实】7 系列一个 clock region 横跨 **50 个 CLB 行**，XC7VX485T 纵向共 **7 个 region**（7×50 = 350）。所以本仓库的 `band` 就是 clock region。

**word 布局实测**（`word = 2*(Y%50)+parity`，≥50 则 +1）：

| row | parity0 word | parity1 word |
|---|---|---|
| 0 | 0 | 1 |
| 23 | 46 | 47 |
| 24 | 48 | 49 |
| 25 | 51 | 52 |
| 49 | 99 | 100 |

`row 0..24` 占 word `0..49`，`row 25..49` 占 word `51..100`，**word 50（ECC）夹在中间**，50 个 row 用满 100 个数据 word（`_q_row50.py` 实测：用到 100 个 word，唯一缺 50）。这条与 `prjxray_ref/PRJXRAY_COMPARE.md` §5 反推的 `offset = 2*(Y%50) + [Y%50>=25]` 完全一致。

**独立交叉验证**：`far_bands` 每个 band 恰好 **5,246 帧**且首尾相接（band0 0..5245、band1 5246..10491、…、band6 31476..36721）；`row_frames=5246` 就是「一个 band 的帧数」。

【推断】ECC word 落在中间而不是末尾，可能是因为一帧在物理上被分成两半（各 25 row × 2 word），校验字夹在中间。【未测】这条没有直接证据，不得讲成必然。

**三个 row 别混**（§74）：tile 的 `Y`（0..349）／band 内行号 `Y%50`（0..49）／帧内 `word` 槽位（0..100）。

复算 `step03_pip/_q_row50.py`。

## 84. A 类 tile 验证：协议成立，首批实测（2026-11-08，原 §70，与 §70 歧义评估撞号顺延）
**受控协议**：前置断言「两个设计的 PIP 列表逐行相同」——比只查 `SITE/BEL` 强，
能把「配置变化」与「布线变化」彻底分开。

| 对比 | 变量 | 数据差格 | 帧 | PIP 列表 |
|---|---|---|---|---|
| `p1b` vs `p2a` | 无（同引脚 AN33） | **0** | 0 | 相同 |
| `c1` vs `c2` | 输入脚 AF25→AN33 | 85 | 49 | 不同 |
| `t18` vs `t15` | IOSTANDARD 18→15（引脚全固定） | **7 位** | 2 | **逐行相同** |

`t18` vs `t15` 的 7 位全在配置行 6（IO 行）：帧 27360 word96 bit16；帧 27361 word95 bits 23,31；帧 27361 word96 bits 1,3,15,17。
→ **IO 属性是多位编码（7 位），不是 1 位**；「一条 PIP 一位」若成立只可能针对布线 PIP。

**换引脚不能测 interface PIP**：换脚同时改 IOB 位、ILOGIC 位、LIOI 与 `IO_INT_INTERFACE` 的 PIP、以及到 LUT 的整条 INT 路径（85 格/49 帧）。

文档：`v7re/steps/T40_CLASS_A_PROTOCOL.md`。下一步：用同引脚、只改 ILOGIC 通路的方式隔离 interface PIP。
## 85. band 是什么（2026-11-08）

**定义**：band = 把器件纵向切成 **7 段、每段 50 行**；一列在某段里的配置占帧地址空间中一段连续帧号。band 是**帧地址的编址单位**，不是硅片上的物理矩形。定位式：`frame = far_bands[(band, col)].start_frame + frame_off`（INT tile 的 frame_off 0..25）。有了它，62,625 个 tile 的地址只需 **7×128 = 896 条**记录就能算出来。

**实测结构**（`far_bands`，896 行）：7 band × 128 列；每 band 帧窗口 **5,246 帧**首尾相接（band0 0..5245、band1 5246..10491、…、band6 31476..36721，7×5246 = 36,722）；器件总帧数 50,176，差 **13,454** 帧属非 INT 资源（I/O、时钟、配置中心）。

**band ↔ region 是置换**：`region = Y//50`、`band = [6,5,0,1,2,3,4][region]`（`bitwriter.py:56`），所以 `band0` 装 `Y=100..149`（region 2）、`band6` 装 `Y=0..49`（region 0）——band 跟帧地址顺序走，不跟 Y 顺序走。

**三条独立验证**：①`law_tiles` 的 Y 只有 350 个值，`Y//50` 切出 7 桶×50；②一帧 `101 = 25×2 + 1(ECC) + 25×2` ⇒ 装 50 行 ⇒ 一段 50 行；③7 系列 clock region 横跨 50 个 CLB 行、485T 纵向 7 个 region。

**列在 band 内错开**：相邻列 `start_frame` 差不是常数，实测差集 `{28,30,32,36,42}`（band0: col0=0、col1=32、col2=68、col3=104、col127=4324）。**只用 `start_frame`**；`end_frame` 语义未查清（INT_L 列 4,387 vs INT_R 列 27–41），不得引用。

**三个用处**：①定位（与 `word = 2*(Y%50)+parity` 配合算到帧/字/位）；②解释复用地址层根源——同一 (band,col) 的 50 个 tile 共用同一批 26 帧、只差 word；③长线（`LV/LH` 跨 12–23 tile）的活动尺度就是 band。

**边界**：band 不等于 I/O bank / 时钟 bank / 手册 bank；【未测】band 为何是 `[6,5,0,1,2,3,4]` 这个置换（可能涉及列块写入顺序与每 config row 末尾 2 个 overhead 帧），无证据不下结论。

详见 `step03_pip/BAND_WHAT_IT_IS.md`；复算 `step03_pip/_q_far_bands.py`、`_q_row50.py`。

## 86. col 与 bank：两套列坐标、bank 不在寻址链里（2026-11-08）

### 一、我们手里有两套列坐标（实测 `_q_two_cols.py`）

| 坐标 | 范围 | 来源 | 用途 |
|---|---|---|---|
| tile 列 | 0..157（158 个） | `law_tiles.col`（tilegrid 的 x） | 几何位置、tile 名、邻居关系 |
| 帧列 | 0..127（128 个） | `far_bands.col` | **寻址**：`frame = far_bands[(band,col)].start_frame + frame_off` |

- tile 列 **128..157 这 30 列在 `far_bands` 里没有记录**；其中 26 列含 INT tile（128..153，每列 350 个）。
- 【数据事实】INT tile 实例 **53,100**（`INT_L` 26,550 全偶列 0..152 + `INT_R` 26,550 全奇列 1..153，0 例外）。
- 能直接取到 `far_bands` 基址的 **44,100 = 83.1%**；其余 9,000 个的原因已在 §87 查清：**`far_bands` 只入了前 128 列（FAR 实际有 154 列）**，不是硬件限制。`column_offsets`（`device,region,x,offset,source`）与 `region_bases`（`device,region,base_frame,anchor_site,source`）是另一套别名/锚点机制（`source='X1_alias_of_X0Y0'` 一类），与本缺口无关。

### 二、列的奇偶是硬件规律

`INT_L` 全落偶数列、`INT_R` 全落奇数列（26,550 / 26,550，0 例外）。左右两侧线名还不对称（`IMUX_L40` vs `IMUX40`、`GCLK_L_B0` vs `GCLK_B0_EAST`），归一化后才对得上 172 族（§68）。

### 三、bank 不在本模型的寻址链里

| bank 类型 | 指什么 | 出现在哪 |
|---|---|---|
| I/O bank | IOB 按供电电压/电平标准分组（共用 VCCO） | `.xdc` 的 IOSTANDARD、bitgen DRC `NSTD-1`/`UCIO-1` |
| 配置/时钟 bank | BUFG/MMCM 所属时钟管理组 | 时钟约束 |
| 手册 bank 编号 | 数据手册给 bank 编的号 | 引脚规划 |

本仓库寻址链只有五层：**band → col → frame_off → word → bit**，没有 bank。若在别处看到「bank」参与列分类，更可能是 FAR 的 `[25:23]` **block type**（README 记作 `type`），那是列类型不是 bank。

### 四、一句话

> `band` 纵向切 7 段（每段 50 行、5,246 帧）；`col` 横向第几列（几何 col 0..157 / 帧 col 0..127 两套）；`bank` 是供电与引脚分组，不进寻址链。

【未测】128 与 158 的几何差额只解释到「右边缘列与邻列共用帧块、靠别名换算」，更底层的布局原因未查。



## 88. PIP 版手段 A 首次成功：BUFGCTRL 输入选择 = 2 位（2026-11-08）

设计：同引脚（AF25/AN33/AN34）、同 IOSTANDARD、`LOC BUFGCTRL_X0Y16`，只改 `S0/S1`（选 I0 还是 I1）。

| 项 | 结果 |
|---|---|
| PIP 列表 | **逐行相同（92/92）** |
| 数据差格 | **2 位**：`(帧 13080, word 0, bit 11)`、`(帧 13081, word 0, bit 3)` |

即 **BUFGCTRL 的 I0/I1 选择由 2 个位编码**。这是「手段 A：同一路径只换中间一跳」的首次成功，
也说明时钟 mux 这类由寄存器位决定的结构，天然适合该手法（INT 换源必然换线，不适用）。

**构建坑**：①`BUFGCTRL` 无 `SIM_DEVICE` 参数；②IO 直连 BUFG 触发 `[Place 30-574]`，
需 `CLOCK_DEDICATED_ROUTE FALSE` 于 a/b/c 三条网。

文档：`v7re/steps/T41_BUFGCTRL_2BIT.md`。

## 87. 比特流里的 bank 与 col：FAR 字段、154 列、以及一个被表截断造成的缺口（2026-11-08）

### 一、完整比特流里没有逐帧地址（实测 43 个位流）

`step03_pip/_q_bit_far.py` + `_q_far_scan.py`：解析 `.bit` 的 Type1/Type2 包，**FAR（reg 0x01）只写一次，值恒为 `0x00000000`**，紧随一个 Type2 FDRI 突发 **5,067,776 字 = 50,176 帧**。全部 43 个本地位流（`_c0..c5`、`_full8*`、`_b1`、`_d2`、`_g1`、`tamper/ref/ref.bit` …）一致，无一例外。

⇒ **`.bit` 文件本身不携带每帧的 bank/col/row**；地址是「从帧 0 起线性自增」隐式表达的。想看每帧的 FAR，只能由地址模型反解（我们的 `frame_map` 就是这条路的产物，来源 `rapidwright-configarray`）。

### 二、FAR 的字段（`v7re/bitstream/far.py` 已实现编解码）

| 位段 | 字段 | 位宽 |
|---|---|---|
| [31:26] | reserved | 6 |
| [25:23] | **block type** | 3 |
| [22] | top/bottom | 1 |
| [21:17] | row | 5 |
| [16:7] | **column** | 10 |
| [6:0] | minor | 7 |

### 三、实测结构（`frame_map` 50,148 帧有 FAR；`_q_far_segments.py`）

| 段 | 帧区间 | 列数 | 列号 | 每列帧数 |
|---|---|---|---|---|
| block=0 top=0 row=0..4 | 0 / 5,246 / 10,492 / 15,738 / 20,984 起，各 5,244 | 154 | 0..153 | 28/30/32/36/42 |
| block=0 top=1 row=0..1 | 26,230 / 31,476 起，各 5,244 | 154 | 0..153 | 28/30/32/36/42 |
| block=1 top=0/1 row=0..4/0..1 | 36,722 起，各 1,920 | **15** | 0..14 | **128（恒定）** |

- 逻辑块 7 段 × (5,244 + 2 overhead) = **36,722 帧**；另一类块 7 段 × (1,920 + 2) = **20,454 帧**；合计 **50,176** ✔
- **col 的步长不齐（28/30/32/36/42）来自列内资源密度不同**，不是随机 —— 这正是 `far_bands.start_frame` 步长集合的来源
- **minor 上限 127** 与「block 1 每列恰好 128 帧」完全吻合（7 位字段刚好够）
- 【数据事实】`bank` **不是 7 系列比特流的字段**。最接近的是 **block type**（两档：逻辑 36,708 帧 / 另一类 13,440 帧）。若上下文用「bank」指 block type，那么地址顺序是 **先 block（bank）→ 再 col → 再 minor**。

### 四、`band` / `col` 与 FAR 的对应（`_q_far_bands_verify.py`，0 不符）

- **`band` = (block type, top/bottom, row) 三元组**，顺序 `band0..6 = (0,0,0),(0,0,1),(0,0,2),(0,0,3),(0,0,4),(0,1,0),(0,1,1)`
- **`far_bands.col` 就是 FAR 的 column 字段**：896 行（7 band × 128 列）与 FAR 首帧**逐条比对 0 条不符**
- 但 FAR 实际有 **154 列**，`far_bands` **只存了 0..127** → 列 128..153 缺基址。这 26 列含 `INT_L`/`INT_R` 各 350 个（`law_tiles` 实测），列 154..157 只有 `INT_FEEDTHRU_1`（穿通，本就不是配置列）
- ⇒ 「INT tile 只有 44,100/53,100 = 83.1% 能定位」**是表截断，不是硬件限制**。补 26 列即可到 53,100/53,100 = 100%（用 `frame_map` 的首帧直接算：band0 col128=4,352、band6 col128=35,828 …）

### 五、一句话

> `.bit` 只写一次 FAR=0，其余靠线性自增；**`band` = FAR 的 (block, top, row)，`col` = FAR 的 column 字段（逻辑块 154 列、另一类 15 列），`minor` = 列内帧号**；**bank 不是比特流字段**，若他人用「bank」指 block type，那就是"列族"层级。

【未测】为何逻辑块 154 列而 tilegrid 有 158 个 tile 列（差的 4 列是穿通列，无配置列）；block 1 对应哪些资源类型未逐个核对。


## 89. 其它 tile 类型的 PIP 迁移计划（T40 续篇，2026-11-08）

【数据事实】A 类「每目的 1 源」7,517 条 = 全器件 PIP 的 21.4%；INT 只占 21.3%；D 类 15,726 条 = 44.8% 仍无位编码（T39）。

【推断】A 类若实测成立「一条布线 PIP ↔ 一个位」，这 21.4% 可由模板零差分成本生成位库；但 T41 的 `BUFGCTRL`（2 源 mux 占 2 位）与 §84 的 `IOSTANDARD`（7 位/2 帧）都是「1:1 拓扑 ≠ 1 位」的先例，故该假说按可证伪处理。

计划要点（未执行，故不进结论区）：
- 第 1 批打 4 个实例：`INT_INTERFACE_L_X14Y349`（col 14 / band 4 / block 21468–21495 / 24 PIP）、`BRAM_INT_INTERFACE_L_X50Y349`（col 50 / 22692–22719）、`IO_INT_INTERFACE_L_X32Y349`（col 32 / **42 帧宽** / 22076–22117）、位置对照 `INT_INTERFACE_L_X14Y299`（band 3 / 16222–16249）。三个模板的 PIP 名逐条相同（`INT_INTERFACE_LOGIC_OUTS_L_Bk -> INT_INTERFACE_LOGIC_OUTS_Lk`）。
- 施工方式限定为「DCP 内删一条 PIP」，与 A 作对比；【数据事实】换引脚不可用（T40：换脚 85 格/49 帧，同时改 IOB/ILOGIC/接口 PIP/整条 INT 路径）。
- 第 2 批 BRAM_L/DSP_L（禁照抄 artix7 的 `BLOCK_START` 35356/34884；先用 `IN_USE`/`ZINIT_A` 当定位器）；第 3 批 HCLK_CMT（982 PIP / 42 目的 / 均 23.38 源）验 INT 生成式是否泛化到 `CLK_HROW`。
- 新增待办：`pip_law_any.py`（任意 tile_type 的族/域/源统计，须复现 INT 的 172/1,598/3,636 作回归门）、`block_info.py`（block_start + **帧宽**）。

【未测】A 类位映射从未实测；24 条 interface PIP 能否在一份设计中全部占用；IOB 边缘 tile（Y351..361）超出行带模型（`block_start` 会 IndexError），算法未建立。

文档：`v7re/steps/T40_OTHER_TILES_PLAN.md`。



## 91. 时钟 mux 批量实测：BUFGCTRL 选择位公式（2026-11-08）

远端 `/opt/lzh/v7re/work/clkmux`，10 构建 / 8 路并发 / 墙钟约 2 分钟。

| 对比 | 差格 | 帧 | PIP 相同 |
|---|---|---|---|
| BUFGCTRL_X0Y8 S0/S1 | **2** | 7834, 7835 | ✅ |
| BUFGCTRL_X0Y16 S0/S1 | **2** | 13080, 13081 | ✅ |
| BUFGCTRL_X0Y24 S0/S1 | **2** | 13080, 13081 | ✅ |
| BUFGMUX X0Y16 S | **2** | 13081 | ✅ |
| 输入脚互换 | 2 | 13080,13081 | ❌ 作废 |
| 换 site（同选择） | 76 | 多 | ❌ 仅旁证 |

**BUFGCTRL 选择位公式**：
```
(frame_f,     word_w, bit 11)
(frame_f + 1, word_w, bit  3)
```
`frame_f/word_w` 由 site 定：X0Y8 → (7834, 97)、X0Y16 → (13080, 0)、X0Y24 → (13080, 4)。
位偏移恒定、位置信息编码在帧/字里 —— 与 INT mux 的「行格/列格」同构。

**BUFGMUX 编码不同**：两位同帧同字 `(13081, 0, bit2)` 与 `(13081, 0, bit11)`。

文档：`v7re/steps/T42_CLOCK_MUX_BATCH.md`。

## 90. far_bands 从 128 列补到 154 列（2026-11-08）

### 一、根因：导出脚本把 10 位列字段截成了 7 位

`v7re/export/law_db.py::load_far()` 原写 `col = (int(r["block_addr"],16) >> 7) & 0x7F`。FAR 的 column 是 **`[16:7]`，10 位**，本器件实际 154 列（0..153），`& 0x7F` 把 128 列之后全截掉 ⇒ `far_bands` 只有 896 行（7 band × 128 列），26 列（128..153）没有基址，而 `INT_L`/`INT_R` 在这 26 列上各有 350 个 tile。

**结论订正**：「INT tile 只有 44,100/53,100 = 83.1% 能定位」是导出 bug，不是硬件限制（§87 已记 FAR 有 154 列）。

### 二、修法

1. `load_far()` 掩码改 `0x3FF`；
2. 新增 `load_far_from_frame_map(model_db)`：直接从 `frame_map.far` 解 (block, top, row, col) 算首帧与帧数，**优先于 CSV 路径**（CSV 会把每段末尾 2 个 overhead 帧算进最后一列）；
3. `far_bands` 增加 `frames INTEGER` 列；`end_frame` 统一改成 `start_frame + frames − 1`（旧值自相矛盾且无人消费，`grep end_frame` 只在 schema 里出现）；
4. 备份：`E:\v7work\model\v7_law_backup_20261108_pre154.sqlite`（11,526,144 B）；脚本 `step03_pip/_extend_far_bands.py`。

### 三、写库结果（实测）

- 行数 896 → **1,078**（7 band × 154 列），列 0..153；原有 896 行 `start_frame` **逐条 0 变动**
- 每 band 末列（153）结束于段尾前 2 帧 → 段窗口仍 5,246（band0 col153 = 5,212..5,243，overhead 5,244/5,245）
- 28 个 overhead 帧（`frame_map.far IS NULL`）= 14 段 × 2，与「每 config row 末尾 2 overhead 帧」一致；`is_overhead` 计数 28 且这 28 行都没有 far
- 复现校验：`law_db.load_far_from_frame_map()` 重算 1,078 行，与库中**逐条 0 差异**（`step03_pip/_q_export_repro.py`）
- 与 CSV 口径的差：`phaseA/frame_index_far.csv` + 10 位掩码重算得每 band 154 列，但最后一列是 34 帧（含 2 个 overhead），库里是 32 —— 已解释，非冲突（`_q_far_csv_check.py`）

### 四、对解码器的影响（`tamper/ref/ref.bit`，945→982 tile）

| 指标 | 修正前 | 修正后 |
|---|---|---|
| active tile | 945 | **982**（= `pips_all.txt` 里 982 个 INT tile） |
| 解码 PIP | 1,789 | **1,886** |
| L1 未解释位 | 234 | 240（仍是 `(1,0,0)`/`(1,1,0)` 两格 × 120 tile） |
| L2 槽位违例 | 0 | **0** |
| 建模覆盖（bit） | 45.25% | **54.49%**（88,358,400 / 162,168,832） |
| 可定位 tile | 44,100 | **53,100**（62,625 里的全部 INT_L/INT_R） |

- **这正是修好它的证据**：新解出的 37 个 tile 贡献 97 条 PIP，而它们没有带来任何 L2 违例、L1 只多出已知的两格标记位。基址若错一帧，读数会整体错位 → L1 爆炸 + L2 大量违例。
- 与真值对账（`_q_verify_pips_after.py`）：`pips_all.txt` 的 INT PIP **1,263** 条，解出 **1,155 = 91.45%**；列 ≥128 的真值 40 条解出 **39**。

### 五、单 bit 穷举重跑（1,633,808 次翻转）

| 类别 | n | 检出 | 率 |
|---|---|---|---|
| off·mux | 560 | 560 | 100% |
| off·other | 2,472 | 2,472 | 100% |
| on·mux | 627,920 | 627,662 | 99.9589% |
| on·other | 1,002,856 | 994,026 | 99.1195% |
| **合计** | **1,633,808** | **1,624,720** | **99.4438%** |

基线解释不了的 240 位不参与「清 0」判定（`off_baseline_skipped`）。与修正前（1,572,246 次 / 99.44%）**率基本不变**，说明新增 37 个 tile 的行为与已建模 tile 一致。

### 六、154 列口径下重跑的四类篡改（2026-11-08）

| 篡改类 | `ref.bit`（982 tile） |
|---|---|
| 单 bit 穷举 | 1,633,808 次翻转，**99.4438%** 检出（off·mux 100%、off·other 100%、on·mux 99.9589%、on·other 99.1195%） |
| 幽灵 mux（空槽位写合法 2 位） | **0/300** 检出（解码器照单全收，报出从未布线的 PIP） |
| 换源（2–4 bit） | **18/300 = 6.0%**；有共享格 17/112 = 15.2%、无共享 1/188 = **0.5%** |
| 整条已布线 PIP 删除 | **8/300 = 2.67%**（全是共享格附带损伤） |
| 空槽位加整条合法 PIP | **0/300 = 0%** |
| word 50（ECC 字）单 bit | **0/300 = 0%** |
| Vivado 真实 LUT 功能篡改 | 1,092 bit 差异、建模区 **0**、解码 PIP 两边都是 1,886、active tile 两边都是 982、L1/L2 都是 240/0 |

- 真实设计的误报（`--fpstats`）：982 active tile 里 120 个报警（**12.22%**）、240 个未解释位
  （每个报警 tile 恰好 `(fo=1,bit=0)` 与 `(fo=1,bit=1)` 两格）、建模位误报 **146.9 ppm**、
  占建模 setbit 7.34%；白名单后告警 tile 0、未解释位 0。
- **顺带修掉一个检测器 bug（重要）**：`attack_fake_mux` 与 `attack_swap` 原用
  `if un or viol` 判检出，**没有减基线**，于是「该 tile 本来就有两个未解释标记位」被误算成检出
  → 幽灵 mux 在 154 列口径下一度报 300/300 = 100%。改为与基线签名 `_tile_signature()` 比较后
  回到 **0/300**；换源从 18 次里剔除误报后仍是 18 次（这两个函数之外的 `--classes` 一直用
  `_detect()`，未受影响）。两次运行同时留在盘上：`tamper/atk_ref300_154col.json`（未减基线，
  **不要引用**）、`tamper/atk_ref300_154col_fixed.json`（修正版）。
- 已同步更新 `paper/TAMPER_LOCALIZER.md`（全文表按 154 列口径刷新 + 文末修订记录）与
  `tamper/README.md`（JSON 与报告小节的对照表）。

### 七、待办

- `--classes` / `--attack`（PIP 删/加、word50、换源）在 154 列口径下重跑，刷新 `paper/TAMPER_LOCALIZER.md` 的分母
- 远端 `/opt/lzh/...` 的 `v7_law.sqlite` 副本尚未同步这次修改



## 93. BUFGCTRL 选择位完整公式（2026-11-08）

11 个 site 实测（Y0–Y8、Y16、Y24），每 site 2 位、PIP 逐行相同：

```
f0 = 7834 + 5246 * (Y // 16)
w  = (93 + Y // 2) mod 101
偶数 Y：(f0, w, 11) + (f0+1, w,  3)
奇数 Y：(f0, w, 27) + (f0+1, w, 19)
```

结构：一个字容纳 2 个 site × 2 位 = 4 位（`{3,11,19,27}`），`w` 每 2 site 前进 1，跨行 `f0` +5246。

附带：`IGNORE0` 是独立位 `(13080, 0, bit1)`，与选择位同字不同位。

坑：`BUFGCTRL_X0Y40/Y48` 不存在（只有 X0Y0..X0Y31）；`BUFHCE` 的 CE 为常量时 cell 被综合裁掉。

文档：`v7re/steps/T43_BUFGCTRL_FORMULA.md`。

## 92. 复用主线现状评估（2026-11-08）

一句话：**规律层已收口，瓶颈移到「可解性」与它脚下的数据层。** 下面按「能讲 / 不能讲 / 还剩什么」三块写，每条都标口径。

### 一、能讲的（数据事实，都能复算）

1. **复用分四层**：物理层 3,737 条 PIP = 3,693（172 个扇入>1 的目的 wire） + 44 直通；
   位池层每家族 10 个格（`frame_off` 16..25，两侧 1,664 格中的 10 个）；
   码字层 `sense=1` 8,900 行 = 3,634 feature（2,818×2 格 + 816×4 格）落在 1,598 个 cell 上，
   每 feature 2.45 格、每 cell 被 5.57 个 feature 共用（分布 2..18）；
   家族层族内每源码字 **172/172 互不相同**、严格子集对 **1,632**、跨族共享 cell **3/1,598**。
2. **规律是可执行形式**：地址链 `region→band→col→frame→word→bit`（154 列、7 band × 5,246 帧）；
   码字 `∈{1,2,7,11}`；行选择位 6 个（列重恰 4）→ `frame_row = 16+r`（384/384 行格 0 例外）；
   列码位 4 个 → 帧 `25−i`。
3. **谱型只有 7 种、172/172 命中**（复用度 = 码字矩阵列重）：20 源 `(5,5,5,5,4,4,4,4,4)`×96、
   24 源 `(18,18,6,6,4,4,4,4,4,4)`×64、16 源 `(12,12,4,4,4,4,4,4)`×6、长线 4 族各不同。
4. **乘积结构独立成立**：不看族名、不看帧号，按列重二分即可还原 `(组,码)` 叉积，
   **163/172 族完整**，9 个例外全是有解释的难族（6 复合族 + 3 长线族）。
5. **对账闭合**：`verify_all_pip.py` 在 INT_L 与 INT_R 上都是 172/172 家族、
   3,634/3,634 feature 精确命中、mux 1,536、beg 2,098、不符 0、未覆盖 0。
6. **缺口账是量出来的**：地址可公式化 160/172 = 93.0%（余 12 族覆盖 4.9% feature）；
   源→槽位顺序可推 **0/1,536 = 0%**（顺序是数据）。

### 二、只能说到这一步的（禁越界）

- **源级可解性**：单 feature 独立判定不可解；联立后**未证明**（现有依据只有 1,632 子集对）。
  不许说「不可解」，只能说「未证明」。
- **泛化**：单器件 485T、单 tile 类型族；跨器件未测、跨 tile 类型 0/4。
- **可加载位流**：ECC 地址项 `A(frame_addr)` 未定，写入器还不能生成任意可加载位流。
- **全器件定位**：`site_frames` 缺 16,979,200 行（INIT 只有 A6LUT、37,900 site）。
- **远端一致**：`/opt/lzh/v7re` 的 `v7_law.sqlite` 仍是 128 列版本。

### 三、可信度的三次自我修正（都有作废记录）

1. sense 混算 → 「每源 5 格 / 102-172 唯一 / 70 族 4:1 合并」全作废（§65、§76）。
2. INT_R 只有 63.6% → 是左右侧线名不对称，归一化后 100%（§68）。
3. `attack_*` 判检出未减基线 → 幽灵 mux 一度 300/300，修正后 0/300（§90）。

### 四、下一步优先级

P1（源级可解性联立求解，2–3 人日、纯本地）> P3（补数据层）> P2（ECC 地址项，需远端+板）。

## 94. P1：源级可解性的精确判定 —— 源是**唯一可解**的（2026-11-08）

### 一、问法与判据

不要启发式。对单个 tile：观察到的置位集合 `obs`（26 帧 × 2 parity 全池），
去掉未建模标记位后得 `target`；候选池 = 全部格都落在 `obs` 内的 feature
（3,634 条归一化去重后的 `(family, src)` 码字，2 或 4 格）。穷尽枚举
`S ⊆ 候选` 使 `union(S) == target`，解去重。

- **恰 1 解** → 该 tile 的源选择由位流唯一确定（模型口径下）
- **≥2 解** → 同位流、不同源，源级不可解的确证
- **0 解** → `target` 里有任何候选都覆盖不到的格子（模型缺口）

### 二、结果（`step03_pip/out/p1_solvability.json`）

| 位流 | active tile | 唯一解 | 多解 | 零解 | 无 mux 配置 |
|---|---:|---:|---:|---:|---:|
| `tamper/ref/ref.bit` | 982 | **868** | **0** | 0 | 114 |
| `_full8.bit` | 76 | 76 | 0 | 0 | 0 |
| `_b1.bit` | 57 | 57 | 0 | 0 | 0 |
| `_d2.bit` | 27 | 27 | 0 | 0 | 0 |
| `_c0.bit` | 21 | 21 | 0 | 0 | 0 |
| `_g1.bit` | 17 | 17 | 0 | 0 | 0 |

**合计 1,066 个含 mux 配置的 tile，全部唯一解，0 个多解、0 个零解、0 个截断。**

### 三、这推翻了什么（重要）

- `T6B_DISAMBIGUATION.md` 的「53 组多解」「`min-cells 2` 精确率 67.4%」
  **不是信息论限制，是解码器实现的产物**：旧解码器按「一条 feature 的全部格子都置位」独立判定
  （`np.logical_and.reduce`），再用 `min-cells` 启发式过滤；它不要求「解释完所有置位」，
  于是同一个观测能同时满足多条候选 → 多报。
- 换成「union 恰等于观测」的精确判据后，多解消失。原因是**编码本身是分离的**：
  族内每源码字 172/172 互不相同、跨族共享 cell 只有 3/1,598；
  选两个同族源会多出格子使 `union ⊋ target`，于是非法。
- 因此 `STATUS §70` 的 (b) 层「源选择：未证明」升级为 **「在模型口径下证明唯一」**；
  §74/§76 里「2 格歧义」的表述应读作「启发式解码器的歧义」，不是位流的信息论下界。

### 四、能说到哪一步（边界，别越界）

- 【数据事实】上述唯一性是在**已建模的 3,634 条 feature/侧**与「除 3 个已知标记格外无未解释位」的两个前提下测出来的。
- 【推断】若硅片上存在模型里没有的 feature，唯一性可能被高估；但模型已被 `verify_all_pip.py`
  在 INT_L/INT_R 上 3,634/3,634 精确命中、且与 `pips_all.txt` 真值对账（94% 召回）。
- 【未测】跨器件、跨 tile 类型；`block 1` 资源。
- 【未测】在「有条目未解释位」的位流上做同样枚举（本实验的 240 个标记位已被排除）。

### 五、可复算

```
python step03_pip/p1_solvability.py --bit tamper/ref/ref.bit _full8.bit --json step03_pip/out/p1_solvability.json
```

脚本要点：`build_pool()` 先用 `name_variants` 建并查集把 `LV_L0`/`LV0`、
`LOGIC_OUTS_L8`/`LOGIC_OUTS8` 这类同物异名收成一个代表（**不做这一步会凭空造出多解**，
第一版就踩了这个坑）；`enumerate_solutions()` 用「选候选最少的未覆盖格」分支 + 解集合去重 + 节点上限。

### 六、下一步

- 把精确判据接回解码器（替换 `min-cells`），重测 S13/T6B 的精确率/召回 —— 预期两者都到 100%
- 再验证：把「已知标记位」当覆盖物时是否还能构造多解（攻击者视角的歧义）



## 95. T44 全类型 tile PIP 普查（离线，2026-11-08；原编号 §74 与 §74「row 三义」撞号，顺延为 §95）

数据源 `templates/*.json` 的 `pip_defs`（`[dst, src, idx, is_bidi]`）。115 个模板中 **70 个含 PIP**，
共 **35,126 条 PIP / 16,951 个 family**，平均 2.07 源/族。

| 类 | 类型数 | PIP | 占比 | 平均源/族 |
|---|---|---|---|---|
| A 无复用 | 23 | 7,517 | 21.4% | 1.00 |
| B 单源主导 | 11 | 2,731 | 7.8% | 1.11 |
| C 稀疏多源 | 28 | 9,360 | 26.6% | 1.57 |
| D 密集多源 | 8 | 15,518 | **44.2%** | **15.46** |

- 多源族只占 **10.0%**（1,703/16,951）；源扇出>1 的占 **13.5%**（2,234/16,608）。
- D 类 8 个：`INT_L/R`（17.3）、`HCLK_CMT`/`HCLK_CMT_L`（23.4）、`CLK_HROW_BOT_R/TOP_R`（12.7）、`HCLK_L/R`（10.0）。
- **结构复用（多源族）与位复用（共享 cell）必须分开报**：后者只有 INT（均值 5.56、最大 18）与 BUFGCTRL 有实测。

文档：`v7re/steps/T44_ALL_TILE_PIP_SURVEY.md`；提示词 `v7re/prompts/PIP_REUSE_ALL_TILES_PROMPT_V1.md`（已修正 70/90 与 B 类定义）。

## 96. PIP 线进度总表（2026-11-08）

全文：`step03_pip/PIP_PROGRESS_20261108.md`（按 `step03_pip/PROMPT_PIP_PROGRESS_V2.md` 生成，六节结构）。
本节只放索引与最关键的一行结论，细节与复算命令看全文。

### 一句话

INT tile 的位库与复用规律**已收口**（172/172 族、3,634/3,634 feature 精确命中、0 不符）；
**没做完的三件**：ECC 与帧地址耦合未闭合、数据层缺 16,979,200 行、跨 tile 类型除 `BUFGCTRL` 外无实测。

### 索引

| 层 | 关键数字 | 详见 |
|---|---|---|
| 地址 | `far_bands` 1,078 行（7 band × 154 列）；每 band 5,246 帧；50,176 = 36,722 + 13,454 | 全文 §3.1、本节 §77/§78/§85/§87/§90 |
| 位库 | 3,737 = 3,693 多源 + 44 直通；3,634 + 59(VCC) + 44 = 3,737；sense=1 8,900 / sense=0 3,264 | 全文 §3.2、§69/§76/§93 |
| 复用 | 列重 Σw=8,900；7 谱型 172/172；乘积结构 163/172；族内唯一 172/172；子集对 1,632；跨族 3/1,598 | 全文 §3.3、§71/§73/§74/§79 |
| 闭环 | 解码精确 100%/召回 96.0%；FASM 幂等 0 帧改动；从零重建 118 位/13 帧 | 全文 §3.4、§57/§58/§59 |
| 篡改 | 单 bit 99.4438%；整条 PIP 删除 2.67%；空槽添加 / word50 / 幽灵 mux 全 0；LUT 功能篡改 0 检出 | 全文 §3.4、§35、`paper/TAMPER_LOCALIZER.md` |
| 可解性 | 1,066 个 tile **全部唯一解，0 多解** | 全文 §3.4、§94 |
| 跨类型 | 70/115 类型含 PIP，35,126 条 / 16,951 family；A 21.4%、D 44.2%；只有 BUFGCTRL 实测 2 位 | 全文 §3.5、§89/§95 |
| 缺口 | INIT 缺 16,979,200 行、100 个 block、ECC 地址项、A 类位映射、单器件 | 全文 §五 |

### 本轮实测（2026-11-08 复核）

| 项 | 值 |
|---|---|
| `far_bands` | 1,078 行，col 0..153 |
| `law_tiles` | 62,625 |
| `law_cells` INT_L / INT_R | sense=1 8,900、sense=0 3,264、feature 3,634、cell 1,598（两侧相同） |
| `verify_all_pip --normalize` | 两侧均 172/172、3,634/3,634、不符 0、未覆盖 0 |
| `pip_bits` | 3,528（`tilepipe_20261025` 3,504 + `step03_pip_20261024` 24） |
| `site_frames` | 19,819,900（目标 36,799,100） |
| `frame_map` | 50,176（50,148 有 FAR、28 overhead） |

复算：
```
python -c "import sqlite3;c=sqlite3.connect(r'E:\v7work\model\v7_law.sqlite');print(c.execute('select count(*) from far_bands').fetchone())"
python v7re/scripts/verify_all_pip.py --tile-type INT_L --normalize
python step03_pip/_q_pipbits_state.py
```


## 98. BUFGCTRL 公式外推全中 + 32 路并发验证（2026-11-08；原编号 §75，与「frame_row」§75 撞号，顺延为 §98）

32 路并发跑 54 个构建（BUFGCTRL Y9–Y31 各一对 46 个 + BUFHCE 8 个），46 成功。

**公式外推：23 个未见过的 site 全部命中，0 不符**。
即 `BUFGCTRL_X0Y0..X0Y31` 全部 32 个 site 的选择位由一条公式覆盖（9 个实测 + 23 个外推验证）。

```
f0 = 7834 + 5246 * (Y // 16)
w  = (93 + Y // 2) mod 101
偶数 Y → (f0,w,11) + (f0+1,w,3)
奇数 Y → (f0,w,27) + (f0+1,w,19)
```

**BUFHCE 8 个构建全失败**：`CE` 为常量时 cell 被综合常量传播删除（`DONT_TOUCH` 不阻止）；
`BUFHCE_X0Y84` 不存在。要测需让 CE 接真实信号。

**32 路并发实测可用**（46 个构建无内存/资源报错）。

## 97. 项目主线：PIP 复用分析（2026-11-08 用户口径）

### 一、主线是什么

只回答三个问题，其余都不算主线：

1. **复用发生在哪几层** —— 器件层（同 (band,col) 的 50 个 tile 共用 26 帧）/ 族层（172 个 mux 家族共用位池）/ 位层（cell 被多个 feature 共用）/ 跨族层（3/1,598）。
2. **复用规律是什么** —— 复用度 = 码字列重（Σw = 8,900）；7 种谱型 172/172；乘积结构 163/172；族内唯一 172/172；子集对 1,632；跨族共享 3/1,598。
3. **这套规律能不能反过来用** —— 生成（给定族与源算出位集）/ 判定（给定位流唯一还原源，P1 已证 1,066 tile 唯一解）。

### 二、不算主线的（列出来是为了不被带跑）

| 旁支 | 为什么不是主线 |
|---|---|
| ECC 与帧地址耦合 | 影响「生成任意可加载位流」，不影响复用规律的表述 |
| `site_frames` 缺 16,979,200 行 | 缺的是 CLB/BRAM/DSP 的 INIT 位，不是 INT 复用 |
| 跨 tile 类型位库迁移 | 工程量大；只有「A 类是否也有复用层」这一条会反哺主线范围 |
| 篡改定位器 / 上板 | 复用规律的下游应用 |
| 论文投稿打包 | 用主线结论去投，不是主线本身 |

### 三、主线的当前缺口（只有两个）

1. **规律仍是查表**：`law_cells` 3,634 条，不是闭式代数。目标：给定 `(family, src)` 能算式算位集，与表逐条 0 差异。
2. **「源 → 槽位顺序」0/1,536 可推**：顺序更像布线邻接的数据。判据：用 `tileconn` 邻接预测顺序，命中率显著高于随机 ⇒ 顺序 = 邻接；否则 ⇒ 顺序是表里的数据，代数不必覆盖它。

### 四、主线的下一步（按依赖）

1. 写生成式代数（2–3 人日，判据：172 族逐条 0 差异）
2. 判定顺序是数据还是规律（1–2 人日，用 `tileconn` 预测）
3. 复用是否跨 tile 类型成立（A 类位上有没有隐式复用，远端实验）
4. 复用是否跨器件同构（需第二器件）

详见 `step03_pip/PIP_PROGRESS_20261108.md` 与 §71 / §92 / §96。


## 101. BUFGCTRL 接入解码器 + 跨设计复现（2026-11-08）

新增 `v7re/scripts/clk_mux_bits.py`（公式 + 编解码）；`fasm2bit.py` 支持
`BUFGCTRL_X0Y<Y>.SEL=I0|I1` 双向。编码实测为 one-hot：`I1 → (A=1,B=0)`、`I0 → (A=0,B=1)`。

验证：
1. `g16_s0` → 解出 `SEL=I0`、`g16_s1` → `SEL=I1`（与 RTL 一致）；
2. 自身回写 **改动帧 0**，sha256 不变 `C8621C0D…F31A17`；
3. **跨设计复现**：把 `SEL=I0` 改成 `I1` 后与 Vivado 的 `g16_s1.bit` 对比
   → **帧级 0 差异 / 50,176 帧**（含 ECC），字节级仅 6 字节（时间戳 2 + 尾部 CRC 4）。

即：改一行 FASM 就能生成与 Vivado 等价的设计，唯一缺口是尾部 CRC。

文档：`v7re/steps/T45_BUFGCTRL_INTEGRATION.md`。


## 102. HCLK_CMT 任务提示词（2026-11-08）

`v7re/prompts/HCLK_CMT_TASK_PROMPT_V1.md`（草稿 `_draft_hclk_cmt.md`，经本地 prompt-optimizer
`user-prompt-professional` 优化）。内容含：已知事实清单（地址公式、INT 172 族已解、受控差分纪律、
四类结构对照）、三问目标（几位/位间关系/可否公式化）、六条方法要求（离线摸底、隔离实验三类、
回读断言、残差归因、禁抽样、交叉验证）、六项交付物、三条红线。

## 99. 复用主线：源→槽位顺序判定为「16 条配置 + 族序号规则」（2026-11-08）

短板（此前记为 0/1,536 可推）已判定：**不是布线邻接，也不是 1,536 条任意数据**。

- 【数据事实】64 个 24 源族去重后只有 **16 种配置**，每种 4 个族；配置由族名（前缀 + 序号）确定：
  `BYP_ALT` 奇偶交替且互为镜像 `r→3−r`、`FAN_ALT` 0/1/2/7 与 3/4/5/6 两态、`IMUX_L` 每 8 个一组组内奇偶交替（12 种）。
- 【数据事实】结构：列码 = f(线类)（斜线/主轴短线/R 线/长线 四类）64/64；行号 = f(方向) 64/64；
  斜线行 = 同名主轴方向行 64/64；8 个旁路源占 row 4/5、每码一 row4 + 一 row5 共 256/256。
- 【数据事实】几何部分 **1,024/1,024 = 100% 可重建**（`_q_slot_split.py`）；旁路部分 512 条只还原结构，row4/5 归属仍是逐族数据。
- 【数据事实】该表对 INT_L 全部 26,550 个 tile 相同（`law_cells` 键不含坐标）→ 与 tileconn 连线、与 mux 位置无关。
- 【数据事实】INT_R 侧已重跑（_q_slot_intr.py）：同样 64 族、类→code 64/64、方向铺满 64/64、配置 16 种，排列三元组集合与 INT_L 完全相同。
- 【未测】为什么恰好 16 种、镜像与奇偶的成因；96 个 20 源 BEG 族未展开。
- 文档：`step03_pip/PIP_REUSE_STRUCTURE.md` §11；脚本 `_q_slot_class.py`…`_q_slot_split.py`。


## 103. HCLK_CMT 攻坚：阶段一完成、阶段二部分完成（2026-11-08）

脚本 `v7re/scripts/hclk_survey.py`，数据 `v7re/steps/hclk_sources.json`，文档 `v7re/steps/T46_HCLK_CMT_SURVEY.md`。

**阶段一（离线，已完成）**：982 PIP / 42 dst / 72 src；14 个 `MUX_CLK_k` 源集合完全相同（48 源 =
CCIO×4 + CK_BUFHCLK×12 + CK_IN×10 + MUX_CLK_MMCM×14 + MUX_CLK_PLL×8）；各组索引连续；
**与 INT 的「8 方向×端线」不同构**（HCLK_CMT 按功能分类）；编码候选收敛为 6 位二进制 / 两级 / 分组 one-hot。

**阶段二（帧定位，部分完成）**：14 个 HCLK_CMT tile（COL 88 与 305，7 个时钟区域各一对）；
MMCM 设计确实经过 HCLK_CMT（`HCLK_CMT_L_X305Y26` 的 `MUX_CLK_MMCM0->>CK_IN0`）；
`d1`(BUFG) vs `d2`(MMCM) 差分 174 格/124 帧，CMT 列新增区为**帧 35528–35585**（word 0,1,2,3,30,31），
但该簇同时含 MMCM 自身配置位，无法分离。

**两条负结果**：换输入引脚**不**改变 HCLK_CMT 的 mux 选择（ma/mb 同一条 PIP）；
纯 BUFG 设计**不**经过 HCLK_CMT（PIP 计数 0）。

**下一步**：用 BUFHCE 做叶子时钟缓冲，对比「输入来自 BUFG」vs「输入来自 MMCM」，
分离出 `MUX_CLK_k` 选择位。已知坑：PLLE2_ADV 无 CLKOUT*B 端口；BUFHCE 的 CE 为常量会被删除；未使用端口会被裁剪。


## 104. HCLK_CMT 隔离成功（2026-11-08）

`/opt/lzh/v7re/work/hclk4`：三设计仅「MMCM 哪个 CLKOUT 喂 BUFH」不同（MMCM 参数逐字相同），
`g0/g1/g2 = CLKOUT0/1/2 → BUFH → FDRE`。

| 对比 | 差格 | PIP 差异 |
|---|---|---|
| g0 vs g1 | **2 格 / 4 位** | 仅 `MUX_CLK_MMCM0` vs `MMCM2 ->> MUX_CLK_13` |
| g0 vs g2 | **4 格 / 6 位** | 同上（MMCM4） |

PIP 行数 193/193/193 完全相同。差分位全部落在**帧 32636–32639**（word 28/29/51），
其中 `(32639,28/29)` 出现 `0xda00`↔`0xd800` 整段互换 → 提示是**两个 16 位字段**而非单一二进制。

**结论**：HCLK_CMT 的 mux 选择位可逐个测出，换源只动 2–4 格，满足受控差分判据。

下一步：补不同 MMCM site（分离「实例」维度）、CLKOUT3–6（输出序号）、BUFG 直驱（CK_BUFHCLK 组）。

文档：`v7re/steps/T47_HCLK_CMT_ISOLATION.md`。

## 100. P1：BEG 侧 96 个族的复用结构（2026-11-08）

**结论一句话**：96 个 20 源 BEG 族全部是完全二分 5×4 网格，P 轴 96/96 由源的方向令牌决定、Q 轴 64/96 为「几何类别四列」——与 mux 侧 6×4 同构，复用定律的第二个实例成立。

# 一、结构（`step03_pip/_p1_beg_bip.py`）

| 形态 | 族数 |
|---|---|
| `K(5,4)` | 64 |
| `K(4,5)` | 32 |
| 非二分 | 0 |

20 源 = 5 × 4；mux 侧 24 源 = 6 × 4。

# 二、两轴归属（`_p1_beg_law.py`）

| 轴 | 判据 | 命中 |
|---|---|---|
| P（5 组） | 同方向令牌的源恒在同一组 | **96 / 96 族** |
| Q（4 列） | 列内几何类别一致（line 4 个 + logic 6 个，故 1 个 logic 并入 line 列） | **64 / 96 族** |
| Q（变体） | len2 按方向拆两列、混入 `LH*/LV_*` 长线 | 32 / 96 族 |
| 配置签名 | 方向组 → 帧 的映射 | 54 种（每种 1–2 族） |

# 三、缺口账更新

- 旧：几何槽位可推 **1,024 / 1,536 = 66.7%**（只有 mux 侧）。
- 新：**2,304 / 2,944 = 78.3%**（mux 1,024 + BEG 1,280）；剩余 640 条 = BEG 的 32 个长线变体族，只做到定性。

# 四、边界

- 只测 INT_L；「P 轴 = 方向」是数据事实，其成因、32 个变体族的列规则均【未测】。
- 不能据此声称「复用已完全解释」：复合族/长线族（12 个）与跨 tile 类型仍在 P2/P4。

# 五、复算

`python step03_pip/_p1_beg_bip.py` / `_p1_beg_law.py` / `_p1_beg_qaxis.py`

## 105. P3：定律 → 生成器（2026-11-08）

**结论一句话**：把定律写成可执行生成器后，**mux 侧 64 个族能用「族名 + 源名」重建出全部 cell，0 差异**（3,072 条记录）；BEG 侧 96 个族在槽位级成立，其中 64 族只靠两条全局规则。生成器合计复现 **3,456 / 3,634 = 95.1%** 的 feature，剩余 178 条属 12 个复合/长线族（P2 未做）。

# 一、判据与脚本

| 脚本 | 口径 | 判据 |
|---|---|---|
| `step03_pip/gen_mux.py` | cell 级 | 生成 cell 集合 == `law_cells` 真值 |
| `step03_pip/gen_slots.py` | 槽位级 | 源 → (行/组, 列/码) 归属一致 |

# 二、mux 侧（64 个 24 源族）

| 项 | 结果 |
|---|---|
| 符合公式 | 64 / 64 |
| 方向令牌 → 行（族内唯一） | 64 / 64 |
| 重建后 0 差异 | **64 / 64**（3,072 条 (feature,cell) 记录） |
| 配置种类 | **16 种 × 4 族**（与 §11 一致） |
| 线类 ↔ 列码 | **64 / 64**：axis/diag 占码对 {{1,2}}、rlineL/rlineR 占码对 {{7,11}}，对内标签逐族互换（每族 1 位）；旁路源占行 4/5 不参与 |

关键修正：**primary 位方向逐族不同**（行 0 用哪个 bit），第一版按「最小 bit 优先」假设，导致恰好一半族（32 个 parity=1 的）被判「公式不符」；改为「行 0 所用的 bit 即 primary」后 64/64 全通。

# 三、BEG 侧（96 个 20 源族）

| 轴 | 规则 | 命中 |
|---|---|---|
| P（5 组） | 方向令牌 → 组 | 96 / 96 |
| Q（4 列） | 几何类别 → 列（line 与 logic 共列） | 64 / 96 |
| 变体 | 32 族需逐族列归属表 | 32 |

# 四、覆盖账

| 口径 | feature | 占比 |
|---|---|---|
| cell 级 0 差异 | 1,536 | 42.3% |
| 槽位级 0 差异 | 1,920 | 52.8% |
| 合计 | **3,456** | **95.1%** |
| 未生成（12 族复合/长线） | 178 | 4.9% |

生成所需表规模 ≈ 6×10² 个数字（172 族 × 3 + 16 配置 + 32 变体），对应 8,900 条置位记录。

# 五、边界（不得越界）

- cell 级 0 差异仅 mux 64 族；BEG 是槽位级，其 cell 坐标（行/列帧窗口）尚未公式化。
- `primary` 位为何逐族不同、【未测】；生成器目前从数据取该值。
- 12 个复合/长线族（178 条 feature）未纳入，属 P2。
- 只验证 INT_L；INT_R 未跑同一套生成器（族名归一化已有，`verify_all_pip.py --normalize` 侧证过 100%）。

# 六、复算

```
python step03_pip/gen_mux.py     # 期望：重建 0 差异: 64
python step03_pip/gen_slots.py   # 期望：mux 64/64、BEG 64/96
```



## 106. HCLK_CMT 选择位枚举（2026-11-08）

`/opt/lzh/v7re/work/hclk5`：MMCM 固定在 `MMCME2_ADV_X0Y6`、7 个 CLKOUT 参数逐字相同，
只改「哪个 CLKOUT 接 BUFH」。Vivado 选中源：CLKOUT0..6 → `MUX_CLK_MMCM0/2/4/6/8/9/10`。

差分（对 k0）：**2–4 格**，全部落在**帧 22144/22145/22147**（word 27–30、51）。

结构：**两段式**
- 段一 `(22144, 51)` bits 25–27 = 组内序号（观测 0/1/2/4），bit 29/31 为类标记；
- 段二 `(22147, 27..30)` 每 word 的 bit 25 或 bit 9 = **8 组 one-hot**（7 个样本落在 7 个不同组，无重复）；
- `48 = 8 组 × 6`，与 `MUX_CLK_k` 源数整除。

未闭合：组的划分规则、类标记位含义；需补同组 6 源、`CK_BUFHCLK*`、`CCIO*`、`MUX_CLK_PLL*` 样本。

文档：`v7re/steps/T48_HCLK_CMT_ENUM.md`。


## 81.1. HCLK_CMT：PLL 源编码解出（2026-11-08）

`/opt/lzh/v7re/work/hclk6`：PLL0..5（`PLLE2_ADV_X0Y6`，参数逐字相同，只换 CLKOUT）。

**关键差异**：PLL 样本在帧 22147 word 27–30 **全为 0**（MMCM 样本在那里有交叉开关图案）。

选择位两处：
```
PLL0: (22144,51) bit25      PLL1: (22145,51) bits25,31
PLL2: (22144,51) bit26      PLL3: (22145,51) bits26,31
PLL4: (22144,51) bit27      PLL5: (22145,51) bits27,31
```

**编码：奇偶分字 + 每字 3 位 one-hot**
```
MUX_CLK_PLL n:  字 = 22144 + (n & 1)，位 = 25 + (n >> 1)
```
`(22145,51)` 的 bit31 = 使能位（PLL 恒置，MMCM 部分置）。

**结论**：`MUX_CLK_PLL0..7` 的编码已解；MMCM 组多出的 22147 字段属于 CMT 交叉开关，不是 MUX_CLK_k。
`CCIO` 组：引脚直驱 FF 完全不经过 HCLK_CMT（两个样本无相关 PIP），需另找构造。

文档：`v7re/steps/T49_HCLK_CMT_PLL.md`。


## 82.1. PLL6/PLL7 补测失败（2026-11-08）

尝试在 `PLLE2_ADV_X1Y6` 上取样本：三个构建成功，但**没有产生任何 `MUX_CLK_PLL*` PIP**，
与 p0 的差异 163–164 格且跨多帧。

原因：`X0Y6` 与 `X1Y6` 不在同一 CMT 列；X1 列走 `CMT_TOP_L_UPPER_T_X305Y356` 那一族，
其输出落在另一个 HCLK_CMT tile 与另一批帧上，不可比。

**结论**：每 CMT 列只有一个 PLL 站点，`PLL0..5` 的 6 个 CLKOUT 已测完；
`PLL6/PLL7` 无法用现有构造产生。因此 PLL 公式标注为**部分验证（6/8）**，不当作全组定律。


## 83.1. HCLK_CMT 源可达性（2026-11-08）

`/opt/lzh/v7re/work/hclk8`：`BUFG(X0Y0/8/16/24) → BUFH → FF` 四个设计，
路由全为 `BUFG → GCLK{n} → HROW CK_MUX_OUT_L0 → HCLK_OUT_L0 → BUFHCLK_L0`，
**无任何 HCLK_CMT PIP**。

| 构造 | 是否经过 HCLK_CMT |
|---|---|
| 引脚直驱 FF | ❌ |
| BUFG → BUFH → FF | ❌ |
| MMCM → BUFH → FF | ✅ `MUX_CLK_MMCM*` |
| PLL → BUFH → FF | ✅ `MUX_CLK_PLL*` |

**48 个源里可达 20 个（MMCM 14 + PLL 6），其余 28 个（CK_BUFHCLK 12 / CK_IN 10 / CCIO 4 / PLL6-7 2）
在常规单区域时钟设计中不会出现。**

**重要推论**：解码器只需覆盖 MMCM/PLL 两类即可解释真实设计中的全部 HCLK_CMT 配置，
不必把 48 源当成全都要解。

附带：`BUFGCTRL_X0Y8/16/24 → GCLK8/16/24`，与 T43 一致。

文档：`v7re/steps/T50_HCLK_CMT_REACH.md`。


## 84.1. MMCM 14 源补测受阻（2026-11-08）

三次尝试均失败：
- MMCM@X1Y6 + FF 锁到 X0 列 `SLICE_X12Y20` → `[Place 30-176] Unroutable Placement`（跨 CMT 列时钟不可布线）；
- FF 改 `SLICE_X12Y120` → 站点不存在；
- MMCM@X1Y6 + FF 自由放置（hclk7 q0..q2）→ 构建成功但**无任何 HCLK_CMT PIP**。

**结论**：`MMCM1/3/5/7/11/12/13` 与 `CK_BUFHCLK*`/`CK_IN*`/`CCIO*` 同属「需跨区域或专用路径」，
现有合成构造不可达。

**HCLK_CMT 最终状态**：
- 选择位位置 ✅（帧 22144/22145 w51 bits 25–27 + bit31；MMCM 另有 22147 w27–30）；
- `PLL0..5` 编码 ✅（6/8）；
- `MMCM0..10` 位置 ✅、编号规则未闭合；
- 其余 28 源 ❌ 不可达（已证明）。

**要再推进必须换信息源**：用真实设计（跨时钟区域/多 MMCM/专用时钟脚）的位流，
而非合成小设计。


## 85.1. 「为什么是 6×4」—— 6 类 × 4 槽（2026-11-08）

本地全量统计（64 个 mux 族）：

| 行帧 | 源数 | 类别 |
|---|---|---|
| 16..19 | 各 4 | ROUTE（方向线） |
| 20/21 | 各 4 | LOGIC 与 BOUNCE（32/32 族顺序互换） |

列 cube 4 种：`{(25)} {(24)} {(23,24,25)} {(22,24,25)}`；行分布恒 `(4,4,4,4,4,4)`、列分布恒 `(6,6,6,6)`。

**结论：6 = 源类别数（4 方向类 + 逻辑输出 + bounce），4 = 每类内槽位数。**
24 = 6 类 × 4 槽；16 条方向线 = 8 方向 × 2 长度类折成 4 行。

**复用本质**：行字面量被 4 源共用、列 cube 被 6 源共用，平均 5.56。

**证伪记录**：H1 的「同族两源必有交集」错（13,834 对无交集）；「跨族零共享」有 3 个例外
（`(0,0,2)`、`(1,0,6)`、`(0,0,9)`，均在 LH0/LV_L0/LV_L18 之间）；「格数只有 2/4」「列 cube 只 4 种」成立。

文档：`v7re/steps/T52_WHY_6X4.md`、`v7re/steps/T51_GENERATIVE_LAW_LOCAL.md`。


## 86.1. LOGIC/BOUNCE 行顺序的可预测规则（2026-11-08）

```
row20 放 LOGIC ⟺ (IMUX 编号 // 8) 为偶数，或 family ∈ BYP_ALT
```
48 个 IMUX + 16 个 ALT 族全部命中，0 例外（IMUX 按 8 个一段交替；BYP_ALT 全 L、FAN_ALT 全 B）。

但「16 条方向线怎么分 4 组」仍是 per-mux：48 个 IMUX 族给出 **32 种不同分组**。

**界线**：类别层面（ROUTE/LOGIC/BOUNCE + 行顺序）可预测；实例层面（哪条线进哪行）是布线图事实。

文档：`v7re/steps/T52_WHY_6X4.md` §8–§9。

## 87.1. 路由级 PIP 表大规模实证：698/698 全通过（2026-11-08）

32 个独立设计自由布线 → 采集 717 条活跃 PIP（85 tile / 40 家族 / 448 去重三元组）→ 698 条能映射到迁移表者，在各自比特流里逐一核对 **2,035 个 cell**：

```
entries 698/698 pass (100.0%)   bits 2035/2035 (100.0%)   failures 0
```

- 含 421 个 sense=0 位（负断言）。
- **阴性对照**：全部 frame +36 → 2/698 (0.3%)，位命中 20.9%（≈sense=0 占比 20.7%）→ 判别力成立，不是"全 0 位流蒙过"。
- 位址规则首次在 85 个 tile 上落地：`band = tile_Y // 50`（**不是** grid_y//50）+ clb_blocks 四级优先级。
- 19 条未覆盖：`FAN_BOUNCE7←FAN_ALT7`(12)、`FAN_BOUNCE2←FAN_ALT2`(7) —— 时钟族表缺，需单独 fuzz。
- **解析修正**：7 系列 .bit 字是**大端**；小端会把同步字读成 0x665599AA 并得到 0 帧。改大端后 FDRI burst = 5,067,776 = 50,176×101。

文档：`step03_pip/S16_PIP_HARVEST_VALIDATE.md`；脚本：`E:\v7work\validate_pip.py`。


## 87.2. 位对/parity 的闭式公式（2026-11-08）

```
g = i // 16 ;  h = (i // 8) % 2
minbit = 8 * (i % 4) + 2 * g + 2 * h
parity = 1 if (i % 8) >= 4 else 0
```
48 个 IMUX **全部命中，0 例外**。加上 §86 的行顺序规则，族级结构里
「位对 / parity / 行类别 / LOGIC-BOUNCE 顺序」四项已可纯计算；
只有「源→槽位」和「方向线 4 分组」是 per-mux 数据。

## 88.1. PIP 覆盖面盘点（回答「是不是只做了 CLB 的 PIP」）

**不是 CLB，是 INT（布线开关盒）的 PIP。**

全器件 115 个含 PIP 的 tile type、共 **35,126 条 PIP**：

| 范围 | PIP 数 | 占比 |
|---|---|---|
| INT_L + INT_R（已做，172 族 × 2） | 7,474 | **21.3%** |
| 其余 113 个 tile type（未做） | 27,652 | 78.7% |

CLB 自身也有 PIP（`CLBLL_L/R` 各 146、`CLBLM_L/R` 各 151，全器件约 1,200 条），**尚未分析**。
单 tile 未做的最大块：`CLK_HROW_BOT/TOP_R` 各 2,840、`PCIE_BOT` 各 1,736、
`HCLK_CMT` 各 982、`BRAM_L/R` 各 974、`DSP_L/R` 各 794、`GTX_CHANNEL_*` 各 628、`LIOI/RIOI` 各 467。

## 88.2. 反向检验：INT PIP 表精度 100%（2026-11-08）

第二波 32 设计（含 LUT→LUT 内部网、去 PACKAGE_PIN），每设计 8 tile 全 PIP 落表 + Tcl driver map：

```
truth 372  TP 366  AMBIG 0  WRONG 0  FN 6  FP 0
```

- **假阳性 0**：~35 万次 (tile×家族) 判定无一"未被使用却匹配"。
- **多解 0**：同 tile 多家族同时激活时仍唯一回推 src。
- 6 条 FN 全为 `BYP_BOUNCE{0,4,1}←BYP_ALT{0,4,1}` —— `all_cells.json` 中无此家族，属 CLB tile 旁路 mux，**范围外**（同第一波 `FAN_BOUNCE*`）。
- 结论：INT tile 作用域内召回 100%、精度 100%。

文档：`step03_pip/S16_PIP_HARVEST_VALIDATE.md` 附录 B；脚本 `E:\v7work\reverse_check.py`。


## 89.1. 槽位表从 48 张压到 16 张 + 2 个常数置换（2026-11-08）

48 个 IMUX 族按「源集合」分成 **16 组 × 3 族**（组内三族共用同一套 24 条源线），
例如 `{IMUX_L0, IMUX_L8, IMUX_L16}`。组内相邻族的槽位表之间是**固定置换**：

| 组 | 一步置换 | 与 P1 对比 |
|---|---|---|
| L0–L7 的 8 组 | **P1** | 8/8 完全一致 |
| L24–L31 的 8 组 | **P1'** | 与 P1 只重合 8/24（是另一个常数置换） |

即：**48 张槽位表 = 16 张基础表 + 2 个常数置换（P1 用于下 8 组、P1' 用于上 8 组）**。
校验方法：把「源→槽位」按族对推导成「槽位→槽位」置换再逐条目比对，不是抽样。

剩余的 16 张基础表之间**没有共有源线**（`L0..L7` 两两交集为 0），
说明它们对应 24 条各不相同的物理线，属于布线图事实，暂未见生成规则。

## 90.1. 方向线 4 分组：仍未导出

例 `IMUX_L0` 的 4 组方向线：
```
r0 {NE2END0, NN2END0, NR1END0, SL1END0}   r1 {SE2END0, EE2END0, SR1END_N3_3, NL1END0}
r2 {NW2END0, WW2END_N0_3, ER1END_N3_3, WL1END_N1_3}   r3 {SW2END_N0_3, SS2END_N0_3, WR1END0, EL1END0}
```
`IMUX_L24` 同源集合但分组不同（`r0 {WW2, NW2, SL1, NR1}`）→ 分组随族变，属 per-mux。
**补记（同日）**：6 条 FN 经查是 `always` ppips（`ppips_int_{l,r}.db` 各 108 行全为 always），`BYP_BOUNCEk←BYP_ALTk`/`FAN_BOUNCEk←FAN_ALTk` 共 16 条**不占配置位**。修正召回口径：truth 372 = TP 366 + PPIP 6 → **召回 100%、精度 100%**。旁路结构为三段串联（BYP_ALTk mux → BYP_BOUNCEk(always) → IMUX），解码器应把这 16 条当零成本通路预置。见 S16 附录 B.5/B.6。


## 91.1. PIP 地址编码规律：列 = 线长类别（768/768 无例外）

把 48 个 IMUX 族的 768 个布线源按「列码 × wire kind」统计：

| 列码 | kind | 数 |
|---|---|---|
| 1 | DOUBLE | 192 |
| 2 | DOUBLE | 192 |
| 7 | SINGLE | 192 |
| 11 | SINGLE | 192 |

即 **列码 1/2 ⇔ 长线 DOUBLE，列码 7/11 ⇔ 短线 SINGLE，零例外**。
行：0–3 = 方向线 4 个成员，4 = 逻辑输出/GFAN，5 = bounce。

24 = 4 行布线源 × 4 列 + 4 逻辑 + 4 bounce。**6 行 = 4 布线 + 1 逻辑 + 1 bounce；4 列 = 类内成员位。**

方向线可归成 4 个名字类（对角线 / 直角 / R 后缀 / L 后缀），每类 4 条占一列；
类内行顺序部分有闭式（对角线类 `row=(N?0:1)+(E?0:2)`），**类→列随族变**。

文档：`v7re/steps/T53_PIP_ADDRESS_LAW.md`。


## 92.1. 方向类 → 列：48/48 可预测（2026-11-08）

全器件只有 **2 种**「列 → 方向类」签名，按 8 段交替：

```
(i//8) 偶数 → {1:对角, 2:直角, 7:R, 11:L}
(i//8) 奇数 → {1:直角, 2:对角, 7:L, 11:R}
```

再加上此前的：位对/parity 闭式（48/48）、线长↔列（768/768）、LOGIC/BOUNCE 行序（64/64），
**现在只剩「类内 4 条线谁在哪一行」是 per-mux**（DIAG/ORTH 各 8 种、R/L 各 24 种）。

文档：`v7re/steps/T53_PIP_ADDRESS_LAW.md` §7–§9。


## 93.1. 类内行序按段变化：否（负结果）+ 编码律定稿

按 8 段、按半段分别检验，段内仍有 2–4 种行序变体 → **类内行序的最小变化单位是族本身**，
不再由任何段号决定，属布线邻接事实。

编码律定稿（`v7re/steps/T53_PIP_ADDRESS_LAW.md` §11）：
class(S) 由名字判定 → 列由 (i//8) 奇偶决定（48/48）→ 行由类内成员序（per-family）
→ 位对/parity 闭式（48/48）→ 行帧 16+row / 列帧 col 码 / 行 18,19 用孪生位。

可计算：类判定、列、位对、parity、帧/字映射。不可计算：类内 4 条线谁在哪一行。


## 94.1. 编码律定稿文档（2026-11-08，收尾）

`v7re/steps/PIP_ADDRESS_ENCODING_LAW.md`（v1.0）：

- 5 条规则（方向类判定 / 列由 (i//8) 奇偶决定 / 列码=线长类别 / 位对闭式 / 位分配）；
- 「复用 = 行列寻址」的解释与两条推论（2 格歧义、4 格唯一）；
- 验证方法五条纪律 + 8 项证据链（含样本量）；
- 边界：类内成员序不可导出，等价于 tileconn（384 条）；
- 与 prjxray 的对比（1,536 条 → 384 条 + 5 公式）；
- 复现脚本清单。

编码规律这条线**收尾**。


## 95.1. 类内行序只有 8 种（4 块类 × 2 奇偶）

按行序序列分组，48 个族严格按 **i 的奇偶**二分，且块 1≡块 4、块 2≡块 3
→ **8 种行序**，不是 48 种（此前说的 8/24 种是"类"粒度，实际是块类×奇偶）。

用 8 个代表族预测整表：20/48 完全命中，块 3 全错（块类映射未定对），
其余多错 1 条。**结构成立，但整表尚未可算。**

文档：`v7re/steps/T53_PIP_ADDRESS_LAW.md` §12。


## 96.1. 更正：行映射 36 种（不是 8 种）；列码 744/744 零例外

- §12「8 种行序」只对 DIAG 单类成立；四类合并后按行映射分组 = **36 组 / 48 族**
  （仅 `i%8 ∈ {0,3}` 的族与 `i+4` 共用，其余各自独立）。该结论作废。
- 列码用 `(i//8)` 奇偶预测：**744/744 命中，零例外**——列完全可算。
- RapidWright 几何路线不可行：`pip_defs` 无几何字段（第 3 字段全 0），
  `Wire`/`PIP` 无坐标 API。

**最终边界：列/位对/parity/帧映射可算，行序是每族数据（36 种）。**

## 89.2. BRAM/DSP 并行采集 + BRAM 配置块实测（2026-11-08）

32 设计并发（RAMB18E1@RAMB18_X0Y1 + DSP48E1@DSP48_X0Y0，属性随设计变化）：

```
wall 226 s   ok=32 fail=0   (MAXP=32 / 44 核)
```

**BRAM INIT 位置（pair 实验，只差 INIT_00）**：64 个翻转位全部落在 **frame 48254, words 5–9**；尾部 frame 50176 word 1。

**BRAM 配置块跨度（span 实验，只差全部 INIT_00..3F）**：64 帧，**步长 2**，48254→48380，每帧同 words 5–9。

结论：
- `INIT_xx → frame = base + 2*xx`，words 5–9；已知 INIT_00@48254。
- **BRAM 配置块 ≫ 28 帧**（INIT 区就 128 帧）——推翻此前"BRAM/DSP = 28 帧"的推断；artix7 db 的 `frame_off 0..27` 只是互连 mux 子区。
- V7 的 BRAM/DSP mux **源名带器件前缀**（`BRAM_RAMB18_*`），与 artix7（`BRAM_CASCINBOT_*`/`BRAM_IMUX_*`）不通用 → 不能直接迁移，需自建 fuzz。

文档：`step03_pip/S17_BRAM_DSP_FLEET.md`；脚本：`E:\v7work\_harvest_bd.sh`、`_h3pair.sh`、`_h3span.sh`、`span_diff.py`。


## 97.1. 主文档更新到 v1.1（2026-11-08）

`v7re/steps/PIP_ADDRESS_ENCODING_LAW.md`：
- 边界章节重写为「36 种行映射」（更正 v1.0 的「8 种」）；
- 列码补全量复核 744/744；
- 新增「几何路线已排除」（pip_defs 无几何字段、RapidWright 无坐标 API）；
- 数据量对比改诚实版：1,536 条 → 576 条（约 2.7×），不再声称 384；
- 摘要第 3 条补反向结论；
- 文末加修订记录 v1.0 → v1.1。


## 98.1. 独立复算（T51 子任务）与主结论一致 + 一条新预测（2026-11-08）

子任务产出 `v7re/scripts/t51_generative_law.py`（`gen(tile_type, family, source, tile_y=None)`）
与 `v7re/steps/T51_GENERATIVE_LAW_CANDIDATE.md`；本地重跑退出码 0。

**支持主结论的数字**：
- 留出法（按 family 分组，留出 10 族 / 208 条）：**208/208 命中**；
- 全量 INT_L sense=1：mux 1,536/1,536、BEG+时钟树 1,992/1,992、composite 96/96、LV_L0 10 条，**合计 3,634/3,634，0 miss**；
- **8×3 与 4×6 候选：0/64 family** → 6×4 是唯一形态；
- **source→slot 不能由名字导出**：124 个源名中 122 个在不同 family 用多个槽位；
  `src_index` 行主序仅 10/1,536 命中、字典序仅 8/1,536 命中。

**与本文一致的边界声明**：该实现把 source→slot 作为 **routing-derived placement 输入**，
不声称它能被导出——与我 §5 的结论相同。

**新增可证伪预测**：`LV_L0` 缺失的位对候选为 `{(0,0,2),(1,0,6)}`，尚未实测。


## 99.1. LV_L0「补齐 2 条」判定：不需要跑，预测是假设的产物（2026-11-08）

用户要求验证 T51 留下的预测 `LV_L0 缺位对 = {(0,0,2),(1,0,6)}`。离线查完，结论是**不必跑 Vivado**：

1. `law_cells` 里 LV_L0 有 10 个源，二分结构为 X(4 格) × Y(3 格)、实测 10 条边；
   结构上缺的 2 条边是 `(0,0,2)+(1,0,6)` 与 `(0,0,9)+(1,0,6)`（**两条都以 (1,0,6) 为端点**），
   不是同一条边被算两次。
2. **routing 模板里 LV_L0 只有 9 个源**（`v7re/.../INT_L.json`，按 `(src,dst)` 正确分组），
   与 law 的差集是 `LH12`（law 多一条时钟树常量线）。
   即这 2 条边在布线图里**根本不存在** → 它们不是「缺失未测」，而是「不存在」。
3. 所以 K(4,3) 是过强假设；LV_L0 的真实规模就是 9（布线）/10（law 含 LH12）。

**顺带复核（重要）**：模板 `pip_defs` 字段序是 `(src, dst)`。按 `dst` 分组后
**172 族里 166 族源集合与 law 完全一致**，另 6 族正好是时钟族，各差 1 条 `LH*`/`LVB_*` 常量线：
`GFAN0/GFAN1` 15 vs 16、`LH0` 11 vs 12、`LVB_L0` 17 vs 18、`LV_L0` 9 vs 10、`LV_L18` 10 vs 12。


## 100.1. INIT 表跨 tile 类型验证（2026-11-08）

两构建法（INIT=0 vs 0xDEADBEEFCAFEBABE）在另外两个 tile 上验证：

| 目标 | 类型 | 结果 |
|---|---|---|
| `SLICE_X20Y20` | CLBLM_R（col 33，SLICEM） | **PASS** 46/46，missing 0，extra 0 |
| `SLICE_X8Y20` | CLBLL_L（col 16，SLICEL） | **FAIL** 13 缺 / 13 多 |

- 块基址必须取 `clb_blocks[(grid_col, y//50)]`（col33=31924、col16=31680），
  **不能用 `far_bands`**（曾因此误判一轮）。
- 同类型跨列 + L/R 左右均通用；T21 已证 SLICEM/SLICEL 也通用 → 排除资源类型因素。
- **CLBLL 布局不同**，且帧 XOR2 与帧镜像两种映射都试过并否决（9/9、7/7 不符）。

下一步：对 `SLICE_X8Y20` 跑 65 个单最小项建 CLBLL 表。

文档：`v7re/steps/T54_INIT_TILE_TYPE_CHECK.md`。


## 101.1. 对象澄清：主线是 PIP 开关盒，INIT 是另一回事（2026-11-08）

用户指出「我想测试的是同类 tile，现在做的不是 pip 开关盒吗」——判断正确。澄清两者的观测对象：

| 对象 | 位是什么 | 结论来源 |
|---|---|---|
| **PIP 开关盒（INT tile）** | mux 选择位（源→目的） | 主线：3,634/3,634、列码 744/744、位坐标公式 |
| **CLB 配置位（INIT）** | LUT 真值表 64 位 | T54：CLBLM 通用、CLBLL 不同 |

**同类 tile 的 PIP 可移植性已经用实测覆盖，不是待办**：
`_full8.bit` 一次解码 191 条 PIP，横跨 **76 个 INT tile（INT_L 70 + INT_R 6）**
（列 8/10/12/14/16/24/26/30/32、行 6/8/10/12/16/20），全部命中同一定律，
且该设计的位流→FASM→位流往返 **逐字节幂等**。

即：同类型 tile（INT_L）之间，PIP 的**相对位坐标与列码完全一致**，与列、行无关。
这与 CLB INIT 的情况形成对照——后者在 CLBLL/CLBLM 之间不同。

下一步若要更硬的同类-tile PIP 证据：选同一 family（如 `IMUX_L34`）在两个远距列上各构一个设计，
比对归一化后的格集合（判据仍是 missing=0 且 extra=0）。


## 102.1. CLBLL_L 的 LUT INIT 布局独立实测（2026-11-08）

T54 用 CLBLM 表预测 CLBLL 失败（13 缺/13 多）→ 本轮用 CLBLL 自己的 64 个单最小项构建重建。

- `SLICE_X8Y20`（CLBLL_L，col16，块基址 **31680**，`SLICEL.A6LUT`）；
- 64 个构建各只多 1 格、64 格互异；全在 **word 40**、帧 **31712–31715**（相对 **32..35**）、位 0..15；
- 验收：`INIT=0xDEADBEEFCAFEBABE` → 实测 46 位 / 预测 46 位，**missing 0 / extra 0**。

**与 CLBLM 对比**：相对帧 32..35、word 40、位域 0..15 **完全相同**；只有「索引 → (帧,位)」的排列不同。
⇒ CLB 的 INIT 布局 = **通用骨架 + per-tile-type 排列**，与 PIP 的「列码可算、行序固化」同形态。

产物：`v7re/steps/T57_CLBLL_INIT_LAYOUT.md`、`v7re/steps/clb_init_clbll_x8y20_a6lut.json`。


## 103.1. 计划 r1 收敛：T2b 由离线数据直接回答（2026-11-08）

计划的 T2b 问题是「同类型 tile 的 PIP 位坐标可否直接复用」。这个问题**已有实测答案**，不需要新构建：

- `verify_all_pip.py --tile-type INT_L`：**3,634 / 3,634 feature 全部精确命中，0 不符**。
  该脚本对每个 feature 用「族内公式算出的 (frame_off, parity, bit)」去核 `law_cells`，
  而 `law_cells` 是全器件 62,625 个 tile 的位集合 —— 即**同一 family 在不同 tile 里用同一组相对坐标**。
- `fasm2bit --decode _full8.bit` 一次解出 **191 条 PIP，横跨 76 个 INT tile（INT_L 70 + INT_R 6）**（列 8/10/12/14/16/24/26/30/32，行 6/8/10/12/16/20），
  且 FASM → 位流往返**逐字节幂等**（sha256 不变）。

结论：**同类型 tile 的 PIP 位坐标 = 块基址 + 族内相对坐标，可直接复用**；
不可复用的只有「族内行序」（36 种，per-family 固化）。


## 104.1. 计划 r2 收口（2026-11-08）

计划 wp-eb065939（同类 tile / PIP 开关盒）重规划 r2：T5、T6 因上游取消而撤销，其目标已由主 Agent 直接完成。
最终 3 项 done（T1 对象判定、T2b 同类型 tile 可移植性、T3 脚本盘点）。

本轮新增的两条实质结论：
1. **CLBLL_L 的 INIT 布局**：64 格全在 word 40、帧相对 **32..35**、位域 0..15，
   与 CLBLM **骨架相同、排列不同**；用 `0xDEADBEEFCAFEBABE` 验收 46/46（missing 0 / extra 0）。
2. **同类 tile 的 PIP 相对坐标可复用**：31 个跨 tile 组合 / 220 格反例 0；
   `_full8.bit` 一次解出 191 条 PIP 横跨 76 tile，与 Vivado 真值 190 命中 / 误判 0 / 漏 8（8 条为零位伪 PIP）。

统一结论：**地址 = 块基址 + 族/类型内相对坐标；不可复用的只有 per-family 行序与 per-tile-type 排列。**

## 105.1. 「两个一样的」指代解析：三条互斥候选（2026-11-08）

用户原句（status 101 末尾的实验提议）里的「两个一样的」有两种以上读法，锁错则机制解释作废。
逐条落成候选、判定条件与记录位置：`v7re/steps/T1_REFERENT_RESOLUTION.md`；复算脚本
`v7re/scripts/t1_referent_probe.py`（exit 0）。

| 候选 | 「两个」指什么 | 现状 |
|---|---|---|
| A | 两份远列设计的归一化格集合 | 待构建；同构现象已实测（T54:19 CLB 侧；T56:152-157 PIP 侧 14 tile→1 相对集合） |
| B | c08/c20 镜像对照里的两行 | 已实测：镜像下 2 行相同（rel34↔33、rel35↔32）、2 行不同 |
| C | 同一批位被两条 PIP 重复计入 | 已实测：law 库 1602 格按源展开成 8900 条（5.56×）；族内 src 撞车 0 |

关键事实（本轮复算）：

- 24 种 4 帧双射全枚举，唯一 missing=0/extra=0 的是 σ={32:34, 33:35, 34:33, 35:32}（4-循环
  0→2→1→3→0）；identity 13/13、XOR2 9/9、mirror(67-rel) 7/7，与 T54:37/:38 数字逐位吻合。
- 两张 INIT 表的 64 个索引 bit 差异 **0** 个，只有帧号映射 σ 不同 → B 的机制是 σ，不是镜像。
- IMUX_L34 在现有数据中**无跨列同源实例**（X32 四 tile 各绑不同源，X8Y20 绑 WR1END1）。
  故按 (family,src) 比，两列实验的共有键可能为 0（判据空洞）；按 family 比则两列不同。
  A 要可判定，构建设计须把两列 IMUX_L34 绑到同一条源线。

计数口径修正：本文件 101 节两处「76 个 INT tile（INT_L 70 + INT_R 6）」应为 **76 tile（INT_L 70 / INT_R 6）**。
行构成已拆开（`t2b_full8_decode.fasm`）：非注释行 **191 = 190 条 PIP + 1 条 CLB INIT**
（`SLICE_X12Y20.ALUT=0x0000000000000001`）；tile 数 **77 = 76 个 INT tile + 1 个 SLICE tile**。
即「191 条 PIP / 77 个 INT_L」是把两种外形相同的行（`tile.x=v`）按同一口径数成一批的结果，
与 §105 候选 C 同型——计数口径不声明，同一批记录就会出现两个不一样的数字。
统一写法：**190 条 PIP / 76 tile（INT_L 70、INT_R 6）**，CLB INIT 行单列。

## 107. 「两个一样的」因果说明固化（2026-11-08，接 §105 之后）

对象已锁死，结论与证据见 `v7re/steps/PAIR_IDENTITY_WHY.md`（复核日志 `v7re/steps/t5_recheck.log`，`EXIT=0`）。

**一句话**：「两个一样的」= 同一张**不含 tile 坐标**的 `(tile_type, family, src)` 格表被同一个解码循环套用到两个 tile 上；
编码层（`law_cells` 无 col/y/base，`v7re/scripts/fasm2bit.py:94-98`、`:113`）+ 口径层（解码只输出 `pats[s] == obs`，`:270-275`）
两层各自独立造成相同 → `missing=0 且 extra=0` 是**构造性恒真**，证明的是「表与位流自洽」，不是「两次独立观测吻合」。

**四种读法，四组答案（不可互相引用）**：

| 读法 | 实测 | 机制 |
|---|---|---|
| ① 单 family 归一化格集合（主答案） | L0 **0/31**、L1 **4/31**、L2 **31/31** | 表无坐标 + 解码恒等（29 对构造性；2 对跨 tile_type 真比较） |
| ② 整窗（全部 PIP 位） | **6/30** 组；跨列仅 1 对 Δcol=2 | 两端被编入同一 PIP 签名 |
| ③ c08/c20 镜像两行 | 2 行同 / 2 行不同 | 索引→帧映射 σ（4-循环），非镜像（T55:19） |
| ④ 同位重复计入 | 设计级 **0 格** | mux 互斥；模型级 5.57 条/格只是候选空间 |

**替代解释全部有反向实测**：过度坍缩（坍缩 0 对）、绝对坐标（0/240）、公式无关（0/30 vs 6/30）、
镜像（列镜像 0/30、bit 对偶 15.7%，且逐 tile 双射不可证伪，只能按奥卡姆作多余假设）、
「同 base ⇒ 同批绝对位」（18/18 两端 y 不同，L0 为 2/2 或 4/4）。

**对实验设计的含义（最重要）**：原设想的「远列各构一个 → 归一化 → 判据 missing=0/extra=0」**无法失败**；
有判别力的是 D1 绝对位全不同（0/31）、D2 只去列（4/31，全部同 y 跨列）、D3 全窗口残差 0（17 列）、
D4 错误归一化对照（0/30、0/30）、D5 跨 tile_type（107/107）。

**两处口径更正（本轮复算，未改他人产物）**：
1. `1602` 与 `1598` 是两种口径，不是一对一错：1598 = 格坐标去重；1602 = `(family,cell)` 对（差 4 = 3 个跨 family 共用格的多计）。
2. `pair_identity_check.md` §5.1 的 INT_R 行（1118/5444）不是 law 全量：`ref_stats` 未给 INT_R 并入 `m.law`，
   48 个 INT_R 独占 mux family（3456 引用 / 480 格）被 `cells_of` 返回 None 跳过；`8900−3456=5444`、`1598−480=1118` 算术吻合。

**未决**：远列正面实验仍未做（col8 vs col32 同一 `IMUX_L34` 源）；整窗跨列样本仅 1 对（Δcol=2）；
`IMUX_L34.WR1END1` 只有 col8 单端。详见 `PAIR_IDENTITY_WHY.md` §9。


## 108. family 是什么：名字来源核对（2026-11-08）

用户问：family 到底是什么、为什么不同 tile 都有同一个、是真实名字还是自己假设的。

**结论：名字是真的，分组概念是我们的。**

1. **名字来自 Vivado 自身**：`_full8.pips` 是 Vivado `get_pips -of_objects <net>` 的原始输出，
   里面直接出现 `IMUX_L34`、`IMUX_L5`、`BYP_ALT0`、`WW4BEG0`、`EE4END0` 等（该文件含 90 个 tile、145 个线名）。
   器件模板 `routing/out_routing/templates/INT_L.json` 的 `pip_defs` 目的线名集合共 **216** 个，
   同样含 `IMUX_L34`。→ **这些是 Xilinx 的线名，不是我们造的。**
2. **"family" 是我们起的分组词**：Xilinx 的术语是「PIP 的目的 wire / sink」；
   我们把「同一个目的 wire 的全部源 PIP」称为一个 family，属于分析单位，不是厂商术语。
   项目里 172 个 family 是 216 个目的线名中「有 site 连接 / 有实测位数据」的子集。
3. **为什么不同 tile 都有同一个 family**：`INT_L` 这个 tile 类型在器件里有 **26,550 个实例**
   （`law_tiles`，INT_R 同为 26,550）。每个实例内部都是同一张 216 条目的线的开关盒，
   所以 `(tile_type, family, src)` 是**类型级**名字，不是实例级。
   物理上每个 tile 各有一份独立配置位，只是布局相同 —— 同名 = 同一张图纸的复印件，不共享位。
   实测印证：同一 (family,src) 跨 tile 的**绝对落点 0/31 相同**（L0），
   去掉块基址后 4/31 相同（L1），再去掉行才 31/31（L2 恒等，构造性）。

## 109. family 定义澄清文档落盘（T4，2026-11-08）

澄清全文：`v7re/steps/family_definition.md`（定义 → 名字来源 → 跨 tile 同名机制 → 适用边界，每条断言带 `路径:行`）。
本节只记它相对 §108 的**三处新增/修正**，避免同一结论两处各说一半。

1. **名字真、切分词是我们起的（混合形态）**：字符串取自 Vivado 线名 —— `_full8.pips` 90 tile / 145 线名 / 100 dst，
   `templates/INT_L.json` 的 `pip_defs` 目的线 216 个、`IMUX_L34` 25 源；代码只做「前缀过滤+排序+原样写回」
   （`v7re/scripts/pip_reuse_law.py:36/68/107/242`、`v7re/export/law_db.py:314`、`step03_pip/gen_all_cells.py:39/49`）。
   反证：器件数据里 0 处 `family`（`templates/*.json`、`prjxray_ref/artix7/*.db` 实测），模板顶层键只有 `type/wires/pips/wire_defs/pip_defs`。
2. **§108 措辞修正**：172 族不是「有 site 连接 / 有实测位」的子集，而是「**有多源选择**」的子集 ——
   216 − 172 = **44** 个 dst 每个只有 1 个源，与 `law_ppips kind='always'` 的 44 条**集合完全相等**（单源无需配置位）。
3. **「两个一样的」分两层**（与 §107 同向，这里给定义层解释）：
   - 名字层：`law_cells` 无坐标列（DDL `v7re/export/law_db.py:37-46`）、`INT_L` 26,550 实例 → 同名是 schema 必然，不是巧合；
   - 格层：`cells_of()` 返回 `(frame_off,bit,parity)`、不含 tile 坐标（`v7re/scripts/fasm2bit.py:113-130`），归一化后相同是**查表恒等**，不是观测。
   有判别力的观测仍只有 §107 那组：458 预测格 0 落空 / 6142 其他源候选格 0 误亮 / 30 tile 窗口 0 残余（`v7re/steps/t3_run.log:129/130/164`）。

**适用边界（A3）**：INT mux family 相对格可跨 tile（同 tile_type）、绝对位不可、跨 tile_type 不可（116 同名 / 56+56 侧缀独有，`IMUX_L34`↔`IMUX34`）；
CLB site family 是 f-string 自造名（`step03_pip/gen_site_cells.py:49`，79 个名覆盖 4 个 CLB tile_type），不可当类型级用。

**未验证**：4 族（`LH0`/`LVB_L0`/`LV_L0`/`LV_L18`）有 5 条源在 law 有、V7 模板无（候选：artix7 与 V7 的器件差异；模板导出不完备），需全器件 `get_pips` 枚举判定。
### 20. S24：IO 入口拓扑补齐 → 6/6 输入网 token 级全对（2026-11-08）

按 S23 结论（IO_INT_INTERFACE/LIOB18 全单源、LIOI 多源家族仅时钟）向 `s13_solve.py` 图追加 96 条类型级固定连接（LIOI→IO_INT_INTERFACE(+1)、同 tile B_k→L_k、IO_INT_INTERFACE→INT_L(+1)/INT_R(−1)、LIOB18→LIOI(+1)），得 `s13_solve3.py`：9 网互斥、覆盖 98/181、1.8 s。对 Vivado ROUTE 真值逐 token 比对：A1/A2/A3/A4/A5/A6 **6/6 EXACT**（A5 真值文件尾部 `ER1BEG1 IMUX3 CLBLM_L_A2` 属同一引脚的第二条网，解码链在其前已止于 GFAN0）。报告 `step03_pip/S24_IO_WALK_CLOSURE.md`。


## 110. 所有 INT tile 是否同一套规则（2026-11-08）

判据：每个 INT 实例窗口（帧 `base+[0..25]`、字 `2*(y%50)` / `+1`）内每个置位位，
其 `(frame_off, bit, parity)` 必须在该 tile_type 的格宇宙（1,598 格）内。

| 样本 | 覆盖 tile | 窗口内置位 | 宇宙外 |
|---|---|---|---|
| 56 个 bitstream | 497 / 53,100（0.94%） | 11,771 | 9 |
| 广覆盖设计 `_tilecov/cov.bit`（200 LUT，16 列 × 14 行） | **3,167 / 53,100（5.96%）** | 13,680 | **2** |

残差归类：`(0,16,p1)` = T5 已知 GCLK 直通使能位（不在 `law_cells`）；
`(1,31,p1)`@`INT_R_X31Y97` 与 `(0,31,p0)`@`INT_R_X13Y25Y345` 类 = **PIP 数为 0 的 tile**，
`law_cells` 中 `(0,31)` 只有 parity=1 而不是 parity=0 → 非 mux 选择位。

**结论：规则统一。** 结构上 segbits 无 col/y 字段（同名套同一张表是数据模型必然）；
实测 3,600+ tile / 25,000+ 位只有 11 位在宇宙外，且全为表外直通/非 mux 位，无一处 mux 编码不同。
边界：覆盖率 5.96%，穷尽需铺满全芯片；表外位语义未建模。

文档：`v7re/steps/T57_INT_TILE_UNIFORMITY.md`。
### 21. S25：IO 固定连线补丁落盘 + 输出侧真实结构（2026-11-08）

- `step03_pip/tileconn_v7_patch.json`（**106 条**，kind=fixed）：LIOI→IO_INT_INTERFACE(+1) 24 条、B_k→L_k 24 条、→INT_L(+1) 24 条、→INT_R(−1) 24 条、LIOB18→LIOI 4 条、LIOI 内部 ILOGIC 通路 6 条。加载器 `step03_pip/tconn_v7.py`（`Graph().land_f/land_b`，prjxray tileconn + 补丁合并，可直接替换 walk/decode 里的散装 land 函数）。
- 远端实测 `get_pips`（`link_design -part xc7vx485tffg1157-3`，LIOB18_X81Y60/62/56/41 四个 tile）：**每个 LIOB18 tile 恰 10 条 pip，四 tile 完全同名同结构**（IOB_O0->>IOB_O_OUT0、IOB_T0->>IOB_T_OUT0、IOB_PADOUT0/1→DIFFI/MONITOR、IOB_DIFFO_IN1->>IOB_PADOUT1）⇒ LIOB 侧无可配置选择，pad 身份不由该 tile 的 pip 决定。
- 结构发现（tileconn 逐条验证）：一个 BEG 线在**发送 tile 上就唯一决定落点簇**，例如
  `NE6BEG0@INT_L_X30Y35 → LIOB18_X81Y41 / LIOI_X82Y41 / VBRK_X80Y41-42 / CLBLM_R_X31Y3x`（dy=+6）；
  `EE2BEG0@INT_L_X30Y59 → LIOB18_X81Y62 / LIOI_X82Y62`（dy=+3，与 o2 真值 IOB_X0Y59 一致 ✅）；
  `NE2BEG0@INT_R_X31Y51 → LIOB18_X81Y56(_0)/X81Y54(_1)`。pad 侧线名形如 `LIOB_<族>_<slot>`（NE4C0/EE2A0/NE2A0 等），slot=0/1 对应 tile 内两个 IOB site。
- 输出侧现状：o/o2/o3 三条网能走到 LIOB 线，但**终点 tile 与真值不完全一致**（o 真值 IOB_X0Y58∈LIOB18_X81Y60，o3 真值 IOB_X0Y60∈X81Y62，走线给的是 X81Y41 / X81Y56）。原因是类型级 land_f 对同一 BEG 返回整簇候选，未用 pad 身份约束。
- 结论：**pad 身份必须由 IO 配置块位决定**（S22 前的 iof 实验已证：换 pin 只改 `27322..27361` 中既非 fabric 的部分，且随带平移 base+74/+75）。下一步实验：12 pad（IOB_X0Y50..61）一热 fuzz → 解出 pad 选择的位编码 → 用它约束输出网终点，同时补齐 IOB 属性族（DRIVE/SLEW/PULLTYPE/IN_TERM 等，artix7 参考表里均有现成 feature 名可直接借）。


## 111. 线长编码律的外部检验（2026-11-08）

用**未参与定律推导**的广覆盖设计（`_tilecov/`，200 LUT，3,167 个 INT tile）检验 T53 的线长编码律：

规模：1,440 个 PIP 实例 / 237 个 tile / 43 个 family（SINGLE 399、DOUBLE 262）。

| 检验 | 结果 |
|---|---|
| A 名字一致性（预测列码的线长类别 == 源名长度） | **661 / 661 一致，0 反例** |
| B 位一致性（预测列帧格在真实位流为 1） | **648 / 648 = 100.00%** |

结论：**列帧位置可直接由「族编号段 + 源名方向类别」算出来，不需要查表**；
「DIAG/ORTH→双长线、R/L→单长线」的映射在新 tile 上零反例。

这是「所有 INT tile 同一套规则」的第二条独立证据链（第一条为格宇宙残差 11 / 25,000）。

边界：覆盖 237/53,100 tile（0.45%）；43/48 个 IMUX 族；`BYP_ALT`/`FAN_ALT`/BEG 不适用本律。

文档：`v7re/steps/T58_WIRELEN_VALIDATION.md`；脚本 `v7re/scripts/wirelen_check.py`。


## 112. 覆盖率 24.36% 的双检验（2026-11-09）

设计 `_tilecov2/`（800 LUT6，stride=90 等距铺 site，显式 `-part xc7vx485tffg1157-3`）。

| 检验 | 规模 | 结果 |
|---|---|---|
| 格宇宙残差 | 12,937 tile（24.36%）、64,326 位 | 宇宙外 **20（0.031%）** |
| 线长律 A（名字一致性） | 5,535 实例 | **0 反例** |
| 线长律 B（列帧置位） | 5,184 格 | **100.00%** |

残差 20 位全部 `parity=0`、`bit 30/31`、`frame_off 0/1`；**14/20 的残差 tile PIP 数 = 0**
→ 非 mux 选择位（长线直通/标记类），与「规则不一致」无关。

两轮合并：线长律累计 **5,832/5,832 全中**；宇宙外累计 22 位，无一例属 mux 编码差异。

文档：`v7re/steps/T59_COVERAGE_24PCT.md`。

## S26（2026-11-09）BRAM 三路 mux 位位置实测

- 锚点实验：`br_imux` / `br_attr` 同 site（`RAMB18_X3Y28` → tile `BRAM_R_X29Y70`，Y70，wof=40），只改 `WRITE_MODE_A`。
  差分只出 **1 个配置位**：`frame 27249, word 41, bit 24`；artix7 表对应 `RAMB18_Y0.WRITE_MODE_A_READ_FIRST 27_56`
  → `word = wof + bit//32 = 40+1 = 41`、`bit = 56%32 = 24` **完全吻合**。
- ⇒ **BRAM 控制块基址 = 27222**（该 tile，band1）：off26 → 帧 **27248**（60 个三路 mux），off27 → **27249**（30 个属性位）。
- 60 个三路 mux 在 (27248, wof=40) 判读：**60/60 合法码字，全部 IMUX（全零态）**；改 WRITE_MODE 不影响任何 mux（属性位与 mux 位池正交）。
- 缺口：`CASCINBOT/CASCINTOP` 显式态未观测到 —— 72K×1 设计里 Vivado 把深度选择做到 fabric，日志无 cascade；下一步用 `CASCADE_ORDER` 显式配对。
- 方法论教训：仅靠“某帧 60 家族全合法”扫描会出假命中（BRAM 行帧大量全零字天然满足 IMUX 码字），必须先用属性位锚定或差分定帧。
- 报告：`step03_pip/S26_BRAM_MUX_VERIFY.md`；v7_verified 98→101。


## 113. 表外位定向实验：长线假设未证实，但定位到系统性线索（2026-11-09）

**负结果**：`s_near`（LUT@X56Y101）vs `s_far`（LUT@X2Y101），都驱动 AF25，跨度差约 70 列；
差分 718 格，但 **bit 30/31 变化为 0** → 「长线经过置位」假设不成立。

**系统性线索**（800 LUT 设计，12,937 个被使用 tile）：

| 区域 | 被使用 tile | 置位数 | 残差 tile |
|---|---|---|---|
| 低半区 y%50<25 | 5,713 | 29,068 | **0** |
| 高半区 y%50≥25 | 7,224 | 35,258 | **20** |

残差行 `y%50 ∈ {29,33,42,45,46,49}`，全部在「字索引 +1 位移」区；
`law_cells` 中 `(0,31)` 只有 `parity=1`（`LH12` 族），而残差全是 `parity=0` → 正好差一次位移。

**判断**：残差是**高半区字位移的映射边界**（占高半区置位 0.057%），不是另一类特征位。
**下一步**：用 `y%50 = 24` vs `25` 两个 LUT 反查落点，确认位移是整字跳变还是逐帧跳变。

文档：`v7re/steps/T60_RESIDUAL_BITS.md`。

## S27（2026-11-09）BRAM 三态全实测 + INIT 布局

- **控制帧模型修正**：BRAM 控制字所在帧是**列块级**（同列同 band 共用一个帧），`word = wof(Y) + bit//32`。
  证据：`RAMB18_X3Y28`(Y70,wof40) 与 `RAMB36_X3Y17`(Y85,wof71) 的 WRITE_MODE 变化位都在 **帧 27249**，只有字不同（41 / 72），bit 都是 24。
- **三态全部实测**：`br_casc2`（64K×8 推断级联）tile `BRAM_R_X29Y60`(wof20) 帧 27248 →
  `ADDRARDADDR L0–L8/L10–L12` = `101`(CASCINBOT)、`L13/L14` = `110`(CASCINTOP)、其余 `000`(IMUX)；
  同一帧同一 wof 在 `br_imux` 上全部 IMUX。⇒ 60 个三路 mux 的码字律 `C = A & !B` 在 V7 完全成立。
- **INIT 布局（36 位宽）**：`INIT_00`→帧 46716，`INIT_01`→46717（步长 **1**），每个 `INIT_xx` 占 8 个字（256 位），窗口起点 = `wof(Y)`。
  注意：18 位宽旧测法得步长 2 —— **位宽模式改变 INIT 排布，两套公式不可混用**。
- 失败路径存档：2017.2 的 `RAMB18E1/RAMB36E1` 都没有 `CASCADE_ORDER_A` 参数；`RAM_EXTENSION_A` 手接级联被 `DRC REQP-193` 拦（加 LOC 也无效）→ 要 CASCIN 态就用“深度超容量”的推断法。
- 报告：`step03_pip/S27_BRAM_CASCADE_INIT.md`；v7_verified 101→104。

## 114. HCLK_CMT 跨类型验证（阶段 A）：时钟列没有自己的 FAR col（2026-11-09）

**目标**：判定 D 类最大一族（`HCLK_CMT`，42 mux / 982 PIP / 23.4 源每族）的 PIP 选择位能否像 INT 一样闭式公式化，并回答「编码律能否跨 tile 类型迁移」。

**文档**：`step03_pip/HCLK_CMT_LAW.md`（位池 / 结构 / 逐源表 / 六维对照 / 缺口）。

### 结论三条

1. **时钟 tile 没有自己的帧列。** `HCLK_CMT`/`CMT_TOP` 各 14 个实例（`grid_x` 88、305 各 7），但 `far_bands` 的 154 个 FAR 列里没有对应列；它们的配置位落在**相邻逻辑列块的尾部帧** `minor 26..29`（逻辑资源用 `0..25`）。证据：hclk5 观测帧 22144/22145/22147 FAR 解码 = `block0 top0 row4 col33 minor26/27/29`；hclk4 = `top1 row1 col33 minor26..29`。`grid_x` 88/305 不在任何 FAR col 的取值集合里。
2. **位池可表达**：cell 仍是 `(frame_off, word, bit)`，`frame_off ∈ {26,27,28,29}`，与 INT 的 `0..25` 不冲突。
3. **「源 → 槽位」不可公式化（本轮）**：`MUX_CLK_13` 48 源实测 13 个（MMCM 7 + PLL 6）。每个源 = 1 组槽位格 + 2–4 码字格；MMCM 组槽位在 `off29` word 26..30（长扫 `out/hclk_fields.json` 实测 5 个字带 `0xd800` 半区）、PLL 组在 `off28` word 76..79，均为 8 个一热槽位（高半 `bit 25`、低半 `bit 9`）；码字在 `off26/27` word 51，MMCM 占 bits 25..31、PLL 占 bits 4..6。**槽位到源名的对应无规律**（`MMCM8→(w27,高)`、`MMCM9→(w30,低)` 相邻编号跳到两端），只能查表。

### dst 由时钟区域固定（新增实测）

把 BUFH 强约束到同一时钟区域的不同站点（合法站点类型是 `BUFHCE`，MMCM `X0Y6` 区域内为 `BUFHCE_X0Y72..X0Y83`），重建 `BUFHCE_X0Y72 / 73 / 75 / 79 / 81` 五个位流：**`.pips` 的 HCLK PIP 全部是 `MUX_CLK_MMCM0 ->> MUX_CLK_13`，dst 不变**。
【推断】`MUX_CLK_k` 按时钟区域分配（485T 14 个区域 ↔ `MUX_CLK_0..13` 14 个），不是按 BUFH 站点；所以「同源换 dst」需换时钟区域才可能造出，而换区域会同时换列与 tile 类型。

### 与 INT 的差异（六维）

| 维度 | INT | HCLK_CMT |
|---|---|---|
| 源数/族 | 24（6 行 × 4 码） | 48 |
| 位池帧区间 | `frame_off 16..25` | `frame_off 26..29` |
| 槽位结构 | 行号 = 帧偏移（6 行 × 4 码） | 组槽位 8 一热 + 码字分区 |
| 合法码字 | 只有 `{1,2,7,11}` | 未见非法码概念 |
| 名字→槽位 | **100%**（1,024/1,024） | **否**（13/48 已测且无规律） |
| 与实例关系 | 全 26,550 实例相同 | 两个实例（X88Y338 / X88Y26）逐字节复现 |

### 器件核对

远端 hclk4/5/6 的 rpt/log 里 part 全是 **`xc7vx485tffg1157-3`**，本仓库是 `ffg1761`；但 14 个 `HCLK_CMT` 实例的 `grid_x/grid_y` 与远端逐条对应、差分落点解码后全落在合法段内 → 同 die、同 CRAM 布局（**间接证据**，待同一 dcp 在 ffg1761 重新 bitgen 做直接实证）。

### 过程记录（可能误导，故记录）

- 远端 python3.8 **无 numpy**，差分改为纯 python 大整数 XOR（自找 SYNC `aa995566` + Type2 count=5,067,776）。
- 差分里必然出现一批 `word == 50` 的格（hclk5 每源 4–22 格）：那是 **ECC 字随数据重算的副作用**，必须排除；排除后每源只剩 4–6 个数据格。
- `hclk6` 的 `c_b` 对 `c_a` 有 416 格、`p_i` 对 `c_a` 有 1,254+ 格且横跨 200+ 帧 → **`p_i` 对 `c_a` 不是受控差分**（两个设计本身不同），必须 `p_i` vs `p0`。

### 待办

- 剩 35 源（`CK_BUFHCLK*` 12、`CK_IN*` 10、`CCIO*` 4、MMCM 未测 7、PLL 未测 2）远端补测；判据：能否排成「6 组 × 8 槽」且组由源名前缀决定。
- 换一个 dst（如 `MUX_CLK_5`）测 1 个源，验证 14 个 dst 是否共用一套布局。
- ffg1761 直接实证（同 dcp 重新 bitgen）。

数据：`out/hclk_diff_raw.json`、`out/hclk_regions.json`、`out/hclk_mux13_cells.json`；脚本：`hclk_cells.py`、`_q_hclk_mux13.py`、`_q_hclk_a1c.py`、`_q_hclk_a1h.py`、`_remote_hclk_{diff,regions,pips}.sh`。


## 114.1. y24/y25/y26 实验：+1 位移确认正确；残差归因改为 BEG 长线层（2026-11-09）

`SLICE_X12Y{24,25,26}` 各一对构建（INIT 0 / 0xDEADBEEFCAFEBABE），实测：

| 行 | 预测 word | 实测 | 结论 |
|---|---|---|---|
| Y24 | 48 | (32..35, 48) | ✅ |
| Y25 | 51 | (32..35, 51) | ✅ |
| Y26 | 53 | (32..35, 53) | ✅ |

⇒ `word = 2*(y%50)+parity`（≥25 再 +1）**完全正确**，位移是整字跳变。
此前「位移边界导致残差」的解释**撤回**。

**残差重新归因**：20 个残差 tile 中有 PIP 的那些，全部指向 BEG 长线入口
（`SS2END->>SS2BEG`、`EE4END0->>EE4BEG0`、`SL1END->>SS2BEG`）；另 14 个 PIP=0 的位于长线穿越段。
⇒ 残差属 **BEG 长线段数/驱动类编码**（与 T32/T33 已知缺口同源），不是 mux 选择位。

文档：`v7re/steps/T60_RESIDUAL_BITS.md` §6–§8。

## S28（2026-11-09）DSP 78/78 三态家族 + FIFO18E1 属性位

- 方法：绝对态判读（全端口 tie0 / tie1 两个设计，读 artix7 预测位），不是逐族差分。
- DSP：`dsp_all0` 39/39 GND=1、VCC=0；`dsp_all1` 反之；`dsp2_all0/1`（双 site）**78/78** 全部通过，156 cell 零例外。⇒ ROUTING_SELECTION 的 D 形态从 5/78 提到 78/78。
- FIFO18E1（BRAM_R_X29Y70，帧 27249）：`EN_SYN`=(word45,bit11) 正码；`FIRST_WORD_FALL_THROUGH`=(word45,bit10) 正码；`ALMOST_EMPTY_OFFSET[0..12]` **13/13 = NOT(offset)**（取反编码：5→0x1FFA、6→0x1FF9、0x1FFA→0x0005、0x1FF8→0x0007）；`ALMOST_FULL_OFFSET[2..12]` 11/13 同上，bit0/bit1 语义未定（依赖 EN_SYN 与奇偶）。
- 新编码语义记录：FIFO 阈值属性是"取反码"，与 BRAM 正码、DSP 三态并列。
- 构建坑：FIFO18E1 无 IS_36_18/DATA_WIDTH 参数；ALMOST_EMPTY 下界 5（EN_SYN=TRUE 时 6）、ALMOST_FULL 上界 8185；FWFT=TRUE 且 EN_SYN=TRUE 被 DRC AVAL-7 拒；DSP CARRYINSEL[2]=1 需 PREG=1（DPREG-5）。
- 报告：`step03_pip/S28_DSP_FIFO_ABSOLUTE.md`；`v7_verified` 104→109。
- 远端产物：`/opt/lzh/step07/br6/`（10 个设计 + check6.py + cells.json）。


## 115. 22 个「表外位」结案：检验脚本漏了 +1 位移（2026-11-09）

根因：`v7re/scripts/all_int_tiles_check.py` 的窗口字计算漏了 `y%50 >= 25` 时的 `+1`
→ 高半区 tile 全部读「上一行」的字槽，把相邻行的位当成本行残差。

修复后：

| 设计 | 覆盖 tile | 窗口置位 | 宇宙外 |
|---|---|---|---|
| `_tilecov2/cov2.bit` | 12,565（23.66%） | 64,686 | **0** |
| 8 设计批量（cov/clsa×5/c0/c3/full8） | 3,231（6.08%） | 14,679 | **3** |

剩余 3 个全部是已知类：`(0,word41,bit16)` = GCLK 直通使能位（已建模 `GCLK_PASS_BIT`）、
`(1,word41,bit7)` = FAN 旁路位（T5 已记录，未接手）。

**作废**：T57/T59 的「宇宙外 9/2/20 位」全部作废（真实值 0）；§113/§114 的「BEG 长线」「位移边界」归因撤回。

**结论**：INT tile 的 mux/BEG 位语义 **100% 覆盖**（12,565 tile、64,686 位，零表外）。

文档：`v7re/steps/T60_RESIDUAL_BITS.md` §9–§11。


## 116. 交付报告 PIP_BIT_REUSE_REPORT.md（2026-11-09）

汇总 T53–T60 的成果写成正式报告：`v7re/steps/PIP_BIT_REUSE_REPORT.md`（215 行，v1.0）。

结构：摘要三结论 / §1 问题 / §2 数据与方法协议 / §3 复用位置与形态（三类结构、"为什么 6×4"、
列码=线长）/ §4 可计算公式 / §5 证据链 E1–E8 / §6 边界 / §7 工程可用性 / §8 与 prjxray 关系 /
§9 复现清单 / §10 方法学四条教训 / 附录术语。

**报告自带命令已全部实跑核对**：
```
pip_reuse_law.py --verify            → 1536/1536 精确命中，0 不符
verify_all_pip.py --tile-type INT_L  → beg 2098/2098，未覆盖 0，覆盖家族 172/172
all_int_tiles_check.py --bit cov2.bit → 12565 tile（23.66%）、64686 位、宇宙外 0、PASS
```

## 117. INT tile PIP 编码规律：完成度分档与公开工作对照（2026-11-09）

回答「INT 所有配置 PIP 规律找全了吗 / 有没有别人做同样实验」。产出文档 `step03_pip/INT_PIP_LAW_STATUS.md`，提示词 `step03_pip/PROMPT_INT_PIP_LAW_STATUS_V1/V2.md`（V2 增加三条纪律：三档分计、对比只谈数据形态、断言须可反驳）。

**三档分计（sense=1，INT_L，分母 3,634 feature = 172 族）**

| 档 | feature | 占比 | 内容 |
|---|---:|---:|---|
| 公式生成 | **2,816** | 77.5% | 24 源 64 族 1,536（`gen_mux.py` 0 差异）+ 20 源纯净 64 族 1,280（`gen_slots.py`） |
| 逐族表 | **736** | 20.3% | 20 源变体 32 族 640（列归属逐族不同）+ 复合 6 族 96（core+drops+extras 组模型，T35 96/96） |
| 未解 | **82** | 2.3% | 6 个长线族：`LH0` 12、`LH12` 12、`LV_L18` 12、`LV_L0` 10、`LVB_L0` 18、`LVB_L12` 18 |

**与 prjxray 的关系（只谈形态）**：其 `segbits_int_l.db` 是逐 PIP 枚举位表（`<tile>.<dst>.<src> <frame_off>_<bit>`，`!` 表示须为 0），一行一条 PIP；本工作是每族 3 个数值 + 16 条配置 + 32 张变体列表（约 6×10² 个数字）再由生成器展开。vx485t **无公开 segbits**（本地导出 `manifest.json` 的 `missing` 明写 `segbits_<T>.db (needs fuzz results)`），故同器件横评不可做，只能退到 artix7 同构对比（13/13 逐字节 MATCH）。

**可发表断言（可反驳）**：160/172 族的 PIP 选择位可由「每族 3 数值 + 16 配置 + 32 变体列表」直接生成，对 3,456/3,634 = 95.1% 的 feature 位级 0 差异重建；否证条件 = 任一 feature 生成失败或相差 1 位。三条攻击：单器件/单类型泛化、`law_cells` 自证循环风险（须引 T3 位流实测差分）、95.1% 中 640 条实为逐族表导致压缩比高估。

**下一步（按性价比）**：①把 32 个 BEG 变体族的列归属压成规则（640/640，半天，本地）②artix7 segbits 走同一生成器做同任务横评（2–3 天，本地）③跨类型/跨器件抽样（HCLK_CMT 目前只到「位池可定位、源→槽位 13/48 实测」，需远端）。

口径外：59 条 `VCC_WIRE` 常量输入 + 44 条直通（3,634 + 59 + 44 = 3,737）。


### S28 续（2026-11-09）ZFULL 模式偏置定死

9 个 FIFO 设计（fifo_a/b/c/d/e/f + fz1..fz4）→ **`ZALMOST_FULL` 存储 = 8191 − FULL（EN_SYN=TRUE）/ 8190 − FULL（EN_SYN=FALSE）**，13/13 位全部可逆；`ZALMOST_EMPTY` 两种模式都 = 8191 − EMPTY（无偏置）。
物理含义：异步模式读写指针多一级同步，阈值以 2 字为步长计数，编码整体左移 1。
证据表：FULL=4/6/7/0x1FF8/0x1FF9/0x0FFC 在两种模式下各读数（见 `step03_pip/S28_DSP_FIFO_ABSOLUTE.md` §3.1）。
⇒ ② 的 BRAM 属性面剩余：`CASCOUT_ARD_ACTIVE`(26,170)、`CASCOUT_BWR_ACTIVE`(26,172) 未测（需 FIFO36 级联设计），其余全部完成。`v7_verified` 109→110。

## 115.1. S29 半带边界探针：残差不是字位移伪影（2026-11-09）

问题（承 §113）：高半区 20 个残差位是否来自 `wof` 的 +1 位移边界（y%50=24 vs 25）。

设计：`yh24`（`SLICE_X10Y24`，wof=48）/ `yh25`（`SLICE_X10Y25`，wof=51），LUT6 INIT 相同、输出都钉 `PACKAGE_PIN AF24`（第一次未钉引脚，两版 IOB 落点不同 → 898 格全片噪声，作废）。

结果（994 格 / 113 帧）：全部可被 `clb_blocks` 解释，**offset 分布 2..8/11..13/15/17..19/22..25/32..35/38，其中 `off∈{0,1} 且 bit≥30` 的格数 = 0**。
⇒ 边界一对设计**不产生**残差型位；`wof` 的 +1 位移本身不引入不可解释位。

与 §113 的对照：残差行 `y%50 ∈ {29,33,42,45,46,49}`，不是边界行 25；且残差全是 `parity=0`，而 `law_cells` 中对应族 `(0,31)` 只有 `parity=1`（LH12）。
新判断：残差是**高半区"LH12 类长线标记"的 parity=0 副本**（同一族的第二字），不是位移伪影 —— 与"长线经过置位"无关，也与 word 跳变无关。

覆盖影响：0.031%（22/64,326 位），不影响任何 mux 解码；列为"未归属族"而非"错位"。

产物：`/opt/lzh/step07/br6/{yh24,yh25}.bit`、`dif.py`、`ydiff.json`（994 格）。


## 117.1. 尾部 CRC 被学习出来（2026-11-09）

新增 `v7re/scripts/crc_learn.py`、模型 `v7re/steps/crc_model.json`。

**方法**：不猜算法，改用「成对位流 + GF(2) 线性求解」——
`CRC(A) ^ CRC(B) = XOR_{p∈A△B} c(p)`，N 份文件给 C(N,2) 条方程。

**数据**：`_sb/` 65 份（INIT=0 与 64 个单最小项）→ 2,080 条方程、136 个位置。
**结果：32 个位平面各解出 64 个位置，矛盾方程 0。**

**留一法验证**：用 64 份建模型预测留出那份的 CRC —— `s01`/`s20`/`s40`/`s_base`
四例全部**逐位精确命中**（如 `6b5811ae` = `6b5811ae`）。65 份文件的 CRC 互不相同。

**意义**：不需要 CRC 算法也能精确算增量；与 ECC 模型同构，可直接接进 `bitgen.py`。
**边界**：当前只覆盖该设计的 136 个位置；跨设计泛化需把全部约 600 份位流纳入同一方程组。

文档：`v7re/steps/T60_CRC_LEARN.md`。

## S30 P2 寻址层（工程化，本轮定稿架构）

- 新模块 `v7re/tilemap.py`：`frame = block.base + frame_off`、`word = word_of(Y) + bit//32`、
  `word_of(y) = 2*(y%50) + (1 if y%50>=25 else 0)`；`tile_block(name)` 返回
  `Block(base_frame, frame_count, band, grid_col, source)`，`source ∈ {measured, derived}`。
- **架构定稿：measured 优先，derived 兜底。** 新表 `v7_law.sqlite.tile_blocks(tile_name,
  base_frame, frame_count, source)` 已灌入 **144 条实测**（来自 `s13_pips.json` 的 181 条
  tile→base 去重 + BRAM/DSP/IO 四个锚点）。未知 tile 才走推导。
- 12 锚点回归：**9 通过**。3 条“不通过”经复核是**锚点本身与实测表冲突**，不是代码错，
  且冲突可用命中数判定（在 `_s8v0.bit` 上跑整族匹配）：

  | tile | 候选 base | 命中族数 | 结论 |
  |---|---|---|---|
  | `INT_R_X7Y11` | 31680 | **12**（FAN_ALT7/CLK1/CTRL1/EE4BEG0…） | 31680 为真 |
  | `INT_R_X7Y11` | 31716 | 2（WL1BEG0/WL1BEG1） | 巧合 |
  | `INT_R_X23Y36` | 32232 | 1（SW6BEG0←SW6END0） | 巧合 |
  | `INT_R_X23Y36` | 32268 | 1（SW6BEG3←SW6END3） | **真**（S13 链一致） |
  | `INT_R_X11Y12` | 31716 | 1（SW2BEG3←WW2END3） | 巧合 |
  | `INT_R_X11Y12` | 31860 | 1（WW2BEG3←SW6END3） | **真**（A1 链一致） |

- 结构性结论：**tile→base 不是列号的简单函数**。三套列号（`tilegrid.grid_x`、`law_tiles.col`
  = 名 X、`clb_blocks.grid_col` = 帧块序列号）互不相等，且同一 INT 列在不同行会落到相差
  36/144 帧的块上（`INT_R_X7Y11→31680` 而 `INT_R_X7Y12→31716`）。⇒ 通用表只能**实测**，
  不能推。判定口径：候选 base 上跑参考 bitstream 的整族匹配，取命中数最多者；命中数相同
  则用走线链一致性裁决。
- 状态：**尚未接入解码器**（现有 `s13_decode.py`/`decode_clb.py` 路径不受影响）。
  下一步：把 `tile_blocks` 的 144 条扩到全部 26,550×2 INT tile（用同一判定口径批量裁决），
  再让 `decode_clb.py`/`emit_netlist2.py` 改走 `tilemap.tile_block()`。


## 118. BEG 段数（span）编码收尾（2026-11-09）

INT_L 96 个 BEG 族的编码规则已抽齐：

| 层 | 规则 | 覆盖 |
|---|---|---|
| parity | `idx // 2` | 96/96 |
| 位窗偏移 | `idx % 2 == 1` → +16 | 96/96 |
| 帧集 | span2 → `{6,9,10..15}`；span4/6 → `{2..7}` | 96/96 |
| 位窗 | span2 2 位（NW0 NN2 NE4 EE6 SE8 SS10 SW12 WW14）；span4/6 4 位（NW0 WW0 NN4 NE4 EE8 SE8 SS12 SW12） | 96/96 |

**仍是数据**：每族在其帧集×位窗内只占 9 格（A 侧 4 + B 侧 5），96 族子集全不相同，
无法由 span/方向/idx 推出。同窗口不同族（如 `NW6BEG0` 与 `WW4BEG0`）格交集为 0，互不干扰。

span 的物理含义：span2 = 8 帧×2 位，span4/6 = 6 帧×4 位 —— 帧与位两种资源的权衡。

文档：`v7re/steps/T61_BEG_SPAN.md`。

## 119. BEG 变体 32 族列归属收口：640/640 由名字推出（2026-11-09）

【数据事实】96 个 20 源 BEG 族中最后 32 个「变体族」（`EE4BEG0..3`、`WW4BEG0..3`、`NE6/NN6/NW6/SE6/SS6/SW6` 各 `0..3`）的列归属此前只能逐族查表；现在**全部由名字推出，640/640 条 (源→列) 0 差异**，INT_L 与 INT_R 各 32/32。

规则（实现在 `step03_pip/gen_slots.py::beg_variant_cols()`）：
- C0/C1：6 条 `len2` 按「轴 vs 斜」3+3；方向位 `b(D)`：{EE,NE,WW,SW} 轴进 C1，{NN,NW,SE,SS} 轴进 C0；`LOGIC_OUTS` 的 `L_i/L_{i+4}` 与 `L_{i+8}/L_{i+12}` 跟随同一方向位。
- C2：长线（4 行表，仅由族序号定）+ 方向桶表（4 桶）给出的 3 条长距离线。
- C3：余下 3 条长距离线 + `L≥16` 的两格（`16+((i+2) mod 4)` 与 `+4`）。

复算：
```
python step03_pip/gen_slots.py                 # [mux] 64/64；[BEG] 96/96，需回落 0（变体规则 32/32）
python step03_pip/gen_slots.py --tile INT_R    # 同（需线名归一：LOGIC_OUTS0→LOGIC_OUTS_L0、LV0→LV_L0）
```

三档账更新：公式 **3,456/3,634 = 95.1%**（原 2,816 = 77.5%）；表只剩复合 6 族 96 条；未解仍 82 条（6 个长线族）。

边界：只覆盖 `len2` 六线齐全的族；两张常数表（4+4 行）为什么按该桶分组【未测】；6 个长线族与 6 个复合族仍未进「公式」档。

详见 `step03_pip/PIP_REUSE_STRUCTURE.md` §14。


## 119.1. CRC 位置批量采集（2026-11-09）

新增 `v7re/scripts/crc_harvest.py`：从「单最小项」设计族里自动采集 `c(p)` ——
组内每个文件与基线差分，若只涉及 1 个数据位置，则 `c(p) = CRC(file) ^ CRC(base)`。

**采集结果**（7 组、446 份位流）：

| 组 | 文件 | 新增位置 |
|---|---|---|
| `_sb` | 65 | 64 |
| `_lk` | 64 | 0（与 `_sb` 同位置） |
| `_clbll` | 65 | 64 |
| `_t24` | 65 | 32 |
| `_sr4` | 65 | 64 |
| `_m2` | 65 | 0 |
| `_initbits` | 112 | 7 |
| 合计 | | **231** |

全部 231 个贡献值均非 0（先前一次采集全 0 是 bug：取到了末尾那个**常量** CRC 包；
正确做法是取**第一个** `0x30000001`）。

**LFSR 递推检验（负结果）**：对 208 对相邻位尝试 4 种 GF(2) 移位关系
（`x·` / `x⁻¹·`，两种多项式表示）→ **0 命中**。即 CRC 不是对 payload 做的教科书式 LFSR，
或它的覆盖区间包含非 payload 数据。

**覆盖上限的结构性约束**：N 份位流最多给 N−1 条独立方程，所以位置覆盖随
**独立设计数**增长，而不是随配对数增长。要覆盖全部 3,634 个 INT 格，需要约 3.6k 个设计。

文档：`v7re/steps/crc_positions.json`（231 位置），本条记入 STATUS。

## S31 INT tile 结构同质性 + 覆盖度普查（提示词执行）

报告：`step03_pip/S31_INT_TILE_UNIFORMITY.md`；提示词：`step03_pip/PROMPT_INT_TILE_UNIFORMITY.md`。

- **族集合上下文无关**（14 tile × 6 类位置：普通 CLB / BRAM 邻接 / IO 夹缝 / 跨 band /
  PCIE 邻接 / IO 邻接）：`get_pips` 全部 **3,737 pip / 216 族**，族名集合逐字节相同。
- **"216 vs 172" 是表定义差异**：多出的 44 族全是**单源常通抽头**
  （BYP_BOUNCE0-7 / BYP_L0-7 / FAN_BOUNCE0-7 / FAN_L0-7 / GCLK_L_B6..B11_EAST/WEST），
  源数均 = 1、无选择位；172 = 可配置族。
- **配置位覆盖 1,598/1,664 = 96.03%**；66 个缺口全在 **offset 0..3**，stride-4
  （off0/2 取 4k，off1/3 取 4k+3），与 offset 4..15 控制区同构 → 判为控制/时钟类，
  推断是 V7 多出的 GFAN/GCLK 档位（【推断，待验】）。
- **绝对态判读**（`_s8v0.bit`，142 个 INT tile）：unique **193**、ambiguous **0**、
  unexplained(有位=1 但无源匹配) **25**、all-zero 默认态 24,206。
- 基址覆盖仍 **142/53,100 = 0.27%**（S30 结论：不可推导）。
- 下一步：① 25 个 unexplained 定性 ② 66 缺口的最小实验（GFAN/GCLK 入口）③ 基址表按
  "命中数最多 + 平局看链"批量扩张 ④ artix7 侧验证"44 常通"是否通用。

### S31 修订（T4b）：命中数不是基址判别器

- 25 条 unexplained 全部是**半码**（一个应为 1 的胞为 1、配对的组/成员胞为 0），落在 offset 0/4/5/6/7，
  与 66 个缺口（offset 0..3，stride-4）**零重叠**；每胞在表中唯属一家族（非跨族共享）。
- **决定性反例**：把同一块 31680 当 `INT_R_X9Y11`/`INT_L_X8Y11`/`INT_L_X6Y11`/`INT_R_X7Y11`
  解，四者都得 **12 unique**。因所有 INT tile 家族位布局相同（T3 结论），匹配成功只证布局一致、
  不证基址正确。
- ⇒ 撤回 S30「命中数最多 + 平局看链」作为 INT tile 基址仲裁口径；T4 的 193 unique 降级为
  「布局一致性证据」；基址改由**列组成 + 块序号**推导，实测表转为校验集，验收用 `route_I*.txt`
  逐 token 复现（S24 的 6/6）。


## 120. 全部 tile 类型的 PIP 编码形状 + 可写范围 + 回归（2026-11-09）

新增 `v7re/scripts/tile_pip_lawscan.py`，产物 `v7re/steps/tile_pip_lawscan.json`（636 family，10 个 segbits）。

| tile | family | 源/族 | 格/族 | 每源格数 | 帧跨度 |
|---|---|---|---|---|---|
| INT_L | 172 | 21.1 | 9.3 | {2:2820, 4:816} | 10 |
| DSP_L | 79 | 5.5 | 5.6 | {1:428, 2:4, 3:4} | 2 |
| BRAM_L | 63 | 5.6 | 6.4 | {1:220, 2:130} | 1 |
| CLBLL_L | 2 | 338 | 324 | {1:632, 2:44} | 8 |
| CLBLM_L | 2 | 348 | 333 | {1:650, 2:45, 3:1} | 8 |

**分三档**：INT 必然多格（2/4 位）；BRAM 半 one-hot；DSP/CLB 基本 1 位 one-hot。
即「一条 PIP 几位」不是全局常量，而是**随 tile 类型变化**：只有 switch box 用二维行列寻址。

**回归**（16 目录随机 32 份位流，解码→回写→逐字节比对）：**OK 32 / 不符 0 / 异常 0**。

**下一步优先级**：DSP（验证 one-hot 成本最低）→ BRAM → CLB 站内 PIP。

文档：`v7re/steps/T62_TILE_PIP_SHAPES.md`。


## 121. T63 —— DSP48 PIP 编码实测（2026-11-09）

9 个构建（`/opt/lzh/v7re/work/dsppip3`，全部 `DSP48_X0Y138`）对照 CEAD/CEALUMODE/CECTRL/CED/CEM/CEP/CEC/CEINMODE。

**结果**：每次切换只动 1–2 格；两种形态 —— ①单格 one-hot（CEAD/CEALUMODE/CED/CEINMODE：0 态与 1 态各一格，位置不同）；
②零值默认（CECTRL/CEM/CEP/CEC：0 态有 1–2 格，1 态无格 = 缺省）。DSP 站点 = 帧 21488–21495（8 帧）。

**结论**：DSP 的 PIP 基本「一条一个位」，与 lawscan 预测 `{1:428, 2:4, 3:4}` 一致；不存在 INT 那种复用。

文档：`v7re/steps/T63_DSP_PIP.md`。

## S32 寻址层定案：块 = (列, band)，Y 只改 word（2026-11-09）

**实测（Y 差分，yA=Y20 / yB=Y24，其余全同，引脚钉死）**
- 两版 INIT 落在**同一组帧** `32428..32431`（块基址 32396 的 offset 32..35）；
- `yA` 只在 word **40**（=2×(20%50)）有 `0xf0f0`，`yB` 只在 word **48**（=2×(24%50)）有 `0xf0f0`，word 41/49（parity=1）全空；
- ⇒ `word = 2*(Y%50)` 直接实测；**Y 不改变块基址**。全片差异 31 帧（INIT 4 帧 + 布线 + IO 入口）。

**结构（每 band 帧预算闭合）**
- 每 band 恰 **5,180 帧**；块尺寸签名：
  - band 0/3/4/5/6：111×36 + 35×28 + 2×30 + 2×72 = 5,180（150 块）
  - band 1/2（含 PCIE）：105×36 + 35×28 + 1×30 + 2×72 + 1×246 = 5,180（144 块）
- 36=CLB 列块，28=BRAM/DSP/接口，72=IO 列，246=PCIE 区，30=边缘接口。
- 块基址 = band 起点 + 前缀和 ⇒ 每 band 只需 1 个锚点，其余全部可推导。

**144 条实测 tile→base 的复核**
- **138/144 恰好是块基址**；6 条例外：5 条落在 IO 72 帧块内部（`27354 = 27322+32`，INT_R_X33 的子窗口）、1 条 `31760 = 31788−28`。
- 规则预测（INT_L→东侧 gap 块否则西侧 CLB；INT_R→西侧 gap 块否则西侧 CLB）命中 **110/144**；剩余 34 条集中在"两 CLB 块相邻、INT 池落在其中一个"的列，需按列实测。

**下一步**：用"候选基址 + 活跃位落点"对 34 列做自动消歧（现有 7,901 份 .bit 与已解码活跃 PIP 足够）。


## 122. T64 —— BRAM PIP 编码实测（2026-11-09）

9 个构建（`/opt/lzh/v7re/work/bram4`，同一 RAMB36E1 站点）对照 ENARDEN/ENBWREN/REGCEAREGCE/REGCEB/RST×4。

**结果**：没有 1 格的族 —— EN/RST 类各 **2 格**（同帧 1019 的 word 13 与 16，两半区各一位）；
REGCE 类各 **4 格**（2 半区 × 2 帧：1012/1013 与 1016/1017），且 REGCE=1 时格**消失**（缺省态表示 1）。

**解读**：BRAM 的多位来自物理结构（一个 RAMB36 = 两个 RAMB18 半区），不是多源共享；
与 INT 的复用机制无关，**BRAM 也没有 PIP 复用问题**。

踩坑：空连接 `()` 触发 Synth 8-2543；`ADDRARDADDR` 最高位必须绑 1（DRC PDCN-135/136）；`CASCADE_ORDER_A` 在 RAMB36E1 不存在。

文档：`v7re/steps/T64_BRAM_PIP.md`。

## S33 块归属按列自动消歧（2026-11-09）

**做法**：不用命中数仲裁（S31 T4d 已证会退化），改用「族模式被解释的条数」——对每个候选基址，统计该 tile 上已知活跃家族里"恰好有一个源的全部位都匹配"的条数，按列（同列所有 Y 求和）取最大。

**结果**：35 个有活跃 PIP 的列中 **34 列唯一确定、1 列打平**（`INT_R` band1 x68：27122 vs 27150）。
样例（`v7re/blockmap.py` 的候选顺序 → 实测胜者）：

| 列 | 胜出基址 | 块类型 |
|---|---|---|
| INT_L 0/x17 | 31680 | clb 36 |
| INT_L 0/x21 | 31752 | clb 36 |
| INT_L 0/x37 | 31960 | gap28 |
| INT_L 0/x51 | 32168 | gap28 |
| INT_R 1/x85 | 27322 | io72 |

**结构含义**：INT 的 PIP 家族偏移集中在 0..15（IMUX 家族在 16..25），而 CLB 自身用 16..35 ⇒ **INT tile 与相邻 CLB 共用同一个 36 帧块**，不存在"每个 INT 一个块"。这解掉了"111 CLB + 35 gap 块 vs 222 个 INT tile"的数量矛盾。

**遗留**：①1 列打平；②需验证相邻 INT_L/INT_R 同块时其 cell 是否真的不相交（若相交则共享会引入歧义，须由 word/offset 分段解释）。

### S33 续：INT_L / INT_R 是否同一张表（实测）
- 两者各 **12,168 条 cell**，覆盖的 `(frame_off,parity,bit)` 坐标集合**完全相同**（1,598 个，重叠率 100%）。
- 但家族集合只共享 60/172（**112 个家族名只在单侧出现**），且共享的 116 个家族里 **0 个**两侧 cell 集合相同。
  ⇒ 不是同一张表的复制；是**同一套物理坐标、两侧各自命名/分配家族**。
- 抽样对比：`INT_L_X20Y40` 活跃 cell 9 个、`INT_R_X21Y32` 9 个，**交集 0** ⇒ 两侧同时占用同一块时当前样本不冲突。
- 结论（暂定）：**一个 36 帧块可同时承载相邻 INT_L/INT_R 两侧**（两侧家族私有、坐标池共享），这也解释了"111 CLB + 35 gap 块"对比"每带约 152 个 INT 列"的数量差。
- 待验证：构造同时激活 INT_L_X20 与 INT_R_X21 两处 PIP 的设计，差分后若只有 1 个块变化 ⇒ 共享成立；若 2 个不同块变化 ⇒ 各侧独占块。

### S33 续 2：列的配对规律（实测 34 列）
band0 已解列里 INT_R 基址大多 = 同侧 INT_L 基址 **+36**（X17/18 31680/31716、X21/22 31752/31788、X26/27 31824/31860、X31/32 31888/31924、X41/42 32024/32060、X46/47 32096/32132、X56/57 32232/32268、X61/62 32296/32332）。
**四处例外（两侧同址）**：31960、32168、32368、32568 —— 全是 **gap28 / io72** 块（31960 gap28、32168 gap28、32368 gap28、32568 io72）。这四块上 INT_L 与 INT_R 的消歧分数都独立取胜（8:0 与 7:1 等），不是噪声打平。

⇒ 规则：**普通列**两侧各占一个 36 帧块（相邻）；**gap 列**两侧共用同一个 28/72 帧块。

**未解冲突**：两侧表各 1,598 cell 且偏移都覆盖 0..25，共用 28 帧块在容量上放不下 ⇒ 二者必有一侧在该块内使用不同的 **word 子区间**（如一侧 word 0..49、另一侧 50..99）。这一条**未验证**，下一步实验：构造只激活 INT_L_X20 与只激活 INT_R_X21 的两份设计，各自与基线差分，看帧号是相差 36（普通列）还是同块不同 word（gap 列）。


## 123. T65 —— HCLK_CMT 48 源编码测量（2026-11-10）

13 个构建（MMCM CLKOUT0..6、PLL CLKOUT0..5，均 `-part xc7vx485tffg1157-3`）全部成功。
踩坑四条：`tail -5` 需 `-n 5`；BUFH 无独立站点（实为 `BUFHCE_X0Y72`）；
FF 必须与 CMT 同区域（`SLICE_X0Y349`）；缺 `create_clock` 会报 PDRC-29/38。

**PLL 系列干净可解**（以 p0 为基准，每份恰好 2 格）：
第一级 `bit = 25 + n//2`、`帧 = 22144 + n%2`（6 源 3 位 × 2 帧，零冲突）；
第二级在帧 22146 word 76..79、bit 6（偶 n）/22（奇 n），word 顺序 77,77,78,78,79,76，**映射未闭合**。

**MMCM 系列**（以 m0 为基准，2–3 格）：第一级同在 (22144/22145,51,25..31)，
第二级在帧 22147 word 27..30、bit 9/25。两级结构与 PLL 同构。

**边界**：48 源只测到 13 个；剩余 35 个（CK_BUFHCLK/CK_IN/CCIO/PLL6-7）在单区域设计里不被选中（T50）。
第二级未闭合 → 暂不能做「源 → 位坐标」正向预测。

**时钟 tile 的复用强度**（回答用户问题）：`CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1` 各 16 源仅用 8 格，
单格最多被 12 个源共用 —— 高于 INT mux（8–18 中位 5.56），是全芯片复用最密的一类。

文档：`v7re/steps/T65_HCLK_48SRC.md`。


## 124. 主线总报告 —— 全 tile 类型 PIP 位编码规律（2026-11-10）

产出 `v7re/steps/ALL_TILE_PIP_ENCODING_REPORT.md`（v1.0，11 章）：摘要三结论 / 术语与判据 /
INT 二维寻址（含列码=线长、行=角色、可计算公式、12,565 实例同规则性）/ BEG 段数编码 96 族 /
时钟族最密复用 / DSP one-hot / BRAM 半区配对 / 跨类型统计 636 family / 读写闭环 /
六条边界 / 四条方法学教训 / 复现清单 / 「复用到底怎么复用」一句话回答。

报告内三条命令已实跑核对（verify_all_pip 172/172 未覆盖 0、pip_reuse_law 1536/1536、
all_int_tiles_check 12565 tile 残差 0）。


## 125. T66 —— INT_L 与 INT_R 是同一套布局（2026-11-10）

`law_cells` 逐族对账（family 名去 `_L/_R` 后）：172/172 配上、**格集合 172/172 完全相同**、
格宇宙两侧都是 1,598 格且相等、每源格数分布一致 `{2:2818, 4:816}`、
同名 `(family,source)` 格集合 **3,586/3,586 零差异**。

唯一差异：`CLK0`/`CLK1`/`GFAN0`/`GFAN1` 四个时钟族的源带 `WEST`/`EAST` 后缀（物理走向不同），
去方向后缀后仍相同。

位流侧（更强）：`verify_all_pip.py --tile-type INT_R --normalize` → mux 336/0 不符、beg 408/0 不符。

结论：两侧同一套布局，解码前只需做线名归一化（去 `_L`/`_R`）。

文档：`v7re/steps/T66_INT_L_R_SAME_LAYOUT.md`。

### S33 续 3：L/R 同名对是同一个物理 mux（决定性）
把 181 条已解 PIP 按「(块基址, 该家族全部 cell 坐标)」去重：
- **181 → 140 个唯一物理配置**，41 组重复，**全部**是 `INT_L_Xn ↔ INT_R_Xn+1` 且**家族名、源名、cell 坐标完全一致**（例：`INT_L_X20Y15 NE6BEG0` 与 `INT_R_X21Y15 NE6BEG0` 都是 9 个坐标 `(2,0,5)(3,0,4)(3,0,5)(4,0,5)(4,0,6)(5,0,4)…`）。
- 41 组跨两侧，家族名无一例外相同 ⇒ **一对名字 = 一个物理 mux**。

据此定论块模型：
| 列类型 | INT_L 块 | INT_R 块 | 说明 |
|---|---|---|---|
| 普通列 | CLB 块（如 31680） | +36（如 31716） | 两侧各一个 36 帧块，物理上是相邻两个 SB |
| gap 列 | 同一块（如 32168、32368、32568） | 同左 | 一个 26 帧池被两侧名字共用，位只写一次 |

**口径修正**：覆盖率/验证计数必须按 (块基址, cell 坐标) 去重，否则同一个物理位被名字对算两次（181 vs 140，虚高 29%）。口径影响待重算：`s13_solve2` 的 98/181 是按名字计的，物理口径需把覆盖集合也去重后再算（分子去重后必然 <98），本条列为待办。


## 126. 主线报告 v1.1 —— 增补 §2.7 左右对称性（2026-11-10）

`v7re/steps/ALL_TILE_PIP_ENCODING_REPORT.md` 升到 v1.1：
新增 §2.7「INT_L 与 INT_R 是同一套布局」（172/172 格集合相同、3,586/3,586 同名源格集合零差异、
位流侧 mux 336 / beg 408 零不符），并把 §9 边界第 6 条改写为「只剩命名差异」。

### S34 INT tile 覆盖度体检（能否说"一块 tile 的所有 PIP 都覆盖"）—— 结论：不能

同一块 `INT_L` tile 两套数据对照（本地 `E:\v7work\pip17.tsv`，来自远端 `link_design` 后 `get_pips`）：

| 口径 | 家族数 | PIP 数 |
|---|---|---|
| 本项目表（artix7 segbits 迁移） | 172 | 3,636 |
| Vivado `get_pips` | 209 | 3,737 |

**配对交集 = 0**（(family,src) 对完全不相交）。原因不是精度，是**方向约定互补**：
- Vivado 侧：111 个 `*END*` 目的线家族（2,344 条 PIP，全部多源，如 `EE2END0` 32 源），`*BEG*` 目的线家族只有 2 个（50 条）；
- 本项目表：90 个 `*BEG*` 目的线家族（1,800 条）+ 82 个旁路/全局家族（1,836 条）。

⇒ **本项目只建了"段起点（BEG）"这一半的位表**；"段终点（END）"那一半（111 家族 / 2,344 条）没有位表，走线器把它们当作 tileconn 的**确定性落地**处理。

这解释了为什么单网场景能 6/6 精确（每块 tile 只有一条网，落地被到达线唯一决定），但这**不等于**覆盖了 tile 上所有 PIP；多网/扇出场景会出现真正的歧义。

**下一步判定实验**：取 `EE2END0`（Vivado 报 32 源），在真实 bitstream 上找它是否有配置位；若有 ⇒ 是缺口；若无（被线名唯一决定）⇒ 现有"落地固定"假设成立。


## 127. T67 —— PIP 覆盖盘点（2026-11-10）

全器件可配置 PIP 实例 **207,253,149**；**INT_L+INT_R = 95.7%**（各 26,550 实例 × 3,737 PIP）。
已覆盖：INT 172 family / 3,634 feature 100%、同规则性 12,565 实例零残差、左右对称 172/172、
GCLK 位与 BUFGCTRL 32 site。
未覆盖按规模：CLB 站内（5.7M 实例）、DSP（1.1M）、BRAM（1.0M）、CLK_HROW（2,840/型）、
HCLK_CMT 剩余 35 源、IOI/IOB、PCIE、GTX、CMT_TOP、CFG_CENTER、MONITOR。
结构性判断：INT 之外多为 one-hot（不复用），缺口代价小；仍有复用的只剩 HCLK_CMT 与 CLK_HROW/HCLK_*。

文档：`v7re/steps/T67_PIP_COVERAGE_GAPS.md`。


## 126.1. T68 —— CLB 站内 PIP 六构建对照（负结果，2026-11-10）

6 个构建（`LOCK_PINS {I0:A1..A6}`，回读 6/6 正确）差分按区域分类：

| 对比 | 总差 | INT 侧(0..25) | CLB 侧(26..71) | 块外 |
|---|---|---|---|---|
| a2 | 12 | 6 | 2 | 4 |
| a3 | 12 | 6 | 2 | 4 |
| a4 | 16 | 8 | 4 | 4 |
| a5/a6 | 32 | 14 | 2 | 16 |

**CLB 侧格在 a2–a6 中完全相同**（`(44,41,2) (49,41,3)`），不随引脚变化 →
LUT 输入选择完全由 INT 侧 IMUX 承担；`CLBLM_L_A <- A1..A6` 这 24 条 CLB 模板 PIP
**不是独立可配置开关**（属结构连线）。

未完成：BYP/DMUX/SR/CLK 四类 CLB 站内 PIP 未判（本轮未导 `.pips`）。

文档：`v7re/steps/T68_CLB_INTERNAL_PIP.md`。

### S34 续：EE2END0 判定实验（第一次失败，原因已定位）
- 设计：`e8`（u1@SLICE_X8Y20）与 `e10`（u1@SLICE_X10Y20），其余全同。
- LOC 确认生效（日志 `PRE u1 SLICE_X8Y20` / `SLICE_X10Y20`），两份 .bit 的 **md5 不同**，但 **FDRI 数据 0 位差异**，不同只有 ASCII 头 3 字节（构建时间戳）。
- 根因：`opt_design` 把两个 LUT6 优化掉了 —— 日志里 `place_design` 之后 `get_cells -filter {REF_NAME =~ LUT*}` 返回 **空**（PRE 有、POST 无），所以没有任何 LUT INIT 被写入，两份配置自然完全相同。
- 修法：源文件加 `(* DONT_TOUCH = "true" *)` 到实例上（不是只加在 wire 上），并在 tcl 里 `set_property DONT_TOUCH true` 双保险；重跑后再差分。
- 结论：本条实验**尚无结论**，不作推断。


## 127.1. T68 结论更正 —— CLB 站内 PIP 全部是伪 PIP（2026-11-10）

用 `prjxray_ref/artix7/ppips_*.db` 与 routing 模板逐名比对：

| tile | 模板 PIP | ppips | kind | 真 PIP |
|---|---|---|---|---|
| CLBLM_L | 151 | 151 | hint 58 / always 93 | **0** |
| CLBLL_L | 146 | 146 | hint 58 / always 88 | **0** |
| INT_L | 3,737 | 108 | default 64 / always 44 | 3,629 |
| BRAM_L | 974 | 794 | always 794 | 180 |

**CLB 两个 tile 的模板 PIP 集合与 ppips 集合完全相同，没有一条可配置开关。**
六构建实验（`LOCK_PINS I0:A1..A6`）里 CLB 侧无随引脚变化的位，原因就在这里。

BRAM 有 180 条真 PIP 尚未覆盖（前期只测了 8 个引脚开关）。

文档：`v7re/steps/T68_CLB_INTERNAL_PIP.md`（已重写）。


## 128. T69 —— BRAM 的 180 条真 PIP（2026-11-10）

BRAM_L 模板 974 条 PIP − ppips 794 = **180 条真 PIP**，全部是
`BRAM_ADDRARDADDR{L,U}n / BRAM_ADDRBWRADDR{L,U}n <- {CASCINBOT, CASCINTOP, IMUX}` 三源 mux，
共 60 个目的线。

prjxray A7 segbits 给出编码形状：IMUX=`000`、CASCINBOT=`101`、CASCINTOP=`110`（每 mux 3 位）。

**这些 PIP 在普通设计里就在用**：`_bramcasc/c0.pips` 里有
`BRAM_CASCINBOT_ADDRARDADDRU6->BRAM_ADDRARDADDRL6`、`BRAM_CASCINTOP_ADDRBWRADDRU9->BRAM_ADDRBWRADDRL9`。

V7 验证受阻：`RAMB36E1` 无 `CASCADE_ORDER_A/B` 参数；`RAM_EXTENSION=NONE` 时 `ADDRARDADDR[15]` 必须接 1
（DRC PDCN-135/136）。正确配方是「NONE + 15 位地址」对「LOWER/UPPER 堆叠两片」。

文档：`v7re/steps/T69_BRAM_REAL_PIPS.md`。


## 129. T69b —— BRAM 级联 mux 的 V7 实测受阻（2026-11-10）

- n1（单 RAMB36E1、NONE、36 位、`ADDRARDADDR({1'b1,addr[14:0]})`）构建成功，
  `.pips` 共 2,153 行，其中 **38 行是 CASC 类**，覆盖 **8 个目的线**
  （`CASCINTOP_ADDRARDADDRU9`、`CASCINTOP_ADDRBWRADDRU6/U9`、`CASCINTOP_ADDRBWRADDRU1` 等）。
  ⇒ 证明 60 个地址 mux 中至少 8 个在普通设计里落到 CASCINTOP 档。
- l1/u1（`RAM_EXTENSION_A=LOWER/UPPER`）两种写法都被 DRC 拒：
  `AVAL-96/97/98/99`（要求 READ/WRITE_WIDTH 为 1，改成 1 后仍报同一 DRC）。
  ⇒ `RAMB36E1` 无法用 `RAM_EXTENSION` 表达级联，级联必须用 **RAMB18E1 的
  `CASCADEINLATA/REG` 端口**（这正是 RAMB36E1 没有而 RAMB18E1 有的那一组端口）。
- 结论：BRAM 的 180 条真 PIP 结构已清、A7 编码形状已知（IMUX=000 / CASCINBOT=101 / CASCINTOP=110）、
  且在 V7 普通设计里确实在用；**V7 位号仍需一组 RAMB18E1 堆叠设计来测**。

## S35 —— 「以 Vivado get_pips 为标准」对账（2026-11-10）

Vivado 2017.2 对任意 INT tile 给出同一张清单：**209 家族 / 3,737 条 pip**（END 目的 111、BEG 目的 2、BYP/FAN/GCLK 等 96）；已抓 `INT_L_X6Y11`、`INT_R_X7Y12`、`INT_L_X8Y11` 三份逐字节同构（`E:\v7work\pip17.tsv`、`pip2.tsv`）。

本项目表 INT_L 侧 **172 家族 / 3,636 条**：BEG 目的 96 + 其它 76，**END 目的 0**。两份清单是同一 switch box 的两个开口方向（本项目=起段、Vivado=收段），共享名字的 26 个家族源集合也不同（如 BYP_ALT0：24 源 vs 2 源）。

**位级判定实验**（`/opt/lzh/step10/e3/e0..e7`）：同一 `LUT6@SLICE_X10Y20/A6LUT`、六输入并接 `din`，只改 `PACKAGE_PIN`（AF24/AP27/AN27/AP26/AP25/AN28/AM25/AP29）以改变到达的 END 线。变化格 90/0/90/0/98/16/90；**去重 19 个 (frame_off,bit) 全部落在本项目家族内，表外格数 = 0**（CTRL_L1 / LVB_L0 / LVB_L12 / NE6BEG0 / EE4BEG0 / SR1BEG_S0 / FAN_ALT0 / IMUX_L1 / IMUX_L2 / BYP_ALT4）。

⇒ Vivado 多出的 111 个 END 家族（2,344 pip）**不占配置位**（tileconn 固定落地）；本项目位表即该块可配置选择的完备集，「以 Vivado 为标准」在位级不新增任何位。副产物：帧内 `word 50` 随帧内容变化 ⇒ 帧级校验/ECC；e2/e4 与 e0 配置全同 ⇒ pad→track 非一一映射。

报告：`step03_pip/S35_VIVADO_STANDARD_CHECK.md`。遗留：66 个 offset 0..3 未覆盖 cell 本轮无命中；Vivado 2 个 BEG 家族与本项目 96 家族未逐一对应（不影响位表）。


## 130. T69c —— BRAM 级联档不可由 RTL 控制（2026-11-10）

- `RAMB18E1` 的完整 pin 列表（`get_pins -of_objects [get_cells u_bram]`，120 个）**没有任何 CASCADE\* 端口**：
  只有 DOADO/DOBDO/DOPADOP/DOPBDOP/ADDRARDADDR[13:0]/ADDRBWRADDR[13:0]/CLKARDCLK/CLKBWRCLK/
  DIADI/DIBDI/DIPADIP/DIPBDIP/ENARDEN/ENBWREN/REGCEAREGCE/REGCEB/RSTRAMARSTRAM/RSTRAMB/
  RSTREGARSTREG/RSTREGB/WEA[1:0]/WEBWE[3:0]。
- `RAMB36E1` 同样没有；`RAM_EXTENSION_A=LOWER/UPPER` 被 DRC AVAL-96..99 拒绝。
- 结论：**CASCINBOT / CASCINTOP / IMUX 三档是由工具按物理邻接自动选择的，用户侧无法用 RTL 属性或端口强制**。
  因此这 180 条地址 mux 的 V7 位号，不能靠「属性对照」测，只能靠「两个真实设计的位差」反推。

## 131. BRAM 180 条 mux 的可测路径（唯一可行）

思路：档位随「该地址位是常量还是来自 fabric」而变。
- n1（现有）：`ADDRARDADDR({1'b1, addr[14:0]})` —— 14 位全部来自引脚，工具给其中 8 个目的线选了 CASCINTOP；
- 新设计 n3：把高 6 位接常量（`{1'b1, 6'h00, addr[8:0]}`），低 9 位仍来自引脚；
- 差分后，凡 n1 有 PIP、n3 无（或反之）的 CASC 目的线，就是档位切换集；
- 再对两个 bitstream 做 BRAM tile 帧差分，得到这些 mux 的位（预期每组 3 位，与 A7 的 000/101/110 形状比对）。

副作用控制：n3 少了 6 个输入引脚，IOB 与部分 INT 布线会变；只看 BRAM tile 帧即可隔离。

## S36 —— 全量 ppip 记录（2026-11-10）

把「不占配置位的连接」统一入库：`v7_law.sqlite` 新表 **`ppips(tile_type,dest,src,kind,source,note)`，共 2,958 行**；导出 `step03_pip/ppips_all.json`（175 KB）与 `ppips_all.csv`（181,734 B）。

| tile_type | kind | 行数 | 来源 |
|---|---|---|---|
| BRAM_L / BRAM_R | always | 794 / 794 | artix7 `ppips_bram_{l,r}.db`（CASCOUT→ADDRARDADDR/DO 级联直通等）|
| DSP_L | always | 560 | **V7 实测**：`get_pips -of_objects [get_tiles DSP_L_X14Y0]` 的 638 家族里 560 个单源（ACOUT→ACIN 级联、IMUX 抽头）|
| CLBLM_L/R | always / hint | 93+58 / 93+58 | artix7 ppips（always=直通，hint=布线提示）|
| CLBLL_L/R | always / hint | 88+58 / 88+58 | 同上 |
| INT_L / INT_R | always | 44 / 44 | artix7 ppips：`BYP_BOUNCE0-7←BYP_ALT0-7`、`BYP_L0-7←BYP_ALT0-7`、`FAN_BOUNCE0-7←FAN_ALT0-7`、`FAN_L0-7←FAN_ALT0-7`、`GCLK_L_B6..B11_EAST/WEST←GCLK_L_B6..B11`；**note 标记 verified_by_v7_get_pips**（S34 的 44 个单源额外家族逐条对上）|
| INT_L / INT_R | default | 64 / 64 | `X.VCC_WIRE default`＝该家族“空源”默认态 |

三类语义：`always`＝恒连通（无法关闭，配置位不存在）；`default`＝无源时的默认驱动（VCC_WIRE 空源，对应本项目“隐含态”）；`hint`＝布线器提示，不是电气连接（CLB 输入名别名）。

配套导出：`E:\v7work\pip_inv_INT_L_X6Y11.json`（Vivado INT tile 清单 209 家族/3,737 条）、`E:\v7work\pips_dsp_q1.tsv`（DSP tile 794 条/638 家族）。


## 132. T69d —— n1/n3/n4 三设计对照：BRAM 地址 mux 位仍不可隔离（2026-11-10）

| 设计 | 地址接法 | CASC 目的线数 | 与 n1 的位差 |
|---|---|---|---|
| n1 | `{1'b1, addr[14:0]}`，14 位全来自引脚 | **8**（bit 6/9/14，CASCINTOP） | — |
| n3 | `{1'b1, 6'h00, addr[8:0]}`，只 9 个输入脚 | **0** | 1,427 格 / 164 帧 |
| n4 | 同 n3 但保留 16 个输入脚（高 7 位异或到 dummy 输出） | **8**（bit 3/7，CASCINTOP） | 2,553 格 / 223 帧 |

结论：
1. **档位确实随「该地址位是否可由邻接级联」而变**（n3 把 8 个 CASCINTOP 全变成 IMUX）；
2. 但位差被 I/O 与整条 INT 布线变化淹没（n1↔n3 1,427 格、n1↔n4 2,553 格，分布在行 0/1/5），
   **无法从中把 8 个 mux × 3 位 = 24 格分离出来**；
3. n4 说明工具会自己挑不同的地址位去走级联（n1 选 bit6/9/14，n4 选 bit3/7），
   用户侧既不能指定、也不能保持恒定。

⇒ BRAM 的 180 条地址 mux 在 V7 上的位号，**用属性/接线对照法测不出来**。
   可用的替代路线只剩：把 A7 的相对位形（每 mux 3 位、IMUX=000/BOT=101/TOP=110）作为假设，
   在真实位流上做「解码一致性」检验（例如取两个已知 BRAM 地址不同的设计，用假设位形解码后应能区分）。

## 133. T70：全 14 个 CMT 站点（MMCM/PLL）编码对照（2026-11-10）

- 站点：`MMCME2_ADV_X{0,1}Y{0..6}` 14 个、`PLLE2_ADV_X{0,1}Y{0..6}` 14 个、`BUFHCE` 168 个、clock region 14 个。
- 28 个设计（CMT→BUFHCE→FDRE）**全部构建成功**；每份 `.pips` 都出现 `HCLK_CMT_MUX_CLK_MMCM0/PLL0 ->> HCLK_CMT_MUX_CLK_13`。
- 差分（簇内归一化）：MMCM X0 列 4 个 site **30/30 全同**、X1 列 4 个 **30/30 全同**、跨列 4/30；
  PLL X0 列 6 个 site **292/292 全同**、跨列 0/292。
- 结论：编码 **per 列 + per 类型** 的常量，与 clock region 的 Y 行无关；全器件只有 4 套布局。
- 边界：PLL X1 列簇定位受孤立位干扰，暂不可信；未覆盖 `MUX_CLK_MMCM0..13` 各源的选择编码。
- 文档 `v7re/steps/T70_CMT_ALL_SITES.md`。

### 踩坑（可复现）

| 现象 | 根因 | 修法 |
|---|---|---|
| `DRC PDRC-34` VCO 500 MHz 越界 | `CLKFBIN` 接常量→`CLKFBOUT_MULT_F` 默认 5 | 加反馈环 + `CLKFBOUT_MULT_F(10.0)` |
| `DRC PDRC-43` 同上（PLL） | 默认 `CLKFBOUT_MULT=5` | `CLKFBOUT_MULT(10)` |
| `Place 30-124` BUFHCE 跨 region | BUFH/FF 交给 placer | 运行时按 region 取 BUFHCE/SLICE 并 LOC |
| `Place 30-575/172`（仅 X1Y0 两行） | 离时钟脚 AF25 太远 | `CLOCK_DEDICATED_ROUTE FALSE`（含 `clk_IBUF`） |

## S37 —— 用 7,987 个既有 bitstream 反推帧块结构（2026-11-10）

全量扫描 `/opt/lzh` 下 7,987 个完整 bitstream（160 GB，numpy 向量化 3 分钟）：**12,658 / 50,176 帧（25.2%）曾被写过**，16,800 帧带 word50。产物 `E:\v7work\step11_cnt.npy`、`step11_cnt50.npy`、`step11_summary.tsv`。

用 `clb_blocks` + 块间 gap 反推出完整块清单（新表 **`frame_blocks`**）：**1,038 块 / 36,260 帧 = 7 × 5,180 精确闭合**；类型 `clb` 763、`gap28` 245、`io72` 14、`edge30` 12、`pcie` 2、`x36` 2。每 band 尺寸签名：band0/3/4/6 = 111×36+35×28+2×30+2×72；band1/2 = 105×36+35×28+1×30+2×72+1×246；band5 = 110×36+35×28+1×30+2×72+1×36。

占用：clb **720/763**、gap28 236/245、io72/edge30/pcie/x36 全被用过；12,658 个非零帧中仅 **84 个（0.66%）** 落在清单外（band 间 66 帧 padding / fabric 之外）。

地面真值（新表 **`tile_block_gt`**）：4,467 个 bitstream 带唯一 `SLICE_XnYm` ⇒ 100 tile，按“块 offsets 32..35 被写过”投票，**45 个唯一命中**；同列跨 band 各命中一块且随 band 平移（X10 → 31716/5486/10732/26470/21224），X8=31680 与 X10=31716 相差 36 帧 ⇒ 相邻 CLB 列各占独立 36 帧块。

报告：`step03_pip/S37_BITSTREAM_BLOCKMAP.md`。未完成：45 锚点写回 `tile_blocks` 需先定 INT↔列 偏移；84 个清单外帧未定性。

## S38 —— INT tile 基址全量派生（INT_L→gx−1 / INT_R→gx+1，2026-11-10）

**规则（新，7/7 独立锚点验证）**：INT tile 与其相邻 CLB 列**共用同一个 36 帧配置块**。

- `INT_L_Xn`（tilegrid `grid_x = gx`）→ 取 `frame_blocks` 中 `kind='clb'` 且 `grid_col = gx−1` 的块（无则取 |gc−gx+1| 最近的 clb 块）；
- `INT_R_Xn`（`grid_x = gx`）→ 取 `grid_col = gx+1` 的块（同上最近邻回退）。

验证锚点（与旧 `tile_blocks` 无关的独立真值，全部命中）：

| INT tile | grid_x | 预测块 base | 真值 base | 来源 |
|---|---|---|---|---|
| `INT_L_X6Y11` | 17 | 31680 | 31680 | S24 走线 6/6 |
| `INT_R_X7Y12` | 18 | 31716 | 31716 | S24 走线 6/6 |
| `INT_L_X28Y51` | 72 | 27186 | 27186 | S13 解码 |
| `INT_R_X31Y51` | 78 | 27286 | 27286 | S13 解码 |
| `INT_L_X10Y11` | 26 | 31824 | 31824 | S13 解码 |
| `INT_L_X12Y19` | 31 | 31888 | 31888 | S13 解码 |
| `INT_R_X25Y40` | 62 | 32332 | 32332 | S13 解码 |

结果：**53,100 个 INT tile 全部派生成功（0 miss）**，写入 `tile_blocks`，`source='derived_gc'`；旧 144 条 `measured` 与之重叠 142 条、仅 **73 条一致** ⇒ 坐实旧 measured 表约一半是歧义解码产物（S33 结论的量化确认）。

结构自洽检查（同 Y 的 `INT_L_Xn` ↔ `INT_R_Xn+1` 块基址差）：36（12,100 对）/ 64（10,150）/ 0（3,250）/ 108（700）/ 66（250）/ 72（100）。含义：36=两侧各占相邻 clb 块；64=中间隔一个 gap28；0=两侧共用同一块（gap 列）；108/72/66=io72/pcie 区插入所致 —— 与 S34 的 L/R 结论一致。

遗留：4 个 band 的「INT 列数 − 块数」不闭合（band0/3/4/6 各 154−150、band1 148−144、band2/5 反而 144−144 与 150−150），说明还有少量列共享块的情形未逐一定性；但派生规则按 `grid_col` 就近取值，不依赖列计数，故不受影响。

产物：`v7_law.sqlite.tile_blocks`（53,102 行，其中 53,100 条 derived_gc）；`v7_verified` 117→118。

## S39 —— 53,100 条派生基址的实测可用率（2026-11-10）

在远端用 `/opt/lzh/venv/bin/python /opt/lzh/step11/vdec2.py`（all_cells.json 24,336 cell + tb_int.json 53,100 条基址）对 5 个真实 bitstream 逐 INT tile 判读：

| bitstream | 有配置位的 tile | 唯一命中家族 | 歧义 | 未解释位 | 有未解释位的 tile |
|---|---|---|---|---|---|
| fifo_a（BRAM+FIFO） | 71 | 186 | 0 | 72 | 30 |
| ia2_p1（DSP） | 458 | 919 | 0 | 674 | 255 |
| yA（纯 LUT 布线） | 17 | 35 | 0 | **0** | **0** |
| e0（单 LUT+8 引脚） | 23 | 59 | 1 | 10 | 1 |
| br_attr（BRAM） | 67 | 198 | 0 | 80 | 26 |

- **歧义率 ≈ 0**（5 个文件合计 919 级判读中只有 1 例），说明派生基址把“同一 tile 同一 family 多解”基本消灭了。
- 未解释位 offset 直方图：e0 集中在 **17..25**（IMUX 池，1+1+1+3+2+1 位）；br_attr 集中在 **2..14**（控制/BYP 区，4/6/10/14/4/6/4/14/10/2/4 位）。⇒ 两类都是**已知表缺口**：IMUX 由 tilepipe 表单独解（不进 all_cells），offsets 0..3 有 66 个未覆盖 cell。**没有出现“整块随机”的迹象**。
- 阴性对照（全部基址 +36 帧，读成邻列的块）：也在“合法”范围（yA 41 族/0 orphan、br_attr 434 族/4 歧义）⇒ **单靠码字合法性无法区分相邻块**；基址正确性依赖 7 个几何锚点 + 块清单闭合（S38），不依赖本项统计。
- 结论：53,100 条基址**可直接投入使用**；剩余误差全部落在已标注的两处表缺口内。

产物：远端 `/opt/lzh/step11/vdec2.py`、`vdec3.py`（带 orphan offset 直方图）、`tb_int.json`、`all_cells.json`；本地 `E:\v7work\vdec2.py`、`vdec3.py`、`tb_int.json`、`tb_int_s36.json`。

## 134. T71：CK_BUFHCLK 12 源编码（2026-11-10）

- 逼出条件：BUFH 时钟必须喂 MMCM 的 CLKIN1，才会出现 `CK_BUFHCLK<n> ->> MUX_MMCM_CLKIN1`（BUFH→FF 完全不经过 HCLK_CMT）。
- `MMCME2_ADV_X0Y6` 所在 region 的 12 个 BUFHCE（`X0Y72..Y83`）逐个替换 LOC，`CK_BUFHCLK` 序号 **12/12 与站点序号一致**。
- 位编码：半区 `(22146,48,21)`=0–5 / `(22147,48,21)`=6–11；槽位 `s0=(22146,26) s1=(22147,25) s2=(22146,25) s3=(22147,24) s4=(22146,24) s5=(22147,23)`；`序号 = 6×半区 + 槽位`。
- 形态与 INT mux 同构（两帧交替 + one-hot 槽位），槽位数 6。
- 未测：CCIO 4 源、`MUX_CLK_4..13` 链式 10 源、`MUX_MMCM_CLKIN1` 其余 18 源、跨区域槽位映射。
- 文档 `v7re/steps/T71_CK_BUFHCLK.md`。
- **环境坑**：`LANG` 非 C 时 Vivado 2017.2 直接 `Aborted (core dumped)`，报 `locale::facet::_S_create_c_locale name not valid`；所有远端脚本必须 `export LANG=C LC_ALL=C`。

## S40 —— S39 的 orphan 是解析器 parity 折叠缺失（已修，orphan 归零，2026-11-10）

**修正 S39**：`all_cells.json` 的 cell 用 `(frame_off, parity, bit 0..31)` 三元组，而比特流观测是 `(frame_off, bit 0..63)`（bit≥32 即 parity=1）。S39 的校验脚本直接拿 `bit` 去比 0..63 的观测键，**所有 parity=1 的 cell 全部匹配不上** → 那些“未解释位”不是表缺口，是脚本 bug。

修正方式：`key = bit + 32*parity`。用同一批 bitstream 重跑：

| bitstream | 有配置位 tile | 唯一命中家族 | 歧义 | **未解释位** |
|---|---|---|---|---|
| e0（单 LUT+8 引脚） | 23 | 33 | 0 | **0** |
| br_attr（BRAM） | 67 | 139 | 0 | **0** |
| yA（纯 LUT 布线） | 17 | 18 | 0 | **0** |
| fifo_a（BRAM+FIFO） | 71 | 129 | 0 | **0** |
| ia2_p1（DSP） | 458 | 877 | 0 | **0** |

合计 **636 个有配置位的 INT tile / 1,196 次家族判读 / 0 歧义 / 0 未解释位**。

另一个反直觉结论：**把 tilepipe 的 IMUX 表并进来是有害的**。`all_cells.json` 本身就含 **96 个 IMUX 家族 / 11,520 cell（offsets 16..25，48 mux/侧）**，与 tilepipe 表覆盖同一批位但源名不同；合并后歧义从 0 升到 4（e0）与 1（yA）→ **保持单表 `all_cells.json` 为唯一 IMUX 来源**，tilepipe 表仅作交叉验证用（S9 CSP 已验）。

结论：INT 侧解码现在是「全解释 + 零歧义」，53,100 条派生基址 + 单张 cell 表即可解任意 bitstream 的 INT 配置区。

产物：`E:\v7work\vdec4.py`（parity 折叠修正版）、远端 `/opt/lzh/step11/vdec4.py`、`all_cells_imux.json`（对照实验用，**不采用**）。

## S41 —— CLB 侧接入派生基址解码（2026-11-10）

新脚本 `E:\v7work\cdec.py`（远端 `/opt/lzh/step11/cdec2.py`）：用 `frame_blocks` 的 763 个 clb 块（键 `band:grid_col`）+ `clb_tiles`（75,900 条 slice→tile_type/grid_col/inst/y）+ `clb_cells`（3,884 特征 cell）逐 slice 判读，并按 `src_wire='INIT[NN]'` 重建 64 位 LUT INIT。

实测：

| bitstream | 命中特征 | 解出的 LUT |
|---|---|---|
| e0.bit（LOCK_PINS 身份映射，已知 INIT=64'h9E3779B97F4A7C15） | 158 | `SLICE_X10Y20/ALUT` = **0x9E3779B97F4A7C15（逐位完全一致）** |
| yA.bit（无 LOCK_PINS，两个 LUT） | 122 | `SLICE_X40Y20/ALUT` = 0x0000FFFF0000FFFF（与源 0x6996966996696996 **不符**） |

- **正面结论**：派生基址 + `clb_cells` 可以逐位复原 LUT INIT；e0 与设计真值 64/64 完全吻合。
- **两个待查问题**（已记录，不作推断）：
  1. 同一块里 `SLICE_Xn` 与 `SLICE_Xn+1`（inst0/inst1）**同时**解出相同 INIT ⇒ `clb_cells` 的 inst 区分或 slice→family 映射有重复，需用 `inst` 参与筛选；
  2. yA 不符大概率是**没有 LOCK_PINS 时 placer 交换了 I0..I5 引脚**（物理 INIT ≠ 逻辑 INIT），需先用 IMUX 解出引脚映射再还原逻辑 INIT。
- 结论边界：CLB 侧“能解”已证（e0），但“通解”还需修 inst 区分 + 引脚映射，二者都不涉及基址。

产物：`E:\v7work\cdec.py`、`clb_cells.json`、`clb_meta.json`（gzip 3.0 MB→406 KB 后推送，`ssh ... | pipe` 在远端 cmd 下不可用，需 `gunzip -f`）。

## 135. T72：CCIO 源（4 源）扫描（2026-11-10）

- 全器件时钟能力引脚 **96 个**（`get_property IS_CLK_CAPABLE`）；每个引脚一个设计（IBUF→BUFHCE→MMCM_X0Y6.CLKIN1→FDRE），24 路并发，96/96 成功。
- 只有 **8 个引脚**出现 `HCLK_CMT_CCIO<n>`：A 组 `C27/E27/C28/C30 → CCIO0/1/2/3`；B 组 `F11/E11/H10/G11 → CCIO0/1/2/3`（B 组走 `HCLK_CMT_L_X305Y338`）。其余 88 个走 `IO_INT_INTERFACE_*`，不进 CMT。
- 位编码：word 48 是 CK_BUFHCLK 字段（8 份全同）；**CCIO 差异在 word 49 / 51**（`(22144,49,28/31)`、`(22145,49,29/30/31)`、`(22144,51,27)`、`(22145,51,27/28)`、`(22146,51,25)`、`(22147,51,26)`）。
- 未解：CCIO 0..3 在 word 49/51 的精确位形（4 样本不足）；「哪些引脚能进 CCIO」由物理位置决定。
- 文档 `v7re/steps/T72_CCIO.md`。
- **坑（重要）**：`export LANG=C LC_ALL=C` 必须写在 shell 里，写进 `.tcl` 会导致 96 个设计静默全 FAIL（日志无 ERROR，只有 `locale::facet::_S_create_c_locale name not valid`）。

## 136. T72 更正：CLKIN1 源编码是「类别 + 索引」两部分（2026-11-10）

- 跨来源族对照（`_h48/m0` = `CLKIN1<-CCIO1` vs `_ccio_out/c02` = `<-CK_BUFHCLK0`）：word 48 在 CCIO 类别下置 `(2,48,22)`，在 BUFHCLK 类别下置槽位位 `(2,48,21)(2,48,26)`。
- ⇒ word 48 = **源类别字段**（不是 BUFHCLK 专用），word 49/51 = **类内索引**；T72 §3 的表述已收紧。
- 未定：n=2 类 + 4 索引不足以定形，需补 MMCM/PLL 类别样本。
- 文档 `v7re/steps/T72_CCIO.md` §7。

## S42 —— CLB 解码器修 inst 区分，yA 之谜澄清（2026-11-10）

修法：`clb_cells` 的 family 名形如 `SLICEL_X0.ALUT`，解码时必须用 slice 的 `inst` 过滤（`'_X{inst}.' in family`），否则 X0/X1 两个实例会同时命中同一批位。

重跑结果（远端 `/opt/lzh/step11/cdec3.py`）：

| bitstream | 命中特征 | 解出 LUT |
|---|---|---|
| e0.bit | 79 | `SLICE_X10Y20/ALUT` = **0x9E3779B97F4A7C15**（= 设计真值，64/64） |
| e7.bit（换引脚，同 INIT） | 81 | `SLICE_X10Y20/ALUT` = **0x9E3779B97F4A7C15** |
| yA.bit | 61 | `SLICE_X40Y20/ALUT` = 0x0000FFFF0000FFFF |

- inst 过滤后**每个 bitstream 只解出 1 个 LUT**（此前 X10Y20 与 X11Y20 重复），两个独立 bitstream 都精确复原真值 ⇒ CLB 侧解码链路成立。
- **yA 的结果不是错误**：yA.v 里 `u_src` 六个输入全部接同一个 `din` 网，综合折叠成常量 1；`u_dst` 的 I0=常量、I1..I5=din ⇒ 整条链退化成**单变量函数**，物理 INIT 必然呈 0x0000FFFF0000FFFF 这类“只依赖一位”的形态。日志证据：`INFO: [Opt 31-389] Phase Constant propagation created 1 cells and removed 2 cells`。
- 结论：S41 提出的“yA 基址或引脚映射有误”的怀疑**被推翻**，是设计本身退化。CLB 侧现在可对任意设计解 LUT INIT（含多 LUT）。

产物：`E:\v7work\cdec.py`（inst 过滤版）、`findbase.py`（块基址扫描器，用于“已知 INIT 反查块”）；远端 `/opt/lzh/step11/cdec3.py`。

## 137. T73：CLKIN1 源编码定形（CCIO 索引 8/8）（2026-11-10）

- 6 个对照设计（`_ck2/`，远端 `/opt/lzh/v7re/work/clkin2`）：`pin → IBUF → [BUFHCE/BUFG] → MMCME2_X0Y6.CLKIN1 → FDRE(SLICE_X0Y349)`；5/6 成功（`t1_direct` 因 `get_nets clk2` 不存在报 `[Common 17-55]`）。
- `t2(BHF0) vs t3(BHF5)`：簇内只差 **2 格** `(22146,48,26)` vs `(22147,48,23)` —— 独立复核 T71 的 6 槽位 one-hot。
- **CCIO 索引 = `(base+1, word 51, bit27)` + `bit28<<1`，8/8 精确**（`C27/E27/C28/C30` 与 `F11/E11/H10/G11` 两组、两个 CMT 列，簇帧 22144 与 25090 同一套位）。
- 类别字段（CCIO/BUFHCLK/BUFG）落在 word 48/49，3 类样本未能逐一解位。
- 文档 `v7re/steps/T73_CLKIN1_ENCODING.md`。

## S43 —— IMUX 引脚映射解码接入（2026-11-10）

新脚本 `imuxdec.py`：在 slice 所属 36 帧块内，用 `all_cells.json` 的 96 个 IMUX 家族（offsets 16..25）解出 **A1..A6 六个引脚各自被哪根线驱动**；引脚↔IMUX 家族用 S9 的 CSP 结果（`A1→IMUX_L7 / A2→IMUX_L2 / A3→IMUX_L1 / A4→IMUX_L11 / A5→IMUX_L8 / A6→IMUX_L4`）。

实测：

| bitstream / slice | 解出结果 |
|---|---|
| e0.bit / `SLICE_X10Y20` | **6/6 引脚全部命中**：A1←GFAN1、A2←FAN_BOUNCE7、A3←FAN_BOUNCE6、A4←BYP_BOUNCE1、A5←FAN_BOUNCE7、A6←WR1END2 |
| yA.bit / `SLICE_X40Y20` | 仅 A5←WL1END_N1_3（其余 5 脚为空）|
| yA.bit / `SLICE_X8Y20` | 全部为空（该 LUT 已被综合折叠成常量，无输入走线）|

- e0 的 6 个输入都接同一个端口 `din`，但**每个引脚走不同的物理线**（GFAN1 / FAN_BOUNCE7 …），因此 e0 能同时验证“6 个 IMUX 各自独立解出”。
- yA 的 `u_dst` 只有 A5 有源、其余 5 脚常量化 —— 与 S42 的“退化成单变量函数”完全一致（这是**第三条独立证据**）。

## 结论：位流解码器**不需要**做“物理 INIT → 逻辑 INIT”的还原

- 逻辑 INIT 只在“要与原始 Verilog 的端口顺序对齐”时才有意义，而端口顺序**不在位流里**（不写 LOCK_PINS 时由 placer 自由选择）。
- 只要引脚与 INIT 用**同一套物理顺序**（A6..A1）解释，函数的语义就是对的：把 LUT6 的 `.I0..I5` 依次绑到 A1..A6 驱动线、`.INIT` 用物理值，功能与原设计等价 —— 这正是 fasm2bels 一类工具的做法（它们也不还原原始端口序）。
- 因此网表发射器的正确形态：**`INIT=物理值` + `I0..I5 = A1..A6 的驱动网`**，并把 `pinmap`（A1..A6 → 源线）作为元数据保留。若确实需要对齐源码端口序，只能借助 DCP/源码，位流侧无解（信息不存在，不是算法问题）。

产物：`E:\v7work\imuxdec.py`；远端 `/opt/lzh/step11/imuxdec.py`。

## 138. T74：CLKIN1 类别字段定位（word 48 bit21/22）（2026-11-10）

- 想构造 MMCM 类源（`MMCM_X0Y6.CLKOUT0 → MMCM_X1Y6.CLKIN1`）：Vivado **拒绝**该拓扑，改为 `CCIO0 ->> MUX_MMCM_CLKIN1` + `MUX_CLK_MMCM0 ->> CK_IN0/MUX_CLK_0`（`_ck3/u1_mmcm2mmcm`，构建成功）。
- 意外得到干净对照：`t2`（CLKIN1 源 = `CK_BUFHCLK0`）vs `u1`（CLKIN1 源 = `CCIO0`），引脚/CMT 相同：
  - `t2`：`(base+2, word48) = bits[21,26]`（21=类别 BUFHCLK，26=槽位 0）
  - `u1`：`(base+2, word48) = bits[22,24]`（22=类别 CCIO，24=配套位未定）
- ⇒ **类别位 = word48 bit21（BUFHCLK）/ bit22（CCIO）**；MMCM/PLL 类在单 CMT 构造下不可达。
- 更正 T72：`u1` 与 `t2` 的 `(base+1, word49)` 完全相同（bits 21,26,29,31），故该字段属 `CCIO0->>MUX_CLK_13` 路径标记，不是 CCIO 索引。
- `u2_pll2mmcm` 失败：`PLLE2_ADV` 无 `CLKOUT*B/CLKFBOUTB` 端口；删后 `[Common 17-55]`（FF 落点为空）。
- 文档 `v7re/steps/T74_CLKIN1_CLASS_FIELD.md`。

## S44 —— 网表发射器 v0（结构层跑通，CLB 集成有 bug，2026-11-10）

新脚本 `E:\v7work\emit.py`：一次遍历同时解 INT 层（`all_cells` 家族→源）与 CLB 层（`clb_cells` 特征 + LUT INIT），输出 JSON。

实测（yA.bit）：

- **INT 层正常**：解出 16 个 tile 的选择，例如 `INT_R_X27Y20` = {`IMUX8→WL1END_N1_3`, `NE6BEG0→LOGIC_OUTS12`}，`INT_L_X28Y20` = {`WL1BEG_N3→SS6END0`}，`NN6BEG0←NN6END0` 链在 X31/X32 纵列上一串 —— 与 S24 的走线拓扑一致。
- **CLB 层返回空**：加“跳过全零模式源”的过滤（`if not ones: continue`，用于剔除 `PRECYINIT.C0` 这类默认态全零模式导致的满片假命中）之后，CLB 结果变成 `{}`。
  - 说明这是 **emit.py 的集成 bug**，不是数据问题：同一套 `clb_cells` + `clb_meta` 在 `cdec3.py`（S42）上能对 e0/e7 精确解出 `0x9E3779B97F4A7C15`。
  - 最可能的位置：emit 里 `meta['tiles']` 解包（`tt, gc, inst, y, band`）与 `decode()` 的 inst 过滤/`obs_of()` 参数在 CLB 分支上不一致，需逐行比对 cdec 的循环体。

结论边界：发射器的**INT 侧可用**，CLB 侧仍需一轮调试；距“任意 .bit → 完整 Verilog”还差：① CLB 集成修正；② 网线归并（把 INT 选择链追到 `LOGIC_OUTS` 得到 CLB→CLB 连接）；③ Verilog 文本输出（`LUT6 #(.INIT(物理值)) .I0..I5 = A1..A6 驱动网`）。

产物：`E:\v7work\emit.py`；远端 `/opt/lzh/step11/emit2.py`。

## 139. T75：用 INT 的观测法补 HCLK_CMT（19 设计 / 8 组合）（2026-11-10）

- 扫本地 143 份 `.bit`+`.pips`：**19 份**用到 HCLK_CMT，聚出 **8 种选择组合**（簇窗口 左列 22144..22157、右列 25090..25103，只看 word 48/49/51）。
- `MUX_MMCM_CLKIN1` 类别位样本从 2 升到 **107**：`(base+2,48)` bit21 = BUFHCLK（102 样本）、bit22 = CCIO（7 样本）。
- `CK_IN13` 6 个已知源（CCIO0..3、MMCM0、PLL0）给出 **6 套互不相同**的格 → 与 INT「行序 36 种」同类，属数据不是公式。
- **更正 T74**：`u1` 的 `.pips` 同时含 `CCIO0->>CLKIN1` 与 `CK_BUFHCLK0->>CLKIN1`，但其簇内格是 BUFHCLK 类 ⇒ `.pips` 会列同 mux 多候选边，不能单凭它判选中源。
- 文档 `v7re/steps/T75_HCLK_OBSERVE.md`。

### S44 续 —— 发射器 v0 修通（同日）

两个 bug 已修，`E:\v7work\emit.py` 现在两层都出结果：

1. **CLB 层返回空的真正原因**：LUT INIT 的 64 个源 `INIT[00..63]` 同属**一个家族**（`SLICEM_X0.ALUT`），每个源只有 1 个 cell 且**互斥性不成立**（一次配置置 1 的位有多个），我原先的 `len(s)!=1 → continue` 把整个家族丢了。改为“INIT 家族聚合、非 INIT 家族仍要求唯一”。
2. **默认态过滤**：加 `if not ones: continue` 剔除 `PRECYINIT.C0` 这类“全零模式”家族（它们在任何空块上都成立，会制造满片假命中）。

实测（三份真实 bitstream，全芯片一次遍历）：

| bitstream | INT tile 数 | 解出的 CLB |
|---|---|---|
| `yA.bit` | 16 | `SLICE_X40Y20/ALUT = 0x0000ffff0000ffff`（与 S42 的折叠结论一致） |
| `s8_v0.bit` | **100** | `SLICE_X8Y11/ALUT = 0x937b7471e799fac5`、`SLICE_X47Y51/ALUT = 0xc0c0c0c0c0c0c0c0`、`SLICE_X8Y11 SLICEL_X0.AFFMUX = O6` |

`s8_v0.bit` 的 INT 层与 S9 的 CSP 结果**逐个吻合**：`INT_L_X6Y11` = `IMUX_L7←SW2END3`(A1)、`IMUX_L2←WW2END0`(A2)、`IMUX_L1←WL1END0`(A3)、`IMUX_L11←SR1END1`(A4)、`IMUX_L8←GFAN0`(A5)、`IMUX_L4←WL1END1`(A6)，输出侧 `EE4BEG0←LOGIC_OUTS_L12`、`NE6BEG0←LOGIC_OUTS_L4` —— 与 S24 的 6/6 走线真值同源。

**仍未解出**：`AFF.ZINI/ZRST`（FF 类型位）本轮没进 `clb`，需单独查该家族的 `tile_type/family` 命名与 inst 过滤；网线归并与 Verilog 文本输出未写。

## 140. 总报告 v1.2：并入 HCLK_CMT（2026-11-10）

- `v7re/steps/ALL_TILE_PIP_ENCODING_REPORT.md` 280 行：摘要增第 4 条（HCLK_CMT 16/48 已解），新增 **§4bis**（字段账、结构结论、方法学教训），§9 边界补 HCLK_CMT 32 源 / BRAM 180 条地址 mux / CRC 覆盖 三项。
- HCLK_CMT 收口口径：16 源已解（BUFHCLK 12 槽位、CCIO 4 索引、类别位 107 样本），32 源**构造不可达**（链式 10 实测 0/264 设计；MMCM/PLL 类 22 被 Vivado 拒绝）。

## S45 —— 任意 .bit → 结构化 Verilog（v0.1 跑通，2026-11-10）

`E:\v7work\emit_v.py`（远端 `emit_v7.py`）在 v0.2 基础上补了三件事：

1. **FF 类型位**：`AFF` 家族的 `ZINI`/`ZRST` 是**两条独立位**（不是互斥源），原先把「匹配到 2 个源」当歧义丢掉；改为这两个源聚合记录 → `SLICE_X8Y11 SLICEL_X0.AFF = ZINI+ZRST`（= FDRE，INIT=0）。
2. **引脚→INT tile 定位**：用 `slice_tile.json`（75,900 条 site→tile，来自 `v7_model.sqlite.sites`）+ `tilegrid.json` 求邻接。实测邻接关系是 **CLB 的 gx+1 = INT_L，gx+2 = INT_R**（`CLBLL_L_X6Y11`(gx16) → `INT_L_X6Y11`(17) / `INT_R_X7Y11`(18)）；于是每个 slice 的 A1..A6 取相邻 INT tile 里 `IMUX_L7/L2/L1/L11/L8/L4` 的选择结果。
3. **Verilog 文本输出**：`LUT6 #(.INIT(物理值))` + `.I0..I5` 依次绑 A1..A6 驱动线 + 注释保留 pinmap / D-src / FF 类型。

实测 `s8_v0.bit`（真值已知的设计）输出 `step03_pip/recovered_s8_v0.v`：

- `u_SLICE_X8Y11` INIT=`0x937b7471e799fac5`，`.I0..I5` = `SW2END3 / WW2END0 / WL1END0 / SR1END1 / GFAN0 / WL1END1` —— **与 S9 CSP、S24 走线真值逐个一致**；
- `u_SLICE_X47Y51` INIT=`0xc0c0c0c0c0c0c0c0`，其相邻 `INT_R_X31Y51` 活跃 IMUX 解出 `IMUX0←NW2END0`、`IMUX3←ER1END1` —— 与 S15 的 `A3=IMUX_L0←NW2END0`、`A2=IMUX_L3←ER1END1` 对应。
- 命名差异：**INT_L 侧 IMUX 家族名带下划线（`IMUX_L7`），INT_R 侧不带（`IMUX0`）**，inst1 的引脚映射表要与 inst0 分开维护（S7 已知 X1 形态不同）。

仍未做：① inst1 的 A1..A6→IMUX 映射表（现在只报“哪些 IMUX 活跃”）；② 跨 CLB 的网线归并（把 `w_*` 追到 `LOGIC_OUTS` / IO 入口，得出 CLB→CLB 与 pad→CLB 连接）；③ FF 实例化（D 源已解出 = AFFMUX 的 O6，CE/SR/CLK 的 mux 位尚未解）。

## 141. T76：CRC 全位置覆盖——现有语料做不到（2026-11-10）

- 新增 `v7re/scripts/crc_solve_all.py`：967 份位流按目录分组，组内选「置位格最少」者为基准，方程 `XOR_{p∈A△B} c(p) = CRC(A)^CRC(B)`，按 32 位平面 GF(2) 消元。
- 结果：方程 895、位置 44,867、秩 760、**无矛盾**、解出 31 个签名、留出 0/5 —— 系统严重欠定。
- 根因：语料里**没有任何一对只差 1 个数据位**（最小差分 14 格；`_sb` 22、`_clbll` 16、`_t24` 20、`_initbits` 48）。T60 的 231 位置来自当时那批「差分=1」的文件，现已不在本地。
- 成本估算：要覆盖 3,634 个位置需 ~3,634 对单比特位流 ≈ **2.7 小时机时**（84 s/构建、32 路并发），且必须 `LOCK_PINS` + 固定 LOC/BEL + 显式 `-part`。
- 文档 `v7re/steps/T76_CRC_COVERAGE_LIMIT.md`。

## 142. T77：清除位（sense=0）与 4 个「异常族」定案（2026-11-10）

- 4 族「异常」撤销：`segbits_int_l.db` 原文就有 `INT_L.LH0.LH12`、`INT_L.LV_L0.LH12`、`INT_L.LV_L18.LH0/LH12`、`INT_L.LVB_L0.LVB_L12` —— prjxray 声明的跨时钟树源，routing 模板无此边属口径差。172 族里 168 族与模板全等。
- `sense=0` 共 6,528 行（INT_L/INT_R 各 3,264），INT_L 去重 **280 格，全部 ⊂ sense=1 格集** ⇒ 无独立清除位；写入器「族内清空再置位」已覆盖。
- 一次切换构建（`_sw1` 引脚驱动 vs `_sw2` LUT 驱动）差分 28 移除 / 110 新增，变量不唯一，**不作清除测试**；清除正确性由 T8b（c0→c3 改写 50,172/50,176 帧相同）覆盖。
- 文档 `v7re/steps/T77_ZERO_BITS_AND_ANOMALY.md`。

## 143. T78 混合设计复验（2026-11-11）

用「60 LUT + 8 DSP48E1 + 4 RAMB36E1」的混合设计测 INT 格宇宙盲区（此前全部检验只由 LUT 设计驱动）。

- `_mixed/mixed.bit`：覆盖 23 个 INT tile、1,824 个窗口位；
- `all_int_tiles_check.py` 原始判定 **FAIL（8 个宇宙外格）**；
- 8 格聚成 5 个签名，全部是**已知的非族级控制位**：`(0,16,p1)`=GCLK 直通使能、`(1,3,p0)/(1,7,p0)/(1,31,p0)`=BYP/FAN 旁路控制位；
- 加入这 4 类白名单后：`_mixed` 残差 **0**、`_tilecov2` 残差 **0**。

结论：INT 规律在混合设计上仍成立；「残差 0」必须写成「宇宙 = law_cells ∪ 4 类非族级控制位」，否则会报假阳性。
BRAM 站点筛选未生效（`SITE_TYPE =~ "RAMB36*"` 未匹配），BRAM 由工具自由放置，未做定向验证。
文档 `v7re/steps/T78_MIXED_DESIGN_CHECK.md`。

## 144. 控制位白名单固化（2026-11-11）

`all_int_tiles_check.py` 内置 `CONTROL_BITS` 并在载入宇宙时并入，共 6 个签名：
`(0,16,1)`=GCLK 直通使能；`(1,3,0)/(1,7,0)/(1,31,0)`=BYP/FAN 旁路 parity 0；`(1,3,1)/(1,7,1)`=同族旁路 parity 1。

固化过程抓到 2 个"已知但从未登记"的位（`_c3.bit`/`_c4.bit` 的 `INT_L_X8Y20 (1,7,1)` 与 `(1,3,1)`，T5 曾记录但未接入）。

12 个来源不同的位流复验：**覆盖 12,958 tile（24.40%）、69,626 位、残差 0、PASS**。

## 145. CRC：结构三否一存 + 可用的增量工具（2026-11-11）

新造 65 个单最小项位流（`SLICE_X12Y20/A6LUT` + `LOCK_PINS`），**64/64 单格**，得 64 条签名写进 `v7re/steps/crc_table.json`。

结构假设：H1「线性于位置」否定（矛盾 918）、H2「帧内相邻位固定映射」否定（矛盾 480）、H3「与帧无关」否定（同 0/异 16）、**H4「跨帧 3232 位固定映射」幸存（48 对，矛盾 0）**。

新增 `v7re/scripts/crc_delta.py`：按帧/字/位差分、跳过 word 50、查表增量重算 CRC；未知位置默认拒绝写出。
端到端：`_full8_i3` 回退 CRC 后再修 → 与 Vivado 原文件**字节级相同**。

边界：覆盖 64/3,634（1.8%）；全覆盖约 3,634 构建 ≈ 2.7 小时；硬件是否校验该 CRC 未验证。

## S46 —— law_ctrl（非族控制位表）+ 全 tile 类覆盖审计（2026-11-10）

### 1. 新表 `law_ctrl`（132 行 = 66 格 × 2 侧）
`v7_law.sqlite.law_ctrl(tile_type, frame_off, bit, parity, name, evidence, date)`：登记 INT 位空间里 `law_cells` **不覆盖**的 66 个坐标（每侧 26×2×32=1,664，`law_cells` 覆盖 1,598 = 96.03%）。

已定性 6 条（其余 60 格 name 为空，待测）：

| 坐标 | 名称 | 证据 |
|---|---|---|
| (0,16,parity=1) | `GCLK_PASS_EN` | 8-DSP 混合设计 + `s8_v0`（同样点亮） |
| (1,3,parity=0) | `BYP_FAN_BYPASS_1` | 混合设计 |
| (1,7,parity=0) | `BYP_FAN_BYPASS_2` | 混合设计 |
| (1,31,parity=0) | `BYP_FAN_BYPASS_3` | 混合设计（3 次） |
| (1,3,parity=1) | `BYP_FAN_BYPASS_1_P1` | `s8_v0` 实测 |
| (1,7,parity=1) | `BYP_FAN_BYPASS_2_P1` | `s8_v0` 实测 |

**结构规律**：off0/off2 = bit≡0 (mod 4) 各 16 格；off1/off3 = bit≡3 (mod 4) 各 16 格；另 off0 bit31、off1 bit30/31、off3 bit31。两条正交 stride-4 位线 × 两个 word(parity) ⇒ 8 组 × 16 位的使能阵列。

**语义**：这些是 **1 位 = 1 个开关**的门控位（GCLK 直通使能、BYP/FAN 旁路），不是 N 选 1 的 mux 家族，故键 `(family, src_wire)` 容不下它们。为什么以前的纯 LUT 实验里不出现：Y 差分/e0–e7 无时钟、不碰旁路；`s8_v0`（有时钟）在 `INT_L_X6Y11` 就点亮了 (0,48)(1,35)(1,39)。

### 2. 全 tile 类覆盖审计（`E:\v7work\audit_cells.py`，远端 `audit2.py`）
对每个 bitstream 遍历 `frame_blocks` 的全部非零格，按块类型查已知表并统计未解释格：

| bitstream | clb 块未知 | gap28 未知 | io72 未知 | edge30 未知 | 已知命中 |
|---|---|---|---|---|---|
| `s8_v0.bit` | **0** | 0 | 186 | 128 | 1,136 |
| `br_attr.bit` | **0** | 103 | 412 | 98 | 1,035 |
| `dsp/out_0.bit` | **0** | 110 | 888 | 128 | 4,796 |

结论：
1. **CLB / INT 层已完整**：clb 块未知 = 0（含 66 洞按 `law_ctrl` 认可），证明 INT+CLB 的位空间被 `law_cells + clb_cells + law_ctrl` 完全覆盖。
2. **BRAM/DSP 侧残差 103/110 格**：主要是 `off 27/28` 的属性位（WRITE_MODE 之外）与接口字节，属下一批要补的属性表。
3. **IO/时钟区是最大空白**：`io72` 186–888 格、`edge30` 128 格未解释，集中在固定签名上（`io72`：off 38 bit0/12/14/16/30、off 39 bit1/7/15/17/19/24/29/31、off 29-33 若干；`edge30`：off 27 bit1/3/9/15、off 28 bit2/4/5/7/8/12/23）。这与 S23 的结论一致——IO **数据通路**无配置位，但 IOB/ILOGIC/OLOGIC 的**属性位**与时钟 HCLK/BUFG 区仍未测绘。

### S46 续 —— 「LUT 实验看不见」的位分三类（2026-11-10）

用 `audit2.py` 对三个纯 LUT 设计（`yA` / `yB` / `e0`）与含时钟/BRAM/DSP 的设计做同一口径审计：

| 设计 | 资源 | clb 未知 | gap28 未知 | io72 未知 | edge30 未知 |
|---|---|---|---|---|---|
| `yA/yB/e0` | LUT only | 0 | 0 | **72（三次完全相同）** | **0** |
| `s8_v0` | LUT+FF+时钟 | 0 | 0 | 186 | 128 |
| `br_attr` | LUT+BRAM | 0 | 103 | 412 | 98 |
| `dsp/out_0` | LUT+DSP | 0 | 110 | 888 | 128 |

三类的性质完全不同：

1. **恒常基线（72 格，io72 块）**：任何 bitstream 都有、三次实验完全一致 ⇒ bitgen 无条件写出的默认配置，LUT 实验只能“看见它在”，永远看不到它“变化”。
2. **资源激活位（io72 增量 114→816；edge30 128）**：只在用到时钟（BUFG/CMT）、BRAM、DSP 时置位，纯 LUT 设计为 0 ⇒ 与 66 洞同性质（用了才出现）。
3. **66 洞（已进 `law_ctrl`）**：GCLK 直通使能 + BYP/FAN 旁路，同样“用了才出现”，但位置在 INT 块内、影响 mux 反解边界。

结论：LUT-only 实验的盲区**不只有 66 洞**，还有 ① io72 的 72 格常驻基线、② edge30 的 128 格、③ 由资源使用触发的一大批 IO/时钟属性位。后两者需要“IO 属性 / 时钟资源”的定向设计才能测绘。


## S47 IOB 属性位实测（2026-11-10）

**结论**：PULLTYPE / DRIVE / SLEW 的配置位全部落在 **io72 块 frame_off 38/39**，word = 该 pad 的行字（wof(Y) 与 parity 字）。不是 edge30。

| 属性=值 | 格数 | 位置要点 |
|---|---|---|
| PULLTYPE=PULLUP / PULLDOWN / KEEPER / NONE | 1 / 1 / 1 / 1 | 全在 (off39, w1)：b21 / b19=0 / b27 / b19=1 |
| DRIVE=2 / 4 / 8 / 16 | 3 / 4 / 4 / 6 | off38 与 off39，w16/w17 |
| SLEW=FAST / SLOW | 9 / 0 | off38+off39，w16/w17；SLOW 即默认 |

**重要纠正**：首轮把 `word 50` 的 7 个变化格当作共享组位，实为帧级校验字随内容变化；剔除 w50 后真实属性位只有 1~9 格。

**入库**：`v7_law.sqlite.law_iob` 30 行（attr,value,frame_off,word,bit,val,evidence,date）。`audit2.py` 加入 iobset（17 个唯一 (off,bit)）后：br_attr io72 未知 412 -> 240；dsp/out_0 888 -> 542。剩余为 IOSTANDARD/IN_TERM/ODT/IBUF 等未探测属性 + gap28/edge30 的 off26..28 区。

**构建坑**：`DRIVE 24` 对 LVCMOS18 非法（Legal: 2,4,6,8,12,16）；必须 `export LANG=C LC_ALL=C HOME=/root`，否则 Vivado 报 `locale::facet::_S_create_c_locale name not valid`。

报告：`step03_pip/S47_IOB_ATTR.md`。


## S47 续 IOB 第二批（IOSTANDARD / IOB 寄存器）2026-11-10

| 变体 | 结果 |
|---|---|
| IOSTANDARD LVCMOS15 | 7 格，全在 io72 off38/39（w16/w17），与 DRIVE/SLEW 同一字段 |
| IBUF_LOW_PWR FALSE | 非法：`ERROR: [Vivado 12-3181] IBUF_LOW_PWR is not a valid property for port din because it uses IOSTANDARD 'LVCMOS18'` |
| IOSTANDARD LVCMOS12 | 被 DRC 拦：`[DRC BIVB-1] ... LVCMOS12 does not support a drive strength of 12`（需配 DRIVE<=8） |
| IOB TRUE（FDRE 打包进 IO） | **476 格**：edge30 110 / clb 160 / io72 206 ⇒ I/O 寄存器通路配置横跨 edge30+io72 |

入库：`law_iob` 30→**37 行**（新增 IOSTANDARD:LVCMOS15 7 行），唯一 (off,bit) 17→18。
审计复跑（iobset=18）：br_attr io72 未知 **412→226**；dsp/out_0 **888→516**；新测 reg_out.bit 未知 io72 98 / edge30 109。

**诊断**：io72 剩余未知（226/516）不在 PULLTYPE/DRIVE/SLEW/IOSTANDARD 字段内 —— 由 reg_out 实验（同一字段变动时 io72 206 格 + edge30 110 格）可见，它属于 **IO 寄存器（ILOGIC/OLOGIC）与 IDELAY 配置区（offsets 28..44）**，是需要单独一族实验的子系统。

## 146. CRC 跨帧映射：可外推（2026-11-11）

补测 `BEL B6LUT` 65 个构建（同样 64/64 单格），合并后 32 个位置 × 4 帧。
用「张成组合」而非显式矩阵求解（签名空间维数 31）。

- 留一位置：**96/96 命中，0 错**
- 只用 31784→31785 训练，预测 31785→31786：**13/13 命中**
- 连用两步预测 31785→31787：**3/3 命中**

结论：跨帧是固定线性映射且可外推 ⇒ 只需测一帧 3,200 个数据位的签名（≈2.4 h），全器件任意帧可算。
未验证：跨 tile 是否同一映射；维数 31 留下的不可表达方向；硬件是否校验 CRC。


## S48 IO 逻辑寄存器位区（2026-11-10）

- `ddr_in`（IDDR）相对 `pass3` 差 **236 格**，集中在 io72 **w0/w1**（din 行字）34 格，散布 off0..31。
- `ddr_out`（ODDR）差 **200 格**，集中在 io72 **w16/w17**（o 行字）25 格 + **clb w14 36 格**。
- 结论：IO pad 配置字段 = io72 块 **offsets 0..33 @ 该 pad 行字**；属性（PULLTYPE/DRIVE/SLEW/IOSTANDARD）只在 off38/39。
- 与 S47 审计空白对应：io72 剩余未知（226/516）落在 off28..44，正是 ILOGIC/OLOGIC 区。
- IDELAY 探针全部失败（IDELAYE2 无 LOAD 端口；IDELAYCTRL REFCLK 需 BUFG 且与固定引脚冲突 → Place 30-574 / Placer could not place all instances），记为**未测**。
报告：`step03_pip/S48_IO_LOGIC_REGS.md`。


## S49 OLOGIC 拆解（2026-11-10）

基线 `pass3`。四个变体：`tbuf`(仅三态) 66 格 / `off1`(FF 打入 OLOGIC) 560 / `off1_fab`(FF 在 fabric) 646 / `oddr_pipe`(DDR 流水) 230 / `tbuf_ff`(三态寄存器) 550。

- **三态使能字段**：`tbuf` 仅 **11 格 io72**（w12 八格 + (16,17,26)(25,17,26)(30,16,3)）。
- **OLOGIC 专属**：`off1` 与 `off1_fab` 的 io72 对称差 **37 格**（FF 是否进 OLOGIC 的差别）。
- **决定性**：`off1`/`off1_fab`/`tbuf_ff` 共有 **29 个相同 edge30 格**（`(3,45,21)(5,45,20)(17,94,4)(23..25,94,4)` + `(27,24|73,{1,3,15})(27,93,{0,2,3,12,14,15})`），而 `oddr_pipe`/`tbuf` 为 **0** ⇒ **edge30 是 IO 时钟进 fabric 的时钟网络配置**，不是 IO 逻辑位；这解释了上一轮 edge30 的 128 个未知格。
- DDR 单列：`oddr_pipe` 无 edge30，但多 36 格 clb(off14) = DDR 模式字段。

报告：`step03_pip/S49_OLOGIC_SPLIT.md`。

## 147. E1/E2 实测：§146 的"跨帧映射"是恒等映射（2026-11-11）

> ⚠️ 本节"发现 2（word50 不是 GF(2) 线性）"**已作废**，由 §148 的判决实验证伪：那个比较拿三个不同数据位的签名当线性组合，方法本身错。第 1 条（§146 是恒等映射）不受影响。

语料 `_crc\`（65 文件，c_base + c00..c63，各 20,273,538 B）。解帧一律走 `bitstream/parser.frames_from_bit`（numpy 裸 reshape 会多出 5 帧，是错接线）。脚本 `v7re/scripts/_e1e2_parser.py`（权威）与 `_e1e2_final.py`（定标到 payload start=338）。输出 `v7re/steps/e1e2_result.json`。

**E1（有效非零约束）**

- base 的 frame 31784..31787 **全部全零**（data=0、word50=0）。
- 64 份变体 **64/64 只差 1 个数据位**，且 4 帧之外 **0 字变化**。
- 64 个位置 = **word 40 的 bit 0..15，在 4 帧里各一份**（16 位 × 4 帧）。即一个 LUT6 的 64 位 INIT 表被切成 4 个 16 位切片。
- ⇒ 任一"帧对 (f, f+1)"的跨帧配对样本数 = **0**：没有任何一份变体同时改动两帧。

**E2（word50 命中）**

- 位置集合里 **0 个 word 50** ⇒ §146 的 32 位置没被 ECC 污染（模型输入干净）。
- 但每份变体的 word50 都被同步重写：**64/64**，值域 max 0x186E < 2^13。
- **关键：同一个 bit 在 4 个不同帧上 word50 完全相同**（bit15 在 frame 31786 与 31787 都是 0x86F）。⇒ 帧内 ECC 不含 frame offset。

**结论（推翻 §146 的"可外推"）**

§146 的签名空间（维数 31）是一组 32 个"按 bit 索引"的签名，而该签名**与帧号无关**。因此任何跨帧线性映射都必然拟合出 **M = I**：留一 96/96、13/13、3/3 全部是"预测了不变的值"，不含任何跨帧信息量。§146 记的"跨帧是固定线性映射且可外推"**不成立**，需改判。

**量测表（单比特 → word50）**

| bit | word50 | bit | word50 |
|---|---|---|---|
| 0 | 0x860 | 8 | 0x1868 |
| 1 | 0x1861 | 9 | 0x0869 |
| 2 | 0x1862 | 10 | 0x086A |
| 3 | 0x0863 | 11 | 0x186B |
| 4 | 0x1864 | 12 | 0x086C |
| 5 | 0x0865 | 13 | 0x186D |
| 6 | 0x0866 | 14 | 0x186E |
| 7 | 0x1867 | 15 | 0x086F |

形态：`c(k) = 0x860 | k | (popcount(k)%2 ? 0x1000 : 0)`。

**这条形态否掉了我此前"用 13 个线性列向量解 word50"的方案**：`c(3)=0x863`，而 `c(1)⊕c(2)=0x1861⊕0x1862=0x0003` —— **不是 GF(2) 线性**。word50 必须按"算术/位置编码"重新建模，或怀疑它根本不是校验字。

**未测（下一步 E3）**：造 2 位同时置位的 INIT 变体，用 `ECC({i,j})` 与 `c(i)⊕c(j)` / `c(i)+c(j)` 对比，判定 XOR 型 / 算术型。这是 word50 是否可写、以及"自造可加载 bitstream"能否成立的唯一判决实验。


## S50 OLOGIC 不是家族（2026-11-10）

变体矩阵 6 个（off1/off_ce/off_sr/off_init1/tbuf_ff/tbuf），统计 pad 行字窗口。判据 `N=a×b, K=a+b, 每源 2 位` **三条全不满足**：

- FF 变体共有核心 **20 格**（off0/1/7/15/28/31/32/33）；`CE` 增 17 格、`SR` 增 10 格（部分重叠、互不相同）；
- `INIT` 只差 **1 格 (off33,bit1)** —— 干净单位开关；
- 纯三态仅 3 格（窗口内），与“OLOGIC 被使用”完全分离。

⇒ IO 逻辑 = **单位开关 + 特征位组**，不是 one-hot 家族。全片编码形态最终四类：**家族（INT/IMUX/AFFMUX/DSP/BRAM）/ 单位开关 / 码字（属性、INIT）/ 时钟网络**。解码器需三张表分别走 CSP / 位读取 / 码表比对。
报告：`step03_pip/S50_OLOGIC_NOT_FAMILY.md`；`ROUTING_SELECTION.md` §6 已同步四类形态。

## 147.1. CRC 跨帧映射的跨 tile 验证（2026-11-11）

在两列不同 slice（`SLICE_X20Y20` col33、`SLICE_X8Y20` col16）各造 8 个样本，用 tile-A（`SLICE_X12Y20`）拟合出的映射预测：

- Δ=1 三对（含两个新列）：**3/3 命中**
- Δ=2 一对（连用两次映射）：**命中**

结论：映射全器件统一，与列/slice 无关 ⇒ 一帧 3,200 个构建的投入是一次性的。

## 148. E3 判决：word50 是 GF(2) 线性函数（2026-11-11）

判决实验，造"同一帧内多位同时置位"的 LUT6 INIT 变体，看 word50 是 XOR 型还是算术型。报告 `v7re/steps/E3_ECC_LINEARITY.md`，数据 `v7re/steps/e3_result.json`，脚本 `_e3_gen.py` / `_e3_run.sh` / `_e3_analyze.py`，远端 `/opt/lzh/v7re/work/e3`。

**构建（6 个，A6LUT @ SLICE_X12Y20，读回全对）**

| tag | INIT | 落到 frame:word40 |
|---|---|---|
| e3_base | 0x0000000000000000 | —（负对照） |
| e3_a | 0x0000000000000005 | 31786: w15,w14 |
| e3_b | 0x0000000000000055 | 31786: w15..w12 |
| e3_c | 0x0000000000000003 | 31786:w15 + 31787:w15（跨帧控制） |
| e3_d | 0x0000000000000014 | 31786: w14,w13 |
| e3_e | 0x0055005500550055 | 31786: w15..w0（整帧 16 位） |

**负对照**：`e3_base.bit` vs 上批 `crcgen/c_base.bit` —— 5,067,800 字**差 0**，同设计同参数确定性成立。

**结果（判别性图案 4 个）**

| 变体 | 置位 | 观测 | XOR | ADD | 判定 |
|---|---|---|---|---|---|
| e3_a | 14,15 | **0x1001** | 0x1001 | 0x00DD | XOR |
| e3_b | 12,13,14,15 | **0x0000** | 0x0000 | 0x01B6 | XOR |
| e3_c | 31786:15 / 31787:15 | 0x086F / 0x086F | 同 | 0x086F | 控制通过 |
| e3_d | 13,14 | **0x0003** | 0x0003 | 0x10DB | XOR |
| e3_e | 0..15 | **0x0000** | 0x0000 | 0x0678 | XOR |

**XOR 4/4 命中，ADD 0/4**。内容位 5/5 只动 word40、帧集合全对。

**结论**
- 【数据事实】`word50 = ⊕_{帧内置位位置 p} col(p)`，`col` 为 13 位列向量，`ECC(全零帧)=0` ⇒ **仿射、常数为 0、GF(2) 线性**。
- 【数据事实】`e3_c` 两帧各自独立：一帧置位不影响另一帧 word50 ⇒ ECC 按帧独立，不含帧地址。
- 【推断】word40 bit `w` 的列 = `0x860 ⊕ w ⊕ (popcount(w)%2 ? 0x1000 : 0)`；`0x860` 是与字相关的常数，置位数 ≥2 时自动抵消。

**更正**：§147"word50 不是 GF(2) 线性"作废（错把三个不同数据位的签名当线性组合）。

**解锁**
1. word50 **可写**：`ECC = ⊕ col(p)`，不需要外部算法。
2. 表可压到 **3,200 个 13 位列向量（≈5.2 KB）** —— 用户"表从 8,486 万条压到 3,200 条"的直觉方向正确，但压缩对象是列向量表，不是帧到帧矩阵 M。
3. `fasm2bit` 的 ECC 增量简化为一次异或：`ECC ^= col(p)`。

**未测（E4）**：只测了 word40 的 16 列；"字相关常数"（word40→0x860）规律未测。最小实验：同 site 用 `B6LUT`（其 INIT 落到另一 word，历史 `crc_positions.json` 有 `31784:8:*`）跑 1 个单比特变体得 `C(word8)`，两字两点判 `C(word)` 是否对 word 索引线性；若线性，3,200 列可由 100 个字常数 + 32 个 bit 列合成，无需 3,200 次构建。另未测：其他 tile 类型是否同一套。

**踩坑（新增）**：`diff_e3.py` 里 Type2 包的字计数是 **27 位**（`h & 0x7FFFFFF`），用 11 位掩码只会取到 1024 字、解出 10 帧的假结果。判据：`base_frames` 必须等于 50,176。

**负对照（追加，2026-11-11 23:5x）**：`e3_a2` = 与 `e3_a` 完全同参数的第二次构建，差分 **0 字 / 0 帧**；再加 `e3_base` vs 上批 `c_base` 0 字 → 确定性双重确认。`e3_manifest.json` 经 `step03_pip/check_manifest.py` 校验 **RESULT PASS (15 ok / 0 warn / 0 fail)**，结论等级 `verified`。

## 148.1. CRC 复核 E1/E2/E3 与口径订正（2026-11-11）

- E1：128 个签名全非零且互不相同；剔零后 rank 仍 992 / 自由 32 / 矛盾 0 → 不是零样本假象。
- E2：样本 word 分布 `{40:128}`，**无 word 50** → 拟合的不是 ECC 的线性性。
- E3：未参与拟合的多比特设计查表预测 CRC —— `0xA5A5F0F01234ABCD`（31 格）`fb596696` 命中、
  `0xDEADBEEFCAFEBABE`（46 格）`e35694f8` 命中。
- **订正**：结论应表述为「可得其它帧的 **CRC 增量**」，不是「可得全器件内容」；M 作为矩阵不唯一，
  唯一确定的是它在 31 维签名子空间上的作用。

## 149. E4/E5：字常数 F(word) 的实测与「对 word 线性」否证（2026-11-11）

### 149.1 结论一句话

【数据事实】ECC 列可分解为 `col(word, bit) = F(word) ^ bit ^ (popcount(bit)%2 ? 0x1000 : 0)`（bit<16 已验），
但 **F(word) 不是 word 索引的 GF(2) 线性函数**，三个独立判据全否。因此 101 个字常数必须查表（或用 E6 全表反推规律），
不能由 6 个基向量合成。

### 149.2 实测数据（全部 frame 31786，bit 15，par(15)=0）

| word | 来源 | col(word,15) | F(word)=col^0xF |
|---|---|---|---|
| 2 | E5 Y=1 | 0x136F | 0x1360 |
| 4 | E5 Y=2 | 0x13AF | 0x13A0 |
| 8 | E4 Y=4 / E5 Y=4 | 0x144F | 0x1440 |
| 10 | E4 Y=5 | 0x148F | 0x1480 |
| 12 | E4 Y=6 | 0x04CF | 0x04C0 |
| 14 | E4 Y=7 | 0x150F | 0x1500 |
| 16 | E5 Y=8 | 0x054F | 0x0540 |
| 32 | E5 Y=16 | 0x174F | 0x1740 |
| 40 | E5 Y=20 | 0x086F | 0x0860 |
| 65 | E5 Y=32 | 0x1B8F | 0x1B80 |
| 97 | E5 Y=48 | 0x0F8F | 0x0F80 |

**独立复现**：E5 的 word40 单比特结果 `0x086F` 与 `_crc` 语料（完全不同的一批 65 个文件、不同构建时间）
word40 bit15 的值完全一致 → 跨语料确定性确认。

### 149.3 三条否证（对 word 索引的 GF(2) 线性）

1. `F(32) ^ F(8) = 0x1740 ^ 0x1440 = 0x0300`，而 `F(40) = 0x0860`。因 40 = 32^8，线性要求二者相等 → **否**。
2. `F(65) ^ F(32) = 0x1B80 ^ 0x1740 = 0x0C40`，而 `F(97) = 0x0F80`。因 97 = 65^32 → **否**。
3. `F(8) ^ F(10) ^ F(12) ^ F(14) = 0x1100 != 0`。因 8^10^12^14 = 0 → **否**。

三条相互独立（不同字集合、不同方向），结论稳。

### 149.4 附带确认的两条结构事实

- **F 全部是 0x20 的倍数**：`F = k(word) << 5`，k 为 8 位（0x9B/0x9D/0xA2/0x2A/0xBA/0x43/0xDC/0x7C…），
  即低 5 位恒 0，与「低 4 位放 bit 索引」自洽（bit<16 只占用低 4 位）。
- **地址律在 CLB 字槽上复现**：E4/E5 全部 11 个样本都落在 **frame 31786**（同列同 band → 同 block_start），
  仅 word 不同；且 Y<25 时 word = 2Y，Y=32/48 时 word = 65/97 = 2Y+1，
  与 `step03_pip/pip_law.py` 的 `w = 2*(y%50)+parity; if w>=50: w+=1` 完全一致。

### 149.5 踩坑（E4 第一次差分作废）

`_e4_out.txt` 首版把**所有 Type1 写包的数据字**（FAR/CMD 等，实测 24 字）也拼进帧数组，导致帧索引前移 24 字：
表现为「word50 零变化 + 出现 word 23/65 等幻影位置」，物理上不可能（每位置列均非零）。
修正 = 只取 Type2（`h & 0x7FFFFFF`）数据字；判据 `base_words = 5,067,776` 且 `rem = 0`。
重建后 9 个构建全部 `OK`、每变体恰 1 个内容位 + 1 个 word50。

### 149.6 产物

- `_e4_gen.py` / `_e4_run.sh` / `_e4_fix.sh` / `_e4_analyze.py`
- `_e5_gen.py` / `_e5_run.sh`
- `_e6_gen.py` / `_e6_run.sh`（51 构建：Y=0..49 全偶数字槽）
- 远端 `/opt/lzh/v7re/work/e4`、`/e5`、`/e6`

### 149.7 下一步（E6）

F(word) 全表（word 0,2,…,98）+ 离线拟合（递推 / 幂次 / CRC / 查表）→ 若得规律则 13 位校验可完全自主计算。

## 149.1. CRC 最后一个前提验证：未测 word 也成立（2026-11-11）

- `BEL C6LUT` 11 个构建（k∈{0,1,2,3,16,17,32,33,48,49}）→ 10 个单格样本，落帧 31786/31787、**word 41**、bit 3/7/11/14/15，全部未参与训练。
- 子空间归属：**10/10 在 128 个 word40 签名张成的空间内**。
- 帧步进 31786→31787 预测：**5/5 命中，0 错**。
- ⇒ 「所有 CRC 增量同一子空间 + 映射与 word/位置无关」成立，3,200 位方案的技术前提闭合。

## 150. E6/E7/E8：ECC 列向量公式闭合（2026-11-11）

### 150.1 结论一句话

`word50 = XOR over 帧内所有置位位置的 col(p)`，且 `col(word,bit) = F(word) ^ bit ^ (popcount(bit)&1 ? 0x1000 : 0)`。
**F 只依赖 word，与 frame 号、tile 列号、clock region 全无关** —— 一张 50~100 项的 F 表即可写任意 CLB 帧的校验字，不需要任何外部算法。

### 150.2 E4 实测（frame 31786，bit 15，par(15)=0）

| Y | word | col 实测 | F(word)=col^15 |
|---|---|---|---|
| 4 | 8 | 0x144F | 0x1440 |
| 5 | 10 | 0x148F | 0x1480 |
| 6 | 12 | 0x04CF | 0x04C0 |
| 7 | 14 | 0x150F | 0x1500 |

### 150.3 E5 基底字法（8 变体，frame 31786）

col(2)=0x136F、col(4)=0x13AF、col(8)=0x144F、col(16)=0x054F、col(32)=0x174F、col(40)=0x086F、col(65)=0x1B8F、col(97)=0x0F8F。
其中 **col(40)=0x086F 与 `_crc` 语料（65 文件、不同构建时间）逐位一致** → 跨语料确定性成立。

### 150.4 三条否证：F 对 word 索引不是 GF(2) 线性

| 关系 | 左 | 右 | 判定 |
|---|---|---|---|
| 40 = 32^8 | F(32)^F(8)=0x0300 | F(40)=0x0860 | ✗ |
| 97 = 65^32 | F(65)^F(32)=0x0C40 | F(97)=0x0F80 | ✗ |
| 8^10^12^14=0 | F(8)^F(10)^F(12)^F(14)=0x1100 | 0 | ✗ |

同一位置（word 40）的**位索引**方向是线性的（E3 已验证），但**字索引**方向不是。

### 150.5 E6：51 构建全测（SLICE_X12Y0..Y49，A6LUT，frame 31786）

51/51 单比特样本全部 OK，F 全部是 0x20 的倍数（`F = A(word) << 5`，A 为 8 位）。
`A(word)` 的低 7 位随 Y 呈**近乎等差数列**：0x19,0x1B,0x1D,0x1F,0x22,0x24,…,0x3E,0x41,0x43,…,0x4B ——
每步 +2，在 0x1F→0x22、0x3E→0x41 处 +3。即**带进位的算术计数**（不是线性码），这就是 F 非线性的机制解释。
H2（F(word+2)=T·F(word) 固定 13×13 矩阵）在 7 个输出位矛盾 → 否；H4（F(2w)=Q·F(w)）→ 否。

### 150.6 E7：F 与 frame / tile 列 / clock region 无关

命名冲突踩坑：base 名 `e7_b` 与站点标签 `b` 相撞，base 的 `.v/.tcl` 被后续站点覆盖成「X12Y54 INIT=1」。
但该"错误"反而给出样本：X12Y54（region 1，frame 26540）col(8,15)=0x144F。
干净复核（`_e7_fix.sh`，新 base `e7_true` 三 LUT 全 INIT=0，读回 SITE0=X12Y4 / SITE1=X12Y54 / SITE2=X20Y4 全 0x0）：

| 构建 | site | frame | content | ECC |
|---|---|---|---|---|
| e7_a | SLICE_X12Y4 | 31786 | (31786, 8, 15) | 5199 = 0x144F |
| e7_c | SLICE_X20Y4 | 31958 | (31958, 8, 15) | 5199 = 0x144F |

⇒ frame 26540 / 31786 / 31958 三点、跨 region、跨列，col(8,15) 全为 0x144F。

### 150.7 自检（`_e6_save.py`）

| 自检 | 内容 | 结果 |
|---|---|---|
| 1 | E3 四个多比特样本（INIT 0x5/0x55/0x14/0x0055005500550055）重算 | **4/4 命中** |
| 2 | E4/E5 十一个单比特样本重算 | **11/11 命中，0 失配** |
| 3 | E7 三个 frame 点 col(8,15) 预测 | **3/3 = 0x144F** |

落盘 `v7re\steps\e6_ecc_table.json`（2,280 B）：`F` 表 50 项（word 0,2,…,48 与 51,53,…,99）、`words_missing` 显式列出 51 个缺项。

### 150.8 覆盖缺口（精确）

已测 50 个 word **全部是 parity=0 槽**（Y<25 → 偶 word，Y≥25 → 奇 word 51..99）。
缺的 51 个：奇 word 1..49（25 个）、偶 word 52..100（25 个）、word 50（本身是 ECC 存储，不需要 F）。
补齐办法：`BEL C6LUT` 落另一个槽（`## 149` 已实测 X12Y20 C6LUT → word 41、bit 3/7/11/14/15）。
E8 = 一构建多 LUT：base（50 LUT 全 INIT=0）+ e8_even（偶 Y 的 25 个 INIT=1）+ e8_odd（奇 Y 的 25 个），
两构建各 25 个独立的 (tile, word) 方程，一次补齐 50 个 word。

### 150.9 产物

`_e4_gen.py`/`_e4_run.sh`/`_e4_fix.sh`/`_e4_analyze.py`、`_e5_gen.py`/`_e5_run.sh`、`_e6_gen.py`/`_e6_run.sh`/`_e6_analyze.py`/`_e6_save.py`、`_e7_gen.py`/`_e7_run.sh`/`_e7_fix.sh`、`_e8_run.sh`；
远端 `/opt/lzh/v7re/work/e4`…`e8`。

### 150.10 对写端（fasm2bit）的意义

```python
def ecc_col(word, bit):          # bit < 16 已验证
    return F[word] ^ bit ^ (0x1000 if bin(bit).count("1")&1 else 0)

def frame_ecc(dwords):           # dwords: [0..49]+[51..100] 共 100 个 32 位数据字
    acc = 0
    for i, v in enumerate(dwords):
        w = i if i < 50 else i      # 索引即 word 号（word50 不参与）
        b = 0
        while v:
            if v & 1: acc ^= ecc_col(w, b)
            v >>= 1; b += 1
    return acc
```

改一位 → `ECC ^= col(p)`，O(1)。这是自造可加载 bitstream 的**最后一块必需件**（此前 `STATUS.md` 记为"唯一硬拦路石"）。

### 150.11 E8/E9/E10：奇偶槽补齐与跨帧复核（追加）

**E8 暴露的结构事实（重要）**：同一列（X12）的 Y=0..49 全部落在**同一个 frame（31786）**里，行号完全由 **word** 编码。
⇒ 一帧 = 一列 × 一带 × 一个 minor，100 个数据字 = 50 行 × 2 半（parity）。
⇒ 同帧内放多个 LUT 只产生 1 个 XOR 方程（25 个未知数 1 个方程），**不能并行测同帧的多个 word**；必须让每个 LUT 落在不同列（不同帧）。

**E9_lo（25 列 × C6LUT，Y=0..24）** 成功：25 个奇槽 word(1,3,…,49) 各落一个独立 frame，得到 25 个独立方程。
frames 31534..32266；col C1..C34。踩坑：`e9_hi`（Y=25..49）与 base 的 LOC 不同 → 布线整体改变 → 差分 3 万+ 字，全部无效。

**E10 跨帧复核（决定性格挡）**：同一 word 换列/换帧：

| 构建 | site | frame | word | F |
|---|---|---|---|---|
| e10_w1 | SLICE_X20Y0 C6LUT | 31958 | 1 | 0x0340（E9 在 frame 31534 同值）✔ |
| e10_w41 | SLICE_X20Y20 C6LUT | 31958 | 41 | 0x1880（E9 在 frame 32086 同值）✔ |

⇒ **F 与 frame / 列无关这一条对奇槽 word 同样成立**，E9 的 25 个值可信。

**结构定律（0 反例，word 0..49）**：令 `i(0)=25`，每增一个 word `i += 1`，**若 `i % 32 == 0` 则再 +1**；
则 `F(word) = ((i & 0x3F) << 5) | (P(word) ? 0x1000 : 0)`。
`i=32` 与 `i=64` 被跳过，正对应 `F` 的 bit 10 / bit 11 被禁用；`P(word)` 是 0x1000 标志位（50 个实测值即真值表，目前无闭式）。
这解释了 §150.5 的"近乎等差数列"：那里只测了偶 word，i 每次 +2；补上奇 word 后步长就是整齐的 +1。

**当前覆盖**：`v7re\steps\e6_ecc_table.json` 共 **75 项**（word 0..49 全部 + 51,53,…,99），
缺 **25 项**：偶数槽 52,54,…,100（= Y≥25 的 parity-1 槽）。补齐需 base 与 variant 同 LOC 的 C6LUT 构建（E9_hi 的做法不可用）。

**自检（全绿）**：E3 4/4、E4/E5 11/11、E7 3/3、E9_lo/E10 跨帧 2/2、i 递推 0 不符。

### 150.12 E11 补完 100/100 + 端到端验证（2026-11-11）

**E11**（25 列 × C6LUT，Y=25..49，base 与 variant **同 LOC**）：25 个偶数槽 word 52,54,…,100 全部拿到，
frames 31534..32266，每帧恰 1 个内容位、1 个 word50。踩坑教训已固化：**base 必须与 variant 使用完全相同的 LOC**，
否则 place/route 整体重排，差分里全是布线噪声（E9_hi 就是这样作废的）。

**覆盖**：`v7re\steps\e6_ecc_table.json` 现 **100/100 个数据 word**（0..49 + 51..100，word 50 是校验字本身）。

**两条结构定律（0 反例）**
- 段一 word 0..49：`i(0)=25`，每增一 word `+1`，**跳过 32 的倍数**；`F = ((i & 0x3F) << 5) | (P?0x1000:0)`
- 段二 word 51..100：`i(w) = w + 27`，**无跳号**；`F = (i << 5) | (P?0x1000:0)`
- `P(word)`（0x1000 标志位）仍是 100 项真值表，未找到闭式。

**端到端复算（决定性）**：`_e13_e2e.py` 用公式把真实 .bit 的**每一帧** word50 从数据字重算，与文件中保存值逐帧比对：

| 文件 | 帧数 | 非零帧 | 命中 | 含 bit≥16 的帧 |
|---|---|---|---|---|
| `_crc\c_base.bit` | 50,176 | 88 | **88/88** | 38 全中 |
| `_crc\c00.bit` | 50,176 | 89 | **89/89** | 38 全中 |
| `_crc\c31.bit` | 50,176 | 89 | **89/89** | 38 全中 |
| `_crc\c63.bit` | 50,176 | 89 | **89/89** | 38 全中 |

⇒ ①公式对 **bit 0..31 全部成立**（此前只验过 bit<16 的 16 个位，`g(bit)=bit` 的高半段现在有实证）；
②非零帧里含布线数据（INT tile 帧），所以 **F 表不局限于 CLB tile**，对布线的 INT 帧同样成立；
③"自行计算 word50"这条链路 **已闭合**，写端不再需要 Vivado 或任何外部算法。

**仍需注意的边界**：所有样本都来自 `xc7vx485t` 同一器件、同一 Vivado 2017.2；
330T（7vx330t）等其他器件未验证是否同一张 F 表；空帧（数据全 0）word50 恒 0 已含在模型内。

## §151 · 比特流尾部包序列与器件级 CRC（新发现，2026-11-11）

【数据事实】`_crc\c_base.bit`（sync 在字节 150 = word 0；50,176 帧；5,067,776 字）在 FDRI 之后的有效包**只有 9 条**，其余 512 个 `0x20000000` 是 Type1 op=0 的 NOP 填充：

| # | Type1 地址 | 寄存器 | 数据 | 含义【推断】 |
|---|---|---|---|---|
| 1 | 0x00 | CRC | **0x591AE6B5** | 帧数据 CRC（配置结束由器件比对） |
| 2 | 0x04 | CMD | 0x0A | GRESTORE |
| 3 | 0x04 | CMD | 0x03 | LFRM |
| 4 | 0x04 | CMD | 0x05 | START |
| 5 | 0x01 | FAR | 0x03BE0000 | 回读起始帧地址 |
| 6 | 0x06 | MASK | 0x0501 | 回读掩码 |
| 7 | 0x05 | CTL0 | 0x0501 | 控制 |
| 8 | 0x00 | CRC | **0xE3AD7EA5** | 回读循环数据的 CRC |
| 9 | 0x04 | CMD | 0x0D | GO |

【数据事实】四类假设**全部否证**（目标值 0x591AE6B5）：
- 反射 CRC32（zlib 四组合：init 0 / 0xFFFFFFFF × xorout 0 / 0xFFFFFFFF）× 4 个区间（`w[0:CRC包)`、`w[1:…]`、`w[4:…]`、仅 FDRI 数据 `w[46:46+5067776]`）→ **无命中**
- 非反射 CRC32（poly 0x04C11DB7，init 0 / 0xFFFFFFFF）× 2 个区间（`w[0:CRC包)`、仅 FDRI）→ **无命中**

【推断】覆盖范围/推进方式不是"从 sync 后第一字到 CRC 包、按字节推进"这种直白取法。四个可能方向：
(a) 只统计**写入配置寄存器的数据字**，且含/不含包头的特定子集；
(b) 含 `0x000000BB 0x11220044` 前导与 `0x0F0F0F0F×4` 及 BUS_WIDTH 等前置包；
(c) **按位推进**而非按字节（Xilinx 配置 CRC 惯例是 bit 级移位）；
(d) word 内字节序 / 位序存在交换。

### 为什么这是下一步的 P0
- 帧数据 `word50` 已可自算（§150），器件级 CRC 是"自造比特流能被器件接受"**唯一剩下的拦路石**：配置结束时器件比对该值，不符则 INIT_B/DONE 拉低。
- **单未知量、可离线拟合**：`_crc` 语料 65 份，每份都有已知 CRC 值和不同内容，足以在无硬件条件下判定命中。
- 不需要板子即可出结论（判据是"值命中"，不是"能跑"）。

### 实验设计（下一步执行）
1. 抽取 65 份语料的 `(payload 区间, CRC 值)` 建 CSV，先只用 1 份做搜索，其余 64 份做验证（判据 65/65）。
2. 参数化搜索空间：起点 ∈ {sync+1, sync+2, `0x000000BB` 之后, `0x0F0F0F0F×4` 之后}；终点 ∈ {CRC 包之前}；推进粒度 ∈ {bit, byte}；位序 ∈ {MSB-first, LSB-first}；init ∈ {0, 0xFFFFFFFF}；xorout ∈ {0, 0xFFFFFFFF}；poly ∈ {0x04C11DB7 反射/非反射}。
3. 若穷举仍不中，改 GF(2) 拟合：定长区间下 CRC 是数据的**仿射**函数，用 65 份样本对 32 个输出位逐位解线性系统（与 §150 解 ECC 列同一套工具 `gf2_solve`）。
4. 命中后落地 `v7re/scripts/crc_dev.py`，并在 §150 的写端链路上补一步。

### 同步记录：其他候选任务（本轮未做）
- **B 全芯片自造流 + 与 Vivado 逐字节比对**：无需硬件即可验证工具链完整性（S15 已对单 tile 做过 0 字差异，未做全芯片）。
- **C 语义覆盖扩展**：BRAM/DSP 目前仅 2 特征（§6.12），SLICEM 的 RAM/SRL、IO/CMT/GTX 全未碰。
- **D 330T 一致性**：现全部样本来自 `xc7vx485t`；`xc7vx330t`（`C:\v7check` 的 34,412 帧样本）是否共用同一张 F 表，只需 1 次构建。
- **E 真实板子回读**：唯一能证伪全部结论的手段，受硬件限制。

## S52 INT 门控位点亮实验（2026-11-11）

66 个 off0..3 洞位（`int_holes.json`）不全是 GCLK/旁路：用 6 个定向设计（`/opt/lzh/step13/gc/`，SLICE_X8Y11，base 31680）实测得到 5 条命名 ——
`(0,1,16)=FF_USED_IN_SLICE`、`(1,1,7)=CE_SOURCE_FABRIC`、`(1,1,3)=SR_SOURCE_FABRIC`、`(1,1,15)/(1,1,23)=CE_SR_CONST_MARK_A/B`【推断】；`law_ctrl` 已更新 10 行（5 坐标×2 侧）。
语料侧：6,015 个既有 bitstream 只点亮过 3 个洞位（(0,1,16)/(1,1,19)/(1,0,31)），其余 63 位未出现；本批 6 设计再点亮 7 个，仍余 56 个未命名。
副结论：`clock_fabric`（LUT 当时钟、无 BUFG）与 `clock_global`（BUFG）洞位完全相同 ⇒ 这 6 位与全局时钟无关；BUFG 差异只在已覆盖 cell。
报告：`step03_pip/S52_INT_GATE_BITS.md`。

## S51. 复用规律总论（2026-11-11）

执行 `step03_pip/PROMPT_PIP_REUSE_V3.md`，产出 `step03_pip/PIP_REUSE_LAW.md`（八段）。四条新表述：

1. **复用四层化**：L1 位级共享（同族 N 源 share K cell）/ L2 跨实例（块基址+行字位移）/ L3 语义（四类编码并存）/ L4 非位（EDA 的 PIP reuse，显式排除）。
2. **每源位数定论**：2 位 5,640 源、4 位 1,632 源（全部落在 (10,24)/(8,16) 形状），无第三档；池内无恒 0 cell。
3. **“合法 ≠ 实际”三反例化**：四 tile 同块皆 12 unique；基址 +36 阴性对照仍合法；S13 多解需真值剪枝。
4. **生成侧口径**：写位 = `ones`→1、`zeros` 与“池内未涉及位”→0（不清零残留会解错源）；自检三步（帧内回读 / FDRI burst / 864 写回环）。

未测清单同步（66 洞、时钟树、DSP 280 属性、FIFO 29 属性、GTX/PCIE、跨器件通用性）。

## S52 续（2026-11-11）—— 第三批 11 设计：7/66 门控位已命名，59 位与 CLB 特性无关

第三批设计（`/opt/lzh/step13/gc2/`）：v_ce_rst / v_ce_inv / v_rst_inv / v_ck_inv / v_two_ff /
v_four_ff / v_lut_ff / v_ff_init1 / v_ff_se / v_latch / v_muxf7，全部与第二批 6 个设计同块（base 31680,
word 22/23，frames 31680..31683）。17 个设计合并矩阵后，**洞位点亮集合仍是 7 个**：

| 洞位 | 名字 | 判据（17 设计） |
|---|---|---|
| (0,1,16) | FF_USED_IN_SLICE | 12 个含 FF 设计全 1；v_latch / gc_nof 为 0 |
| (1,0,7) | FF_D_BYPASS_A【推】 | FDRE 类普遍 1；v_ff_se(FDSE) / v_muxf7 / v_latch 为 0 |
| (1,0,19) | FF_MULTI_OR_FABRIC_D【推】 | 多 FF 或 D 来自 fabric 时 1 |
| (1,1,7) | CE_SOURCE_FABRIC | CE 接端口（含 LUT 取反）1；接常量 1 时 0 |
| (1,1,3) | SR_SOURCE_FABRIC | R/S 接端口 1；接常量 0 |
| (1,1,15) | CE_R_FABRIC_MARK_A | CE/R 任一来自 fabric 即 1，恒与 (1,1,23) 同置 |
| (1,1,23) | CE_R_FABRIC_MARK_B | 同上 |

结论：**剩余 59 个洞位与 slice 内 FF/CE/SR/LUT/MUXF 的任何组合都无关**（17 个设计零命中）。
它们更可能是全局网/长线（GCLK_L_B**, LV/LH）在 tile 内的落点使能，或同块另一侧 INT 半区的控制位。
已写入 law_ctrl（14 行 L/R 各 7）。

## §149 T80 全帧 CRC 签名（2026-11-11）

- 语料：`SLICE_X12Y<Y>`（Y=0..49）、4 BEL × 16 个 `k=16a+2b`（覆盖 bit 15..0 各一次），
  基线 **per-(Y,BEL)** 共 200 份；合计 3,250 个构建，全部 OK。
- V1 位置域：3,200/3,200 每份差分 `add=1,rem=0`；(word,bit) 唯一 3,200；
  word 0..100（缺 word 50 = ECC）、bit 0..31；**全部落在单帧 31786**；签名全互异、零签名 0。
- V2 子空间：rank(旧 64) = 31，rank(新 3,200) = 31，新签名落在 span(旧) 外 **0** 个。
- V3 跨帧：另造 16 个奇数 k 设计（frame 31787），用 32 对训练（张成 30 维）预测 →
  **10/10 命中、0 错**，6 个不可表达（训练缺 2 维）。命中含跨 word（41,15/14/31）与跨行（y=30→word 61/62）。
- 踩坑：首版语料基线按 Y 一份（BEL 只 A6LUT），不同 BEL 的 LOCK_PINS 引脚不同 →
  每份差约 100 格噪声；改 per-(Y,BEL) 基线后严格单格。
- 文档：`v7re/steps/T80_CRC_FULLFRAME.md`。
- **补满秩（§149 后续）**：追加 word 41（C6LUT/D6LUT）32 个位置 × 2 帧共 64 个构建，全部单格；
  训练对达 **64**，张成维数 **31（饱和）**，**留一法 64/64 精确命中、0 错、0 不可表达**。
  ⇒ 跨帧映射与 word/行/BEL 无关，只与帧序号有关。

## §150 CRC 语义的文档级证据（T81）

- 来源：UG470 v1.15（2022-07-27）日文版，本地 `_ug470.pdf`（185 页）。
- p.86：CRC **默认包含在配置位流中**、**硬件校验**，失配则 **INIT_B 拉低、配置中断**；可经 BitGen（UG628）关闭；
  7 系列为 **32 位 CRC**；加密位流（`BITSTREAM.ENCRYPTION.ENCRYPT=Yes`）时 CRC 失效、改由 HMAC。
- p.101–103（表 5-19）：CRC 覆盖起点为 **RCRC 命令之后**；位流中**有两个 CRC 包**：
  首个在 FDRI 数据之后（例值 `C81874CB`），第二个在 START/FAR 之后、恒为 **`E3AD7EA5`**
  （与我们在 10 个设计上测到的常量完全一致，因为它只覆盖固定尾部序列）。
- 结论：改位流数据后**必须**修首个 CRC；第二个 CRC 无需重算。我们的增量表因此是必需项。
- 未验证：JTAG 配置路径的板级实测；UG628 BitGen 关闭 CRC 的选项名。
- 文档：`v7re/steps/T81_CRC_UG470.md`。

## S53 时钟树测绘（第一部分，2026-11-11）

- **时钟脊 = 12 个 `edge30` 块**（每 band 两个）：base 2562 / 7370 / 7808 / 12616 / 13054 / 17862 / 18300 / 23108 / 23546 / 28792 / 33600 / 34038。此前"word 50 非零的 157 帧"主要就在这些块里。
- **BUFGCTRL**：BUFG vs BUFGCE 的唯一配置位 = `(edge30 base7808 + off26, word 93, bit 5)`。
- **BUFHCE**：每站点 4 位簇 `{(off,w,31),(off+1,w,19),(off+1,w,23),(off+1,w,25)}`；`BUFHCE_X0Y0` 在 `(base34038+off26/27, word 48)`，`X0Y5` 平移为 `(off28/29, word 49)`；`X0Y10` 出现在多处（LOC 未完全生效）。CE 常量位 = `(off27, w48, b19)`：CE=1 时为 1。
- **MMCM**：`CLKFBOUT_MULT_F` 4→6（输出保持 100MHz）差 16 个非校验位，全在 **帧 27392/27393**，words 12/25/26/29 ⇒ CMT 块 word 映射与 wof(Y) 不同（未定）。
- 构建约束：MMCM VCO 必须 600–1600MHz（否则 `DRC PDRC-34` + route 失败）；BUFR 不能驱动被 LOC 锁在 fabric 的 FF（`Place 30-176`）；BUFG 的 LOC 需匹配 `REF_NAME == BUFG`（用 BUFGCTRL 过滤匹配不到，g0≡g4 即证据）。
- 报告：`step03_pip/S53_CLOCK_TREE_P1.md`；`v7_verified` 126→**132**（6 行）。
- 未做：edge30/CMT 的 word 基准锚；BUFR/BUFIO/BUFMRCE/PLL；3,020 个 HCLK_* tile。

## S54 CMT（MMCM/PLL）配置区定位（2026-11-11）

- **帧锚点**：`MMCME2_ADV_X0Y0`→帧 32638/32639（band0 io72 base 32568 **+70/+71**）；`X0Y1`→27392/27393（27322+70）；`X0Y2`→1130/1131（1092+70）。
  ⇒ **规则：CMT 配置帧 = 该 band 的 io72 块基址 + 70 / +71**（站点 Y = 9 + 52·band）。
- **word 是属性平面，不是行字**（全项目首例非 `wof(Y)` 规则）：
  - LOWER 槽（MMCM）：MULT 差异只落在 word **12 / 25 / 26 / 29**；
  - UPPER 槽（PLL，`CMT_TOP_R_UPPER_T_X88Y44`）：同一对帧，但 word 是 **77 / 80 / 81 / 94**。
- 时钟脊三件套的分工定型：`edge30` = BUFGCTRL/BUFHCE；`io72 +70/+71` = CMT（MMCM/PLL）；HCLK_*（3,020 tile）未定位。
- 报告 `step03_pip/S54_CMT_WORD_ANCHOR.md`；`v7_verified` 132→**137**。
- 未做：MMCM/PLL 约 20 个属性的逐位命名（只证了"在哪两帧、哪些 word"）；BUFIO/BUFR/BUFMRCE；HCLK 位区。

## S55 MMCM 属性位实测（2026-11-11）

站点 `MMCME2_ADV_X0Y0`（帧 32638/32639），12 个单属性变体：

| 属性 | 位 | 结论 |
|---|---|---|
| STARTUP_WAIT | (w2,b30) | 0=FALSE / 1=TRUE |
| CLKFBOUT_PHASE | (w26,b23) | 0→90 置 1 |
| CLKOUT0_PHASE | (w29,b23) | 0→45 置 1 |
| CLKOUT0_USE_FINE_PS | (w21,b31) + (w29,b19) | FALSE→TRUE |
| BANDWIDTH | (w12,b0)=1,(w12,b9)=0,(w12,b11)=0 | OPT→LOW |
| CLKOUT1 启用 | (w29,b4/b9/b12/b15) | 加一路输出 |
| DIVCLK 1→2 | (w26,b9) | 一次配对（B 级） |
| REF_JITTER 0.010→0.020 | **无任何位变化** | 不编码 |

- **MULT 与 CLKOUT0_DIVIDE 是分段码，不是二进制**：MULT 最少 8 个 cell 跨 w12/w25/w26（3 与 5 共享 (26,20)，4 与 6 共享 (12,0)）；DIVIDE 8→6/7/10 的 cell 集互不嵌套。定形需 0..64 全扫描。
- word 平面：**w2 = STARTUP_WAIT；w12/w25/w26 = MULT/DIVCLK/BANDWIDTH/FB_PHASE；w29 = CLKOUT；w21 = FINE_PS**。
- 报告 `step03_pip/S55_MMCM_ATTR_BITS.md`；`v7_verified` 137→**144**。

## S56 PLL 属性位实测（2026-11-11）

站点 `PLLE2_ADV_X0Y0`（帧 32638/32639，与 MMCM 同一对帧）：

| 属性 | 位 | 结论 |
|---|---|---|
| STARTUP_WAIT | (w98,b1) | FALSE=0 / TRUE=1 |
| CLKOUT0_PHASE | (w77,b8) | 0→45 置 1 |
| CLKOUT0_DIVIDE 8→10 | (w77,b0)(w77,b3) | 置 1 |
| CLKOUT0_DUTY 0.25 | (w77,b0)(w77,b3) 置 1，(w77,b4) 清 0 | — |
| MULT 4→5 | (w80,b11) 置 1，(w94,b30) 清 0 | — |
| DIVCLK 1→2 | (w80,b0/b3/b22)(w94,b20/b29) 清 0；(w80,b1/b4)(w81,b15)(w94,b23) 置 1 | B 级 |
| BANDWIDTH LOW | (w94,b20/b22/b29) 清 0 | — |
| CLKOUT1 使能 | (w77,b22) 置 1，(w77,b27) 清 0 | — |

- **PLL 的 word 平面 = w77 / w80 / w81 / w94 / w98**，与 MMCM 的 w2/w12/w25/w26/w29/w21 **完全错开**。
- 编码形态与 MMCM 同构：MULT/DIVIDE 分段码，单比特属性是开关位。
- 至此 **CMT 两个原语（MMCM + PLL）都能从位流解码主要属性**。
- 报告 `step03_pip/S56_PLL_ATTR_BITS.md`；`v7_verified` 144→**152**。

## S57 · MMCM MULT / CLKOUT_DIVIDE 分段码（2026-11-11）

37 个设计（MULT 3–32 + DIVIDE 1–64 抽样）实测，站点 `MMCME2_ADV_X0Y0`、帧对 32638/32639：

- **CLKIN1_PERIOD 不编码**：4 组对照（7/12/14/16 各跑 200/100/50 MHz 两档）位级完全相同。
- **MULT 是两级码**：coarse 在 `f0.w26` 的 bit20/27/28/30/31 一带（同一 coarse 值可对应 16 与 24），
  fine 在 `f0.w25`/`f1.w25`；`f0.w25` 低字节在 3–10 段是 `7b/7d/79/7f`，11–32 段恒 `7f` 且高字节呈滑动窗口。
- **DIVIDE 也是分段码**：`f0.w29` 只有 8 个取值，`0x90000000` 同时对应 4/6/12，`0x48000000` 对应 16/24/48；
  `f1.w29` 低 16 位恒 `0x9010`（DIVIDE=1 为 `0x1010`，多一个旁路位）。
- 结论：**只能查表**，无闭式；表已入库 `cmt_code`（33 行）+ `v7_verified` 154。
- 报告：`step03_pip/S57_MMCM_MULT_DIVIDE_CODE.md`。
- 未测：MULT 1–2 / 33–64（需 CLKIN ≤25 MHz 进 VCO 窗口）、DIVIDE 11/13–15/18/22/25–31/40/56/80/128。

## S58 · BUFIO / BUFR / BUFMRCE（2026-11-11）

8 设计实测（远端 `/opt/lzh/step15/clk2/`），结论：

- **BUFIO 无任何配置位**（与基线位流逐位相同）。
- **BUFR**：CE `(27322,w44,b17)+(27323,w44,b13)`、CLR `(27322,w46,b17)+(27323,w46,b13)`（**CE/CLR 均为反向存储**）、
  DIVIDE 码字在 `f27354/f27355` 的 **word 50**。
- **BUFMRCE**：CE / INIT_OUT **不编码**（三个变体位流只差 1 个 word50 值）；实例化才出现的 5 个位：
  `(27255,w48,{8,11}) (27364,w48,27) (27365,w48,25) (27393,w49,3)`。
- **重要修正**：`word 50` 的性质按块类型而定——fabric 块（CLB/INT/BRAM/DSP）是校验/ECC，
  **io72/edge30/CMT 块里是真实配置字**（div2 vs div3 只在 w50 有差异）。
- 构建门：BUFR 输出必须悬空（否则 `Place 30-134` / `Place 30-176`）；`get_drc_checks PLACE-176` 返回空会让脚本中止。
- 站点归属：时钟分发三件套的位都在 **io72 块**（27322 系列），与 CMT（io72+70/+71）同区，`edge30` 只覆盖了 BUFGCTRL/BUFHCE。
- 报告：`step03_pip/S58_BUFIO_BUFR_BUFMRCE.md`；`v7_verified` 154 → **161**。

## S59 · HCLK_* 位区定位（2026-11-11）

3 设计三态差分（`h_off` 无缓冲器 / `h_bufg` 全局 / `h_on` BUFHCE 区域），FF 固定 `SLICE_X8Y11`：

- 逐 cell 按 (off,bufg,on) 三元组分类：**bufg_only 169 / hclk_only 31 / other 55**（排除 word 50）。
- **核心结论：HCLK_* 没有自己的帧块**。`frame_blocks` 六类里没有 hclk；HCLK 配置分两层：
  1. 缓冲器入口：`edge30` 的 `off26..29`（BUFHCE_X0Y0 = `(34038+26,w48,b31)+(34038+27,w48,b19/23/25)`，与 S53 逐位一致）；
  2. 轨道选择：各列 **CLB/INT 块的 INT 控制池**（off 0..25）按该行 row word 排布，**单 bit 语义**。
- `hclk_only` 31 个 cell 完全列出（io72 27322 系列、clb gc16/gc115/gc179/gc188、edge30 33600/34038、pcie 28354/28355）。
- 口径修正：**“按 tile 算覆盖率”对 HCLK 不适用**（它不是独立可配置块）。
- 报告：`step03_pip/S59_HCLK_LOCATION.md`；`v7_verified` 161 → **167**。

## §151 CRC 签名依赖绝对帧位置（远距实测，T82）

- 实验：`SLICE_X12Y200`（col20、band4、base 10768）造 2 份（INIT=0 / INIT=1），与 anchor（`SLICE_X12Y20`，base 31752）对比同一 (word 0, bit 15)。
- 差分格：far 落在帧 **10802**（=10768+34）、word 0、bit 15 —— 与 anchor 的帧 31786（=31752+34）**同一帧偏移、同一 word、同一 bit**。
- 实测签名：anchor `0xcc97191d`，far `0x6d7922f5`，**异或 K=`0xa1ee3be8`（非零）**。
- 结论：CRC 签名不是 (word,bit) 的函数，而是**绝对帧位置**的函数（CRC 是 LFSR，贡献随「距 CRC 寄存器的位数」变化）。
  ⇒ T80 的 3,200 条表只在帧 31786 有效；跨帧外推必须依赖「帧步映射」，而该映射已实测 **rank 31（奇异，32 维丢 1 维）**，正向可迭代、反向不可逆。
- 另一发现：全帧扫描用的 k 只有偶数（`k=16a+2b`），所以 3,200 条全部落在帧 31786 一个帧上，此前"每行 4 BEL 覆盖"的表述应更正为"每行 4 BEL、单帧"。
- 文档：本节；`v7re/scripts/crc_delta.py` 仍未接入 3,200 条表。

## S60 · GTX 配置帧区首次定位（2026-11-11）

- 语料：远端 194 个用户级 .v 中 **0 个 GTX/PCIE 实例**，7,987 个 bitstream 无 GTX 设计 ⇒ 自建。
- 最小探针：`GTXE2_CHANNEL` 只连 8 端口即可综合；需 `BUFG` 转发 `TXOUTCLK`（REQP-1739）、`GTGREFCLK` 供参考时钟（REQP-51/52），DRC 豁免必须在 `place_design` **之前** 用 `set_property SEVERITY Warning [get_drc_checks <ID>]`（**不加花括号**，否则 Vivado 12-2485）。
- 配置区：**帧 31476..31507**（block base 31476 = 31508−32，紧邻 band0 第一个 CLB 块 31508），**word 平面 0..100 全宽**（非 `wof(Y)`）。
- 实测字段：`CPLL_FBDIV` 2→4 = `(31507,w1,b16)`；`TXOUT_DIV` 4→8 = `(31506,w12,b0/b2)`；`TX_DATA_WIDTH` 20→40 = `(31504,w4,b14)↓ (31505,w4,b14)↑ (31506,w4,b25)↑ (31507,w4,b24)↓`。
- 通道 word 偏移：Y0=16（基准）/ Y1=38(+22) / Y2=73(+57) / Y3=95(+79)【未定形】。
- word 50 在 GTX 块内是帧级校验字（每帧 5–9 位随配置变化），非配置。
- 入库：`v7_verified` 167→**173**；报告 `step03_pip/S60_GTX_FRAME_ANCHOR.md`。

## §152 CRC 多项式直接反解（路线 B）失败记录

- 目标：检验 `c(p) = A · x^{d(p)} mod P`（标准 LFSR 模型），从而免掉逐帧锚点。
- 数据：3,200 条单比特 CRC 签名（帧 31786）。
- 扫了 8 个候选多项式（`04C11DB7`/`EDB88320`/`1EDC6F41`/`82F63B78`/`741B8CD7`/`A833982B`/`814141AB`/`0xAF`）× 两种移位方向（MSB/LSB）× 四种流内下标约定（word*32+bit、位反序、从末尾倒数两种）。
- 结果：**全部失败**，矛盾 5–51 万条（方程总量 102,400）。即使只解 32 个未知 A，也无一组约定能满足。
- 结论：这些候选多项式与「按帧内 word/bit 线性排列」的流顺序假设不成立。可能原因（未验证）：
  1. CRC 覆盖自 RCRC 起，含头部包与 FDRI 长度字节，`d` 必须按**真实包序**算，而不是 `frame*101+word`；
  2. 每个 32 位字的位序（MSB 先）与 ECC 耦合；
  3. Xilinx 用的可能不是这 8 个常见多项式。
- 决策：路线 B 暂停；CRC 保持「按锚点局部可用」状态（`crc_table.json` 64 条 + `crc_delta.py` 未接入 3,200 条）。
- 影响面：CRC 只影响「生成的位流能否被 FPGA 加载」，不影响本项目主线（PIP 编码规律、解码器、FASM 层）。

### S60 续 · 通道平面定形（2026-11-11）

- **通道 word 平面基址 = 0 / 22 / 57 / 79**（Y0/Y1/Y2/Y3），由两个互相独立的属性交叉确认：
  - `CPLL_FBDIV` 2→4：`(31507,w1,b16)` / `(31507,w23,b16)` / `(31507,w58,b16)` / `(31507,w80,b16)`；
  - `TXOUT_DIV` 4→8：`(31506,w12,b0/b2)` / `(31506,w34,...)` / `(31506,w69,...)` / `(31506,w91,...)`。
- 四条平面不等距（22/35/22/22），中段多 13 字【未定形】。
- quad 偏移：`LOC X1Y0` 的差异落在 **帧 27286/27287** ⇒ quad X1 的 GTX 块 = `[27286−32, 27286)`，与 band0 的 `[31476, 31508)` 同构（「下一 CLB 块基址 −32」）。
- 入库：`v7_verified` 173→**178**（CH_PLANE_BASE ×4 + QUAD_BLOCK ×1）。

## §153 CLB 站内四类（BYP/DMUX/SR/CLK）定性（T82）

- BYP：`segbits_clblm_l.db` 703 行中 **0 行**含 BYP → 纯连线，无配置位。
- CLK：posedge vs negedge 全芯片只差 **1 位** `(31753, 41, 19)`（块基址 31752 + 偏移 1，word 41，bit 19），对应 `CLKINV/NOCLKINV`。
- SR：用 vs 不用 → CLB 块内 7 格（`(31753,41,2/3/9)` + word40 bit6 在帧偏移 2/4/9/15 重复），**未分离**。
- DMUX：本轮 3 个构造设计全部构建失败（tcl 引用不存在的 cell、`A6LUT_O6` 双重驱动冲突），无数据。
- CLB 可配置特征共 58（SLICEL）/61（SLICEM）条：LUT 模式 4、FF D 选择 4×4 位、LUT 输出选择 4×4 位、FF 属性若干、使用标志 5、CLKINV 1、PRECYINIT 3、SMEM 3。
- 文档 `v7re/steps/T82_CLB_SITE_CLASSES.md`。
### S60 续2 · GTX RX 字段 + COMMON 平面（2026-11-11）

- `RX_DATA_WIDTH` 20→40 = `(31504,w4,b14)↓ (31505,w4,b14)↑`，与 `TX_DATA_WIDTH` 的前两位**完全相同** ⇒ `w4.b14` 对是 **TX/RX 共用的数据位宽位**；`TX_DATA_WIDTH` 独有的 `w4 b25/b24` 对才是 TX 专属。
- `RX_CM_TRIM` 4→5 = `(31505,w4,b8)`；`RXSLIDE_MODE` OFF→AUTO = `(31504,w16,b7)↑ (31505,w16,b10)↓`（需 `SHOW_REALIGN_COMMA=FALSE`，否则 `DRC AVAL-23`）。
- `GTXE2_COMMON.QPLL_FBDIV` 4→5 = `(31506,w45,b16)`，其平面基址 **w45** 落在 Y1 区间 22..56 内 ⇒ **"通道不等距 22/35/22"里多出的 13 字就是 COMMON 平面**。
- GTX 帧平面模型（最佳）：w0..21=Y0 / w22..44=Y1 / w45..56=COMMON / w57..78=Y2 / w79..100=Y3。
- 构建坑：`GTXE2_COMMON` **没有** `QPLL_FBDIV_45` 参数（`Synth 8-3438`）；`RXSLIDE_MODE=AUTO` 与 `SHOW_REALIGN_COMMA=TRUE` 互斥（`DRC AVAL-23`）。
- 入库：`v7_verified` 178→**183**。

## §154 AFFMUX：O5/O6 选择是 1 位（T83）

- 设计：`LUT6_2` 同 INIT、同 `LOC/BEL`、同 `LOCK_PINS`，仅 FF 的 D 接 `.O6()` 或 `.O5()`（`f_o6` / `f_o5`）。
- 差分：O6 319 格、O5 320 格，**移除 0 / 新增 1** = `(31782, 40, 0)`（= 块基址 31752 + 30，word 40，bit 0）。bit=1 → O5，bit=0 → O6。
- 与 prjxray A7 的 `SLICEL_X1.AFFMUX` 一致：该字段 4 位编码 6 个源，其中 O5=(1,1,0,0) / O6=(1,0,0,0) **只差 `31_00`**。
- 结论：AFFMUX **不是** 4 位 one-hot；`(块基址+30, 40, 0)` 对应 A7 的 `31_00`。
- 失败对照：`f_ax`（FF.D = 输入脚，走 AX bypass）构建成功但差分 40+ 格跨 700+ 帧（换源同时换网），AX/CY/XOR/F7 的位仍未定位。
- 文档 `v7re/steps/T83_AFFMUX.md`。
### S60 续3 · COMMON 的 quad 归属（2026-11-11）

- 7 个 quad 通过 LOC 扫描全部定位：**quad i 的 GTX 块 = `band_base(i) − 272`，长 32 帧**。
  X0Y0 31476 / X0Y1 26230 / X0Y2 0 / X0Y3 5246 / X0Y4 10492 / X0Y5 15738 / X0Y6 20984（7/7 命中）。
- 通道↔quad：`GTXE2_CHANNEL_X0Y0..27`，**quad = Y÷4**（实测 X0Y4 落在 26230 簇 = quad1）。
- 全片：56 channel + 14 COMMON = 2 个 die 半区（X0/X1）× 7 quad，每 quad 一个 32 帧块。
- 实验纪律：LOC 扫描的差分里有一批固定的 fabric/时钟噪声帧（31516/31521/31551/31556、31684–31686、31827–31829、31963–31965、32100/32171/32235/32299、27286–27361、28818），必须按「簇首 = band_base−272」判读。
- 入库：`v7_verified` 183→**190**（QUAD_BAND_MAP ×7）。

## §155 AOUTMUX：4 位字段，O5/O6 四格全不同（T84）

- 构造：`LUT6_2` 双输出形态固定，`s_a`（FF.D=O6、输出脚=O5）vs `s_b`（FF.D=O5、输出脚=O6）。
- CLB 块内差分：`s_a` 置 `(3,40,8)(4,40,10)(6,41,4)(7,41,5)`；`s_b` 置 `(3,40,4)(4,41,10)(6,41,8)(7,40,5)` —— **各 4 位、互不相同**，对上 prjxray `SLICEM_X0.AOUTMUX` 的 4 位字段。
- 交叉印证：单输出对 `g_o6`/`g_o5` 的 CLB 块差分与上表一致；另出现 `(30,40,6)(30,40,11)`，疑为 LUT 模式位（未单独验证）。
- 未解决：V7 帧偏移（3/4/6/7）与 A7（30/31）不对应，需建 V7↔A7 偏移映射。
- 文档 `v7re/steps/T84_AOUTMUX.md`。

## §156 CLB 剩余特征实测 + ppip 归类（T85）

- 设计固定 `u_lut`=SLICE_X12Y20/A6LUT、`u_ff`=SLICE_X12Y20/AFF，5 份对照（FDRE / FDCE / LDCE / CE=1 / CE=pin）。
- **FFSYNC = 1 位** `(31752, 41, 16)`：FDRE(同步)=1，FDCE(异步)=0，全芯片只差这 1 格。
- SR 使用 = 3 位 `(31753,41,2)(31753,41,3)(31753,41,9)`。
- CE 使用 = 7 位（候选 `(31753,41,7)`，另 6 格待定）。
- LDCE 锁存器 = 6 位：移除 FFSYNC 3+1 位，新增 `(31753,41,19)`(CLKINV) 与候选 LATCH `(31782,41,0)`。
- **CLB 151 条「PIP」全是 ppip**：93 always（硬连线，无配置位）+ 58 hint（仅提示）；其中 LUT 输入 `A1..A6←IMUX*`、`AX..DX←BYP*`、`CE←FAN6/CLK←CLK0/SR←CTRL0` 都是 always ⇒ 这三类的源选择确实在 INT 侧，没有站内配置位。
- 文档 `v7re/steps/T85_CLB_REMAINING_BITS.md`。

## §157 PRECYINIT（CI 常量）1 位 + CLB 位汇总（T86）

- 构造：`CARRY4` 只差 `.CI(1'b0)` vs `.CI(1'b1)`，`LOC SLICE_X12Y20` 固定。
- 结果：全芯片只差 **1 格** `(31752, 40, 12)`，CI=1 时为 1，无布线差异。
- prjxray `PRECYINIT` 是 3 位字段，本次只拿其中一位（CYINIT / INIT 两档未测）。
- A5FF/A5FFMUX 仍未隔离：`f_o5`/`f_o6` 的 `(30,40,0)` 属 AFFMUX；要用 IN_A 必须换整条输入网，噪声不可控。
- CLB 站内已定位位汇总表（FFSYNC/CLKINV/AFFMUX/AOUTMUX 4 位/SR 3 位/CE 7 位/LATCH/PRECYINIT）写入 `v7re/steps/T86_PRECYINIT.md` §5。

## §158 CLB 边角位收口（T87，7 构建）

- `f_fdre_bff` vs `f_ldce_bff`（BFF 上 FDRE vs LDCE）：全芯片 1 移除 / 2 新增 → `(0,41,16)`=FFSYNC、`(1,41,19)`=CLKINV、`(30,41,0)`=**LATCH（确认）**；三者与 AFF 上同位 ⇒ slice 级。
- CE：`d_cepin`(CE=引脚) vs `c_ce_lut`(CE=B6LUT 输出) → 稳定 4 位 `(1,41,7)(23,41,0)(24,41,0)(25,41,0)`，随源变 3 位 `(8,39,16)(13,39,17)(19,41,1)`；`CEUSEDMUX` 强候选 = `(1,41,7)`。
- PRECYINIT：`.CI(1'b1)` 与 `.CYINIT(1'b1)` 都置 `(0,40,12)` ⇒ 该位 = 「取常量 1」档；`CYINIT=引脚` 档差分 170/116 格噪声，另两档未定形。`p_cynet`（同 slice LUT 驱动 CYINIT）报 `12-2285 A6LUT_O6` 冲突，改用 `p_cypin`。
- SMEM：`RAM32M` `WE=1` vs `WE=pin` → 8/59 格噪声，`WEMUX/WA7USED/WA8USED` 未拿到。
- 文档 `v7re/steps/T87_CLB_CORNERS.md`（含 CLB 站内最终位表）。

## §159 CLB 位级规格文档定稿（2026-11-11 收口）

交付给解码器的权威文档：`v7re/docs/CLB_BIT_SPEC.md`（206 行）+ 解码器 `v7re/scripts/clb_decode.py`。

### 一、核心公式（已 256/256 验证）

```
frame_off = 34 + (k & 1) - 2 * ((k >> 3) & 1)
word      = 40 (A/B) | 41 (C/D)
bit       = B_L - 4*(k>>4) - ((k>>1)&3)      B_A=B_C=15, B_B=B_D=31
```

对 `clb_init_locked_x12y20_4lut.json` 的 4×64=256 个格逐项相等，0 处不符。

### 二、解码器验证（6/6）

`python v7re/scripts/clb_decode.py _ff\d_fdre.bit` → `FFSYNC=1`；`d_fdce`→0；`d_lat`→`LATCH=1,CLKINV=1`；`d_cepin`→`CEUSEDMUX=1,CE_TARGET=[1,1,1]`；`d_ce1`→全 0；`p_ci1`→`PRECYINIT_1=1`。6 个设计与意图全部一致。

### 三、最大陷阱（必须写进解码器注释）

INIT 位号与「I0..I5 接 A1..A6 的哪个」绑定。未加 `LOCK_PINS` 的设计，Vivado 随机分配输入引脚 → **格集合不变、索引标签被置换**。实测 `_full8_i3.bit`（设计 INIT=3）直接套公式解出 `0x0000000100000001`（bit0+bit32）而非 `0x3`。解码必须先由 INT 侧 IMUX 解出引脚序。

### 四、置信度分层

- **确认**（多构造/多 BEL）：INIT 公式、FFSYNC、CLKINV、LATCH、AFFMUX O5/O6、AOUTMUX 4 位、SR 三位、PRECYINIT 常量 1 档。
- **强候选**：`CEUSEDMUX=(1,41,7)`（跨 CE 源稳定，但对照含一个混杂变量）。
- **候选**：CE 目标编码 `(23/24/25,41,0)`。
- **未拿到**：A5FF/A5FFMUX、SMEM 的 `WEMUX/WA7USED/WA8USED`、`PRECYINIT` 另两档。

### 五、零配置位的三类（别再找了）

LUT 输入 mux（24 条 always ppip）、BYP 旁路（4 条 always）、CE/CLK/SR 的**源选择**（3 条 always）。CLB 的 151/146 条「PIP」全是 ppip：**93 always（硬连线）+ 58 hint**。

### 六、适用范围限制

1. 只在 `SLICE_X12Y20`（CLBLM、grid_col 20、Y=20 上半区）实测；跨列/跨行未验证。
2. V7 帧偏移（INIT 34/35、AOUTMUX 3/4/6/7、AFFMUX 30）与 prjxray A7（30/31）**不同体系**，不能套用。
3. 表只适用 **CLBLM**；T54 已证 CLBLL 布局不同（`SLICE_X8Y20` 用本表解 INIT 会 13 缺 13 多）。

### 七、下一步选项

- **A（推荐）**：标定 CLBLL（`SLICE_X8Y20`），用同一套公式拟合新的 `B_L`/帧偏移 → 得到两套表。
- B：跨列验证（选 grid_col 10 / 30 的 slice），确认块基址与帧偏移的列无关性。
- C：继续 HCLK_CMT 剩余 32 源。
- D：SMEM 三位 + A5FF（需要更严的闸门构造）。
### S60 续4 · X1 半区复核（2026-11-11）

- **方法修正**：LOC 扫描差分噪声过多，改为「同一 LOC、只改一个参数」的成对实验，差异只剩目标位。
- 实测：`X0Y0` QPLL 4→5 → `(31506,w45,b16)`；`X1Y0` → `(36718,w45,b16)`；`X1Y2` → `(5242,w45,b16)`。
- ⇒ **X1 半区 = X0 + 5212 帧**；统一公式 `block_base = band_base(i) − 272 + (X1 ? 5212 : 0)`，两个独立实测点均命中。
- 入库：`v7_verified` 190→**193**（HALF_OFFSET + X1Y0/X1Y2 块基址）。
### S61 · HCLK 干净复核（2026-11-11）

用「同一 LOC、只改一个参数」成对实验 + 第二个 LOC 复跑取交集，重测 S59 的 HCLK 判读：

- 4 设计：`bgA/bhA`（`SLICE_X8Y11`）、`bgB/bhB`（`SLICE_X10Y20`），每对只差 `BUFG` ↔ `BUFHCE`。
- 结果：`runA = 90 cell`、`runB = 90 cell`、**交集 86**、各 run 独有 **4** 个 → **86 个与位置无关的时钟网络位**，4 个是消费方 slice 的局部位。
- runA 局部：`(31680,w22,b23)(31681,w22,b25/b26/b29)`；runB 局部：`(31716,w40,b23)(31717,w40,b25/b26/b29)`。
- **纠正 S59**：`31680` 那格不是 HCLK 网络位，是 slice 局部选择位；S59 的 31 个 `hclk_only` 里 28 个属真配置，其余是噪声。
- 86 格按帧聚簇：`2588–2589/7834–7835/13081/28818–28819`（edge30 时钟脊）、`27328–27391`（BUFH 入口）、`27469–27945`（HCLK 纵向轨道）、`28356–28563`（扇出）、`33868–34065`（另一端脊 + BUFHCE 站点簇）。
- 新表 `clk_cells(net,frame,word,bit,note,date)` **94 行**；`v7_verified` 193→**196**；报告 `step03_pip/S61_HCLK_CLEAN_RECHECK.md`。
- **方法学（回灌全局）**：配置位归属一律「同 LOC 只改一参 + 二次 LOC 取交集」；单次差分只给上界。

## 161. 第一优先度：寻找 PIP 复用规律（2026-11-11 决策）

**一句话**：本项目第一优先度只有一个 —— 找出 PIP 复用发生在哪几层、规律是什么、规律能否反用；其余工作全部排在它之后。本节是优先级判官，与 §97 配套。编号 151 已被两节 §151（CRC 相关）占用，故本节取 161。

### 优先级阶梯（1 最高，逐级以 0 差异/分子分母为判据）

| # | 目标 | 当前分子/分母 | 判据（达到才能往下一级） | 复算入口 |
|---|---|---|---|---|
| 1 | 复用规律的**完备性**：172 族的位集合能否由「族名 + 源名」生成 | **3,552/3,634 = 97.7%**（定律 3,456 + 复合组模型 96，2026-11-11 接入） | 剩 82 条（6 个长线族）达到 ≥80/82 由名字推出且 0 差异 | `python step03_pip/gen_slots.py` |
| 2 | 规律的**表达形式**：7 谱型 + 两轴归属 + 16 配置压成常数表 | 172/172 谱型命中；64/64 mux 族 0 差异 | 172 族逐族 0 差异 | `python step03_pip/gen_mux.py` |
| 3 | 规律的**外部校验**：四条独立支路 | 器件模型 115/115、Vivado `get_pips` 1,155/1,263、不变量 231,656 位 0 违例、E8 50,176 帧全等 | 四支路同时成立 | `python v7re/scripts/verify_all_pip.py --normalize`；`python v7re/scripts/tamper_localize.py --check tamper/ref/ref.bit` |
| 4 | 规律的**可迁移性**（判据驱动，仍服务主线） | **结构形式已跨 3 类 tile 验证**（INT_L/R、HCLK_CMT §162、HCLK_BRAM §163）；坐标逐类型不同；类型 3/115、器件 0/1 | 再测 1 个非时钟类型（`CLK_HROW_TOP_R`）仍同形；任一类型 0 差异率 <50% 即证否普适 | `python step03_pip/_q_transfer_hclk.py` |
| 5 | 规律的**反用**（下游应用，不单列章节） | 生成 95.1%；可解性 1,066/1,066；单 bit 检出 99.44% | 作为 Q3「规律能反用」的佐证 | `python step03_pip/p1_solvability.py` |

### 明确不做（除非 1–3 全部闭合）

| 项 | 为什么不是第一优先度 |
|---|---|
| ECC 与帧地址耦合（`ECC = L(data) ⊕ A(frame_addr)`，`A` 未定） | 它挡的是「可加载」，与「找规律」正交 |
| `site_frames` 补全（缺 16,979,200 行） | 数据层工作量，不改变规律陈述 |
| 跨家族 / 跨器件位库迁移 | 当前证据 0/1，先有规律再谈迁移 |
| 篡改定位器上板、CLB 站点 INIT 映射、IOB/OLOGIC 等类型普查 | 下游或旁支，会稀释主线 |

### 理由

主线收窄后，唯一在关键路径上的缺口是 **6 个长线族的 82 条 feature**（占 3,634 的 2.3%）——它就是论文里「规律覆盖率」这一句的分母。其余工作（ECC、数据层、迁移、上板）都不会改变「复用规律是什么」这句话，只会让成文变成资料汇编。

6 族实测（`law_cells`，INT_L，sense=1）：`LVB_L0` 18 源/36 行、`LVB_L12` 18/36、`LH0` 12/24、`LH12` 12/24、`LV_L18` 12/24、`LV_L0` 10/20；列重分布分别为 `6,6,6,3×6` / 同 / `4,4,3,3,3,3,2,1,1` / 同 / `4,4,4,3,3,3,3` / `4,4,3,3,2,2,2`。

### 失效条件（何时改主线）

若 82 条最终判定「不可由名字推出」（命中 <60/82），则主线表述改为「172 族中 170 族可公式化、2 族为表数据」，并在论文中作为边界如实写；此时第一优先度降级为**数据完整性**，不再继续找规律。

### 2026-11-11 晚：复合族组模型接入生成器

- `step03_pip/gen_slots.py` 新增 `composite_models()`（读 `v7re/steps/composite_groups.json`，每族 4 组 × core 3 格 + drops 2 源各去 1 格 + extras 2 源各加 1 格）与覆盖率汇总。
- 实测：**96/96 源 0 差异**（6 个复合族 `CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`），覆盖率由 3,456/3,634 = 95.1% 升到 **3,552/3,634 = 97.7%**；`[其它]` 从 12 族降到 **6 族 = 82 条 feature**（`LH0`、`LH12`、`LVB_L0`、`LVB_L12`、`LV_L0`、`LV_L18`）。
- 口径：复合族是**表级**模型（每族 4 组常数 ≈ 28 个数字），不是纯定律；统计里与「定律 3,456」分列。备份 `step03_pip/_gen_slots_backup_20261111.py`。

### 2026-11-11 深夜：第 2 步 —— 6 个长线族 82 条的定性（结论：表数据，不可由名字推出）

判据：若 82 条能由「族名 + 源名」推出，覆盖率从 97.7% 升到 100%；否则按 §161 失效条件改口径。

**结构事实（`law_cells` sense=1 实测，脚本见下方复算命令）**

| 族 | 源 | 格 | 每源格数 | 二分 | 完全二分 | 跨族共享格 |
|---|---|---|---|---|---|---|
| `LH0` | 12 | 9 | 恒 2 | 是（2 连通块） | 否（12/20 边） | `(0,2,0)`、`(1,6,0)` 与 `LV_L0` 共用 |
| `LH12` | 12 | 7 | 恒 2 | 是 | 是（K(4,3)，12/12） | 无（与其它族不共格） |
| `LVB_L0` | 18 | 9 | 恒 2 | 是 | 是（K(6,3)，18/18） | 与 `LVB_L12` 同形不同位 |
| `LVB_L12` | 18 | 9 | 恒 2 | 是 | 是（K(6,3)，18/18） | 同上 |
| `LV_L0` | 10 | 7 | 恒 2 | 是 | 否（10/12 边） | `(0,2,0)`、`(1,6,0)` |
| `LV_L18` | 12 | 9 | 恒 2 | 是（2 连通块） | 否（12/20 边） | `(0,0,2)`、`(0,0,9)` 与 `LH0`/`LV_L0` |

**两条候选规则的证伪结果**

| 假设 | 检验 | 结果 | 判定 |
|---|---|---|---|
| H1：源的方向类（N/S/E/W/NE/… /long）决定它的格对 | 每个族内按方向类分组，统计组内格对是否唯一 | **22/36** 组唯一，14 组内出现 ≥2 种格对 | 否 |
| H2：方向类决定二分 A 侧（= 组选择位） | 每族统计「方向类 → A 侧格」是否唯一 | **25/36** 组唯一，11 组内 A 侧不唯一 | 否 |

**结论（口径更新）**

- 82 条 = **6 张逐族表**（每表 ≤9 个格 + ≤18 条边），是**数据**，不是定律；与 mux/BEG 的「名字即坐标」不是一个等级。
- 因此第 1 步的完备性是 **3,552/3,634 = 97.7%**（定律 3,456 + 复合组模型 96），剩余 **82 条（2.3%）如实标注为表数据**，不再声称可公式化。
- 【推断】这 6 族是长线（`LV/LVB/LH`）在 tile 边界的进出位，位池与相邻逻辑列共享（`LH0`/`LV_L0`/`LV_L18` 的 3 个共享格即证据）；【未测】其分配是否由长线的物理邻接决定——仓库里没有长线的内部几何，只有 `tileconn` 的端口对，故无法判定。
- 跨族共享格实测（`_q_longline_struct.py` 输出）：`(1,6,0) ∈ {LH0, LV_L0, LV_L18}`、`(0,2,0) ∈ {LH0, LV_L0}`、`(0,9,0) ∈ {LV_L0, LV_L18}` —— 即这三个长线族的位池确实交叠。
- 复算：`python step03_pip\_q_longline_struct.py`；生成器影响：`gen_slots.py` 的 `[其它]` 计数由 12 族降为 6 族、82 条。

### 编号清理记录（2026-11-11，仅改编号、不动正文）

- 全文件有三套历史编号：数字节（`## N.`）、`§N` 节（§149–§159）、`SN` 节（S26–S60）。本次**只清理数字节**：把重复出现的第 2、3 次改为 `N.1` / `N.2`（共 38 处，原编号保留在前缀里，因此正文里“见 §87”仍指向第一次出现的那节）。
- 本节原写 `## 151.`，与另两节 `## §151`（CRC 两篇）在阅读上撞号，故改号为 **161**（备份：`step03_pip/_status_before_renumber_20261111.md`）。
- 清理后：数字节 145 个、无重号、最大 161；`N.x` 子号 41 个、无重号；`\ufffd` = 0；行数不变（5,739）。
- 仍存在（未动，属另一会话正在写的系列）：`## §151` 两节同号（`§151 · 比特流尾部包序列与器件级 CRC` 与 `§151 CRC 签名依赖绝对帧位置`）。引用时请写全标题，勿只写 §151。

### 边界

- 本节只定优先级，不改任何既有结论；数字以 §96/§117/§119 与 `PIP_REUSE_STRUCTURE.md` 为准。
- 本节写入日期 2026-11-11，与 §97（主线定义）、§92（现状评估）构成三层：定义 → 评估 → 优先级。
### S62 · S52 门控位双位置复核（2026-11-11）

用 S61 的方法（同 LOC 只改一参 + 第二个 LOC 取交集）复核 S52 的 7 个命名位：

- **CE 组**（`CE=1'b1` vs `CE=port`）交集 5 格：`(0,0,14)(0,0,17)(1,1,7)(21,1,0)(25,1,0)` —— `(1,1,7)` CE_SOURCE_FABRIC ✅。
- **FF 组**（纯 LUT vs +FDRE）交集 23 格：含 `(0,1,16)` FF_USED ✅、`(1,0,7)` FF_D_BYPASS ✅，其余为 AFF 配置（`(1,0,25/26/29)` 等）与 FF 输入 IMUX；另有 4 格落在 base+147/149（相邻 INT 块，不算本 slice）。
- **SR 组**（`R=1'b0` vs `R=port`）交集 **仅 1 格** `(1,1,3)` SR_SOURCE_FABRIC ✅（其余 39 格全是位置相关漂移）。
- **推翻 S52 两条**：`(1,1,15)` CE_SR_CONST_MARK_A、`(1,1,23)` CE_SR_CONST_MARK_B（任何双位置交集都不出现）；`(1,0,19)` FF_MULTI_OR_FABRIC_D 降级【未定】。
- 新增 2 个 CE 通路门控位 `(0,0,14)(0,0,17)`。
- 结构事实：加 1 个 FF ⇒ 23 个位置无关位；解码器须按**块窗口 36 帧**过滤，否则会误收相邻 INT 块的布线位。
- `v7_verified` 196→**205**；报告 `step03_pip/S62_GATE_BITS_RECHECK.md`。
### S63 · 长线（LV/LH）能否点亮剩余门控位 —— 负结果（2026-11-11）

**动机**：66 个门控位里仍有 60 个从未被任何设计点亮，猜测与「长线/全局线进入 switch box 的使能」有关。

**实验**：4 个设计，`u_s(LUT6) → u_d(LUT6) → FDRE`，唯一变量是**布线距离**：

| 设计 | `u_d`/FF 位置 | 结果 |
|---|---|---|
| `v_s` | `SLICE_X8Y11`（同 slice，短） | 基线 |
| `v_v` | `SLICE_X8Y84`（同列，跨 73 行 → 强制 LV 长竖线） | 差 308 格 |
| `v_h` | `SLICE_X80Y11`（同行，跨 72 列 → 强制 LH 长横线） | 差 286 格 |

**判读**：把差异归一到 `(frame−31680, word−22, bit)` 后与 `int_holes.json` 的 66 格求交 ——
**只命中 2 格**：`(0,1,16)` 与 `(1,0,7)`，即 S62 已确认的 `FF_USED_IN_SLICE` / `FF_D_BYPASS_A`。
**没有任何新的门控位被点亮。**

**结论**：剩余 60 格**不是**长线/全局线入口使能。结合 S52（17 个 slice 内组合设计零命中）与语料扫描（6,015 个设计仅 3 格），
这 60 格最可能属于尚未实例化的资源：`IDELAY/ISERDES/OSERDES`（IO 侧）、`BUFMR/BUFIO` 的 fabric 侧、或 `CARRY4` 的专用进线。**盲试组合的边际收益已接近 0，需要按资源类型定向设计。**

**副产品**：`v_v`/`v_h` 的 gate-offset 差异里出现 `(31681,22,7)(31681,22,13)`、`(31827,23,9)(31827,24,0/1)` 等，均属**消费方 slice 的局部选择位**（S61 同类），印证了“局部位 ≠ 网络位”的区分。
### S64 · REUSE_RULES v2 收口（2026-11-11）

`step03_pip/REUSE_RULES.md` 重写为 **v2**（11,726 B），把 2026-10-27 之后的全部结论固化：

- **§1 家族与形状律**：L1 位池族内私有 1,598/1,598、L2 `N=a×b`/`K=a+b` 344 族零反例、L3 每源 **2 位或 5 位**（旧"2 或 4 位"已修正）；2 位源 2,004 / 5 位源 1,632，且 5 位族 = IMUX+BYP+FAN+CLK+CTRL+GFAN 共 70 族。
- **§2 坐标律**：新增半带规则 `wof(y)=2*(y%50)+(y%50>=25)`；块基址改为「只能查 `frame_blocks`（1,038 块 = 7×5,180）」；`word 50` 按块类型区分（fabric=校验 / io72·edge30·CMT·GTX=真实配置）。
- **§3 差分三语义 + 双位置交集纪律**（S61）：单次差分只给上界，交集才是配置位本体。
- **§4 复用边界**：END 侧 2,228 条 0 位（S35）、always ppip 2,598 条无位（S16）、L/R 同名对同一物理 mux（140 去重，S33）。
- **§5 覆盖度**：INT cell 96.03%，66 格性质已排除"长线族选择位"与"长线入口使能"两条假设。
- **§6 四类编码**：家族 / 单位开关 / 码字 / 时钟网络，并给各 tile_type 归类与完成度。
- **§7 统计口径**：172 族 / 12,168 cell / 1,598 唯一位置 / 3,636 feature / 140 去重 / 96.03%，并列出常见混用（181 vs 140 vs 3,636 vs 3,737）。
- **§10 与 v1 的差异**：7 条变更（器件型号、半带、5 位、word 50、块基址、新增四节、2 条推翻 1 条纠正）。

原 v1（2026-10-27）已就地覆盖；其内容在 `PIP_REUSE_LAW_FULL.md` / `PIP_REUSE_LAW.md` / `REUSE_LAW_TEST_PLAN.md` 中留存。
### S65 · 5 位源机制（2026-11-11）

`step03_pip/S65_FIVE_BIT_MECHANISM.md`。全量统计 172 族（INT_L 侧）后得到唯一结构：

- **5 位 = 1 位隐式上层 + 4 位显式下层**。上层 `N/4` 组 one-hot，**只写选中那条的 1**（其余从不写 0）；下层固定 4 条线，**全部写入**（1 开 3 关）。
- 三条形状：`(N=24, coords=10, 隐式 6, 显式 4)` × 64 族；`(16, 8, 4, 4)` × 6 族（GFAN/CLK/CTRL）；**2 位族 explicit=0**（两级都隐式，`(20,9,9,0)`×96、`(12,7,7,0)`×4、`(18,9,9,0)`×2）。
- 隐含律：隐式列计数恒 = 4（每组固定 4 成员）；`N = (N/4)×4`；`coords = N/4 + 4`。
- **未解**：下层为何要显式写 0（H1 电平敏感 / H2 译码共享），判别实验 = 同族「成员相同组不同」的源，比较下层 4 位是否恒等。
- 口径修正：`1,632 个 5 位源 = 64×24 + 6×16`（先前"70 族 ×24"错误）；`K` 是 coords 数不是每源位数。
- 落盘：`E:\v7work\five_bit_structure.json`；`v7_verified` 205→**210**。
### S66 · REUSE_RULES v3 回灌（2026-11-11）

`step03_pip/REUSE_RULES.md` 升 v3（9,588 B），把 S65 的两级结构写进正文：

- **§1.4 重写**：删除「机制未解」表述，改为「两级 mux 树 + 第二级显式全写」；补 5 位源数拆分 `1,632 = 64×24 + 6×16`（修正"70 族×24"的错误）。
- **§6.0 新增**：家族类两级结构图 + 六类 tile_type 的组数/第二级/coords/每源对照表；给出唯一判据——**第二级是否显式写 0 决定每源 5 或 2 位**，与 tile_type、族大小、家族名无关。
- **§1.2 口径澄清**：`K=a+b` 的 K 是 coords 数（IMUX 10 / GFAN 8 / EE2 9），不等于每源位数。
- **§11 变更记录**：v2→v3 五项（含解码错误模型按类区分：5 位族缺 0 = 冲突，2 位族缺位合法）。
## 162. ②a 跨类型可迁移性判定：HCLK_CMT 与 INT 同形（2026-11-11）

**问题**：§161 阶梯第 4 级「可迁移性」原来只有 2/115 类型、0/1 器件。本节用**已有远端差分数据**（`hclk4/5/6`，不新跑 Vivado）把 HCLK_CMT 套进 INT 的同一套判据，判定「复用律是 INT 专属还是结构可迁移」。

**数据**：`step03_pip/out/hclk_mux13_cells.json`（`_q_hclk_mux13.py` 生成）→ 判定脚本 `step03_pip/_q_transfer_hclk.py`。

**判据与结果（族 `MUX_CLK_13`，48 源中实测差分 11 源 + 2 个基线）**

| 判据 | 内容 | 结果 | 证据 |
|---|---|---|---|
| C1 | 位池可定位 | **是** | 26 个置 1 格全部落在 `minor 26..29` 的 `off26/27 w51`、`off28 w76..79`、`off29 w27..w30` |
| C2 | 每源恰 1 个组槽位格、互不重复 | **是（11/11）** | MMCM 组：`off29` 的 `w27..w30` × 半区（`bit 6`=高、`bit 22`=低）；PLL 组：`off28` 的 `w76..w79` × (`bit 25`/`bit 9`) |
| C3 | 组内码字互不相同 | **是**（MMCM 6/6、PLL 5/5） | 码字都在 `off26/27` 的 `w51`，MMCM 落 `bit 0..6`，PLL 落 `bit 4..6` |
| C4 | 组槽位由「组内序号」单调决定 | **否** | MMCM 序号 2,4,6,8,9,10 → 槽位 (29,29,lo) (29,28,hi) (29,28,lo) (29,27,hi) (29,30,lo) (29,27,lo)；PLL 同样非单调 |

**结论（三档判定）**

- **形式可迁移**：HCLK_CMT 的 mux 族与 INT 同构 —— **1 个一热组槽位 + 2..4 个码字格**，组内码字唯一，组选与码选分离（跨组出现相同码字是设计如此）。
- **坐标不可迁移**：位池不在 INT 的 `frame_off 16..25`，而在**相邻逻辑列块的尾帧** `minor 26..29`（A1 已证：时钟列没有自己的 FAR col）；且源→槽位不是名字的函数（C4 否，且 13/48 实测）。
- 因此阶梯 4 的表述改为：**「结构形式可迁移（2 类 tile 已验证），坐标需逐类型实测」**；不再只是「2/115 未测」。

**【推断】** 组槽位一热 + 码字分区这套结构，可能是 7 系列 CRAM 里「多路选择」的通用编码方式（INC：HCLK_CMT 与 INT 在帧布局、位宽、半区规则上都不同，却共享同一编码范式）。**【未测】** 其它 113 种 tile 类型、以及 die 变体（`ffg1761` vs `ffg1157`）上的坐标是否只差常数偏移。

**可证伪条件**：若在 `CLK_HROW_TOP_R`（D 类、224 族、12.7 源/族）上套同一判据出现「每源组槽位格数 ≠ 1」或「组内码字重复」，则「结构形式可迁移」不成立，只能写「INT 与 HCLK_CMT 两个特例」。
### S67 · INT 66 个「洞」的归属（2026-11-11）

`step03_pip/S67_HOLE_ATTRIBUTION.md`。对远端 13,749 个 >15 MB 的 .bit 做全语料扫描（`/opt/lzh/step18/holescan_all.py`，16 进程）：

- **25/68 坐标在真实设计里被点亮**：`(1,1,30)` 1,284 次、`(0,1,16)` 334、`(1,0,31)` 192、`(1,0,7)` 144、`(1,0,19)` 98、`(1,1,15)`/`(1,1,23)` 各 93、`(0,1,31)` 40、`(1,1,3)`/`(1,1,7)` 各 21、`(1,1,19)` 16、`(1,0,23)` 9、`(0,0,12)` 5 …
- **17 个可映射到 CLB 家族**：`A5FF/B5FF/C5FF/D5FF`（五输入 LUT 的 FF 选择）、`PRECYINIT`、`CARRY4`、`ALUT/BLUT/CLUT/DLUT`、`WEMUX` ⇒ **36 帧块的低 offset 是 INT 与 CLB 的真混合区**，此前“INT 低 / CLB 高（16..35）”的划分是错的。
- **offset 2..3 的 32 格在 13,749 个设计中零出现** ⇒ 485T 不配置（VBRK/长线分段候选）。
- **修正 S52**：`(1,1,15)=C5FF`、`(1,1,23)=D5FF`、`(1,0,7)=A5FF`（原 FF_D_BYPASS/CE_SR_MARK 命名作废）。
- 独立交叉验证：S5 差分实测的 `PRECYINIT (0,40,12)` 与语料统计 `(0,0,12)` 同坐标。
- `v7_verified` 210→**222**。
## 163. ②b 跨类型可迁移性：时钟区 6 对受控差分（2026-11-11）

**做法**（不新跑 Vivado，复用远端已有 `s0/s1` 成对实验）：先按 `.pips` 判「是否单变量」，再算位流差分，最后用 `frame_map` 把差分格解成 FAR 字段。

**① 控制性判定（`.pips` 集合差）**

| 对 | 目录 | pips 差行数 | 结论 |
|---|---|---|---|
| `y2_s0/y2_s1` | `work/clkmux3/out` | **0** | 只改了一个属性，布线完全一致 |
| `y4_s0/y4_s1`、`y5`、`y6`、`y7` | 同上 | **0** | 同上 |
| `s0sel/s1sel` | `work/bufgmux/out` | **0** | 同上（`.v` 差只有 `BUFGCTRL.S0/S1` 互换） |

**② 位流差分指纹（每对都只有 2 个数据格）**

| 对 | 置 1 格 | 清 0 格 | ECC 格 |
|---|---|---|---|
| `clkmux3 y2` | `frame7834 word94 bit11` 0→1 | `frame7835 word94 bit3` 1→0 | 16 |
| `clkmux3 y4` | `7834/95/11` | `7835/95/3` | 16 |
| `clkmux3 y5` | `7834/95/27` | `7835/95/19` | 18 |
| `clkmux3 y6` | `7834/96/11` | `7835/96/3` | 18 |
| `clkmux3 y7` | `7834/96/27` | `7835/96/19` | 20 |
| `bufgmux` | `13080/0/11` | `13081/0/3` | 12 |

**③ 三条结构（与 INT 同形的判据）**

- **位对跨两帧**：置 1 在 `minor 26`，清 0 在 `minor 27`，同一 `word`、位号相差 **8**（11↔3、27↔19）。INT 的「位对 (B,B+1) + parity/phase 分离」在时钟区表现为「相邻两帧 + 位号差 8」。
- **半区一热**：`y2/y4/y6` 用 `bit 11`（低半区），`y5/y7` 用 `bit 27`（= 11+16，高半区）。与 HCLK_CMT「每字两半区各一个标记位」同形。
- **落点同一区域**：全部在 **FAR `col 75` 的 `minor 26/27`**（= 逻辑列块尾部的时钟区）；HCLK_CMT 落在 `col 33` 的 `minor 26..29`，规律一致。

**④ 类型归属**：`col 75` 的时钟类 tile 是 `HCLK_BRAM_X75Y{26..338}`（7 个，每时钟区一个），故这些位属 **`HCLK_BRAM`** 类型（非 INT）。【口径】按列归属推断，**未做 site 级对照**；`bufgmux` 改的是 `BUFGCTRL.S0/S1`，其配置位存放在时钟列而非 BUFG 站点自身，这一点与「时钟列无自己的 FAR col、配置位寄生在相邻逻辑列块尾帧」一致。

**⑤ 结论**：阶梯第 4 级从「仅 HCLK_CMT」扩到 **3 类 tile**（`INT_L/R`、`HCLK_CMT`、`HCLK_BRAM`），三处都呈「位对 + 半区 + 一热」，可写「**结构形式可迁移**」；坐标随类型/列不同，仍需逐类型实测。

**可证伪条件**：若在 `CLK_HROW_TOP_R`（224 族）上出现「每源置 1 格数 ≠ 1」或「位对不跨帧」，则「结构形式可迁移」不成立。

**复算**：`step03_pip/_remote_ctrl_bits.py`（远端差分，输出 `out/ctrl_all.json`）+ 本地 `frame_map` 解 FAR。
### S68 · 8 个「点亮无表」格的归属尝试（2026-11-11）

`step03_pip/S68_ATTRIB_CORRELATION.md`。对 13,749 个 .bit 判读 10 个目标坐标，再读同目录 .v 做关键词相关性统计。

- **限制**：13,749 里只有 **1,234（9.0%）** 有同目录 .v，且以本项目探针为主（`DONT_TOUCH` 基准率 91.7%）⇒ 结论只在该子集内成立。
- **可归属 7 个**：`(1,1,19)`→**CARRY4（28×，16 个设计）**、`(0,0,20)`/`(0,1,20)`→CARRY4、`(0,1,8)`/`(1,0,27)`→分布式 RAM/SRL（LUT6_2+RAM64/128/256+SRLC32 完全共现）、`(1,0,31)`/`(0,1,31)`→时钟（PLL/BUFG，2–3.5×）。
- **不可归属 1 个**：`(1,1,30)` 1,284 个设计点亮，但与全部 RTL 特征**负相关**（BUFH 0.1% vs 基准 17%）⇒ 疑为探针设计共性痕迹，非功能位。
- **方法学结论**：语料找 .v 的做法源覆盖率太低且偏斜；要可信归属必须自造定向设计（CARRY4/分布式 RAM/时钟各 2–3 个 × 双位置）。
- `v7_verified` 222→**229**。

## 164. ②c：`CLK_HROW_CK_MUX_OUT_L8` 源槽位公式（2026-11-12，19/62 源实测，GCLK 子空间 19/32）

目标：判 `CLK_HROW` 类多源族能否像 INT 一样「由源序号生成」。本轮在远端 `clkmux3` 工程新建 **19 个受控位流**（`y<k>_s0`，只改 `BUFGCTRL_X0Y<k>` 的 LOC），用 `.pips` 做族归属，得到可直接执行的槽位公式。

> **两次自我更正**（留档，避免重踩）：①初稿把 `y1..y7` 当「行变体」，错——变的是 `BUFGCTRL_X0Y<k>` 站点，即**源序号 k**；②第二稿只看 `frame 2589`，漏掉 k≥8 的槽位落在 `frame 2588`，误判「公式失效」。

### 1. 受控性与族归属（【数据事实】）

- 19 个位流的 `.v` **逐字节相同**（`diff y2_s0.v y4_s0.v` 为空），唯一差异是 `set_property LOC BUFGCTRL_X0Y<k>`。
- `.pips` 同一行（`clkmux3/out/y<k>_s0.pips`）：
  `CLK_HROW_BOT_R_X192Y78.CLK_HROW_R_CK_GCLK<k> ->> CLK_HROW_CK_MUX_OUT_L8`
  ⇒ 同一族 `CLK_HROW_BOT_R.CLK_HROW_CK_MUX_OUT_L8` 的 19 个不同源。
- 该族 62 个源（模板 `CLK_HROW_BOT_R.json`，`pip_defs` 为 `[src, dst, delay, inverted]` 顺序）：
  **`CLK_HROW_R_CK_GCLK0..31`（32）+ `CLK_HROW_CK_IN_L0..13`（14）+ `CLK_HROW_CK_IN_R0..13`（14）+ `CLK_HROW_CK_INT_0_{0,1}`（2）= 62**。
- 构建环境：必须 `export LANG=C.UTF-8; unset LANGUAGE`，否则 Vivado 2017.2 报 `locale::facet::_S_create_c_locale name not valid` 并 core dump。

### 2. 槽位公式（19/19 命中，0 例外，【数据事实】）

```
组      p = k // 16            (k = GCLK 序号)
槽位    s = k % 16
frame   = 2589 - floor(s / 8)
word    = 24 + floor((s % 8) / 2)
半区    = (s % 2) ? 高位 : 低位
标记值  = 0x800a >> p          (p=0 → 0x800a = bits{1,3,15}；p=1 → 0x4005 = bits{0,2,14})
镜像    = 同 frame 下 word + 49（24..27 → 73..76）
```

实测样本（`frame/word` 的原值）：

| k | frame | word | 值 | 说明 |
|---|---|---|---|---|
| 1 | 2589 | 24 | `800a0000` | s=1 高半区，组 A |
| 8 | 2588 | 24 | `0000800a` | s=8 低半区，组 A |
| 16 | 2589 | 24 | `00004005` | s=0 低半区，**组 B**，标记值右移 1 位 |
| 17 | 2589 | 24 | `40050000` | s=1 高半区，组 B |
| 24 | 2588 | 24 | `00004005` | s=8 低半区，组 B |
| 31 | 2588 | 27 | `40050000` | s=15 高半区，组 B |

另有 k=1..7（2589, w24..w27 高低交替）、k=9..15（2588, 同构）全部符合上式，共 19 个 k 值。

### 3. 容量账（关键结论）

- **GCLK 子空间刚好铺满**：32 个 GCLK（0..31）× 每帧 8 槽 = 需要 4 帧容量，实际用 **2 帧 × 8 槽 × 2 组 = 32 槽**，一一对应，无空洞。
- 全族 62 源 = 32(GCLK) + 30(CK_IN_L/R + CK_INT)。按「标记值右移 1 位」的规律，后 30 个源预计用 `0x2002`（组 C）与 `0x1001`（组 D）标记，落在更多帧里 —— **未测**（要造 CK_IN 路径的受控对，成本高于 GCLK）。
- 标记值随组右移这一事实，说明「组」编码在**位的低 4 位区间内平移**，而槽位编码在「帧 × word × 半区」三维里 —— 与 INT 的「组槽位（帧 16+r）+ 4 位码」是同一设计思想的不同分配。

### 4. 判定与剩余

- 【数据事实】实测 **19/62 源（30.6%）**，GCLK 子空间 **19/32（59.4%）**；19/19 由上式复现，0 例外；`.pips` 证明同族不同源。
- 【推断】k=0、18..23、25..30 的剩余 GCLK 槽位可直接由公式给出（无需再测即可预测）；后 30 个 CK_IN 源需要另一类受控设计。
- 按写死的阈值：仍**不能**宣布「整族可由名字+序号生成」——GCLK 子空间的结构已闭合（2 帧 × 8 槽 × 2 组 = 32），但 30 个 CK_IN 源的组 C/D 未验证。
- 复算：`python3 step03_pip/_remote_words16.py`（k=1..16 原值表）、`_remote_check_group.py`（k=1/8/16/17/24/31 抽查）、`_remote_build_y8_11.sh` / `_remote_build_y12_16.sh` / `_remote_build_y17_24_31.sh`（构建）。

## 165. CK_IN 源在 HROW 家族里没有置位字段（2026-11-12）

**问题**：`CLK_HROW_CK_MUX_OUT_L*` 62 个源里，32 个 GCLK 已由 §164 的公式闭合（实测 19/32），剩余 30 个（`CK_IN_L0..13` 14 + `CK_IN_R0..13` 14 + `CK_INT_0_{0,1}` 2）的槽位在哪里？

**实验（受控对，`/opt/lzh/v7re/work/ckpair`）**
- `a_mmcm.bit`：`MMCME2_ADV_X0Y6` → `BUFH` → `FDRE @ SLICE_X0Y100`；`.pips` = `CLK_HROW_TOP_R_X192Y338.CLK_HROW_CK_IN_L13 ->> CLK_HROW_CK_MUX_OUT_L0`。
- `b_bufg.bit`：`BUFGCTRL_X0Y1` → 同一 `FDRE @ SLICE_X0Y100`；`.pips` = `..._R.CLK_HROW_R_CK_GCLK1 ->> CLK_HROW_CK_MUX_OUT_L8`。
- 两者不同车道（L0 vs L8），故**不是严格受控对**（共 159 个差异字），但足以做「标记字段在不在」的定性判据。

**标记扫描（全比特流，74,400 个数据字）**
| 标记值 | 含义 | a（CK_IN13 源） | b（GCLK1 源） |
|---|---|---|---|
| `0x800a` 低/高半 | 组 A | **0 处** | (2589,73)、(7835,24)、(7835,73) |
| `0x4005` | 组 B | 0 处 | 0 处 |
| `0x2002` / `0x1001` | 组 C / D（预测） | 0 处 | 0 处 |

（`a` 里唯一命中 `0x1001` 的 (27360,99) 是数据字 `0x01001001` 的低半偶合，不是标记。）

**判读**
- 【数据事实】以 CK_IN 为源时，HROW 家族的选择字段**全零**；以 GCLK 为源时才出现 `0x800a` 一热标记。
- 【推断】`CK_IN_L/R*` 与 `CK_INT_0_*` 是**默认通路**：HROW mux 的置位字段只编码「改成某个 GCLK」，不编码选哪个 CK_IN —— 后者由**上游 `HCLK_CMT_MUX_CLK_<k>` 决定**（`CK_IN_L0` ← `HCLK_CMT_MUX_CLK_0`，`tileconn.json` `grid_deltas [104,0]`）。
- 与容量账自洽：32 个 GCLK 恰好填满 2 帧 × 8 槽 × 2 组 = 32 槽，没有给 30 个 CK_IN 留槽。

**可反驳预测（未做，下一步）**
- P1：把时钟源换成另一个 CK_IN index（如 `CK_IN_L0`），HROW 侧位流应**逐字不变**，只有 `HCLK_CMT` 侧变。
- P2：若在 `b` 里再叠加一个 CK_IN 源（同车道 L8），`0x800a` 应被清掉。
- 任一预测不成立 ⇒ 上述「默认通路」判读作废，CK_IN 仍需独立槽位。

**边界**：单车道对比（L0 vs L8）、单设计对；`CK_INT_0_*` 完全未测。


## §160 交接提示词定稿 + 发现 site_frames 残缺（2026-11-12）

### 一、交付
`AGENT_HANDOFF_PROMPT.md`（根目录，224 行）：可直接交给另一个 agent 的完整交接提示词。
按 AGENTS.md 硬规则先用 `prompt-optimizer` 的 `optimize-user-prompt`（`user-prompt-professional` 模板）产结构，再人工补硬数据附录（优化器会把领域数字抽掉）。
内容：现状摘要（已确认/候选/未测/失败路线）、目录与数据库清单（标注权威 vs 派生）、关键脚本清单、8 条方法论、5 条禁区、P0–P5 优先级、汇报格式、附录 A 环境、附录 B 硬数据基线。

### 二、写作过程中发现的真问题：本地 `site_frames` 是残缺表

```
select count(*), min(frame), max(frame), count(distinct frame) from site_frames
→ (19819900, 32, 36687, 6104)
```

全量应为 **36,799,100 行 / 9,156 个 distinct frame**（763 block × 12 个 frame_off），文件 7,581 MB（全量 Build 记录为 7,949 MB）。
`min(frame)=32` 说明它是中途中断的构建，**不是**「重新设计后的缩减版」。

影响：任何基于本地 `site_frames` 的覆盖率/统计数字都不可信；早前记录的「36,799,100 行」属于另一次完整构建，本地现表不是它。
处置：列为交接文档的 P0（先 `count` 再 `build_site_frames.py --all --replace --validate` 重建，约 680 s、7.9 GB）。

### 三、附带核对
- `v7_law.sqlite`（14.5 MB）表齐全：`law_cells` 24,328 / `law_tiles` 62,625 / `clb_blocks` 763 / `clb_cells` 3,884 / `clb_tiles` 75,900 / `far_bands` 1,078 / `ppips` 2,958 / `v7_verified` 245 / `cmt_code` 33。
- `STATUS.md`：5,998 行 / 240 个 `## ` 标题。

### 2026-11-13 复盘：P1 的「换 CK_IN 序号」不可行 → 改用 25 个设计的普查

**P1 原设计不可行（三条摆放约束，全部实测报错）**
- `ERROR: [Place 30-152] Unroutable Placement! A MMCM / BUFHCE component pair is not placed in a routable site pair` —— MMCM 与 BUFHCE 必须同一时钟区域。
- `ERROR: [Common 17-69] 'BUFHCE_X0Y130' is not a valid site name` —— 该区域合法 BUFHCE 只有 `X0Y72..83`（早前 hclk8 已踩过）。
- `ERROR: [Place 30-176]` —— 跨区后时钟源离被锁定的负载太远，无法布线。
⇒ 在本器件上「保持负载不动、只把时钟改成另一个 CK_IN 序号」造不出来。

**替代证据：全库标记普查（`_remote_marker_census.py`，逐 bitstream 扫 74,400 个数据字，判「半字恰好等于标记值」）**
| 设计（HROW 源） | 数量 | 标记命中 |
|---|---|---|
| CK_IN 通路（`hclk4 g0..g2`、`hclk5 j0/k0..k6`、`hclk6 p0..p5`、`hclk8 m_def/p_72..p_83`、`ckpair a`） | **25** | **0**（唯一命中 (27360,99) `0x01001001` 是数据字偶合） |
| GCLK 通路（`clkmux3 y1_s0` k=1、`y2_s0` k=2） | 2 | 有：k=1 → (2589,24)/(2589,73) 高半 `0x800a0000`；k=2 → (2589,25)/(2589,74) 低半 `0x0000800a` |
| 混合（`hclk6 c_a/c_b`，`.pips` 同时有 `CK_IN_L13 ->> MUX_OUT_L0` 与 `GCLK0 ->> MUX_OUT_L8`） | 2 | 有 6 处 `0x0000800a`（对应它确实选了 GCLK0 的那条车道） |

**结论**
- 【数据事实】k=2 的位点（2589,25 低半）= 公式预测值，**独立复现了 §164 的坐标公式**（此前只实测 k=1/8/16/17/24/31）。
- 【数据事实】25 个 CK_IN 源设计、跨 3 个时钟列（col33/col75 等），**零标记**；只有真正选了 GCLK 的设计才出现标记，且 `c_a/c_b` 的「有/无」与它 `.pips` 里的源类别完全对得上。
- 判定：§165 的「CK_IN = 默认通路、不占置位字段」由【推断】升为**高置信（25 设计、3 列、零反例）**，但因为没有同 tile 同车道的严格对，**正式仍标【推断】**。
- P2（同车道叠加 CK_IN 使 `0x800a` 被清掉）在当前摆放约束下也造不出来：router 只会在该车道二选一，无法同时要求两条。


## 166. P1 行序：16 键 / 8 张基础表 / 1 条镜像律（2026-11-13）

**问题**（§161 阶梯第 1 级 + 交接文档 P1）：mux 区的「类内成员序」原判为数据（48 族 36 种），
能否由结构变量导出？

**结论（【数据事实】，全部由 `step03_pip/_q_row_law.py` 复算）**

1. **只有 16 种行序，且 16 个键 → 16 个编码是双射**。键 = `((pair//2)%8, primary)`，
   即「位对在 16 位半区内的位置 + primary 位」。族名、parity、L/R 侧都不进键。
2. **INT_L 与 INT_R 逐键相同**（0 个键不同）；用 INT_L 建表预测 INT_R：**1,024/1,024，0 不符**（跨侧留出）。
3. **primary=S 的行号 = primary=P 的行号 +2 mod 4**：16 张表只剩 **8 张基础表**。
4. **族名 → (pair, parity, primary) 有闭式**：IMUX `pair=[0,2,2,4,4,6][i//8]+8*(i%4)`、
   `parity=(i//4)%2`、`primary=S iff (i//8) 偶`；BYP/FAN 各一张 8 项常数表；**128 族 0 不符**。
5. **全量再生 2,048/2,048 条方向线 feature**（64 族 × 16 条 × 2 侧）的 `(row, colcode)`，
   `missing=0`、`extra=0`。
6. LOGIC/GFAN 与 BOUNCE 的第 4/5 行归属由全局 mux 序号 `g=i//8` 奇偶决定，**64/64 族 0 反例**。
7. 48 个 IMUX 族的等价类 = **12 组 × 4 族**：`{0,2,4,6} {1,3,5,7} {8,10,12,14} …`，
   即行序只依赖 `(i 的奇偶, i//8)`。

**与旧结论的差异（如实记录）**：旧文「48 族 36 种」「`i%8∈{0,3}` 与 `i+4` 共用」在本机当前
`law_cells` 上复现不出来。三种口径的结果：①只比方向线前缀 → 12 组；②比 24 条源的精确线名 → 48 组；
③比含 LOGIC/BOUNCE 的完整签名 → 48 组。旧数字来源不明（可能更早的库版本），本轮不沿用。
本结论**不否定**「源→槽位不是线名的函数」：同一线名在不同族仍可落不同行，成为函数的是键。

**边界**：8 张基础表本身是否还能再压缩（按 j 的循环/反射生成元）**未测**——已试「相邻 j 为行旋转」
只在 j=0→1、1→2 成立，j≥3 出现反射。族名→键的物理含义（16 位半区）只有分布证据，无 CRAM 布局级证据。
第 4/5 行内 8 条源的**成员选择**仍是数据。

**报告**：`v7re/steps/T88_ROW_ORDER_STRUCTURE.md`（含 16 张表全表、分配闭式、验证矩阵）。
**复现**：`python step03_pip/_q_row_law.py` → 末行六个 PASS。
**影响**：§161 阶梯第 1 级的表述可从「公式 + 数据表」改为「公式 + 8 张表 + 1 条镜像律」；
`pip_reuse_law.json` 里的 `slots` 可改为按上述闭式生成，不再逐族存 1,536 条。

**旁支（同日）**：本地 `site_frames` 残缺表（19,819,900 行 / 6,104 frame）重建已在后台启动；
`build_site_frames.py` 改为流式分块写入（原实现全量 3,680 万行需约 8 GB 内存，本机可用不足 1 GB），
并在 `--replace` 时先删二级索引再重建。完成后单独记账。

## 167. T88 独立复核 + 行序生成律（32 个置换 → 4 基 + 1 位 + 1 条步进律）

日期 2026-11-13 · 复现 `python step03_pip/_row_s4.py`（末行 `generator rule: 32/32 = True`，exit 0）

### 167.1 独立复核 T88 的四条主结论（不读 T88 的表，直接从 `law_cells` 原始单元重算）

| 判据 | 结果 |
|---|---|
| 每侧 64 个 mux 族 → 不同编码数 | **16**，且每个编码恰好 **4 个族**（分布 `{4:16}`） |
| INT_L vs INT_R 逐族同码 | **64/64** |
| 16 种编码在「+2 mod 4」下两两成对 | **8 对**，闭包成立 |
| IMUX 48 族按 `(i//8, i%2)` 分组 | **12 组**，每组内编码全同（0 反例） |

口径：`row = frame_off - 16`（只取 `frame_off ∈ 16..19` 的 sense 单元），编码按
`DIAG[NE,NW,SE,SW] ORTH[NN,EE,WW,SS] R[NR,ER,WR,SR] L[NL,EL,WL,SL]` 拼 4 位行号。

### 167.2 生成律：8 张表还可以再压

把每类的 `p_j` 看成 S4 元素（位置→行号），`p_{j+1} = g_j ∘ p_j`，则

```
class ∈ {DIAG,ORTH}:  g = [r³, ρ, r³, e,  r³, ρ, r³]
class ∈ {R,L}:        g = [r,  ρ, r,  X2, r,  ρ, r ]
r=(1,2,3,0)  ρ=(3,2,1,0)  e=(0,1,2,3)  r³=(3,0,1,2)  X2=(3,2,0,1)
```

- **32/32 个置换全部由「4 个基置换 p0 + 1 个比特（类别对）+ 固定步进律」重建**；
- `p7 == p0` 对 DIAG/ORTH 成立，对 R/L 不成立（后者 `p7` 是 `p0` 的 ρ 复合），所以周期不是 8；
- 基置换 `p0`：DIAG `(2,0,3,1)`、ORTH `(2,3,0,1)`、R `(2,0,1,3)`、L `(3,1,0,2)`；
- `primary=S` 等于每位置 `+2 mod 4`（即把行号高位置 1，等价于复合 τ=(2,3,0,1)），与 T88 H3 一致。

**量级**：原表 32×log2(24) ≈ 147 bit → 现为 4×log2(24) + 1 bit ≈ 20 bit，**压缩约 7 倍**。

### 167.3 对 T88 的方法学备注

- T88 的 H1/H2（16 键双射）与 R1（2,048 条全量再生）都用了同一份数据建表再回放，
  **部分循环**；真正非循环的证据是 ①64 族→16 键的 4 倍压缩 ②INT_L 训练 / INT_R 预测的
  **跨侧留出 1,024/1,024**。本文 167.1 的复核独立于 T88 的脚本，结论一致。
- 旧文「48 族 36 种」在本数据的三种口径下都复现不出（IMUX 单独 12 组、含 BYP/FAN 16 组），
  同意 T88 §7 的处理：标记为不可复现，不复用该数字。
- 生成律里的 `j` 编号是**约定依赖**的：`g_j` 序列只在 `j = (pair//2)%8` 这个排序下成立，
  换排序则序列变。因此它是「以规范键序为前提的律」，不是无条件的群作用。

### 167.4 未解（留给下一步）

- 4 个基置换 `p0` 本身（≈18 bit）仍是数据，未找到出处；
- 类别对（DIAG/ORTH vs R/L）为何决定 `A` 与 `X`，没有位布局级证据；
- 是否在 `BRAM` / `CLK_HROW` 等其它 tile_type 上同形，未验证。

## 168. T89：行序生成律落地（4 基置换 + 步进律）并接入生成器（2026-11-13）

**任务**：先收尾选项 3（把 §167 的步进律写成代码、全量对拍、判定 p7 与类别对），
再把行序接进生成器（选项 1，去逐族 slots）。报告 `v7re/steps/T89_ROW_LAW_GENERATOR.md`。

### 168.1 选项 3 收尾（【数据事实】）

- 生成律：`p0`（DIAG `(2,0,3,1)` / ORTH `(2,3,0,1)` / R `(2,0,1,3)` / L `(3,1,0,2)`）
  + 5 个步进置换（`r/r3/rho/e/X2`）+ 1 个类别对比特，按 `p_{j+1}=g_j∘p_j` 重建 32 个置换，
  **32/32 逐项相等**；拼成 16 种编码后与 `law_cells` 全量对拍 **2,048/2,048，0 不符**（两侧各 1,024）。
- `p7 == p0`：DIAG/ORTH **成立**，R/L **不成立**（`p7 = p0 ∘ ρ`）⇒ **周期不是 8**，
  只有 DIAG/ORTH 子空间呈 8 周期。
- 类别对 ↔ 线长类别：实测列码 DIAG/ORTH ⊂ {1,2}（DOUBLE）、R/L ⊂ {7,11}（SINGLE），
  2,048 条方向线 **0 例外**。【推断】行序与列码由同一变量驱动；这是同一分组的证据，非因果证明。

### 168.2 选项 1：接入生成器（【数据事实】）

新增 `step03_pip/row_law.py`（只存 4 基置换 + 5 步进置换 + 1 bit；族名→pair/parity/primary/列码全闭式）
与 `step03_pip/gen_mux_rowlaw.py`（用律替换 `pip_reuse_law.json` 的逐族 slots）。

| 判据 | 结果 |
|---|---|
| 与旧 1,536 条 slots 逐条比对 | **差分 0**（方向线 1,024 由律生成，行 4/5 residue 512） |
| 随机 200 个 `(family, source)` 与 `law_cells` 对拍 | **0 不符** |
| 接回 `predict()` 的 mux 区全量 | **1,536/1,536** |
| 两侧方向线全量（INT_L/INT_R） | **2,048/2,048** |
| `verify_all_pip.py --tile-type INT_L` | **3,634/3,634**（100%） |
| `verify_all_pip.py --tile-type INT_R --normalize` | **3,634/3,634**（100%） |

**量级**：行序从 1,536 条逐族 slots 降为 4 基置换（≈18.3 bit）+ 5 步进置换（≈22.9 bit）+ 1 bit；
仍未去表的是行 4/5 的 512 个槽位（LOGIC/GFAN、BOUNCE 的成员→列归属）。

### 168.3 未解与边界

- 4 个基置换本身仍是数据，未找到出处；`j` 的编号依赖规范键序，换排序则步进律不成立。
- 行 4/5：行号由 `g=i//8` 奇偶决定（64/64），但成员→列仍是逐族数据（512 槽）。
- 因果未证：需在存在混合线长类别的 tile_type 上重复（选项 2）。

### 168.4 旁支记账：本地 `site_frames` 已重建

`build_site_frames.py` 改为流式分块写入（原实现全量 3,680 万行需约 8 GB 内存，本机可用不足 1 GB），
`--replace` 时先删二级索引再重建。全量重建 804 s，结果 **36,799,100 行 / 9,156 distinct frame /
75,800 site / `SLICE_X10Y20` 498 行**，三条判据同时成立。旁支结束，不再占用主线。

**复现**：`python step03_pip/_row_gen.py`、`python step03_pip/gen_mux_rowlaw.py`。

### 168.5 选项 2（离线普查）：CLK_HROW 键同形、映射代数不同

报告 `v7re/steps/T89_OPTION2_CROSS_TYPE.md`。族规模普查（A7 segbits）：BRAM 63 族/侧中源数 ≥8 的只有 3 族、DSP 79 族中只有 1 族（其余 2 源 one-hot）；INT 是 172/172。CLK_HROW 的 62 源族按「组内位置 mod 16 + 组位」分解，19 个实测 GCLK 源 19/19 成立，§165 普查的 k=2 独立复现（20/20），与 INT 的 16 位半区键同形；但它的映射是 16 槽位表，不是 4 成员置换 + 步进律——「同类映射、不同基置换」只对键成立。BRAM/DSP 需要 V7 实测位表，本轮未测。可证伪预测：造 k=18、k=25 两个受控位流检验剩余槽位公式。

## 169. T89 交付复核 + 复用在位级上的定位 + 一条负结果

日期 2026-11-13 · 复核对象 `step03_pip/_row_gen.py`、`gen_mux_rowlaw.py`、`v7re/steps/tile_pip_lawscan.json`

### 169.1 复核结果（重跑，非采信）

| 脚本 | 输出 | 与 T89 报告一致 |
|---|---|---|
| `_row_gen.py` | `RESULT: PASS (2048/2048)`，16 张表与原表逐行相同，`p7==p0` 仅 DIAG/ORTH 为真 | ✅ |
| `gen_mux_rowlaw.py` | 旧 slots 1,536 条差分 0；`predict()` 1,536/1,536；两侧方向线 2,048/2,048；随机 200 对 0 不符 | ✅ |
| `tile_pip_lawscan.json` | 636 族；`sources>=8` 的族数：INT 172/172、BRAM 3/63、DSP 1/79、CLBLI/LM 各 2/2 | ✅ |

### 169.2 定位结论：位级上的「复用」是 INT 的 24 源 mux 现象

| tile_type | family 数 | 源数 ≥8 的族 | 最大源数 |
|---|---|---|---|
| `INT_L` / `INT_R` | 172 | **172（100%）** | **24** |
| `BRAM_L` / `BRAM_R` | 63 | 3 | 111 |
| `DSP_L` / `DSP_R` | 79 | 1 | 280 |
| `CLBLM_L/R` | 2 | 2 | 358 |
| `CLBLL_L/R` | 2 | 2 | 338 |

INT 的复用形状统一是「24 源 = 6 行（帧 16..21）× 4 列（帧 22..25 的四位码）」；
其它类型的「多源」是 111–358 的超大 fan-in，不是 4×6 网格，所以**行序律不能直接搬**。
这解释了 T89 选项 2 的负结果：`CLK_HROW` 只有「键」同形，映射是 16 槽位表。

### 169.3 负结果：ρ 共轭不能让 R/L 的 8 步闭合成环

试过 `p∘ρ`、`ρ∘p`、`ρ∘p∘ρ` 三种共轭，步进序列都仍是 `[r,ρ,r,X2,r,ρ,r]`，
第 8 步不回到起点 ⇒ **「周期 8」在 R/L 上确实不成立，不是坐标系没选对**。
所以 `j` 的 0..7 不是循环，而是一条开链；步进律里那个 j=3 的例外跳 `X2` 是真实的断裂点。

### 169.4 建议的下一步（按主线价值排序）

| 优先级 | 事项 | 判据 / 可证伪预测 |
|---|---|---|
| P0 | `INT_INTERFACE_L/R`（4,550+3,850）与 `INT_FEEDTHRU_1/2`（525+600）是否也是 24 源 6×4 | 若源数分布与 INT_L 一致，则把律扩到 INT 全家；若出现 2/4/8 源的小 mux，则先记形状再谈律 |
| P1 | 行 4/5 的 512 个槽位（LOGIC/GFAN 与 BOUNCE 的成员→列归属） | 收口后 mux 区除了 4 个基置换外不再有表 |
| P2 | 4 个基置换的出处 | 位级大概率无解，需要 die shot 或官方 CRAM 图；建议限时，做不到就标「数据」并停止追问 |
| P3 | `CLK_HROW_CK_MUX_OUT_L8` 的 16 槽位表定性 | 明确写「律不迁移」，避免后人误以为可套 4 置换模型 |

## 170. T90 —— INT_INTERFACE / FEEDTHRU 的 PIP 形状：24 源假设被否证（2026-11-13）

**结论**：这四类 tile 没有 24 源 6x4 mux。接口类是 1:1 直通（无选择器，无需配置位），FEEDTHRU 类 PIP 数为 0。
「位级复用 = INT 的 24 源 6x4」这一判断成立，且更干净。

| tile_type | 实例 | pips/实例 | dst 数 | fan-in 分布 | 1:1 直通 |
|---|---|---|---|---|---|
| INT_INTERFACE_L | 4,550 | 24 | 24 | `1:24` | 24/24 |
| INT_INTERFACE_R | 3,850 | 24 | 24 | `1:24` | 24/24 |
| BRAM_INT_INTERFACE_L | 2,400 | 24 | 24 | `1:24` | 24/24 |
| IO_INT_INTERFACE_L | 350 | 24 | 24 | `1:24` | 24/24 |
| HCLK_INT_INTERFACE | 301 | 0 | 0 | — | — |
| INT_FEEDTHRU_1 | 525 | 0 | 0 | — | — |
| INT_FEEDTHRU_2 | 600 | 0 | 0 | — | — |

接口类 24 条 PIP 的实际内容是 `INT_INTERFACE_LOGIC_OUTS_L_Bk ->> INT_INTERFACE_LOGIC_OUTS_Lk`
（B 侧线到同号 A 侧线的拷贝，tile 边界续接）。**「24」是巧合**：INT 的 24 是「每目的 24 个源」，
接口类的 24 是「有 24 对线要续接」——原假设把两个 24 混为一谈。

独立旁证：本地 `prjxray_ref/artix7/` 22 个 db 只覆盖 10 种 tile_type（BRAM/CLBLL/CLBLM/DSP/INT），
`segbits_*` 与 `ppips_*` 里没有任何 interface / feedthru 类型 —— prjxray 逐位挖矿都没挖出配置位。

覆盖口径修正：207,253,149 = INT 198,434,700 + 其它 8,818,449；后者里接口类的
**342,000 个实例是纯 1:1 直通（不可配置）**，FEEDTHRU 类 0 个。所以「还有 4.3% 没做」的说法不成立，
那 4.3% 的大头是不可配置的直通线。

顺带测到的其它类型 fan-in（同一脚本）：`LIOI` 467 pips / fan-in 1,2,11,12,16,17,18；
`CLK_BUFG_BOT_R` 304 pips（32 个 5 源）；**`HCLK_L` 200 pips / 20 dst = 8 个直通 + 12 个 16 源 mux**；
`CMT_FIFO_L` 278 pips 几乎全直通；`GTX_INT_INTERFACE` 168 pips（48 个 2 源）。
`HCLK_L` 的 16 源 mux（529 实例/侧）是 INT 之外第一个宽度 >=16 的真选择器，编码形态未测 —— 新的下一步。

产物：`v7re/scripts/iface_feedthru_probe.py`、`v7re/steps/T90_INTERFACE_FEEDTHRU.md`、
`v7re/steps/t90_tile_fanin.json`、`PROMPT_P0_INTERFACE_FEEDTHRU.md`。
边界：纯静态统计，未起构建；「1:1 直通不需要配置位」依据是结构无选择 + prjxray 缺席，未做位流实测。

## 171. T91 —— HCLK_L 叶子时钟 mux（16 源）：真 crossbar，但工具只用一档（2026-11-13）

**结构**（`_tif/HCLK_L.json`）：20 目的 / 200 PIP = 8 个 1:1 直通 + **12 个 16 源选择器**
（`HCLK_LEAF_CLK_B_{BOT,TOP}L0..5`）。**12 个选择器的 16 个源完全相同**：
`BUFHCLK8..11`(4) + `BUFRCLK0..3`(4) + `OUTIN_L0..7`(8)。即 16 进 12 出的 crossbar，
`12x16 = 192` 条 PIP —— 若 12 个出口共用一份「选了第几路」，只需 4 位，这是复用可能发生的地方。

**实测**（292 个 `.pips` / 281 设计）：按 `(side, grid_x)` 汇总，**同列 tile 恒用同一个源** ——
L 列 3/17/21/31/51/67/72/77/91/112/126/189/195 全用 `BUFHCLK8`（→ BOTL5 或 TOPL5）；
L 列 **301** 用 `BUFHCLK11`；R 列 4/78 用 `BUFHCLK0`。
唯一例外：`HCLK_L_X91Y338` 同时出现过 `BUFHCLK8`（61 设计）与 `BUFHCLK9`（1 设计 `_hb3_out/h08`）。
16 个源里实测只出现 4 个（0、8、9、11）⇒ crossbar 在真实设计里几乎不被「选择」。

**位级**（新增 `v7re/scripts/hclk_leaf_diff.py`，按帧聚簇 + 控制减法）：
- 对照 `h00 vs h01`（叶子源同为 8，只差 HCLK_CMT 槽位）：**10 格**，全在帧 `22146..22147` word 48
  （与 T71 一致，已知字段）；
- 目标 `h00 vs h08`（叶子源 8→9，HROW 轨道 L8→L9）：**38 格**，两簇 —— `22146..22147`(4) 与
  **`23512..23589`(34)**；控制减法后剩 33 格，仍分不开「HROW 轨道 mux」与「HCLK_L 叶子 mux」，
  因为两者都在同一帧段，而**时钟 tile 的 tile->frame 基址没有**（`clb_blocks` 只覆盖 CLB，
  INT 有 `law_cells`，时钟 tile 缺地址表）。

**主线判断**：HCLK_L 不是「第二个 24 源复用现象」。结构上有复用的可能性（12 出口共享 16 源），
但工具行为让「选择」几乎不发生 —— 没有可枚举样本，就没有可验证的编码律。

**下一步（建议先做 1）**：1) 建时钟 tile 的 frame 映射（离线，把 34 格拆成 HROW / HCLK_L 两部分）；
2) 构造强制换源（BUFR / OUTIN），若工具坚持不换就写「选择不可达」而不是继续猜位。

产物：`v7re/scripts/hclk_leaf_diff.py`、`v7re/steps/T91_HCLK_LEAF_MUX.md`。

## 172. 坐标系审计（clock_blocks 前置）：`band` 实证撞名，`far_bands` 154 列分 5 类

用户 m17093 质疑「grid_x 会不会撞名」，审计结论：**会，而且库里已经撞了**。

- `clb_blocks.band` vs `far_bands.band`：同名、同范围、基数相同，但 763 个块**全部不一致**
  （0→6、1→5、2→0、3→1、4→2、5→3、6→4）。任何按 band 相等的 join 都静默出错。
  本审计过程中我最初就犯了此错（得出 111 个 AMB），已更正。
- `far_bands` 的 154 列按「7 个 band 上的帧数」分 5 类，签名在 7 带上完全一致：
  36 帧 = **111 列 = CLB 列**（与 763 个 clb_blocks 映射到的 111 列集合**完全相同**）；
  28 帧 = 35 列（推断 INT）；**30 帧 = 4 列（33/62/75/120）= 时钟列**；
  32 帧 = 2 列（0/153，边界）；42 帧 = 2 列（32/121，未定）。
- `grid_x` 有 412 个值而 `far_col` 只有 154 个；同一 `grid_x` 上叠多种 tile
  （192 同时是 `CLK_HROW_TOP_R` 与 `CLK_BUFG_BOT_R`）⇒ 映射表主键必须带 `type`。
- 已验证安全的映射只有一条：`clb_col → far_col` 111↔111 严格 1:1
  （5→1、6→2、9→3、11→4、16→6、19→7、20→8、23→9、25→10；旁证 31752→(band6,col8)）。
- 未定项不猜：`column_offsets.x` 属哪个命名空间、42 帧列、32 帧列、28 帧列与 154 个 INT 列位的关系。
- 方法验证：`h00` vs `h08` 38 格落区 —— col33(4 格 word48，CMT 槽位)、**col75(26 格，时钟 mux)**、
  col74(6 格)、col76(2 格) ⇒ 时钟相关位**不只在 4 个时钟列**，CLB 列里也有。
- 文档 `v7re/steps/COORD_AUDIT.md`（含 10 节）；本条同时确立命名硬规则
  （禁裸 `col`/`band`/`x`，跨坐标系 join 前打印基数，结论一律回到 `frame_index`）。

## 173. 两个「为什么」的初步答案（2026-11-13）

### 1. 为什么覆盖率停在 97.7% 而不是 100%

【数据事实】剩余 82 条 feature 全在 6 个长线族（`LH0` 12 / `LH12` 12 / `LVB_L0` 18 / `LVB_L12` 18 / `LV_L0` 10 / `LV_L18` 12），它们的**源不是本 tile 的普通线，而是别的长线与长线的端点线**：
- `LH0` 的 12 个源 = `EE4END3, ER1END3, LH12, LV_L0, LV_L18, LV_L9, NE2END3, NE6END3, NW2END3, SR1END3, SS6END3, SW6END3`；
- `LVB_L0` 的 18 个源里含 `LH0, LH12, LH6, LVB_L12, LV_L0, LV_L18`；
- `LV_L18` 含 `LH0, LH12, LH6, LV_L0`。

【数据事实】这 6 族也是**唯一**存在跨族共享格的族：`(1,6,0) ∈ {LH0, LV_L0, LV_L18}`、`(0,2,0) ∈ {LH0, LV_L0}`、`(0,9,0) ∈ {LV_L0, LV_L18}`（`_q_longline_why.py`）。

【推断】所以这 82 条编码的是**长线之间的邻接关系**（谁与谁相邻、哪一段接哪一段），属于「器件布线拓扑的数据」，不是名字的派生量。要把它公式化，需要额外数据源（长线的物理次序/坐标），而当前工具链没有暴露：`templates/*.json` 的 `pip_defs` 第三字段 `delayIndex` 在 INT 全为 0，RapidWright 也没有 mux 内部或长线相邻关系的 API（`PIP_BIT_REUSE_REPORT.md` §6 记录过这一点）。

⇒ 结论：97.7% 是「名字可派生」的上界；剩下 2.3% 是拓扑数据。**不写成 100% 是诚实，不是没做完**。

### 2. 码集 `{1,2,7,11}` 的结构（`_q_longline_why.py`）

【数据事实】4 个合法列码两两异或后 popcount 恒为 **2**：
`1^2=3(2位)`、`1^7=6(2位)`、`1^11=10(2位)`、`2^7=5(2位)`、`2^11=9(2位)`、`7^11=12(2位)` → **最小汉明距离 = 2**。
【数据事实】任取一个合法码、翻转任意 1 位，得到的 7 个 4 位字 `{0,3,5,6,9,10,15}` **全部非法**。
⇒ 【推断】码集的设计使其具备**单比特错误可检出**性质（检错、不纠错）；这与篡改实验中「mux 区清位方向单 bit 检出 100%」是同一事实的编码论表述。
【数据事实】码集还存在子集关系：`1 ⊂ 11`（0001 ⊂ 1011）、`2 ⊂ 7`（0010 ⊂ 0111）——与全表统计的 1,632 对族内严格子集同源。
【推断】这不是最大码集（4 位、距离 2 的最大规模是 8），说明码集还受别的约束（候选：4 个线长类别只能两两正交到 2 位；成因未测）。

## 174. 「mux 为什么是 6 行」的分解（2026-11-13）

**结论先行**：6 = **4 个「线源槽」+ 1 个「旁路槽」+ 1 个「本地槽」**；其中 2 个槽的名字可解释，另 4 个槽只知其划分、不知其语义。

### 实测（`_q_mux6_sig.py`、`_q_mux6_verify.py`，`law_cells` INT_L sense=1）
- 64 个 24 源族，**64/64 族每一行（`frame_off` 16..21）都恰好 4 个源**；6 × 4 = 24，组格总数 1,536 = 24 × 64 ✔。
- 每 `(行, 列码)` 格恰 1 个源（列码 ∈ {1,2,7,11}），即 6×4 网格**满填、无空洞**。
- **第 20、21 行的构成对 64 族完全一致**：恒为「4 个 bounce 类（2×`BYP_BOUNCE` + 2×`FAN_BOUNCE`）」与「4 个本地类（1×`GFAN` + 3×`LOGIC_OUTS`）」，两行谁在上随族交替。
- **第 16..19 行装的是 16 个「线源」**（方向 END 线，如 `EE2END0`、`NL1END0`、`SR1END_N3_3`），每行 4 个；其**行归属随族变化**：64 族去重后恰 **16 种签名、每种 4 族**——与 §11 的「16 种配置 × 4 族」是同一个 16。

### 判读
- 【数据事实】「6」不是一个均匀的维度，而是 **`4（线）+1（旁路）+1（本地）`** 的拼合；旁路/本地两行由名字直接决定，线源四行的排列是族参数（已由 §11 的 `(前缀, i//8, i%2)` 规则给出）。
- 【数据事实】**否定**一个自然猜测：这 4 行**不是**「四个方向」。实测每行混装多个方向（例 `IMUX_L40` 第 16 行 = `EE2END0`(E)、`NL1END0`(NL)、`SE2END0`(SE)、`SR1END_N3_3`(SR)），故「6 行 = 6 个方向分组」的说法不成立（`PIP_BIT_REUSE_REPORT.md` 里把它列为语义猜测，此处正式否证）。
- 【推断】线源四行的语义（为什么恰 4 组）仍未解；候选是「到达边」或「IMUX 内部四段驱动」，两者都缺直接证据，标未测。

### 复算
`python step03_pip\_q_mux6_sig.py`（打印 16 种签名）、`python step03_pip\_q_mux6_verify.py`（每行 4 源、20/21 行构成）。

## 175. 线源四组的语义：查到了什么、否证了什么（2026-11-13）

**问题**：§174 把「6 行」拆成 `4 线 + 1 旁路 + 1 本地` 后，剩下「为什么恰好 4 个线源组、这 4 组是什么」。

### 实测（`_q_mux6_partition.py`、`_q_mux6_latin.py`、`_q_mux6_edges.py`）
- 【数据事实】每族的 16 个线源恒分成 **4 组 × 4**；并且**每组恰含一个长度类**（码 1/2/7/11 各一）：64 族 × 4 行 = **256/256 组零异常**。即线源部分是「4 组 × 4 长度类」的拉丁方。
- 【数据事实】组划分**不是全局唯一**：64 族去重后 **32 种划分、每种 2 族**。最常见的一种划分（去后缀名）：
  `{EE2END, NL1END, SE2END, SR1END}`、`{EL1END, SS2END, SW2END, WR1END}`、`{ER1END, NW2END, WL1END, WW2END}`、`{NE2END, NN2END, NR1END, SL1END}`。
- 【数据事实】**否证「4 组 = 4 个方向」**：组内混装方向（第一组就有 E/NE?/SE/SR 混装），且每组的 4 个源在 `tileconn` 里的到达偏移根本不唯一——例 `EE2END0` 有 `(-18,0) (-9,0) (-7,0) (-6,0)` 四个到达偏移。
- 【数据事实】**否证「4 组 = 4 条到达边」**：同上，一个源可来自多条边，边与组不是一一对应。

### 判读：与仓库既有结论一致，且给出「为什么 6」的答案
- 既有结论（`IMUX_INDEX_SOLVED.md` §2）：同一源在不同 mux 上的 `(row,col)` 会变，「哪个布线资源接到哪个输入脚由芯片物理走线决定，是逐 mux 不同的常量表」。
- 与本轮实测合起来看：【推断】**6×4 网格是物理开关矩阵**（6 个开关行 × 4 个开关列），而不是逻辑分组；「4 线 + 1 旁路 + 1 本地」是**这些开关行实际接了哪类线**的描述；「16 种配置」是 64 个 mux 的物理排列被压缩成 16 类。
- 因此「为什么 6」的答案是：**6 = 物理开关行数**；「为什么 16」= 64 个 mux 的布线排列恰好只有 16 种。这两条都是【推断】，缺一份硅片/版图级证据。

### 这条对论文的意义（诚实提醒）
若 6 与 16 的成因是「物理布线常量表 + 16 类排列」，那么「生成式公式」这个说法的准确含义是：**把 172 份逐 mux 常量表压缩成 16 类 + 名派生规则**，而不是「从名字推导出硅片结构」。写作时应按前者表述，否则会被审稿人反问「你这公式的物理依据是什么」。

## 173a. 长线族验证：用真实位流反解 INT tile 基址，长线格 23/23 命中

用户问「INT 里的长线组能解决吗」。结论：**能，且已验证**。

- 长线族共 6 个（`LV_L0` 10 源、`LV_L18` 12、`LH0` 12、`LH12` 12、`LVB_L0` 18、`LVB_L12` 18），
  **82 个源、每源恰好 2 格**（A 侧 + B 侧），与 BEG 同构。
- 长线→长线的**续接边 26 条**（去重后）：`LV_L0←{LH12,LH6}`、`LV_L18←{LH0,LH12,LH6,LV_L0}`、
  `LH0←{LH12,LV_L0,LV_L18,LV_L9}`、`LH12←{LH0,LV_L0,LV_L18,LV_L9}`、
  `LVB_L0↔LVB_L12` 互连且吃下全部 6 条；每条长线同时被 8 个 BEG 族当源。
  **「段数/跨度」没有独立编码**——跨 N 个 tile 就是 N 次续接的组合（bounce）。
- `LV_L9` 与 `LH6` **没有自己的驱动族**（只作源），是待查缺口。
- 新工具 `v7re/scripts/int_base_solve.py`：用 `law_cells` 的相对格约束 + 暴力扫，
  从**真实位流**反解每个 INT tile 的帧基址；解唯一即视为可信。
- 在 `_n1.bit`（+`_n1.pips`，392 个 INT tile）上：**258 个 tile 得到唯一基址**
  （2 个多解、5 个无解）；同列多 tile 基址一致（`INT_R_X29Y105..109` 全为 992）。
- **长线专项：23 条长线相关 PIP，23/23 的全部预测格在该位流中为 1**（0 不符）。
- 负对照的边界（如实记）：同族「未使用源」的格本应全 0，实测 106 正确 / 182 误置位——
  这是已知的 **2 格 pattern 歧义**（符号级解码 full8 曾多解 92 条同一现象），
  不是位错误；因此「某源未用」不能用格全 0 来证否。
- 另做一致性对拍：`pip_bits`（3,528 条实测绝对位）与 `law_cells` 在 12 个 (tile,PIP) 组上
  **base 全一致（12/12）**，行间差 5,246 = `row_frames`，与配置行结构吻合。

## 176. 版图级证据：工具链里查不到（2026-11-13，A 路失败记录）

**目标**：为 §175 的【推断】「6×4 是物理开关矩阵、行是物理开关行」找版图级佐证。

**查了什么**
- RapidWright `Site` API：`site.getSiteWireCount()` = **96**（`SLICE_X0Y0`，含 `A1..A6`、`CYINITGND_HARD0` 等）；`site.getSitePIPs()` = **138** 条，形态全是 `D6LUT.A1->>O6`、`D5LUT.A1->>O5` 这一类**LUT 输出选择**，**没有** IMUX/开关矩阵的内部坐标。
- `Tile` API：只有 `getWireCount/getWireName/getWireIndex/getWireIntentCode/getPIPs`，**不提供** tile 内开关的物理行列。
- 线序/意图码能否分开那 4 组：
  | 组 | 线索引 | 意图码 |
  |---|---|---|
  | G1 | 237, 333, 226, 348 | DOUBLE, SINGLE, DOUBLE, SINGLE |
  | G2 | 268, 277, 270, 295 | DOUBLE, DOUBLE, SINGLE, SINGLE |
  | G3 | 297, 231, 267, 300 | SINGLE, DOUBLE, DOUBLE, SINGLE |
  | G4 | 334, 273, 301, 293 | DOUBLE, SINGLE, DOUBLE, SINGLE |
  → **线索引离散、组内不连续**；但**每组恒为 2 DOUBLE + 2 SINGLE**（与「每组恰含 4 个长度类」一致）。
- Vivado 2017.2：`link_design -part xc7vx485tffg1157-3` 后取 `get_tiles/get_pips/get_site_pips` 的批处理探针**挂死无输出**（>10 分钟，已终止），未取得 tile 内部几何。

**结论**
- 【数据事实】当前工具链（RapidWright 2026.1.1 + Vivado 2017.2）**都不暴露** CRAM 开关矩阵的物理行列坐标；能看到的只有「线—PIP 连接关系」。
- 【推断】因此「6 行是物理开关行、4 列是物理开关列」这条**无法在本仓库取证**；可用的最强证据仍是行为学的（6×4 满填、每组 4 类、16 种排列）。
- 【数据事实】列轴有厂商元数据佐证：`getWireIntentCode()` 把长度类分开（DOUBLE = 2 跳线，SINGLE = 1 跳/R 线），且每组 2+2 恒定；**行轴没有任何厂商元数据**。

**对论文的处置**：把「6 行」写成【推断】（物理开关矩阵的假设），把「4 列 = 长度类」写成【数据事实 + 厂商 intent code 佐证】。这样即使审稿人追问行轴，我们也没有把推断当事实。

## 177. PIP 复用规律现状盘点（2026-11-13）

按 `step03_pip/PROMPT_PIP_REUSE_STATUS_V2.md` 生成、并按 A/B/C 三档 + 缺陷账 + 自我攻击三节写成：**`step03_pip/PIP_REUSE_STATUS_20261113.md`**（80 行）。

**当日复跑（全部 2026-11-13）**
- `python step03_pip/gen_slots.py` → `[mux] 64/64`、`[BEG] 96/96（变体 32/32）`、`[复合] 96/96`、覆盖 **3,552/3,634 = 97.7%**、余 82 条（6 长线族）。
- `python v7re/scripts/verify_all_pip.py --tile-type INT_L|INT_R --normalize` → `家族 172`、`精确命中 3634（100.0%）`、`mux 1536/1536`、`beg 2098/2098`、不符 0、未覆盖 0。
- `python -m pytest v7re\tests -q -p no:cacheprovider` → `15 passed in 0.37s`。

**三档结论（详见文档）**
- A 已证明 6 条（生成器闭合 / 校验双向 / 回归 15 passed / 复用度量 / 槽位编码 231,656 位 0 违例 / 真值 91.45%）。
- B 只有行为学证据 5 条（6×4 物理矩阵、列=长度类、BEG 二分、E5 全器件抽样、跨类型同形 19/32）。
- C 明确没做到 4 条（82 条长线无公式、行轴无版图证据=工具上限、跨类型 3/115、跨器件 0/1、26 帧块外与 word 50 未建模）。

**缺陷账排序（影响×可修性）**：①82 条长线（可修性高，判据 ≥80/82）②行轴版图证据（工具上限）③跨类型 3/115 ④跨器件 0/1 ⑤ECC 未闭合 ⑥位库粒度。

**自我攻击三条**（文档「如果我错了」节）：97.7% 是否自证（1 天：生成器不读 `law_cells` 直接比对，差异 ≤82 为通过）、列=长度类（≥95% 一致为通过）、跨类型同形（另选 `CK_BUFG_CASCO*` 复跑，≥50% 0 差异为成立）。

## 178. 6 个长线族的编码结构（2026-11-13 晚，缺陷账第 1 行的推进）

**做了什么**：把 6 个长线族从「逐源 2 格」重写成 **A 轴 × B 轴的双格边编码**（源 = 一条边 = 一个 A 格 + 一个 B 格），判据 = 源图能否 2-着色成二分。

**结构（`step03_pip/_q_longline_pairs.py`，实测）**

| 族 | 源 | 格 | A×B | 边/满格 | 完全性 |
|---|---|---|---|---|---|
| `LH0` | 12 | 9 | 5×4 = 20 | 12 | 稀疏 |
| `LH12` | 12 | 7 | 4×3 = 12 | 12 | **完全** |
| `LVB_L0` | 18 | 9 | 6×3 = 18 | 18 | **完全** |
| `LVB_L12` | 18 | 9 | 3×6 = 18 | 18 | **完全** |
| `LV_L0` | 10 | 7 | 4×3 = 12 | 10 | 缺 2 |
| `LV_L18` | 12 | 9 | 4×5 = 20 | 12 | 稀疏 |

- 【数据事实】**48/82 = 58.5% 落在完整乘积网格上**（`LH12` 4×3、`LVB_L0` 6×3、`LVB_L12` 3×6），与 mux（6×4）、BEG（5×4）是**同一种「双格边编码」**；剩下 34/82 是稀疏子集。
- 【数据事实】跨族共享的 3 个格正是长线互相选的结果：`LH0`/`LH12`/`LV_L0`/`LV_L18` 互为对方族的源，`(1,6,0)`、`(0,2,0)`、`(0,9,0)` 被 2–3 个族共用。
- 【数据事实】同一源在不同族里的 **A/B 序号不一致**（`LH0` 的 A 序号 = 0/1/3，B 序号 = 0/0/0/0）⇒ 没有全局「端口序号」规则。

**被证伪的三条候选规则（`_q_longline_order.py`、`_q_longline_ordinal.py`）**
1. 「按模板 `pip_defs` 顺序编号」：`LH0` 族的 11 个源按序排列后 A/B 格无周期（0..10 逐个不同），否。
2. 「按方向/到达边归类」：`LH0` 的 A 组 =「1 条长线 + 2 个端线」，但配对方向无固定规律（`NW2`+`NW6`、`NR1`+`SW2`、`NN6`+`SW2` 混装），否。
3. 「源名 → 全局端口序号」：`LH0` 在 `LH12`/`LVB_L0`/`LVB_L12`/`LV_L18` 里 B 序号恒 0，但 A 序号 1/0/1/3 不固定；`LH12` 的 B 序号 0/3/5/2/4 全不同，否。

**结论（更新缺陷账第 1 行）**
- 【数据事实】这 82 条不是「乱码」，而是**同一编码形式的稀疏实例**；两轴承载的是「物理到达端口」，不是名字属性，故不能用名字推导。
- 【数据事实】落表代价重新算过：**6 族共 ≤54 个格 + 82 条边**（远小于原估计的「6 张 9 格 × 18 边表」），且其中 48 条落在 3 个完整网格上，可按「4×3 / 6×3 / 3×6 的坐标表」压缩存储。
- 【推断】要把这 82 条彻底公式化，需要开关矩阵每个输入端口的物理编号（RapidWright/Vivado 均不提供，见 §176）⇒ 维持「表数据」判定，但表格规模已从 82 条压到 ≤54 格。



## 179. 数据盘点（2026-11-13 22:3x，按用户「重新更新我的数据」要求重跑）

**库**
| 库 | 大小 | 关键表 |
|---|---|---|
| `E:\v7work\model\v7_model.sqlite` | **7,949.3 MB** | `site_frames` **36,799,100 行 / 9,156 帧（全量，已补齐）**、`frame_map` 50,176、`sites` 86,022、`site_pins` 5,489,706、`tiles` 150,380、`pip_bits` 3,528 |
| `E:\v7work\model\v7_law.sqlite` | 15.2 MB | `law_cells` 24,328、`law_tiles` 62,625、`clb_cells` 3,884、`clb_blocks` 763、`far_bands` 1,078、`frame_blocks` 1,038、`tile_blocks` 53,102、`ppips` 2,958、`law_ctrl` 132、`law_iob` 37、`law_ppips` 216、`clk_cells` 94 |

**重要变化**：本机 `site_frames` 已是**全量 36,799,100 行 / 9,156 帧**（此前记录的 19,819,900 行残缺状态已不存在）⇒ 交接不再依赖远端那 7.6 GB 副本。

**代码/文档**：`v7re/steps/*.md` **123**、`v7re/scripts/*.py` **75**、`step03_pip/*.py` **433**、`v7re/docs/` 3（`PROJECT_PLAN.md`/`CLB_BIT_SPEC.md`/`CHIP_485T.md`）、`STATUS.md` **6460 行 / 204 个 `## N.` 小节**。

**发现的记账缺陷**：`## N.` 编号**有 39 个重复**（5, 6, 35, 52, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 114, 115, 117, 119, 126, 127, 147, 148, 149, 173），其中 87/88/89 各 3 次、`173` 两次（一为坐标系审计、一为长线族验证）。写论文引用前必须重编号，否则引不动。

**两个口径必须写清**（不是矛盾）：`gen_slots.py` 的 **3,552/3,634 = 97.7%** 指「能由槽位表生成」的 feature；`verify_all_pip.py` 的 **3,634/3,634 = 100%** 指「用表+定律整体校验无不符」。差集 82 条 = 6 个长线族，其中 48/82 已在完整乘积网格上（§178）。

## 180. 讲解稿：INT tile 族实验的思路 / 结果 / 问题（2026-11-13）

- 交付 `step03_pip/INT_TILE_FAMILY_EXPERIMENT_STORY.md`（298 行、11 节）：§3 八步链（每步写"排除了什么"）、§4 时间线（当时以为 → 后来改成）、§5 结果两列表（已外部验证 / 仅自洽分开）、§6 **17 个问题分五类**（数据获取/判读/统计/工具能力/文档脚本，每条含"没发现会得出什么错结论"）、§7 撤回表 7 行、§8 重做 10 条带代价、§9 缺口、§11 复算入口索引。
- 提示词：`step03_pip/PROMPT_INT_TILE_STORY_V1.md`（756 字符）→ `_V2.md`（1,281 字符，MCP `optimize-user-prompt` + `iterate-prompt`）；V2 追加六条硬要求（时间线专节、五类问题各≥2、错误结论必须带数字、撤回表、结果两列、重做 10 条带代价）。
- 稿中直接引用的最新数字：生成器 **3,552/3,634 = 97.7%** 0 差异；槽位不变量 **231,656 位 0 违例**；真值 1,155/1,263 = 91.45%；线长律 12,565 tile / 64,686 位表外 0；E8 50,176 帧全等；单 bit 检出 99.4438%；误报 240 位 / 120 tile（白名单后 0）。
- 该稿的定位：对外讲解件，不新增实验；所有数字均指向 `step03_pip/` 现有脚本（§11 索引）。



## 180a. 单一口径收口（①）+ 一键复现（②）落地（2026-11-13 22:4x）

按用户「欧克」启动收口工作。三件事里的前两件已完成。

### ① `SINGLE_SOURCE_OF_TRUTH.md`（仓库根，9 节）
把会写进论文的数字集中登记：每行=**值 / 口径 / 命令 / 状态**，状态分 ✅已现场验证、📊数据事实、🧩推断未闭合、❌作废。
- §1 器件与位流基础 9 行；§2 INT 复用主线 **24 行**；§3 其它 tile 类型 12 行；§4 **作废清单 9 条**（36 种行序、T13 INIT 表、24 源接口假设、word50、4.3% 残余、CLB 151 条可配置、site_frames 残缺…）；§5 CLB 位级 12 行；§6 CRC/ECC 7 行；§7 **待对账 5 条**；§8 复现入口；§9 术语表 10 条（外部 Agent 必读）。
- 关键新数字（本次重跑得到，此前未单独登记）：`(feature,cell)` 记录 **8,900**、不同 cell **1,598**（sense=1）、sense=0 **3,264 行/280 格**、BEG cover **640** feature、长线 **48/82 = 58.5%** 落在完整乘积网格。

### ② `repro.py`（仓库根，172 行）
一条命令跑 9 项检查：`python repro.py` → 逐项打印 `expect / 耗时 / PASS|FAIL`，末行 `OVERALL: PASS (9/9)`。
检查项与期望：`slots.coverage` 3552/3634、`slots.families` 族数 172、`verify.INT_L` 与 `verify.INT_R` 各 3634/3634、`mux.law` 1536/1536、`beg.shape` 32/32、`row.generator` 2048/2048、`tiles.instances` residual=0、`unit.tests` 15 passed。
踩坑：`gen_mux_rowlaw.py` 打印的是 `2048 / 2048`（带空格），正则写成 `2048/2048` 会假 FAIL——已改为 `2048\s*/\s*2048`。
**实测：9/9 PASS，总耗时 9.2 s**（`tiles.instances` 占 7.1 s）。

### 剩余
③ 图表数据包（把 134 个 json 收敛成 6 张图的 CSV，删 `_x.json` 类垃圾）——未开始。
④ `STATUS.md` 的 38 个重复小节编号未重编（写论文引用前必须处理）。

## 181. 术语+流程+覆盖指南（2026-11-13）

- 交付 `step03_pip/INT_EXPERIMENT_GUIDE.md`（167 行 / 8 节）：§2 **24 条术语四列表**（定义/本项目取值/真实例子/常见误解）、§3 单个 PIP 的端到端样例（`INT_R_X37Y199` 的 `SS6END0->>SS2BEG0`，两格 `(11,0,10)(13,0,10)`）、§4 八步流程（目的/做法/判据/产出/不做会怎样）、§5 六条"为什么"（替代方案/否掉原因/否掉会犯什么错）、§6 **覆盖三层账**、§7 六个易错概念、§8 复算入口。
- 提示词：`PROMPT_INT_GUIDE_V1.md`（1,636 字符）→ `_V2.md`（2,113 字符，MCP）。
- **覆盖结论（新核对的精确口径，与旧稿的 59 不一致）**：一个 INT tile 3,737 条 = **3,629 条有位记录的信号 PIP（97.1%）+ 64 条 `VCC_WIRE` 常量（1.7%）+ 44 条直通（1.2%）**；`law_cells` 3,634 与模板 3,629 差 **5** 条（长线跨族选源拼写差异，**未核实**）。
- 两个分母必须分开说：按 tile 内 PIP 算规则覆盖 **3,552/3,737 = 95.0%**；按 `law_cells` 特征算 **3,552/3,634 = 97.7%**。
- 器件级：**7,474/35,126 = 21.3%**（仅 INT_L/INT_R，单器件）；未覆盖的 27,652 条中 D 类密集多源占 15,518（44.2%）。补齐估算 **25–35 人日**。
- 脚本：`_q_cover_tile.py`（四类分解）、`_q_cover_pairs.py`（law vs 模板 归一化比对：tpl 3,737 / law 3,634 / law_only 5 / tpl_only 108 = 64 VCC + 44 直通）。



## 182. 小节编号收口（④）—— 并更正一条我自己报错的数字（2026-11-13 22:5x）

### 先更正
我在 §179 / §180 里写「`STATUS.md` 有 38 个重复小节编号」，**这是错的**，是我自己的统计 bug：正则写成 `^## (\d+)\.`，只抓整数前缀，于是把 `## 87.1.` `## 88.2.` `## 100.1.` 这类**小数小节**误算成 `87`/`88`/`100` 的重复。
用允许小数的正则 `^## (\d+(?:\.\d+)?)\.` 重算：208 个数字标题里**真重复只有 2 处**——`173`（两个「为什么」）与 `180`（讲解稿 / 收口）。

### 做了什么
- 备份：`_status_before_renumber_20261113.md`（改前的完整快照）。
- 把重号的**后一个**改为字母后缀：`173` → `173a`（长线族验证）、`180` → `180a`（单一口径收口）。
  选字母后缀而不是顺延重编，是因为全仓库有 **1,431 处 `§N` 引用**（113 个 md 文件，最多的是 `STATUS.md` 285 处、`step03_pip/_status_before_renumber_20261111.md` 218 处），整体重编会把这些引用全部打断；后缀法保留原有单个编号的全部语义。
- 新建 `STATUS_SECTION_INDEX.md`（274 行）：**206 个数字小节**的「编号 / 行号 / 标题」总表 + **53 个非数字遗留标题**（`## S26`、`## §18`、`## 附：…` 这类）单列一节。以后写论文引用一律查这张表。
- 复检：`STATUS.md` **6,512 行 / 206 个数字小节 / 0 重复**，最大号 `181`（`180a` 不占整数位）。

### 教训（写进纪律）
统计类断言必须先验证正则/口径本身。这次差点把 40 个正常的小数小节改成字母后缀，**是在写盘前用备份回滚才发现的**——所以今后任何批量改写 `STATUS.md` 前必须先 `copyfile` 备份。

## 183. 为什么 97.7% 补不到 100%：帧块分区 + 82 条的本性（2026-11-13）

**新实测（`step03_pip/_q_frame_partition.py`，INT_L sense=1，按源数分组）**

| 组 | 族数 | frame_off 范围 | 帧块位置 |
|---|---|---|---|
| 复合族（16 源） | 6 | **0..1** | 26 帧块最前 2 帧 |
| 长线族（18/12/10 源） | 6 | **0..1** | 同上（与复合族共用 0..1） |
| BEG（20 源） | 96 | 2..15（三种区间 2–7 / 6–15 / 7–15） | 中间 14 帧 |
| mux（24 源） | 64 | 16..25 | 最后 10 帧 |

- 【数据事实】**26 帧块按功能分区**：0–1 = 时钟/长线（12 族）、2–15 = BEG（96 族）、16–25 = mux（64 族），三块互不重叠。
- 【推断】这解释了 82 条为何推不出：它们与复合族同居帧 0..1，该区编码的是「物理到达端口」，不是名字属性；mux/BEG 区编码的是「逻辑方向 + 线长」，名字里就带着。

**为什么没补到 100%（四条原因，按强度排序）**
1. 【数据事实】四条候选规则全被证伪：模板 `pip_defs` 顺序（`LH0` 11 源无周期）、方向/到达边配对（A 组混装方向）、全局端口序号（`LH0` A 序号 1/0/1/3、B 序号恒 0）、几何类→格对（22/36 唯一）。
2. 【数据事实】6 族长线**互相选源形成闭环**：`LH0←LH12`、`LVB_L0←LVB_L12`、`LV_L18←LH0/LH12`、`LV_L0←LH12`，共享 3 个格（`(1,6,0)`、`(0,2,0)`、`(0,9,0)`）⇒ 无法用「族自身名字」闭合，必须外部锚（物理次序）。
3. 【数据事实】工具不给物理编号：`Site.getSitePIPs()` 只给 LUT 输出选择；`Tile` 无内部行列；Vivado `link_design` 几何探针挂死（§176）。
4. 【推断】再加样本（每源一个受控位流，82 个构建 ≈3 h）只能验证「表对不对」，不能把表变成公式——公式需要端口编号，样本再多也不产生编号。

**已做到的最好状态**：82 条 = 6 张表，合计 **≤54 个格 + 82 条边**；其中 48/82（`LH12` 4×3、`LVB_L0` 6×3、`LVB_L12` 3×6）落在**完整乘积网格**上，可按坐标表压缩存储。

**口径提醒**：数据覆盖是 100%（82 条全在 `law_cells`，解码器可用）；缺的是**公式覆盖**（能否只凭名字算出）。报告时必须分两列，否则会被当成"数据缺失"。



## 183. 图表数据包（③）落地（2026-11-13 22:5x）

### `make_fig_data.py`（仓库根，205 行）
从两个 SQLite 库 + 既有 json **自动生成** `figs/` 下 6 张图的数据，不手工编辑：

| 文件 | 行数 | 内容 |
|---|---|---|
| `fig1_frame_blocks.csv` | 1,078 | 帧布局：7 band × 154 列区块 + 帧区间 + 类别（36=CLB 111 列 / 28=INT / 30=CLOCK 4 列 / 32=BOUNDARY / 42=UNDETERMINED） |
| `fig2_fanin_families.csv` | 636 | 各 tile_type 每族的 fan-in 与 cell 数 |
| `fig2_fanin_hist.csv` | 45 | fan-in 直方图（INT 最大 24；BRAM 111 / DSP 280 / CLBLM 358 / CLBLL 338） |
| `fig3_coverage.csv` | 7 | 三档覆盖率：172/172、3634/3634、3552/3634、12565/53100、95.75% |
| `fig4_family_shape.csv` | 178 | mux 6×4 ×64、BEG K(a,b) ×108、长线 ×6 |
| `fig5_clb_bits.csv` | 2,875 | CLB 每个 cell 的语义 + 置信度四档 |
| `fig6_cells_per_feature.csv` | 6 | 复用度量：20→1、24→3、36→2、40→96(BEG)、48→6、72→64(mux) |

配套 `figs/README.md`：每列含义 + 四条画图注意（坐标系别混、word 50 排除、帧号 vs 块偏移、按 tile_type 分组）。
`--check` 走临时目录，不碰 `figs/`；已接入 `repro.py` 作为第 10 项检查。

### 新增的关键数字（画图时才发现）
- `fig6` 揭示的复用强度：**64 个 mux 族每族 72 格、96 个 BEG 族每族 40 格**——这是「复用」最直接的一句话量化。
- `beg_families.json` 里 108 个族中 **7 个不是二分形状**（`CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`、`LV_L0`），它们走 `kind/note` 字段，画形状图时必须单列，否则会 `KeyError: 'A'`（我第一版就崩在这里）。

### 垃圾文件清理
22 个下划线开头的 json 里，**16 个在 `*.py`/`*.md` 中 0 引用**，已移入 `_trash_20261113/`（含 `MANIFEST.json` 记录原路径、大小、理由），**没有删除**，可随时 `move` 回来。
保留 6 个有引用的：`step03_pip/_x.json`（STATUS 引用）、`_clbll_map.json`（T57 文档）、`_mcp_opt_raw.json`（提示词文档）、`_famspec.json`/`_famspec_r.json`（REMOTE_CLEANUP_PLAN）、`_famexp.json`（verify_reuse.py 等 12 处）。

清理后重跑 `repro.py`：**10/10 PASS**（新增 `figs.data` 检查）。


## 184. A 档交付提示词（给 ClawsGO 写论文用）（2026-11-13 23:0x）

### 产物
`HANDOFF_A_CLAWSGO_PROMPT.md`（仓库根，8 节）：0 角色与任务、1 数据包（10 个文件的表格 + 明确「不给 site_frames」）、2 引言素材三项要求、3 方法章节三件事、4 六张图画什么、5 六条硬性纪律、6 八条机械验收、7 卡住怎么办、8 可放心引用的核心数字表。

### 关键设计（为什么要这么写）
| 设计 | 原因 |
|---|---|
| 明说「v7_model.sqlite 7.9 GB 不给你」 | 它连不上这台机器；与其让它猜，不如规定「需要就写需要」 |
| 作废清单**点名 4 条**（36 种行序、24 源接口、word50、4.3% 残余） | 这四条是最容易被外部 Agent 从旧文档里捡走复述的 |
| 三套坐标系写死基数 154/412/111 | 我们自己也在这上面栽过（`band` 撞名，见 §172） |
| 验收 #6「输入未改（sha256 一致）」 | 云端 Agent 改输入是真实风险 |
| 验收 #7「空话检测」 | 论文引言最容易写「显著提升」而无数字 |
| 8 节数字表带脚注（1,598 vs 1,602） | 真源表 §7.1 有 4 格待对账，先给口径再给它，避免它二选一混用 |

### 数字核对（交付前逐条 grep 过）
`fig3_coverage.csv` 七行与真源表一致：172/172、3634/3634、3552/3634=97.74%、8900、(1,598)、12565/53100=23.66%、198434700/207253149=95.75%。`fig6` 六行确认「40→96 族（BEG）、72→64 族（mux）」。
`fig3_coverage.csv` 编码复核为**合法 UTF-8**（PowerShell `Get-Content` 默认按 GBK 显示才出现的乱码，文件本身没问题）。

### 生成方式
草稿经 `cd E:\DEEPSEEK\tools\prompt-optimizer; node po.mjs user <草稿> --template user-prompt-professional` 处理；优化器基本原样返回（本提示词结构已足够规整），人工补回硬数据表与脚注。

## 185. 流水线视角：INT tile 规律是怎么被处理出来的（2026-11-13）

- 交付 `step03_pip/INT_TILE_LAW_PIPELINE.md`（16 节）：九阶段（S1 位流→位矩阵 / S2 帧→tile 基址 / S3 受控差分 / S4 差异→cell 三元组 / S5 三套结构判据 / S6 两轴归属 / S7 172 族分桶 / S8 生成器 / S9 四支路验证），每阶段写「输入/处理(≤15 行伪代码)/输出/判据/真实数字/失败分支」。
- 关键新增表格：§11 一条真实连接的九阶段形态（`INT_R_X37Y199` 的 `SS6END0->>SS2BEG0`）、§12 数据量演进（162,168,832 位 → 88,358,400 建模位 → 8,900 记录 → 3,634 连接 → 1,598 格 → ~600 数字，总压缩 ≈2.7×10⁵）、§13 表结构演进、§14 「600 个数字重建 8,900 条记录」的 3 条前提、§15 12 行文字流程图。
- 提示词：`PROMPT_INT_PIPELINE_V1.md`（1,048 字符）→ `_V2.md`（1,524 字符，MCP；V2 增：表结构演进、每阶段失败分支、三套判据完整写法+真实反例、压缩代价、文字流程图）。
- 该文只整理既有实测，不新增实验；所有数字指向 `step03_pip/` 现有脚本（§16 索引）。



## 185. 复核 ClawsGO A 档交付：六条口径冲突全部成立（2026-11-14 10:4x）

对 ClawsGO 报的 6 条逐条机械复核，**全部成立**（我这边 R/CSV 实测确认），并已修复：

| # | 它报的问题 | 复核 | 处理 |
|---|---|---|---|
| 1 | `fig5` 缺 `word` 列，三维图无法画 | ✅ 确认：列里确实没有 `word` | **不补列**——`word = 2*(y%50)+(1 if y%50>=25 else 0)+parity`，随站点 y 变，**不是 tile_type 级量**。改为在 `figs/README.md` 写明为何没有、以及要画三维须先指定实例 |
| 2 | `fig5` 置信度只有 2 档（512 + 2,363），README 写 4 档 | ✅ 确认 | 新建 `v7re/steps/clb_manual_bits.json`（18 行，T82–T87 实测位），`make_fig_data.py` 合并 → 现在 **2,893 行 / 5 档**：confirmed 14、confirmed(INIT) 512、strong-candidate 1、candidate 3、unknown 2,363；新增 `provenance` 列（`db:clb_cells` 2,875 / `manual:T82-T87` 18） |
| 3 | `fig2_fanin_hist.csv` 26 行，README 写 45 | ✅ 确认（26 行） | README 改正为 26，并注明「只保留实际出现过的 (type, fan-in)」 |
| 4 | `fig4` 的 BEG 实际 101 行、全 `complete_product=True`，与「32/32」不是同一对象 | ✅ 确认（101 BEG + 64 mux + 6 longline + 7 composite = 178） | README 改正为 101，并加注「101/101 结构全二分」≠「32 族做过位流重建」；同时说明 64+101+7=172 与「每侧 172 family」自洽 |
| 5 | **`fig1` 只覆盖帧 0–36,719（36,708 帧），全器件 50,176** | ✅ 确认：`sum(frames)=36,708`、`max(end_frame)=36,719` | **这是本次最重要的发现**：`far_bands` 只覆盖 `FAR_BLOCK_0`，另一部分 13,440 帧（`FAR_BLOCK_1`）不在表内。已写入真源表 **§1.3**（36,708/50,176 = 73.2%），并在 `figs/README.md` 加「不得外推」警告。此前 §172/COORD_AUDIT 里「1,078 区块覆盖全部 50,176 帧」的说法**作废** |
| 6 | `fig3` README 称「三档」，CSV 实为 7 行 | ✅ 确认 | README 改正为「五档指标 + 两行交叉校验」 |

### 顺带闭环的数字
它做的交叉校验 `Σ(格数 × 族数) = 20+72+72+3,840+288+4,608 = 8,900` 与 `fig3` 的 `(feature,cell)` 记录数**逐位相等** —— 已固化为 `repro.py` 第 11 项检查 `figs.sum`（`sum 8900`）。

### 结论
A 档产出可用；**6 条冲突里 5 条是我方文档/CSV 的错，1 条是它的合理误判（`word` 列）**。它没有编造数字、没有混坐标系、输入未改 —— 三个校准点都过了。
`repro.py` 现 **11/11 PASS**；`STATUS.md` 本节约 6,6xx 行。


## 186. 补全器件区块表：`FAR_BLOCK_1` 的 13,440 帧（2026-11-14 11:2x）

### 背景
§185 复核时发现 `far_bands` 只覆盖 36,708 帧（73.2%），另 13,440 帧属 `FAR_BLOCK_1` 且**没有任何块表**。论文若画「器件完整布局」会少 27%。

### 做法
新增 `v7re/scripts/build_frame_blocks_full.py`（约 290 行）：直接读 `frame_map` 的真实 FAR，用 `bitstream.far.FarAddress.decode` 拆字段，按 `(block_type, top_bottom, row, column)` 聚块：

```
blocks                1183  (type0 1078 / type1 105)
frames                50148  (type0 36708 / type1 13440)
by class              BOUNDARY=14, BT1=105, CLB=777, CLOCK=28, INT=245, UNDETERMINED=14
columns per class     BOUNDARY=2, BT1=15, CLB=111, CLOCK=4, INT=35, UNDETERMINED=2
band -> (top,row)     0->(0,0) 1->(0,1) 2->(0,2) 3->(0,3) 4->(0,4) 5->(1,0) 6->(1,1)
clb_col attached      763/777
problems              none
```

产出 `v7_law.sqlite:frame_blocks_full`（1,183 行）+ `v7re/steps/frame_blocks_full.json`。

### 三条新结论
1. **`band` 的含义首次确定**：`far_bands.band` 0..4 = `(top_bottom=0, row 0..4)`，5 = `(1,0)`，6 = `(1,1)`。此前只知道它撞名、不知道它到底是什么。
2. **`FAR_BLOCK_1` 结构规整**：105 块 = 15 列 × 7 带，每块恰好 **128 帧**（其余类都是 28–42 帧）。
3. **`FAR_BLOCK_1` 在所有采样设计中恒为 0**（36 份：30 份随机 + 6 份定向 `_n1`/`_n3`/`_n4`/`_full8`/`_c0`/`f_o6`），逐帧统计非零数据字合计 **0**（已排除 word 50）。即：位流里这 26.8% 的帧被写进器件，但**不含任何配置数据**。用途未定（可能是大器件才用的第二 FAR 块，或 485T 上的填充）。

### 校对与收口
- 自检项：总帧 50,148、type0 1,078 / type1 105、每块帧段连续、覆盖 = 全帧减 28 overhead（无缝隙无重叠）、CLB 777 块 / 111 列、BT1 15 列。
- `fig1_frame_blocks.csv` 从 1,078 行（仅 bt0）换成 **1,183 行**（全器件），列增加 `block_type/top_bottom/row_addr`。
- `repro.py` 新增第 12 项 `frames.full`（`(1183, 50148)`）；现 **12/12 PASS**。
- 真源表新增 §1.11（全器件区块表）、§1.12（BT1 恒零）；原 §1.10 把「73.2%」标为**作废**。
- `figs/README.md` 的 fig1 段落整段重写（新列含义 + `band→(top,row)` 表 + BT1 灰色建议）。

### 一处自我纠错（第二次同类错误）
我第一次「补 §1.3」用 `"| 1.3 |" in s` 当成功判据——但该文件**本来就有**一张表存在 §1.3（行开销帧），所以判据恒真、插入其实没生效。同类的「存在性 grep ≠ 正确性」在 T24 的 15 位十六进制串上已经踩过一次。这次改为按行号定位 + 断言唯一匹配才落地。


## 187. fig1 绘图任务书（给 ClawsGO 的完整提示词，2026-11-14 20:5x）

产物 `HANDOFF_FIG1_PROMPT.md`（8 节）。经 `node po.mjs user <草稿> --template user-prompt-professional` 优化后再人工补硬数据表、验收项与作废口径。

### 结构
§0 角色与边界（只读一个 CSV、缺数据写「需要但未提供」）→ §1 输入（sha256 `ef36d862…510a8`、39,869 B、1,183 行 + 已核基线）→ §2 五条不可改写事实（含 `far_band→(top,row)` 对应表）→ §3 画什么（主图 + **BT1 必须独立面板**）→ §4 五条硬性纪律 → §5 三个交付物 → §6 八条机械验收 → §7 卡住怎么办 → §8 可放心引用数字 + 作废口径。

### 本任务书针对的三个真实陷阱
1. **BT1 列号与主图 far_col 数值重叠**（都是 0..14，但一个是 `FAR_BLOCK_1` 块内编号、一个是 `FAR_BLOCK_0` 列号）。不显式禁止就会画进同一坐标系，得到一张看似合理、实际把两套不相干的东西叠在一起的图。
2. **恒 0 的那些帧必须视觉区分**：`BT1` 13,440 帧有表、无内容。若与 CLB 同色，读者会以为器件下半部分有 13,440 帧配置数据。
3. **三套坐标系基数**：`far_col` 154 / `grid_x` 412 / `clb_col` 111。验收第 7 条要求全文检索裸 `col`/`band`/`x`。

### 验收里两条是「可机检的诚实性」
- 第 3 条：让它从 CSV **独立重算** 1,183 行、Σ=50,148、CLB 111 列、BT1 15 列，与图例逐一相等 —— 防它手抄错。
- 第 7 条：空话检测（显著/大幅/极大）。

### 输入核对数据
`figs/fig1_frame_blocks.csv`：39,869 B、1,183 数据行、sha256 `ef36d862c579db43d41f4f2b2a4630bec3ca96a33c80847e1912507b60a510a8`；
`class×block_type`：CLB/INT/CLOCK/BOUNDARY/UNDETERMINED 全为 bt=0，BT1 全为 bt=1；`Σn_frames=50,148`；`clb_col` 非空 763/1,183。

## 188. 复用规律讲解材料（任务书 + 三张图）

用户 m17600 要求「解释复用规律怎么找到的/长什么样/还缺什么，最好有图解，给提示词并使用」。

- 任务书 `HANDOFF_REUSE_LAW_EXPLAIN.md`（经 `node po.mjs user … --template user-prompt-professional` 生成提示词，人工补硬数据附录 2.1–2.7，含作废口径 6 条）。
- 出图脚本 `v7re/scripts/make_reuse_law_figs.py`（读 `v7_law.sqlite`，离线约 3 s），产物：
  - `v7re/steps/figs_law/law_1_reuse.png`：`IMUX_L40` 24 源 → 10 格（6 行格 帧 16–21 + 4 列格 帧 22–25），每源恰好 5 格（`Counter({5: 24})`）。
  - `v7re/steps/figs_law/law_2_codes.png`：S4 生成链（DIAG/ORTH 周期 8、R/L 周期 4 且 `j=3` X2 断裂）+ 16 种行序码 / 每码 4 族。
  - `v7re/steps/figs_law/law_3_coverage.png`：四档覆盖 172/172、3,634/3,634、3,552/3,634（97.74%）、12,565/53,100（23.66%）。
- 排版踩坑：`DejaVu Sans Mono` 无 CJK 字形（`Glyph 22522 missing`）→ 去掉该 font family；fig1 三版重排（源盒重叠 → 总线穿框 → 底部文字压网格）才可读。

## 189. 6×4 的第 4/5 行 512 槽位：列归属被压到 2 位/族

用户 m17684「试一下」→ 把 `6×4` 网格里第 4、5 行（BOUNCE 与 LOGIC/GFAN）的 512 个槽位压成生成律。

### 数据事实（`v7_law.sqlite:law_cells`，INT_L，64 个 mux 族）
- 每个源恰好 2 个 sense=1 格：1 个行格（帧 16–21）+ 1 个列格（帧 22–25）；24 个源的 (行,列) 对**互不相同**（48/48 族、64/64 族均 0 重复）。
- 第 4/5 行只放 LOGIC/GFAN 与 BOUNCE 两个类，**哪个类放第 4 行由 `(族号//8) 的奇偶` 决定**（`IMUX_L0..L7`、`IMUX_L16..L23`、`IMUX_L32..L39`、`BYP_ALT*` → row4；其余 → row5）。
- 行内 4 个成员占 4 个不同列。

### 规律：列先分「对」，再分「对内顺序」
列对（pair）由**源的类**唯一决定，512 个源、0 例外：

| 源 | 列对 |
|---|---|
| `LOGIC_OUTS_L0..L15` | `{0, 1}` |
| `LOGIC_OUTS_L16..L23` | `{2, 3}` |
| `GFAN*` | `{2, 3}` |
| `BYP_BOUNCE*` | `{2, 3}` |
| `FAN_BOUNCE*` | `{0, 1}` |

对内顺序只有 1 位：
- **LOGIC 组完全确定**：row4 → 排列 `(1,0,3,2)`；row5 → `(0,1,2,3)`（规范序 = L 序号升序、GFAN 排最后）。**64/64 族、0 例外**。
- **BOUNCE 组**：BYP 对与 FAN 对各剩 1 位，4 种组合 `((3,2),(1,0))` 18 族、`((2,3),(0,1))` 18、`((3,2),(0,1))` 14、`((2,3),(1,0))` 14 —— 仍是**数据**（2 位/族）。

### 量化
| 项 | 值 |
|---|---|
| 槽位数 | 512（64 族 × 8） |
| 每个槽位信息量 | 2 bit（4 列选 1） |
| 压缩前 | 1,024 bit |
| 压缩后 | **128 bit**（2 bit/族，仅 BOUNCE 的内对顺序） |
| 压缩比 | **8×**；LOGIC 那 256 个槽位**0 自由位** |

### 一条负结果
「BOUNCE 的列 = f(源名, 行)」不成立：14/42 个 (源,行) 组合仍取到两列（如 `BYP_BOUNCE1` 在 row4 既是 2 又是 3），所以对内存顺序不能从源名推出。

### 复现
```python
# 读 law_cells，按 sense=1 取每源的 (行格, 列格)，按上表校验列对；
# 已在 /tmp 探针里跑过：checked sources: 512  violations: 0
```

## 190. CRAM 排布图成因与"行"的四个义项（2026-11-14）

**文档**：`step03_pip/CRAM_LAYOUT_WHY_AND_ROW_TERMS.md`（199 行 / 12,638 B）
**提示词**：`step03_pip/PROMPT_CRAM_LAYOUT_WHY_V1.md`（2,043 字符）→ `_V2.md`（2,625 字符，MCP 两轮）
**缘起**：论文图 1（整片配置帧布局）被问「为什么长这样 + 行到底是什么」。

### 新增的可复算事实

1. 【数据事实】单段列深直方图（`far_bands`，7 段完全同构）：**36 帧 111 列 / 28 帧 35 列 / 30 帧 4 列 / 42 帧 2 列 / 32 帧 2 列**；`111×36+35×28+4×30+2×42+2×32 = 5,244` 帧/段，×7 = 36,708 帧。
2. 【数据事实】30 帧的 4 列 = `far_col 33 / 62 / 75 / 120`（时钟 CMT 列）；42 帧的 2 列 = `col 32 / 121`（紧邻 CMT）；32 帧的 2 列 = `col 0 / 153`（左右边缘）。
3. 【数据事实】守恒式 `30 + 42 = 36 + 36 = 72`：CMT 列少 6 帧、邻列多 6 帧，合计不变。
4. 【数据事实】与 §162 的时钟区实测互相印证：时钟 mux 位落在 `col 33` 的 `minor 26–29`（即 30 帧列的尾部），两条方法（读 FAR 布局 / 位流差分）独立同结论。
5. 【数据事实】block1 = 7 段 × 15 列 × 128 帧 = 13,440 帧；`36,708 + 13,440 + 28 = 50,176` 帧 = FDRI 5,067,776 ÷ 101。

### "行"的四义（此后引用必须带记号）

| 记号 | 范围 | 含义 |
|---|---|---|
| `y` | 0–349 | 瓦片行（几何纵坐标） |
| `row` | top=0: 0–4；top=1: 0–1 | FAR 段号 |
| `r` | 0–5 | tile 内 mux 输入组号（与纵向位置无关） |
| `minor` | 0–27/29/31/35/41 | 列内帧偏移（= `frame_off`） |

图 1 的细横线是 `minor`，不是 `y`；`y` 的信息编码在 `word` 里，不画在该图上。

### 复算入口

- `SELECT frames, count(*) FROM far_bands GROUP BY frames ORDER BY frames;` → `28:245, 30:28, 32:14, 36:777, 42:14`
- `SELECT band, count(*), sum(frames) FROM far_bands GROUP BY band;` → 7 行，各 154 列 / 5,244 帧
- `python step03_pip/_q_far_minor_identity.py` → 36,708/36,708
- `python step03_pip/_q_col_three.py` → tile 列 158 / FAR 列 154 / grid_x 412

### 未测（文档 §6.3 明列）

① 28 帧 35 列 vs 36 帧 111 列的资源差异（只做了推断，未逐列核对）② FAR `top` 字段物理含义（为何 5+2 段）③ block1 的 15 列与 grid_x 的对应 ④ "36" 这个常数是否等于某类资源配置位 ÷ 3,200。

---

## 191. 全量活跃实例扫描（92 位流 / 7,453 扫描 / 0 违例）

**文档**：step03_pip/ALL_BITS_SCAN_20261114.md　**脚本**：step03_pip/_q_all_bits_scan.py　**结果**：step03_pip/out/all_bits_scan.json

### 一句话

【数据事实】本地 92 个位流、7,453 次活跃 tile 扫描（去重 1,965 个 tile，占 INT 实例 3.70%）、32,350 个置位上：**L2 槽位违例 0**（95% 上界 0.040%）；L1 未解释位 576（1.78%），其中 558（96.9%）落在 3 个已知标记格 (1,0,0)/(1,1,0)/(0,16,1)，其余 18 个散在 5 个格且**只出现在手工探针设计**；真实设计 
ef.bit 982 tile / 240 未解释（全为上述 3 格）/ 0 违例。

### 关键数字

| 指标 | 值 |
|---|---|
| 位流 / 扫描次数 / 不同 tile | 92 / 7,453 / 1,965 |
| 扫描置位数 | 32,350 |
| L2 违例 | **0** |
| L1 未解释 | 576 = 558(3 格) + 18(5 格) |
| 非白名单位所在文件 | _c3/_c3_rt/_c4/_c4_rt/_c5/_c0_to_c3/_g16_edit/_rt_g16_s0/_resynth/_s8v0（全为手工探针） |

### 口径

L1 = 未被任何命中族解释的置位（扫 rame_off 0..25）；L2 = 槽位编码律（一热 ≤1 行 / 有行⇒码∈{1,2,7,11} / 有码⇒有行）；活跃 tile = 该 tile 帧 0..25 有任一置位；上界用 rule of three 3/n。

### 边界

只覆盖 3.70% 实例；92 个位流全是 INT 相关设计，不能证跨类型普适；18 个非白名单位除 (1,7,1)/(1,3,1) 外尚未逐位归因。

---

### S71 · fuzz 流水线文档化（2026-11-15）

新增两份交付物（不改动任何实测数据）：

- `step03_pip/FUZZ_PIPELINE_DETAIL.md` —— 七段流水线详解：语料 fuzz（被动）→ 定向 fuzz（主动）→ 并发执行 → 差分判读 → 归属判定 → 写回验证 → 落库。每段按「输入/操作/输出/判据」组织，判据写成可执行断言；每段附「这一步会怎样静默撒谎」（症状 / 为什么看起来正常 / 如何区分）；含失败传播图与止损点；含吞吐表（32 并发 214 s、峰值 RSS 3.0 GB、语料扫描 ≈3 min）。
- `step03_pip/PROMPT_FUZZ_PIPELINE_V1.md` —— 生成该文档的提示词（`optimize-user-prompt` + `iterate-prompt` 两轮）。

同时新增 `step03_pip/FRAME_ADDRESS_FUZZ_GUIDE.md` + `PROMPT_FRAME_ADDR_FUZZ_V1.md`（帧结构/寻址/复用规律的新人材料）与配图 `fig_frame_addressing.png`。

**本轮澄清的三条概念**（已在文档中体现）：① `parity` 是行槽低/高字索引，不是校验位；② `101 = 50 行 × 2 字 + 1 校验字`；③ 文件内 band 顺序为 `2,3,4,5,6,1,0`（非单调），band 间各有 66 帧间隙，尾部 13,488 帧属 IO/GTX/CFG 侧。

## 192. G1 关闭：INT tile 的 3,737 条 PIP 全部有交代

**文档**：step03_pip/G1_SPECIAL_PIPS.md　**脚本**：step03_pip/_g1_special_pips.py　**结果**：step03_pip/out/g1_special_pips.json

### 结论

【数据事实】**3,737 = 3,629（位坐标实测）+ 64（VCC 常量，无位）+ 44（扇入=1 直通，无位）**。L1 位坐标完备度由 3,629/3,737 = 97.1% 升为 **3,737/3,737 = 100%**。

### 分类（templates/INT_L.json，按目的 wire 扇入分组）

| 扇入 | 目的 wire | PIP | 说明 |
|---|---|---|---|
| >1 | **172** | **3,693** | 172 个 mux 族，其中 64 族含一条 VCC_WIRE |
| =1 | **44** | **44** | 无选择的直通 |
| 合计 | 216 | **3,737** | — |

### VCC 无位（三条独立证据）

1. law_cells 里源名含 VCC 的 feature **0** 条；族坐标制只有 24 槽（6 行×4 码），VCC 没有第 25 个槽。
2. pip_bits 3,528 条里 **frame/word/bit 为 NULL 的恰 48 条，全部是 VCC_WIRE → IMUX_L***（non-NULL VCC = 0）；同批实验 IMUX_L0 的 23 个信号源全部有位。
3. 外部独立实现 prjxray_ref/PRJXRAY_COMPARE.md:74：INT 3,737 → 有位 3,629 → **无位 108**，与本地逐条一致（本地缺 0、prjxray 多 7）。

### 直通无位（结构 + 统计）

- 扇入=1 ⇒ 无选择 ⇒ 无选择位；law_cells 172 族全为扇入>1。
- 位池恒 1 检测（ref.bit 982 活跃 tile / 1,664 池格）：曾有置位 448 格，**恒 1 的 0 格、≥90% 的 0 格**；若直通/VCC 占位则必恒 1。

### 边界

INT 侧的 VCC 无法用本地位流差分直接证明（常量输入不产生受控对），故依赖证据 1+3；证据 2 来自同机制的 CLBLL_L 类型（CLBLL_L_X6Y11 的 IMUX_L0）。

### 复算

python step03_pip/_g1_special_pips.py；SQL：SELECT count(*), sum(CASE WHEN frame IS NULL THEN 1 ELSE 0 END) FROM pip_bits WHERE wire_a LIKE '%VCC%' OR wire_b LIKE '%VCC%'; → 48 / 48。

### 剩余闸门

G2 精确覆盖解码真值对账（1–2 人日，本地）｜G3 82 条长线公式（可选）｜G4 跨类型（需远端）｜G5 分母表述（0.2 人日）。

---

### S72 · INT tile 建立流程文档化（2026-11-15）

- `step03_pip/INT_TILE_CONSTRUCTION.md` —— 把 S9/S10/S24/S30/S31/S37/S38 合并成一条线：拓扑层（prjxray V7 原生库 + 106 条 IO 补丁 + get_pips 真值）→ 位层（同一 DCP 改一根网的 1,200 变体）→ 地址层（frame_blocks + wof(Y) + 45 个 LOC 锚点）→ 同质性（14 tile × 6 邻接字节级相同；181→140 L/R 去重）→ 三条独立校验（CSP 48/48、ROUTE 6/6、写回 864/864）。
- 配图 `step03_pip/fig_int_tile_build.png`（四面板：拓扑层 / 变体位流水线 / 地址层 / 收敛指标）。

## 193. G2 关闭：精确覆盖解码与真值对账

**文档**：step03_pip/G2_EXACT_COVER_RECONCILE.md　**脚本**：step03_pip/g2_exact_cover.py、_q_g2_debug.py　**结果**：step03_pip/out/g2_exact_cover.json

### 判据

把解码从「逐 PIP 独立判全格置位 + min-cells」换成**精确覆盖**：	arget = observed − KNOWN_UNMODELED，解 S 满足 ∪cells(S) = target（不允许余量、不允许少解释）；枚举极小覆盖，每 tile 解上限 200、节点 40 万（本实验未触顶）。

### 结果（	amper/ref/ref.bit，982 活跃 INT tile）

| 指标 | 旧判据 | 新判据 |
|---|---|---|
| 解出 PIP | 1,886 | 1,413 |
| TP | 1,155 | **1,407** |
| FP | 731 | **6** |
| FN | 108 | **21** |
| 精确率 | 61.24% | **99.58%** |
| 召回率 | 91.45% | **98.53%** |
| 解唯一性 | 无定义 | **868/868 唯一解**（0 多解/0 零解/0 截断/0 孤格） |

- 有真值 tile **868**，其中 **857（98.7%）逐条相同**。
- 另有 **114** 个活跃 tile 的真值只有一条长线行（LV_L18 63 + LV18 51）、数据位为 0 —— 长线「记账位置≠位位置」，不计入对账。

### 残差（21 FN / 6 FP，全部有名有姓）

- FN 6 条：方向反转（LH12←LV0 解成 LV0←LH12，两条反方向 PIP 共用格）。
- FN 9 条：目的线扇入=1（如 FAN_BOUNCE7←FAN_ALT7），固定直通无位，与 §192 的 44 条同源。
- FN 6 条：真值 LV_L18←LV0 的 2 格已被其它 PIP 点亮，极小覆盖不重复记账。
- FP 6 条：LVB0←LVB12(3)、LH0←LH12(2)、LV0←LH12(1)，与第一条同源。

### 两个坑（都已写进文档）

1. **真值方向**：get_pips 写法是 <src>->><dst>，而 law_cells.family 是目的线；取反会得到 TP=0/FP=1,413 的整齐崩坏，可作自检信号。
2. **名字归一化**：真值里有 LV0<< 之类方向后缀；剥离后 **153 条真值行**由漏报转为命中，候选池归一化后为 3,634。

### 一句话

「位流→配置」是唯一映射（868/868 单解），此前的 731 条多报是**判据缺陷**而非编码歧义；换判据后多报降到 6 条且全部归因。

### 剩余缺口

单一设计（只有 ref.bit 有真值）｜114 个长线记账 tile 需「位归到线」的新模型｜跨类型 0/115（G4，需远端）｜21 条 FN 的口径需在论文里明写。

### 复算

python step03_pip/g2_exact_cover.py → 期望 唯一解 868 / 真值∈解空间 857 / TP 1407 FP 6 FN 21；残差归因 python step03_pip/_q_g2_debug.py。

---
## 194. P1 级补强：7 个独立设计上的位级复现与真值对账（2026-11-15）

**一句话**：7 个结构互不相同的新设计、656 个活跃 INT tile，位坐标 + 精确覆盖解码 vs Vivado `get_pips` 真值 —— **精确率 100%（FP=0）**、**可检出行召回 100%（4,682/4,682）**；未检出的 1,348 行全部是结构上无配置位的连接（620 常量源 + 728 扇入=1 直通），**真漏 0**。

### 设计（`step03_pip/gen_p1_designs.py` → `tamper/ref/p1/`）

| 设计 | 结构 | 活跃 tile | 置位 | 构建 |
|---|---|---|---|---|
| d1_lut_chain | 24 级 LUT6 链 | 31 | 1,744 | OK |
| d2_lut_big | 64 LUT6 / 2 列×32 行 | 56 | 4,368 | OK |
| d3_carry | 16 级 32 位累加器链 | 125 | 25,340 | OK |
| d4_fanout | 1 驱动 64 LUT | 51 | 3,906 | OK |
| d5_srl | 32 SRL16E / 4 时钟区 | 314 | 3,908 | OK |
| d6_muxtree | 8 组×6 层 2:1 | 47 | 2,698 | OK |
| d7_spread | 16 LUT / 4 region | 32 | 1,264 | OK |
| d8_dense | 96 LUT 单 region | — | — | 失败 |

d8 失败原因：`ERROR: [DRC LUTLP-1] Combinatorial Loop Alert: 96 LUT cells form a combinatorial loop`（设计写成 `t[i] ← t[(i+1)%96] / t[(i+5)%96]`，确实成环；不是工具问题）。

### 结果（`out/p1_replication.json`）

| 设计 | tile | 唯一解 | 多解 | 零解 | 表外位 | 完全一致 | TP | FP | FN | 精确率 | 召回 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| d1_lut_chain | 31 | 31 | 0 | 0 | 0 | 26 | 183 | 0 | 63 | 1.000 | 0.744 |
| d2_lut_big | 56 | 56 | 0 | 0 | 0 | 45 | 590 | 0 | 103 | 1.000 | 0.851 |
| d3_carry | 125 | 125 | 0 | 0 | 98 | 40 | 2,392 | 0 | 605 | 1.000 | 0.798 |
| d4_fanout | 51 | 51 | 0 | 0 | 0 | 36 | 419 | 0 | 157 | 1.000 | 0.727 |
| d5_srl | 314 | 314 | 0 | 0 | 64 | 280 | 581 | 0 | 246 | 1.000 | 0.703 |
| d6_muxtree | 47 | 47 | 0 | 0 | 0 | 36 | 381 | 0 | 135 | 1.000 | 0.738 |
| d7_spread | 32 | 32 | 0 | 0 | 0 | 28 | 136 | 0 | 39 | 1.000 | 0.777 |
| **合计** | **656** | **656** | **0** | **0** | **162** | **491** | **4,682** | **0** | **1,348** | **1.000** | **0.7765** |

### 残差归因（`out/p1_residual.json`）

- 【数据事实】620 行常量源（`VCC_WIRE`/`GND_WIRE` 驱动目的线，无可编程连接）
- 【数据事实】728 行目的线扇入=1（`pip_defs` 固定连接，无选择位）
- 【数据事实】**真漏 0 行** ⇒ 可检出召回 = 4,682/4,682 = 100%

### 判据与唯一放宽处

判据与 G2 一致（obs → 去 3 个标记格 → 候选 ⊆ obs → 穷尽枚举要求 union == target → 恰 1 解）。
唯一放宽：`target` 中任何候选都覆盖不到的格（模型外位，GCLK 时钟字段）单列 `outside_bits` 后剔除，否则 96 个 tile 判零解。合计 162 个表外位（d3 98、d5 64），全在 `frame_off 0..2`。

### 边界

单器件 `xc7vx485tffg1761-2`、单类型 INT_L/INT_R（2/115）；真值为 Vivado 自身导出，**非硅片回读**；d8 未建成（样本 7）；表外位未解释编码。

复算：`python step03_pip/p1_replication_cells.py` / `python step03_pip/_q_p1_residual.py`；文档 `step03_pip/P1_REPLICATION.md`。

## 195. 项目工作详情总表（PROJECT_WORK_SUMMARY.md）

用户 m17786「帮我把当前项目工作详情整理 md 文件」→ 新建仓库根 `PROJECT_WORK_SUMMARY.md`（11 节 / 387 行 / 21,908 B）。

- 结构：一句话现状 → 目标与边界 → 环境与数据资产（含「只在本机 / 只在远端」表）→ 已闭合成果（帧系统 / INT 四类机制 / CLB / 时钟 / 其它类型 / ECC-CRC）→ 关键数字总表 → 方法论八条 → 未闭合清单（数据缺口 vs 方法上限）→ 代码与文档索引 → 作废口径九条 → 复现方式 → 对外交付现状 → 术语表。
- 数字现场重取：`v7_model.sqlite` 7,581.1 MB（`site_frames` 36,799,100 / `frame_map` 50,176）、`v7_law.sqlite` 14.61 MB（`law_cells` 24,328 / `frame_blocks_full` 1,183 / `clb_cells` 3,884）、`v7re/scripts` 77、`step03_pip` 462、`v7re/steps/*.md` 123、单元测试 15 passed、`repro.py` **12/12 PASS（约 9 s）**。
- 族按机制分解（修正此前「172/64/96」混用）：172 = `IMUX` 48 + `BYP_ALT`/`FAN_ALT` 16（24 源 mux，1,536 feature）+ BEG 96（1,920）+ 时钟/控制 6（96）+ 长线 6（82）⇒ 3,634 feature。
- 注意：本节编号原写 §191，与另一线（`P1_REPLICATION`）已占用的 §191 冲突，改为 §195；`STATUS.md` 现另有 §185 重号待清，最大号 195。
## 196. P1 补强第二轮：12 个设计、844 个 tile、零误报（2026-11-15）

**相较 §194 的变化**：第一轮 7 个设计（656 tile、TP 4,682、FP 0、FN 1,348）扩到**第二轮 12 个设计**——新增 `d8b_dense`（96 LUT 密集，修掉 d8 的组合环）、`d9_wide`（32 个 LUT6 全 6 输入）、`d10_long`（16 LUT 横跨最远列，压长线族）、`d11_mix`（24 LUT + 16 SRL16E）、`d12_fanout2`（2 源各驱动 48 LUT）。

### 汇总

| 指标 | 数值 |
|---|---|
| 设计数 | **12**（全部建成，各 20,273,538 B） |
| 活跃 INT tile | **844** |
| 唯一解 / 多解 / 零解 | **844 / 0 / 0** |
| TP / FP / FN | **5,940 / 0 / 1,400** |
| 精确率 | **1.000** |
| 召回（对全部真值行） | 0.8093 |
| 可检出行召回 | **5,940/5,940 = 100%** |
| 表外位（GCLK 时钟字段） | 164（d3 98 + d5 64 + d11 2） |
| 完全一致的 tile | 656/844 |

### FN 1,400 行逐条归因（`out/p1_residual.json`）

- 【数据事实】**775 行扇入=1 直通**（`pip_defs` 固定连接，无选择位）
- 【数据事实】**625 行常量源**（`VCC_WIRE`/`GND_WIRE` 驱动目的线，无可编程连接）
- 【数据事实】**真漏 0 行**（775 + 625 = 1,400，`misses` 为空）

### 分设计（`out/p1_replication.json`）

| 设计 | tile | 唯一解 | 表外位 | 完全一致 | TP | FP | FN | 精确率 | 召回 |
|---|---|---|---|---|---|---|---|---|---|
| d1_lut_chain | 31 | 31 | 0 | 26 | 183 | 0 | 63 | 1.000 | 0.744 |
| d2_lut_big | 56 | 56 | 0 | 45 | 590 | 0 | 103 | 1.000 | 0.851 |
| d3_carry | 125 | 125 | 98 | 40 | 2,392 | 0 | 605 | 1.000 | 0.798 |
| d4_fanout | 51 | 51 | 0 | 36 | 419 | 0 | 157 | 1.000 | 0.727 |
| d5_srl | 314 | 314 | 64 | 280 | 581 | 0 | 246 | 1.000 | 0.703 |
| d6_muxtree | 47 | 47 | 0 | 36 | 381 | 0 | 135 | 1.000 | 0.738 |
| d7_spread | 32 | 32 | 0 | 28 | 136 | 0 | 39 | 1.000 | 0.777 |
| d8b_dense | 44 | 44 | 0 | 31 | 761 | 0 | 23 | 1.000 | 0.971 |
| d9_wide | 39 | 39 | 0 | 37 | 122 | 0 | 4 | 1.000 | 0.968 |
| d10_long | 34 | 34 | 0 | 32 | 125 | 0 | 5 | 1.000 | 0.962 |
| d11_mix | 41 | 41 | 2 | 35 | 201 | 0 | 20 | 1.000 | 0.910 |
| d12_fanout2 | 30 | 30 | 0 | 30 | 49 | 0 | 0 | 1.000 | 1.000 |
| **合计** | **844** | **844** | **164** | **656** | **5,940** | **0** | **1,400** | **1.000** | **0.8093** |

### 关键工程细节（复现必须知道）

1. 一帧被同一 `(band,col)` 的 **50 个 tile 共享**，必须按 `word → row` 分位，否则全部解判零解（第一版踩过）。
2. 模型三元组是 **`(frame_off, bit, parity)`**，不是 `(frame_off, word, bit)`；word 由实例的 `Y%50` 现算。
3. word 50 是 ECC，必须跳过；不跳过会引入每帧 1 个字的结构性噪声。
4. 表外位（GCLK 时钟选择）需单列剔除，否则 96 个 tile 判零解；本轮共 164 个。
5. `d8_dense` 第一轮失败于 `DRC LUTLP-1`（组合环），改链式后成功；写 Verilog 时要自己先看有没有环。

### 边界

单器件 `xc7vx485tffg1761-2`、单类型 INT_L/INT_R（2/115）；真值是 Vivado 自身导出、**非硅片回读**；12 个设计均为小规模单时钟、无 BRAM/DSP 实例。

复算：`python step03_pip/gen_p1_designs2.py` → 远端 `bash run_new.sh` → `_dump.py out2` → `python step03_pip/p1_replication_cells.py` / `_q_p1_residual.py`；文档 `step03_pip/P1_REPLICATION.md`。

## 197. 逆向 Vivado：7 系列 CRC 是 CRC-32C，并已提取出 32×37 线性矩阵（2026-11-15）

背景：§152 的「路线 B（反解多项式）」失败，CRC 一直停在「按锚点局部可用」。本次改为**直接逆向 Vivado 的比特流库**。

### 目标定位（关键：bitgen 功能在共享库，不在巨型可执行文件）

- `$XILINX_VIVADO/lib/lnx64.o/librdi_bitstream.so`（3,252,032 B，**符号未剥离**）
- `$XILINX_VIVADO/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitgen.so`（499,288 B）
- `$XILINX_VIVADO/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitstream.so`（185,440 B）

`lnx64.o` 下没有 `bitgen` 可执行文件（只有 vivado/xelab/hw_server 等），Vivado 的 bitgen 走库调用。

### 符号表直接给出算法入口

- `FUJIBS_BITFILE::crc32_37(char*, char const*, char const*)` @ `0x80b0`（3,498 B）
- `FUJIBS_BITFILE::crc32_37(char*, int, char const*)` @ `0x8e60`（65 B，把整数展开成 32 个 '0'/'1'）
- `FUJIBS_BITFILE::add_crc(bool, char*)` @ `0x8eb0`、`add_rbcrc` @ `0x8f00`、`recalc_crc()` @ `0xc110`
- `Bs_FujiBitfile::calcCRC(std::bitset<32>&, std::bitset<32> const&, std::bitset<5> const&)` @ `0x14f590`
- `Bs_FujiBitfile::calcRBCRC(std::bitset<32>&)` @ `0x15d260`

### 不能 dlopen：安装完整性自检

`dlopen(librdi_bitstream.so)` 在**加载阶段**就打印 `Error: The file  is corrupt. Please re-install this software from the original media.`（字符串来自 `librdi_common.so` / `librdi_device.so`，不在 librdi_bitstream 里）。设 `XILINX_VIVADO`、把测试程序放进安装目录、伪造 `argv[0]`、改 cwd 均无效；ISE 侧 `libBsFuji_Bitstream.so` 单独加载缺 `BS_BITFILE::getNumOptions()`。

### 绕过：Unicorn 直接模拟核心 `0x14d870`

`calcCRC` 只是壳（检查 `[this+0x125]` 后 `jmp 0x14d870`）；核心 7,456 B，是 37 位向量 → 32 位的位运算网络。用 Unicorn 按 PT_LOAD 映射 ELF 段，从 `0x14d870` 以 `(rdi=out, rsi=in, rdx=sel)` 调用（wrapper 已重排参数，非 SysV 原序），得到 37 列矩阵。

### 结果

**第 36 列（选择器最高位）= `0x82F63B78` = 反射版 CRC-32C（0x1EDC6F41 位反转）**。即 7 系列用的是 CRC-32C，不是 zlib 的 CRC-32 —— 这解释了 §152 为什么按 0x04C11DB7 怎么试都不中。

矩阵全文见 `step03_pip/crc_matrix.json`，过程见 `step03_pip/CRC_RE_FINDINGS.md`，脚本 `step03_pip/_crc_emu.py`（Unicorn）与 `dis*.py`（capstone）。

### 尚未闭合

- 调用语义：32 位输入是「上一轮 CRC」还是「数据字」、5 位选择器各位含义、循环覆盖区间（UG470 说自 RCRC 之后、含头部包）——需读 `recalc_crc`(`0xc110`) 与 `calcRBCRC`(`0x15d260`) 的循环。
- 与真实 .bit 对齐：`_crc/c_base.bit` 的 `0x591AE6B5`（§151）尚未被矩阵复现；已排除 sync 起点 + `M(c^w)`/`M(w)^c` + 位反转/字节序 + init 0/0xFFFFFFFF 的直白组合。
- 结论不影响主线（PIP 编码规律/解码器/FASM 层），仅影响「自造位流能否被器件加载」。

### 附带

REA（npm `rea-agents` 6.7.0）已装；`rea` 的 Ghidra 依赖用 ghproxy 镜像下载到 15 MB 后连接被重置，暂不影响（Unicorn 路线不需要 Ghidra）。

## 198. INT tile PIP 规律覆盖率审计（三档口径 + 108 条非可配置行的对账）

**问题**：INT tile 的所有 PIP 配置是否都已找到规律。

**答案：不是全部。** 位级 100% 已知并复现，但“律”只覆盖 95.10%；2.26%（82 条）只有表没有律。

### 198.1 三档覆盖（互斥，INT_L 与 INT_R 数字相同）

| 档 | 分子/分母 | 比例 | 判定口径 |
|---|---|---|---|
| 位级已知（feature→格 清单） | 3,634/3,634 | 100% | `law_cells` 有该 feature 的 (frame_off,parity,bit)，且 `verify_all_pip.py` 预测与库全等、0 不符 |
| 可由公式/表重建 | 3,552/3,634 | 97.74% | `step03_pip/gen_slots.py`：定律 3,456 + 复合组模型 96 |
| 纯定律（无逐族回落） | 3,456/3,634 | 95.10% | mux 1,536（64×24）+ BEG 1,920（96×20），`gen_slots.py` 打印「纯定律 64/64、96/96，需回落 0」 |
| 无公式 | 82/3,634 | 2.26% | 6 个长线族 `LH0/LH12/LV_L0/LV_L18/LVB_L0/LVB_L12` |

复现：`python repro.py -k verify`、`python step03_pip/gen_slots.py`。`gen_slots.py` 的原始输出：
`族数 172：24 源 64 / 20 源 96 / 其它 12`、`[mux] 纯定律 64/64`、`[BEG] 纯定律 96/96（变体 32/32）`、
`覆盖 定律 3456/3634 + 复合组模型 96/3634 = 3552/3634（97.7%），余 82 条无公式`、
`规模：3634 个 feature、1602 个不同 cell、8900 条 (feature,cell) 记录`。

### 198.2 108 条非可配置行：完整对账（本次现场核）

从远端 `/opt/lzh/v7re/work/refs_20261021/routing/out_routing/templates/INT_L.json`（141,121 B）与 `INT_R.json`（136,361 B）
取回模板（base64 走 ssh，本地 `_tif/INT_L.b64`），逐行对账：

```
模板 pip_defs 3737 行，无序去重后仍 3737
law_cells 无序对 3629 个；交集 3629，仅模板有 108，仅库有 0
```

108 条明细 = `law_ppips` 的 108 行：

- **44 always（硬连线，0 配置位）**：`BYP_BOUNCE0..7`(8) + `BYP_L0..7`(8) + `FAN_BOUNCE0..7`(8) + `FAN_L0..7`(8) = 32，
  外加 `GCLK_L_B6..B11_EAST/WEST` 12 条（GCLK 主干东西分叉，每根两次）。它们是从 BYP_ALT/FAN_ALT 或 GCLK 主干**直连**的线段，没有选择就没有配置位。
- **64 default（VCC 默认源）**：`IMUX_L0..47` 48 条 + `BYP_ALT0..7`/`FAN_ALT0..7` 16 条，各有一条 `src_wire='VCC_WIRE'` 的默认输入行。这是 mux 的“无源默认态”，不占配置位。

**对齐结论**：`3,737 = 3,629 个可配置无序对 + 108 条非可配置行`，无未解释余项。
`3,634` 与 `3,629` 的差 5 条是同一线对的双向声明（`LVB_L0↔LVB_L12`、`LH0↔LH12`、`LH0↔LV_L18`、`LH12↔LV_L0`、`LH12↔LV_L18`），属长线互连。

### 198.3 缺口分类（“有数据无律” vs “没数据”）

| 缺口 | 数量 | 性质 | 说明 |
|---|---|---|---|
| 长线 6 族 | 82 条 feature / 46 格 | **有数据、无律** | `law_cells` 有位、`verify_all_pip` 能命中；但 `gen_slots.py` 无法生成，写 FASM 时只能查表 |
| `LV_L9` / `LH6` 驱动 | 2 条线 | **没数据** | 它们只作源出现在别人族里，自身没有目的族（模板里也没有），不是配置缺口 |
| mux 行序 | 20 bit/族 | 参数化（半律） | 由 S4 生成链给出，但 4 个基置换是数据 |
| mux 列内顺序 | 32 bit 全局 | 表 | 类→列对是律，对内第几格是表 |
| BEG 成员→格 | 96 族节点表 | 表 | 形状是律（K(4,5)/K(5,4)），成员分配是数据 |

### 198.4 提升路径（要把“纯定律”从 95.1% 提到 90% 以上——实际已达标；要提速的是覆盖率而非比例）

若目标是让 82 条长线也进“纯定律”：
1. 补齐长线→长线续接边：已知 26 条去重边（`LV_L0←{LH12,LH6}` 等），再补 `LH6/LV_L9` 的驱动族（需构造 2 个设计，约 3 分钟机时）。
2. 对 6 个长线族各做一次「按源逐个置位」的差分（6 族 × 16 次 ≈ 96 次构建，32 路并发约 6 分钟），验证“每源 2 格”在长线上是否与 BEG 同构。
3. 若 2 成立，长线可复用 BEG 的二分图模型，82 条并入定律 → 纯定律 3,538/3,634 = 97.36%。

**未核**：`LV_L9`/`LH6` 是否真的在 Vivado 模板里没有目的族（只查了本项目的 `law_cells` 与 INT 模板，未查 RapidWright 拓扑）。

### 198.5 交付

- 提示词：`PROMPT_INT_PIP_LAW_COVERAGE.md`（经 `prompt-optimizer` 生成后补硬数据与复现命令）
- 本审计的全部数字来自现场：`repro.py` 2/2 PASS、`gen_slots.py` 输出、模板 3,737 行对账脚本（临时）。

## 199. 长线实例解剖：一条 LH12 跨 60 个 tile，只有 4 个交接点、8 个配置位

**素材**：`_tilecov2/cov2.bit` + `cov2.pips`（本地已有），net `n_123`（6 位加法器的一条进位/数据网）。

### 199.1 net n_123 的完整路径（工具报告，非推断）

| 序 | tile | PIP |
|---|---|---|
| 1 | `INT_R_X135Y300` | `LOGIC_OUTS12 ->> NW6BEG0` |
| 2 | `INT_R_X133Y303` | `NW6END_S0_0 ->> SW6BEG3` |
| 3 | `INT_R_X131Y299` | `SW6END3 ->> LH0` |
| 4 | `INT_R_X119Y299` | `LH0 <<->> LH12` |
| 5 | `INT_R_X107Y299` | `LH0 <<->> LH12` |
| 6 | `INT_R_X95Y299` | `LH0 <<->> LH12` |
| 7 | `INT_R_X83Y299` | `LH0 <<->> LH12` |
| 8 | `INT_R_X71Y299` | `LH12 ->> WW4BEG0` |
| 9 | `INT_R_X67Y299` / `X63Y299` | `WW4END0 ->> WW4BEG0`（连续 3 跳） |
| 10 | `INT_R_X59Y299` | `WW4END0 ->> NL1BEG_N3`，同 tile `NL1BEG_N3 ->> NW2BEG3` |
| 11 | `INT_L_X58Y300` | `NW2END3 ->> IMUX_L5` |

### 199.2 长线段：12 个 tile 一跳，共 60 个 tile

`LH12` 在 x = 131 → 119 → 107 → 95 → 83 → 71，**每跳 12 个 tile**，总计跨 **60 个 tile**。
名字里的 `12` 就是物理跨度；同样地 `LV18` 是竖直 18、`LH0/LV0` 是 1 跳短段（见 net `n_0`：`LV18` 从 Y344 到 Y128，间距 18）。

### 199.3 每个交接点只占 2 位，中间 tile 全 0（实测）

Feature = `(family=LH0, src_wire=LH12)`，`law_cells` 给 2 格：`(frame_off=1, parity=1, bit=22)` 与 `(frame_off=1, parity=1, bit=24)`
⇒ 每交接点 = 该 tile 块基址 **+1 帧、word 100 的第 22/24 位**（word = `2*(299%50)+1+1 = 100`）。

实测（在 `cov2.bit` 上按 `tile_blocks.base_frame + frame_off` 验证）：

| tile | 表基址 | 实测命中帧 | 该 feature 两位 |
|---|---|---|---|
| `INT_R_X119Y299` | 19782 | **19782** | 11 |
| `INT_R_X107Y299` | 19374 | **19374** | 11 |
| `INT_R_X95Y299` | 18938 | **18974** | 11 |
| `INT_R_X83Y299` | 18566 | **18566** | 11 |
| `INT_R_X131Y299`（起点） | 20190 | 无 | 00（此处用 `(LH0, SW6END3)`） |
| `INT_R_X71Y299`（终点） | 18164 | 无 | 00（此处用 `(WW4BEG0, LH12)`） |
| 中间 `X125/113/101/89/77` | — | 扫 ±60 帧全 0 | 00 |

也就是说：**60 个 tile 的跨距，只用 4 个交接点 × 2 位 = 8 个配置位承载；中间 11 个 tile 一个位都不占。**

### 199.4 由此得到的两条结论

1. **长线的“配置”只发生在交接点**：一条物理长线穿过 12 个 tile，中途不产生任何配置位；要改变它接到哪根线上，只在交接 tile 改 2 位。这解释了为什么长线族“每源恰好 2 格”与 BEG 同构。
2. **双向 PIP 必须靠位流定向**：`.pips` 把连接写成 `LH0 <<->> LH12`，方向不定；实测只有 `(family=LH0, src=LH12)` 那 2 位被置 1，
   `(family=LH12, src=LH0)` 的另 2 位在该设计里扫全库 0 命中。所以「`<<->>` 不能当有向边用」。

### 199.5 附带发现（待修）

`tile_blocks` 里 `INT_R_X95Y299` 的 `base_frame=18938`，但实测该 tile 的交接位在 **18974**（差 36 = 一个 INT 块的帧数）。
其余 3 个交接点与表基址完全一致 ⇒ `derived_gc` 来源的基址至少有一处 off-by-one-block。
**未核**：是单点错还是整列错，需对 X95 整列做一次 `int_base_solve`。

### 199.6 与缺口的关系

这 82 条长线“无公式”，缺的正是**交接点表**：哪根长线接哪根（26 条去重续接边已提取），以及 4 个基置换级别的排列规律。
结构已经很规整（每 12/18 tile 一交接、2 位 one-hot），照 BEG 的二分图模型律化的可行性高。

图：`v7re/steps/figs_law/law_4_longline.png`（61 个 tile 全画，橙=交接点 2 位，蓝=0 位）。

## 199.7 全语料挖矿：长线交接只有 12 种边，步长恒定

扫本地全部 **309 份 `.pips`**（`**/*.pips`），对每个 net 取相邻两个长线 PIP，记录 `(dst_上一段, 中间段, 下一段)` 与步长向量：

```
continuation edges: 12
  (NN6END0, LV_L0, LV_L18)  25     (LV_L0, LV_L18, NN6BEG3)  22
  (LV0,     LV18,  NN6BEG3)  18     (NN6END0, LV0, LV18)      14
  (NW6END0, LV_L0, LV_L18)  14     (NW6END0, LV0, LV18)       8
  (LV_L0, LV_L18, NE6BEG3)   7     (LV_L0, LV_L18, LH12)      5
  (LV_L0, LV_L18, LH0)       5     (LV0, LV18, LH0)           3
  (LV0, LV18, NW6BEG3)       3     (LV_L0, LV_L18, NW6BEG3)   1
step vectors: [((0, 18), 125)]      # 只出现一种步长：竖直 +18
```

**结论**：长线一跳不是“一根线单独跨 N tile”，而是 **「1 格入口段（`LV0`）+ 18 格主段（`LV18`）」交替**；
横向同理是「`LH0`（1 格）+ `LH12`（12 格）」。这也解释了为什么交接点恰好每 12/18 个 tile 出现一次。
整数命名（0/12/18）就是段长，不是任意编号。

横向步长在本批语料里没有出现 `(12,0)`，因为 `n_123` 来自 `cov2`（另一份），说明横向交接确实存在、只是语料里稀少 —— **未核**横向是否同样只有有限种边。

## 200. 全语料核对：长线交接律成立，但 `tile_blocks` 基址 25% 是错的

2026-11-16。用户 m17954「需要」要求做两步零机时核对：(1) 全语料挖长线交接边；(2) 用 64 个实测 tap 验证「每交接点 2 位、段长 12/18」。

### 200.1 第一步：交接边挖矿（309 份 `.pips`，292 份有 `.bit`）
- 竖直交接 hops **125 次**、distinct 边 **12 种**；步长向量**只有一种** `((0,18),125)`。
- 结论：长线一跳 = 「1 格入口段（`LV0`）+ 18 格主段（`LV18`）」交替；横向同理 `LH0`(1)+`LH12`(12)。
- 本批语料横向 hops **0**（`LH12` 实例只在 `_tilecov2/cov2`），横向同构仍只有单例证据。

### 200.2 第二步：64 个 tap 核对 → 18 个不符，全部同一列
| 结果 | 数量 | 说明 |
|---|---|---|
| cells 全 1（表基址正确） | 46 | 律成立 |
| cells 全 0 | 18 | **全部** `(LV_L0, NN6END0)`、**全部** `INT_L_X72`、delta 恒 **+36** |
| 无法判定（无 cells/无基址） | 0 | — |

`(LV_L0,NN6END0)` 的 cells = `(frame_off 0, bit 7, parity 0)`、`(0,9,0)`；在 x=72 的所有 tile 上，这两个位都出现在「表基址 +36」处。

### 200.3 用三个独立 BEG feature 交叉确认 x=95 同样错
| tile | feature | 表基址 | at base | at base+36 |
|---|---|---|---|---|
| `INT_R_X95Y165` | `SE6BEG3 ← EE4END3` | 8446 | `[0,0]` | `[1,1]` |
| `INT_R_X95Y20` | `SE2BEG0 ← EE4END0` | 34676 | `[0,0]` | `[1,1]` |
| `INT_R_X95Y225` | `SE6BEG1 ← EE4END1` | 13692 | `[0,0]` | `[1,1]` |

### 200.4 全面测量：`tile_blocks` 有 25.1% 的基址是错的
用 numpy 向量化反解（对每个 tile 把它的全部 feature cells 取交集，唯一候选才算测出），扫 167 份设计（每份都有 `.pips` 与 `.bit`）：

```
designs parsed 167   tiles measured 6674
agree     4994   (74.8%)
disagree  1674   (25.1%)
outlier      6   (|delta| > 1000，解不唯一/退化)
```

delta 分布（measured − derived）：

| delta | 数量 | 恰好等于 |
|---|---|---|
| **+36** | 1,166 | 一个 CLB 块 |
| **−28** | 322 | 一个 INT 块 |
| **−30** | 124 | 一个 CLOCK 块 |
| **−42** | 47 | 一个 UNDETERMINED 块 |
| **−32** | 15 | 一个 BOUNDARY 块 |

**delta 全部等于 ±(相邻块的帧数)** ⇒ 这不是随机误差，而是 `tile_blocks` 的「块在列内的序号」整体偏了一格：派生公式按每列固定块数/固定块大小算 y→块号，而实际列内混排 CLB(36)/INT(28)/CLOCK(30)/BOUNDARY(32)/UNDETERMINED(42) 五种块，序号一错就整列偏移一个邻居块的帧数。

受影响的列（部分）：INT_L 的 8/14/20/26/32/36/42/50/62/66/72/78/84/92/100/106/114/120/124/130/142/148 全是 +36；INT_R 的 69/75/95/103/111/127/139 全 +36，5/11/23/29/39/47/81/89/117/133 是 −28，33 是 −30，121 是 −42，0 是 −32。

### 200.5 已做的处置
- 新表 `v7_law.sqlite:tile_blocks_measured(tile_name, base_frame, votes, delta, status)`，6,674 行；`status ∈ {agree, disagree, outlier}`。
- **不覆盖** `tile_blocks`：保留派生值并标 `delta`，避免把「测量值」与「派生值」混成一个来源；所有按绝对帧下结论的地方一律先查 `tile_blocks_measured`，查不到才回落。
- 副产物：`tile_blocks` 只有 `(tile_name, base_frame, frame_count, source)` 四列，没有 `tile_type/grid_x`，按列统计要现拆名字。

### 200.6 影响面与不变项
- **受影响**：任何「tile → 绝对帧」的结论，例如 T91 时钟 `h00/h08` 的 `23512..23589` 归属（依赖时钟 tile 的基址）、`law_tiles` 的绝对位展示、以及此前 §173 里 258 个唯一基址（那批是用 `int_base_solve` 反解的，属测量值，不受影响）。
- **不受影响**：全部相对位结论（`law_cells` 的 `frame_off` 是块内偏移，与块在哪无关），因此 PIP 复用律、BEG 形状、mux 6×4 网格、行序 S4 生成链、CLB 位级、ECC 签名全部不依赖本 bug。
- **口径**：`verify_all_pip.py` 的 3,634/3,634 与 `repro.py` 的 12 项检查都只用相对坐标，结论不变。

### 200.7 下一步
1. 用 6,674 个测量值反推「y → 列内块序号」的正确规律（列内块序 = 按 frame 升序数第几个块），重建 `tile_blocks` 派生公式并自检到 6,674/6,674。
2. 再对 64 个 tap 复跑，预期 64/64。
3. 然后才做长线律化（82 条 → 若与 BEG 同构，纯律 3,538/3,634 = 97.36%）。

## 201. 第一步完成：正确的基址律 `base = band(y)*5246 + offset(col)`，6,667/6,668

2026-11-16。承 §200。用户 m18010 提示「错误的原因可能是原始数据是从 prjxray 直接移植的」，要求先跑第一步（反推 y→块号的正确规律）。结论：**猜对了**——旧表按 prjxray 那种「每列固定块序列」的假设推导，而真实布局是**按配置带（band）**组织。

### 201.1 反推过程（全部来自实测，不依赖旧表）
1. 把 6,668 个测量值各自落到 `frame_blocks_full` 的块起点上：**6,668/6,668 都能精确落在某个块的 `start_frame`**（一个不差），说明测量值本身是干净的块基址。
2. 每个测量值除 `5246`（`row_frames`，一带的帧数）：同一 `grid_x` 的余数**恒等**（99.99%，6,667/6,668），余数就是该列的 `offset(col)`。
3. 商 `k = base // 5246` 与 `y` 的关系（`INT_L_X32` 全列）：

| `y//50` | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| 实测 band `k` | 6 | 5 | 0 | 1 | 2 | 3 | 4 |

即 **`band(y) = 6 - y//50`（当 `y//50 < 2`）；否则 `band(y) = y//50 - 2`**。物理含义：y=0 在器件底部，底部 2 个带是 k=6、5，往上依次回到 k=0..4。

### 201.2 定律
```
base(tile) = band(y) * 5246 + offset(grid_x)
band(y)   = 6 - (y//50)      若 (y//50) < 2
          = (y//50) - 2      否则
offset(c) = start_frame(col_addr=c, band=k) - k*5246     （全 154 列都有值，取自 frame_blocks_full）
```
- `offset` 对 154 列全部可算，且每列只有一个值（无歧义）。
- 预测 vs 实测：**6,667 / 6,668 命中**（唯一不符的是 §200 里那个 `INT_L_X32Y0`、`col_addr` 解成 31 的退化样本，`status='outlier'` 已排除在统计外）。

### 201.3 为什么旧表错、且 delta 恰好是 ±块大小
旧 `tile_blocks` 把「列内第几个块」当成 `y` 的线性函数（等价于 prjxray tilegrid 的 (col,row) 均匀假设），而真实列内块是**按带（band）排的、每带一个块**，块大小 28/30/32/36/42 不等。序号一旦偏一格，基址就正好差一个**邻居块**的帧数 —— 与 §200.4 观测到的 `+36 / −28 / −30 / −42 / −32` 完全对应。

### 201.4 已落库
- `v7_law.sqlite:tile_blocks_fixed(tile_name, base_frame, band, col_addr, delta_vs_old)`，**53,102 行**（全部 INT_L/INT_R tile）。
- 相对旧表的修正量：不变 37,952；+36 10,150；−28 3,850；−30 450；−32 350；−42 350 ⇒ **共 15,148 个 tile（28.5%）基址被修正**。
- `tile_blocks` 原表保留不动（作为「派生口径」的历史值），新结论一律用 `tile_blocks_fixed`。

### 201.5 复验：64 个长线 tap
| 基址来源 | 通过 |
|---|---|
| 旧 `tile_blocks` | 46/64 |
| 新 `tile_blocks_fixed` | **64/64** |

⇒ 「每交接点 2 位」的律本身一直是对的，先前 18 个不符全部由基址表错误造成。

### 201.6 适用范围（必须写清）
- 实测覆盖 `grid_x = 0..151`（152 列，左半器件）；**`grid_x ≥ 152` 未验证**（语料里没有高 x 的设计）。
- `grid_x → col_addr` 对 INT tile 在左半区是**恒等**（x=32 ↔ col_addr=32、x=72 ↔ 72、x=95 ↔ 95）；但这对 **CLB 不成立**（`clb_blocks` 的 `grid_col=5` 落在 `col_addr=1`），说明不同 tile 类型的列编号规则不同，不能互推。
- 该定律是**经验律**：它把 6,668 个测量值压成「1 个分段函数 + 154 个列偏移」，但没有解释为什么列偏移是这些值（列偏移可能等价于 `clb_col`/块序的另一种写法）。

### 201.7 下一步
1. 用远端在高 `grid_x` 放置的 2–3 个设计验证右半区（约 3 次构建）。
2. 长线律化：82 条 feature，若与 BEG 同构则纯律 3,538/3,634 = 97.36%。
3. 把 `tile_blocks_fixed` 接进 `int_base_solve.py` / `h00-h08` 那类按绝对帧对位的脚本。

## 202. 基址律的右端验证：name-index 153 + y=349 全覆盖，433/433

2026-11-16。§201 留的边界是「`grid_x ≥ 152` 未验证」。实测后发现那句**坐标搞错了**：tile 名里的 `_X<n>` 是**列位序号 0..153**，而 `grid_x` 是另一套 0..411 的坐标（例如 `INT_R_X133Y97` 的 `grid_x=342`）。所以真正要补的是**列位序号 152/153** 与**高 y**，不是 `grid_x`。

### 202.1 三个远端设计（右端列位）
在远端 Vivado 2017.2 上建三个最小设计（4×LUT6 + 4×FDRE，`DONT_TOUCH`，逐颗 `LOC`+`BEL` 钉死），走完整 synth→place→route→bitstream，导出 `.pips`：

| 设计 | 钉住的 SLICE | 产出的 INT tile 列位 |
|---|---|---|
| `r1` | `SLICE_X218Y6/56/106/156` | 121..153 |
| `r2` | `SLICE_X218Y20/75/130/180` | 121..151 |
| `r3` | `SLICE_X221Y30/90/140/200` | 120..153 |

- 中间踩的两个坑：① `set_property ... [get_cells L1]` 写在 `write_bitstream` **之后** ⇒ 约束完全不生效（第一次跑出来 tile 全在 x≈31）；② `SLICE_X210Y110` **不是合法 site**（该列只有 300 个 slice，不是 350），`[Common 17-69] 'SLICE_X210Y110' is not a valid site name`。
- 另需 `set_property SEVERITY {Warning} [get_drc_checks NSTD-1]` / `UCIO-1`，否则 `write_bitstream` 被 DRC 拦下（`ERROR: [Vivado 12-1345]`）。
- 传脚本的坑：PowerShell 管道会给 bash 塞 `\r`（`$'\r': command not found`），改成 `scp` 传 LF 文件再 `bash /mnt/c/...` 即可；`ssh` 里带引号的 `bash -c` 还会被 cmd.exe 抢先解释，同样避开。

### 202.2 结果
| 文件 | INT tile 数 | 列位范围 | 律命中 | 不符 | 歧义 |
|---|---|---|---|---|---|
| `r1` | 187 | 121..153 | 116 | **0** | 67 |
| `r2` | 220 | 121..151 | 165 | **0** | 53 |
| `r3` | 232 | 120..153 | 152 | **0** | 80 |

合计 **命中 433 / 不符 0**；197 个「歧义」全是只带 BEG feature（每族只有 2 格）的 tile，反解不唯一，属测量限制不是律错。

### 202.3 合并后的覆盖声明（修正 §201.6）
- 列位序号：旧语料 0..151 + 本次 120..153 ⇒ **0..153 全覆盖**（tile 名索引的全部取值）。
- y：旧语料实测已覆盖 **0..349 全部**（7 个配置带全覆盖）。
- 因此 §201 的「右半器件未验证」**作废**；基址律在「列位 0..153 × y 0..349」这个完整命名域内已验证：**7,100 / 7,101**（6,667 + 433）。
- 仍未覆盖的是**没有 tile 名的区域**：`FAR_BLOCK_1` 的 13,440 帧（105 块 × 128 帧，§1.12 已证恒 0），以及 `grid_x` 里那些非 INT 列位。

## 203. CRC 完全解出：线性映射 + 两段区间 + 设备常量 S（2026-11-16）

§197 只拿到了「37→32 的线性矩阵」和「是 CRC-32C」，仍说不清**位流里到底校验哪些 word、初值是多少**。本节把这件事做完，结果可**逐位复现任何 7 系列位流的 CRC**，并可用于**修复被手工改过的位流**。

### 203.1 算法本体（4 参数，Ghidra 漏了第 4 个）

`crc32_37` @`0x80b0` 实际签名是 4 参数：

```c
crc32_37(void *this, char *state32, char *data32, char *sel5)
```

- 汇编 `0x80f5: cmp byte ptr [rcx], 0x30` 证明第 4 个参数是 5 字符选择串；Ghidra 只解出 3 个参数且截断了函数体。
- 语义（Unicorn 提取，`v7work/vivado_re/crc32_37_emu.py`）：

  ```
  st' = L(st XOR word)        # state_cols[k] == data_cols[k]，逐位相等
  ```

- `f(0,0,0) = 0`，纯线性无常数项；仿射性实测通过。
- `sel_cols = [0x1EDC6F41, 0x3DB8DE82, 0x7B71BD04, 0xF6E37A08, 0xF31A9B51]` —— 第 0 列正是 **CRC-32C 多项式本体 0x1EDC6F41**（非反射形式）。

### 203.2 关键方法：差分消元

绝对对齐一直失败（`crc_align*.py` 全灭），因为 mask 串、COR/CTL 常量、初值都是未知量。改用**差分**后一次命中：

取同一 base 设计的多个位流（`_crcb/b00..b64.bit`，65 个，字节数完全相同，只差 FDRI 里的几个数据 word 和 CRC 包本身），则

```
delta(CRC 包) = XOR_{变化的 word w}  L^k(delta_w)
k = 在 w 之后才被喂入的 word 数
```

所有未知常量在差分中抵消。实测 9 对可用差分，**唯一解**：

- 矩阵用 `step03_pip/crc_matrix.json` 的 `matrix[:32]`（**列号 = word 的 bit 号，不需要位反转**）
- 最后一个被喂的 word 在 FDRI 数据结束之后 **C = 1** 个 word

`diff_probe.py` 枚举了 MATS × 位序 × C∈[0,96)，只有这一种命中。

### 203.3 绝对模型：常量偏移 S

线性 + `f(0)=0` ⇒ `CRC = model(words) XOR S`，S 对同一器件恒定。实测 20 个位流 S1 完全相同：

```
range1: words[12 .. crc1_index-1]           S1 = 0x06F99760
CRC1 = model(range1) XOR 0x06F99760
```

`range1` 从 **payload word 12**（sync 之后）开始，到 **CRC 包的 header word 之前一个 word** 结束，初值 0。

第二段从 `crc1_index+2` 起到 `crc2_index-1`，S2 = `0x5F9F7992`（b00 实测；该值依赖器件与 FAR/CTL 状态，`fix_crc.py` 从参考位流现算而非硬编码）。全部 65 个位流的 CRC2 都是 `0xE3AD7EA5`。

### 203.4 验证结果

| 语料 | 数量 | 结果 |
|---|---|---|
| `_crcb/b00..b64` 两段 | 65 | **OK OK 全部** |
| 无关设计（`_c0`/`_c1`/`_c3`/`_c4`/`_c5`/`_2020_*`/`_b1` ...） | 15+ | **全部 OK** |
| `_c0_to_c3.bit`（我早先手工改帧、未重算 CRC） | 1 | **FAIL**（符合预期，检出篡改） |

修复测试：`fix_crc.py _c0_to_c3.bit _c3.bit out.bit` → crc1 `0xD11354F1 → 0x456E332A`，重算后再次预测 **OK**。

### 203.5 位流容器格式（修正）

`_c0.bit` = 20,273,538 B：

- 13 B magic `00090ff00ff00ff00ff000000161`
- `0x61` len=37 `top;UserID=0XFFFFFFFF;Version=2017.2` @13
- `0x62` len=15 `7vx485tffg1761` @53（**器件 Virtex-7 485T FFG1761**）
- `0x63` len=11 日期 @71、`0x64` len=9 时间 @85
- `0x65` **长度栏是 4 字节**（不是 2）→ `L = int.from_bytes(d[98:102]) = 20,273,436`，**payload 从 offset 102 开始，102+L = 20,273,538 = 文件全长**

payload 内：48 B `0xFF` 填充，sync `aa995566` 在 word 12；word 数组 5,068,359 个；type-1/type-2 packet 解析**恰好消费完全部 word**（559 个 packet），证明 packet 模型正确。

### 203.6 代码

- `v7work/vivado_re/crc32_37_emu.py`：Unicorn 提取 37 列矩阵（注意每次调用要 `uc.mem_write(STACK,0)` 清栈，否则第二次 `UC_ERR_READ_UNMAPPED`）
- `diff_probe.py`：差分消元，产出唯一解
- `abs_crc_fast.py`：字节表加速（4×256），验证 S 恒定
- `predict_crc.py`：**给定任意 .bit 预测/校验 CRC**
- `fix_crc.py`：**改帧后重算并写回两个 CRC 包**