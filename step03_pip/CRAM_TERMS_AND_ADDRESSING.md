# (frame_off, parity, bit) 是什么：术语、物理结构、位流地址换算

> 驱动提示词：[`PROMPT_CRAM_ADDRESS_V1.md`](PROMPT_CRAM_ADDRESS_V1.md)（prompt-optimizer MCP 生成）
> 适用器件：xc7vx485tffg1761-2（Virtex-7 / VC707）
> 标注：`【硬件事实】` 物理结构决定；`【数据事实】` 本项目实测可复算；`【推断】` 解释性推论
> 代码依据：`v7re/scripts/bitwriter.py:33-62`、`v7re/bitstream/parser.py:37-60`、`v7re/config.py`

---

## 0. 一句话

**`(frame_off, parity, bit)` 是"某个 tile 内部第 frame_off 帧、第 parity 个 word、第 bit 位"的相对坐标**，
一共覆盖 26 帧 × 2 word × 32 bit = **1,664 位**，就是该 tile 的全部配置位池；
再加上 tile 自己的 `(col, Y)`，才能换算成位流里的绝对地址 `(frame, word, bit)`。

---

## 1. 术语表：物理对象 → 位流里的位置

| 术语 | 层 | 含义 | 物理 / 位流对应 |
|---|---|---|---|
| CRAM cell（配置位） | 物理 | 1 个 SRAM 单元，输出驱动一根 pass transistor 的栅极 | 位流里恰好 **1 bit** |
| `bit` | 地址 | 该 cell 在 word 内的位号 | 0..31，位流里 1 word 的第 `bit` 位 |
| word | 地址 | 32 bit = 1 个 32 位字 | 位流里 4 字节（小端序按位展开） |
| `parity` | 地址 | 一帧内同一 row 的**上下两个 word** 里的哪一个 | 0 或 1 |
| frame（帧） | 地址 | 101 word = 3,232 bit，CRAM 阵列的一"列切片" | 位流里 404 字节 |
| `frame_off` | 地址 | 该 tile 的块基址与帧之间的**相对帧号** | INT tile：0..25（26 帧） |
| block / band block | 地址 | 一个 `(列 col, band)` 对应的一段连续帧 | `far_bands.start_frame` 给出起点 |
| FAR | 地址 | 帧地址寄存器（frame address register），26 bit | 位流里的 `0x01` Type-1 包头 |
| `sense` | 物理 | 极性：该位取 1 还是取 0 表示"选中" | 表里一列，`sense=0` 表示反相 |
| tile | 物理 | 器件网格里的一个可配置块（INT/CLB/BRAM/DSP/IO…） | 由 `(tile_type, col, row)` 定位 |
| band | 物理 | 水平 clock region 带，每带 50 个 row | `band = band_by_region[Y//50]` |
| row / col | 物理 | tile 在网格里的 Y / X 坐标 | 进入 `band`、`far_bands` 查表 |
| PIP | 物理 | programmable interconnect point：一条可配置连线（输入 wire → 输出 wire） | 若干 cell 的 pattern |
| IMUX | 物理 | INT tile 里"输入多路选择器"，选哪根信号进 CLB/布线 | 一个 family 的位池 |
| family | 逻辑 | 本项目术语：**一个 mux 或长线驱动器的输出 wire** | 一组私有位（cell 池） |
| `src_wire` | 逻辑 | 该 mux 的某个输入 wire | feature 的一半 |
| feature | 逻辑 | 一条 PIP 类型 = `(family, src_wire)` | 若干 cell 的置 1 集合 |
| `BEG` / `END` | 物理 | 长线的起点 / 终点 wire 名（如 `SS6BEG0`、`SS6END0`） | 名字，不是位 |
| tileconn | 物理 | **固定的** tile 间直连（`BEG→END`），不是 mux | **不占 CRAM 位** |

> 为什么 `BEG→END` 不是 mux：7 系列的段-to-段直连由版图几何决定，位流里没有对应开关位。
> 把它当 mux 会得出"少了一族位池"的错觉（T1 曾踩过）。

---

## 2. 物理结构自下而上

```
① 配置 SRAM 位（1 bit）
      │ 输出 = 栅极电压
      ▼
② pass transistor 开关（一个 NMOS 传输门，通/断）
      │ 若干个开关并联成一级
      ▼
③ mux 树（N 个输入 → 1 个输出 wire）
      │ 每一级的选择由一组位控制
      ▼
④ 目标 wire（= 本项目的 family 名）
```

【硬件事实】7 系列布线 mux 不是二进制译码器，而是 pass transistor 树：
某个输入导通 = 该输入对应的那几个开关位一起置 1。所以**编码是 one-hot / 分级 one-hot**，
位数 = 「组数 + 组内成员数」，而不是 `ceil(log2 N)`。

【数据事实】一个 INT tile 有 172 个 family、1,598 个不同 cell、3,636 条 feature；
每条 feature 置 **2 或 5** 个 cell；每个 cell 被 **3..24** 个 feature 共用（均值 7.61）。

【推断】为什么 CRAM 按"列"组织成一帧一帧：配置是**逐列串行写入**的（一帧 = 该列的一个竖切片），
写一帧只需一次 FDRI 突发；同时一个 tile 的配置位在物理上就排布在同一列，按帧写等于按物理邻接写。

---

## 3. 位流容器结构（从文件到帧）

【数据事实】`tamper/ref/ref.bit` 20,273,538 字节：

| 段 | 大小 / 内容 |
|---|---|
| 头部 | **102 字节**，字段是 `key + len + 文本` 形式：`00 09 "0FF00FF0"`…`01 61 00 25 "top;UserID=0XFFFFFFFF;Version=2017.2"`、`00 62 00 0F "7vx485tffg1761"`、`00 63 00 0B "2026/11/03"`、`00 64 00 09 "22:47:25"`、`00 65 01 35`、结尾 `59 1C` |
| 同步字 | `AA 99 55 66`（SYNC，parser 用 `data.find(SYNC)` 定位） |
| 包流 | Type-1 / Type-2 配置包（`0x01` FAR、`0x02` FDRI、`0x04` CMD…） |
| FDRI 载荷 | **5,067,776 words = 50,176 帧 × 101 word** |
| 帧 | 每帧 101 × 32 bit = **3,232 bit = 404 字节** |
| 额外帧 | 每个 config row 末尾还有 **2 个 overhead 帧**（不属任何用户块） |

【数据事实】解析后得到 `bits.shape = (50,176, 101, 32)`（`bitwriter.load_bits`），
即 `bits[frame][word][bit]`；`.bit` 里因夹着包头，**不能**用线性偏移直接寻址，
必须先解析包结构、把 FDRI 载荷拼成连续帧数组（`.bin` 是 `.bit` 去掉 102 字节头，同样含包头）。

---

## 4. 一帧内部的 101 个 word 是什么

【数据事实】`band_rows = 50`：一个 band 有 50 个 row（Y 方向 50 行）。
每行需要 **2 个 word**（正/反相各一份，即 `parity=0/1`）：

```
word  0, 1  ← row 0   (parity 0, 1)
word  2, 3  ← row 1
   ...
word 48,49  ← row 24
word 50     ← ECC（每帧 1 个校验字，13 位有效）
word 51,52  ← row 25  ← 从这里开始整体 +1
   ...
word 99,100 ← row 49
```

所以：**50 row × 2 + 1 ECC = 101 word**。

【数据事实】`bitwriter.word_of(y, parity)`（`v7re/scripts/bitwriter.py:41-43`）：

```python
w = 2 * (y % BAND_ROWS) + parity      # BAND_ROWS = 50
return w + 1 if w >= 50 else w        # 跳过 word 50 这个 ECC 字
```

---

## 5. 地址换算全链路

```
tile 名  →  (tile_type, col, Y)            # law_tiles 表
band     =  band_by_region[Y // 50]        # [6,5,0,1,2,3,4]，七区实测，不是简单反向
base     =  far_bands[(band, col)].start_frame
frame    =  base + frame_off               # frame_off ∈ 0..25（INT tile）
word     =  2*(Y % 50) + parity，若 ≥50 则 +1
最终位置 =  (frame, word, bit)             # bits[frame][word][bit]
载荷偏移 =  frame*404 + word*4 + bit//8    # 以 FDRI 载荷为起点，bit 号为字内 0..31
```

三层放大：

```
┌─ frame（404 B = 101 word）────────────────────────────┐
│ word 0..100（每 word 32 bit）                         │
│   └─ 每个 word = 32 个 CRAM 位 ──→ bit 0..31          │
│                                                       │
│ 一个 tile 只拥有其中 2 个 word（由它的 Y 与 parity 定）│
└───────────────────────────────────────────────────────┘
```

`(frame_off, parity, bit)` = **tile 内坐标**：frame_off 选帧、parity 选两个 word 之一、bit 选位。
INT tile 的池 = 26 × 2 × 32 = **1,664 位**，其中一个 tile 实际可达的正是这 1,664 位。

---

## 6. 真实演算：`INT_R_X37Y199` 的 `SS6END0 → SS2BEG0`

【数据事实】`INT_R_X37Y199`：`tile_type=INT_R`、`col=37`、`Y=199`；
`band = band_by_region[199 // 50] = band_by_region[3] = 1`；
`far_bands[(band=1, col=37)].start_frame = 6510`。

PIP `SS6END0 → SS2BEG0`（family=`SS2BEG0`, src_wire=`SS6END0`）由 2 个 cell 组成：
`(frame_off=11, parity=0, bit=10)`、`(frame_off=13, parity=0, bit=10)`。

算 word：`Y % 50 = 49` → `2*49 + 0 = 98`，`98 ≥ 50` 故 **+1 → word = 99**
（若 parity=1，则 `99 → 100`）。

算 frame：`6510 + 11 = 6521`、`6510 + 13 = 6523`。

于是：

| cell | frame | word | bit | 偏移（FDRI 拼成连续数组后的字节，非文件偏移） |
|---|---|---|---|---|
| (11, 0, 10) | 6521 | 99 | 10 | 6521×404 + 99×4 + 1 = 2,634,981 |
| (13, 0, 10) | 6523 | 99 | 10 | 6523×404 + 99×4 + 1 = 2,635,789 |

【数据事实】读 `ref.bit`：`bits[6521][99][10] == 1` 且 `bits[6523][99][10] == 1`；
真值对照 `tamper/ref/pips_all.txt` 里确有 `INT_R_X37Y199/INT_R.SS6END0->>SS2BEG0` 一行 → 解码与真值一致。

---

## 7. 为什么这样设计（推断，依据在括号里）

1. **帧跨越 50 个 row，而不是 1 个 row**：写配置是按列串行的，一次 FDRI 突发写一帧 = 该列 50 行 × 2 word 的竖条，
   效率最高；同一 band 内 50 个 tile 因此**共享同一批帧，只靠 word 区分**（`word_of` 只用到 `Y % 50`）。
2. **word 50 是 ECC**：每帧一个 13 位校验字，与数据字强相关但**含帧地址项**（STATUS §34：`word50 = ECC(data) ⊕ marker(far_low)`）。
   这也是为什么 `word_of` 要跳过它——它不属于任何用户块。
3. **`band_by_region` 不是简单的 `6-Y//50`**：七个 clock region 与 far_bands 的编号顺序是实测出来的
   （`[6,5,0,1,2,3,4]`），器件顶部 region 在地址空间里排最后。
4. **每个 config row 末尾 2 个 overhead 帧**：不属于用户逻辑，`frame_map` 里单列标注，读取时需跳过。

【不确定性】第 1、2 条是结构推论（帧长 101、ECC 位置、word 公式都已实测），
但 Xilinx 为什么把 row 编码进 word 而不是帧号，属于设计意图推断，无官方文档佐证。

---

## 8. 复现

```python
import sys, sqlite3, json
import numpy as np
sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\v7re")
from bitstream.parser import frames_from_bit

db = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
bbr = json.loads(con.execute("select value from meta where key='band_by_region'").fetchone()[0])

def base_of(name):
    tt, col, y = con.execute("select tile_type,col,y from law_tiles where tile_name=?", (name,)).fetchone()
    band = bbr[min(y // 50, len(bbr) - 1)]
    sf = con.execute("select start_frame from far_bands where band=? and col=?", (band, col)).fetchone()[0]
    return tt, int(sf), y

def word_of(y, parity):
    w = 2 * (y % 50) + parity
    return w + 1 if w >= 50 else w

tt, base, y = base_of("INT_R_X37Y199")          # ('INT_R', 6510, 199)
bits = np.array(frames_from_bit(r"tamper\ref\ref.bit"), dtype=np.uint32)
bits = np.unpackbits(bits.view(np.uint8).reshape(bits.shape[0], 404), axis=1,
                     bitorder="little").reshape(bits.shape[0], 101, 32)
for fo in (11, 13):
    print(fo, base + fo, word_of(y, 0), bits[base + fo, word_of(y, 0), 10])   # 1
```
