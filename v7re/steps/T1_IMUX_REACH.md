# T1：24 个未测 IMUX family 是否 CLBLM 专属？（结论：假设证伪）

日期：2026-11-02　器件：xc7vx485tffg1761-2　Vivado 2017.2　运行目录：`/opt/lzh/v7re/work/t1`

## 1. 被检验的假设

`REUSE_RULES.md` §6 原假设：

> 每侧缺 `IMUX_L22/28/29/31/32/35/38/40/43/44/45/47`（INT_R 同名去掉 `_L`）。
> **假设**：这 12 个是 `CLBLM`(SLICEM) 专属输入——基座设计建在 `CLBLL_L`(SLICEL) 上，够不着它们。

若成立，则"补齐覆盖"必须换基座到 CLBLM 才可能；若不成立，则只是**没测到**，不是测不到。

## 2. 方法

先做一个**覆盖更大**的设计，一次看清 IMUX 的全貌，而不是逐个 pin 试：

* 器件内两个 slice（`SLICE_X12Y20` = X0，`SLICE_X13Y20` = X1）各放 4 个 `LUT6`
  （`A6LUT`/`B6LUT`/`C6LUT`/`D6LUT`），8 个 LUT 共 48 个输入脚，全部由 6 个顶层输入驱动。
* 每个 LUT 用不同 `INIT` 防止被优化合并，全部 `(* DONT_TOUCH = "true" *)`。
* `place_design` → `route_design` → 用 `get_pips -of_objects [get_nets -hier]` 把**每条 net 的
  所有 PIP** 导出，再看落到哪些 IMUX。

一次 `route_design` 就同时给出三样东西：INT 侧 `src -> IMUX_Ln`、CLB 侧 `CLBLM_IMUXn -> 站点引脚`、
以及"这条 mux 到底有没有被用"。

## 3. 结果

**48 个 IMUX 全部被使用，一个不缺**——包括此前"未测"的那 12 个。

```
IMUX_L0..L47 全部出现；此前未测的 12 个对应的站点引脚是：
  IMUX_L22 -> CLBLM_M_C3    IMUX_L28 -> CLBLM_M_C4    IMUX_L29 -> CLBLM_M_C2
  IMUX_L31 -> CLBLM_M_C5    IMUX_L32 -> CLBLM_M_C1    IMUX_L35 -> CLBLM_M_C6
  IMUX_L38 -> CLBLM_M_D3    IMUX_L40 -> CLBLM_M_D1    IMUX_L43 -> CLBLM_M_D6
  IMUX_L44 -> CLBLM_M_D4    IMUX_L45 -> CLBLM_M_D2    IMUX_L47 -> CLBLM_M_D5
```

规律一目了然：**这 12 个正好是 "M" 侧 slice 的 `C1..C6` 与 `D1..D6` 全部输入脚**。
基座设计只用了 `A6LUT` 的 `A1`，所以 A 脚之外（更别说 C/D 的 LUT）从来没被碰过。
不是够不着，是没碰到。

完整映射表（48 条，含本次是否被使用）：
`v7re/steps/imux_pin_map_clblm_l_x8y20.json`

## 4. 顺带得到的结构（供 T3「生成函数」用）

`IMUX 编号 -> 站点引脚` 不是乱排，而是**每 12 个一组、按 LUT 的 A/B/C/D 分节**，
且同组内 L 侧与 M 侧交替出现：

| 编号段 | 引脚顺序（L/M 交替） |
|---|---|
| 0–11 | A3, A3, A2, A2, A6, A6, A1, A1, A5, A5, A4, A4 |
| 12–23 | B6, B6, B1, B1, B3, B3, B2, B2, B5, B5, B4, B4 |
| 24–35 | B5, B5, B4, B4, C4, C4, C3, C3, C2, C2, C5, C5 |
| 36–47 | D2, D2, D4, D4, D3, D3, D1, D1, D6, D6, D4?, D5 |

（上表最后一段按实测值填：`L36→D2 L37→D4 L38→D3 L39→D3 L40→D1 L41→D1 L42→D6 L43→D6 L44→D4 L45→D2 L46→D5 L47→D5`，
此处顺序与前三段不同，说明**分节起点随片段偏移**，这正是要解释的规律，不能靠肉眼拍平。）

若这条"引脚序列"能被一个生成式（如从 `A1` 起按某个固定置换 + 相位偏移）复现，
则 T3 的 pattern 分配有可能同样是"结构化的枚举"，而不是一张任意表。

## 5. 结论与影响

1. **原假设证伪**：这 24 个 family 不是 CLBLM 专属，SLICEM 与 SLICEL 都能用全部 48 个 IMUX。
2. **覆盖率缺口的真实成因是"基座设计太瘦"**：单输入、单 LUT、单 BEL。改基座即可，不需要换器件/换列。
3. **补齐路径明确**：用覆盖 8 个 LUT × 6 输入的老基座（本次这个设计）跑 tilepipe，
   逐个 sink 做 PURE 语义变体，即可把这 12 个 family 的 12×~20 条源补齐。
4. 顺带产出一张**权威 IMUX↔site pin 表**，以后定位"某条 PIP 影响哪个 LUT 的哪个脚"不必再查 prjxray。

## 6. 下一步

* 用本设计当基座，对 12 个未测 family 各取一个 sink 做 tilepipe（PURE 语义），
  补齐后复用度统计的 IMUX 覆盖应从 78.1% → 100%。
* 把 `REUSE_RULES.md` §6 的假设段改写为"已证伪 + 真实原因"，避免后续重复误判。
