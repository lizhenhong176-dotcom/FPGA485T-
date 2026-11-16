# T85 CLB 剩余站内特征逐个实测 + ppip 归类

日期：2026-11-11　器件：xc7vx485tffg1157-3　站点：SLICE_X12Y20（块基址 31752）
固定：`u_lut` → `LOC SLICE_X12Y20 / BEL A6LUT`，`u_ff` → `LOC SLICE_X12Y20 / BEL AFF`，`LOCK_PINS I0:A1..I5:A6`，引脚全部 `PACKAGE_PIN` 固定。

## 1 五份设计

| 设计 | FF 原语 | 复位 | CE |
|---|---|---|---|
| `d_fdre` | FDRE（同步复位） | `rst` | `1'b1` |
| `d_fdce` | FDCE（异步清零） | `rst` | `1'b1` |
| `d_lat`  | LDCE（锁存器） | `1'b0` | — |
| `d_ce1`  | FDRE | `1'b0` | `1'b1` |
| `d_cepin`| FDRE | `1'b0` | `ce` 引脚 |

## 2 实测结果（只列 CLB 块内 = 帧 31752..31787）

### 2.1 FFSYNC：同步 vs 异步复位 = **1 位**

`d_fdre` vs `d_fdce`：**全芯片只差 1 格**

```
(帧 31752, word 41, bit 16)     FDRE(同步) = 1    FDCE(异步) = 0
```

这是本轮最干净的结果：两个原语的布线 PIP **完全相同**，只有这一位变。

### 2.2 SR 使用 vs 不用 = **3 位**

`d_fdre`(R=rst) vs `d_ce1`(R=1'b0)：

```
(31753, 41, 2) (31753, 41, 3) (31753, 41, 9)
```

三者 `R=rst` 时为 1。与 T82 的 7 格有重叠但少 4 格（T82 那批还换了 SR 源，混了布线）。

### 2.3 CE 使用 vs 常 1 = **7 位**

`d_ce1`(CE=1'b1) vs `d_cepin`(CE=ce)：

```
(31753, 41, 7) (31760, 39, 16) (31765, 39, 17)
(31771, 41, 1) (31775, 41, 0) (31776, 41, 0) (31777, 41, 0)
```

`(1,41,7)` 是最像 `CEUSEDMUX` 的单一位；其余 6 格分两簇（word 39 的 16/17、word 41 的 0/1 连续三帧），**归属未定**，需再做「CE 源换成另一种」的对照。

### 2.4 锁存器 vs 触发器 = **6 位**（4 移除 / 2 新增）

`d_fdre` vs `d_lat`：

```
移除: (31752, 41, 16)  ← FFSYNC
      (31753, 41, 2) (31753, 41, 3) (31753, 41, 9)  ← SR 三位
新增: (31753, 41, 19)  ← 与 T82 的 CLKINV 同位
      (31782, 41, 0)   ← 候选 LATCH 位
```

即 LDCE 需要把 CLKINV 置 1（G 与 C 的极性/走线不同）并多置 `(30,41,0)`。

## 3 CLB 的 151 条「PIP」全是 ppip（无配置位）

`prjxray_ref/artix7/ppips_clblm_l.db` 151 行（`ppips_clbll_l.db` 146 行），按目的归类：

| 类 | 条数 | 类型 | 含义 |
|---|---|---|---|
| `A.A1..A6` / `B/C/D` | 24 | hint | 「A 可由 A1 驱动」——只给路由器提示 |
| `A1..A6 ← CLBLM_IMUX{6,3,0,10,9,5}` 等 | 24 | always | **硬连线**：LUT 输入引脚固定接某个 IMUX 输出 |
| `AX←BYP0` `BX←BYP5` `CX←BYP2` `DX←BYP7` | 4 | always | 旁路输入硬连 |
| `AMUX.A` `BMUX.B` `CMUX.C` `DMUX.COUT/D` | 5 | hint | 站内 mux 输出的提示 |
| `CE←FAN6` `CLK←CLK0` `SR←CTRL0` | 3 | always | 控制引脚硬连到固定的 fan/clock/ctrl 线 |
| `COUT_N.COUT` | 1 | always | 进位输出 |
| `CLBLM_LOGIC_OUTS*/AQ..DQ` 等 | 90 | 61 always / 29 hint | 站内到 INT 的输出连接 |

⇒ **151 条里 93 条是 always（硬连线，没有任何配置位），58 条是 hint（只是提示，真实选择发生在 IMUX）**。这解释了 T68 为什么 toggle 不出来：它们本来就不是开关。

## 4 「没有配置位」的三类（累计）

| 对象 | 位 | 证据 |
|---|---|---|
| LUT 输入 mux（`CLBLM_L_A ← A1..A6`） | 0 | 24 条 always ppip，实际选择在 INT IMUX（T68） |
| BYP 旁路（`AX←BYP0` 等） | 0 | 4 条 always ppip；segbits 中 0 行 BYP |
| CE/CLK/SR 的「源选择」 | 0 | 3 条 always ppip（`CE←FAN6`/`CLK←CLK0`/`SR←CTRL0`）；源在 INT 侧 `CTRL_L*`/`CLK_L*` 选 |

## 5 已定位的 CLB 站内配置位（V7 实测）

| 特征 | 位置（块基址 31752） | 极性 |
|---|---|---|
| `FFSYNC`（同步/异步复位） | `(0, 41, 16)` | 1=同步 |
| `CLKINV`（时钟反相） | `(1, 41, 19)` | 1=neg（T82） |
| `AFFMUX` O5/O6 | `(30, 40, 0)` | 1=O5（T83） |
| `AOUTMUX`（4 位） | `(3,40,8)(4,40,10)(6,41,4)(7,41,5)`=O5；`(3,40,4)(4,41,10)(6,41,8)(7,40,5)`=O6 | T84 |
| SR 使用 | `(1,41,2)(1,41,3)(1,41,9)` | 1=使用 |
| CE 使用 | 候选 `(1,41,7)` + 6 格待定 | 1=使用 |
| LATCH | 候选 `(30, 41, 0)` | 1=锁存 |

## 6 边界与未决

- 所有位号只在 `SLICE_X12Y20`（grid_col 20，Y=20 上半区）实测；跨 slice/跨行未验。
- `CE` 那 7 格与 `LATCH` 的 `(30,41,0)` 都是**候选**，未做第二组独立对照。
- `PRECYINIT`（3 位）、`A5FF/A5FFMUX`、SMEM 的 `WA7USED/WA8USED/WEMUX` 未测。
- V7 帧偏移与 A7 偏移（30/31）不对应，无法直接套 prjxray 的位号。
