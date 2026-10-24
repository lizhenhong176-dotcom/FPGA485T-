@echo off
REM 如果重启后 DSH 起不来（多半是 dsh-better-sidebar 与当前运行时版本冲突），
REM 双击本文件即可回滚到重启前的插件组合。
set DSH=E:\Users\i\AppData\Local\Programs\DeepSeek Harness\resources\runtime\cli\bin\dsh.cmd
call "%DSH%" plugin --profile desktop remove dsh-better-sidebar
call "%DSH%" plugin --profile desktop remove dsh-ide-git
echo.
echo 已移除 dsh-better-sidebar 与 dsh-ide-git，现在重新打开 DeepSeek Harness。
pause
