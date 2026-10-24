# M1 — 地址锚点与列偏移（远程 Linux 实测）

状态：**M1 pilot PASS：7 个 region 锚点 + 20 个 blind holdout 全部命中**。
13×7 全矩阵尚未跑；当前模型已足以进入 M2，但完整矩阵仍建议补。

## 0. 最终校验

- 7 个 region base 全部实测，`X0Y0..X0Y6`；`X1Y*` 共用同 Y 的 base。
- 20 个 blind holdout（未参与拟合，覆盖 X0/X1、全部 7 个 Y region）：
  `frame residual = +2` 20/20，`word` 20/20 精确匹配。
- 47 个历史 probe：45 个 residual +2，2 个 residual 0；word 无错误。
- 模型 DB：`probes` 72，`probe_bits` 1248，`region_bases` 14，
  `column_offsets` 420（30 列 × 14 region）。


## 1. 本轮做了什么

在远程 Linux（`fpga` → `172.17.71.129`）上，用 `scripts/run_batch.py` 跑了
7 个 `SLICE_X10Y* / A6LUT` 锚点，覆盖全部 7 个 Y 方向 clock region：

```bash
cd /data/lzh/v7re
export FPGA_WORK=/data/lzh/v7re/data/m1
export VIVADO_BIN=/data/lzh/Xilinx/Vivado/2017.2/bin/vivado
export XILINXD_LICENSE_FILE=/data/lzh/Xilinx/Vivado_license_2037.lic

/data/lzh/venv/bin/python -u scripts/run_batch.py \
  --manifest data/m1/manifests/m1_pilot.csv \
  --workdir-root /data/lzh/v7re/data/m1/probe \
  --out /data/lzh/v7re/data/m1/batches/m1_pilot.json
```

`--workdir-root` 必须是绝对路径；相对路径会让 Vivado 找不到 `build.tcl`。
没有设置 `XILINXD_LICENSE_FILE` 时，`synth_design` 会报
`A valid license was not found for feature 'Synthesis'`。

## 2. 实测 region base

这些是 A6LUT **4 帧组的第一帧**，不是首个 diff 帧。A6LUT INIT bit0 的首个
diff 帧稳定地比 base 晚 2 帧。

| clock region | rows | base | 首个 diff |
|---|---:|---:|---:|
| X0Y0 | 0..49 | 31748 | 31750..31751 |
| X0Y1 | 50..99 | 26502 | 26504..26505 |
| X0Y2 | 100..149 | 272 | 274..275 |
| X0Y3 | 150..199 | 5518 | 5520..5521 |
| X0Y4 | 200..249 | 10764 | 10766..10767 |
| X0Y5 | 250..299 | 16010 | 16012..16013 |
| X0Y6 | 300..349 | 21256 | 21258..21259 |

`X1Y0..X1Y6` 与同 Y 的 X0 区域共用 base。X 方向偏移在 X0→X1 边界连续，
因此 `region_bases` 里 14 行是 7 个实测值 + 7 个 X1 别名。

## 3. 地址模型

```text
region = clock_region(site)
base   = region_bases[region]
frame0 = base + column_offsets[region][X]
word   = 2 * (Y % 50) + (1 if (Y % 50) >= 25 else 0)
```

- `column_offsets` 共 30 个 X：13 个来自 Y=160 实测（X0,10,20,40,60,80,100,
  120,140,160,180,200,220），17 个由历史 probe 反推（X2,3,4,42,44,49,53,
  151,152,154,155,156,157,165,214,219,221）。
- 7 个锚点的 word 全部等于 `2*(Y%50)+half`：Y10/60/160/210/310 为上半
  （word 20），Y130/280 为下半（word 61）。
- 47 个历史 probe 全部通过：45 个 frame residual +2，2 个 residual 0；
  word 无错误。

## 4. 导入与校验

```bash
/data/lzh/venv/bin/python scripts/import_m1.py \
  --db data/model/v7_model.sqlite \
  --root data/m1/probe \
  --root data/m1/holdout/p1 \
  --root data/m1/holdout/p2 \
  --root data/m1/holdout/p3 \
  --root data/m1/holdout/p4 \
  --old-db /data/lzh/v7re/work/refs_20261021/db/v7.sqlite
```

结果：`M1 IMPORT PASS`，`old_probes_checked=47`，`old_probes_skipped=0`，
`errors=[]`，`old_errors=[]`；另有 20 个 holdout 全部通过。

DB 计数（`data/model/v7_model.sqlite`）：

- `probes` 72，`probe_bits` 1248
- `region_bases` 14，`column_offsets` 420（30 列 × 14 region）
- `sites` 86,022，`site_pins` 5,489,706

## 5. 还没做的全矩阵

M1 计划原要求 13 个 X × 7 个 region = 91 个独立 probe。本轮用 7 个
region 锚点 + 30 个 X 列表 + 20 个 blind holdout（20/20 命中）达到了
pilot 门槛；17 个非 Y160 列偏移来自历史 probe，属于标定证据，不是
独立扫描。若要把 M1 做到“无争议”，再补：

1. 在 X0Y0..X0Y6 各跑 13 个 X（或每个 region 抽 3 个 X），验证
   `column_offsets` 在 Y 方向不随 region 变；
2. 把 holdout 扩到 50 个以上，并包含非 A6LUT 的 BEL；
3. 通过后再把 `site_frames` 填成可查询的完整地址表，进入 M2（单 PIP 隔离）。

## 6. 关键文件

远程：

- `data/m1/probe/SLICE_X10Y*/A6LUT/result.json`
- `data/m1/batches/m1_pilot.json`
- `data/m1/m1_pilot.log`
- `data/model/v7_model.sqlite`
- `scripts/import_m1.py`

本地：

- `v7re/scripts/import_m1.py`
- `v7re/README.md`（M1 region 表）
- `v7re/ARCHITECTURE.md`（7 个 region）
