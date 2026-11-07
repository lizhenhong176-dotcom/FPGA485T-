# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

更新：2026-11-06（最新一轮：T21，见 §52）

目标：XC7VX485T-2FFG1761（VC707）比特流逆向。
主线：**RapidWright 拓扑 → PIP→bit 差分 → frame/bit 数据库 → PIP 复用规律**。

> 本文件是正常 UTF-8。2026-10-25 曾因 PowerShell 5.1 以 ANSI 读取再写回出现一次双重编码，已重写修复；
> 之后确认过：用 `Get-Content` 直接读会显示乱码，那是控制台按 GBK 解码造成的**显示**问题，文件本身没坏。
> **编辑中文文档仍请用 `[IO.File]::WriteAllText(..., UTF8)` 或带 `-Encoding utf8` 的方式。**

---

## 1. 位置

| 内容 | 位置 |
|---|---|
| 项目代码 | `E:\DEEPSEEK\FPGA比特流逆向`（`v7re/`、`step03_pip/`、`tools/`） |
| 路由模型 | `E:\v7work\_curated_20261021\routing\v7_routing.db`（1.2 GB） |
| 模型库 | `E:\v7work\model\v7_model.sqlite`（`pip_bits` 2,652 行 = 2,616 路由位 + 36 默认源；`imux_codes` 2,304 行；`bit_map` 28 行） |
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

## 5. 跨类型（INT_L vs INT_R）—— 已完成（2026-10-25）

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

## 6. PIP 复用规律（可执行形式，2026-10-25）

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


## 35. T8 —— 位流改写器闭环（2026-11-04）

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


## 52. T21 —— 四个 LUT 的 INIT 映射同构 + 行不变性（2026-11-06，verified）

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
