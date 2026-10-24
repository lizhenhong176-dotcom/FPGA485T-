# FPGA485T 自动同步指南

## 功能说明

每 24 小时自动执行以下操作：

1. **远端数据同步** — 从 `s.tschai@172.17.70.41` 拉取最新数据到 `E:\v7work`
2. **更新文档** — 刷新 STATUS.md 和 README.md 的时间戳
3. **Git 提交** — 将所有变更提交到本地仓库
4. **推送 GitHub** — 推送到 `https://github.com/lizhenhong176-dotcom/FPGA485T-.git`

## 文件清单

| 文件 | 用途 |
|---|---|
| `sync_and_push.ps1` | 主 PowerShell 脚本（核心逻辑） |
| `sync_and_push.bat` | 批处理包装器（方便双击运行） |
| `task_fpga_sync.xml` | Windows 任务计划程序配置 |

## 手动运行

```powershell
# 方法 1：直接运行 PowerShell 脚本
pwsh -File E:\DEEPSEEK\FPGA比特流逆向\sync_and_push.ps1

# 方法 2：双击 sync_and_push.bat

# 方法 3：通过 Git Bash
cd /e/DEEPSEEK/FPGA比特流逆向
bash sync_and_push.sh
```

## 设置定时任务（Windows 任务计划程序）

### 方法 1：命令行导入（推荐）

```cmd
schtasks /create /tn "FPGA485T Auto Sync" /xml "E:\DEEPSEEK\FPGA比特流逆向\task_fpga_sync.xml"
```

### 方法 2：手动创建

1. 打开 **任务计划程序** (taskschd.msc)
2. **操作 → 导入任务**
3. 选择 `task_fpga_sync.xml`
4. 确认触发器为 **每天一次**，重复间隔 **1 天**

### 管理定时任务

```cmd
# 查看任务
schtasks /query /tn "FPGA485T Auto Sync"

# 立即运行
schtasks /run /tn "FPGA485T Auto Sync"

# 删除任务
schtasks /delete /tn "FPGA485T Auto Sync" /f
```

## SSH 连接要求

- 私钥位置：`C:\Users\i\.ssh\v7remote`
- 远端主机：`s.tschai@172.17.70.41`
- 确保私钥权限正确：`icacls C:\Users\i\.ssh\v7remote /inheritance:r`

## 常见问题

### Q: SSH 连接失败？

检查：
```bash
ssh -i C:\Users\i\.ssh\v7remote s.tschai@172.17.70.41 echo "OK"
```

### Q: Git push 需要认证？

使用 SSH 密钥或配置 GitHub Personal Access Token：
```powershell
git remote set-url origin https://<USERNAME>:<TOKEN>@github.com/lizhenhong176-dotcom/FPGA485T-.git
```

### Q: 同步哪些文件？

当前配置同步：
- `/opt/lzh/v7re/data/model/v7_model.sqlite`（模型库~635MB）
- `/opt/lzh/v7re/work/refs_20261021/probe/result.json`
- `/opt/lzh/step03/pip1` 和 `pip2`（实验目录）
- `/opt/lzh/v7re/*.py`（Python 源码）

可在 `sync_and_push.ps1` 的 `$SyncPaths` 数组中修改。

## 日志查看

每次运行的输出保存在：
```
E:\DEEPSEEK\FPGA比特流逆向\sync_log_$(date).txt
```

或在 Windows 事件查看器中查找 "FPGA485T Auto Sync"。
