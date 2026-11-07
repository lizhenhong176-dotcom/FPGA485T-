# 项目入口

**每个任务开始前，先读 `STATUS.md`**（项目现状、已完成/待办、已知坑）。
**要用远端 Vivado，先读 `REMOTE.md`**（当前地址/用户/私钥、三种调用姿势、DHCP 换址后的重连流程、远端数据清单）。
实验细节见 `step03_pip/RESULTS.md` 与 `step03_pip/REUSE_RULES.md`，代码用法见 `v7re/README.md`。
**位级差分实验的通用流程见 skill `fpga-bitstream-experiment`**（`.agents/skills/fpga-bitstream-experiment/SKILL.md`；提示词 V1/V2：`BITSTREAM_EXPERIMENT_FLOW_V1.md`、`BITSTREAM_EXPERIMENT_FLOW_V2.md`）。

# 回答纪律（系统提示词，详见 `step03_pip/SYSTEM_PROMPT_V7_BITSTREAM.md`）

涉及体系结构 / 位流 / 位级结论时，本仓库的助手须遵守：

- **三色标注**：`【硬件事实】`（手册级）/`【数据事实】`（本项目实测）/`【推断】`（由数据反推）三者不得混写。
- **禁编造**：帧偏移、cell 位置、数量、tile_type 无数据即写「未测」并给可行验证办法。
- **禁模糊量化**：不用「一般来说/通常/大多数」代替数字。
- **命名先行**：tile_type / wire / site / BEL / PIP feature 名，先给规则再展开概念。
- **两个不可混的概念**：`BEG→END` 的 tileconn 落点是**固定连接不是 mux**；「家族」不是 Xilinx 官方术语。
- **进度以 `STATUS.md` 为准**，不臆造。
- 术语保留英文原文，正文中文。

# 提示词纪律（硬规则）

**任何提示词的写作与修订，都必须调用 prompt-optimizer 工具完成，不得手写落盘。**

- 新建提示词：先自拟草稿 → `optimize-user-prompt`（模板按用途选 `user-prompt-professional` / `user-prompt-planning`）→ 落盘 V1。
- 需要针对性加固：再调 `iterate-prompt`（`iterate` 模板，`requirements` 写具体加固项）→ 落盘 V2，并在文件末尾附「V1 → V2 改动清单」表格。
- 需要长期挂载的行为约束：调 `optimize-system-prompt`（`analytical-optimize` 模板），再人工补**自包含附录**（命名地基 / 模型与单元清单 / 基线数字与「未解」行），因为优化器会把领域知识抽象成一句"遵守某模型"。
- 产出物命名：`<TOPIC>_V1.md` / `_V2.md`，正文保持工具返回的结构化版本，不得自行回退成口头版。

# Codex usage policy

- **Codex review / 审核**: use the high model (e.g. `gpt-6.1-sol`) with an
  adversarial prompt. Record the model and command in the review report.
- **Codex implementation / 工作**: use a low model. Reserve the high model for
  review and final arbitration, not routine edits or test runs.
- Review bundles must include the actual evidence needed to recompute claims;
  never ask a reviewer to trust summaries alone.
