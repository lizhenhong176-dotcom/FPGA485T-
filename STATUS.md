# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

更新：2026-10-25

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
| 远端机器 | `172.17.70.41`（DHCP，会变）；用户 `s.tschai`；私钥 `C:\Users\i\.ssh\v7remote` |
| 远端 WSL | Ubuntu 20.04；Vivado 2017.2 `/opt/lzh/Xilinx/Vivado/2017.2`；venv `/opt/lzh/venv` |
| 远端实验 | `/opt/lzh/step03/{pip1,pip2,reuse,reuse3,reuse5,reuse6,tilepipe}` |
| 仓库 | https://github.com/lizhenhong176-dotcom/FPGA485T-.git（origin 已配） |

---

## 2. 远端环境用法

```bash
"C:\Program Files\WSL\wsl.exe" -d Ubuntu -u root -- bash -lc "<命令>"   # System32 下的 wsl.exe 是 stub

export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source x.tcl
```

坑：

- SSH 默认 shell 是 `cmd.exe`，嵌套引号会被吃 → 写 `.sh`（**LF**）→ scp → `bash /mnt/c/Users/S.tschai/x.sh`。
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

`tilepipe` **已于 17:53 完成**（900 个 `v_*.bit` + `tilepipe.json`），结果已入库并做完端到端验证。
当前远端没有长任务在跑（Vivado 进程为 0）。

下一步实验（尚未开始）：BEL 级位测量，见 §5 第 2 条。

---

## 5. 待办

1. ~~**第 6 层：mux 内「物理输入序号」**~~ **已解（2026-10-25）**：见 §3 与 `step03_pip/IMUX_INDEX_SOLVED.md`；编码规则 = 行 one-hot(`word 16..21`) × 列四码(`word 22..25`)，864/864 实测对齐。INT_R 已完成硅片对照（IMUX6，24/24）。
1b. **ECC 全表**：现在只拟合了 IMUX 字段用到的位置；要写任意帧（LUT INIT、BRAM/DSP 配置）需要把 `ecc_table.json` 扩到全部 1600 位。
2. **BEL 级位**（下一个主战场）：`reuse4` 已铺好 BEL 级 DCP 的路（`synth_design -top top`）。待测 F7/F8、CE/SR/CLK 选择 mux、CARRY4、BRAM/DSP 配置位。
3. 批量扩展：tilepipe 流程推到更多 tile（跨列 / 跨 clock region），验证公式在两个 region 的行为。
4. STEP04：frame/bit 数据库生成器（含 `site_frames` 表）。

---

## 6. 常用命令

```bash
# 远端跑一个 mux 的 25 源实验
cd /opt/lzh/step03/reuse6 && bash /mnt/c/Users/S.tschai/p6_run.sh

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
