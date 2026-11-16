# S50 OLOGIC 是“特征位组”，不是家族

日期 2026-11-10。基线 `pass3`，变体矩阵 6 个（off1 / off_ce / off_sr / off_init1 / tbuf_ff / tbuf），统计窗口取 pad 行字（w0/w1/w16/w17），剔除 w50。

## 1. 判据回顾（INT 家族的定义）

INT 家族的成立条件是三条同时满足：`N = a × b`（源数 = 组数×成员数）、`K = a + b`（位池 = 组数+成员数）、**每源恰 2 位**（一组位 + 一成员位）。

## 2. OLOGIC 实测：三条全部不满足

| 变体 | 语义 | 命中格数（io72，pad 行字） |
|---|---|---|
| `off1` | FDRE + IOB TRUE（OLOGIC OFF） | 25 |
| `off_ce` | 同上 + CE 由 `din` 驱动 | 39 |
| `off_sr` | 同上 + R 由 `din` 驱动 | 31 |
| `off_init1` | 同上 + `INIT=1` | 36（与 init0 差 **1 格**） |
| `tbuf_ff` | T 由 FDRE 驱动 | 32 |
| `tbuf` | 纯 OBUFT（无寄存器） | 3（窗口内） |

- 4 个 FF 变体的**共有核心 = 20 格**：`(0,7)(1,6)(7,16)(15,17)(28,1)(28,19)(28,25)(31,1)(31,19)(31,25)(31,26)(31,28)(32,12)(32,16)(32,30)(33,11)(33,15)(33,17)(33,29)(33,31)`；
- `CE` 额外带来 17 格、`SR` 10 格，二者**部分重叠但互不相同**；
- `INIT` 只差 **1 格：(off33, bit1)** —— 干净的单位开关；
- 三态（无寄存器）只有 3 格在窗口内 —— 与“OLOGIC 被使用”完全分离。

结论：**每源不是 2 位，位数与源数不存在 a×b 关系** ⇒ IO 逻辑侧不是 one-hot 家族，而是“**单位开关 + 特征位组**”（与 artix7 `segbits_liob33` 的形态一致：属性→位列表，无家族）。

## 3. 编码分类最终版

| 形态 | 对象 | 判据 | 反解方法 |
|---|---|---|---|
| 家族（one-hot 网格） | INT PIP、IMUX、AFFMUX、DSP GND/VCC、BRAM CASCIN | `N=a×b, K=a+b, 每源 2 位` | C1/C2 + CSP |
| 单位开关（1 位=1 特征） | OLOGIC INIT、ZINI/ZRST、BYP/FAN 旁路、GCLK 直通 | 位独立可共现 | 查表/直接读位 |
| 码字（值编码） | PULLTYPE、DRIVE、SLEW、IOSTANDARD、ZALMOST_*、LUT INIT | 每值一组固定位，**无网格律** | 码表比对 |
| 时钟网络 | edge30 off26..29 | 与“是否有时钟进 fabric”相关 | 静态推断 |

## 4. 对解码器的直接含义

```
family_table : 走 CSP（互斥选择）
feature_bits : 走位读取（可共现，不能当“选择”处理）
code_table   : 走码表比对
```

若把 IO 侧误当家族塞进 CSP，会因为“位可共现、每源位数不恒定”而产生大量 UNEXPLAINED/CONFLICT —— S44 之前 emit.py 的 CLB 空结果是同类教训（LUT INIT 64 源不互斥，不能要求唯一）。
