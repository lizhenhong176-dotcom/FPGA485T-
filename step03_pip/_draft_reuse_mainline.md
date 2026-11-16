请为「Xilinx 7 系列 XC7VX485T-2FFG1761（VC707）INT tile 的 PIP 复用」写一份技术说明，只回答两个问题：

（一）复用发生在哪一层？
必须按物理地址层次自下而上逐层说清楚：位池（cell）层 → 特征（feature/PIP）层 → 家族（family/目的 wire）层 → tile 层 → 器件层。每一层要回答：这一层有多少个对象、对象之间是否共享、共享的度量是什么（例如「1,598 个 cell 被 3,634 个 feature 共用，平均 5.57」）。
必须明确区分 sense=1（必须为 1 的位）与 sense=0（必须为 0 的约束位），并声明所有统计一律只取 sense=1；混算会得到每源恒 5 格、平均 3.35、每 cell 7.61、102/172 唯一、70 族 4:1 合并这组假象。

（二）复用的规律是什么？
至少覆盖以下已实测的规律，每条都要给出：规律的一句话陈述、可执行形式（公式或伪代码）、量化证据（分子/分母）、该规律的边界或反例。
1. 族内唯一性：同一 family 内每个源（src）的位集互不相同（172/172 族）。
2. 形状分类：按 (置位格数, 源个数) 分 7 类，给出每类的族数与占比。
3. 网格生成律：mux 区的 row/colcode 网格（frame_row = 16+row、frame_col = {25-i}、位对偶起点、column 帧恒 primary、row 2/3 用配对位）。
4. 完全二分图：BEG 区 32 族 = K(4,5)。
5. 复合组模型：6 个时钟/控制族的 core + drops + extras 组结构，以及「先过滤 sense=1 再比对」的必要性。
6. 跨族共享：1,598 个 cell 里只有 3 个被两个 family 共用，说明「复用基本被族边界封住」。
7. 幂等/可加性：174 条定律可解释 3,634 条 feature，且同一规律在 INT_L 与 INT_R 两侧同构（需先做线名归一化）。

数据来源限定：E:\v7work\model\v7_law.sqlite 的 law_cells / law_tiles / far_bands 表；v7re/steps/pip_reuse_law.json；v7re/steps/T3_PIP_REUSE_LAW.md；v7re/steps/T35_COMPOSITE_GROUP_MODEL.md；v7re/steps/beg_families.json；v7re/scripts/verify_all_pip.py。
输出要求：
- 结论先行，开头 5 行内给完整答案；
- 每个数字后面标来源（表名/脚本/文档），推测必须显式标注为推断；
- 不确定的地方写「未测」，禁止编造；
- 结尾给一份复算命令清单，任何人按命令能复现全部数字；
- 不要写与「复用在哪 / 复用规律」无关的内容（不写 ECC、不写篡改定位、不写数据层缺行）。
