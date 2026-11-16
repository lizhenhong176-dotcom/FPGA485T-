import io

p = r"step03_pip/PROMPT_LAW_TO_DATALAYER_PLAN_V2.md"
add = """

---

# 附：V2 相对 V1 的改动清单

| # | 改动 | 原因 |
|---|---|---|
| 1 | 新增「现状基线要求」整节（8 条，逐条带 `文件:行号`） | V1 只说「附证据指针」，没说指到哪；执行者无从下手 |
| 2 | 补入「自研边界」一条（`step03_pip/REUSE_RULES.md:8`：形状表来自 prjxray artix7 segbits） | 计划必须让执行者知道哪些是移植、哪些是自研，否则验收标准会被写歪 |
| 3 | 补入复合族原点 `T3_PIP_REUSE_LAW.md` §9.2（12 族「主码+附码、跨 parity、未闭合」） | 说明 A 轨在收什么口，而不是凭空修文档 |
| 4 | 技术债改为带数字：`site_frames` 现存 2,425,600 行（仅 X0 ALUT）、BLUT/CLUT/DLUT 约 727 万行已删、库 7.9 GB 级 | V1 的「仍错误」不可验收 |
| 5 | 新增索引置换的可复现证据（`_full8.bit` 解出 `0x1` vs `_full8_i3.bit` 解出 `0x100000001`，差格 `(31786,40,7)` 被标 k=32） | 这是 B 轨的核心待解问题，必须写明现象才能定验收 |
| 6 | 新增「环境与工具链」整节（Python 3.8 依赖、Vivado 路径、DRC 豁免、远端 ssh 姿势与 LF 要求） | V1 把这些混在硬约束里，执行者容易漏 |
| 7 | 硬约束新增第 7 条「回归门」四条可复算命令（INT_L/INT_R 的 verify_all_pip、tamper_localize 基线、T5 往返 9/9） | 没有回归门就无法判断替换 site_frames 是否引入退化 |
| 8 | 硬约束新增第 8 条「回滚具体动作」（`VACUUM INTO` 备份、限定 tile_type+family 子集、副本库先验） | V1 只写「失败如何回滚」，缺可执行动作 |
| 9 | 硬约束新增第 9 条（时间给区间 + 不确定性来源）与第 10 条（把「必须问用户」收敛到三类） | 避免执行者在持久表/远端/构建三件事上自行放行 |
| 10 | 输出格式要求补「证据指针统一用 `文件:行号`」 | 与项目回答纪律对齐 |
"""

t = io.open(p, encoding="utf-8").read()
io.open(p, "w", encoding="utf-8").write(t.rstrip() + add)
print("ok", len(t) + len(add))
