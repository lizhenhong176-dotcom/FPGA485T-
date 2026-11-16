# T42：时钟 mux 批量实测 —— BUFGCTRL 选择位的公式

日期：2026-11-08
远端：`/opt/lzh/v7re/work/clkmux`（10 个构建，8 路并发，墙钟约 2 分钟）

## 1. 结果总表

| 对比 | 变量 | 数据差格 | 帧 | PIP 相同 |
|---|---|---|---|---|
| `g8_s0` vs `g8_s1` | BUFGCTRL_X0Y8 的 S0/S1 | **2 位** | 7834, 7835 | ✅ |
| `g16_s0` vs `g16_s1` | BUFGCTRL_X0Y16 的 S0/S1 | **2 位** | 13080, 13081 | ✅ |
| `g24_s0` vs `g24_s1` | BUFGCTRL_X0Y24 的 S0/S1 | **2 位** | 13080, 13081 | ✅ |
| `mx_s0` vs `mx_s1` | BUFGMUX X0Y16 的 S | **2 位**（同帧） | 13081 | ✅ |
| `sw_a` vs `sw_b` | 输入脚互换（a↔b） | 2 位 | 13080, 13081 | ❌ |
| `g16_s0` vs `g8_s0` | 换 site（选择相同） | 76 位 | 多 | ❌ |

## 2. BUFGCTRL：选择位有固定公式

三 site 全部是 **2 位**，且位置图案完全一致：

```
(frame_f,      word_w, bit 11)
(frame_f + 1,  word_w, bit  3)
```

| site | frame_f | word_w |
|---|---|---|
| `BUFGCTRL_X0Y8` | 7834 | 97 |
| `BUFGCTRL_X0Y16` | 13080 | 0 |
| `BUFGCTRL_X0Y24` | 13080 | 4 |

即：**位偏移固定（bit 11 / bit 3），只有 (frame, word) 随 site 变化**。
这与 INT mux 的「行格 + 列格」是同一类结构——选择位在字内的位置是常量，位置信息编码在帧/字里。

## 3. BUFGMUX 与 BUFGCTRL 不是同一编码

`BUFGMUX` 的两个位落在**同一帧同一字**：`(13081, word 0, bit 2)` 与 `(13081, word 0, bit 11)`。
而 `BUFGCTRL` 是跨两帧（bit 11 / bit 3）。两者原语不同、编码不同。

## 4. 换 site 会连带换时钟树

`g16_s0` vs `g8_s0`（选择相同、只换 BUFGCTRL 位置）：76 位、PIP 列表不同——
因为 BUFGCTRL 换 site 意味着换时钟区域，HROW/HCLK 整条树都变。**这条不构成 PIP 测量，仅作旁证。**

## 5. 输入脚互换：PIP 不同，作废

`sw_a`（a→I0, b→I1）vs `sw_b`（b→I0, a→I1）：2 位差、但 PIP 列表不同
（两个不同引脚分别接到 I0），说明差分里混了 IOB/接口路径。按 T40 协议，此对比**不作结论**。

## 6. 结论

1. **BUFGCTRL 的 I0/I1 选择 = 2 位**，公式 `(f, w, 11)` + `(f+1, w, 3)`；
2. `(f, w)` 由 site 决定（X0Y8 → (7834, 97)、X0Y16 → (13080, 0)、X0Y24 → (13080, 4)）；
3. BUFGMUX 用另一套编码（同帧同字 bit 2 / bit 11）；
4. 手法 A 在时钟 mux 上**可稳定复现**：3/3 site 都给出 2 位且 PIP 逐行相同。

## 7. 下一步

按本表把剩余 site（X0Y0/X0Y32/X0Y40/X0Y48）与 BUFHCE、HROW 的 CK_MUX 补齐，
即可把时钟树的 mux 层位映射基本收全。
