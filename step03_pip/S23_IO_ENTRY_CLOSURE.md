# S23 —— IO 入口段收口：IO_INT_INTERFACE 无选择位，缺口在拓扑不在编码

日期：2026-11-08

## 结论

1. **`IO_INT_INTERFACE_L`（700 tile）没有可配置 mux**：每行 24 条 PIP，**全部 1 源**（固定直通）。
2. **`LIOB18` 同样全是 1 源直通**（10 条）。
3. **`LIOI` 里有 30 个多源家族，但全部是时钟相关**（`IOI_ILOGIC*_CLK/CLKB`、`IOI_OCLK*`、`IOI_OLOGIC*_CLKDIV*`、以及 2 源小 mux `OFB/TFB/O/OB`），**没有一条是“IOB → fabric 数据通路”的选择**。
4. IOB→fabric 的数据通路是**纯固定连接**：`IOB → LIOI(ILOGIC) → IO_INT_INTERFACE(固定 24 线) → INT_L_X32 的 LOGIC_OUTS_L18（普通 INT mux 的源）`。

⇒ 之前 S10 里“A4 网在 IO 入口走不通”，**不是缺配置位表，而是缺 tileconn 拓扑**（prjxray 的 tileconn.json 里 INT_INTERFACE 相关对为 0 条）。

## 实测数据

同一设计（LUT@SLICE_X47Y52，din=IOB_X0Y50）导出各 tile 的全部 PIP：

| tile | pips | 家族 | 源数分布 |
|---|---|---|---|
| `INT_L_X32Y50` | 3,737 | 216 | 1×44, 20×96, 25×64, 16×6, 18, 17, 12, 11, 10, 9 |
| `INT_R_X33Y50` | 3,737 | 216 | 同上 |
| `IO_INT_INTERFACE_L_X32Y50` | 24 | 24 | **全 1 源** |
| `LIOB18_X81Y54` | 10 | 10 | **全 1 源** |
| `LIOI_X82Y54` | 467 | 239 | 1×209, 2×14, 11×4, 12×4, 16×2, 17×2, 18×4 |

### LIOI 的 30 个多源家族（全部时钟类）

| 家族 | 源数 | 源 |
|---|---|---|
| `IOI_ILOGIC{0,1}_CLK` / `_CLKB` | 18 | `IOI_IMUX20/22_*`、`IOI_IOCLK0..3`、`IOI_LEAF_GCLK0..5`、`IOI_PHASER_TO_IO_{I,O}CLK`、`IOI_RCLK_FORIO0..3` |
| `IOI_OCLK_0/1`、`IOI_OCLKM_0/1` | 16–17 | 同上（OCLK 侧） |
| `IOI_OLOGIC{0,1}_CLKDIV(B/FB)` | 11–12 | `IOI_IMUX8_*`、`IOI_LEAF_GCLK0..5`、`IOI_RCLK_FORIO0..3` |
| `IOI_ILOGIC{0,1}_CLKDIVP` | 2 | `IOI_CLK0_*`、`IOI_PHASER_TO_IO_ICLKDIV` |
| `LIOI_OLOGIC{0,1}_OFB/TFB`、`IOI_ILOGIC{0,1}_O`、`LIOI_O0/O1`、`IOI_*_OCLKB` | 2 | 配对旁路（`D1/OQ`、`T1/TQ`、`D/DDLY`、`ODELAY0/OQ`） |

## 对既有产物的影响

| 项 | 状态 |
|---|---|
| S10 的 IO 入口缺口 | **可解释并可直接补**：手工加 3 类 tileconn 对（LIOI→IO_INT_INTERFACE、IO_INT_INTERFACE→INT_L、IOB→LIOI），不必再 fuzz |
| 位表新增工作 | **0**（数据通路无位） |
| 唯一遗留 | 30 个时钟家族若要做 ISERDES/OSERDES/IDELAY 逆向才需要，共约 300 个源 |

## 复现
```bash
# 远端
JOB=y50 vivado -mode batch -source /opt/lzh/step06/iof/build3.tcl   # 内含 get_pips 导出
python3 /tmp/lii.py    # 打印 LIOI 多源家族
```
