# Codex 执行器：计划隔离执行 + 独立验收

分工：**我（规划/验收）** 写计划与验收器 → **Codex（执行）** 在隔离目录跑 → **验收器** 用数值独立判定成败。
Codex 不参与计划制定，也不自评通过。

## 为什么必须用独立进程启动

Codex CLI 在本会话的 DSH 沙箱内无法初始化（实测）：

```
WARNING: proceeding, even though we could not create PATH aliases: 拒绝访问。 (os error 5)
Error: failed to initialize in-process app-server client: 拒绝访问。 (os error 5)
```

原因是它需要写 `C:\Users\i\.codex\tmp`，而本会话工作区是 `E:\DEEPSEEK\FPGA比特流逆向`。
所以启动器是一个独立 `.cmd`：双击运行（或在我这边用完整权限启动）。

## 目录

| 路径 | 作用 |
|---|---|
| `PLAN.md` | 当前计划（唯一任务描述），每次运行复制到运行目录 |
| `run_codex.cmd` | 启动器：建运行目录、检查登录、跑 `codex exec`、跑验收器 |
| `verify_run.py` | 独立验收器：数值重算 + 结构校验 + v7re 未被篡改 |
| `_dryrun/` | `-DryRun` 的产物，用于本地自测启动器 |

运行产物：`E:\v7work\codex_runs\<RUNID>\`（`PLAN.md`、`results.csv/json`、`FIT.json`、`REPORT.md`、
`DONE.json`、`events.jsonl`、`last_message.md`、`verify.txt`、`run.env`）。

## 用法

```bat
:: 正常执行
run_codex.cmd

:: 只演练，不调用 codex（验证启动器/验收器本身）
run_codex.cmd -DryRun

:: 若 Codex 连审批都要跳过（默认已是 danger-full-access），可加 -Bypass
run_codex.cmd -Bypass
```

从 PowerShell 调用时加 `$env:DSH_NO_PAUSE=1`，避免结尾 pause 挂住。

## Codex 自身的沙箱在 Windows 上不可用

实测 `-s workspace-write` 时，Codex 用 `Rejected(... blocked by policy)` 拦掉所有 shell 命令：
连 `powershell -Command 'Get-Content PLAN.md'` 都被拒，模型只能回复“环境只读”。改成
`-s danger-full-access` 后 `cmd /c echo PROBE_OK` 正常执行。所以启动器默认关闭 Codex 沙箱，
隔离边界改为三条外部约束：

1. `PLAN.md` 写死“只能写当前运行目录”；
2. `verify_run.py` 事后检查 `v7re` 未被改动、`E:\v7work` 顶层除运行目录外无新写入；
3. 所有产物必须落在运行目录内，验收器逐个核对数值。

## 隔离边界

- `--cd` 指向运行目录，模型被要求在目录内工作；外部靠上面三条核查兜底。
- `v7re` 只读；验收器按 mtime 检查未被修改。
- 不联网、不装软件、不动 Vivado 安装（写在计划硬约束里，验收器抽查产物结构）。
- 计划变更：只改 `PLAN.md`，验收器里 `EXPECTED` 点列表同步改。

## 验收器做什么

1. `results.csv` 点数 = 10，成功 ≥8，A 组（区域锚点）成功 ≥4。
2. 每个成功点：帧连续、`bit_count` 与 `bits` 自洽、位宽一致。
3. `FIT.json` 的 `regions` + `dX_at_Y160` **重算** `predicted`，与实测帧号比，残差必须 ≤2。
4. `REPORT.md` 存在且含全部成功点；`DONE.json` 状态合法。
5. `v7re` 下文件 mtime 不晚于运行开始时间（防篡改）。
6. 数值交叉检查结果打印为 `[advisory]`，不参与硬判定。

退出码：0 通过；1 有硬性失败。

## 2026-10-20 起：改走 DSH 的 `subagent_codex` 工具

宿主里装了官方 `@deepseek-ai/dsh-subagent-codex@0.2.1-rc.2`，它的运行模型与上面的 `.cmd` 启动器不同：
我在会话里直接调 `subagent_codex` 工具，宿主用 `codex app-server --stdio` 起一个独立 Codex 会话，
返回后把最终消息交给我。`.cmd` 启动器保留作为人工兜底（例如宿主没启动、需要完全手工跑）。

新增两个**确定性**脚本，Codex 只负责“跑命令 + 轮询 + 回报”，判定逻辑不在它手里：

| 脚本 | 作用 |
|---|---|
| `scan_r2.py` | 逐点跑 `vivado.probe.probe()`，增量落盘 `results.csv/json`；失败只记 `error` 不中断；已完成的点默认跳过（断点续跑） |
| `fit_r2.py` | 合并多个 run 目录，拟合 `frame(X,Y)=region_base[Y//50]+dX_at_Y160[X]`，输出 `FIT.json`（含残差、结构异常、pass 判定） |

```bat
python scan_r2.py --out E:\v7work\codex_runs\r2_a1 --locs SLICE_X10Y50,SLICE_X10Y100
python fit_r2.py --runs E:\v7work\codex_runs\r2_a1 E:\v7work\codex_runs\r2_a2 ... --out E:\v7work\codex_runs\r2_fit
```

并行分片（避免多个 Codex 同时写同一份 CSV）：每片一个 `--out`，最后用 `fit_r2.py` 合并。

## 排错

- `codex not logged in`：先 `codex login`。
- Vivado 子进程失败：看运行目录里 `probe\<loc>\*.log`；常见 `LOC not honored`（该 site 不可用）和
  `vivado.bat` 非零退出（重试即可，Vivado 2017.2 在 Windows 上偶发）。
- 运行目录为空：说明 codex 初始化失败，改用 `-Bypass`。
