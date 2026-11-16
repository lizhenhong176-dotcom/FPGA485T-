# 提示词 V2（经 prompt-optimizer 专业优化 + 定向迭代）

> 生成方式：`optimize-user-prompt`（模板 `user-prompt-professional`）→ `iterate-prompt`（模板 `iterate`，要求：去角色扮演空话 / 加验收标准 / 加自检清单 / 禁编造 / 中文+英文术语 / 命名地基前置）。
> 用途：交给另一个模型，产出「家族 + mux 架构 + Virtex-7 全部物理单元」的完整讲解。

---

## 任务一：家族（family）定义与逆向意义

- 用一句话定义家族（≤40 字，必须包含：同一 tile_type 下目标 wire 相同、互斥、编码方式三要素）。定义须落到可核对事实，不得用抽象比喻或角色扮演式空话。
- 说明家族为什么这样划分（依据是什么物理/编码事实），每条依据须给出可核对证据或标注"未测"。
- 说明家族划分对逆向意味着什么（对网表恢复、位池覆盖、歧义消除的具体影响），影响须可量化或指明验证办法。
- 必须点明：家族属于连线层，不属于逻辑层；家族定义在 tile_type 层，实例化在 tile 层。
- 必须说明：家族不是 Xilinx 官方术语（UG470/UG472 无此词）；若认为等价于 select group / mux tree / feature group，须说明对应关系与差异。

## 任务二：mux 在 FPGA 架构中的位置（六级逐级列清）

对每一级给出：名称 / 物理位置 / 控制位在哪 / 输入输出数 / 是否已解码。资料不足处写"未测"及可行验证办法，禁止编造偏移或数量。

1. 长线与全局线选择（LV/LVB、GFAN、HROW）
2. INT tile 内布线 mux（=家族，控制位在 INT tile 自己的 26 帧）
3. 跨 tile 的 wire 续接（BEG→END 落点由 tileconn 决定；必须强调这不是 mux，是固定连接）
4. site 入口 mux（IMUX_L/R0..11、BYP、CTRL、CLK；控制位在 CLB tile 帧里，实测 offset 16–25，与 INT 帧分离）
5. BEL 内部 mux（AFFMUX、AOUTMUX、BOUTMUX(F7/F8)、PRECYINIT、DI1MUX、WEMUX、CEUSEDMUX、SRUSEDMUX、CLKINV）
6. 硬块内部 mux（BRAM 的 WEMUX/EN/RSTREG、DSP 的 AREG/BREG/OPMODE、IO 的 ILOGIC/OLOGIC）

并回答：为什么第 2 级在逆向里最贵（须结合背景事实中的位池密度、家族数量、覆盖数字论证）。

## 任务三：Virtex-7 全部物理单元穷举清单

判断标准（防偷工减料的验收标准）：清单中每一项都必须满足——读者能凭"所在 tile_type"列在 485T 的 tile 表里逐个定位到对应 tile_type；凡无法定位到具体 tile_type 的项，须显式标注"tile_type 未测"并给出定位方法。不能只列 CLB/BRAM/DSP/IO 四个词，也不能用"等/其他"收尾省略。

必须分九组逐组给表格，列固定为：单元 / 所在 tile_type / 是否可配置 / 配置位位置 / 能否从位流恢复 / 逆向难度。任何一格无数据写"未测"，不写"通常/一般"。

- A 配置与全局：配置帧、OVERHEAD、CRC-ECC、ICAP、FRAME_ECC、STARTUP、BSCAN、DNA_PORT、USR_ACCESS、SYSMON/XADC、EFUSE、读回、MFWR、FAR
- B 时钟：clock region、HROW、CMT/MMCM/PLL、BUFG/BUFGCE/BUFH/BUFR/BUFMR/BUFIO、GCLK/GCLK_B、GFAN、CC 引脚、GT 参考时钟
- C 可编程逻辑：SLICE、LUT6/LUT5/LUT6_2、MUXF7/F8、CARRY4、FDRE/FDSE/FDCE/FDSRE、LD latch、分布式 RAM、SRL16E/SRLC32E、AFFMUX/AOUTMUX/BOUTMUX、WEMUX
- D 互连：INT tile、wire 类型全集、PIP、家族、tileconn、BRK/VBRK、NULL、长线、GFAN
- E IO：IOB/IOI/IO_INT_INTERFACE、ILOGIC/OLOGIC、ISERDES/OSERDES、IDELAY/ODELAY、IN_FIFO/OUT_FIFO、IBUF/OBUF/IOBUF/IBUFDS、bank、VREF、DCI、PAD、RIU/ORP
- F 存储：RAMB18/RAMB36、FIFO18/FIFO36、BRAM_INT_INTERFACE、级联
- G DSP：DSP48E1、DSP_INT_INTERFACE、pre-adder、级联
- H 高速硬核：GTX quad、参考时钟、PCIE_2_1、XADC
- I 调试测试：BSCAN、JTAG、ILA/VIO（须点明 ILA 是软逻辑，不在位流物理单元里）

另给 485T 计数表，凡数字必须标来源，无数据写"未测"。

## 必须回答的四个咬合问题

1. 家族与 IMUX 都是 mux，为何一个在 INT 层一个在 CLB 层，会不会抢同一批位？（须结合 INT 帧与 CLB 帧分离、offset 16–25 等证据回答）
2. 哪些单元根本没有配置位、必须靠 tileconn 落点 / site 位置 / PAD 表识别？
3. 哪些单元有配置位但还没解码？按数量 × 位池密度 × 对网表完整性影响排序。
4. 只给一个 .bit 能恢复到什么程度？给"能 / 不能 / 需要额外假设"三分类清单。

## 命名规范（务必最先讲，作为命名地基）

在展开任何概念（家族、mux、层级等）之前，必须先完整给出本节的命名地基，使读者在接触概念前已掌握记法。概念章节不得先用后解释命名。

prjxray segbits 的 PIP feature 名为 `INT_L.NL1BEG1.NN6END2 07_32 12_33`，格式为 `<tile_type>.<目标 wire>.<源 wire> <frame_off>_<bit>`，`!` 表示该位须为 0；本项目记法 `TILE/TILE_TYPE.SRC->>FAM` 是同一件事的两种写法；家族 = 同一 tile_type 下目标 wire 相同的那组互斥 PIP；wire 名语义：`<方向><长度>BEG<n>/END<n>`，方向 N/S/E/W 与 NE/NW/SE/SW，长度 1/2/4/6，LV/LVB 长竖线，GFAN 全局扇出，ER/R 短线，LOGIC_OUTS 是 CLB 输出进布线，IMUX/BYP/CTRL/CLK 是 CLB 输入侧 mux 输出。必须给四张速查表覆盖以上规范。

## 背景事实（项目实测，可直接采信，不得篡改）

器件 xc7vx485tffg1761-2，150,380 tile、141,634 site、1,760 package pin、14 clock region；SLICEL 43,200 + SLICEM 32,700 = 75,900 slice；位流 50,176 block frame × 101 字 × 32 bit，每个 config row 末尾 2 帧是 OVERHEAD 不属于任何用户块；单元定位 = (块基址 + frame_off, word, bit)，word = 2*(Y%50) + parity，bit = raw % 32；INT tile 位池 1,664 位（26 帧 × 2 字 × 32），1,598 位被 3,636 条 PIP feature 覆盖，66 位未覆盖；1,598/1,598 cell 只属一个家族，0 例跨族共享；族内 3..18 源/cell（均值 5.57，最大 18），每 PIP 占 1–4 cell；形状 5 类 (9,20)×96 / (10,24)×64 / (8,16)×6 / (7,12)×4 / (9,18)×2；已确认两级 one-hot：(9,20) = 4 组 × 5 成员，位宽 4+5=9 而非 ceil(log2 20)=5；全芯片解码 181 PIP / 181 家族 / 0 ambiguous，写位回环 864/864；LUT INIT 的 FASM 索引是普通二进制 A6(MSB)…A1(LSB) 无位反序，FF 的 ZRST/ZINI/AFFMUX/BOUTMUX(F8) 已定位并跨 tile_type 验证。

## 层级表（必须给出）

芯片→region→column→tile→site→BEL→cell，标出家族定义在 tile_type 层、实例化在 tile 层，且必须点明家族属于连线层不属于逻辑层。

## 输出格式（严格九段，顺序不可变）

1. 一句话定义家族（≤40 字，含目标 wire、互斥、编码）
2. 命名规范四张速查表
3. 层级表
4. mux 六级清单
5. 物理单元九组表格
6. 485T 计数表
7. 四个咬合问题
8. 常见误解纠正 ≥6 条（每条写：错在哪、正确是什么）
9. 6 道自测题 + 答案（至少 2 道跨单元与位两个层面）

## 输出前自检清单（逐条核对后再交付，任一不满足即返工）

- [ ] 全文无角色扮演式空话、无抽象比喻替代事实；每条断言落到可核对事实或可执行步骤。
- [ ] 任务三每一项都能按判断标准定位到 tile_type，或显式标注"tile_type 未测"并给定位方法；无"等/其他"省略。
- [ ] 所有数字可追溯到背景事实，或明确标"未测"；无一处"通常/一般"替代数字。
- [ ] 每条断言均带【硬件事实】/【数据事实】/【推断】三色标注之一，未混写。
- [ ] 命名规范位于概念章节之前作为命名地基；概念章节未先用后解释命名。
- [ ] 四张速查表齐全；层级表、mux 六级、物理单元九组表格、485T 计数表、四个咬合问题、误解纠正 ≥6 条、6 道自测题均完整。
- [ ] 家族未被说成 Xilinx 官方术语；若与 select group / mux tree / feature group 比较，已说明对应与差异。
- [ ] BEG→END 续接未被说成 mux。
- [ ] 涉及已解码/未解码均以背景数字为准，无臆造进度。
- [ ] 所有术语保留英文原文，正文中文输出。

## 纪律（违反即失败）

- 三色标注【硬件事实】【数据事实】【推断】不得混写，每条断言须带标注。
- 不许用"一般来说 / 通常"代替数字；涉及数量要么给可核对值，要么写"未测"。
- 资料不足处必须写"未测"并给出可行验证办法，严禁编造偏移、数量或位置。
- 不许把家族说成 Xilinx 官方术语；若认为等价于 select group / mux tree / feature group，须说明对应与差异。
- 不许把 BEG→END 续接说成 mux。
- 涉及本项目已解码 / 未解码，以背景数字为准，不臆造进度。
- 不知道某单元配置位位置就写"我不知道，可行验证办法是 X"，不要编造偏移。
- 所有数字必须可追溯到背景事实或明确标"未测"。
- 全部输出中文，术语保留英文原文。
