import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
add = """### 2026-11-13 复盘：P1 的「换 CK_IN 序号」不可行 → 改用 25 个设计的普查

**P1 原设计不可行（三条摆放约束，全部实测报错）**
- `ERROR: [Place 30-152] Unroutable Placement! A MMCM / BUFHCE component pair is not placed in a routable site pair` —— MMCM 与 BUFHCE 必须同一时钟区域。
- `ERROR: [Common 17-69] 'BUFHCE_X0Y130' is not a valid site name` —— 该区域合法 BUFHCE 只有 `X0Y72..83`（早前 hclk8 已踩过）。
- `ERROR: [Place 30-176]` —— 跨区后时钟源离被锁定的负载太远，无法布线。
⇒ 在本器件上「保持负载不动、只把时钟改成另一个 CK_IN 序号」造不出来。

**替代证据：全库标记普查（`_remote_marker_census.py`，逐 bitstream 扫 74,400 个数据字，判「半字恰好等于标记值」）**
| 设计（HROW 源） | 数量 | 标记命中 |
|---|---|---|
| CK_IN 通路（`hclk4 g0..g2`、`hclk5 j0/k0..k6`、`hclk6 p0..p5`、`hclk8 m_def/p_72..p_83`、`ckpair a`） | **25** | **0**（唯一命中 (27360,99) `0x01001001` 是数据字偶合） |
| GCLK 通路（`clkmux3 y1_s0` k=1、`y2_s0` k=2） | 2 | 有：k=1 → (2589,24)/(2589,73) 高半 `0x800a0000`；k=2 → (2589,25)/(2589,74) 低半 `0x0000800a` |
| 混合（`hclk6 c_a/c_b`，`.pips` 同时有 `CK_IN_L13 ->> MUX_OUT_L0` 与 `GCLK0 ->> MUX_OUT_L8`） | 2 | 有 6 处 `0x0000800a`（对应它确实选了 GCLK0 的那条车道） |

**结论**
- 【数据事实】k=2 的位点（2589,25 低半）= 公式预测值，**独立复现了 §164 的坐标公式**（此前只实测 k=1/8/16/17/24/31）。
- 【数据事实】25 个 CK_IN 源设计、跨 3 个时钟列（col33/col75 等），**零标记**；只有真正选了 GCLK 的设计才出现标记，且 `c_a/c_b` 的「有/无」与它 `.pips` 里的源类别完全对得上。
- 判定：§165 的「CK_IN = 默认通路、不占置位字段」由【推断】升为**高置信（25 设计、3 列、零反例）**，但因为没有同 tile 同车道的严格对，**正式仍标【推断】**。
- P2（同车道叠加 CK_IN 使 `0x800a` 被清掉）在当前摆放约束下也造不出来：router 只会在该车道二选一，无法同时要求两条。

"""
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + add)
t = io.open(ST, encoding="utf-8", newline="").read()
print("bytes", len(t.encode("utf-8")), "ufffd", t.count("\ufffd"), "165 count", t.count("## 165."))