# S2/S3 — CLB 块基址与 site INIT 布局（受控实验定论）

日期：2026-10-27 晚。方法：S3 受控 RTL 实验（`s3_init.tcl`：lut_b LOC 到指定 SLICE/BEL，
post-synth `set_property INIT`，直接 `write_bitstream`），对同一位流对做逐位差分。
全部 12+11 个位流一次生成（`xargs -P 6`），数据在远端 `/opt/lzh/step03/s3site/`。

## 1. 实验矩阵与原始结果

| 探针 | 位置 | k0 (INIT[0]) | k1 (INIT[1]) | k2 (INIT[2]) | k3 (INIT[3]) |
|---|---|---|---|---|---|
| base10→k | SLICE_X10Y20 A6LUT | (31750, 40, 15) | (31751, 40, 15) | (31750, 40, 14) | (31751, 40, 14) |
| base11→k | SLICE_X11Y20 A6LUT | (31742, 40, 15) | (31743, 40, 15) | — | — |
| base52→k | SLICE_X52Y20 A6LUT | (32774, 40, 15) | (32775, 40, 15) | — | — |
| base53→k | SLICE_X53Y20 A6LUT | (32766, 40, 15) | (32767, 40, 15) | — | — |
| Y21 | SLICE_X10Y21 | (31750, 42, 15) | (31751, 42, 15) | — | — |
| Y21 | SLICE_X11Y21 | (31742, 42, 15) | (31743, 42, 15) | — | — |
| Y40 | SLICE_X10Y40 | (31750, 81, 15) | (31751, 81, 15) | — | — |

## 2. 定论

### 2.1 块基址（与 CSV 完全吻合）
- tile X10/X11（CLBLL_L_X10）band0 → block **0x420380 = 帧 31716**（36 帧，31716..31751）。
- tile X52/X53（CLBLM_L_X52）band0 → block **0x421280 = 帧 32740**。
- 块基址直接取 `phaseA/frame_index_far.csv`（1,183 块）——无需再用 probe 共识法。

### 2.2 site 实例 ↔ 帧窗口（关键新知识）
一个 36 帧 CLB 块内，**左右两个 site 用不同帧窗口区分，而不是用 word 区分**：

| site | 帧窗口（ALUT INIT 起始） | 实测 |
|---|---|---|
| 左 site（SLICE_XnY，n 偶） | **34/35**（窗口 32..35） | X10（CLBLL）与 X52（CLBLM）都是 34 |
| 右 site（SLICE_Xn+1Y，n 偶） | **26/27**（窗口 26..29） | X11 与 X53 都是 26 |

- **V7 与 artix7 的差异**：artix7 `segbits_clbll_l.db` 的 SLICEL_X0 窗口是 32/33；
  V7 的 CLBLL 左 site 实测 34/35（= artix7 **CLBLM** 表）。CLBLM 两代一致（34/35），
  X1 右 site 两代一致（26/27）。→ **V7 CLBLL 左 site 迁移时要用 artix7 CLBLM_X0 表**。

### 2.3 word 公式（受控实验推翻旧 probe 噪声）
```
word = 2*(Y%50) + (1 if (Y%50) >= 25 else 0)
```
实测：Y20→40、Y21→42、Y40→81、（旧数据吻合 Y0/10/150/160/210/220/310→+0，Y30/80/280→+1）。
左右两个 site **共享同一个 word**（X10 与 X11 在 Y21 都是 42）。

### 2.4 位布局（与 artix7 2×2 列模式一致）
`k0=(F,15), k1=(F+1,15), k2=(F,14), k3=(F+1,14)` …
四个 LUT 共用同一组 4 帧，bit 段错开：ALUT 起始 bit 15、BLUT 31、CLUT 47、DLUT 63。

### 2.5 旧 probe_bits 数据的污染结论
- 旧 `probes` 表的 `init_a/init_b` 元数据**不可信**（Y0 记录 1↔2 但实测位型是 1↔4；
  Y10 记录 1↔2 但帧对是 (34,35)=k8,k9 的位型）。
- 由此产生的「CLBLM +2 系统偏移」「word 奇偶随 site」等假象全部被受控实验推翻。
- **以后一律以受控差分（S3 方法）为准，不再用旧 probe 做布局推断。**

## 3. 对 S4（收编解码器）的输入
解码一个 CLB site 特征位：
```
frame = block_base(X所在列, band) + frame_off(由 site 左/右 + BEL 决定, 用上表映射)
word  = 2*(Y%50) + (Y%50>=25)
bit   = 表内 bit（与 artix7 相同，CLBLL 左 site 换 CLBLM_X0 表）
```
剩余工作：块基址全器件映射（用 CSV 的 FAR 字段解码 (top/bottom,row,col) 与 CLB 列对齐），
以及 AFFMUX 等非 LUT 家族的 word 公式复核。

## 4. 复现
远端：`/opt/lzh/step03/s3site/`（`s3_init.tcl` + `s3_run.sh` + `s3_run2.sh` + `s3_diff.py`）。
本地副本：`step03_pip/` 同名文件；结果文本 `step03_pip/s3_results.txt`、`s3_results2.txt`。

## 5. 勘误（S4 期间推翻的两条）
- **「V7 CLBLL 左 site 要用 artix7 CLBLM 表」作废**：根因是 SLICE→tile 归属错误
  （SLICE_X10/X11 其实属 CLBM_R_X7 的 X1/X1，SLICE_X8/X9 才属 CLBLL_L_X6）。
  修正后 CLBLL inst0=32..35、CLBM inst0=34..37、inst1=26..29——**与 artix7 表完全一致**。
- **word 公式补全 parity 项**：`word = 2*(Y%50) + (Y%50>=25) + parity`，
  parity 来自 artix7 表（CLUT/DLUT=1）。实测 CLUT Y20→41、Y40→82，B6LUT→40。
  word 50 永不产生 → 是 ECC word（100 配置位 + 1 ECC = 101 word，完全对称）。
- site 实例号不能取 getSites() 顺序（_L tile 颠倒）；**按 slice 名 X 奇偶**：
  偶 X → X0 实例，奇 X → X1。10 个实测 slice 全部符合。

