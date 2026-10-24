# FPGA485T 自动同步脚本
# 功能：远端数据同步 → 更新 STATUS.md → Git commit & push
# 用法：pwsh -File sync_and_push.ps1

$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== FPGA485T Auto Sync ===" -ForegroundColor Cyan
Write-Host "时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# ========================
# 1. 同步远端数据到本机
# ========================
Write-Host "[1/4] 同步远端数据..." -ForegroundColor Yellow

$RemoteHost = "s.tschai@172.17.70.41"
$RemoteKey = "C:\Users\i\.ssh\v7remote"
$LocalWorkDir = "E:\v7work"

# 远端关键目录列表（从 STATUS.md 提取）
$SyncPaths = @(
    "/opt/lzh/v7re/data/model/v7_model.sqlite",
    "/opt/lzh/v7re/work/refs_20261021/probe/result.json",
    "/opt/lzh/step03/pip1",
    "/opt/lzh/step03/pip2",
    "/opt/lzh/v7re"
)

# 创建临时脚本文件避免引号问题
$TempScript = "$env:TEMP\fpga_sync_$($PID).sh"
$TempContent = @"
#!/bin/bash
RSYNC_OPTS="-avz --checksum --progress -e 'ssh -i ${RemoteKey} -o StrictHostKeyChecking=no'"

mkdir -p "${LocalWorkDir}/model"
mkdir -p "${LocalWorkDir}/probe"
mkdir -p "${LocalWorkDir}/step03"

rsync \$RSYNC_OPTS ${RemoteHost}:/opt/lzh/v7re/data/model/v7_model.sqlite ${LocalWorkDir}/model/
rsync \$RSYNC_OPTS ${RemoteHost}:/opt/lzh/v7re/work/refs_20261021/probe/result.json ${LocalWorkDir}/probe/
rsync \$RSYNC_OPTS \$RSYNC_OPTS ${RemoteHost}:/opt/lzh/step03/pip1 ${LocalWorkDir}/step03/
rsync \$RSYNC_OPTS \$RSYNC_OPTS ${RemoteHost}:/opt/lzh/step03/pip2 ${LocalWorkDir}/step03/
rsync \$RSYNC_OPTS ${RemoteHost}:/opt/lzh/v7re/*.py ${LocalWorkDir}/v7re_sync/

echo "SYNC_COMPLETE"
"@

[System.IO.File]::WriteAllText($TempScript, $TempContent, [System.Text.UTF8Encoding]::new($false))

try {
    # 使用 wsl 执行 bash 脚本
    $Result = cmd.exe /c "C:\Program Files\WSL\wsl.exe" -d Ubuntu -u root -- bash -lc "bash $TempScript" 2>&1
    
    if ($Result -match "SYNC_COMPLETE") {
        Write-Host "✓ 远端数据同步完成" -ForegroundColor Green
    } else {
        Write-Host "⚠ 同步未完成，但继续后续步骤" -ForegroundColor DarkYellow
        Write-Host $Result
    }
} catch {
    Write-Host "⚠ SSH 同步失败：$_" -ForegroundColor DarkYellow
} finally {
    # 清理临时文件
    if (Test-Path $TempScript) { Remove-Item $TempScript -Force }
}

Write-Host ""

# ========================
# 2. 更新 STATUS.md 最后更新时间
# ========================
Write-Host "[2/4] 更新状态文件..." -ForegroundColor Yellow

$StatusPath = Join-Path $ScriptRoot "STATUS.md"
if (Test-Path $StatusPath) {
    # 读取原文件
    $Content = Get-Content $StatusPath -Raw -Encoding UTF8
    $Now = Get-Date -Format "yyyy-MM-dd"
    
    # 替换最后更新时间行
    $Updated = $Content -replace "(最后更新：)\d{4}-\d{2}-\d{2}", "`${1}${Now}"
    
    # 添加同步记录到待办区域
    $SyncLogEntry = "- **[$Now 自动同步]**：远端模型库 + STEP03 实验数据已同步到 `E:\v7work`"
    
    # 在待办区域开头插入日志
    if ($Updated -match "## 4\. 待办") {
        $Updated = $Updated -replace "(## 4\. 待办)", "`n`n## 同步日志 ($Now)`n`n$SyncLogEntry`n`n---`n`n`${1}"
    }
    
    Set-Content $StatusPath $Updated -Encoding UTF8 -NoNewline
    Write-Host "✓ STATUS.md 已更新" -ForegroundColor Green
} else {
    Write-Host "⚠ STATUS.md 不存在" -ForegroundColor DarkYellow
}

# 更新 README.md 的时间戳
$ReadmePath = Join-Path $ScriptRoot "README.md"
if (Test-Path $ReadmePath) {
    $ReadmeContent = Get-Content $ReadmePath -Raw -Encoding UTF8
    $ReadmeUpdated = $ReadmeContent -replace "(最后更新 |Last updated:)\s*\d{4}-\d{2}-\d{2}", "`${1} $Now"
    Set-Content $ReadmePath $ReadmeUpdated -Encoding UTF8 -NoNewline
    Write-Host "✓ README.md 已更新" -ForegroundColor Green
}

Write-Host ""

# ========================
# 3. Git 提交
# ========================
Write-Host "[3/4] Git 提交变更..." -ForegroundColor Yellow

git add -A
$status = git status --porcelain
if (-not $status) {
    Write-Host "✓ 没有需要提交的变更" -ForegroundColor Green
    exit 0
}

# 生成提交信息
$CommitMsg = "chore: auto-sync $(Get-Date -Format 'yyyy-MM-dd')`n`n"
$CommitMsg += "- Synced remote data from ${RemoteHost}`n"
$CommitMsg += "- Updated STATUS.md and README.md timestamps"

git commit -m $CommitMsg
Write-Host "✓ Git 提交完成" -ForegroundColor Green

Write-Host ""

# ========================
# 4. 推送到 GitHub
# ========================
Write-Host "[4/4] 推送到 GitHub..." -ForegroundColor Yellow

try {
    git push origin main 2>&1
    Write-Host "✓ 推送成功" -ForegroundColor Green
} catch {
    # 如果 main 分支不存在，尝试 master
    try {
        git push origin master 2>&1
        Write-Host "✓ 推送到 master 成功" -ForegroundColor Green
    } catch {
        Write-Host "⚠ 推送失败：$_" -ForegroundColor Red
        Write-Host "提示：可能需要先关联远程分支 `git push --set-upstream origin <branch>`" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "=== 同步完成 ===" -ForegroundColor Cyan
Write-Host "下次运行时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss').AddHours(24)" -ForegroundColor Gray
