总体结论：**REJECT**。现有材料支持“5 条记录满足脚本的形式字段检查”，但不足以支持“5 个独立、可复算、可用于 STEP04 的 M2 实验证据”。核心原因是：5 个 pair 都是同一类 A3→A5 改动，且 gate 脚本不检查实验独立性、证据文件存在性、JSON 与 bitstream 的一致性，也不重新计算 diff。

**P0（阻塞）**

- **Gate PASS 不是独立性证明。** `scripts/check_m2_gate.py:55-84` 只统计 JSON 数量、唯一 `id`、tile_family，并检查字段格式；没有检查 site、row、pin transition、bitstream 是否重复，也没有验证 `route_a/route_b` 来自 `pips.txt`。因此 `m2_mcd_0001..0005` 虽然计数为 5，但全部是 `B.A3->B.A5`，见各 JSON 的 `changed_inputs`，例如 [m2_mcd_0001.json:6-13](/E:/DEEPSEEK/FPGA比特流逆向/codex_review_m2_20261022/data/m2/pairs/m2_mcd_0001.json:6) 和 [m2_mcd_0005.json:6-13](/E:/DEEPSEEK/FPGA比特流逆向/codex_review_m2_20261022/data/m2/pairs/m2_mcd_0005.json:6)。这不是 5 种独立控制变量。
- **记录的 bitstream 证据不在当前目录。** JSON 声明的 bitstream 路径不存在，例如 `data/m2/pins/pin_a3/design.bit`、`data/m2/fam/clbll_l/pin_a3/design.bit` 均为 `False`。因此无法独立重算 `diff_frames`、`data_bits` 或验证 SHA。JSON 中的 SHA 只能标识外部文件，不能替代文件本身。
- **“至少 3 families”被重复 A3→A5 模式人为满足。** `M2_CORPUS.md:14-18` 将 CLBLL_L 的不同 Y/位置、CLBLM_L 的 SLICEM/SLICEL 计作 family 覆盖，但没有证明这些是独立的路由机制；`0002` 与 `0004` 甚至具有相同 diff frame 集合，见 [m2_mcd_0002.json:34-42](/E:/DEEPSEEK/FPGA比特流逆向/codex_review_m2_20261022/data/m2/pairs/m2_mcd_0002.json:34) 和 [m2_mcd_0004.json:34-42](/E:/DEEPSEEK/FPGA比特流逆向/codex_review_m2_20261022/data/m2/pairs/m2_mcd_0004.json:34)。

**P1（重要）**

- **route 与 pips 的一致性只能抽查，不能由 gate 得出。** 例如 Y40 的 `pips.txt` 确实显示 `IMUX1→A3` 对 `IMUX8→A5`，且 XDC 只改变 `LOCK_PINS`，见 `data/m2/validation/clbll_l_y40/a3/pips.txt:1-4`、`.../a5/pips.txt:1-4` 和对应 XDC。但 gate 脚本没有读取这些文件；JSON 的 `pip_symdiff=4` 只是自报值，见 `check_m2_gate.py:25-30`。
- **SHA 的语义未被正确纳入验证。** 文档承认 `.bit` 头含时间戳，应比较 frame 内容而非整文件哈希，见 `M2_CORPUS.md:40-42`；但 JSON 同时记录整文件 SHA，却没有记录规范化 frame SHA、bitstream header 排除规则或实际 diff 命令输出。因此 SHA 不能证明 frame 差异对应 JSON。
- **排除 word 50 没有充分证据。** `check_m2_gate.py:35-39` 只禁止把 word 50 写入 `data_bits`；它没有证明 word 50 的所有变化都只是 ECC/aux，也没有检查 word 50 是否包含与目标 PIP 相关的数据。文档只称其为 ECC/aux，见 `M2_PIP.md:29-31`、`M2_CORPUS.md:34-36`。
- **word 模型尚未覆盖边界。** `M2_CORPUS.md:31-35` 的模型只由 Y11、Y21、Y31、Y41 支持；验证 README 明确承认只在一个 clock region、一个 tile family 内拟合，且 Y50/Y51 尚未测试，见 `data/m2/validation/README.md:28-32`。Y40 是模型拟合后的 held-out replay，但只能证明该局部插值，不足以证明跨 clock-region 通用性。
- **“INT mux 与 site PIP 必然耦合”结论过强。** `M2_PIP.md:68-80` 只证明当前 `CLBLM_R` 的每个 LUT pin 有一个 site PIP；这不等于所有 tile、所有 sink、所有拥塞条件都不存在可分离实验。文档自身也提出 second sink/congestion 方案，见 `M2_PIP.md:105-111`。
- **diff 算法存在潜在漏报。** `bitstream/frames.py` 的 `diff_frame_indices` 只比较共同长度，见函数实现；若两输入 frame 数不同，尾部差异被静默忽略。当前没有记录 frame 数一致性、配置寄存器/CRC/aux 区域分类，也没有展示原始逐帧 diff 输出。
- **build 日志有未约束 I/O 警告。** 例如 Y30 日志报告 `NSTD-1` 和 `UCIO-1`，见 `data/m2/validation/clbll_l_y30/a3/build.log:494-498`。这未必污染目标 frame，但应作为 bitstream 生成控制项，而不是默认为无关。

**P2（改进）**

- JSON 没有记录实验时间、Vivado seed、完整约束快照、工具版本摘要和归一化 bitstream hash。
- `M2_CORPUS.md:40-42` 只描述一次 `m2_mcd_0002` 重跑；其余 pair 没有逐 pair rerun 证据。
- `CLBLM_L` 的 SLICEM/SLICEL 差异很有价值，但目前只有一个位置各一组，不能区分 site-type 效应与列/布线效应。

目前分类如下：

- **证据支持：** A3→A5 在这些样例中通常替换一个 INT mux PIP 和一个 site PIP；A1→A3 的确产生更大 route 差异，见 `A1_A3_NEGATIVE.md:6-14`；Y30/Y40 的记录与局部 word 模型一致。
- **合理假设：** word 50 主要是 ECC/aux；A3→A5 的 3 个 bit 可能主要反映 site-PIP 编码；`word = 2*row + half` 可能适用于同一 clock region。
- **尚未验证：** 5 个 pair 的独立性；JSON 与真实 bitstream 的逐位一致性；word 50 无真实数据位；跨 row-50/clock-region 的模型；INT mux 与 site-PIP 的可分离性；bitstream 差异没有 placement、CRC、header 或其他辅助区域伪阳性。

优先实验：

1. **重建并归档完整证据包。**  
   目的：让每个 pair 可复算。输入：两份 `.bit/.bin`、两份 `pips.txt`、两份 `build.log`、XDC、Vivado 版本。通过标准：所有引用文件存在；逐条 route 集合与 pips 一致；规范化 frame diff 与 JSON 完全一致；整文件 SHA 只作为 provenance。
2. **独立 pin-transition 复现实验。**  
   目的：打破 A3→A5 单一模式。输入：同一 tile/row 的 A1→A3、A2→A4、A5→A6，固定 placement、BEL、INIT、I/O。通过标准：至少两种 transition 产生不同且可重复的 route/diff 签名。
3. **Y49/Y50/Y51 边界实验。**  
   目的：验证 word 50 与 clock-region 边界。输入：相邻三行、相同 CLBLL_L 设计。通过标准：明确记录 word 49/50/51 的全部变化，并证明排除 word 50 不删除目标数据位。
4. **跨 family held-out replay。**  
   目的：检验模型是否可泛化。输入：未参与拟合的 CLBLM_L、CLBLM_R、不同 X 列。通过标准：预测 word、frame group、bit positions 全部命中；失败时明确限定模型适用范围。
5. **分离 INT/site-PIP 实验。**  
   目的：获得可归因的 incidence。输入：第二 sink 或受控拥塞设计，固定目标 site 并记录新增负载。通过标准：存在只改变上游 INT、或可由线性代数唯一分解的观测；否则不得进行 bit flipping。

可直接执行的最小下一步清单：

1. 确认 `Test-Path` 对每个 JSON 的 `evidence.*` 全部为真。  
2. 对每个 pair 运行只读的 frame parser/diff，保存 stdout。  
3. 检查 A/B frame 数完全相等。  
4. 重新计算 `set(route_a) ^ set(route_b)`，与 JSON 比较。  
5. 从 `pips.txt` 重新抽取 route，和 JSON 逐行比较。  
6. 输出所有差异 `(frame,word,bit)`，同时保留 word 50，不要先过滤。  
7. 标记 header、CRC、aux、配置寄存器区域并单独统计。  
8. 对每个 pair 至少做一次独立 rerun，记录 bitstream 规范化 hash。  
9. 增加 A2/A4/A6 transition，至少获得两种非 A3→A5 模式。  
10. 在 Y49/Y50/Y51 完成边界测试后，才决定是否进入 STEP04。