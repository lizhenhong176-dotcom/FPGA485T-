# 路由选择（routing selection）——编码形态总表

> 范围声明：只讲**路由选择**，即"某个 mux 的输出连到哪根源线"这件事在配置位里怎么编码。
> 不涉及 LUT INIT、FF 属性、IOB 电气属性（DRIVE/SLEW/PULLTYPE）、BRAM 内容。
> 设备 xc7vx485tffg1157-3，数据来源分三档标注：
> 【实测·本项目】/【迁移·artix7 表 + V7 结构验证】/【未验】。

## 1 一个 tile 块里，选择位住哪儿

| 块类型 | 帧数 | 位池 | 选择位所在 offset | 说明 |
|---|---|---|---|---|
| INT_L / INT_R | 28（26 数据 + 2 overhead） | 1,664 位 | **16..25** | 640 位全被 172 个 mux 家族占满 |
| CLBLL / CLBLM | 36（34 + 2） | 2,176 位 | **16..25** | 同一段承载 IMUX（site 边界选择）+ 本站 CLB 输出 mux |
| BRAM | 28 | — | **26**（依 artix7 表；V7 未验） | 60 个三路 mux 全部集中在 offset 26 |
| DSP | 28 | — | **26 + 27** | 78 个两路 mux（GND/VCC tie-off） |
| LIOB18 / LIOI / IO_INT_INTERFACE | 28 | — | **无选择位** | S23 实测：24/24、10/10 全单源；LIOI 30 个多源家族全是时钟 |

地址律（INT/CLB 已实测，BRAM/DSP 部分验证）：

```
cell_frame = block_base + frame_off
word       = wof(Y) + parity ,   wof(Y) = 2*(Y%50) + (1 if (Y%50)>=25 else 0)
bit        = raw_bit % 32
```

`Y` 取 **tile 名的 Y**（不是 grid_y）；`parity` = artix7 表里 `bit//32`；`block_base` 由 `clb_blocks(grid_col, band)` 或夹缝规则（西侧 CLB +36/+68、下一 CLB −28）给出。

## 2 四种编码形态（这是"路由选择"的全部）

### 形态 A：INT 分级 one-hot（多级 mux）【实测】

- 家族 = `(tile_type, 目标 wire)`；家族内 N 个源共用一个 k 位位池，**跨族零共享**（1,598/1,598）。
- `N = a × b` 且 `k = a + b`（不是 `ceil(log2 N)`）——两级 mux 各一级 one-hot。
- 每个源恰置 2 位（5,640 源）或 4 位（1,632 源，两级同时选通）；默认源常为全零。
- 五类形状（344 家族/双侧）：`(k=9,N=20,4×5)×192`、`(10,24,4×6)×128`、`(8,16)×12`、`(7,12,3×4)×8`、`(9,18,3×6)×4`。
- 反解：候选 = `{ones ⊆ 观测 且 zeros ∩ 观测 = ∅}`；单 PIP 唯一（181/181），多 PIP 需联合 CSP（9 网互斥、覆盖 98/181，1.8 s）。

### 形态 B：site 边界 IMUX（一热选择进 BEL）【实测】

- 每个 slice 实例 24 个 IMUX，位表按**实例形态**迁移（inst0 ← slice X8 表，inst1 ← slice X9 表），与 tile_type 无关：
  `SLICE_X8Y11` 回放 6/6 exact+unique；`CLBLM_R_X31Y51` 的 `SLICE_X47Y51` 2/2 exact+unique。
- 位池同样在 16..25。每源 2–4 位。

### 形态 C：BRAM 三路 cascade 选择【迁移·待 V7 验证】

- artix7 表：`BRAM_L/R` 各 60 个三路 mux，**全部在 offset 26**，每 mux 三源恒为
  `{CASCINBOT_*, CASCINTOP_*, IMUX_*}`。
- 编码是**三态 one-hot**：

```
CASCINBOT : 26_32=1  26_33=0  26_35=1
CASCINTOP : 26_32=1  26_33=1  26_35=0
IMUX      : 26_32=0  26_33=0  26_35=0     ← 隐含全零态
```

- 与形态 D 同构（都是"两胞 + 隐含零态"）。
- V7 差异：源名带器件前缀（`BRAM_RAMB18_*` / `BRAM_R_IMUX_*`），名字不能直接搬，**位位置与编码形态可搬**。

### 形态 D：DSP 两路 tie-off 选择【实测 5/78】

- `DSP_L/R` 各 78 个两路 mux，源恒为 `{DSP_GND_L, DSP_VCC_L}`，位在 offset 26/27。
- V7 实测（5 个家族，逐位与 artix7 表一致）：

| 家族 | GND | VCC | 走线 |
|---|---|---|---|
| `DSP_0_D0` | (26,w2,b1) | (27,w2,b0) | 两胞全 0 |
| `DSP_0_CEAD` | (26,w1,b31) | (27,w1,b30) | 全 0 |
| `DSP_0_RSTD` | (27,w3,b0) | (27,w2,b21) | 全 0 |
| `DSP_0_D1` | (27,w2,b4) | (27,w2,b10) | 全 0 |
| `DSP_0_INMODE0` | (27,w4,b6) | (27,w4,b2) | 全 0 |

- 另有 560 个单源家族（`DSP_IMUXk_m → DSP_0_Xx`）= always-on 固定连线，**无配置位**（旁证：换 IOB 引脚后 DSP 配置帧 0 差异）。

## 3 覆盖度（只看路由选择）

| 部件 | 家族数 | 位位置 | 编码形态 | 状态 |
|---|---|---|---|---|
| INT_L / INT_R | 172 ×2 | 16..25 | A | ✅ 实测 + 写回 864/864 + 6/6 token 级走线复原 |
| CLB IMUX（site 边界） | 24 ×2 ×每 slice 实例 | 16..25 | B | ✅ 实测（CSP 唯一解 6/6 + 2/2） |
| CLB 输出 mux（LOGIC_OUTS→BEG） | 48/slice | 16..25 | A | ✅ 实测（真值表 147 条含 0 冲突） |
| IO 入口（IOI/IO_INT_INTERFACE/LIOB） | 24/10/0 | — | 固定连线 | ✅ 实测无位 |
| BRAM 输入选择 | 60 ×2 | 26 | C | ⚠️ 结构已定，V7 位位置未逐位验 |
| DSP tie-off | 78 ×2 | 26/27 | D | ⚠️ 5/78 逐位验证 |
| DSP 输入（fabric→DSP） | 560 单源 | — | 固定 | ✅ 无位（实测） |
| 时钟（HCLK/BUFG/CLK_FEED） | ~300 源 | ? | ? | ❌ 未测 |

## 4 结论（一句话）

**路由选择只有四种编码形态**：INT 的分级 one-hot（A）、site 边界的 IMUX（B）、BRAM 的三路 cascade（C）、DSP 的两路 tie-off（D）；**A/B 已逐位实测并在 6 条网上端到端复原，C/D 的结构已由参考表 + V7 实测锚定，只剩逐一差分确认**；时钟树是唯一完全没有数据的路由选择域。


---

## 6. 位域边界（补齐 IO 与时钟网两类，2026-11-10）

前五节只覆盖 INT / CLB / BRAM / DSP。S47–S49 把 IO 与时钟网络补上后，全片的“配置位归属”可以按四类划清：

### 6.1 四类可配置对象

| 类别 | 例子 | 位的位置 | 编码形态 |
|---|---|---|---|
| **A 路由 PIP** | INT switch box 的 `SRC ->> FAM` | INT 块 off0..25 | 每 pip 1 位（或同族共享 2/4 位 one-hot） |
| **B site 边界/内部 mux** | IMUX、AFFMUX、OLOGIC OMUX、DSP GND/VCC、BRAM CASCIN | 各自块内 | **家族式 one-hot**：`N=a×b`、`K=a+b`、每源 2 位 |
| **C 属性码字** | PULLTYPE/DRIVE/SLEW/IOSTANDARD、INIT、ZALMOST_* | io72 off38/39；CLB off32..35；BRAM off26/27 | **码字**（非 one-hot），每值一组固定位 |
| **D 时钟网络** | IO 时钟进 fabric 的 BUFG/布线 | edge30 off26..29 | 按“是否有时钟进 fabric”出现/不出现 |

### 6.2 IO pad 字段（io72，word = 该 pad 行字）

| 字段 | 位 | 证据 |
|---|---|---|
| 三态使能 | 11 格，w12 八格 + (16,17,26)(25,17,26)(30,16,3) | S49 `tbuf` |
| 输出寄存器（OLOGIC 打包） | 37 格（`off1` 与 `off1_fab` 的对称差） | S49 |
| DDR 模式 | 36 格 clb off14 | S48/S49 `ddr_out`/`oddr_pipe` |
| PULLTYPE | (39,w,19)/(39,w,21)/(39,w,27)，NONE=b19=1、PULLDOWN=全 0 | S47 |
| DRIVE 2/4/8/16 | 3~6 格，off38/39 w16/w17 | S47 |
| SLEW FAST | 9 格，off38/39 w16/w17 | S47 |
| IOSTANDARD LVCMOS15 | 7 格，off38/39 | S47 续 |

### 6.3 时钟网络（edge30 off26..29）

clk 驱动 fabric 触发器时固定出现 29 格（`(3,45,21)(5,45,20)(17,94,4)(23..25,94,4)` + `(27,24/73,{1,3,15})` + `(27,93,{0,2,3,12,14,15})`）；时钟只接 ODDR/仅作数据时 **0 格**。⇒ 该区可按设计静态推断，无需逐位探测。

### 6.4 解码器过滤规则

```
候选池(路由) = INT 块 off0..25 ∪ CLB 块 off16..35
禁止触碰   = io72 off0..44 ∪ edge30 off26..29        # pad 属性/逻辑 + 时钟网
```

写位回环（864/864）与走线复原（6/6）只覆盖前者；后者一旦被误写会改变 pad 电气属性或时钟网。

### 6.5 两条口径必须分开

- “**IO 数据通路无配置位**”：pad 到 fabric 的连接是固定 tileconn（S23 / S35 证明，`get_pips` 在 LIOB18 只有 10 条单源 pip）。
- “**IO pad 自身有配置位**”：属性、IO 寄存器、三态、时钟网（S47–S49）。

混用这两句会让“IO 侧无位”结论被 S47–S49 的反例推翻。
