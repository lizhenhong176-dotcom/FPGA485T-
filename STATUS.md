# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

更新：2026-11-08（最新：§108 family 名字核对、§109 family 定义澄清〔全文 `v7re/steps/family_definition.md`〕）

目标：XC7VX485T-2FFG1761（VC707）比特流逆向。
主线（2026-11-08 起，用户口径）：**PIP 复用分析** —— 复用发生在哪几层、复用规律是什么、这套规律能否反过来生成/判定位库（见 §97）。
前序（RapidWright 拓扑 → PIP→bit 差分 → frame/bit 数据库）已完成，作为支撑；
**旁支**（不在主线）：ECC 与帧地址耦合、`site_frames` 补全、跨 tile 类型位库迁移、篡改定位器上板。

> 本文件是正常 UTF-8。2026-10-25 曾因 PowerShell 5.1 以 ANSI 读取再写回出现一次双重编码，已重写修复；
> 之后确认过：用 `Get-Content` 直接读会显示乱码，那是控制台按 GBK 解码造成的**显示**问题，文件本身没坏。
> **编辑中文文档仍请用 `[IO.File]::WriteAllText(..., UTF8)` 或带 `-Encoding utf8` 的方式。**

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


## 81. HCLK_CMT：PLL 源编码解出（2026-11-08）

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


## 82. PLL6/PLL7 补测失败（2026-11-08）

尝试在 `PLLE2_ADV_X1Y6` 上取样本：三个构建成功，但**没有产生任何 `MUX_CLK_PLL*` PIP**，
与 p0 的差异 163–164 格且跨多帧。

原因：`X0Y6` 与 `X1Y6` 不在同一 CMT 列；X1 列走 `CMT_TOP_L_UPPER_T_X305Y356` 那一族，
其输出落在另一个 HCLK_CMT tile 与另一批帧上，不可比。

**结论**：每 CMT 列只有一个 PLL 站点，`PLL0..5` 的 6 个 CLKOUT 已测完；
`PLL6/PLL7` 无法用现有构造产生。因此 PLL 公式标注为**部分验证（6/8）**，不当作全组定律。


## 83. HCLK_CMT 源可达性（2026-11-08）

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


## 84. MMCM 14 源补测受阻（2026-11-08）

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


## 85. 「为什么是 6×4」—— 6 类 × 4 槽（2026-11-08）

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


## 86. LOGIC/BOUNCE 行顺序的可预测规则（2026-11-08）

```
row20 放 LOGIC ⟺ (IMUX 编号 // 8) 为偶数，或 family ∈ BYP_ALT
```
48 个 IMUX + 16 个 ALT 族全部命中，0 例外（IMUX 按 8 个一段交替；BYP_ALT 全 L、FAN_ALT 全 B）。

但「16 条方向线怎么分 4 组」仍是 per-mux：48 个 IMUX 族给出 **32 种不同分组**。

**界线**：类别层面（ROUTE/LOGIC/BOUNCE + 行顺序）可预测；实例层面（哪条线进哪行）是布线图事实。

文档：`v7re/steps/T52_WHY_6X4.md` §8–§9。

## 87. 路由级 PIP 表大规模实证：698/698 全通过（2026-11-08）

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


## 87. 位对/parity 的闭式公式（2026-11-08）

```
g = i // 16 ;  h = (i // 8) % 2
minbit = 8 * (i % 4) + 2 * g + 2 * h
parity = 1 if (i % 8) >= 4 else 0
```
48 个 IMUX **全部命中，0 例外**。加上 §86 的行顺序规则，族级结构里
「位对 / parity / 行类别 / LOGIC-BOUNCE 顺序」四项已可纯计算；
只有「源→槽位」和「方向线 4 分组」是 per-mux 数据。

## 88. PIP 覆盖面盘点（回答「是不是只做了 CLB 的 PIP」）

**不是 CLB，是 INT（布线开关盒）的 PIP。**

全器件 115 个含 PIP 的 tile type、共 **35,126 条 PIP**：

| 范围 | PIP 数 | 占比 |
|---|---|---|
| INT_L + INT_R（已做，172 族 × 2） | 7,474 | **21.3%** |
| 其余 113 个 tile type（未做） | 27,652 | 78.7% |

CLB 自身也有 PIP（`CLBLL_L/R` 各 146、`CLBLM_L/R` 各 151，全器件约 1,200 条），**尚未分析**。
单 tile 未做的最大块：`CLK_HROW_BOT/TOP_R` 各 2,840、`PCIE_BOT` 各 1,736、
`HCLK_CMT` 各 982、`BRAM_L/R` 各 974、`DSP_L/R` 各 794、`GTX_CHANNEL_*` 各 628、`LIOI/RIOI` 各 467。

## 88. 反向检验：INT PIP 表精度 100%（2026-11-08）

第二波 32 设计（含 LUT→LUT 内部网、去 PACKAGE_PIN），每设计 8 tile 全 PIP 落表 + Tcl driver map：

```
truth 372  TP 366  AMBIG 0  WRONG 0  FN 6  FP 0
```

- **假阳性 0**：~35 万次 (tile×家族) 判定无一"未被使用却匹配"。
- **多解 0**：同 tile 多家族同时激活时仍唯一回推 src。
- 6 条 FN 全为 `BYP_BOUNCE{0,4,1}←BYP_ALT{0,4,1}` —— `all_cells.json` 中无此家族，属 CLB tile 旁路 mux，**范围外**（同第一波 `FAN_BOUNCE*`）。
- 结论：INT tile 作用域内召回 100%、精度 100%。

文档：`step03_pip/S16_PIP_HARVEST_VALIDATE.md` 附录 B；脚本 `E:\v7work\reverse_check.py`。


## 89. 槽位表从 48 张压到 16 张 + 2 个常数置换（2026-11-08）

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

## 90. 方向线 4 分组：仍未导出

例 `IMUX_L0` 的 4 组方向线：
```
r0 {NE2END0, NN2END0, NR1END0, SL1END0}   r1 {SE2END0, EE2END0, SR1END_N3_3, NL1END0}
r2 {NW2END0, WW2END_N0_3, ER1END_N3_3, WL1END_N1_3}   r3 {SW2END_N0_3, SS2END_N0_3, WR1END0, EL1END0}
```
`IMUX_L24` 同源集合但分组不同（`r0 {WW2, NW2, SL1, NR1}`）→ 分组随族变，属 per-mux。
**补记（同日）**：6 条 FN 经查是 `always` ppips（`ppips_int_{l,r}.db` 各 108 行全为 always），`BYP_BOUNCEk←BYP_ALTk`/`FAN_BOUNCEk←FAN_ALTk` 共 16 条**不占配置位**。修正召回口径：truth 372 = TP 366 + PPIP 6 → **召回 100%、精度 100%**。旁路结构为三段串联（BYP_ALTk mux → BYP_BOUNCEk(always) → IMUX），解码器应把这 16 条当零成本通路预置。见 S16 附录 B.5/B.6。


## 91. PIP 地址编码规律：列 = 线长类别（768/768 无例外）

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


## 92. 方向类 → 列：48/48 可预测（2026-11-08）

全器件只有 **2 种**「列 → 方向类」签名，按 8 段交替：

```
(i//8) 偶数 → {1:对角, 2:直角, 7:R, 11:L}
(i//8) 奇数 → {1:直角, 2:对角, 7:L, 11:R}
```

再加上此前的：位对/parity 闭式（48/48）、线长↔列（768/768）、LOGIC/BOUNCE 行序（64/64），
**现在只剩「类内 4 条线谁在哪一行」是 per-mux**（DIAG/ORTH 各 8 种、R/L 各 24 种）。

文档：`v7re/steps/T53_PIP_ADDRESS_LAW.md` §7–§9。


## 93. 类内行序按段变化：否（负结果）+ 编码律定稿

按 8 段、按半段分别检验，段内仍有 2–4 种行序变体 → **类内行序的最小变化单位是族本身**，
不再由任何段号决定，属布线邻接事实。

编码律定稿（`v7re/steps/T53_PIP_ADDRESS_LAW.md` §11）：
class(S) 由名字判定 → 列由 (i//8) 奇偶决定（48/48）→ 行由类内成员序（per-family）
→ 位对/parity 闭式（48/48）→ 行帧 16+row / 列帧 col 码 / 行 18,19 用孪生位。

可计算：类判定、列、位对、parity、帧/字映射。不可计算：类内 4 条线谁在哪一行。


## 94. 编码律定稿文档（2026-11-08，收尾）

`v7re/steps/PIP_ADDRESS_ENCODING_LAW.md`（v1.0）：

- 5 条规则（方向类判定 / 列由 (i//8) 奇偶决定 / 列码=线长类别 / 位对闭式 / 位分配）；
- 「复用 = 行列寻址」的解释与两条推论（2 格歧义、4 格唯一）；
- 验证方法五条纪律 + 8 项证据链（含样本量）；
- 边界：类内成员序不可导出，等价于 tileconn（384 条）；
- 与 prjxray 的对比（1,536 条 → 384 条 + 5 公式）；
- 复现脚本清单。

编码规律这条线**收尾**。


## 95. 类内行序只有 8 种（4 块类 × 2 奇偶）

按行序序列分组，48 个族严格按 **i 的奇偶**二分，且块 1≡块 4、块 2≡块 3
→ **8 种行序**，不是 48 种（此前说的 8/24 种是"类"粒度，实际是块类×奇偶）。

用 8 个代表族预测整表：20/48 完全命中，块 3 全错（块类映射未定对），
其余多错 1 条。**结构成立，但整表尚未可算。**

文档：`v7re/steps/T53_PIP_ADDRESS_LAW.md` §12。


## 96. 更正：行映射 36 种（不是 8 种）；列码 744/744 零例外

- §12「8 种行序」只对 DIAG 单类成立；四类合并后按行映射分组 = **36 组 / 48 族**
  （仅 `i%8 ∈ {0,3}` 的族与 `i+4` 共用，其余各自独立）。该结论作废。
- 列码用 `(i//8)` 奇偶预测：**744/744 命中，零例外**——列完全可算。
- RapidWright 几何路线不可行：`pip_defs` 无几何字段（第 3 字段全 0），
  `Wire`/`PIP` 无坐标 API。

**最终边界：列/位对/parity/帧映射可算，行序是每族数据（36 种）。**

## 89. BRAM/DSP 并行采集 + BRAM 配置块实测（2026-11-08）

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


## 97. 主文档更新到 v1.1（2026-11-08）

`v7re/steps/PIP_ADDRESS_ENCODING_LAW.md`：
- 边界章节重写为「36 种行映射」（更正 v1.0 的「8 种」）；
- 列码补全量复核 744/744；
- 新增「几何路线已排除」（pip_defs 无几何字段、RapidWright 无坐标 API）；
- 数据量对比改诚实版：1,536 条 → 576 条（约 2.7×），不再声称 384；
- 摘要第 3 条补反向结论；
- 文末加修订记录 v1.0 → v1.1。


## 98. 独立复算（T51 子任务）与主结论一致 + 一条新预测（2026-11-08）

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


## 99. LV_L0「补齐 2 条」判定：不需要跑，预测是假设的产物（2026-11-08）

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


## 100. INIT 表跨 tile 类型验证（2026-11-08）

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


## 101. 对象澄清：主线是 PIP 开关盒，INIT 是另一回事（2026-11-08）

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


## 102. CLBLL_L 的 LUT INIT 布局独立实测（2026-11-08）

T54 用 CLBLM 表预测 CLBLL 失败（13 缺/13 多）→ 本轮用 CLBLL 自己的 64 个单最小项构建重建。

- `SLICE_X8Y20`（CLBLL_L，col16，块基址 **31680**，`SLICEL.A6LUT`）；
- 64 个构建各只多 1 格、64 格互异；全在 **word 40**、帧 **31712–31715**（相对 **32..35**）、位 0..15；
- 验收：`INIT=0xDEADBEEFCAFEBABE` → 实测 46 位 / 预测 46 位，**missing 0 / extra 0**。

**与 CLBLM 对比**：相对帧 32..35、word 40、位域 0..15 **完全相同**；只有「索引 → (帧,位)」的排列不同。
⇒ CLB 的 INIT 布局 = **通用骨架 + per-tile-type 排列**，与 PIP 的「列码可算、行序固化」同形态。

产物：`v7re/steps/T57_CLBLL_INIT_LAYOUT.md`、`v7re/steps/clb_init_clbll_x8y20_a6lut.json`。


## 103. 计划 r1 收敛：T2b 由离线数据直接回答（2026-11-08）

计划的 T2b 问题是「同类型 tile 的 PIP 位坐标可否直接复用」。这个问题**已有实测答案**，不需要新构建：

- `verify_all_pip.py --tile-type INT_L`：**3,634 / 3,634 feature 全部精确命中，0 不符**。
  该脚本对每个 feature 用「族内公式算出的 (frame_off, parity, bit)」去核 `law_cells`，
  而 `law_cells` 是全器件 62,625 个 tile 的位集合 —— 即**同一 family 在不同 tile 里用同一组相对坐标**。
- `fasm2bit --decode _full8.bit` 一次解出 **191 条 PIP，横跨 76 个 INT tile（INT_L 70 + INT_R 6）**（列 8/10/12/14/16/24/26/30/32，行 6/8/10/12/16/20），
  且 FASM → 位流往返**逐字节幂等**（sha256 不变）。

结论：**同类型 tile 的 PIP 位坐标 = 块基址 + 族内相对坐标，可直接复用**；
不可复用的只有「族内行序」（36 种，per-family 固化）。


## 104. 计划 r2 收口（2026-11-08）

计划 wp-eb065939（同类 tile / PIP 开关盒）重规划 r2：T5、T6 因上游取消而撤销，其目标已由主 Agent 直接完成。
最终 3 项 done（T1 对象判定、T2b 同类型 tile 可移植性、T3 脚本盘点）。

本轮新增的两条实质结论：
1. **CLBLL_L 的 INIT 布局**：64 格全在 word 40、帧相对 **32..35**、位域 0..15，
   与 CLBLM **骨架相同、排列不同**；用 `0xDEADBEEFCAFEBABE` 验收 46/46（missing 0 / extra 0）。
2. **同类 tile 的 PIP 相对坐标可复用**：31 个跨 tile 组合 / 220 格反例 0；
   `_full8.bit` 一次解出 191 条 PIP 横跨 76 tile，与 Vivado 真值 190 命中 / 误判 0 / 漏 8（8 条为零位伪 PIP）。

统一结论：**地址 = 块基址 + 族/类型内相对坐标；不可复用的只有 per-family 行序与 per-tile-type 排列。**

## 105. 「两个一样的」指代解析：三条互斥候选（2026-11-08）

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


## 114. y24/y25/y26 实验：+1 位移确认正确；残差归因改为 BEG 长线层（2026-11-09）

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

## 115. S29 半带边界探针：残差不是字位移伪影（2026-11-09）

问题（承 §113）：高半区 20 个残差位是否来自 `wof` 的 +1 位移边界（y%50=24 vs 25）。

设计：`yh24`（`SLICE_X10Y24`，wof=48）/ `yh25`（`SLICE_X10Y25`，wof=51），LUT6 INIT 相同、输出都钉 `PACKAGE_PIN AF24`（第一次未钉引脚，两版 IOB 落点不同 → 898 格全片噪声，作废）。

结果（994 格 / 113 帧）：全部可被 `clb_blocks` 解释，**offset 分布 2..8/11..13/15/17..19/22..25/32..35/38，其中 `off∈{0,1} 且 bit≥30` 的格数 = 0**。
⇒ 边界一对设计**不产生**残差型位；`wof` 的 +1 位移本身不引入不可解释位。

与 §113 的对照：残差行 `y%50 ∈ {29,33,42,45,46,49}`，不是边界行 25；且残差全是 `parity=0`，而 `law_cells` 中对应族 `(0,31)` 只有 `parity=1`（LH12）。
新判断：残差是**高半区"LH12 类长线标记"的 parity=0 副本**（同一族的第二字），不是位移伪影 —— 与"长线经过置位"无关，也与 word 跳变无关。

覆盖影响：0.031%（22/64,326 位），不影响任何 mux 解码；列为"未归属族"而非"错位"。

产物：`/opt/lzh/step07/br6/{yh24,yh25}.bit`、`dif.py`、`ydiff.json`（994 格）。


## 117. 尾部 CRC 被学习出来（2026-11-09）

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
