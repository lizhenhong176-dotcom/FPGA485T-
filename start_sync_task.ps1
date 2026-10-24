# 创建 Windows 定时任务的 PowerShell 脚本
$TaskName = "FPGA485T Auto Sync"
$ScriptPath = "E:\DEEPSEEK\FPGA比特流逆向\sync_and_push.ps1"

Write-Host "=== 设置 FPGA485T 自动同步定时任务 ===" -ForegroundColor Cyan

# 删除已存在的同名任务（如果有）
$Existing = schtasks /query /tn $TaskName /fo CSV 2>$null
if ($Existing) {
    Write-Host "删除现有任务..." -ForegroundColor Gray
    schtasks /delete /tn $TaskName /f
}

# 获取当前用户
$CurrentUser = $env:USERNAME

# 创建动作（Action）
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$ScriptPath`""

# 创建触发器：每天每 24 小时
$trigger = New-ScheduledTaskTrigger -Daily -At (Get-Date -Format "HH:mm")
# 修改为每隔 24 小时
$trigger.Repetition.Interval = "P1D"

# 设置主体
$principal = New-ScheduledTaskPrincipal -LogonType Interactive -UserId $CurrentUser

# 设置运行条件（不断电、不限网络）
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 72)

# 注册任务
Register-ScheduledTask -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "FPGA485T 自动同步远端数据到本地，更新说明文件并上传 GitHub（每 24 小时）"

Write-Host "✓ 定时任务已创建：$TaskName" -ForegroundColor Green
Write-Host ""
Write-Host "任务详情：" -ForegroundColor Yellow
schtasks /query /tn $TaskName /v /fo LIST
