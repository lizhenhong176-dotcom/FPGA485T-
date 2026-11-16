# tamper/ —— 无参考篡改定位器的实验素材与原始结果

报告：`paper/TAMPER_LOCALIZER.md`；现状记录：`STATUS.md §35`；
脚本：`v7re/scripts/tamper_localize.py`。

全部数字都能用下面这条链路从 `.bit` 重算，不需要 Vivado（除 `tamper_init.bit` 的生成）。

## 参考设计（被测的真实位流）

| 文件 | 说明 |
|------|------|
| `ref/top.v`、`ref/top.xdc`、`ref/build.tcl` | 24 级 LUT6 链，LOC 散布 8 列 × 3 行带，全 A6LUT |
| `ref/routed.dcp` | 布线后的 checkpoint（后面所有重写都基于它） |
| `ref/ref.bit` | 参考位流，20,273,538 B，13,426 个置位，**982 个 active INT tile**，1,812 条 PIP |
| `ref/pips_all.txt` | `get_pips -of_objects [get_nets -hier]` 的真值 PIP 表 |
| `ref/cells.txt` | 24 个 site 的 NAME / INIT / LOC / BEL |
| `ref/tamper_init.tcl` | 把 24 个 LUT6 的 INIT 全改后重写位流 |
| `ref/tamper_init.bit`、`ref/tamper_init.log` | 功能被改、布线不变的篡改位流及其构建日志 |

> Vivado 2017.2 在中文路径下会崩（`TclStackFree: incorrect freePtr`），
> 这些产物是在纯 ASCII 目录 `C:\Temp\tamper_ref` 里构建后拷回来的。

## 原始结果（JSON 都带 `bitstream` 与 `baseline` 字段，可直接对照）

| 文件 | 对应报告 | 内容 |
|------|----------|------|
| `ver_ref.json`、`ver_full8.json` | §4 | 解析式统计 vs 真翻转校验（120/120 一致） |
| `ex_ref.json`、`ex_full8.json` | §4 | 单 bit 穷举（128 列口径） |
| `exhaustive_ref_154col.json` | §4 | 单 bit 穷举（**154 列口径**：`ref` 1,633,808 次翻转，99.4438% 检出） |
| `atk_ref300_v2.json`、`atk_full8_v2.json` | §5.1/§5.2 | 128 列口径，**已作废见下** |
| `atk_ref300_154col_fixed.json`、`atk_full8_154col_fixed.json` | §5.1/§5.2 | 154 列口径 + 基线比对修正：幽灵 mux **0/300**、换源 **6.0%**（有共享格 15.2% / 无共享 0.5%） |
| `classes_ref300_154col.json` | §5.3/§5.4 | 154 列口径：整条 PIP 删除 8/300 = 2.67%、空槽添加 0/300、word50 0/300 |
| `delta_init_154col.json` | §5.5 | 154 列口径下 `ref` vs `tamper_init`：1,092 bit 差异、建模区 0 个 |
| `classes_ref_all.json`、`classes_full8_all.json` | §5.3/§5.4 | 穷举整条 PIP 删除/添加、word50 |
| `delta_init.json` | §5.5 | `ref.bit` vs `tamper_init.bit`：1,092 bit 差异、建模区 0 个 |
| `fpstats.txt` | §6.2 | 6 个干净位流的误报统计（含白名单前后） |
| `res_ref.json`、`res__*.json` | §4 汇总 | 各探针位流的穷举汇总 |
| `scan_all_probes.txt` | §3 | `E:\v7work` 下 34 个探针位流的不变量校验（0 违例） |

## superseded/（不要引用）

早期版本的结果，保留只为可追溯：

- `atk_ref300_154col.json`、`atk_ref300_154col.log` —— 检测器**未减基线**时跑出的数字
  （幽灵 mux 一度报 300/300 = 100%），成因见报告文末修订记录
- `atk_ref.json`、`atk_ref300.json`、`atk_ref300.log` —— 换源统计 bug 未修时的数字
  （29% / 49.6% / 15.9%），因复原时无条件写共享格、误差逐样本累积而虚高。
- `classes_ref.json`、`classes_ref300.json`、`classes_full8_300.json` —— 小样本（40/300）
  抽样版，检出率随机波动（1.67%–3.0%），已被穷举版 `*_all.json` 取代。
- `scan_34_probes.txt` —— 只扫到顶层 2 个文件（未递归），由 `scan_all_probes.txt` 取代。

## 复现

```bash
cd v7re/scripts
python tamper_localize.py --check ../../tamper/ref/ref.bit              # 基线: L1=234(白名单后0) L2=0
python tamper_localize.py --classes ../../tamper/ref/ref.bit --n 9000 --json ../../tamper/classes_ref_all.json
python tamper_localize.py --attack ../../tamper/ref/ref.bit --n 300 --seed 11 --json ../../tamper/atk_ref300_v2.json
python tamper_localize.py --check ../../tamper/ref/ref.bit --fpstats
python tamper_localize.py --check ../../tamper/ref/ref.bit --delta ../../tamper/ref/tamper_init.bit
python tamper_localize.py --coverage
```
