# 《Determining Confidence in FPGA Bitstream Reverse Engineering Results》导读与项目映射

## 0. 文献信息

| 项 | 值 | 来源 |
|---|---|---|
| 标题 | Determining Confidence in FPGA Bitstream Reverse Engineering Results | PDF 首页 |
| 作者 | Ronald D. Williams (UVA, ECE)；Zachary A. Collier (Radford Univ., Management)；Anvesh Perumalla (Univ. of Cincinnati, ECE)；Thomas L. Polmateer (UVA, Systems Eng.)；John M. Emmert (Univ. of Cincinnati, ECE)；James H. Lambert (UVA, Systems Eng.) | PDF 首页 |
| 资助 | NSF Grants 1916760 / 1916722，CHEST IUCRC | PDF 首页脚注 |
| 年份 / 页码 | 2023，pp. 152–156（共 5 页） | PDF 页脚 |
| ISBN | 979-8-3503-3878-2 | PDF 页脚 |
| 会议名 | 待核。ISSN 2379-2027 对应 IEEE International Symposium on Technologies for Homeland Security (HST)，2023 卷 p.152 —— **【推断】**，PDF 正文与页脚均未印会议名 | scholarsportal 记录 `23792027/v2023inone/152` |
| DOI | 未获取（IEEE Xplore 直连失败）；Xplore 文档号 **10365865** | — |
| 免费全文 | https://par.nsf.gov/servlets/purl/10536733 （NSF Public Access，无需登录） | 已下载 |
| IEEE 页 | https://ieeexplore.ieee.org/abstract/document/10365865 | — |
| 本地文件 | `papers/Confidence_FPGA_Bitstream_RE.pdf`（5,059,510 B，5 页，SHA 前 8 位待算） | — |

下载注意：该 PDF 是 linearized PDF，服务器会在约 4.5 MB 处 abrupt close（`curl: (56) schannel: server closed abruptly`），必须用 `curl -C -` 续传 2 次以上才能凑齐 5,059,510 B；一次性 `Invoke-WebRequest` 拿到的 4,834,772 B 是残文件，`read_document` 会报 `Invalid PDF structure`。

---

## 1. 一句话概括

这不是方法论文，是**完备性判据清单**论文：它不讲怎么逆向，而是提出「做 FPGA 比特流逆向的人，必须确定哪 10 类信息，才算有资格说自己解对了」，并主张置信度应当**按命题逐条装配证据**来评估，而不是给一个总数字。

**【推断】作者自己的定位**：文末明确写 "Future work should include the development of confidence scores in concert with the development of bitstream RE approaches"——即本文只给框架，不给度量。

---

## 2. 论文讲了什么（结构）

- **§I 引言**：RE 的合法用途（防伪、恶意植入检测、护 IP）与危害（IP 窃取）；引 Chip Protection Act 1984 的合法用途定义。
- **§II 配置概览**：
  - §II.A 通用比特流：比特流既含**配置数据**，也含**如何配置**的信息（协议）；RE 的大头工作就是把这套协议挖出来。
  - §II.B 配置包：直接引 Project X-Ray——Type 0 填充、Type 1 读/写、Type 2 扩展字数；每个包头含 NOP/READ/WRITE 之一 + 地址 + 字计数。
  - §II.C 配置寄存器：包头地址字段选寄存器，写寄存器控制器件与配置流程。
  - §II.D 细节缺失：厂商文档只给高层视图，足以看结构、不足以定配置。
- **§III 置信度**（核心）：
  - §III.A 状态 vs 配置：把器件总状态切成 **configuration**（建立逻辑元件与互连参数的开关位）与 **initialization state**（不直接建立参数的寄存器值，如 loader 地址寄存器）；再分 volatile / persistent；强调**未初始化的 volatile 存储在上电瞬间必须假定为未知值**。
  - §III.B–§III.D：逐条给出 **Proposition 1–10**（见 §3 表）。
  - §III.E 如何建立置信度：厂商给的信息可**假设为完全正确**并给满分；实测得到的置信度取决于**测试设计**与结果；拿不到的信息必须**假设**，可用**敏感性分析**评估影响。举的例子很好：寄存器 "A" 用途完全未知，但它在某个具体比特流里从未被写 → 无知对结果的置信度削减可能极小。最后指向 **"weight of evidence"** 量化方法（引 [30–32]，包括 Collier 等自己在 Regulatory Toxicology 上的 WOE 框架）。
- **§IV 结论**：置信度值必须按类别逐项给，且**不可能脱离具体逆向方法来定义**；未来工作是随方法一起发展 confidence scores 与风险标准。

---

## 3. 十条 Proposition 与我们的实际状态

标注规则：`✅ 达成` / `◐ 部分` / `✗ 未做`；证据一律指本仓库文件。

| # | 论文要求（原文语义） | 我们的状态 | 证据 / 缺口 |
|---|---|---|---|
| **P1** | 器件中**所有** state 与 configuration 位、其**用途**、其**易失性**、其**赋值机制**、其**默认初值**都必须已知 | ◐ | 配置位侧：CLB 12 项 269 位 0 反例（`CLB_VERIFY.md`）；state 侧只碰了 word50 帧校验字（13 位值域，§17），loader 内部寄存器**未逐一定性**；**易失性与默认初值完全未测**；word50 的生成机制正是当前唯一硬拦路石 |
| **P2** | 原始比特流的**字段划分**与**协议**必须已知；影响传输路径与格式的机制（串/并/JTAG、M[2:0] 引脚）必须已知 | ✅ | 文件头 `a`–`e` / SYNC `AA995566` / Type 1-Type 2 / 帧；`parse_bit_v2.py`、`v7re/bitstream/parser.py` |
| **P3** | 每个 **loader 状态寄存器**的用途、格式、访问方式已知；包 → 寄存器状态变化的映射已知 | ◐ | IDCODE / FAR / FDRI / CMD / CTL0 / MFWR / CRC / BSPI 等基本可从 UG470 得名，但**仍未描述或未识别的寄存器存在**（论文 §III.C 明确警告这点），我们未做"寄存器全清点" |
| **P4** | loader 的**聚合行为**已知（字节序、地址推进方式等） | ✅ | 大端 32 位字；Type1 cnt=0 时后随 Type2；FAR 自动递增；`leftover=0` 两器件一致 |
| **P5** | 比特流中的配置数据 ↔ **fabric 中开关元件地址**的映射已知 | ✅ | 三因子公式 `frame = block_start(col,Y) + off`、`word = 2*(Y%50)+parity(+1 if ≥50)`、行带 `[6,5,0,1,2,3,4]`；`frame_map` 50,176 行（§16） |
| **P6** | 开关元件**地址 ↔ fabric 中对应元件**的映射已知 | ◐ | 这是我们的主战场：INT PIP 位级闭环 0 差异（S13/S14/S15、T5/T6）；CLB ~90%；**BRAM/DSP ~10%**（只 2 特征）；**IO/CMT/GTX/PCIE 0%** |
| **P7** | 必须解出**实际配置**，而不能只解**功能**（同一设计可有多种实现） | ✅ | 我们做的就是逐位实际配置，天然强于功能级；且已实测到"同一功能不同位置"（v485x0a/x0b 从 frame 31540 移到 31543）与"同一 LUT 不同 INIT 编码"，正是 1-to-many 的实例 |
| **P8** | 必须解**整片**，含设计用到的区与**未用区**（未用区也可能有耗电结构或恶意植入） | ◐ | 好的一面：全 50,176 帧全扫、`leftover=0`、非零帧仅 60/80 个，未用区大量为 0；差的一面：**未用区里的 IO/CMT/GTX tile 我们根本没解码能力**，所以"未用区已确定"这句话目前只在 CLB/INT 范围内成立 |
| **P9** | 必须确定各设计部分**相对供电分布**的位置 | ✗ | 完全未涉及 |
| **P10** | 必须确定各设计部分**相对时钟分布**的位置 | ◐ | 已有：clock region 7 个 50 行条带、行带映射、GCLK 接入使能位 `(frame_off=0,bit=16,parity=1)`、GCLK 编号由 slice 所在列决定（§25）；缺：把"设计部件 → 时钟树干段"系统化，HCLK/BUFG/BUFH 未解 |

**汇总：✅ 4 条（P2/P4/P5/P7）、◐ 5 条（P1/P3/P6/P8/P10）、✗ 1 条（P9）。**

---

## 4. 三个对我们有直接冲击的点

### 4.1 P7「功能等价不足」正好解释了我们的 2 格歧义

论文说：一个设计在器件里有多实现，所以"只知道功能"不够。反过来对我们同样成立——**从位反推时也可能有多解**。T6 里 "mux 是否配可判对（53/53），选哪个源不可判"，本质就是同一个位图案对应多条 PIP 链。论文给的不是解法，但给了**正当性**：这不是我们工具烂，这是映射本身的 one-to-many 性质，必须在置信度上体现（T6b 的 83.7%/80.3% 就是这种体现）。

### 4.2 P8「未用区」把我们的一句口头结论钉死了

我们反复说"60/80 个非零帧，其余全 0，所以未用区干净"。按 P8 这个说法**不成立**：0 值并不等于"已确定"，因为我们还没有 IO/CMT/GTX 的位语义，无法排除这些 tile 里存在"0 也有意义"的位（例如 PUDC/PULLUP 类默认态、IO 标准默认配置）。要成立必须补 IO tile 解码。**【推断】这是本文对我们最有杀伤力的一条。**

### 4.3 §III.E 的「未知但未被写 → 置信度削减可很小」

这个论证给了我们一个**可以立刻用的减负工具**：12 个时钟/控制族（帧 0–1）虽然没闭合定律，但如果能证明**它们在具体比特流里取固定值或极少变化**，其对整体结论的置信度削减可以量化地小。反过来，word50 ECC 是**每帧都写**的，不能套用这条豁免——它是 P1 里的硬缺口，这也解释了为什么它是唯一真正的拦路石。

---

## 5. 能帮我们什么 / 不能帮我们什么

**能**
- 给出一张**完备性检查表**（P1–P10），补上 `STATUS.md` 目前只有"完成度百分比"、没有"我们还不知道我们不知道什么"的空白。
- 提供 confidence 的**评估方法论**（逐命题装配证据 + sensitivity analysis + weight of evidence），比现在拍一个"~90%"严谨。
- 提供可引用的**外部权威**，说明"为什么 v7 逆向必须做全集而非抽样"。

**不能**
- 不给算法、不给任何实测数字、不解 ECC、不解 IO。
- 通篇未涉及 **bitstream 加密 / 认证**（AES-HMAC、BBRAM、EFUSE）这一层——这是它作为 2023 年 HST 会议论文的最大盲区，也正好是我们 485T 板上还没碰的面。
- 未涉及**部分重配置**（PR）与 ICAP 内部配置端口——而"恶意植入"的现实路径恰恰多在这两处。

---

## 6. 建议动作（要不要做，由你定）

1. 在 `STATUS.md` 增一节「Confidence by Proposition」，用 §3 那张表做骨架，每格只填四档：`厂商手册` / `实测` / `推断` / `未知`。这比完成度百分比更抗质疑。
2. 把「未用区干净」这句结论在文档里改成限定表述：「在 CLB/INT 范围内未用区为 0，IO/CMT/GTX 未解码，故 P8 不成立」。
3. P1 的"易失性 / 默认初值"是一块完全没碰、成本却不高的面：读 UG470 的默认值表 + 造一个"仅改一个默认值相关属性"的差分实验即可给出一格结论。

---

## 附：论文自身引用的关键前置文献（便于顺藤摸瓜）

- Project X-Ray 比特流格式文档（[29]）——我们已经在用它的 segbits/ppips。
- Fyrbiak et al., "Hardware reverse engineering: Overview and open challenges", IVSW 2017（[2]）——综述。
- Ender et al., "Insights into the Mind of a Trojan Designer: The Challenge to Integrate a Trojan into the Bitstream", ASP-DAC 2019（[13]）——**从比特流往器件里塞 Trojan 的实操**，比本文更接近"怎么写位"。
- Zhang et al., "A Comprehensive FPGA Reverse Engineering Tool-Chain: From Bitstream to RTL Code", IEEE Access 2019（[19]）——端到端 bitstream→RTL，与我们 S14/S15 同类工作。
- Collier et al., "A weight of evidence assessment approach for adverse outcome pathways", 2016（[30]）——WOE 量化方法的原始出处。
