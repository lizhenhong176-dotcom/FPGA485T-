# V7 CLB 位级规格（给解码器用）

器件：**xc7vx485tffg1157-3**　Vivado 2017.2　更新：2026-11-11
配套脚本：`v7re/scripts/clb_decode.py`　位图数据：`v7re/steps/clb_init_locked_x12y20_4lut.json`

> 本文所有位号都来自**受控差分实验**（固定 `LOC`/`BEL`/`LOCK_PINS`/引脚，只改一个因素）。
> 标注 **确认** 的位至少有两个独立构造或两个独立 BEL 验证；标注 **候选** 的只有一组证据。

---

## 1 坐标系统

### 1.1 帧与字

- 位流帧数 **50,176**；每帧 **101** 个 32 位字（word 0..100）。
- **word 50 是帧级 ECC/校验字**，解码时**必须跳过**（它随数据字变化，不承载配置）。
- 帧号 → FAR 的映射见 `v7re/bitstream/far.py`；`frame_map` 表 50,176 行。

### 1.2 CLB 块基址

每个 CLB tile 的 36 个连续帧构成一个「块」：

```
块基址 = clb_blocks[(grid_col, y // 50)]
```

- `grid_col = X % 26`（同一列在上下 50 行内共享块基址）
- 本文实测点：`SLICE_X12Y20` → `grid_col 20` → **块基址 31752**
- 块内帧偏移 `frame_off ∈ [0, 35]`

### 1.3 字与奇偶

块内 `frame_off` 的奇偶性决定用哪个 word：

| frame_off 奇偶 | LUT INIT 所在 word |
|---|---|
| 偶 | word 40 |
| 奇 | word 41 |

（本文件的位表直接给 `(frame_off, word, bit)` 三元组，不依赖此规则。）

---

## 2 LUT INIT（64 位，闭式公式）

### 2.1 公式

对某个 slice 内的 LUT `L ∈ {A,B,C,D}`，INIT 的第 `k` 位（`k = 0..63`）位于：

```
frame_off = 34 + (k & 1) - 2 * ((k >> 3) & 1)
word      = 40            (L = A, B)
            41            (L = C, D)
bit       = B_L - 4 * (k >> 4) - ((k >> 1) & 3)

其中 B_A = 15, B_B = 31, B_C = 15, B_D = 31
```

绝对帧号 = `块基址 + frame_off`。

### 2.2 验证

- 对 `clb_init_locked_x12y20_4lut.json` 的全部 **4 × 64 = 256** 个格，公式与实测表**逐项相等**（0 处不符）。
- 用公式解码 `_full8.bit` → `INIT_A6LUT = 0x0000000000000001`，与设计值一致。

### 2.3 解码前必须先确定引脚置换（重要）

INIT 位号与「LUT 输入 I0..I5 分别接哪个物理引脚（A1..A6）」绑定。若设计**没有** `LOCK_PINS`，Vivado 会把输入随机分给 A1..A6，此时：

- **格集合不变**（仍是上面 64 个格）；
- **索引标签会被置换** → 直接套公式会得到错误 INIT。

实测例：`_full8_i3.bit`（设计 INIT=3，未加 LOCK_PINS）按公式解出 `0x0000000100000001`（bit0 + bit32），而不是 `0x3`。

**解码器做法**：先从 INT 侧 IMUX 位解出每个 LUT 输入的物理引脚序（见 `v7re/scripts/decode_exact.py` 与 `law_cells` 的 `minbit/parity` 公式），据此把公式里的 `k` 换成实际引脚组合，再取值。

---

## 3 触发器（FF）位

| 特征 | `(frame_off, word, bit)` | 极性 | 状态 |
|---|---|---|---|
| `FFSYNC`（同步/异步复位） | `(0, 41, 16)` | **1 = 同步（FDRE）**，0 = 异步（FDCE） | 确认（AFF + BFF 双点） |
| `CLKINV`（时钟反相） | `(1, 41, 19)` | **1 = 反相**（negedge / 锁存 G） | 确认（negedge + latch 两路） |
| `LATCH`（锁存器） | `(30, 41, 0)` | **1 = LDCE** | 确认（BFF 独立对照） |
| `FF.INIT` | `(67, 40, 3)` | 单比特 | 确认（T17） |

> `FFSYNC`/`CLKINV`/`LATCH` 是 **slice 级**：AFF 与 BFF 上位置相同。

---

## 4 选择器位

### 4.1 `AFFMUX`（FF 的 D 来源）

| 配置 | 位置 |
|---|---|
| O5 vs O6 | `(30, 40, 0)`：**1 = O5**，0 = O6 |

prjxray 的 `AFFMUX` 是 **4 位字段编码 6 个源**（AX/CY/XOR/F7/O5/O6），不是 4 位 one-hot；其中 O5 与 O6 只差 1 位，与实测一致。

### 4.2 `AOUTMUX`（LUT 输出选择）—— 4 位

| 档位 | 置位格（4 个） |
|---|---|
| O5 | `(3, 40, 8) (4, 40, 10) (6, 41, 4) (7, 41, 5)` |
| O6 | `(3, 40, 4) (4, 41, 10) (6, 41, 8) (7, 40, 5)` |

两组构造（`LUT6_2` 双输出交换、单输出 LUT 换脚）给出**相同**结果。

---

## 5 控制使能位

| 特征 | 位置 | 极性 | 状态 |
|---|---|---|---|
| `SR` 使用 | `(1,41,2) (1,41,3) (1,41,9)` 三位同时为 1 | 1 = 使用 | 确认（两组一致） |
| `CE` 使用 | `(1,41,7)` | 1 = 使用 | **强候选**（跨 CE 源稳定） |
| `CE` 目标编码 | `(23,41,0) (24,41,0) (25,41,0)` | — | 候选 |
| `PRECYINIT` 常量 1 档 | `(0, 40, 12)` | **1 = 进位初值取常量 1** | 确认单档 |

`PRECYINIT` 在 prjxray 里是 3 位字段（CY0 / INIT0 / INIT1）；本器件只定位了「常量 1」这一档，`CYINIT` 走专用布线、换档必然改布线，另两档未定形。

---

## 6 没有配置位的部分（ppip）

CLB 内部那 151 条「PIP」（`ppips_clblm_l.db`，CLBLL 为 146 条）**全部是 ppip**，分两类：

| 类型 | 条数 | 含义 |
|---|---|---|
| `always` | 93 | **硬连线**，没有任何配置位 |
| `hint` | 58 | 只给路由器提示，真实选择发生在 INT 侧 |

其中明确「零配置位」的三类：

| 对象 | 证据 |
|---|---|
| LUT 输入 mux（`CLBLM_L_A ← A1..A6`） | 24 条 always ppip；改 `LOCK_PINS` 只改 INT 侧 IMUX 位 |
| BYP 旁路（`AX←BYP0` `BX←BYP5` `CX←BYP2` `DX←BYP7`） | 4 条 always ppip；segbits 中 0 行 BYP |
| CE/CLK/SR 的**源选择** | 3 条 always ppip（`CE←FAN6`/`CLK←CLK0`/`SR←CTRL0`）；源在 INT `CTRL_L*`/`CLK_L*` |

⇒ 解码这些「选择」时不要找 CLB 位，要去 INT tile 找对应的 mux 位。

---

## 7 解码器

```bash
python v7re/scripts/clb_decode.py <bitstream> [site] [--base N] [--json]
```

默认 `site=SLICE_X12Y20`、`base=31752`。

输出示例（`_full8.bit`）：

```
site SLICE_X12Y20  base 31752
  FFSYNC       0        LATCH        0        CEUSEDMUX    0
  CLKINV       0        SR_USED      0        PRECYINIT_1  0
  FINIT        0        AFFMUX_O5O6  0        AOUTMUX      O5
  INIT_A6LUT   0x0000000000000001
  INIT_B6LUT   0x0000000000000100
  INIT_C6LUT   0x0000000000000100
  INIT_D6LUT   0x0000010000000000
```

### 7.1 反向验证（用已知设计对拍）

| 设计 | 设计意图 | 解码结果 | 是否一致 |
|---|---|---|---|
| `d_fdre` | FDRE 同步复位 | `FFSYNC=1`，`SR=[1,1,1]` | ✓ |
| `d_fdce` | FDCE 异步复位 | `FFSYNC=0`，`SR=[1,1,1]` | ✓ |
| `d_lat` | LDCE 锁存 | `LATCH=1`，`CLKINV=1`，`SR=[0,0,0]` | ✓ |
| `d_cepin` | CE 接引脚 | `CEUSEDMUX=1`，`CE_TARGET=[1,1,1]` | ✓ |
| `d_ce1` | CE 接常量 1 | `CEUSEDMUX=0`，`CE_TARGET=[0,0,0]` | ✓ |
| `p_ci1` | `CI=1'b1` | `PRECYINIT_1=1` | ✓ |

**6/6 全部与设计意图一致。**

---

## 8 置信度汇总

| 特征 | 状态 | 证据强度 |
|---|---|---|
| LUT INIT 公式 | **确认** | 256/256 格公式与实测表相等 |
| `FFSYNC` | **确认** | AFF/BFF 双点、单一位差 |
| `CLKINV` | **确认** | negedge 与 latch 两路 |
| `LATCH` | **确认** | BFF 独立对照（1/2 格） |
| `AFFMUX` O5/O6 | **确认** | 1 位差，与 prjxray 一致 |
| `AOUTMUX` 4 位 | **确认** | 两组构造一致 |
| `SR` 三位 | **确认** | 两组独立设计一致 |
| `PRECYINIT` 常量 1 | **确认单档** | CI=1 与 CYINIT=1 两组 |
| `CEUSEDMUX` | 强候选 | 跨 CE 源稳定，但对照含一个混杂变量 |
| `CE` 目标编码 | 候选 | 3 位模式，未独立复核 |
| `PRECYINIT` 另两档 | 未定 | `CYINIT` 改档必改布线 |
| SMEM `WEMUX`/`WA7USED`/`WA8USED` | 未拿到 | RAM32M 差分噪声 8/59 格 |
| `A5FF`/`A5FFMUX` | 未拿到 | 需换整条输入网，噪声不可控 |

## 9 适用范围与已知限制

1. 全部位号只在 `SLICE_X12Y20`（grid_col 20，Y=20 上半区）实测；**跨列/跨行未验证**。
2. V7 的帧内偏移（如 INIT 在 34/35、AOUTMUX 在 3/4/6/7）与 prjxray 的 A7 偏移（30/31）**不是同一体系**，不能直接套用 A7 位号，需要单独建 V7↔A7 偏移映射。
3. `word 50` 是 ECC，解码时跳过；写位流时要重算（见 `bitgen.py`）。
4. CLBLL 与 CLBLM 的 slice 布局不同（T54：`SLICE_X8Y20` 用 CLBLM 表解 INIT 会 13 缺 13 多），本文的表只适用于 **CLBLM**；CLBLL 需单独标定。
