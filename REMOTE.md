# 远端机器连接记录（唯一权威来源）

> 任何会话要用远端 Vivado，**先读本文件**。这里的每条命令都在 2026-10-27 17:45 实测通过。
> 机器是 DHCP，地址会变；变了按 §4 的流程重新定位，然后**更新本文件 + `~/.ssh/config`**。

---

## 1. 当前有效连接（2026-10-27 17:45 验证）

| 项目 | 值 |
|---|---|
| 地址 | **172.17.70.41**（DHCP，会变；旧地址 172.17.71.129 已于 2026-10-27 失效） |
| SSH 用户 | **s.tschai**（不是 `lzh`，也不是 `root`——那两个都被拒） |
| 私钥 | `C:\Users\i\.ssh\v7remote`（`IdentitiesOnly yes`；`id_ed25519` 对这台**无效**） |
| ssh 别名 | `ssh fpga`（`~/.ssh/config` 已改指本行；旧配置留档为 `Host fpga-old`） |
| 远端 OS | Windows 11（build 26200），主机名 `DESKTOP-47NHOKA`，`SSH-2.0-OpenSSH_for_Windows_9.5` |
| 默认 shell | **cmd.exe**（不是 bash！所有引号/管道问题都源于此） |
| Linux 侧 | WSL Ubuntu 20.04，用 `C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root`（System32 下的 `wsl.exe` 是 stub） |
| 工作区 | `/opt/lzh`（磁盘 1007G，已用 216G） |
| Vivado | `/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado`，license `/opt/lzh/Xilinx/Vivado_license_2037.lic`（2037.05） |
| Python | `/opt/lzh/venv/bin/python` = 3.8.10，已装 RapidWright（site-packages 里的 jar 已手工换成 `lin64` 版） |
| JDK | `/usr/lib/jvm/java-17-openjdk-amd64` |
| git | 远端 `/opt/lzh/v7re` **不是 git 仓库**；代码以本地 `step03_pip/` 为准 |

---

## 2. 三种调用姿势（按可靠性排序）

### A. 跑脚本（推荐，唯一不会被引号坑到的方式）

本地写 `.sh`（**必须 LF**，用 write 工具或 `newline='\n'`；`Out-File -Encoding ascii` 会产生 CRLF，远端报 `$'\r'` 错），
再走 stdin 管道：

```powershell
cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < "E:\DEEPSEEK\FPGA比特流逆向\step03_pip\_recon.sh"' 2>&1 | Out-String
```

PowerShell **不支持 `<` 重定向**，所以外面必须套 `cmd /c`（整条用单引号包住，交给 cmd 解析）。
脚本里第一行固定：

```bash
set -u
export LANG=C LC_ALL=C            # 或 C.UTF-8；不设置 Vivado 直接崩
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
```

### B. 单条命令（可以，但**里面不能有管道 `|`**）

```powershell
ssh fpga 'C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -lc "hostname; ls /opt/lzh/step03; df -h /opt"'
```

管道会被 Windows 的 cmd.exe 抢走解释（实测 `| tail -1` 报「'tail' 不是内部或外部命令」）。
需要管道就用姿势 A。

### C. Windows 侧命令（不进 WSL）

```powershell
ssh fpga 'hostname & ver'
```

### 取文件回来（scp 会挂死，别用）

远端打包 → base64 → 本地落盘 → Python 解：

```bash
# 远端脚本里
cd /opt/lzh/step03
tar czf - sweep1/pips_S_*.json fam/spec.json | base64 -w0
```

```powershell
cmd /c 'ssh -o BatchMode=yes fpga "... bash -s" < "pull.sh" > "out.b64"'
# 再用 python base64+tarfile 解到 step03_pip/remote_json/
```

注意：PowerShell 自己的 `>` 重定向写的是 UTF-16，解码要按 `utf-16` 读；用 `cmd /c` 的重定向则是原始字节。

---

## 3. Vivado 必备细节（踩过的坑）

- **locale**：不设 `LANG`/`LC_ALL` 会 `locale::facet::_S_create_c_locale name not valid` 直接崩。
- **`-source /dev/stdin` 不工作**（管道不可 seek）：tcl 必须先写成文件再 `-source x.tcl`。
- **DRC 阻断 bitgen** 的两类处理（写法不同，别混）：
  ```tcl
  set_property IS_ENABLED false [get_drc_checks PDCN-1568]
  set_property IS_ENABLED false [get_drc_checks PDCN-1569]
  set_property SEVERITY {Warning} [get_drc_checks NSTD-1]   ;# 强制检查只能用 SEVERITY
  set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
  ```
- 并行：`ls v_*.txt | xargs -P 12 -I{} ...`，12 路是这台机器的稳定上限。
- 每个变体 `.bit` 约 20.27 MB，跑 100 个变体≈2 GB，磁盘够用但别忘了清。

---

## 4. 地址又变了怎么办（2026-10-27 实测流程，5 分钟）

1. **确认不是本机问题**：`ping 172.17.64.1`（网关）与 `ping 8.8.8.8` 都要通。
2. **确认目标真的没了**：对旧 IP 做 ICMP + TCP 22/445/3389 探测，全 timeout 才算。
   （ARP 表里旧 IP 显示 `Reachable` **不算证据**：本网段的 ARP 由 VRRP 虚拟 MAC
   `00-00-5E-00-01-1F` 代答，所有 IP 都"可达"。）
3. **找候选**：`Get-NetNeighbor -AddressFamily IPv4 | ? {$_.IPAddress -like "172.17.*"}`，
   再对 `~/.ssh/known_hosts` 里出现过的 IP 逐个试 TCP 22。
4. **认机器**：读 SSH banner，`SSH-2.0-OpenSSH_for_Windows_9.5` 就是这台（Windows+WSL）。
   ```powershell
   $c=New-Object Net.Sockets.TcpClient; $c.Connect($ip,22); $s=$c.GetStream()
   $b=New-Object byte[] 256; Start-Sleep -Milliseconds 800; $n=$s.Read($b,0,256)
   [Text.Encoding]::ASCII.GetString($b,0,$n).Trim(); $c.Close()
   ```
5. **登录**：用户名 `s.tschai` + 私钥 `v7remote`。用 `lzh`/`root` 或 `id_ed25519` 都会
   `Permission denied (publickey,password,keyboard-interactive)`。
6. **更新记录**：改 `~/.ssh/config` 的 `Host fpga`（把旧条目降级留档），并改本文件 §1 的地址与日期。
7. 本网段事实：本机 `172.17.68.157/21`（以太网），网段 `172.17.64.0/21`，网关 `172.17.64.1`。

---

## 5. 远端数据清单（2026-10-27 盘点 `/opt/lzh/step03`）

> **2026-11-07 清理后状态（A+B 档，详见 [step03_pip/REMOTE_CLEANUP_PLAN.md](step03_pip/REMOTE_CLEANUP_PLAN.md) 与 [STATUS.md](STATUS.md) §55）**
> - 磁盘 299 G → **194 G**（可用 762 G）；`step03` 226,730 MB → **118,914 MB**
> - **`.bin` 已全部删除**（5,570 → 4）。同名 `X.bin` 只是 `X.bit` 去掉 102 字节 Vivado 头，逐文件 `cmp -i 102:0` 自证后才删；可用 `tail -c +103 X.bit > X.bin` 重建
> - 仅存 4 个孤本 `.bin`：`fam/v_FAN_ALT3_BYP_BOUNCE3.bin`、`v_BYP_ALT6_BYP_BOUNCE3.bin`、`v_EE2BEG1_LOGIC_OUTS_L1.bin`、`v_SE6BEG0_LOGIC_OUTS_L0.bin`（无 `.bit` 双胞胎）
> - `.bit` 5,765 个未动；`.dcp` 5,833；`.Xil`、`*.backup.log`、`*.jou`、`bands2\r`、`dsptest\r`、`reuse4/` 已清除
> - 下表是 **2026-10-27 的历史盘点**，个数已不准确（如 `tilepipe` 实为 1,248 个 `.bit`），"本地是否已有结果"一列仍有效

| 目录 | .bit | .json | .dcp | 本地是否已有结果 |
|---|---|---|---|---|
| tilepipe | 936 | 1 | 972 | ✅ `tilepipe.json` → 864 EXACT |
| tilepipe2 | 936 | 1 | 972 | ✅ `tp2.json` → 864 EXACT |
| tilepipe3 | 156 | 1 | 162 | ✅ `tp3.json` → 144 EXACT |
| tilepipe4 | 936 | 0 | 972 | ✅ 已另行导出 `tp4b.json` |
| fam | 125 | 3 | 125 | ✅ `famdiff.json`；**`spec.json`/`expected.json` 未拉回** |
| famr | 125 | 2 | 124 | ✅ `famdiff_r.json`；**`spec.json` 未拉回** |
| bands2 | 51 | 10 | 51 | ✅ 10 个 `y*/diff.json` 已拉回 |
| sweep1 | 48 | 24 | 48 | 位观测有 `sweep_obs.json`；**24 个 `pips_S_*.json`（每个设计的 PIP 名单）未拉回** |
| reuse | 25 | 1 | 26 | ✅ `reuse_bits.json` |
| reuse3 | 60 | 1 | 60 | **`p3_bits.json` 未拉回** |
| reuse4 | 0 | 0 | 1 | 半成品，**已于 2026-11-07 删除** |
| reuse5 | 72 | 2 | 72 | ✅ `mux32.json`；**`mux32_fields.json` 未拉回** |
| reuse6 | 124 | 2 | 102 | ✅ `holdout.json`/`p6_bits.json` |
| blkcol / blkcol2 / blkcol3 | 26×3 | 1×3 | 27×3 | ✅ `t16/t12/t10.json` |
| colscan | 104 | 0 | 108 | ✅ `col_9/11/12/13.json`（真实列 9/12/13/15） |
| colscan2 | 52 | 0 | 54 | ✅ `rep_C6R/rep_C8R.json` |
| lutmap | 65 | 0 | 1 | ✅ LUT INIT 64 位映射（`lutmap.b64`） |
| one | 23 | 0 | 23 | ✅ `one_obs.json`（长线逐条删除，已失效） |
| pip1 / pip2 | 9 / 24 | 0 | 11 / 24 | 早期帧号实验 |
| band1 / band3 / right | 26×3 | 0 | 27×3 | ✅ 行带/INT_R 早期实验 |
| `bands2\r` | 0 | 0 | 0 | **垃圾目录**（CRLF 事故产物），**已于 2026-11-07 删除** |

其他：`/opt/lzh/v7re`（27G，工程副本 + `data/model/v7_model.sqlite`）、`/opt/lzh/Xilinx`（31G）、
`/opt/lzh/codex`（2.8M）、`/opt/lzh/venv`（210M）、`/opt/lzh/README.md`。

**注意**：`/opt/lzh/README.md` 里写的路径是 `/data/lzh/...`，那是旧路径，**实际全在 `/opt/lzh/...`**。

---

## 6. 与本地文档的关系

- 项目现状/待办 → [STATUS.md](STATUS.md)
- PIP 复用规则总纲 → [step03_pip/REUSE_RULES.md](step03_pip/REUSE_RULES.md)
- 地址律与行带 → [step03_pip/PIP_LAW.md](step03_pip/PIP_LAW.md)
- 本次重连的诊断过程也记在 `STATUS.md` §6.8。
