# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

更新：2026-10-27（远端连接信息见 [REMOTE.md](REMOTE.md)）

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

最近一轮（2026-10-27）：**PIP 复用规则收尾 + 远端重连**。
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
5. **补齐 12 个未测 IMUX / 侧**（`IMUX_L22/28/29/31/32/35/38/40/43/44/45/47`）：
   假设它们属 `CLBLM`(SLICEM) 专属输入，基座建在 `CLBLL_L`(SLICEL) 上够不着。
   验证办法：把基座 LUT 放到 `SLICE_X12`（→ `CLBLM_L_X8`）再跑一遍 tilepipe。
6. **非 IMUX 家族的多源覆盖**：现在每族只测了 1 个源（124/2,484 = 5%），
   域内编码唯一性只由 prjxray 表保证。每族再测 3..5 个源即可，成本同 famdiff 那轮。
7. **长线家族的块归属**（唯一真正的未解项）：`SWEEP_DIAGNOSIS.md`。
   需要「只保留一段长线」的对照实验，`one/` 那批逐条删除的位流因位集重叠已失效。

---

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
