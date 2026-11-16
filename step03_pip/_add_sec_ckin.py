import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
nums = [int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)]
n = max(nums) + 1
sec = """## __N__. CK_IN 源在 HROW 家族里没有置位字段（2026-11-12）

**问题**：`CLK_HROW_CK_MUX_OUT_L*` 62 个源里，32 个 GCLK 已由 §164 的公式闭合（实测 19/32），剩余 30 个（`CK_IN_L0..13` 14 + `CK_IN_R0..13` 14 + `CK_INT_0_{0,1}` 2）的槽位在哪里？

**实验（受控对，`/opt/lzh/v7re/work/ckpair`）**
- `a_mmcm.bit`：`MMCME2_ADV_X0Y6` → `BUFH` → `FDRE @ SLICE_X0Y100`；`.pips` = `CLK_HROW_TOP_R_X192Y338.CLK_HROW_CK_IN_L13 ->> CLK_HROW_CK_MUX_OUT_L0`。
- `b_bufg.bit`：`BUFGCTRL_X0Y1` → 同一 `FDRE @ SLICE_X0Y100`；`.pips` = `..._R.CLK_HROW_R_CK_GCLK1 ->> CLK_HROW_CK_MUX_OUT_L8`。
- 两者不同车道（L0 vs L8），故**不是严格受控对**（共 159 个差异字），但足以做「标记字段在不在」的定性判据。

**标记扫描（全比特流，74,400 个数据字）**
| 标记值 | 含义 | a（CK_IN13 源） | b（GCLK1 源） |
|---|---|---|---|
| `0x800a` 低/高半 | 组 A | **0 处** | (2589,73)、(7835,24)、(7835,73) |
| `0x4005` | 组 B | 0 处 | 0 处 |
| `0x2002` / `0x1001` | 组 C / D（预测） | 0 处 | 0 处 |

（`a` 里唯一命中 `0x1001` 的 (27360,99) 是数据字 `0x01001001` 的低半偶合，不是标记。）

**判读**
- 【数据事实】以 CK_IN 为源时，HROW 家族的选择字段**全零**；以 GCLK 为源时才出现 `0x800a` 一热标记。
- 【推断】`CK_IN_L/R*` 与 `CK_INT_0_*` 是**默认通路**：HROW mux 的置位字段只编码「改成某个 GCLK」，不编码选哪个 CK_IN —— 后者由**上游 `HCLK_CMT_MUX_CLK_<k>` 决定**（`CK_IN_L0` ← `HCLK_CMT_MUX_CLK_0`，`tileconn.json` `grid_deltas [104,0]`）。
- 与容量账自洽：32 个 GCLK 恰好填满 2 帧 × 8 槽 × 2 组 = 32 槽，没有给 30 个 CK_IN 留槽。

**可反驳预测（未做，下一步）**
- P1：把时钟源换成另一个 CK_IN index（如 `CK_IN_L0`），HROW 侧位流应**逐字不变**，只有 `HCLK_CMT` 侧变。
- P2：若在 `b` 里再叠加一个 CK_IN 源（同车道 L8），`0x800a` 应被清掉。
- 任一预测不成立 ⇒ 上述「默认通路」判读作废，CK_IN 仍需独立槽位。

**边界**：单车道对比（L0 vs L8）、单设计对；`CK_INT_0_*` 完全未测。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
print("added section", n)
t = io.open(ST, encoding="utf-8", newline="").read()
print("bytes", len(t.encode("utf-8")), "ufffd", t.count("\ufffd"), "headings", len(re.findall(r"(?m)^## \d+\.", t)))