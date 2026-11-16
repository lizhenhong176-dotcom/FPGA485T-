为 fpga-bitstream-experiment skill 的 reference/commands.md 追加一个「踩坑与硬约束」小节，中文 Markdown，可直接追加到文件末尾，不含开场白和结尾总结。

结构要求：
- 一级标题固定为「## 踩坑与硬约束（2026-11-06 实测）」
- 每条使用「### N. 标题」，标题后紧跟「- 现象：」「- 根因：」「- 修法：」三行小结构，顺序不可变
- 代码、命令、报错原文用行内 code 或 fenced block 呈现，修法中的命令必须可直接照抄

必须覆盖以下 6 条，逐条给出报错原文、根因、可照抄修法：
1. WSL 内 Vivado abort rc=134：报错原文含 `terminate called ... locale::facet::_S_create_c_locale name not valid`；根因为 Windows 的 LANG 被带入 WSL 且该 locale 未安装；修法为脚本开头执行 `export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE`。
2. LOCK_PINS 管脚名不按 BEL 命名：SLICEM.B6LUT 的 BEL 管脚仍为 A1..A6，写 `I0:B1` 报 `ERROR: [Vivado 12-2497] invalid device pin 'B1'`；修法为先 `get_bel_pins` 实测，四个 LUT 一律 `I0..I5 -> A1..A6`。
3. 本地 run_code/pwsh 默认超时 120s 短于多构建墙钟；修法为显式抬高 timeoutMs（11 个构建约 3 分钟）。
4. 远端取文件禁止把 base64 塞进命令行（会 ENAMETOOLONG 且被污染成前导全零）；修法为远端 `tar czf -` 管道 `base64 -w0` 落到本地文件再解码，更省的做法是远端直接差分只回传 JSON。
5. 修改中文长文档（如 STATUS.md）禁止 read 全文 + write 全文回写：read 有行数上限，回写会截断文件；修法为追加用 Python `open(...,'a',encoding='utf-8')`，定点改用 edit，写前先备份。
6. 远端 ssh 姿势唯一可用形态：`cmd /c 'ssh -o ConnectTimeout=10 fpga "C:\PROGRA~1\WSL\wsl.exe -d Ubuntu -u root -- bash -s" < script.sh'`；远端命令里的 `|` 管道会被 cmd 截断，必须整段走 `bash -s` 脚本。