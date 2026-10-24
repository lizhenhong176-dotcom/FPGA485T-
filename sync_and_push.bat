@echo off
REM FPGA485T 自动同步批处理脚本
REM 每 24 小时运行一次
setlocal enabledelayedexpansion

echo [=== FPGA485T Auto Sync ===]
echo Time: %date% %time%

REM 切换到项目目录
cd /d "E:\DEEPSEEK\FPGA比特流逆向"

REM 调用 PowerShell 脚本
powershell -ExecutionPolicy Bypass -File "%~dp0sync_and_push.ps1"

pause
