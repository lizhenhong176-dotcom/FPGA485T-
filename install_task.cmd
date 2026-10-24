@echo off
REM 以管理员权限创建 Windows 定时任务
REM 用法：右键此文件 -> 以管理员身份运行

echo [=== 安装 FPGA485T 自动同步定时任务 ===]

set TASK_NAME="FPGA485T Auto Sync"
set SCRIPT_PATH=E:\DEEPSEEK\FPGA比特流逆向\sync_and_push.ps1

REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [错误] 请以管理员身份运行此脚本！
    echo 右键此文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

REM 删除旧任务（如果存在）
schtasks /delete /tn %TASK_NAME% /f 2>nul

REM 创建新任务（每天 18:00 运行）
schtasks /create /tn %TASK_NAME% ^
    /tr "powershell -ExecutionPolicy Bypass -File ^"%SCRIPT_PATH^"" ^
    /sc DAILY /st 18:00 /sd 2026-10-24 ^
    /ru SYSTEM /f

if %errorLevel% equ 0 (
    echo [成功] 定时任务已创建
    echo.
    schtasks /query /tn %TASK_NAME% /v /fo LIST
) else (
    echo [失败] 无法创建任务
)

pause
