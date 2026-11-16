# P0 任务提示词：INT_INTERFACE / FEEDTHRU 的 PIP 形状

> 生成方式：草稿经 `prompt-optimizer` CLI 优化
> （`cd E:\DEEPSEEK\tools\prompt-optimizer; node po.mjs user "<草稿>" --template user-prompt-professional`），
> 再人工补回被优化器抽掉的硬数据（实例数、路径、字段序）。
> 本提示词已在 2026-11-13 实际执行，结果见 `v7re/steps/T90_INTERFACE_FEEDTHRU.md`。

---

## 提示词正文

背景：我在对 Xilinx Virtex-7（xc7vx485tffg1157-3）做位流逆向，主线是「PIP 复用编码规律」：
位流里哪些配置位被多个 PIP 复用、能否用闭式公式生成，而不是靠查表。

已确定的事实（不要重新质疑，除非有反证）：

1. INT_L / INT_R 各 172 个 family（family = PIP 的目的 wire），每个 family 有 24 个源，
   24 个源落在固定的 6 行 × 4 列网格里，行帧 = `16+row`，列码第 i 位对应帧 `25-i`。
2. 列码 = 线长类别：1/2 → DOUBLE，7/11 → SINGLE，744/744 全中。
3. 行（类内成员序）已由 T89 解成生成律：4 个基置换 + 7 步置换步进（S4 上的 r/ρ/e/X2/r³ 组合），
   32/32 重建成功，1,536/1,536 与两侧 2,048/2,048 全中。
4. 全器件可配置 PIP 实例 207,253,149 个，其中 INT_L/INT_R 占 95.7%（各 26,550 实例 × 3,737 PIP）。
5. 源数 ≥8 的 family 分布：INT 172/172（最大 24 源）、BRAM 3/63（最大 111）、DSP 1/79（最大 280）、
   CLBLM 2/2（最大 358）、CLBLL 2/2（最大 338）。结论是「位级复用」是 INT 的 24 源 6×4 现象，
   其它类型是超大 fan-in。

要回答的问题（P0）：INT_INTERFACE_L / INT_INTERFACE_R / INT_FEEDTHRU_1 / INT_FEEDTHRU_2
这四类 tile 的 PIP，是否也是「每目的 24 源 + 6×4 网格 + 与 INT_L 相同的列码/行律」？还是另一种结构？

已知这些 tile 的实例数：INT_INTERFACE_L 4,550、INT_INTERFACE_R 3,850、INT_FEEDTHRU_1 525、
INT_FEEDTHRU_2 600，合计 9,525 实例，目前完全未覆盖。

数据在哪：

- 路由模板在远端机器 `ssh fpga`：`/opt/lzh/v7re/work/refs_20261021/routing/out_routing/templates/`
  下的 `*.json`，每个 tile_type 一个文件，字段 `pip_defs` 是 `(src, dst)` 二元组的列表
  （注意顺序是 src 在前，反了会全错）。
- 本机 `v7re/steps/tile_pip_lawscan.json` 有 636 个 family 的扫描结果，可先查这四类是否在里面。
- 本机 `E:\v7work\model\v7_law.sqlite` 表 `law_cells` / `law_tiles` 有已落库的 INT 格数据，可用于对拍。

要求：

1. 只做离线统计与对比，不许起新的 Vivado 构建（机时贵，且这题不需要）。
2. 按目的 wire 分组，统计每组的源数分布、格数（cell）分布、是否出现 24 源、是否落在 6×4 网格。
3. 若出现 24 源，直接拿 INT 的编码公式去预测，报「命中/不符/未覆盖」三个数，不许只说「类似」。
4. 若源数不是 24，如实报出真实分布，并判断它属于哪种形态
   （单源 / 多源 one-hot / 超大 fan-in / 其它）。
5. 不许写 `STATUS.md`，只产出「报告 md + 脚本 + 数据 json」。
6. 每个数字必须附可复现命令，命令要能在当前仓库直接跑。
7. 做不到就写「数据」，不要为了凑公式造规律。

输出：一份 markdown 报告，含结论表（四类 tile 各自的族数/源数分布/是否 24 源/是否 6×4/
编码是否同 INT）、证据（具体文件名与统计数字）、复现命令、以及对
「位级复用是否只存在于 INT」这个总判断的影响。

---

## 执行结果摘要（2026-11-13）

| 假设 | 判定 |
|---|---|
| 接口类也是 24 源 mux | **否证**：24 个目的各只有 1 个源，是 `X_Bk ->> Xk` 的 1:1 直通 |
| FEEDTHRU 有可配置 PIP | **否证**：模板与 `tile_types.pips` 都是 0 |
| 9,525 实例是未覆盖的可配置面 | **否证**：可配置 PIP 实例 0 个 |

新线索：`HCLK_L` 有 12 个 **16 源 mux**（200 pips / 20 dst / 529 实例每侧），
是 INT 之外第一个宽度 ≥16 的真选择器，编码形态未测。

产物：`v7re/scripts/iface_feedthru_probe.py`、`v7re/steps/T90_INTERFACE_FEEDTHRU.md`、
`v7re/steps/t90_tile_fanin.json`、`STATUS.md` §170。
