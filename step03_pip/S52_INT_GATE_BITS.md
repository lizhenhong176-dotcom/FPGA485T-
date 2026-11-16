# S52 — INT 门控位点亮实验（66 洞，off0..3 stride-4）

日期：2026-11-11　远端：`/opt/lzh/step13/`（`holescan3.py` 语料扫描、`gc/` 实验组）　块：`SLICE_X8Y11`（CLB base 31680，行字 22/23）

## 1. 66 个洞的结构（`all_cells.json` INT_L 侧，1,664 − 1,598）
```
(0,0) [0,4,8,12,16,20,24,28,31]   (0,1) [0,4,8,12,16,20,24,28]
(1,0) [3,7,11,15,19,23,27,30,31]  (1,1) [3,7,11,15,19,23,27,31]
(2,0)/(2,1) [0,4,8,12,16,20,24,28]  (3,0)/(3,1) [3,7,11,15,19,23,27,31]
```
即两条正交 stride-4 位线（`bit≡0` 与 `bit≡3 (mod 4)`）× 4 个 offset × 2 parity。清单 `E:\v7work\int_holes.json`。

## 2. 语料挖掘：6,015 个既有 bitstream 里只点亮过 3 个洞位
- 第一版扫描有 bug：用 `wd = 2*y` 当行字，y=25 读到 word 50（**帧校验字**）→ 假命中全挤在 y=25。改用 `wof(y)=2*(y%50)+(1 if y%50>=25 else 0)` 后重扫 301 个设计（step 20）：
  - `(0,1,16)` ← `s4ff/ff_f7.bit`、`s5/s5_d_fdld.bit`…（FF 类设计）
  - `(1,1,19)` ← `s5/s5_d_fdld.bit`
  - `(1,0,31)` ← `s7/s7b_A_d2.bit`
- 剩余 63 位在 6,015 个设计里**从未出现** ⇒ 现有语料覆盖不到这些门控模式，必须定向造设计。

## 3. 定向实验（6 个设计，全部 20,273,538 B）

| 设计 | FF 位置 | CE | R | clk 路径 |
|---|---|---|---|---|
| `clock_global` | SLICE_X8Y11 | port `ce` | const 0 | IBUF→BUFG |
| `clock_fabric` | 同上 | port `ce` | const 0 | LUT6 输出 |
| `fanout` | 同上 | port `ce` | const 0 | port 直驱 CK |
| `gc_ce` | 同上 | const 1 | const 0 | IBUF→BUFG |
| `gc_rst` | 同上 | const 1 | port `rst` | IBUF→BUFG |
| `gc_nof` | 无（纯 LUT） | — | — | — |

实测（base 31680，y11，只列洞位）：

| 设计 | (0,1,16) | (1,0,7) | (1,0,19) | (1,1,3) | (1,1,7) | (1,1,15) | (1,1,23) |
|---|---|---|---|---|---|---|---|
| clock_global | ✔ | ✔ | ✔ | – | ✔ | ✔ | ✔ |
| clock_fabric | ✔ | ✔ | ✔ | – | ✔ | ✔ | ✔ |
| fanout | ✔ | ✔ | ✔ | – | ✔ | ✔ | ✔ |
| gc_ce | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| gc_rst | ✔ | ✔ | ✔ | ✔ | – | ✔ | ✔ |
| gc_nof | – | – | – | – | – | – | – |

关键判读：
1. **`(0,1,16)` = 该 slice 有 FF 在使用**（唯一的 0/1 完全跟随 FF 存在性的位，纯 LUT 设计为 0）。
2. **`(1,1,7)` = CE 来自 fabric 信号**（CE 接常量 1 时清零：`gc_ce`/`gc_rst` 为 0）。
3. **`(1,1,3)` = R/SR 来自 fabric 信号**（R 接常量时为 0；`gc_rst` 与 s8_v0 为 1）。
4. **`(1,1,15)`、`(1,1,23)` = CE 或 R 存在“常量端”时的补偿/默认码**（四个 FF 设计中，`CE/R` 全 fabric 的 s8_v0 两位均为 0，其余都有常量端 → 置 1）。【推断，待全常量组合验证】
5. `(1,0,7)`、`(1,0,19)` 与上面三条正交出现于所有 FF 设计，属 FF 控制总线（parity=0 侧）的伴随位，命名留空。【未命名】
6. `clock_fabric`（无 BUFG、LUT 当时钟）与 `clock_global`（BUFG）点亮**同一组洞位** ⇒ 这 6 位都与“是否走全局时钟树”无关；BUFG 的差异只体现在已覆盖 cell（off1p0 bit10/14/29、off0p0 bit27 等）。

## 4. 入库
`v7_law.sqlite.law_ctrl`（132 行 = 66×2 侧）新增命名 10 行（5 个坐标 × 2 侧）：
- `(0,16,1)` = `FF_USED_IN_SLICE`
- `(1,7,1)` = `CE_SOURCE_FABRIC`
- `(1,3,1)` = `SR_SOURCE_FABRIC`
- `(1,15,1)` = `CE_SR_CONST_MARK_A`【推断】
- `(1,23,1)` = `CE_SR_CONST_MARK_B`【推断】
其余 56 格仍未命名（语料 + 本批 6 设计都点不亮）。

## 5. 构建坑（复现必读）
- 缺 `export LANG=C LC_ALL=C HOME=/root` → `terminate called ... locale::facet::_S_create_c_locale name not valid`（3/3 崩）。
- `clk` 放非时钟脚（AM28）→ `ERROR: [Place 30-574] Poor placement for routing between an IO pin and BUFG` + `[Place 30-99] IO Clock Placer failed`；改 `clk=AL31`（IOB_X0Y78，时钟脚）解决。
- PACKAGE_PIN 重复 → `ERROR: [Vivado 12-1411] ... port d[7] ... occupied by port d[4]`。
- `set_property CFGBVS GND` 必须带 `[current_design]`，否则 `[Common 17-163] Missing value for option 'objects'`。
- LUT 与 FF 同放一个 slice → `A6 cannot be used because of C5LUT usage`（本批把 LUT 放 SLICE_X9Y11）。

## 6. 结论
66 个洞**不是**“GCLK 直通/旁路专属”，而是 **FF 使用标记 + CE/SR 来源位 + 2 个常量补偿位**，其余 60 位仍未点亮。要覆盖它们必须造出「CE/R 既非常量也非普通 fabric 网」「多 slice 同用」等组合设计（下一批）。
