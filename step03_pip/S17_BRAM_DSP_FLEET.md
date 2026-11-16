# S17 —— BRAM/DSP 大规模并行采集 + BRAM 配置块布局实测（2026-11-08）

## 1. 并行基础设施（已完成，可复用）

脚本 `E:\v7work\_harvest_bd.sh`（远端 `/opt/lzh/step04_h3.sh`）：
每个设计 = 1×RAMB18E1 @`RAMB18_X0Y1`(tile `BRAM_R_X5Y0`) + 1×DSP48E1 @`DSP48_X0Y0`(tile `DSP_L_X14Y0`)，
属性随设计号变化（INIT_00/01、DOA_REG、OPMODE、ALUMODE），布线自由。

采集范围（8 个 tile，含接口与相邻 INT）：

```
BRAM_R_X5Y0  BRAM_INT_INTERFACE_R_X5Y0  INT_R_X5Y0  INT_L_X6Y0
DSP_L_X14Y0  INT_INTERFACE_L_X14Y0      INT_L_X14Y0 INT_R_X13Y0
```

结果：

```
=== wall 226 s   === ok=32 fail=0     (MAXP=32，44 核 / 98 GB)
```

构建期踩坑（已修）：`DSP48E1` 的 `BREG/BCASCREG` 必须同值或 BREG=2+BCASCREG=1，否则
`ERROR: [DRC AVAL-3] ... BREG and BCASCREG set to incompatible values`；`write_bitstream` 前需
`CFGBVS/CONFIG_VOLTAGE`。

## 2. BRAM INIT 位位置（pair 实验，决定性）

两个设计**只差** `INIT_00`（0 vs 64 个 1），其余完全相同：

```
differing frames: 2
  frame 48254  words 5(8) 6(16) 7(8) 8(16) 9(16)      ← 64 位，正好等于翻转的位数
  frame 50176  words 1(16)                            ← 尾部（CRC/ECC 区）
```

## 3. BRAM 配置块跨度（span 实验）

两个设计**只差**全部 64 个 `INIT_00..INIT_3F`：

```
differing frames: 65
  frame 48254, 48256, 48258, ... 48380     ← 64 帧，步长 2，每帧都是 words 5,6,7,8,9
  frame 50176                              ← 尾部
```

**结论**：

| 事实 | 值 |
|---|---|
| `INIT_xx` 所在帧 | `base + 2*xx`（xx = 0x00..0x3F） |
| `INIT_xx` 所在字 | 5,6,7,8,9（每帧 5 字承载 256 位） |
| 已知 INIT_00 帧 | **48254**（该 BRAM 列 Y0 行） |
| INIT 区跨度 | 48254 → 48380 = **128 帧**（不是 28） |
| 尾部校验区 | frame 50176 word 1 |

**重要修正**：BRAM tile 的配置块**不是 28 帧**。artix7 `segbits_bram_*.db` 的 `frame_off` 只有 0..27，
那是**互连 mux 子区**；块内初始化数据另有 128 帧的空间。之前"BRAM/DSP = 28 帧"的推断被实测推翻。

## 4. 采集到的可用 PIP 样本（表外参考）

`BRAM_R_X5Y0` 上有 65 条被真正使用的 PIP，例如：

```
BRAM_R.BRAM_ADDRARDADDRU1->>BRAM_RAMB18_ADDRARDADDR0   (IBUF)
BRAM_R.BRAM_IMUX8_1->>BRAM_RAMB18_DIADI0               (RAMB18E1)
BRAM_R.BRAM_RAMB18_DOADO0->>BRAM_LOGIC_OUTS_B15_2      (RAMB18E1)
```

`DSP_L_X14Y0` 上约 60 条，例如 `DSP_L.DSP_IMUX16_1->>DSP_0_B7`、`DSP_L.DSP_0_P0->>DSP_LOGIC_OUTS_B21_0`。

**与 artix7 db 的差异（关键）**：V7 的源线命名带器件限定前缀
（`BRAM_RAMB18_ADDRARDADDR0`），artix7 db 是 `BRAM_CASCINBOT_ADDRARDADDRU0` / `BRAM_IMUX_ADDRARDADDRL0`。
即 **BRAM/DSP 的 mux 源名在 V7 与 artix7 不通用**，不能像 INT 那样直接迁移表，需要按 V7 自己的名字重新 fuzz 或做名字映射。

## 5. 下一步

1. DSP 同样做 pair/span 实验（变化 OPMODE/ALUMODE/INMODEREG），定位 DSP 配置块基址与位。
2. BRAM/DSP **互连 mux 表**：因源名不通用，需要自建 one-hot fuzz（每个 mux 的 20–25 个源各一版），32 并发下约 20–30 分钟一轮。
3. IOB（`IOB18S/M`、`ILOGICE2/OLOGICE2`）同样一轮，参考 prjxray 无对应 db，需全自建。

## 6. 复现

```
bash /opt/lzh/step04_h3.sh                # N=32 MAXP=32
bash /tmp/h3pair.sh                       # 只差 INIT_00 的两个设计
bash /tmp/h3span.sh                       # 只差全部 INIT_xx 的两个设计
python3 /tmp/span_diff.py                 # 打印差异帧
```
