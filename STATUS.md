# FPGA 比特流逆向 — 项目现状（每个任务开始前先读本文件）

最后更新：2026-10-24

目标：XC7VX485T-2FFG1761（VC707）比特流逆向。
路线：**拓扑（RapidWright 导出）→ PIP→bit 差分 → frame/bit 数据库 → 完整 bit↔feature 映射**。

---

## 1. 位置

| 内容 | 位置 |
|---|---|
| 项目代码（本地） | `E:\DEEPSEEK\FPGA比特流逆向\v7re` |
| STEP03 实验脚本 | `E:\DEEPSEEK\FPGA比特流逆向\step03_pip` |
| 本地工作数据（DB、bit） | `E:\v7work`（`routing\v7_routing.db`、`routing\out_routing`、`m2\`、`bits\`） |
| 远端机器 | `172.17.70.41`（DHCP，重启可能变），用户 `s.tschai`，私钥 `C:\Users\i\.ssh\v7remote` |
| 远端 WSL | Ubuntu 20.04，`/opt/lzh/v7re`、`/opt/lzh/Xilinx/Vivado/2017.2`、`/opt/lzh/venv` |
| STEP03 实验目录 | 远端 `/opt/lzh/step03/pip1`、`pip2` |

**远端实测核对（2026-10-24 只读 SSH 验证，非推测）：**

| 内容 | 远端权威位置 | 实测 |
|---|---|---|
| 模型库（含 M1） | `/opt/lzh/v7re/data/model/v7_model.sqlite` | 635,047,936 B / 2026-10-21 22:09；sites 86,022、site_pins 5,489,706、tiles 150,380、tile_types 115、**probes 72 / probe_bits 1248 / region_bases 14 / column_offsets 420**；`site_frames`/`bit_map`/`pip_bits` 仍 **0** |
| 模型库副本 | `/opt/lzh/v7re/work/refs_20261021/model/v7_model.sqlite` | 同上（22:10，逐字节同尺寸）|
| 旧 M0 probe 库 | `/opt/lzh/v7re/work/refs_20261021/db/v7.sqlite` | 8,179,712 B；sites 75,900 / probes 47 / probe_bits 784（= 本机镜像那份）|
| P0 边界库 | `/opt/lzh/v7re/work/refs_20261021/p0/v7_p0.sqlite` | 361,844,736 B |
| 逐站点 probe | `/opt/lzh/v7re/data/m1/probe`、`work/probe_smoke`、`work/refs_20261021/probe` | 全片 `result.json` 共 **31** |
| v7re 测试 | `/opt/lzh/v7re/tests`（7 个 `test_*.py`）| pytest **18 collected**（与 §2「18 passed」一致）|
| Vivado | `/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado` | 存在（2017.06 wrapper）|

> **同步缺口（已定位）**：本机 `E:\v7work\model\v7_model.sqlite` 是**另一份构建**（639,430,656 B，`region_bases`/`column_offsets`/`site_frames` 全 0，**不含 M1**）。要消除缺口：从远端拷 `data/model/v7_model.sqlite` 覆盖本机即可（含 14/420/72/1248）。`site_frames`/`pip_bits` 两张空表是 STEP04/M2 要填的，两边都还没有。

---

## 2. 远端环境怎么用

```bash
# WSL 入口（System32 下的 wsl.exe 是 stub，必须用全路径）
"C:\Program Files\WSL\wsl.exe" -d Ubuntu -u root -- bash -lc "<命令>"

# Vivado
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C          # 不设会报 locale::facet::_S_create_c_locale
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source x.tcl

# Python / RapidWright
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
/opt/lzh/venv/bin/python ...
```

注意：

- **SSH 默认 shell 是 cmd.exe**，嵌套引号极易被吃。复杂命令一律「本地写 `.sh`（LF 换行）→ `scp` → `bash /mnt/c/Users/S.tschai/x.sh`」。
- PowerShell 的 `Set-Content` 会写 CRLF，bash 脚本必须用 `[IO.File]::WriteAllText(..., ($lines -join "`n"))`。
- RapidWright 的 pip 包会去 github.com 下 400MB jar（连不通），已改用本机 `rapidwright-2026.1.1-standalone-win64.jar` 复制成 `lin64` 名字放进 site-packages，**Java 跨平台，实测可用**。
- 远端 `pytest tests`（v7re）当前 **18 passed**。

---

## 3. 已完成

### STEP01 拓扑导出

- RapidWright 遍历全片：150,380 tiles / 115 类型 / 56,847,864 wires / 207,253,149 PIPs。
- 发现 `Tile.getWireConnections` 提供跨 tile 连接（RW 内置 tileconn）。
- 产物：`out_routing`（241 文件，9.7MB）+ `v7_routing.db`。

### STEP02 跨 tile 连接规范化

- corridor 规则（tile 类型序列 → 连接规则），全设备验证 0 conflicts。
- 后继改做**精确边表**：`edges_exact` 39,923,710 行，150,380 tiles，
  11,857,917 条有外连 wire；全量校验 bad_wires=0 / missing=0 / extra=0。
- 规则：同 (grid_x, grid_y) 唯一，`INT_R_X145Y180` 与 `CLBLM_R_X145Y180` 是不同 grid 单元；
  tile **名字**里的 X/Y 会撞号，不能用名字键。

### STEP03 PIP→bit（进行中，已有结论）

方法：RapidWright 读 DCP → 删一条 PIP → 写回 DCP → Vivado 重新 bitgen → 逐位差分。

**已确认的三条硬结论：**

1. **帧号 = 线性序号**（按 config row，每行末尾补 2 个 overhead 帧）。
   验证：块基址 `0x420300` ↔ 帧 31,680；`0x4203A0` ↔ 31,748。
2. **word 50 是 ECC**，不是配置位。任何数据位变化都会带出一组 word50 位变化（6~10 位）。
3. **站点内部 PIP（CLB 的 A→LOGIC_OUTS、IMUX→A）改 DCP 无效**：bitgen 是从网表+布局
   重新推导站点路由的，不看 DCP 的 route 属性。要 fuzz 站点内位只能改网表/布局。

**PIP 位位置实测（列 X6，`LOGIC_OUTS_L20->>NR1BEG2`）：**

| Y | 变化帧 | 配置位 |
|---|---|---|
| 20 | 31688, 31694 | (w41, b7) |
| 22 | 31688, 31694 | (w45, b7) |
| 30 | 31688, 31694 | (w62, b7) |
| 31 | 31688, 31694 | (w64, b7) |
| 32 | 31688, 31694 | (w66, b7) |
| 40 | 31688, 31694 | (w82, b7) |
| 41 | 31688, 31694 | (w84, b7) |
| 42 | 31688, 31694 | (w86, b7) |
| 50 | **26442, 26448** | (w1, b7) |
| 52 | 26442, 26448 | (w5, b7) |
| 60 | 26442, 26448 | (w21, b7) |

规律：

- 帧对由 **(列, clock region, PIP 变体)** 决定；同区域内恒定，块内偏移恒为 8 和 14。
  region 0（Y0~49）块基址 `0x420300`，region 1（Y50~99）块基址 `0x400300`。
- **word ≈ 2 × (Y − region 起始行) + k**，k 实测为 1 或 2（Y20/22/50/52/60 是 1，
  Y30/31/32/40/41/42 是 2，**待复核**）。
- bit 位由 PIP 变体在 tile 内的位置决定（这组全是 b7）。
- 另一变体 `LOGIC_OUTS_L12->>NR1BEG0`（Y10）→ 帧 31690/31693、word 20，说明帧对与 word
  都依赖变体，不只是坐标。

**FAR 位域（26 位）：**

| 位 | 字段 |
|---|---|
| [25:23] | block type（0=逻辑，1=BRAM/DSP） |
| [22] | top/bottom |
| [21:17] | config row |
| [16:7] | column |
| [6:0] | minor |

**帧数账：** ConfigArray 14 行 / 1,183 blocks / 50,148 帧；每行末尾 2 个 overhead 帧 →
14×2=28 → 50,176，与 `.bit` 里 FDRI 的 5,067,776 words ÷ 101 完全一致。

### 复核状态（2026-10-24，gpt-6.1-sol 对抗式）

完整报告：[codex_review_step03_20261024/REVIEW.md](E:/DEEPSEEK/FPGA比特流逆向/codex_review_step03_20261024/REVIEW.md)

| 主张 | 判定 | 备注 |
|---|---|---|
| C1 帧号 = 线性序号 | INCONCLUSIVE | 需要从 `.bit` 包流独立解 FAR 交叉验证 |
| C2 每行末尾 2 个 overhead | INCONCLUSIVE | 同上，目前是“用假设验证假设” |
| C3 word 50 = ECC | **降级**：word 50 是校验/辅助区 | 分类循环，需多项式/校验子证据 |
| C4 site PIP 改 DCP 无效 | PASS（限已测案例） | 0 帧差异证明 bitgen 不照抄 site route |
| C5 位位置模型 | INCONCLUSIVE | 拟合可用，但 k∈{1,2} 是描述性结论 |
| C6 变体决定帧对 | INCONCLUSIVE | 需同位置只改变体的对照 |

## 4. 待办

0. **[同步 远端→本机]** 把远端 `/opt/lzh/v7re/data/model/v7_model.sqlite`（含 M1：region_bases 14 / column_offsets 420 / probes 72 / probe_bits 1248）拷回本机 `E:\v7work\model\`，消除 §1 记录的同步缺口。

> **STEP03 已有结论但尚未入库**：远端模型库 `pip_bits`/`bit_map` 仍为 **0**；`step03_pip/RESULTS.md` 里的 (变体→帧对,word,bit) 还没写进 DB。填 `pip_bits` 是 STEP04 的输入。

1. **STEP04：frame/bit 数据库生成器** —— 用 (列, region, 行, 变体) → (帧, word, bit) 公式；先把 `RESULTS.md` 的观测填进 `pip_bits`。
2. **补 C1/C2 的独立证据**（复核意见第 1 条）：解析 `.bit` 的 FAR/FDRI 包流，独立统计行切换与每行末端 2 帧，和 `ConfigArray` 对照。
3. **补 C3 的独立证据**：查 7 系列 ECC 的多项式/校验子，对已知单 bit 翻转验证 word 50；并测“数据不变时 word 50 是否变”。
4. **解决 k 的抖动**（复核第 3 条）：同一变体在更多 Y、每个 clock region、多种 tile 上取点，记录 wire/PIP 身份。
5. **C6 对照实验**：固定位置，只改变体，比较帧对与 bit。
6. **批量 PIP 表**：固定一个 tile，把所有 PIP 变体跑一遍（脚本已有雏形）。
7. **站点内部位 fuzz**：改网表/引脚（不是改 route）。

---

## 5. 常用命令

```bash
# 建一个 PIP 实验（远端）
cd /opt/lzh/step03/pip2
bash /mnt/c/Users/S.tschai/run_ymore.sh     # 模板：build → a.bit → 删 PIP → b.bit → diff

# 本地看结果
type E:\DEEPSEEK\FPGA比特流逆向\step03_pip\RESULTS.md
```
