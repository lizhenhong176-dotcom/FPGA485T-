# IMUX 物理输入序号：问题与答案

> 2026-10-25。这是 STATUS.md 待办 ①「mux 物理输入序号」的收口文档。
> 结论：**不需要拟合公式**——IMUX 的 24 个输入本来就有一个规整的 6×4 坐标，
> 用 prjxray 的 7 系列 INT 数据库可直接读出，并在我们 485T 实测的 864 条记录上 100% 对上。

---

## 1. 问题是什么

`pip_bits` 里每条 IMUX 选择位写成 `(frame, word, bit)`。对同一个 mux（如 `IMUX_L8`），
24 个源的地址可以排成 6×4 的格子；但把同一个源（如 `GFAN0`）拿到另一个 mux（如 `IMUX_L2`）上看，
它的格子位置会变。于是当时的问题是：

- 能不能找到一个「物理输入序号」k，使得 `源 -> k` 是全局唯一的；
- 位地址由 `mux + k` 唯一决定，即 `(frame,word,bit) = f(mux, k)`。

当时三个候选解释都已被否掉（见 `P6_FINDINGS.md`）：
同名 wire 落在同格（否）、字母序等于物理输入序（否）、tile_type 里 PIP 声明顺序等于物理输入序（否）。

## 2. 答案

**24 个输入 = 6 行 × 4 列**，行列各自独立编码：

| 轴 | 位 | 编码 |
|---|---|---|
| 行 row=0..5 | `word 16..21` | one-hot，行号 = 置位字 - 16 |
| 列 col=0..3 | `word 22..25` | 四选一码：`0001 / 0010 / 1011 / 0111`（顺序即 col 0/1/2/3） |

- 每个 mux 只占用固定的 word 组：**word = 22 + ((L//4) % 2)**，`bit = 1 + 8*(L%4) + L//8`。
- 行、列两个字段互不相交，所以 24 个输入的位集合两两正交（一行 4 个、每列 6 个，正好铺满 6×4）。
- 同一 mux 内：`源 -> (row, col)` 是**双射**；跨 mux：同一个源可以出现在不同 (row,col)，这不是错误，
  而是因为「哪个布线资源接到哪个输入脚」由芯片物理走线决定，是逐 mux 不同的常量表。

## 3. 数据来源

- `prjxray_ref/artix7/segbits_int_l.db`（164,493 B）与 `segbits_int_r.db`（160,201 B）。
- 格式：`INT_L.<mux>.<src> <word>_<bit> ...`，例如
  `INT_L.IMUX_L8.LOGIC_OUTS_L12 16_02 17_02 ... 25_02`。
- 7 系列 INT tile 与 Artix-7 同构（同一套 segbits 覆盖 7 系列全家族），48 个 IMUX × 24 输入/侧。

## 4. 交叉验证（关键）

用我们自己在 485T 上实测的 36 个 mux × 24 源 = **864 条**记录逐条比对：

- 行（置位字 - 16）：**864/864 一致**
- 列（word 22..25 的四位码）：**864/864 一致**

也就是 prjxray 的这张表和我们从硅片上差分出来的位是同一套编码。
这同时解释了之前「同一源位置平移」的现象——平移发生在**行**轴上（不同 mux 的同名源接不同行），
当时按「源名固定」去对齐，才会看起来乱。

## 5. 语义观察

以 `IMUX_L8` 为例，行 0..5 与列 0..3 的源家族非常规整：

| row | 源家族 |
|---|---|
| 0 | SS2END / SW2END / SR1END / NL1END0（南向） |
| 1 | NN2END / NE2END / ER1END / WL1END（北向） |
| 2 | EE2END / SE2END / WR1END / EL1END（东向） |
| 3 | WW2END / NW2END / NR1END / SL1END（西向） |
| 4 | BYP_BOUNCE_N3_6 / BYP_BOUNCE_N3_2 / FAN_BOUNCE2 / FAN_BOUNCE7（旁路） |
| 5 | GFAN0 / LOGIC_OUTS_L22 / LOGIC_OUTS_L0 / LOGIC_OUTS_L12（本 slice 输出 + 全局扇出） |

列的四个码对应组内四个成员，码型本身也有结构：

- `0001` / `0010`：单 bit one-hot，对应「直连」类（SS/NN/EE/WW、GFAN0、BYP_BOUNCE_N3_6）
- `1011` / `0111`：三 bit，对应「转折」类（SR/ER/WR/NR、FAN_BOUNCE2/7、LOGIC_OUTS_L0/L12）

## 6. 怎么用

### 查表

```
python step03_pip\pip_query.py imux IMUX_L8
```

### 编码（给一个 mux 选一个源）

1. 从 `imux_codes` 查出 `(row, col_code, field_bit)`；
2. 清掉该 mux 字段的 24 个格（`word 16..21` × `bit b0, b0-1`）；
3. 在 `row` 对应的 word 上置 `b0`；按 `col_code` 在 `word 22..25` 上置位（1 置、0 不置）；
4. 绝对地址：`frame = 帧基址 + (word - 16)`（本 tile 内基址 31696），bit 用 `field_bit` / `field_bit-1`。

### 反解

同 `pip_query.py decode`：读入 .bit，按每个 mux 的 24 个候选位集合求 Jaccard，取最优即源。

## 7. 表与工具

| 对象 | 位置 |
|---|---|
| 生成脚本 | `step03_pip/gen_imux_table.py`（解析 segbits -> JSON） |
| 数据 | `step03_pip/imux_codes.json`（2304 行：INT_L 1152 + INT_R 1152） |
| 数据库 | `v7_model.sqlite` 表 `imux_codes`（本地与远端 `/opt/lzh/v7re/data/model/v7_model.sqlite` 均已建） |
| 查询 | `pip_query.py imux [IMUX_Lx]` |

表结构：`tile_type, mux, lut_input, src_wire, row, row_word, col_code, col_index, idx, field_bit, source`。

## 8. 已知边界

- **INT_R 没有实测对照**：右半 tile 的 1152 行是按同一套 prjxray 数据推的，尚未在硅片上验证；
  左半 864/864 只能说明编码规则对，不保证 INT_R 的 mux 命名方向没镜像。要补就做一次右半 tile 差分。
- `idx = row*4 + col` 是**我们自己的编号**，硅片只认 `(row, col_code)`；
  prjxray 的 `bit` 字段是 0..63 的打包编号（如 L7 是 56/57），与我们的 `bit(0..31)+word` 是同构映射，不要混用。
- 行轴为什么这样排（为什么 L8 的 row0 是南向）还没有物理解释，目前只当常量表。

## 9. 复现

```
python step03_pip\gen_imux_table.py            # 生成 imux_codes.json
python step03_pip\ingest_imux.py               # 写入本地 v7_model.sqlite
python step03_pip\pip_query.py imux IMUX_L8    # 抽查
```

远端同步：`step03_pip/_imux_sync.py` 是自包含 payload（gzip+base64 内嵌 JSON），
经 ssh stdin 送进 WSL 的 python3 执行即可。
