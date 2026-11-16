# V7 位流逆向 · 速查卡（xc7vx485tffg1761-2）

> 【数】= 本项目实测（tilegrid / site 表普查）；【硬】= 7 系列手册；【未测】= 无数据。

## 1 定位公式

```
cell = (block_base + frame_off, word, bit)
word = 2*(Y % 50) + parity        # 半带：Y%50 >= 25 时 +1
bit  = raw % 32
parity = raw_bit // 32            # prjxray 把两字打包进 bit 字段，漏 parity = 合并两个物理位
overhead = 每 config row 末 2 帧，不属任何用户块
```

| 规模 | 值 |
|---|---|
| 帧 / 字 / 位（全芯片） | 50,176 × 101 × 32 【数】 |
| tile / site / pin / clock region | 150,380 / 86,022（fabric）/ 1,760 / 14 【数】 |
| 位池（单 INT tile） | 1,664 位 = 26 帧 × 2 字 × 32 【数】 |

## 2 各层已解位位置

| 层 | 单元 | 帧/字偏移 | 状态 |
|---|---|---|---|
| CLB | LUT INIT | X0: off 32–35；X1: off 26–29（word = 行字） | ✅ 64 位，二进制 A6(MSB)…A1(LSB)，无位反序 |
| CLB | FF | off 30/31：`AFFMUX`(off30)、`ZRST`(off30,12)、`ZINI`(off31,3) | ✅ |
| CLB | `BOUTMUX`(F8) | off 30 位 22/23 | ✅ |
| CLB | `PRECYINIT` | off 30 位 12/13/14 | ✅ 四态含 sense |
| CLB | `CARRY4 CY0` | — | 【未测】 |
| CLB | CE/SR/CLKINV | — | 【未测】 |
| CLB | RAM/SRL | `ALUT.SRL`(30,16)、`DLUT.RAM`、`WA7USED`、`WA8USED`、`WEMUX`(40,23) | ✅ 部分 |
| INT | PIP（家族） | off 0–15（26 帧块内） | ✅ 181 PIP / 0 ambiguous |
| CLB | IMUX | off 16–25（word 22/23） | ✅ 双侧 48/48 |
| — | tileconn `BEG→END` | 无位（固定连接） | ✅ 查表 |

## 3 家族（family）

```
家族 = 同一 tile_type 下、目标 wire 相同的一组互斥 PIP，其源共用同一小组配置位编码区分。
```

| 指标 | 值 |
|---|---|
| cell → 家族独占 | 1,598 / 1,598（0 例跨族共享）|
| 族内共享 | 3..18 源/cell，均值 5.57，最大 18 |
| 每 PIP 占 cell | 1–4 |
| 形状 5 类 | (9,20)×96 / (10,24)×64 / (8,16)×6 / (7,12)×4 / (9,18)×2 |
| 编码结构 | 两级 one-hot：`(9,20)` = 4 组 × 5 成员，位宽 `4+5=9`（≠ `ceil(log2 20)=5`）|
| 判形状技巧 | 算**列计数**：`b×a + a×b` = 两级；出现每源 4 位 = 有直通源（`(8,16)`/`(10,24)`，未细化）|

## 4 命名

| 片段 | 含义 |
|---|---|
| `NN/SS/EE/WW` + `1/2/4/6` | 单方向线（北/南/东/西），长度 |
| `NE/NW/SE/SW` + `1/2/4/6` | 对角方向线 |
| `BEG<n>` / `END<n>` | 线段起终点；`BEG→END` 由 tileconn 固定决定（**不是 mux**）|
| `LV` / `LVB` | 跨 clock region 长竖线 |
| `GFAN` | 全局扇出 |
| `LOGIC_OUTS` | CLB 输出进布线 |
| `IMUX_L/R0..11`、`BYP`、`CTRL`、`CLK` | CLB 输入侧 mux 输出 |
| PIP feature | `<tile_type>.<目标wire>.<源wire> <off>_<bit>`，`!` = 须为 0 |
| 家族命名空间 | `(tile_type, 目标 wire)` —— 跨 tile_type 同名不算同族 |
| `SLICEM` | 只有偶数列（`CLBLM_*`）；有分布式 RAM/SRL |

## 5 mux 六级

| 级 | 名称 | 控制位 | 状态 |
|---|---|---|---|
| 1 | 长线/全局（`LV/LVB`、`GFAN`、`HROW`）| 布线帧 | 部分 |
| 2 | **INT 内布线 mux = 家族** | INT tile 26 帧，off 0–15 | ✅ |
| 3 | 跨 tile 续接 | **无位**（tileconn 17,928 条）| ✅ |
| 4 | site 入口 `IMUX/BYP/CTRL/CLK` | CLB 帧 off 16–25 | ✅ |
| 5 | BEL 内 mux | CLB 帧 off 30/31 等 | 大部分 ✅（CY0/CE/SR 未测）|
| 6 | 硬块内 mux | 硬块帧 | 部分（BRAM 少数）|

## 6 资源计数

| 项 | 数 | 项 | 数 |
|---|---|---|---|
| SLICE | 75,900（SLICEL 43,200 / SLICEM 32,700）| LUT6 | 303,600 |
| FF | 607,200 | MUXF7 / F8 | 151,800 / 75,900 |
| CARRY4 | 75,900 | BRAM36 | 1,030（tile 480+550）|
| DSP48E1 | 2,800（DSP_L 770 + DSP_R 630 tile ×2）| GTXE2_CHANNEL | 56 |
| MMCM / PLL | 14 / 14 | BUFGCTRL | 32 |
| BUFHCE / BUFR / BUFIO / BUFMRCE | 168 / 56 / 56 / 28 | ILOGIC/OLOGIC/IDELAY/ODELAY | 各 700 |
| INT_L + INT_R | 53,100 | clock region | 14 |

## 7 常见坑

1. `(frame_off, bit)` 不够 → 必须带 `parity`。
2. 位全 0 ≠ 未选 → 通常是**默认源**。
3. 位数 ≠ `ceil(log2 N)` → 是各级 one-hot 之和。
4. `BEG→END` 不是 mux → 无配置位，靠 tileconn。
5. 家族不是 Xilinx 官方术语（UG470/472 无此词）。
6. XDC 里 `foreach` 被静默忽略 → LOC 丢失，设计落到 band1。
7. 预综合阶段 `get_cells` 返回空 → LOC 必须在 synth 后施加。
8. 同一 INT 列若有 28 帧接口块 → 块基址 = 下一个 CLB 块 − 28。
9. LUT INIT 索引无位反序（曾被 MSB/LSB 读法坑过）。

## 8 关键文件

| 用途 | 路径 |
|---|---|
| 项目进度 | `STATUS.md` |
| 位池复用规则 | `step03_pip/REUSE_RULES.md` |
| 全量讲解 | `step03_pip/FPGA_UNITS_MUX_FULL.md` |
| 回答纪律 | `AGENTS.md` / `step03_pip/SYSTEM_PROMPT_V7_BITSTREAM.md` |
| cell 表（24,336 条）| `step03_pip/all_cells.json` |
| tile 普查 | `E:\v7work\db\prjxray\xc7vx485t\tilegrid.json` |
| site 普查 | `E:\v7work\model\v7_model.sqlite`（`sites` 表）|
| 位级验证库 | `E:\v7work\model\v7_law.sqlite`（`v7_verified`）|
| 全芯片解码器 | `step03_pip/decode_clb.py` / `imux_decode.py` / `int_walk_v1.py` |
| 网表发射器 | `step03_pip/emit_netlist2.py` → `E:\v7work\netlist2.v` |
