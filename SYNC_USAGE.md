# FPGA485T 自动同步 - 使用说明

## ✅ 已完成配置

1. **Git 远程仓库** — 已添加 `origin` → `https://github.com/lizhenhong176-dotcom/FPGA485T-.git`
2. **同步脚本** — `sync_and_push.ps1`（核心逻辑）
3. **定时任务安装器** — `install_task.cmd`（需管理员权限）
4. **使用文档** — `SYNC_GUIDE.md`

## 📋 执行步骤

### 第一步：首次手动运行测试

```powershell
# 在项目目录打开 PowerShell
cd E:\DEEPSEEK\FPGA比特流逆向

# 以 bypass 方式运行脚本
powershell -ExecutionPolicy Bypass -File .\sync_and_push.ps1
```

预期输出：
```
=== FPGA485T Auto Sync ===
[1/4] 同步远端数据...
✓ 远端数据同步完成
[2/4] 更新状态文件...
✓ STATUS.md 已更新
✓ README.md 已更新
[3/4] Git 提交变更...
✓ Git 提交完成
[4/4] 推送到 GitHub...
✓ 推送成功
```

### 第二步：设置每天自动运行（可选）

```cmd
REM 右键 install_task.cmd -> 以管理员身份运行
```

这会在 Windows 任务计划程序中注册 "FPGA485T Auto Sync" 任务：
- **频率**：每 24 小时
- **默认时间**：每天 18:00
- **可修改**：在任务计划程序中编辑触发器

### 第三步：验证同步

检查同步的数据文件是否存在：
```powershell
dir E:\v7work\model\v7_model.sqlite
dir E:\v7work\step03\pip1
```

查看 Git 历史记录：
```bash
git log --oneline -5
```

## 🔧 自定义配置

### 修改同步的文件列表

编辑 `sync_and_push.ps1` 中的 `$SyncPaths` 数组：

```powershell
$SyncPaths = @(
    "/opt/lzh/v7re/data/model/v7_model.sqlite",  # 模型库
    "/opt/lzh/v7re/work/refs_20261021/probe/result.json",  # 探针数据
    "/opt/lzh/step03/pip1",  # STEP03 实验 1
    "/opt/lzh/step03/pip2",  # STEP03 实验 2
    "/opt/lzh/v7re"  # v7re 源码
)
```

### 修改同步时间

#### 方法 1：命令行（管理员）
```cmd
schtasks /change /tn "FPGA485T Auto Sync" /st 09:00
```

#### 方法 2：图形界面
1. 打开 **任务计划程序** (`taskschd.msc`)
2. 找到 **FPGA485T Auto Sync**
3. 双击 → **触发器** 选项卡 → 编辑

## 🆘 故障排除

| 问题 | 解决方案 |
|---|---|
| SSH 连接失败 | 检查私钥 `C:\Users\i\.ssh\v7remote` 是否有效 |
| Git push 被拒 | 配置 GitHub Token: `git remote set-url origin https://USER:TOKEN@github.com/...` |
| 脚本执行被阻止 | 使用 `-ExecutionPolicy Bypass` 参数 |
| 需要管理员权限 | 右键 `install_task.cmd` → 以管理员身份运行 |
| 远端 IP 变了 | 编辑 `sync_and_push.ps1` 中的 `$RemoteHost` |

## 📁 生成的文件说明

| 文件 | 用途 |
|---|---|
| `sync_and_push.ps1` | **主脚本** — 同步、更新、提交、推送 |
| `sync_and_push.bat` | 批处理包装器（方便双击） |
| `start_sync_task.ps1` | PowerShell 版定时任务创建器 |
| `install_task.cmd` | 管理员版定时任务创建器（推荐） |
| `task_fpga_sync.xml` | XML 格式任务定义 |
| `SYNC_GUIDE.md` | 详细使用文档 |
| `.git` 仓库 | Git 历史（自动 commit + push） |

## 💡 注意事项

1. **网络要求** — 需要同能访问 GitHub 和远端机器 (172.17.70.41)
2. **磁盘空间** — `E:\v7work\model\v7_model.sqlite` 约 635MB
3. **SSH 私钥** — 确保私钥权限正确，仅当前用户可访问
4. **GitHub Token** — 如果使用 HTTPS，需要 Personal Access Token
5. **首次运行** — 建议先手动运行一次测试所有步骤

## 🔄 维护命令

```cmd
# 查看定时任务状态
schtasks /query /tn "FPGA485T Auto Sync" /v

# 立即运行一次
schtasks /run /tn "FPGA485T Auto Sync"

# 暂停任务
schtasks /change /tn "FPGA485T Auto Sync" /disable

# 启用任务
schtasks /change /tn "FPGA485T Auto Sync" /enable

# 删除任务
schtasks /delete /tn "FPGA485T Auto Sync" /f
```
