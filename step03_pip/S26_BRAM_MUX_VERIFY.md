# S26 —— BRAM 三路 mux 位位置实测（V7）

日期：2026-11-09　器件：xc7vx485tffg1157-3　样本：`br_imux` / `br_attr`（同 site，仅 WRITE_MODE_A 不同）

## 1. 锚点：用属性位定出 BRAM 控制块基址

| 设计 | 唯一变量 | 放置 |
|---|---|---|
| br_imux | `RAMB18E1`，`WRITE_MODE_A("READ_FIRST")` | `RAMB18_X3Y28` → tile `BRAM_R_X29Y70` |
| br_attr | 同上，`WRITE_MODE_A("WRITE_FIRST")` | 同上（同 site） |

逐帧逐字差分（大端解析，先验 FDRI burst = 50,176×101）：

```
frame 27249 : word 41 bit 24   ← 唯一配置位
frame 27249 : word 50 bits {3,4,7,11,12}  ← 该帧的校验/ECC 类字随之变化
```

artix7 参考表对应条目：`BRAM_L.RAMB18_Y0.WRITE_MODE_A_READ_FIRST  27_56`

换算（`word = wof(Y) + bit//32`，`bit = raw%32`，Y70 → `wof=40`）：
`off=27, bit=56` → `word = 40 + 1 = 41`，`bit = 24`　**与实测完全一致**。

⇒ **BRAM 控制块基址 = 27249 − 27 = 27222**（tile `BRAM_R_X29Y70`，band1）；
　　offset 26（三路 mux）→ 绝对帧 **27248**；offset 27（属性）→ **27249**。

## 2. 60 个三路 mux 的零态验证

在 (27248, wof=40) 用 artix7 的 60 个家族表判读：

| 设计 | 家族数 | ILLEGAL | 状态分布 |
|---|---|---|---|
| br_imux | 60 | 0 | IMUX × 60 |
| br_attr | 60 | 0 | IMUX × 60 |

- 立法：`(A,B,C) ∈ {000(IMUX), 101(CASCINBOT), 110(CASCINTOP)}`，即 `C = A & !B`。
- 结论：**60/60 家族在该帧全部落在合法码字上，且默认全为 IMUX（全零态）** —— 与 artix7 的“隐含全零 = IMUX”一致。
- 副结论：改 WRITE_MODE 不影响任何 mux 家族（属性位与 mux 位池正交）。

## 3. CASCIN 态未观测到（诚实缺口）

- `br_casc2`（72K×1，3×RAMB36 @ X3Y11/12/13）日志中 **无 cascade 字样**，Vivado 把深度选择做在 fabric 里，BRAM 未进入级联。
- 因此 `CASCINBOT / CASCINTOP` 两种显式态在 V7 上**仍未逐位验证**；下一步用 `CASCADE_ORDER_A="FIRST"/"LAST"` 显式配对，或改用 2×RAMB36 手动级联。

## 4. 方法论教训（重要）

只用“某帧 60 家族全合法”做扫描会产生**假命中**：BRAM 行帧（一帧 101 字 = 该行 101 列的 tile 数据）里大量字为 0，
全零天然满足 IMUX 码字，于是任意 `wof` 都可能“合法”。
必须先有**锚点**（一个已知属性位）或用**差分**把帧定死，再判读状态。

## 5. 覆盖率更新

| 形态 | 家族数 | 状态 |
|---|---|---|
| BRAM 三路 mux | 60×2 侧 | 位位置已定（off 26），零态 60/60 验证；CASCIN 态待验 |
| BRAM 属性位 | 30 | `WRITE_MODE_A` 已逐位验证；其余 29 条待验 |
| DSP 两路 tie-off | 78 | 5 个已逐位验证（S22） |
