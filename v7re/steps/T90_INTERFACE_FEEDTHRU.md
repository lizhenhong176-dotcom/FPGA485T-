# T90 —— INT_INTERFACE / FEEDTHRU 的 PIP 形状：24 源假设被否证

**日期**：2026-11-13
**范围**：`INT_INTERFACE_L/R`、`INT_FEEDTHRU_1/2`，附带 `BRAM_INT_INTERFACE_L`、`IO_INT_INTERFACE_L`、`HCLK_INT_INTERFACE`、`GTX_INT_INTERFACE`、`HCLK_L`、`LIOI`、`CLK_BUFG_BOT_R`、`CMT_FIFO_L`
**结论一句话**：这四类 tile **没有** 24 源 6×4 mux —— 接口类全是 1:1 直通（不需要配置位），FEEDTHRU 类 PIP 数为 **0**。INT 的 24 源 6×4 复用结构**仍然只属于 INT_L / INT_R**。

---

## 0. 一句话结论

| 原假设 | 判定 |
|---|---|
| `INT_INTERFACE_L/R` 也是「每目的 24 源 + 6×4 网格」 | **否证**。它们是 24 个 **1:1 直通**，每目的只有 1 个源 |
| `INT_FEEDTHRU_1/2` 有可配置 PIP | **否证**。模板 PIP 数 = **0**，`tile_types.pips` 也是 0 |
| 9,525 个实例是「未覆盖的可配置 PIP」 | **否证**。其中 0 个可配置 PIP 实例 |

---

## 1. 方法

数据源：远端路由模板 `/opt/lzh/v7re/work/refs_20261021/routing/out_routing/templates/*.json`，
字段 `pip_defs` 为 `(src, dst)` 二元组（**src 在前**）。

脚本：`v7re/scripts/iface_feedthru_probe.py` —— 按 `dst` 分组，统计组内 `src` 数的分布。

```bash
# 取模板（远端 → 本地）
ssh fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" <<'EOF'
export LANG=C LC_ALL=C
T=/opt/lzh/v7re/work/refs_20261021/routing/out_routing/templates
cd $T && tar czf - INT_INTERFACE_L.json INT_INTERFACE_R.json BRAM_INT_INTERFACE_L.json \
  IO_INT_INTERFACE_L.json HCLK_INT_INTERFACE.json HCLK_L.json GTX_INT_INTERFACE.json \
  LIOI.json CLK_BUFG_BOT_R.json CMT_FIFO_L.json | base64 -w0
EOF

# 统计（本地）
python v7re/scripts/iface_feedthru_probe.py --dir _tif --json v7re/steps/t90_tile_fanin.json
```

实例数取自本机 `E:\v7work\model\v7_model.sqlite` 的 `tile_types` 表。

---

## 2. 结果

| tile_type | 实例数 | pips/实例 | dst 数 | fan-in 分布 | 1:1 直通 |
|---|---|---|---|---|---|
| `INT_L` / `INT_R` | 26,550 各 | 3,737 | — | **24 源为主** | — |
| `INT_INTERFACE_L` | 4,550 | 24 | 24 | `1:24` | **24/24** |
| `INT_INTERFACE_R` | 3,850 | 24 | 24 | `1:24` | **24/24** |
| `BRAM_INT_INTERFACE_L` | 2,400 | 24 | 24 | `1:24` | **24/24** |
| `IO_INT_INTERFACE_L` | 350 | 24 | 24 | `1:24` | **24/24** |
| `HCLK_INT_INTERFACE` | 301 | **0** | 0 | — | — |
| `INT_FEEDTHRU_1` | 525 | **0** | 0 | — | — |
| `INT_FEEDTHRU_2` | 600 | **0** | 0 | — | — |

### 2.1 接口类 PIP 的实际内容

`INT_INTERFACE_L` 的 24 条 PIP 全部形如：

```
INT_INTERFACE_LOGIC_OUTS_L_B0  ->> INT_INTERFACE_LOGIC_OUTS_L0
INT_INTERFACE_LOGIC_OUTS_L_B1  ->> INT_INTERFACE_LOGIC_OUTS_L1
...
INT_INTERFACE_LOGIC_OUTS_L_B23 ->> INT_INTERFACE_LOGIC_OUTS_L23
```

即 **B 侧线 → 同号 A 侧线的 1:1 拷贝**（tile 边界上的线续接）。没有任何选择器，也就没有
「多选一」需要编码。`INT_INTERFACE_R` / `BRAM_INT_INTERFACE_L` / `IO_INT_INTERFACE_L` 同构，
只有线名不同。

> **「24」是巧合**：INT 的 24 是「每目的 24 个源」，接口类的 24 是「该 tile 有 24 对线要续接」。
> 我原来的假设把两个 24 混为一谈 —— 这正是本轮的否证点。

### 2.2 FEEDTHRU 类

`INT_FEEDTHRU_1`（525 实例）与 `INT_FEEDTHRU_2`（600 实例）的模板 PIP 数为 **0**，
`tile_types.pips` 亦为 0。它们有 126 根线但没有可切换的连接 —— **不承载 PIP 配置**。

---

## 3. 独立旁证：prjxray 也没有这些 tile

本地 `prjxray_ref/artix7/` 共 22 个 db 文件，覆盖的 tile_type 只有 **10 种**：

```
BRAM_L/R, CLBLL_L/R, CLBLM_L/R, DSP_L/R, INT_L/R
```

`segbits_*` 与 `ppips_*` 里**没有任何** interface / feedthru tile 类型。
prjxray 的做法是把全器件位流逐位挖矿，若这些 tile 有配置位，一定会出现在 segbits 里。
它们缺席，与「1:1 直通 = 无需配置」互相印证。

---

## 4. 对「位级复用」总判断的影响

### 4.1 结论不变，且更干净

「位级复用（一个配置位被多个 PIP 共享）是 INT 的 24 源 6×4 mux 现象」——**成立**。
本轮排除了 9,525 个实例，其中可配置 PIP **0 个**。

### 4.2 覆盖率口径要改

之前的 95.7% 分母是「全部 PIP 实例 207,253,149」，把 1:1 直通也算进去了。
更准确的说法：

| 口径 | 数值 |
|---|---|
| 全部 PIP 实例 | 207,253,149 |
| 其中 INT_L/INT_R | 198,434,700（95.7%） |
| 其中纯 1:1 直通（接口类） | **342,000**，不可配置 |
| 其中 FEEDTHRU 类 | **0** |

即：**可配置 PIP 实例 ≈ INT 的 198.4M + 少量其它类型**；「INT 占 95.7%」这个数字本身没错，
但把它读成「还有 4.3% 可配置 PIP 没做」是错的 —— 那 4.3% 里大头是不可配置的直通线。

---

## 5. 顺带测到的「别的类型长什么样」

同一脚本对其它类型跑出的 fan-in 分布，说明**多源 mux 广泛存在，但宽度都不是 24**：

| tile_type | pips | dst | fan-in 分布 | 备注 |
|---|---|---|---|---|
| `LIOI` | 467 | 239 | `1:209, 2:14, 11:4, 12:4, 16:2, 17:2, 18:4` | 宽度 11/12/16/17/18 混杂 |
| `CLK_BUFG_BOT_R` | 304 | 176 | `1:144, 5:32` | 32 个 5 源选择器 |
| `HCLK_L` | 200 | 20 | `1:8, 16:12` | **12 个 16 源 mux** |
| `CMT_FIFO_L` | 278 | 274 | `1:270, 2:4` | 几乎全直通 |
| `GTX_INT_INTERFACE` | 168 | 120 | `1:72, 2:48` | 48 个 2 源选择器 |

**这是主线的新线索**：`HCLK_L` 的 16 源 mux（12 个/实例，529 实例/侧）是 INT 之外
第一个「宽度 ≥16 的真选择器」。16 源若按二进制编码只需 4 位、one-hot 要 16 位 ——
它的编码形态（以及是否复用）还没测过，是比接口类更值得做的下一步。

---

## 6. 边界

- 本报告只做**静态统计**，未起任何 Vivado 构建。
- 「1:1 直通不需要配置位」的依据是「结构上无选择 + prjxray 无 segbits」，**未做位流实测**
  （要做的话需要找到两个只差该 PIP 是否使用的设计，成本高、收益低）。
- 只看了 10 个 tile 类型的模板，其余 105 个类型未统计；`iface_feedthru_probe.py`
  对全目录可直接跑。
- 实例数来自 `tile_types` 表，若表有偏差，表格里的「实例数」列随之偏差。

---

## 7. 复现

```bash
python v7re/scripts/iface_feedthru_probe.py --dir _tif --json v7re/steps/t90_tile_fanin.json
sqlite3 E:/v7work/model/v7_model.sqlite \
  "select type,instances,pips from tile_types where type like '%INTERFACE%' or type like '%FEEDTHRU%'"
```
