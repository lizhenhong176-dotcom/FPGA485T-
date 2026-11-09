# S21 —— DSP 输入选择归属：判定实验结果（2026-11-08）

## 实验
3 个设计，唯一变量是 `din` 的 `PACKAGE_PIN`（p1/p3 = AF24，p2 = AP27），DSP 固定 `DSP48_X0Y0`、`DONT_TOUCH`、DRC 全豁免。

| 设计 | 用途 |
|---|---|
| p1 | din → AF24 |
| p2 | din → AP27 |
| p3 | 与 p1 完全相同（负对照） |

## 前置校验（本次通过）
- 两条 net 的 `ROUTE` **确实不同**：
  - p1：`IOB_IBUF0 … SW6BEG0 LV_L18 SW6BEG0×7 NW2BEG1 WL1BEG_N3 IMUX_L23 DSP_0_A0`
  - p2：`IOB_IBUF1 … SW6BEG0 LV_L18 SW6BEG0 SW2BEG0 SW6BEG0×6 SR1BEG1 WR1BEG3 IMUX_L23 DSP_0_A0`
- 负对照 p1 vs p3：**0 位差异**（确定性成立）。
- 上一轮失败的探针（a[0] vs a[1] 不约束引脚）只差 3 字节 ASCII 头 → 已验证是“没有强制引脚导致落点相同”，本轮用 `PACKAGE_PIN` 修掉了。

## 结果

```
p1 vs p2:  153 帧 / 630 字 / 1428 位
DSP 配置帧 (31986, 31987) 的差异 = 0 位      ← 关键
DSP 块内 (31960..31987) 的差异 = 166 位，全部落在 31963..31985（base+3..+25）
```

### 结论 1：DSP 的 A[0] 源选择**不占用 DSP 配置位**
路由串末尾是 `IMUX_L23 → DSP_0_A0`，且 DSP 配置帧（`base+26/+27`，即 AREG/MASK/CEAD 那些位所在的帧）**一位都没变**。
⇒ “哪根 INT 线喂 DSP 的 A0”这件事，**不需要任何 DSP 侧 mux 位**：最后一级是 INT tile 的 `IMUX_L23` mux（和 CLB 输入用的是同一族 IMUX），`IMUX_L23 → DSP_0_A0` 是**固定连接**（tileconn）。

### 结论 2（新发现）：DSP tile 自己也是布线 tile
定位块（`31960`）内**有 166 位随布线变化**，且在 `base+3..+25` 这些非配置帧里。
⇒ `DSP_L` / `DSP_R` 这两类 tile **除了 DSP48E1 配置，还承载穿行布线**（PIP）。
而 artix7 的 `segbits_dsp_l.db` **只有配置行（436 行 = 78 mux + 280 属性），没有一条布线行** —— 这块在参考库里同样是空白。

## 对后续实验的影响

1. **不需要为“DSP 输入选择”建表**：复用 INT 的 IMUX 表 + tileconn 即可（`IMUX_L23 ↔ DSP_0_A0` 一类固定连接，可从 tileconn 的 1,920 条 INT→DSP 线对里直接取）。
2. **需要新建的是 `DSP_L/DSP_R` 的布线族表**：只有当某条网**穿过** DSP tile 时才需要（本实验 166 位就属此类）。同理可推 BRAM tile 也会有。
3. S20 设计里的 E 组（输入 mux）可以改成**零成本**：不需要额外设计，只要把 tileconn 的 INT→DSP 线对登记成固定连接。
4. 真正的 PQ 级空白变成：**DSP/BRAM tile 的穿线 PIP fuzz**，规模比 INT 小（每 tile 28 帧），但属于全新开工。

## 复现命令
```bash
# 远端
JOB=p1 vivado -mode batch -source /opt/lzh/step05/dsp/build_ia2.tcl   # p2/p3 同理
python3 /opt/lzh/step05/dsp/diff_bit.py ia2_p1.bit ia2_p2.bit
```
