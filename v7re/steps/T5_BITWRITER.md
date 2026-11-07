# T5 v1：由 PIP 列表写出配置位（mux 区）

日期：2026-11-02
脚本：`v7re/scripts/bitwriter.py`
输入：`_full8.bit`（真实位流）、`_full8.pips`（Vivado 路由导出）

## 0. 一句话结论

把位流里 `INT_L_X8Y20` 等 9 个 tile 的 mux 区**清空**，只用 PIP 列表按定律重写，
**往返差异位 = 0**（9/9 tile PASS，共 52 条 PIP）。即：mux 区可以由 PIP 列表**生成**，
不再只能读。

## 1. 能力边界（v1 明确声明）

| 支持 | 不支持 |
|---|---|
| 帧 16–25 的 64 个网格族（`IMUX_L0..47`、`BYP_ALT0..7`、`FAN_ALT0..7`） | 帧 0–15 的 12 个时钟/控制复合码族 |
| 由 `pip_reuse_law.json` 的定律算地址与位 | 帧 2–7 的 32 个 BEG6/4 族（仍走查表） |
| 只写 `sense=1` 位 | CLB 内部特征位（LUT INIT / FF 等，见 `site_frames`） |

## 2. 自检方法（往返）

```python
before = 该 tile 帧 16..25 的位图
clear_region(...)        # 清零
write_pips(...)          # 只用 PIP 列表重写
assert before == after   # 逐位比对
```

结果：

| tile | PIP 数 | 未知源 | 往返差异位 |
|---|---|---|---|
| `INT_L_X8Y20` | 52 | 0 | **0** |
| `INT_L_X32Y6..13` | 各 1–2 | 0 | **0** |
| 合计 | 9 个 tile | 0 | **0** |

## 3. 为什么这算「能写」

往返测试的强度在于：**清空之后再重建**。如果定律有任何一位算错，
清空后的重写就不可能和原始位图逐位相同（52 条 PIP、每条 2–4 格，任何错一位都会暴露）。
它同时验证了：

* 地址公式（帧/字/位）在真实位流上成立；
* 每条 PIP 的 pattern 与 `sense` 语义正确；
* 多 PIP 同时写入不互相污染（与 T4 一致）。

## 4. 还不能宣称的

* **没有做「新设计生成」的端到端验证**：没有把这些位写进空位流再交给 Vivado/硬件比对，
  因为那需要真实器件加载或 Vivado 的等价性检查。当前证据是「与 Vivado 产出的位图逐位一致」，
  这已足够证明映射正确，但不等于「任意 PIP 组合都能被器件接受」。
* **时钟网络写不了**：12 个时钟/控制族仍是复合码，任何用到 BUFG/时钟选择的设计
  必须退回查表（`law_cells`）。

## 5. 复现

```bash
python v7re/scripts/bitwriter.py --selftest --bit _full8.bit --pips _full8.pips
```

## 6. 下一步

1. 把 `bitwriter` 的 `write_pips()` 接进 FASM 管线的输出端，先覆盖网格族；
2. 用 M2 语料的 6 组成对位流做**跨设计**验证（每条差异应当等于对应 PIP 的 pattern）；
3. 补齐时钟/控制族的仪器化实验，然后写入器才能覆盖完整 tile。


## 7. 时钟/控制族实验（2026-11-02 追加）

之前把帧 0–15 的 12 个族记为“复合码、未闭合”。做了 6 个时钟实验设计后，
结论要改：**这 12 个族可以被 law_cells 正确解释，且已在 V7 上实测验证**。

### 7.1 实验设计

远端 `/opt/lzh/v7re/work/clk/`，同一个 FF（`SLICE_X12Y20/AFF`），只改时钟/控制来源：

| 设计 | 时钟 | CE | 复位 |
|---|---|---|---|
| c0 | BUFG(clk) | 1 | 0 |
| c1 | BUFG(clk2) | 1 | 0 |
| c2 | 直连引脚（无 BUFG） | 1 | 0 |
| c3 | BUFG(clk) | ce | 0 |
| c4 | BUFG(clk) | 1 | r（同步 R） |
| c5 | BUFG(clk) | 1 | r（FDSE 的 S） |

### 7.2 结果：路由与位一一对上

以 c0 为例，Vivado 的路由链是：

```
GCLK_L_B11 ->> GCLK_L_B11_WEST ->> CLK_L1
CLBLM_CLK1 -> CLBLM_M_CLK
```

用 `law_cells` 检查该 tile，**唯一完全满足的族就是 `CLK_L1 / GCLK_L_B11_WEST`**，
且 16 个候选源里只有这 1 个满足（无歧义）。

c4（同步复位）的路由：

```
r_IBUF ... WW4END1 ->> GFAN0 ->> CTRL_L1 ;  CLBLM_CTRL1 -> CLBLM_M_SR
```

检查结果同样精确：**`CTRL_L1 / GFAN0` 与 `GFAN0 / WW4END1` 两条同时满足**。

c3（CE）走的是 `WR1END2 ->> FAN_ALT7 ->> FAN_L7` → `CLBLM_FAN7 -> CLBLM_M_CE`，
落在 mux 区（帧 16–25）的 `FAN_ALT7` 上，已被定律覆盖。

### 7.3 往返自检扩展到帧 0–25

给 `bitwriter.py` 加了 `--with-table`（非 mux 区走 `law_cells`）与 `--frames 0:26`：

| 设计 | tile PASS | FAIL | 失败 tile 的差异位 |
|---|---|---|---|
| c0 / c1 / c2 | 20 | 1 | 1 |
| c4 | 26 | 1 | 1 |
| c3 / c5 | 29 / 26 | 1 | 2 |

失败的永远是 `INT_L_X8Y20`（即带时钟路径的那个 tile），差异位固定落在
**帧 0 / 字 parity 1 / 位 16**。

### 7.4 差异位的归属：GCLK 直通族不在表里

反查 `law_cells`（全部 tile_type）：**没有任何一行使用 (帧 0, 位 16, parity 1)**。
而它在 c0/c2/c4 里只在 `INT_L_X8Y20` 为 1，`INT_L_X32Y*`、`INT_R_X9Y20` 都是 0 ——
说明它是**该 tile 上“GCLK 线被接入”的那一位**，对应路由 `GCLK_L_B11 ->> GCLK_L_B11_WEST`。

即：prjxray 的 INT 表覆盖了 172 个 family，但**没有覆盖 INT tile 内的 GCLK 直通族**
（`GCLK_L_B0..B11`）。这就是时钟路径往返差 1–2 位的唯一原因。

把 BUFG 约束到不同 site（c6/c7/c8：`BUFGCTRL_X0Y8/16/24`）后，路由**仍然是 GCLK_L_B11** ——
因为 GCLK 编号由 slice 所在列决定，不由 BUFG 位置决定。要换 GCLK 源，
需要把 FF 放到不同的列区域。

### 7.5 更新后的能力边界

| 区域 | 状态 |
|---|---|
| 帧 16–25 的 64 个网格族 | 定律（可算） |
| 帧 0–15 的 12 个时钟/控制族 | **law_cells 查表，已实测验证**（CLK_L1 / CTRL_L1 / GFAN0） |
| INT tile 内 GCLK 直通族 | **缺失**（每 tile 1 位，位置已知：帧0/parity1/bit16） |
| CLB 内部特征位 | 走 `site_frames` |


## 8. GCLK 直通位：定位与验证（2026-11-02）

### 实验

| 设计 | 做法 | 结果 |
|---|---|---|
| g1–g4 | FF 换列（`SLICE_X20Y20/X40Y20/X60Y20/X68Y20`） | GCLK 源恒为 `GCLK_L_B11`，只是 WEST/EAST 变体不同 |
| d2 | 双时钟（`SLICE_X8Y20` 用 clk、`SLICE_X48Y20` 用 clk2，两个 BUFG） | 仍在 `GCLK_L_B11`，两块 tile 位图案完全相同 |

结论：Vivado 在该器件上恒定把 GCLK 路由到 **B11 脊线**，用设计变换**无法**测出 B0–B11 各自的位。

### 但位结构是确定的

三个有代表性的设计（`c0` 单时钟、`g1` 换列、`d2` 双时钟）里，时钟所经的那个 INT tile
帧 0/1 的置位图案**完全一致**：

```
帧0 par0 = [27]
帧0 par1 = [16]        <- 多出来的这一位
帧1 par0 = [25, 26, 29]
```

其中 par0 的位和帧 1 的位都能被 `CLK_L1 / GCLK_L_B11_WEST` 定律 cell 解释，
**唯一多出的就是 `(frame_off=0, bit=16, parity=1)`**，且对 WEST/EAST、INT_L/INT_R、
单/双时钟、换列全部一致。

### 判定

`(0,16,par1)` 不是“GCLK 线号编码”，而是**每个 tile 一位的 “GCLK 接入使能”**：
线号本身已经由 `CLK_L1 / GCLK_L_B11_WEST` 的定律 cell 表达，这一位只表示“本 tile 有时钟从 GCLK 网络进来”。

### 代码

`v7re/scripts/bitwriter.py` 新增：

```python
GCLK_PASS_BIT = (0, 16)     # (frame_off, bit)，parity 固定 1
# write_pips() 内：
if fam.startswith("GCLK_L_B"):
    M[base + GCLK_PASS_BIT[0], word_of(y, 1), GCLK_PASS_BIT[1]] = 1
    ok += 1
    continue
```

### 补丁后往返结果

| 设计 | 结果 |
|---|---|
| c0 / c1 / c2（单时钟，BUFG / 第二时钟 / 直连引脚） | **21 / 21 / 21 tile 全 PASS，0 差异** |
| d2（双时钟） | **27 / 27 tile 全 PASS，0 差异** |
| c3（CE=ce）/ c4（同步 R）/ c5（FDSE S） | 29 / 26 / 26 PASS，各 **1 位**未解释 |

### 残留的 1 位

| 设计 | 残留位 | `law_cells` 中的归属 |
|---|---|---|
| c3 | `(帧1, word41, bit7)` | **0 条候选** |
| c4 / c5 | `(帧1, word41, bit3)` | **0 条候选** |

这两个格在 prjxray 的 INT 表里根本不存在，与 GCLK 位同类：属**表外族**，
出现在 tile 用了 bounce 线驱动的 `BYP_ALT` / `FAN_ALT`（`BYP_L1`、`BYP_BOUNCE0`、`FAN_L7`）时。

相关性扫描（c0/c3/c4/c5/d2/full8 六份位流 × 各自路由）：

```
c0、d2：帧1 par1 无置位        （没有 bounce 驱动的 BYP/FAN）
c3    ：帧1 par1 = [7]         BYP/FAN = FAN_ALT7←FAN_L7, BYP_ALT1←BYP_L1
c4/c5 ：帧1 par1 = [0,3,4,9]   BYP/FAN = BYP_ALT0←BYP_BOUNCE0, BYP_BOUNCE0←BYP_ALT1, BYP_ALT1←BYP_L1
```

即该位**只在 tile 内确实用到了 bounce 旁路时才出现**，性质与 GCLK 使能位相同（每 tile 一位），
但目前无法把位 3 与位 7 分别归给 BYP_ALT 与 FAN_ALT —— 需要专门的旁路仪器化实验（尚未做）。

### 能力边界（更新）

| 区域 | 状态 |
|---|---|
| mux 区 64 族（帧 16–25） | 可写、可读、可逆，往返 0 差异 |
| BEG6/4 32 族（帧 2–7） | 定律已知（K(4,5)），写入器尚未接入 |
| 时钟族 CLK_L1 / CTRL_L1 等 | 走 `law_cells` 查表可写 |
| GCLK 直通使能 | **已定位 `(0,16,par1)` 并接入** |
| BYP/FAN bounce 旁路 | 差 1 位（帧1 位 3 / 位 7），未接入 |


## 9. 残留位的性质：b1 反证实验（2026-11-02）

c3/c4/c5 各差 1 位，位在 `(帧1, word41, bit7)` / `(帧1, word41, bit3)`，`law_cells` 中无归属。
为判断它到底属于 `FAN_ALT` 还是 `BYP_ALT`，专门造了 b1：

```
b1: LUT la(SLICE_X12Y20/A6LUT) -> FDRE ff -> LUT lb(SLICE_X13Y20/A6LUT).I0 -> o
路由：a3: WW2END3 ->> FAN_ALT3 ->> FAN_BOUNCE3 ->> IMUX_L5
      a4: NL1BEG_N3 ->> FAN_ALT1 ->> FAN_BOUNCE1 ->> IMUX_L4
      o : EE2END0 ->> BYP_ALT0 ->> BYP_BOUNCE0 ->> IMUX_L34
```

**b1 里 FAN_ALT、BYP_ALT 都用了，但帧 1 par1 一位都没有置位。**

对照 c3/c4 的路由：

```
c3: ce_IBUF: WR1END2 ->> FAN_ALT7 ->> FAN_L7       (FAN_L7 进 CLB 的 CE 脚)
    d_IBUF : WW2END0 ->> BYP_ALT1 ->> BYP_L1       (BYP_L1 进 CLB 的 D 脚)
c4: d_IBUF : WW2END_N0_3 ->> BYP_ALT0 ->> BYP_BOUNCE0 ->> BYP_ALT1 ->> BYP_L1
    r_IBUF : WW4END1 ->> GFAN0 ->> CTRL_L1
```

差别很明确：

* **b1**：FAN_ALT / BYP_ALT 的输出走 `FAN_BOUNCE*` / `BYP_BOUNCE*` 再进 **IMUX（tile 内的 LUT 输入）** —— 帧 1 干净；
* **c3/c4**：FAN_ALT / BYP_ALT 的输出走 `FAN_L7` / `BYP_L1` 进 **CLB 站点引脚（CE / D）** —— 多出 1 位。

## 10. 判定（当前可下的最强结论）

`(帧1, par1, bit7)` 与 `(帧1, par1, bit3)` 不是「BYP_ALT 族 / FAN_ALT 族的选通位」，
而是**「旁路网络把信号送到 CLB 站点引脚」这一路本身的标记位**，prjxray 的 INT 表未覆盖它。

* 它们只在 **FAN/BYP 的多跳链最终落到站点引脚（CE / SR / D）** 时出现；
* 同一份位流里，同一 tile 同时有 CE-via-FAN 与 D-via-BYP（c3）却**只多出 1 位**（bit7），
  说明这类位是按「哪条多跳链、几跳」编码，而不是按目标站点引脚编码；
* c4 的两跳 BYP 链（`BYP_ALT0 ->> BYP_BOUNCE0 ->> BYP_ALT1 ->> BYP_L1`）给出 bit3，与 c3 的单跳链不同。

要把它拆干净，需要专门造「CE 只经单跳 FAN」与「CE 只经双跳 FAN」的对照设计；
在那之前，写入器对这类设计保持「已知差 1 位」的诚实声明，不用猜测去填。

## 11. 写入器当前能力（最终态）

| 设计类型 | 往返结果 |
|---|---|
| 纯 LUT / FF，时钟走 GCLK（c0/c1/c2/d2） | **100% PASS，0 差异** |
| LUT + FF + CE/SR 经 FAN/BYP 多跳链（c3/c4/c5） | 26–29 tile PASS，**各差 1 位** |
| 所有 tile 的对照（9 tile 首轮） | 9/9 PASS |
