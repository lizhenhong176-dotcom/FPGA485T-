# 提示词：复现 Vivado 7 系列比特流 CRC

你要在一台装有本项目语料的机器上，**从零实现** Xilinx 7 系列 `.bit` 文件的尾部 CRC 校验，并通过验证。下面是全部已知事实，不要去看 `v7work/vivado_re/*.py` 里已有的实现（那是答案），只允许读 `step03_pip/crc_matrix.json` 这个从二进制里提取出来的数据文件。

## 一、结论（要复现的目标）

CRC 是**线性映射**，格式为：

```
st = 0
for i in range(a, b+1):
    st = L(st XOR W[i])
CRC = st XOR S
```

其中 `W` 是 bitstream payload 的 32 位大字数组，`L` 是由 `crc_matrix.json` 的 `matrix[:32]` 定义的线性算子，`S` 是设备常量。

两个 CRC 包（区间参数）：

| 段 | 起点 a | 终点 b | S |
|---|---|---|---|
| 第 1 段 | `12` | `crc1_index - 1` | `0x06F99760` |
| 第 2 段 | `crc1_index + 2` | `crc2_index - 1` | 依赖器件/FAR 状态，从同源参考位流现算 |

`crc1_index` / `crc2_index` 是"写 CRC 寄存器"那个 packet 的 header word 下标；CRC 值在第 `index+1` 个 word。

## 二、L 的定义（关键，容易搞错）

`crc_matrix.json` 的 `matrix` 是 37 个十六进制字符串，只取前 32 个：

- `COLS[k] = int(matrix[k], 16)`，k = 0..31
- **列号 k 就是 word 的 bit 号 k，不需要任何位反转**
- `L(x) = XOR_{k: x 的 bit k 为 1} COLS[k]`

实现建议：预计算 4 张 256 项字节表加速（`T[b][v]` = 只用第 b 个字节的 bit 拼出来的值），
`L(x) = T0[x&0xFF] ^ T1[(x>>8)&0xFF] ^ T2[(x>>16)&0xFF] ^ T3[(x>>24)&0xFF]`。

矩阵本身的性质（可用于自检）：
- `COLS[k+1] = (COLS[k] << 1) ^ (0x05EC76F1 if COLS[k] & 0x80000000 else 0)`，对 k=0..35 全成立
- `COLS[36] = 0x82F63B78` = CRC-32C 多项式 `0x1EDC6F41` 的位反转
- 前 32 列 GF(2) 秩 = 32（可逆）

## 三、位流容器格式（容易搞错的地方）

以 `_c0.bit`（20,273,538 B）为例：

- 13 B magic `00090ff00ff00ff00ff000000161`
- `0x61` len=37 字符串（设计名/版本）
- `0x62` len=15 字符串（器件，例如 `7vx485tffg1761`）
- `0x63` len=11 日期、`0x64` len=9 时间
- `0x65` **长度栏是 4 字节，不是 2 字节**：`Lh = int.from_bytes(d[98:102], 'big')`
- **payload 从 offset 102 开始**，长度正好 `Lh`；校验：`102 + Lh == 文件总长`

payload 里：前 48 B 是 `0xFF` 填充，sync `0xAA995566` 在第 12 个 word；
word 数组 `W[i] = int.from_bytes(bs[4i:4i+4], 'big')`。

## 四、packet 解析（定位 CRC 包）

```
type = h >> 29
type 1: op=(h>>27)&3, reg=(h>>13)&0x3FFF, cnt=h&0x7FF
        if op==2: 数据占 cnt 个 word，索引 +1+cnt；否则 +1
type 2: cnt = h & 0x7FFFFFF；索引 +1+cnt
```
"写 CRC 寄存器" = `op==2 and reg==0 and cnt==1`，此时 `W[i+1]` 就是该段的 CRC 值。

自检：正确解析时**恰好消费完整个 word 数组**（`_c0.bit` 是 5,068,359 word / 559 个 packet）。

## 五、S2 怎么得

第一个位流（称参考位流）跑一遍：算出第二段的 `model`，则 `S2 = model ^ crc2值`。
之后对所有同源位流用这个 S2。

## 六、算法是怎么来的（背景，不必重做）

1. `librdi_bitstream.so` 符号未剥离，`FUJIBS_BITFILE::crc32_37` 就是核心。
2. 它实际是**4 参数**：`(this, state32, data32, sel5)`；Ghidra 只解出 3 个。
3. `dlopen` 被安装自检挡住，改用 Unicorn 直接模拟函数体，逐位喂 0/1 得到 37 列矩阵。
4. 绝对对齐失败（mask 串、COR/CTL 常量、初值互相纠缠），改用**差分**：65 个同源位流只差 FDRI 里几个 word，差分把所有未知常量消掉，唯一解就是"列号=bit 号、末 word 在 FDRI 结束 +1"。

## 七、验收标准（必须全部满足）

在 `E:/DEEPSEEK/FPGA比特流逆向/` 下：

1. `_crcb/b00.bit` 两段都算对：
   - CRC1 = `0x46DA6AD9`，CRC2 = `0xE3AD7EA5`
   - 推导出的 `S1` 必须等于 `0x06F99760`
2. `_c0.bit` 的 CRC1 = `0xD11354F1`（用 S1 预测必须命中）
3. `_crcb/b01..b20` 全部两段 OK
4. `_c0_to_c3.bit` 必须**判为不符**（这是手工改帧后没重算 CRC 的文件，值仍是 `0xD11354F1`，正确预测应为 `0x456E332A`）——这条验证你的一致性检查是真的在工作

## 八、交付

写一个 `crc_repro.py`，提供：
- `load(path)` → `(bytes, [words])`
- `find_crcs(W)` → `[(header_index, value), ...]`
- `calc(W, a, b)` → 线性模型值
- CLI：`python crc_repro.py <file.bit>` 打印每段的 `crc=... pred=... OK/FAIL`

然后跑完上面第七节的 4 项验收，把实际数字贴出来。
