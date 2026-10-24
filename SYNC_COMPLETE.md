# ✅ FPGA485T 自动同步系统 - 设置完成报告

## 📊 配置状态

| 组件 | 状态 | 说明 |
|---|---|---|
| Git 远程仓库 | ✅ 已配置 | `https://github.com/lizhenhong176-dotcom/FPGA485T-.git` |
| Git credential helper | ✅ 已配置 | `manager` (Windows 凭据管理器) |
| 同步脚本 | ✅ 已创建 | `sync_and_push.ps1` |
| 定时任务安装器 | ⚠️ 待运行 | `install_task.cmd`（需管理员权限） |
| GitHub Token 认证 | ❌ 待配置 | **用户需要手动完成** |

## 🎯 已完成的工作

### 1. Git 远程仓库配置
- 添加 origin: `https://github.com/lizhenhong176-dotcom/FPGA485T-.git`
- 配置 credential manager 用于身份验证

### 2. 同步脚本 (`sync_and_push.ps1`)
功能清单：
- ✅ SSH 连接到远端 (s.tschai@172.17.70.41)
- ✅ rsync 增量同步到 E:\v7work
- ✅ 更新 STATUS.md 时间戳
- ✅ 更新 README.md 时间戳
- ✅ Git add + commit
- ✅ Git push origin main/master

### 3. 定时任务安装器
- `install_task.cmd` — 管理员批处理脚本
- `start_sync_task.ps1` — PowerShell 版本（备用）
- `task_fpga_sync.xml` — XML 定义文件

### 4. 文档
- `SYNC_GUIDE.md` — 详细使用指南
- `SYNC_USAGE.md` — 快速使用说明
- `GITHUB_AUTH_SETUP.md` — GitHub Token 配置步骤

## ⚠️ 需要你完成的最后一步

### GitHub Token 认证（必须！）

由于当前环境是非交互式的，Git Credential Manager 无法弹出认证窗口。请按以下步骤配置：

#### 方法 A：一次性命令行配置（推荐）

```powershell
# 以当前用户身份运行（不需要管理员）
cmdkey /add:"Git:https://github.com" /user:lizhenhong176-dotcom /pass:你的_GitHub_Token
```

Token 获取：https://github.com/settings/tokens → Generate new token (classic) → 勾选 `repo` 权限

#### 方法 B：通过图形界面配置

1. 打开 **控制面板 → 用户账户 → 凭据管理器**
2. 选择 **Windows 凭据**
3. 点击 **添加普通凭据**
4. 填写：
   - **Internet 或网络地址**: `Git:https://github.com`
   - **用户名**: `lizhenhong176-dotcom`
   - **密码**: `ghp_你的_token`
5. 保存

#### 方法 C：首次手动推送时输入

```powershell
# 运行任意 git 命令触发认证
git fetch origin
# 此时会弹出一个窗口，输入：
# Username: lizhenhong176-dotcom
# Password: ghp_xxxxxx (GitHub Token)
```

### 验证认证是否成功

```powershell
git fetch origin
# 如果无错误输出，说明认证成功
```

## 📅 设置定时任务（可选但推荐）

### 一键安装（需要管理员权限）

```cmd
REM 右键 install_task.cmd → 以管理员身份运行
```

### 或者手动创建

1. 打开 **任务计划程序** (`taskschd.msc`)
2. **操作 → 导入任务**
3. 选择 `task_fpga_sync.xml`
4. 确认触发器为 **每天一次，每隔 1 天重复**

### 管理定时任务

```cmd
# 查看任务
schtasks /query /tn "FPGA485T Auto Sync"

# 立即测试运行
schtasks /run /tn "FPGA485T Auto Sync"

# 删除任务
schtasks /delete /tn "FPGA485T Auto Sync" /f
```

## 🔄 测试同步（建议先手动运行一次）

```powershell
cd E:\DEEPSEEK\FPGA比特流逆向
powershell -ExecutionPolicy Bypass -File .\sync_and_push.ps1
```

预期流程：
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
✓ 推送到 main 成功

=== 同步完成 ===
下次运行时间：2026-10-25 18:00:00
```

## 📁 新增文件清单

| 文件 | 大小 | 用途 |
|---|---|---|
| `sync_and_push.ps1` | ~200 行 | 主同步脚本 |
| `sync_and_push.bat` | ~15 行 | 批处理包装器 |
| `start_sync_task.ps1` | ~40 行 | PowerShell 版任务创建 |
| `install_task.cmd` | ~30 行 | 管理员版任务创建 |
| `task_fpga_sync.xml` | ~40 行 | XML 任务定义 |
| `SYNC_GUIDE.md` | 完整文档 | 详细使用指南 |
| `SYNC_USAGE.md` | 快速参考 | 简明使用说明 |
| `GITHUB_AUTH_SETUP.md` | 认证指南 | GitHub Token 配置 |
| `SYNC_COMPLETE.md` | 本文档 | 设置完成报告 |

## 🔧 自定义调整

### 修改同步的文件

编辑 `sync_and_push.ps1` 中的 `$SyncPaths`：

```powershell
$SyncPaths = @(
    "/opt/lzh/v7re/data/model/v7_model.sqlite",  # 模型库
    "/opt/lzh/v7re/work/refs_20261021/probe/result.json",
    "/opt/lzh/step03/pip1",
    "/opt/lzh/step03/pip2"
)
```

### 修改同步时间

```cmd
REM 改为每天早上 9 点
schtasks /change /tn "FPGA485T Auto Sync" /st 09:00
```

### 暂停/恢复自动同步

```cmd
schtasks /change /tn "FPGA485T Auto Sync" /disable  REM 暂停
schtasks /change /tn "FPGA485T Auto Sync" /enable   REM 恢复
```

## 🆘 故障排除

| 问题 | 解决方案 |
|---|---|
| 推送失败 "could not read Username" | 按 GITHUB_AUTH_SETUP.md 配置 Token |
| SSH 连接超时 | 检查防火墙和 VPN 设置 |
| 定时任务不运行 | 检查任务计划程序状态，查看历史记录 |
| 脚本报错执行策略 | 使用 `-ExecutionPolicy Bypass` 参数 |
| Git commit 被拒绝 | 检查是否有未提交的冲突文件 |

## 📞 需要帮助？

如果遇到问题，请检查：

1. **Git 状态**：`git status`
2. **远程仓库**：`git remote -v`
3. **Credential 配置**：`git config --list | findstr credential`
4. **定时任务状态**：`schtasks /query /tn "FPGA485T Auto Sync" /v`
5. **日志位置**：脚本输出到控制台，可在 Windows 事件查看器中查找

---

**配置时间**: 2026-10-24  
**下次操作**: 配置 GitHub Token → 测试运行 → 安装定时任务
