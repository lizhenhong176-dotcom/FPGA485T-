
## 197. 逆向 Vivado：7 系列 CRC 是 CRC-32C，并已提取出 32×37 线性矩阵（2026-11-15）

背景：§152 的「路线 B（反解多项式）」失败，CRC 一直停在「按锚点局部可用」。本次改为**直接逆向 Vivado 的比特流库**。

### 目标定位（关键：bitgen 功能在共享库，不在巨型可执行文件）

- `$XILINX_VIVADO/lib/lnx64.o/librdi_bitstream.so`（3,252,032 B，**符号未剥离**）
- `$XILINX_VIVADO/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitgen.so`（499,288 B）
- `$XILINX_VIVADO/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitstream.so`（185,440 B）

`lnx64.o` 下没有 `bitgen` 可执行文件（只有 vivado/xelab/hw_server 等），Vivado 的 bitgen 走库调用。

### 符号表直接给出算法入口

- `FUJIBS_BITFILE::crc32_37(char*, char const*, char const*)` @ `0x80b0`（3,498 B）
- `FUJIBS_BITFILE::crc32_37(char*, int, char const*)` @ `0x8e60`（65 B，把整数展开成 32 个 '0'/'1'）
- `FUJIBS_BITFILE::add_crc(bool, char*)` @ `0x8eb0`、`add_rbcrc` @ `0x8f00`、`recalc_crc()` @ `0xc110`
- `Bs_FujiBitfile::calcCRC(std::bitset<32>&, std::bitset<32> const&, std::bitset<5> const&)` @ `0x14f590`
- `Bs_FujiBitfile::calcRBCRC(std::bitset<32>&)` @ `0x15d260`

### 不能 dlopen：安装完整性自检

`dlopen(librdi_bitstream.so)` 在**加载阶段**就打印 `Error: The file  is corrupt. Please re-install this software from the original media.`（字符串来自 `librdi_common.so` / `librdi_device.so`，不在 librdi_bitstream 里）。设 `XILINX_VIVADO`、把测试程序放进安装目录、伪造 `argv[0]`、改 cwd 均无效；ISE 侧 `libBsFuji_Bitstream.so` 单独加载缺 `BS_BITFILE::getNumOptions()`。

### 绕过：Unicorn 直接模拟核心 `0x14d870`

`calcCRC` 只是壳（检查 `[this+0x125]` 后 `jmp 0x14d870`）；核心 7,456 B，是 37 位向量 → 32 位的位运算网络。用 Unicorn 按 PT_LOAD 映射 ELF 段，从 `0x14d870` 以 `(rdi=out, rsi=in, rdx=sel)` 调用（wrapper 已重排参数，非 SysV 原序），得到 37 列矩阵。

### 结果

**第 36 列（选择器最高位）= `0x82F63B78` = 反射版 CRC-32C（0x1EDC6F41 位反转）**。即 7 系列用的是 CRC-32C，不是 zlib 的 CRC-32 —— 这解释了 §152 为什么按 0x04C11DB7 怎么试都不中。

矩阵全文见 `step03_pip/crc_matrix.json`，过程见 `step03_pip/CRC_RE_FINDINGS.md`，脚本 `step03_pip/_crc_emu.py`（Unicorn）与 `dis*.py`（capstone）。

### 尚未闭合

- 调用语义：32 位输入是「上一轮 CRC」还是「数据字」、5 位选择器各位含义、循环覆盖区间（UG470 说自 RCRC 之后、含头部包）——需读 `recalc_crc`(`0xc110`) 与 `calcRBCRC`(`0x15d260`) 的循环。
- 与真实 .bit 对齐：`_crc/c_base.bit` 的 `0x591AE6B5`（§151）尚未被矩阵复现；已排除 sync 起点 + `M(c^w)`/`M(w)^c` + 位反转/字节序 + init 0/0xFFFFFFFF 的直白组合。
- 结论不影响主线（PIP 编码规律/解码器/FASM 层），仅影响「自造位流能否被器件加载」。

### 附带

REA（npm `rea-agents` 6.7.0）已装；`rea` 的 Ghidra 依赖用 ghproxy 镜像下载到 15 MB 后连接被重置，暂不影响（Unicorn 路线不需要 Ghidra）。
