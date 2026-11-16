# T69：BRAM 的 180 条真 PIP —— 结构、prjxray 预测、V7 验证受阻

日期：2026-11-10

## 一、结构：60 个三源 mux

BRAM_L 模板 974 条 PIP，减去 ppips 794 条，剩 **180 条真 PIP**，全部形如

```
BRAM_ADDRARDADDR{L,U}<0..14> <- BRAM_CASCINBOT_ADDRARDADDRU<n>
                             | BRAM_CASCINTOP_ADDRARDADDRU<n>
                             | BRAM_IMUX_ADDRARDADDR{L,U}<n>
```

- 60 个目的线 = ADDRARDADDR 的 L/U 各 15 位 + ADDRBWRADDR 的 L/U 各 15 位；
- 每个 3 源，合计 180 条；
- 语义：地址来自「下半 BRAM 的级联」「上半 BRAM 的级联」还是「fabric IMUX」。

## 二、prjxray（A7）给出的编码形状

`prjxray_ref/artix7/segbits_bram_l.db` 里 180 条一一对应，每个 mux 用 **3 位**：

| 源 | 位型（A,B,C） |
|---|---|
| `BRAM_IMUX_...` | 0 0 0 |
| `BRAM_CASCINBOT_...` | 1 0 1 |
| `BRAM_CASCINTOP_...` | 1 1 0 |

例：`BRAM_ADDRARDADDRL0` 用 A7 的 `26_32 / 26_33 / 26_35` 三位。
这是 A7 的位置编号，V7 的位号需要实测；但**编码形状（3 位、IMUX=000）可以直接作为 V7 的待验预测**。

## 三、这些 PIP 在正常设计里确实被用到

`_bramcasc/c0`（单 RAMB36E1、32 位数据、16 位地址，地址位 15 未按 DRC 要求拉 1）虽然 bitgen 被
DRC 拦下（`PDCN-135/136`：`RAM_EXTENSION=NONE` 时 `ADDRARDADDR[15]` 必须接 LOGIC 1），
但 **place/route 已完成**，导出的 `c0.pips` 里就能看到：

```
addr_a_IBUF[6]  BRAM_R_X29Y105/BRAM_R.BRAM_CASCINBOT_ADDRARDADDRU6->BRAM_ADDRARDADDRL6
addr_a_IBUF[6]  BRAM_R_X29Y105/BRAM_R.BRAM_CASCINBOT_ADDRARDADDRU6->BRAM_ADDRARDADDRU6
addr_b_IBUF[6]  BRAM_R_X29Y105/BRAM_R.BRAM_CASCINTOP_ADDRBWRADDRU6->BRAM_ADDRBWRADDRL6
addr_b_IBUF[9]  BRAM_R_X29Y105/BRAM_R.BRAM_CASCINTOP_ADDRBWRADDRU9->BRAM_ADDRBWRADDRL9
```

**结论：这 180 条不是休眠结构，普通设计里 Vivado 就在用它们**（RAMB36 的上下半地址就是级联过来的）。
这解释了为什么 T64 的 8 个引脚开关实验里一个都没碰到它们 —— 那是另一类位。

## 四、V7 验证受阻的两点

1. **`RAMB36E1` 没有 `CASCADE_ORDER_A/B` 参数**（2017.2 报 `Synth 8-3438`），
   无法用参数直接切级联；
2. `RAM_EXTENSION_A=NONE` 时 `ADDRARDADDR[15]` 必须接 1（`DRC PDCN-135/136`），
   要造级联设计必须改成 `RAM_EXTENSION_A("LOWER"/"UPPER")` 并成对堆叠两个 RAMB36。

## 五、下一步的正确配方

1. 设计 A：单 RAMB36E1，`RAM_EXTENSION=NONE`，`ADDRARDADDR({1'b1, addr[14:0]})` —— 基线，IMUX 路径；
2. 设计 B：两个 RAMB36E1 堆叠，`RAM_EXTENSION_A` 分别 `LOWER`/`UPPER`，地址 16 位 —— 强制级联；
3. 差分 A↔B，只看 BRAM tile 帧：预期得到 60 组、每组 3 位的 encoding，
   再与 prjxray 的 `000/101/110` 形状比对。

## 六、覆盖意义

| 类别 | 真 PIP 数 | 状态 |
|---|---|---|
| INT | 3,629 | 已 100% 解码（172/172 族） |
| BRAM | 180 | 结构 + 形状已知，V7 位号待测 |
| DSP | 794 → 抽查 8 个为 one-hot | 部分 |
| CLB | 0 | 全为 ppip，无位 |
