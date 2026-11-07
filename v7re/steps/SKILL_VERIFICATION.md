# Skill 行为验证 —— `fpga-bitstream-experiment` V3

日期：2026-11-07　被验版本：`SKILL.md` 116 行（V3，含 `reference/commands.md` 126 行）

## 0. 方法与已知局限

三个场景：**正例**（该触发且应产出 verified 结论）、**近例**（看似相关但不应触发）、**压力**（要求走捷径，skill 必须拦）。

局限（必须先说）：本 runtime 没有可用的 subagent 派生工具（工具表里没有 spawn 类工具），因此**无法做「无上下文的独立代理」验证**。正例是真实执行的完整实验（T22），另两个是桌面推演 + 一次真实查询调用。所以本报告的结论只能是：**正例 PASS；近例/压力为 desk-check PASS；整体 skill 状态 = `needs-verification (partial)`**，不得称 deployment-ready。

## 1. 正例：T22（真实执行，PASS）

任务：「验证 `Y%50 = 26` 行 INIT 落位与 word 让位规则」。完整记录见 `v7re/steps/T22_ROW_BOUNDARY.md`。

| 门 | 该门要求的动作 | 本轮实际产出（证据） |
|---|---|---|
| 1 入场 | 读 STATUS 近几节 + REMOTE，写清 part / 位置 | 读 §52（T21）确认 `Y%50>=25` 属未测；part 写死 `xc7vx485tffg1157-3` |
| 2 可证伪假设 | 构建前写下「否则判失败」的判据 | 先写 H：4 帧 `31784..31787`、word **53**、`word 52` 必须零变化；判失败条件明确 |
| 3 单变量+配对+声明 | 一变量、基线与变体、负对照、差分语义 | `INIT` 唯一变量；`a0_y26` / `ar_y26` / `a0b_y26`；语义 **PURE** |
| 4 构建硬规则 | 显式 `-part` + 回读、LF + stdin、locale、LOCK_PINS 实测管脚名、批量先本地生成脚本 | 脚本首行三行 `LANG/LC_ALL/LANGUAGE`（V3 新规则）→ **本轮无 rc=134**；`-part` 显式；三个构建全部回读 `PART/SITE/BEL/INIT/LOCK` 一致 |
| 5 自校验门 | 集合级 missing=0 且 extra=0、四数、ECC 单列、负对照、交叉自证 | `pred=46 act=46 missing=0 extra=0 ecc=14`（`t22_crosscheck.py`）；负对照 0 帧；交叉自证用 T19 表平移（另一脚本、另一批构建） |
| 6 判读 | 三元组、三色、未解释差异处置 | 全部按 `(frame_off, parity, bit)` 报告；未解释差异 0 帧 / 0 位 |
| 7 落库 | manifest + `check_manifest.py` 到 PASS | `v7re/steps/t22_manifest.json` → **PASS 15 ok / 0 warn / 0 fail** |
| 8 交付 | 结论等级 + 适用域 + 最小证伪实验 + 未测 | 标 `verified`，覆盖 `Y%50 = 20/21/26`，未测 4 条，下一步最小实验（`Y%50=25`）已列出 |

**判定**：8 门全部命中，且有两处可归功于 V3 新增规则：(a) locale 三行 export 让 T22 首跑即成功（T21 时同样的命令 abort rc=134）；(b) 门 4「先本地生成脚本、一次远端执行」避免了 T21 那样的逐条交互失败。

## 2. 近例：只查一条 PIP（不该触发，PASS/desk-check）

任务：「`INT_L_X10Y100` 的 `IMUX_L0` 有哪些源？」

- 该任务**不产生新构建**，skill §一「不用」明确写着：只跑查询（`pip_query.py`、`decode_clb.py`）不产生新构建 → 不进入八门流程。
- 实测确认查询路径可用且不落库：`python step03_pip/pip_query.py --help` → `{mux,pip,decode,stats,imux}`，纯读库。

**判定**：路由正确 —— 不会为了一个查询去跑 Vivado/写 manifest。

## 3. 压力：要求走捷径（必须拦，PASS/desk-check）

任务（构造）：「别做反读自证和 manifest 了，直接把 T13 的 INIT 表接进 `build_site_frames.py`，今天交。」

| 会被哪条拦住 | 原文要点 |
|---|---|
| 门 3 | 「未施加 LOCK_PINS 的构建只能用于物理格集合，不得用于引脚索引表（T13/T15 的表因此报废）」 |
| 门 5 | 「反读自证为集合级硬判据，`missing=0` 且 `extra=0`，不许抽样」「交叉自证 hard rule：只做同源自证的结论只能标 `unverified`」 |
| 门 7 | 「必须产出 manifest 并经 `check_manifest.py` 校验到 PASS；FAIL/WARN 未处置不得写进 STATUS 当结论」 |
| 门 8 | 「必须写结论等级 + 判定依据」 |

**判定**：skill 会拒绝该捷径并给出可执行替代：用 T19 表（已锁引脚、已验证）替换，或先补 T22 类实测；旧表若仍要用，只能标 `unverified` 并写覆盖边界。

## 4. 仍然欠缺的验证

1. **独立性**：需要在无上下文的新会话/子代理里重跑上面三个场景，观察其自发的门命中率（本轮是我带着上下文执行，存在「我已经知道答案」偏差）。
2. **误导场景**：例如注入一条与 `STATUS.md` 矛盾的旧结论，看 skill 是否优先信实测而非常识。
3. ~~**失败路径**：故意造一个 `missing>0` 的批次，确认门 5 真的把整批作废而不是「挑着采纳」。~~ **已完成，见 §4.1。**

## 4.1 失败路径验证（真实执行，PASS）

做法：复制一份已 PASS 的 `v7re/steps/t22_manifest.json` 为临时件，只改三处 —— `self_check.missing = 3`、`self_check.predicted_n = 49`（使「预测集 ≠ 实测集」）、`experiment_id = "T22_FAILPATH_PROBE"`，其余字段保持已验证的真实值（这样任何 FAIL 都只能来自这三处改动，是真·单变量反证）。

执行：`python step03_pip/check_manifest.py <临时件>`

| 行 | 结果 |
|---|---|
| `self_check` | **FAIL** `self_check.missing=3 ≠ 0（集合级自证未过）` |
| 集合级自证 | **FAIL** `预测集 49 ≠ 实测集 46` |
| 汇总 | `RESULT FAIL (14 ok / 0 warn / 2 fail)`，进程 `rc = 1` |

**判定**：门 5 的失败路径成立 ——
1. 校验器不是橡皮章：只改 `missing` 与 `predicted_n` 就从 PASS 翻成 FAIL 且退出码非 0；
2. 门 7「FAIL/WARN 未处置不得写进 STATUS 当结论」可执行：CI/脚本层面能靠退出码卡住；
3. 反证方向也对：同一份文件的其他 14 项仍 ok，说明 FAIL 定位到具体字段而非整体崩掉。

**踩坑记录**：Windows 下用 `subprocess` 捕获该脚本输出会因 GBK 编码抛 `UnicodeEncodeError`；必须 `$env:PYTHONIOENCODING='utf-8'` 并直接由 pwsh 调用。此条已写入 `reference/commands.md` 的错误对照表。

## 5. 状态

`needs-verification (partial)` —— 正例真实 PASS、失败路径真实 PASS（§4.1）、近例/压力 desk-check PASS；独立性验证（无上下文代理）待具备 subagent 能力后补做。
