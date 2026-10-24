# GLOSSARY — 485T（Virtex-7）比特流逆向术语表

> 目标器件：**XC7VX485T-2FFG1761**（VC707），IDCODE `0x03687093`
> 配套：`README.md`、`bitstream/`、`vivado/`、`scripts/`
> 用法：先看「按主题的阅读顺序」，查词直接跳到字母表；最后一节把术语接到你现有的文件和数据上。

## 0. 先记住这几个数字

| 项 | 值 | 来源 |
|---|---|---|
| 帧数（485T） | 50,176 | `E:\v7work\legacy\v485\top.bit` 实测 |
| 帧数（330T） | 34,412 | `E:\v7work\legacy\v7lut_a\top.bit` 实测 |
| 一帧 | 101 个 32 bit 字 = 3232 bit | 7 系列固定 |
| 帧内布局 | 0..49 数据 + **50 号字低 13 位 ECC** + 51..100 数据 | 实测（80 个非零帧） |
| clock region 高 | 50 个 SLICE 行 | README 已测 |
| LUT INIT | 64 bit，分布在同一 site 的 4 帧、word 20 | X10Y10 探针 |

---

## 1. 字母表

类别：**架构**＝芯片结构；**配置**＝位流/配置机制；**逆向**＝方法论；**工程**＝Vivado 与工具链。

| 术语 | 类别 | 一句话释义 | 你工作里的对应 |
|---|---|---|---|
| **.bit** | 配置 | ASCII 头 + 二进制配置流 | `E:\v7work\legacy\v485\top.bit` |
| **.bin** | 配置 | 纯二进制配置流，无 ASCII 头 | `top.bin` |
| **anchor（锚点）** | 逆向 | 已知 `(LOC,BEL) → 帧组` 的标定点 | X10Y10 → 31748..31751 |
| **BEL** | 架构 | site 内的具体槽位名，如 `A6LUT`、`BFF` | `--bel A6LUT` |
| **bit map（位图）** | 逆向 | 逻辑位 → 物理位 (frame, word, bit) 的映射 | `bit_map.json` |
| **bitgen** | 配置 | Vivado 的位流生成器（`write_bitstream` 背后） | 你每 30 秒出一个流 |
| **bitstream（比特流）** | 配置 | 配置 SRAM 的镜像，不是“程序” | 整个工作的对象 |
| **BRAM36 / BRAM18** | 架构 | 块 RAM，36Kb/18Kb | 未探 |
| **BUFG / BUFH / BUFR** | 架构 | 全局 / 区域 / IO 时钟缓冲 | 未探 |
| **CARRY4** | 架构 | 进位链，纵向跨 slice | 未探 |
| **CLB** | 架构 | 基本逻辑块，含 2 个 slice | 探针落点所在 |
| **clock region** | 架构 | 时钟域，7 系列高 50 个 SLICE 行 | README “50 SLICE rows” |
| **CMD** | 配置 | 命令寄存器；写 `RCRC`、`DESYNC`、`IPROG` | `parser.py` 的 `commands` |
| **CMT** | 架构 | 时钟管理 tile，含 MMCM/PLL | 未探 |
| **column（列）** | 架构 | 同类型 tile 的纵向排列；列宽不等 | X 方向帧号步长 418/472/544/442 |
| **compression** | 配置 | `-compress` 压缩 FDRI 数据；压缩流不能直接切帧 | 用 `leftover` 判断 |
| **COR0 / COR1** | 配置 | 配置选项寄存器（含压缩、回读相关位） | 未用 |
| **CRC** | 配置 | 整条流的 32 位校验，写在 CRC 寄存器 | 改流必须重算 |
| **CTL0 / CTL1** | 配置 | 配置控制寄存器 | 未用 |
| **DCP** | 工程 | Design Checkpoint，冻结的布局布线结果 | `routed.dcp` |
| **DESYNC** | 配置 | 结束配置、进入用户模式的命令（0x0D） | 每条流末尾都有 |
| **differential analysis（差分）** | 逆向 | 两个只差一处的位流做帧/字/位比对 | `diff_frame_indices` |
| **DNA** | 配置 | 器件唯一 ID（57 bit） | 未用 |
| **DONT_TOUCH** | 工程 | 禁止综合/优化改动该单元 | 探针 Verilog 里 |
| **DRC** | 工程 | 设计规则检查；`NSTD-1`/`UCIO-1` 是 IO 未约束告警 | 已降级为 Warning |
| **ECC** | 配置 | 每帧 13 位纠错码，在 word 50 低 13 位 | 改数据必须重算 |
| **eFUSE** | 配置 | 一次性可编程位（密钥、DNA、禁用 JTAG 等） | 与逆向安全相关 |
| **FAR** | 配置 | Frame Address Register，帧地址寄存器；写 FDRI 时自增 | `parser.py` 的 `far` |
| **FASM** | 逆向 | FPGA Assembly，位数据库的文本交换格式 | 可作导出目标 |
| **fasm2bels** | 逆向 | 从 FASM 反推 BEL 级网表 | 后续目标 |
| **FDRI / FDRO** | 配置 | 帧数据输入 / 输出寄存器 | 配置内容出入口 |
| **FF（触发器）** | 架构 | 每个 slice 8 个，含 INIT/SR/RAM 等属性位 | 未探 |
| **frame（帧）** | 配置 | 配置存储器最小可寻址单位，101 字 | 切帧的基本单位 |
| **fuzzing / fuzzer** | 逆向 | 系统造设计、生成位流、比对差异，反推位语义 | `probe_bits.py` 就是 fuzzer |
| **GF(2) 线性** | 逆向 | 物理位对 INIT 满足异或叠加 | `lut/codec.py` 的 encode |
| **GTX / GTH** | 架构 | 高速串行收发器 | 未探 |
| **harness** | 逆向 | 一组带已知参考（bit+dcp+json）的设计 | prjxray 的做法 |
| **IDCODE** | 配置 | 器件身份码 | `0x03687093` = 485T |
| **INIT** | 架构 | LUT 的 64 位真值表内容 | 探针扫的变量 |
| **IOB / IOI** | 架构 | IO 缓冲 tile 与 IO 互联 tile | 未探 |
| **IPROG** | 配置 | 内部触发重配置的命令 | 未用 |
| **ISERDES / OSERDES** | 架构 | IO 串并/并串转换器 | 未探 |
| **LOC** | 工程 | 位置约束，如 `SLICE_X10Y10` | `top.xdc` |
| **LUT6 / LUT6_2** | 架构 | 6 输入查找表；LUT6_2 可拆成两个 5 输入 LUT | `A6LUT` |
| **major / minor frame** | 配置 | 帧地址的两级编号；同一 site 的多帧常是不同 minor | 4 帧组 31748..31751 |
| **MASK** | 配置 | 回读/校验掩码寄存器 | 未用 |
| **MFWR** | 配置 | 多帧写寄存器 | 未用 |
| **MMCM / PLL** | 架构 | 时钟管理单元（倍频、分频、相移） | 未探 |
| **netlist recovery** | 逆向 | 从位流恢复网表/RTL，逆向的终点 | 长期目标 |
| **NOP** | 配置 | 空包，只有包头 | 解析时跳过 |
| **O5 / O6** | 架构 | LUT 的两个输出（5 输入 / 6 输入） | 与 INIT 位段相关 |
| **one-hot probe** | 逆向 | 一次只翻转一个 INIT 位的探针 | 64 个 `bit_XX.bit` |
| **opcode** | 配置 | 包操作码：00 NOP / 01 READ / 10 WRITE | `parser.py` 的 `op` |
| **packet（包）** | 配置 | 位流语法单位：“往某寄存器写 N 个字” | Type1/Type2 |
| **partial reconfiguration（PR）** | 配置 | 只重写部分帧；会出现多段 FDRI 与 FAR 跳变 | 未涉及 |
| **PIP** | 架构 | 可编程互连点，布线开关 | 未探 |
| **ppips** | 逆向 | pseudo PIP，布线开关的抽象表示 | prjxray 概念 |
| **probe（探针）** | 逆向 | 位置固定、只变一个变量的最小设计 | `vivado/probe.py` |
| **prjxray / prjxray-db** | 工具 | 社区 7 系列逆向工具链与数据库 | 只覆盖 artix7/kintex7/zynq7/spartan7 |
| **rank（秩）** | 逆向 | 64 列是否线性无关；rank=64 表示全可解 | README 已验证 |
| **RCRC** | 配置 | 复位 CRC 的命令（0x04） | 流开头附近 |
| **readback** | 配置 | 通过 FDRO 读回配置内容 | 未用 |
| **row（行）** | 架构 | 同一 clock region 内的 SLICE 行号 | `Y` 坐标 |
| **routing（布线）** | 架构 | 由 PIP 构成的连线资源 | 最难的一块 |
| **segbits** | 逆向 | prjxray 的位数据库条目：某组位控制什么 | 可作数据库字段命名 |
| **site** | 架构 | 可放置单元的位置，如 `SLICE_X10Y10` | `LOC` 的目标 |
| **SLICE / SLICEL / SLICEM** | 架构 | CLB 的一半；L 纯逻辑，M 还能当分布式 RAM | 探针落在 SLICEL |
| **sync word（同步字）** | 配置 | `AA 99 55 66`，配置流起点 | `parser.py` 的 `SYNC` |
| **tile** | 架构 | 版图上的矩形单元（CLB/INT/BRAM/IO…） | `tilegrid` 的行列 |
| **tileconn** | 逆向 | tile 之间的连接关系 | prjxray 数据库 |
| **tilegrid** | 逆向 | tile 名 → (row, column) 的器件几何表 | 你缺的那张表 |
| **truth table / minterm** | 架构 | 真值表/最小项；INIT 的第 i 位对应第 i 个最小项 | INIT 0x1 vs 0x2 |
| **Type 1 / Type 2** | 配置 | 包头两种：带 14 位地址+11 位字数 / 只带 27 位字数 | `bits_tcl` 生成的流里都有 |
| **Vivado** | 工具 | 你的“神谕”：造任意参考位流做对照 | `E:\app\Vivado\2017.2` |
| **WBSTAR** | 配置 | 重配置起始地址寄存器（配合 IPROG） | 未用 |
| **word（字）** | 配置 | 32 bit，位流的最小传输单位 | `word 20` / `word 50` |
| **write_bitstream** | 配置 | Vivado 生成 `.bit`/`.bin` 的命令 | `bits.tcl` |
| **XDC** | 工程 | 约束文件，`LOC`/`BEL` 都写在这 | `top.xdc` |

---

## 2. 按主题的阅读顺序

**A. 先懂芯片（架构）**
`CLB` → `SLICE` → `SLICEL/SLICEM` → `LUT6/LUT6_2` → `INIT` → `FF` → `CARRY4`
→ `site` → `BEL` → `tile` → `column` → `row` → `clock region`

**B. 再懂配置（位流）**
`bitstream` → `.bit/.bin` → `sync word` → `packet` → `Type1/Type2` → `opcode`
→ `word` → `frame` → `FAR` → `FDRI` → `ECC` → `CRC` → `CMD` → `DESYNC`

**C. 再做逆向（方法）**
`probe` → `one-hot probe` → `differential analysis` → `anchor` → `bit map`
→ `rank` → `GF(2)` → `fuzzing` → `tilegrid` → `segbits` → `FASM` → `netlist recovery`

**D. 最后是工程（工具）**
`DCP` → `XDC` → `LOC` → `BEL` → `DONT_TOUCH` → `DRC` → `Vivado` → `prjxray`

---

## 3. 最容易混的六组词

1. **frame / word / bit**：帧 ⊃ 字 ⊃ 位。完整坐标是“第 31750 帧 / 第 20 字 / 第 15 位”。
2. **帧号 / FAR**：帧号是切帧后的**序号**（0..50175）；FAR 是硬件**地址**。两者要靠模型对应。
3. **tile / site / BEL**：tile 是版图块；site 是可放置位置；BEL 是 site 内的槽位。
4. **LOC / BEL**：`LOC=SLICE_X10Y10` 只定到格子；`BEL=A6LUT` 才定到哪个 LUT。
5. **ECC / CRC**：ECC 是**每帧** 13 位；CRC 是**整条流** 32 位。改数据两者都要重算。
6. **`.bit` / `.bin`**：内容同源，`.bit` 多一段 ASCII 头（设计名、器件、时间、长度）。

---

## 4. 你当前工作里最高频的十个词

| 词 | 在你的哪个文件/数据里出现 |
|---|---|
| `frame` | `bitstream/parser.py` → `frames_from_words` |
| `word 20` | `bit_map.json` 里每个 INIT 位的主位置 |
| `word 50` | 同上，总是跟着变的那一组（ECC） |
| `anchor` | X10Y10/A6LUT，帧组 31748..31751 |
| `one-hot` | `vivado/bits.py` 生成 `bit_00..bit_63` |
| `bit map` | `E:\v7work\probe\SLICE_X10Y10\A6LUT\bit_map.json` |
| `GF(2)` | `lut/codec.py` 的 `encode()` 用异或叠加 |
| `DCP` | `routed.dcp`，保证 a/b 两个流布局一致 |
| `BEL` | `--bel A6LUT` → `top.xdc` |
| `clock region` | README 的 “50 SLICE rows” |

---

## 5. 一条位流的术语流

```
top.bit
  │  header（'a'..'e' 字段）
  │  sync word AA995566
  ▼
packet 流：Type1/Type2 包头 + 数据字
  │  FAR  → 当前帧地址
  │  FDRI → 帧数据
  │  CRC / CMD(RCRC, DESYNC)
  ▼
word 流（大端 32 bit）
  │  每 101 字切一刀
  ▼
frame（0..50175）
  │  0..49 数据 / 50 ECC / 51..100 数据
  ▼
bit 位置（frame, word, bit）
  │  探针 + 差分 + GF(2)
  ▼
bit map → tilegrid → segbits → FASM → netlist
```

---

## 6. 外部资料怎么对应

- **prjxray-db**：`tilegrid.json`、`segbits_*.db`、`ppips_*.db` 的字段名可以照抄，**数据不能照抄**（没有 virtex7）。
- **UG470**（7 Series FPGAs Configuration User Guide）：`packet`/`FAR`/`FDRI`/`CMD`/`CRC`/`IDCODE` 的权威定义。
- **RapidWright**：可能有 V7 的 tile/site/连线拓扑，可用于校验你的 `tilegrid`。
- **Debit / Bitol**：UltraScale 的同类工作，方法可借鉴，格式不同（帧 93 字）。
