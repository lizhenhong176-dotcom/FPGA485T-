# T73：HCLK_CMT CLKIN1 源编码定形（类别 + 参数）

日期：2026-11-10　器件 `xc7vx485tffg1157-3`　远端 `/opt/lzh/v7re/work/clkin2`，本地 `_ck2/`

## 1. 六个对照设计（6 建 5 成）

统一骨架：`pin → IBUF → [BUFHCE 或 BUFG] → MMCME2_ADV_X0Y6.CLKIN1`，
MMCM `CLKFBOUT_MULT_F=10`、`CLKOUT0_DIVIDE_F=10`，FDRE 锁 `SLICE_X0Y349`（与 CMT 同 region），
`CLOCK_DEDICATED_ROUTE FALSE` 加在 `clk/clk2/ck` 三条网，显式 `-part xc7vx485tffg1157-3`。

| tag | 引脚 | 中间级 | 结果 |
|---|---|---|---|
| `t1_direct` | `C27` | 无（直连 CLKIN1）| ❌ `[Common 17-55]`（`get_nets -hier clk2` 不存在）|
| `t2_bh72_c27` | `C27` | `BUFHCE_X0Y72` | ✅ |
| `t3_bh77_c27` | `C27` | `BUFHCE_X0Y77` | ✅ |
| `t4_bh72_e27` | `E27` | `BUFHCE_X0Y72` | ✅ |
| `t5_bh72_c28` | `C28` | `BUFHCE_X0Y72` | ✅ |
| `t6_bufg_c27` | `C27` | `BUFG` | ✅ |

每份 `.pips` 的 HCLK_CMT 边确认了变量确实生效：

```
t2: CCIO0 ->> MUX_CLK_13    CK_BUFHCLK0 ->> MUX_MMCM_CLKIN1
t3: CCIO0 ->> MUX_CLK_13    CK_BUFHCLK5 ->> MUX_MMCM_CLKIN1
t4: CCIO1 ->> MUX_CLK_13    CK_BUFHCLK0 ->> MUX_MMCM_CLKIN1
t6: CCIO0 ->> MUX_CLK_0     CK_BUFHCLK0 ->> MUX_MMCM_CLKIN1
```

## 2. 差分（CMT 簇帧 22144–22149）

| 对比 | 变量 | 总差 | 簇内差 | 簇内格 |
|---|---|---|---|---|
| `t2` vs `t3` | BUFHCE 槽位 0 → 5 | 10 | **2** | `(22146,48,26)` → `(22147,48,23)` |
| `t2` vs `t4` | CCIO 0 → 1 | 24 | 6 | `(22144,49,28/31)(22144,51,27)(22145,49,29/31)(22145,51,27)` |
| `t2` vs `t5` | CCIO 0 → 2 | 24 | 6 | `(22144,51,29)(22145,49,29/30/31)(22145,51,28)(22146,51,25)` |
| `t2` vs `t6` | 类别 BUFHCLK → BUFG | 43 | 8 | `(22144,51,27/29)(22145,49,21/23/25/26)(22147,49,21/26)` |

**槽位隔离干净到只有 2 格**，且正好是 T71 测到的 `s0=(22146,26)`、`s5=(22147,23)` —— 独立复核成立。

## 3. CCIO 索引 = 2 位二进制（8/8 命中）

把类别（CCIO）与槽位（BHF0）固定，只变 CCIO 索引，读 `(簇帧+1, word 51)`：

| 引脚 | CCIO | bits @ `(base+1,51)` | bit27 | bit28 |
|---|---|---|---|---|
| `C27` | 0 | `[]` | 0 | 0 |
| `E27` | 1 | `[27]` | 1 | 0 |
| `C28` | 2 | `[28]` | 0 | 1 |
| `C30` | 3 | `[27,28]` | 1 | 1 |
| `F11` | 0 | `[]` | 0 | 0 |
| `E11` | 1 | `[27]` | 1 | 0 |
| `H10` | 2 | `[28]` | 0 | 1 |
| `G11` | 3 | `[27,28]` | 1 | 1 |

**8/8 精确**，且两个 CMT 列（簇帧 22144 与 25090）**同一套位**：

```
CCIO 索引 = (bit @ (base+1, 51, 27)) | (bit @ (base+1, 51, 28) << 1)
```

这是 HCLK_CMT 里第一个完全定形、可读可写的字段。

## 4. 汇总模型

`MUX_MMCM_CLKIN1` 的选择编码分两部分：

| 部分 | 位置 | 已定形？ |
|---|---|---|
| 源类别 | word 48（CCIO 置 `+22`；BUFHCLK 置槽位位）| 3 类样本（CCIO / BUFHCLK / BUFG），未逐一解位 |
| 类内参数 | CCIO：`(base+1,51,27/28)` 2 位二进制<br>BUFHCLK：`(base+2,48,21/26)` 6 槽位 one-hot × 半区 | CCIO **已定形 8/8**；BUFHCLK 见 T71 |

## 5. 未解项（诚实边界）

- 类别字段本身用哪些位区分（`(2,48,22)` 之于 CCIO、`(2,48,21/26)` 之于 BUFHCLK、`t6` 的 `(1,49,23/25/29/31)+(3,49,21/26)` 之于 BUFG）—— 3 类样本不足以给出位定义；
- CCIO 0..3 各自还带一组「非索引」格（如 `(22144,49,28)`、`(22146,51,25)`），本轮未归属；
- `t1`（直连）失败，直连类别未测。

## 6. 复现

```bash
export LANG=C LC_ALL=C          # 必须在 shell 里，不能写进 .tcl
cd /opt/lzh/v7re/work/clkin2
ls *.tcl | sed 's/.tcl//' | xargs -P 6 -I{} sh -c \
  '/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source {}.tcl > {}.log 2>&1'
```
