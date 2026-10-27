# FPGA485T — XC7VX485T 比特流逆向

对 XC7VX485T-2FFG1761（VC707）做比特流逆向：从 RapidWright 拓扑数据出发，
建立 **PIP → 配置位（frame/word/bit）** 映射，最终形成可查询的 bit↔feature 数据库。

## 当前进度

| 阶段 | 内容 | 状态 |
|---|---|---|
| STEP01 | 全片 tile/wire/PIP 拓扑导出（150,380 tiles / 56.8M wires / 207M PIPs） | ✅ |
| STEP02 | 跨 tile 连接规范化 + 精确边表（39,923,710 行，全量校验 0 差异） | ✅ |
| STEP03 | PIP→bit 差分实验：帧号公式、word 50 校验区、位位置模型 | 🚧 进行中（见下） |
| STEP04 | frame/bit 数据库生成器 | ⏳ |

**最新状态与待办见 [STATUS.md](STATUS.md)。**

## 已确认的关键事实（STEP03）

- 比特流帧号 = `ConfigArray` 线性序号（每个 config row 末尾 2 个 overhead 帧，共 50,176 帧；
  与 `.bit` 中 FDRI 5,067,776 words ÷ 101 一致）。
- FAR 26 位：`[25:23]` block type、`[22]` top/bottom、`[21:17]` row、`[16:7]` column、`[6:0]` minor。
- 帧对由 **(列, clock region, PIP 变体)** 决定；`word ≈ 2×(Y − region起始行) + k`，bit 位由变体决定。
- word 50 是校验/辅助区（含 ECC 位），差分时必须排除。
- 站点内部 PIP（CLB 的 A→LOGIC_OUTS 等）改 DCP route 属性 **不会**改变比特流：
  bitgen 从网表+布局重新推导站点路由。

> 这些结论已经过 `gpt-6.1-sol` 对抗式复核，判定与证据缺口见
> [codex_review_step03_20261024/REVIEW.md](codex_review_step03_20261024/REVIEW.md)。

## 目录结构

```
v7re/                 主工具包
  bitstream/          .bit 解析、帧/位差分
  routing/            拓扑导出、跨 tile 连接、精确边表
  vivado/             Vivado 调用、DCP 生成、探针
  scripts/            CLI（parse_bit / diff_frames / probe_lut / sweep_lut）
  db/                 SQLite schema
  tests/              pytest（18 passed）
step03_pip/           PIP→bit 实验脚本与结果（RESULTS.md）
codex_review_*/       各阶段对抗式复核包
lit/、m2_fix/、tools/  辅助脚本（大文件不入库）
```

## 环境

- 器件：XC7VX485T-2FFG1761（VC707）
- Vivado 2017.2（远端 Windows + WSL Ubuntu，license 为 2037.05）
- Python 3.8 + numpy/fasm/intervaltree/pyyaml/pytest
- RapidWright 2026.1.1（Java 17）

**远端连接方式（地址/用户/私钥、调用姿势、换址后怎么重连）见 [REMOTE.md](REMOTE.md)。**
一句话：`ssh fpga` → Windows cmd → `C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s`，脚本走 stdin 管道。

## 快速开始

```bash
cd v7re
python -m pytest tests -q
python scripts/parse_bit.py <file.bit>
```

远端实验（Vivado 生成 bitstream 并差分）——本地写 LF 的 `.sh`，再管道送进去：

```powershell
cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < "step03_pip\_recon.sh"'
```

本地复核（不需要远端）：

```powershell
cd step03_pip
python pip_law.py --check     # 地址律自检：列扫描 + INT_L 124 + INT_R 124
python verify_reuse.py        # 三种差分语义 × 3,270 条观测
python reuse_stats.py         # 位域独占性 + 覆盖率
```
