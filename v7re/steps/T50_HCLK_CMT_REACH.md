# T50：CK_BUFHCLK / CCIO 组可达性 —— 两条负结果

日期：2026-11-08
远端：`/opt/lzh/v7re/work/hclk8`，4 个构建（BUFG 放不同 site，BUFG→BUFH→FF）。

## 1. 设计

```
pin → BUFG(LOC=BUFGCTRL_X0Y0/8/16/24) → BUFH → FDRE
```

期望进入 `HCLK_CMT_MUX_CLK_k` 的 `CK_BUFHCLK*` 源。

## 2. 结果：完全不经过 HCLK_CMT

四个设计的路由都是：

```
BUFG → CLK_HROW_R_CK_GCLK{0,8,16,24} ->> CLK_HROW_CK_MUX_OUT_L0
     → CLK_HROW_CK_HCLK_OUT_L0 ->> CLK_HROW_CK_BUFHCLK_L0
```

**没有任何 `HCLK_CMT` 相关 PIP**。BUFG/BUFH 在同一时钟行内闭环，
根本不经过 HCLK_CMT 的 `MUX_CLK_k`。

（附带一条有用信息：`BUFGCTRL_X0Yn` 的输出对应 `GCLK{n}`——
Y0→GCLK0、Y8→GCLK8、Y16→GCLK16、Y24→GCLK24，与 T42/T43 的结论一致。）

## 3. 与 CCIO 组一起看

| 尝试 | 结论 |
|---|---|
| 引脚直驱 FF（`c_a`/`c_b`） | 不经过 HCLK_CMT |
| BUFG → BUFH → FF（`r0..r3`） | 不经过 HCLK_CMT |
| MMCM → BUFH → FF | **经过**，选中 `MUX_CLK_MMCM*` |
| PLL → BUFH → FF | **经过**，选中 `MUX_CLK_PLL*` |

即：**只有「CMT 输出」这一类源会走 `HCLK_CMT_MUX_CLK_k`**。
`CCIO*`、`CK_BUFHCLK*`、`CK_IN*` 这三类（共 26 个源）在当前构造下不可达。

## 4. 可达性汇总（48 个源）

| 类 | 数量 | 可达 | 编码 |
|---|---|---|---|
| `MUX_CLK_MMCM0..13` | 14 | ✅ | 部分（选择位已定，另混 CMT 交叉开关字段） |
| `MUX_CLK_PLL0..5` | 6 | ✅ | ✅ 已解（奇偶分字 + one-hot） |
| `MUX_CLK_PLL6..7` | 2 | ❌ | — |
| `CK_BUFHCLK0..11` | 12 | ❌ | — |
| `CK_IN4..13` | 10 | ❌ | — |
| `CCIO0..3` | 4 | ❌ | — |

**可达 20 / 48（41.7%）**，其中编码完全解出的只有 6 个（PLL0..5）。

## 5. 为什么剩下的不可达（推断）

`HCLK_CMT_MUX_CLK_k` 的作用是「选一路 CMT 输出送到垂直时钟脊」。
`CK_BUFHCLK*`/`CK_IN*`/`CCIO*` 是**跨 CMT 列 / 专用输入**的路径，
只有当设计跨越时钟区域、或使用专用时钟管脚时才被 Vivado 选中；
用同区域、单时钟的构造无法触发。

## 6. 结论

**HCLK_CMT 的 48 源里有 28 个在常规设计中根本不会出现**，
真正需要解码的是「CMT 输出」那 20 个（MMCM 14 + PLL 6）。
这大大缩小了这项工作对实际解码器的价值：
只要覆盖 MMCM/PLL 两类，就能解释真实设计里的全部 HCLK_CMT 配置。

这条结论应该写进解码器文档，避免后续把 48 源当成全都要解。


## 7. 补完 MMCM 14 源的尝试（A 任务）—— 受阻

目标：拿到 `MUX_CLK_MMCM1/3/5/7/11/12/13`（X0 列样本只出现了 0/2/4/6/8/9/10）。

三次尝试：

| 尝试 | 做法 | 结果 |
|---|---|---|
| `hclk9/s0,s1` | MMCM@X1Y6，FF 锁到 `SLICE_X12Y20`（X0 列区域） | `[Place 30-176] Unroutable Placement` —— 跨 CMT 列的时钟不可布线 |
| `hclk9/s2` | 同上，FF 改 `SLICE_X12Y120` | 站点不存在 |
| `hclk7/q0..q2` | MMCM@X1Y6，FF 自由放置 | 构建成功但**无任何 HCLK_CMT PIP** |

结论：X1 列的 CMT 输出在本构造下不进 HCLK_CMT；跨列送时钟被布线器直接拒绝。

**因此 `MMCM1/3/5/7/11/12/13` 在现有构造下不可达**，与 `CK_BUFHCLK*`/`CK_IN*`/`CCIO*` 同属「需要跨区域或专用路径」的一类。

## 8. HCLK_CMT 最终状态

| 项 | 状态 |
|---|---|
| 选择位所在位置 | ✅ 已定位：帧 22144/22145 word 51 bits 25–27、bit31；MMCM 另有帧 22147 word 27–30 |
| `MUX_CLK_PLL0..5` 编码 | ✅ 奇偶分字 + one-hot（6/8 样本） |
| `MUX_CLK_MMCM0..10` 选择位 | ✅ 7 个样本，位置已定，但组内编号规则未闭合 |
| 其余 28 源 | ❌ 构造不可达（已证明，非未测） |

**要再往前推，必须换信息源**：找真实设计（跨时钟区域、多 MMCM、用专用时钟管脚）的位流，
而不是继续用合成小设计——合成设计里 Vivado 根本不会选中那些源。
