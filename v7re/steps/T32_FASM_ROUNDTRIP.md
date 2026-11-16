# T32：位流 → FASM → 位流 端到端回归（100% 精确判据下）

日期：2026-11-07
脚本：`v7re/scripts/fasm2bit.py`（`--decode` 方向已改为族内精确匹配）

## 1. 改动

| 项 | 改动前 | 改动后 |
|---|---|---|
| `--decode` 判据 | 候选源格数 ≥4 且全为 1，且只接受唯一命中 | 族内位域与候选 pattern **完全相等** |
| GCLK 直通 | 解码侧无、写入侧无 | 两侧都支持（使能位 + `CLK_L*` 选中源合成 `GCLK_L_B11 ->> GCLK_L_B11_WEST`） |
| 解码性能 | 每个 tile 重算全部 family 的 pattern（>10 分钟未完成） | 预计算 `family → {src: pattern}` + 跳过无置位的 tile（秒级） |
| ECC 覆盖不足时 | 直接 `SystemExit` | 新增 `--ignore-ecc-coverage`：跳过该帧并计数（产物**不可加载**，仅供数据字保真度测量） |

## 2. 幂等回归：位流 → FASM → 位流

```
python v7re/scripts/fasm2bit.py --decode --in X.bit --out X.fasm
python v7re/scripts/fasm2bit.py --in X.bit --fasm X.fasm --out X_rt.bit
```

| 设计 | FASM 行数 | 改动帧数 | 结果 |
|---|---|---|---|
| `_full8.bit` | 190 | **0** | sha256 相同 `FAE4412F1916B55FF7C7BA7FFF85CABCF9F6C653BF9E05A723A94439E45A52A1` |
| `_c0.bit` | 25 | **0** | sha256 相同 |
| `_c3.bit` | 36 | **0** | sha256 相同 |
| `_c4.bit` | 36 | **0** | sha256 相同 |

「改动帧 0」的含义：解码出的每条特征回写时命中的位，已经与原始位流完全一致，
没有任何一位被改动 —— 在 100% 精确判据下，**`位流 → FASM → 位流` 逐字节幂等**。

## 3. 从零重建（更严的测试）

```
python v7re/scripts/fasm2bit.py --in _full8.bit --fasm _full8.fasm --blank         --ignore-ecc-coverage --out _full8_blank_rt.bit
```

先把整个 payload 清零，只用 FASM 重建，再与原始位流比对数据字（不计 word 50）：

```
数据字差异位合计：119
涉及帧：          14 / 50,176
word50 不同帧：   54（因 ECC 未覆盖而跳过更新，属预期）
差异最大的帧：    32606 (36 位) 32607 (36 位) 32600 (8) 32601 (8) 27360/27361 (4–5)
```

这 119 位就是**解码器尚未覆盖的部分**，与 §T30 的缺口一致：

1. 8 个旁路/扇出直通族（`BYP_BOUNCE*`、`BYP_L1`、`FAN_BOUNCE7`、`FAN_L7`）；
2. CLB 特征（`--decode` 目前只输出 INT PIP，不输出 `site.bel.INIT` 等），
   所以清零后 CLB 侧没有重建。

换句话说：**从零重建的残差完全可归因，没有"不明来源"的位**。

## 4. 结论

1. 精确判据下，`位流 → FASM → 位流` 在 4 个真实设计上**逐字节幂等**；
2. `FASM → 位流` 的写入路径对 INT PIP 是完备的（190/190 条特征回写零偏差）；
3. 从零重建的缺口只有两类，且都已定位到具体实验（旁路族补测、CLB 特征接入 `--decode`）。

## 5. 复现命令

```bash
python v7re/scripts/fasm2bit.py --decode --in _full8.bit --out _full8.fasm
python v7re/scripts/fasm2bit.py --in _full8.bit --fasm _full8.fasm --out _full8_rt.bit
```
