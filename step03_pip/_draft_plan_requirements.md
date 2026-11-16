V2 需要补齐以下缺失，其余结构与 V1 保持一致：

1. 现状基线必须带**具体证据指针**（文件:行号），至少覆盖：
   - `step03_pip/REUSE_RULES.md:8`：形状表来源是 prjxray artix7 segbits（跨家族沿用）——这决定了「自研」边界必须在计划里讲清；
   - `v7re/steps/T3_PIP_REUSE_LAW.md` §9.2：12 个复合族当时记为「主码+附码、跨 parity、未闭合」，这是 A 轨要收口的原点；
   - `v7re/steps/T35_COMPOSITE_GROUP_MODEL.md`、`v7re/steps/composite_groups.json`：组模型；
   - `v7re/scripts/verify_all_pip.py`：172/172 的复算入口；
   - `STATUS.md` §56（T23：LUT INIT 索引顺序随 slice 种类不同、T19 表接入 build_site_frames）。
2. 技术债必须写具体，不能只写「错误」：
   - `site_frames` 现存 INIT 行 = 2,425,600 行（仅 X0 的 ALUT），BLUT/CLUT/DLUT 共约 727 万行已主动删除；
   - `_full8.bit`（ALUT INIT=1）能解出 `0x1`，但 `_full8_i3.bit`（INIT=3）解出 `0x100000001`，多出的第 32 位来自真实差格 `(31786, 40, 7)`，而实测表把该格标成 k=32 —— 即**格集合正确、索引标签被置换**；
   - 库体积：site_frames 属 7.9 GB 级持久表，任何替换必须走事务 + 备份，禁止全量回写。
3. 每个任务必须给**可复算的验收命令与预期输出**，并至少包含这几条回归门：
   - `python v7re/scripts/verify_all_pip.py --tile-type INT_L` → 172 家族 / 3,634 feature / 精确命中 3,634 / 未覆盖 0 / 不符 0；
   - 同一命令加 `--tile-type INT_R`；
   - `python v7re/scripts/tamper_localize.py --check <干净.bit>` → L1 未解释位 0（白名单后）、L2 槽位违例 0；
   - T5 往返：清空重建 9/9 tile、52 条 PIP、0 差异。
4. 环境细节要写全：Python 3.8 + numpy/pyyaml/intervaltree/pytest；Vivado 2017.2 位于 `E:\app\Vivado\2017.2\bin\vivado.bat`；构建必须在 `C:\Temp\tamper_ref`（纯 ASCII），产物拷回工作区；`write_bitstream` 需把 NSTD-1/UCIO-1 降为 Warning 且 DRC 豁免不随 dcp 保存，必须在 Tcl 里重设；远端用 `cmd /c 'ssh -o BatchMode=yes fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < script.sh'`，脚本必须 LF 且 `LANG=C`。
5. 风险与回滚要具体：改 `site_frames` 前先 `ATTACH` 备份库或 `VACUUM INTO`；每次替换限定 `tile_type`+`family` 子集并先在副本库上跑验收；失败回滚 = 从备份库恢复该表；Vivado 构建失败回滚 = 丢弃 `C:\Temp\tamper_ref` 产物，不动工作区已有 `.bit`。
6. 时间估计要给区间并标注不确定性来源（例如「B 轨 3–5 人日，取决于索引置换规律能否在 1 天内在 2 个 LUT 种类上闭合」）。
7. 明确「必须问用户」的边界只有三类：删改持久表、动远端在用目录、跑 Vivado 构建（耗时且需要 ASCII 目录）。其余可自行决定。
