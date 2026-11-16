# S58 · BUFIO / BUFR / BUFMRCE 配置位实测（8 设计）

日期：2026-11-11
基线：`t_base`（IBUFG→BUFR(BYPASS,CE=1,CLR=0)+FDRE）
设备：xc7vx485tffg1157-3，远端 `/opt/lzh/step15/clk2/`
比对：大端解析，逐帧逐字 diff（帧号绝对）

## 0. 三条结论

1. **BUFIO 没有任何配置位** —— `t_bufio` 与 `t_base` 的位流**逐位完全相同**（0 差异）。
   BUFIO 是纯无源分发器，无可配置状态。
2. **BUFR 有三个可配置项**：`CE`、`CLR`（**取反存储**）、`BUFR_DIVIDE`（码字）。
3. **BUFMRCE 的 CE / INIT_OUT 不编码** —— `CE=0/1` 与 `INIT_OUT=0/1` 三种变体位流**只差一个 word 50 的值**，
   没有对应的配置位组。BUFMRCE 的作用纯粹是布线可达性。

## 1. 构建过程中撞到的三个门（复现必读）

| 现象 | 原因 | 处理 |
|---|---|---|
| `ERROR: [Place 30-134] A BUFR can only drive loads in the same clock region` → `Place 30-99 IO Clock Placer failed` | BUFR 驱动了别处的 OBUF（跨 region） | BUFR 输出**悬空**（`wire unused_b = b;`）+ `DONT_TOUCH`，不接 IO |
| `ERROR: [Place 30-176] Unroutable Placement`（上一轮） | BUFR 驱动被 LOC 锁在 fabric 的 FF | 同上，BUFR 输出不驱动 fabric |
| `WARNING: No drc_checks matched for ... PLACE-176` 且脚本中止 | 2017.2 里没有 `PLACE-176` 这个 DRC id | 不要豁免它；`get_drc_checks` 返回空会让脚本退出 |

另外：`BUFR_DIVIDE` 用字符串参数（`"BYPASS"/"2"/"3"`），不是整数。

## 2. BUFR CE / CLR（帧对 + 取反）

基线 vs `t_ce0`（CE=1→0）：

```
f=27322 w=44  0x00000000 -> 0x00020000   bit 17 置 1
f=27323 w=44  0x00000000 -> 0x00002000   bit 13 置 1
f=27342 w=45  0x00000000 -> 0x00008000   bit 15 置 1
f=27346 w=45  0x00000000 -> 0x00008000   bit 15 置 1
```

基线 vs `t_clr1`（CLR=0→1）：

```
f=27322 w=46  0x00020000 -> 0x00000000   bit 17 清 0
f=27323 w=46  0x00002000 -> 0x00000000   bit 13 清 0
f=27342 w=47  0x00008000 -> 0x00000000   bit 15 清 0
f=27346 w=47  0x00008000 -> 0x00000000   bit 15 清 0
```

⇒ **CE 与 CLR 各占一个 cell，且 CLR 是反向存储**：`CLR=0` 时该 cell = 1，`CLR=1` 时 = 0。
（CE 同向：`CE=1` → 0，`CE=0` → 1。所以 **CE 也是反向存储**，两者都是“低有效”编码。）

同一逻辑 cell 在两个帧里出现两次（`(27322,b17)` 与 `(27323,b13)`，位差 4、帧差 1），
与 CMT 属性平面的“成对镜像”是同一写法。

## 3. BUFR_DIVIDE 是码字（且证实 word 50 在这里是配置字）

`t_div2` / `t_div3` 相对基线的差异**只有两帧的 word 50**：

| 设计 | f=27354 w=50 | f=27355 w=50 |
|---|---|---|
| base (BYPASS) | `0x00081cf1` | `0x0000156f` |
| div2 | `0x000a0540` | `0x00024570` |
| div3 | `0x000a0540` | `0x00015571` |

- `f27354` 的值在两个 D 变体里相同 ⇒ 它是“**DIVIDE ≠ BYPASS**”的使能码；
- `f27355` 才是分段码（div2 与 div3 差 bit16/17 与 bit1–4）。

**这是一条重要修正**：此前（S27/S35）结论是“word 50 = 帧级校验/ECC”。
本实验证明 **在 IO/时钟块里 word 50 是真实配置字**（否则两个不同属性的位流不可能只在 w50 有差别）。
⇒ 正确表述：`word 50` 的性质**按块类型而定**——fabric 块（CLB/INT/BRAM/DSP）里它是校验/ECC，
IO/时钟块（io72/edge30/CMT）里它是普通配置字。

## 4. BUFMRCE：只有布线效应，没有端口位

`t_mrc`（IBUFG→BUFMRCE→BUFR）相对基线差异 12 帧 / 23 字，其中真正的数据位：

```
f=27255 w=48  bits {8, 11}          置 1
f=27364 w=48  bit 27                置 1
f=27365 w=48  bit 25                置 1
f=27390 w=49  bit 31                清 0（基线有，mrc 无）
f=27393 w=49  bit 3                 置 1
```

其余全是 word 50（帧 27357/27358/27390–27393/27405/27406）与 CMT 帧 27392/27393 的 w58/w59
—— 属于“时钟布线改变后 bitgen 顺带更新的辅助字/CMT 布线位”，不是 BUFMRCE 的端口属性。

**CE / INIT_OUT 不编码**的证据：`t_mrc` vs `t_mrc_ce0` vs `t_mrc_out1`，
三者差异**只有 1 个字**（`f=27393 w=50`，三个不同值 `0x180015e4 / 0x08000518 / 0x38001539`）。
一个端口不可能只用“一个 word-50 数值”来表达，且没有任何独立 cell 变化 ⇒ 该端口无配置位。

## 5. 站点归属（帧 → 块）

| 帧 | 块 | 归属 |
|---|---|---|
| 27322/27323 | io72 块 base 27322（off 0/1） | BUFR CE/CLR cell |
| 27342/27346 | 同上（off 20/24） | 第二份镜像 cell |
| 27354/27355 | 同上（off 32/33） | BUFR_DIVIDE 码字 |
| 27255 | band1 CLB 块 base 27250（off 5） | BUFMRCE 位 |
| 27364/27365 | io72（off 42/43） | BUFMRCE 位 |
| 27390/27393 | io72（off 68/71） | 布线辅助 |
| 27392/27393 | CMT 配置帧（io72+70/+71） | CMT 布线模式 | 

⇒ **时钟分发三件套的配置位都落在 IO 列块（io72）里**，与 CMT（io72+70/+71）同一区域，
与 `edge30` 的 BUFGCTRL/BUFHCE 分处不同块。这解释了为什么此前把 edge30 当成“时钟脊”只覆盖了一半。

## 6. 复现配方

```
设计：IBUFG(clk) → BUFR/BUFIO/BUFMRCE → 输出悬空（DONT_TOUCH，避免 Place 30-134/30-176）
      + 1×FDRE @SLICE_X8Y11 保证时钟被使用
tcl ：synth → CFGBVS GND / CONFIG_VOLTAGE 1.8 → 综合后 LOC(FD*) → PACKAGE_PIN(clk=AL31, o=AM25)
      → IOSTANDARD → create_clock → opt/place/route → 豁免 NSTD-1/UCIO-1 → write_bitstream
变体：base(BYPASS,CE1,CLR0) / div2 / div3 / ce0 / clr1 / bufio / mrc / mrc_ce0 / mrc_out1
```

## 7. 未完成

- BUFIO 的“分区/半区选择”是否由别的 cell 决定（BUFIO 有 ISE/ISR？7 系列 BUFIO 无属性）——本轮 0 差异说明**没有**；
- BUFMRCE 的 5 个位（27255 w48 b8/b11、27364 b27、27365 b25、27393 w49 b3）未逐个定名，
  只知它们随 BUFMRCE 出现（可能是 MRCC 路由选择）；
- BUFR 的 `BUFR_DIVIDE` 完整码表（BYPASS/2..8）未全扫，只测了 2 与 3。
