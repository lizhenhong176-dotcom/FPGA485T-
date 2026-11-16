盘点这个 FPGA 比特流逆向项目里「PIP 线」的当前进度，产出一份可直接复算的进度报告。

背景：xc7vx485tffg1761-2（VC707），工作区 E:\DEEPSEEK\FPGA比特流逆向，数据库 E:\v7work\model\v7_law.sqlite（law_tiles / law_cells / far_bands / ppips）与 v7_model.sqlite（pip_bits / site_frames / frame_map），
文档在 step03_pip/ 与 v7re/steps/，状态以 STATUS.md 为准。

要盘的内容：
1) 帧地址与定位：band / col / frame_off / word / bit 五层换算，FAR 字段，overhead 帧，word 50 的 ECC。
2) PIP → 位库：每个 INT tile 3,737 条 PIP 的构成（多源族 + 直通），172 个 family 的码字，sense=1 与 sense=0 两类行。
3) 复用规律：复用度量（码字列重）、7 种谱型、乘积结构、跨族共享、家族内唯一性、子集对。
4) 读写闭环：解码器、写入器、位级往返、篡改检出与定位。
5) 跨 tile 类型：A/B/C/D 四类 PIP 的普查结果与迁移计划现状。
6) 缺口与风险：数据层缺口、ECC 未闭合项、单器件局限、哪些结论已作废。

输出要求：一张按证据可复算的进度表 + 已作废结论清单 + 缺口账 + 下一步优先级。
