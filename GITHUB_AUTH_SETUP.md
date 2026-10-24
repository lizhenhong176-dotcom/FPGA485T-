# GitHub 认证配置指南

## 📋 快速设置（只需一次）

由于 GitHub 禁用了密码认证，需要使用 **Personal Access Token (PAT)**。

### 第一步：生成 GitHub Token

1. 打开 https://github.com/settings/tokens
2. 点击 **Generates new token → Generates new token (classic)**
3. 填写：
   - **Note**: `FPGA485T Auto Sync`
   - **Expiration**: 选择过期时间（建议 90 天）
   - **权限**：勾选 `repo` (Full control of private repositories)
4. 点击 **Generate token**
5. **复制并保存 Token**（格式如 `ghp_xxxxxxxxxxxx`）

### 第二步：配置到 Git Credential Manager

#### 方法 A：使用命令行（推荐）

```powershell
# 在 PowerShell 中运行
git config --global credential.helper manager

# 触发认证（任意 git 命令即可）
git fetch origin

# 会弹出窗口输入：
# Username: 你的 GitHub 用户名 (lizhenhong176-dotcom)
# Password: 粘贴刚才的 GitHub Token
```

#### 方法 B：手动存储到 Windows 凭据管理器

```powershell
# 以管理员身份运行 PowerShell
$cred = New-Object System.Management.Automation.PSCredential `
    ("lizhenhong176-dotcom", (ConvertTo-SecureString "ghp_xxxxxxxx" -AsPlainText -Force))
Store-Credential -Target "git:https://github.com" -Credential $cred
```

### 第三步：验证

```powershell
git fetch origin
# 如果成功且无错误提示，说明认证配置正确
```

## 🔧 脚本中的其他认证方式

### 环境变量方式（适合自动化）

在 `sync_and_push.ps1` 开头添加：

```powershell
# 设置环境变量
$env:GH_TOKEN = "ghp_your_token_here"

# 或使用 HTTPS URL 带 Token
git remote set-url origin "https://lzh:lhp@github.com/lizhenhong176-dotcom/FPGA485T-.git"
```

### SSH 密钥方式（需要开放 22 端口）

```powershell
# 生成 SSH 密钥
ssh-keygen -t ed25519 -C "FPGA485T Auto Sync"

# 添加到 GitHub
# 1. 查看公钥：cat ~/.ssh/id_ed25519.pub
# 2. 复制输出到 https://github.com/settings/keys

# 修改远程仓库为 SSH URL
git remote set-url origin git@github.com:lizhenhong176-dotcom/FPGA485T-.git
```

## ⚠️ 常见问题

### Q1: 推送时提示 "Username for 'https://github.com'"

解决方案：配置了 credential helper 但仍需要输入。按提示输入：
- **Username**: GitHub 用户名
- **Password**: GitHub Token（不是登录密码！）

### Q2: "fatal: could not read Username"

原因：在非交互式环境中无法弹出认证窗口。

解决方案 1：预先存储凭据
```cmd
cmdkey /add:"Git:https://github.com" /user:lizhenhong176-dotcom /pass:ghp_xxxxxx
```

解决方案 2：使用环境变量
```powershell
$env:GIT_ASKPASS = "echo"  # 禁用交互式提示
$Token = "ghp_xxxxxx"
git push origin main 2>&1
```

### Q3: Connection timed out (SSH)

GitHub 的 22 端口在网络中被阻断。使用 HTTPS + Token 方式。

### Q4: "Permission denied (publickey)"

SSH 私钥无效或未添加到 GitHub。检查：
```bash
ssh -T git@github.com
# 应返回 "Hi username! You've successfully..."
```

## 🔄 定期更换 Token

GitHub Token 有有效期，到期前需要：

1. 在 GitHub settings/tokens 生成新 Token
2. 更新 Windows 凭据管理器中的密码
3. 或更新 `sync_and_push.ps1` 中的 Token

## 💡 最佳实践

| 场景 | 推荐方式 |
|---|---|
| 个人电脑自动同步 | Windows Credential Manager + HTTPS |
| 服务器/CICD | 环境变量或 secrets 存储 |
| 长期项目 | SSH 密钥 + Agent |
| 多平台兼容 | HTTPS + PAT |
