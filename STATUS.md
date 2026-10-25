# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

更新：2026-10-25

目标：XC7VX485T-2FFG1761（VC707）比特流逆向。
主线：**RapidWright 拓扑 → PIP→bit 差分 → frame/bit 数据库 → PIP 复用规律**。

> 本文档 2026-10-25 重建过一次：此前被 PowerShell 5.1 以 ANSI 读取再以 UTF-8 写回，造成双重编码损坏。
> **编辑中文文档请用 `[IO.File]::ReadAllText/WriteAllText(..., UTF8)`，不要用 `Get-Content | Set-Content`。**

---

## 1. 位置

| 内容 | 位置 |
|---|---|
| 项目代码 | `E:\DEEPSEEK\FPGA比特流逆向`（`v7re/`、`step03_pip/`、`tools/`） |
| 路由模型 | `E:\v7work\_curated_20261021\routing\v7_routing.db`（1.2 GB） |
| 模型库 | `E:\v7work\model\v7_model.sqlite`（`pip_bits` / `bit_map` 各 28 行） |
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

**其他**：改 DCP 里的 site 内 PIP 不生效（bitgen 从网表+布局重推站点路由）；跨 tile PIP 生效。

---

## 4. 正在跑

`/opt/lzh/step03/tilepipe`：整块 `INT_L_X6Y11` 的全量扫描
（36 个基线设计 × 25 源 ≈ 900 位流，`xargs -P 12`）。

⚠️ 首次运行是白跑的：守卫 `[ -f "ref_$TAG.dcp" ] && continue` 对每个 tag 都成立
（`reuse5` 里同时有 `SLICE_*` 和 `ref_SLICE_*`），`p6_make.py` 一次没执行。已修复并重跑，
当前 900 个 `v_*.dcp` 已生成，正在 bitgen，最终汇总到 `tilepipe.json`。

---

## 5. 待办

1. tilepipe 跑完后统计：每个位被多少 PIP 复用、各 mux 的使能 cell、`cell = enable(imux) ∪ select(wire)` 是否成立。
2. 第 6 层：mux 内“物理输入序号”未解出。候选：由 25 源 × 20 格实测表反解 5×5 置换；或用 RapidWright site_pins/belt、prjxray ppips 顺序对照。
3. 把 reuse3/5/6 的观测写回远端 `v7_model.sqlite`（当前只有本机 28 行）。
4. STEP04：frame/bit 数据库生成器。

---

## 6. 常用命令

```bash
# 远端跑一个 mux 的 25 源实验
cd /opt/lzh/step03/reuse6 && bash /mnt/c/Users/S.tschai/p6_run.sh

# 本地分析
D:\Anaconda3\python.exe E:\DEEPSEEK\FPGA比特流逆向\step03_pip\p6_analyze.py
```
