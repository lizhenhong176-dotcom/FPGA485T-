# Vivado 逆向：7 系列 CRC 算法（P2 空白）突破记录

日期：2026-11-15　目标：`librdi_bitstream.so` / `libBsFuji_Bitstream.so`

## 结论（先看这个）

**7 系列的 CRC 不是 zlib 的 CRC-32（0xEDB88320），而是 CRC-32C（Castagnoli）**。

证据：从 CRC 核心提取出的 32×37 线性映射矩阵中，第 36 列（5 位选择器的最高位）恰为

```
0x82F63B78  =  反射版 CRC-32C 多项式（0x1EDC6F41 的位反转）
```

这解释了 STATUS.md 里"MSB/LSB、字节序、位序、初值/终值、zlib 全不匹配"的历史结论——一开始多式就错了。

## 怎么拿到的

1. Vivado 的 bitgen 功能在共享库里，不在巨型可执行文件里：
   - `$V/lib/lnx64.o/librdi_bitstream.so`（3,252,032 B，符号未剥离）
   - `$V/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitgen.so`（499,288 B）
   - `$V/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitstream.so`（185,440 B）
2. 符号表直接给出函数：
   - `FUJIBS_BITFILE::crc32_37(char*, char const*, char const*)` @ `0x80b0`（3,498 B）
   - `FUJIBS_BITFILE::crc32_37(char*, int, char const*)` @ `0x8e60`（65 B）
   - `FUJIBS_BITFILE::add_crc(bool, char*)` @ `0x8eb0`、`add_rbcrc` @ `0x8f00`、`recalc_crc()` @ `0xc110`
   - `Bs_FujiBitfile::calcCRC(std::bitset<32>&, std::bitset<32> const&, std::bitset<5> const&)` @ `0x14f590`
   - `Bs_FujiBitfile::calcRBCRC(std::bitset<32>&)` @ `0x15d260`
3. `calcCRC` 与 `crc32_37` 都只是壳：`calcCRC` 检查 `[this+0x125]` 后 `jmp 0x14d870`；`crc32_37` 把 32 位整数展开成 32 个 '0'/'1' 字符再调 `calcCRC`。
4. **真正的核心在 `0x14d870`（7,456 B）**，是一个把 37 位向量（32 数据 + 5 选择器）线性映射到 32 位的位运算网络。

## 为什么不能直接调库

`dlopen(librdi_bitstream.so)` 在加载阶段就打印

```
Error: The file  is corrupt. Please re-install this software from the original media.
```

来自依赖链里的 `librdi_common.so` 安装完整性自检；换 cwd、设 `XILINX_VIVADO`、把测试程序放进 `$XILINX_VIVADO`、伪造 argv[0] 都绕不过；ISE 侧的 `libBsFuji_Bitstream.so` 单独 dlopen 又缺 `BS_BITFILE::getNumOptions()`。

**绕过办法：不加载库，直接 Unicorn 模拟那段代码。** `emu_crc.py` 把 ELF 各 PT_LOAD 段按 vaddr 映射进 Unicorn，栈与 scratch 单独映射，从 `0x14d870` 起以 `(rdi=out, rsi=in, rdx=sel)` 调用（注意：这是 wrapper 做完参数重排后的约定，不是 SysV 原序）。

## 提取到的矩阵（37 列）

```
 k  M[k]        k  M[k]        k  M[k]        k  M[k]
 0 c5670b91    10 d725148b    20 8b277743    30 e13b70f7
 1 8f2261d3    11 aba65fe7    21 13a29877    31 c79a971f
 2 1ba8b557    12 52a0c93f    22 274530ee    32 8ad958cf
 3 37516aae    13 a541927e    23 4e8a61dc    33 105ec76f
 4 6ea2d55c    14 4f6f520d    24 9d14c3b8    34 20bd8ede
 5 dd45aab8    15 9edea41a    25 3fc5f181    35 417b1dbc
 6 bf672381    16 38513ec5    26 7f8be302    36 82f63b78
 7 7b2231f3    17 70a27d8a    27 ff17c604
 8 f64463e6    18 e144fb14    28 fbc3faf9
 9 e964b13d    19 c76580d9    29 f26b8303
```

线性性已实测验证（5 组随机 a/b/选择器，`f(a^b, sa^sb) == f(a,sa) ^ f(b,sb)` 全过）。

## 还没做的

- 调用语义：`calcCRC` 的 32 位输入是"上一轮 CRC"还是"数据字"、5 位选择器各位含义（帧类型/字位置）、循环顺序 —— 需要读 `FUJIBS_BITFILE::recalc_crc`（`0xc110`，2,464 B）与 `calcRBCRC`（`0x15d260`，853 B）。
- 与真实 .bit 对齐：`_2020_bit_base.bit` 尾部 4 字节是 `0x20000000`（DESYNC 填充），不是 CRC，说明 7 系列的 CRC 不是"文件尾 4 字节"，需要按 UG470 的帧/包结构定位。

## 文件

- `emu_crc.py`：Unicorn 模拟器 + 37 列矩阵提取 + 线性性验证
- `crc_matrix.json`：矩阵
- `dis1.py`/`dis2.py`/`dis3.py`/`dis_helper.py`：capstone 反汇编脚本
- `syms.py`：ELF 符号解析
