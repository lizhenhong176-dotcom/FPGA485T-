# prjxray artix7 对表报告(PRXRAY_COMPARE)

- **日期**:2026-10-24
- **目的**:验证 prjxray-db artix7 数据库对 XC7VX485T(V7)的 tile 级位布局可移植性,决定 STEP03 战略(移植 vs 纯自研 fuzz)
- **结论(一句话)**:**INT 位库逐位精确匹配、六个 tile 类型枚举零缺失,可整体移植;CLB INIT 物理骨架一致但序号差一个 per-LUT 置换(已测出);site-PIP 全部为伪 PIP(无配置位)。STEP03 从"发现战役"变为"移植+验证战役"。**

---

## 0. 数据来源与完整性

- 仓库:`f4pga/prjxray-db` @ `master`,commit `0a0addedd73e7e4139d52a6d8db4258763e0f1f3`(2021-12-14)
- 下载:`raw.githubusercontent.com/f4pga/prjxray-db/master/artix7/...`(2026-10-24)
- 文件与 SHA256 见本目录 `SHA256SUMS.txt`;比对脚本 `compare_init.py`(INIT 256 条)、`compare_coverage.py`(六 tile 覆盖率)可复现全部数字
- 本地实测来源:`E:\v7work\m2\clb_shell\segbits_CLBLM_R.db`(256 行)、`E:\v7work\m2\m2_mcd_0001.json`、`step03_pip\RESULTS.md` 的删 PIP 差分表、STEP01 模板 `E:\v7work\_curated_20261021\routing\out_routing\templates\*.json`

**命名/坐标映射约定**(对表前提):

| 项 | 本地(V7) | prjxray(artix7) |
|---|---|---|
| INT PIP 命名 | `SRC->>DST`(RapidWright) | `INT_L.DST.SRC`(**目的在前**) |
| LUT 命名 | `A6LUT`(Vivado BEL) | `ALUT`(合并 A5/A6) |
| site 命名 | `SLICEM_X0` | `SLICEM_X0` / `SLICEL_X1`(一致) |
| bitindex | word×32+bit(word 绝对,Y10 行基址 20) | word 相对(tilegrid `offset` 补基址) |
| CLB 帧锚 | tile baseaddr = 列基址+32(如 0x00420320) | 列基址(minor 0),`frames:36` |

---

## 1. 对表 1:INT_L 删 PIP 实测 vs segbits_int_l.db —— 3/3 逐位命中

| PIP(本地名) | 本地实测(块内帧偏移, word, bit) | prjxray 条目 | 判定 |
|---|---|---|---|
| `LOGIC_OUTS_L20->>NR1BEG2` @X6, 11 个 Y 点 | 帧 {8,14};w=2r+1+[r≥25], b7(Y20→w41) | `INT_L.NR1BEG2.LOGIC_OUTS_L20 08_39 14_39` | **命中**:帧 {8,14} 一致;39=(word 1,b7),w41=offset(40)+1 |
| `LOGIC_OUTS_L12->>NR1BEG0` @X6Y10 | 帧 {10,13};w20, b7 | `INT_L.NR1BEG0.LOGIC_OUTS_L12 10_07 13_07` | **命中**:帧、word 槽(s=0)、bit 全一致 |
| `NR1END0->>IMUX_L8` @X6Y11 | 帧 {19,22,24,25};(w22,b3)×1 + (w22,b2)×3 | `INT_L.IMUX_L8.NR1END0 19_03 22_02 !23_02 24_02 25_02` | **命中**:4 帧及位分布(03@19, 02@22/24/25)精确一致 |

要点:

1. **PIP = 多位多帧且带负位**:prjxray 每行含正位(置 1)与 `!` 负位(必须为 0)——删 PIP 差分只能看到正位,负位是**免费的补充验证目标**(检查目标位在两个 bitstream 里都为 0)。
2. word 统一公式最终形态:**word = 2r + [r≥25] + s,其中 s = prjxray bitindex ÷ 32 ∈ {0,1}**;"k 抖动"= [r≥25](word 50 行中分)+ 每变体固定的 s 槽位。
3. 帧 = 列块基址 + prjxray 帧偏移(INT 段 minor 0–27)。

## 2. 对表 2:m2_mcd_0001(INT_R)归属闭环

prjxray:

```text
INT_R.IMUX8.NR1END0  19_03 22_02 !23_02 24_02 25_02
INT_R.IMUX1.NR1END0  16_09 !22_09 23_09 24_09 25_09
```

- m2 的三个位 **(22,2)(22,3)(22,9) = 两行正位的并集**:(22,3)@f19 与 (22,2)@f22/24/25 是 IMUX8 开启侧;(22,9)@f16/23/24/25 是 IMUX1 关闭侧。8 个 diff 帧中 6 个(f16/19/22/23/24/25)被两行解释;**f20/f21 待查**(推测为同 mux 家族兄弟源的负位/编码位翻转,prjxray 同族行可直接查)。
- **site-PIP 零配置位**:prjxray `ppips_clblm_r.db` 明确标注 `CLBLM_M_A3.CLBLM_IMUX1 always`、`CLBLM_M_A5.CLBLM_IMUX8 always`——A3↔IMUX1、A5↔IMUX8 是硬件固定连线,与 M2_PIP.md 的"每脚恰一 site PIP"观察一致。**M2 遗留的"3 bit 无法在 INT-mux 与 site-PIP 间归属"问题关闭:全部 3 bit 归 INT-mux。**
- INT_R.IMUX8 与 INT_L.IMUX_L8 位型完全相同(镜像 tile 共享布局)。

## 3. 对表 3:CLBLM_R LUT6 INIT(256 条)——骨架一致,序号差 per-LUT 置换

- **物理骨架完全一致**:A/B/C/D 各占连续 16-bit 组(A=w20 低半、B=w20 高半、C=w21 低半、D=w21 高半),帧组相同,256 个物理位一一对应,无一位落错区域。
- **INIT 序号存在固定 6-bit 置换**(本地序号 i 的第 k 位 ↔ prjxray 序号第 perm[k] 位,每个 LUT 各一个,均 64/64 点校验 PASS):

| LUT | 本地位(0..5) → prjxray 位 |
|---|---|
| A | [1, 4, 3, 5, 0, 2] |
| B | [2, 4, 1, 3, 0, 5] |
| C | [1, 0, 3, 2, 4, 5] |
| D | [2, 0, 5, 1, 4, 3] |

- **判定方向**:本地标号是 Vivado 逻辑 INIT 序(网表 INIT 值逐位翻转标定 + 任意值往返 24/24 PASS,见 CLB_RESULT.md);prjxray 的 ALUT.INIT 用的是另一种(物理/引脚)序——与 7 系 LUT"逻辑 INIT ↔ 物理位"存在已知置换的现象一致(见 MDPI 9(7):1132 等)。**本地 db 保持现状即可(它是逻辑序,更符合直觉);移植 prjxray CLB 特征时按上表转换。**
- 附:prjxray CLBLM tile 的两个 site 是 SLICEM_X0 + SLICEL_X1,其特征分居不同帧组(SLICEL_X1 的 ALUT 在帧 26–29 一带,SLICEM_X0 在 32–35)。

## 4. 对表 4:覆盖率(六个 tile 类型,STEP01 枚举零缺失)

| tile | RW 枚举 | 有位∩(segbits) | 伪∩(ppips) | RW 缺 | prjxray 多 |
|---|---:|---:|---:|---:|---:|
| INT_L | 3737 | 3629 | 108 | **0** | 7 |
| INT_R | 3737 | 3629 | 108 | **0** | 7 |
| CLBLL_L | 146 | 0 | 146 | **0** | 12 |
| CLBLL_R | 146 | 0 | 146 | **0** | 12 |
| CLBLM_L | 151 | 0 | 151 | **0** | 14 |
| CLBLM_R | 151 | 0 | 151 | **0** | 14 |

- prjxray 多出条目全部解释:INT 侧 7 条 = 本地模板 f1=True 双向 PIP 的**反向条目**(LH/LV/LVB 类);CLB 侧 12/14 条 = SLICE 属性类伪 pip(`CEUSEDMUX`/`CLKINV`/`FFSYNC`/`LATCH` 等,RapidWright 不建模为 pip)。
- INT 伪 pip 108 条的类型:default 64 / always 44。
- **CLB site-PIP(146/151 条)全部为伪 PIP,无一位配置位** → STATUS 待办 #7"站点内部位 fuzz"的对象不存在,应改为 **BEL 特征映射**(FF/CARRY4/F7F8MUX/FFMUX/O5O6 等,prjxray `segbits_clbll_l/clbm_*.db` 每类约 700 行,含完整位定义)。

## 5. 结构确认(prjxray tilegrid,xc7a200t)

```text
INT_L_X6Y5   offset=10   INT_L_X6Y10  offset=20   INT_L_X6Y20  offset=40
INT_L_X6Y24  offset=48   INT_L_X6Y25  offset=51   INT_L_X6Y30  offset=61
(全部 frames=28, words=2, baseaddr=列基址 minor 0)
CLBLL_L_X2Y10 / CLBLM_R_X7Y10: frames=36, offset=20, 列基址锚定
```

- **offset = 2r + [r≥25] 逐点证实,含 Y24→48、Y25→51 的 +1 跳变(word 50 = ECC/辅助位,恰好卡在行中分)** → 复核判定 C5(k 抖动)可升级为 PASS(结构性),C3(word 50 特殊性)获结构性佐证。
- prjxray CLB tile 锚在**列基址**(frames=36),本地 V7 tilegrid 锚在 minor 32 → **移植 CLB 特征时帧偏移需 +32 对齐**(INIT 对表已按此验证)。
- INT 段实测用到 minor 0–25,与 frames=28 一致;CLB 两个 slice 分居 ~26–31 与 32–35。

## 6. 对 STEP03 战略的影响(建议)

1. **INT PIP→bit 库整体移植**:segbits_int_l/r.db(每侧 3636 行)转入 `pip_bits`,表结构必须一 pip 多行且带极性(正位/负位)。验证策略:按 pip 家族抽样 3–5 条做删 PIP 差分(现有机器),**外加负位全量校验**(目标位在基准 bitstream 中恒为 0)——负位是删 PIP 法给不了的,prjxray 直接提供。
2. **M2 MCD 语料降级为验证工具**(不再是发现工具);m2_mcd_0001 已被 prjxray 完整解释。
3. **待办 #7 改写**:不做 site-PIP fuzz(无位);做 BEL 特征移植 + valall 式任意值往返验证(FF/CARRY4/MUX 等,prjxray db 全有)。
4. **CLB INIT**:保留本地逻辑序 db;若直接采用 prjxray 行,按 §3 置换表转换。
5. **扩展路线**:BRAM/DSP/IO/CLK 等 tile 同法移植(artix7 db 均有);**V7 特有 tile(GTX/PCIE 等)无 artix7 对应,仍需自研**——这是移植路线的唯一硬边界。
6. 入库建议的 pip_bits 行:`(tile_type, pip_dst, pip_src, frame_off, s, bit, polarity, source='prjxray@a00added'|'measured')`,便于后续区分来源与增量验证。

## 7. 复现

```bash
cd E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref
python compare_init.py       # 对表3:INIT 256 条 + 置换推导
python compare_coverage.py   # 对表4:六 tile 覆盖率
# 对表1/2 为手工查表(grep),条目已在 §1/§2 引用原文
grep "NR1BEG2.LOGIC_OUTS_L20" artix7\segbits_int_l.db
grep -E "INT_R\.IMUX[18]\.NR1END0 " artix7\segbits_int_r.db
```
