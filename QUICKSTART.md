# 快速开始指南

## 5 分钟快速上手

### 步骤 1: 准备环境

确保已安装:
- ✅ PowerShell 5.1 或更高版本
- ✅ Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)
- ✅ Git (可选,用于自动提交)

验证安装:
```powershell
# 检查 PowerShell 版本
$PSVersionTable.PSVersion

# 检查 Claude CLI
claude --version

# 检查 Git (可选)
git --version
```

### 步骤 2: 单个项目快速测试

```powershell
# 进入脚本目录
cd D:\cx

# 为单个项目生成 CLAUDE.md (预览模式)
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun

# 查看生成结果
notepad .\output\CLAUDE.md.new

# 查看变更报告
notepad .\output\changes-report.md

# 如果满意,正式应用
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"
```

### 步骤 3: 批量处理多个项目

```powershell
# 1. 复制配置文件模板
Copy-Item repos-config.example.json repos-config.json

# 2. 编辑配置文件,添加你的项目
notepad repos-config.json

# 3. 预览批量更新
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -DryRun

# 4. 正式批量更新
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json

# 5. 查看汇总报告
notepad .\batch-output\batch-summary-*.md
```

### 步骤 4: 设置定时任务 (可选)

```powershell
# 设置每天凌晨 2 点自动运行
.\setup-scheduled-task.ps1 `
    -ScriptPath "D:\cx\batch-regenerate-claude-md.ps1" `
    -ConfigPath "D:\cx\repos-config.json" `
    -Time "02:00"

# 立即测试运行
Start-ScheduledTask -TaskName "Claude-MD-Auto-Update"
```

---

## 配置文件示例

### repos-config.json

```json
{
  "repositories": [
    {
      "name": "my-frontend",
      "path": "D:\\projects\\my-frontend",
      "enabled": true
    },
    {
      "name": "my-backend",
      "path": "D:\\projects\\my-backend",
      "enabled": true
    }
  ],
  "gitConfig": {
    "user": "Claude Bot",
    "email": "claude-bot@company.com",
    "autoPush": false
  }
}
```

---

## 常见使用场景

### 场景 1: 新项目初始化

```powershell
# 为新项目生成 CLAUDE.md
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\new-project"

# 查看生成的文件
code D:\projects\new-project\CLAUDE.md
```

### 场景 2: 项目重构后更新

```powershell
# 重构后重新生成
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\refactored-app"

# 对比变化
git diff D:\projects\refactored-app\CLAUDE.md
```

### 场景 3: 每周例行更新

```powershell
# 批量更新所有项目
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json

# 查看哪些项目有更新
Get-Content .\batch-output\batch-summary-*.md | Select-String "Updated"
```

### 场景 4: 自动提交到 Git

```powershell
# 更新并自动提交
.\batch-regenerate-claude-md.ps1 `
    -ConfigFile repos-config.json `
    -AutoCommit

# 检查提交历史
cd D:\projects\my-app
git log --oneline | Select-String "CLAUDE.md"
```

---

## 输出文件说明

### 单个项目模式

```
output/
├─ CLAUDE.md.new          # 新生成的 CLAUDE.md
├─ CLAUDE.md.old          # 原文件备份
└─ changes-report.md      # 详细变更报告
```

### 批量模式

```
batch-output/
├─ batch-summary-20260315-143025.md    # 汇总报告
├─ project-alpha/
│  ├─ CLAUDE.md.new
│  ├─ CLAUDE.md.old
│  └─ changes-report.md
├─ project-beta/
│  ├─ CLAUDE.md.new
│  └─ changes-report.md
└─ project-gamma/
   └─ changes-report.md
```

---

## 验证生成结果

### 检查长度

```powershell
# 查看行数
(Get-Content .\output\CLAUDE.md.new).Count

# 理想: 40-80 行
# 可接受: 81-200 行
# 需要精简: 201-300 行
# 过长: 300+ 行
```

### 测试 Claude 是否能正常读取

```powershell
# 进入项目目录
cd D:\projects\my-app

# 启动 Claude Code
claude

# 在 Claude 中测试
# Claude 会自动读取 CLAUDE.md
```

---

## 故障排查

### 问题 1: Claude CLI 未找到

```powershell
# 安装 Claude Code CLI
npm install -g @anthropic-ai/claude-code

# 验证
claude --version
```

### 问题 2: 执行策略错误

```
错误: 无法加载文件,因为在此系统上禁止运行脚本
```

**解决方案**:
```powershell
# 临时允许 (当前会话)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 或永久允许 (需要管理员权限)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### 问题 3: 路径包含空格

```powershell
# 使用引号包裹路径
.\regenerate-claude-md.ps1 -ProjectPath "D:\My Projects\my app"
```

### 问题 4: 生成的内容太长

查看 `changes-report.md` 中的建议:
- 移除 Claude 可以推断的信息
- 将详细内容移到 `.claude/rules/`
- 使用文件引用代替代码示例

---

## 最佳实践

### ✅ 推荐做法

1. **先预览再应用**
   ```powershell
   # 总是先用 -DryRun 预览
   .\regenerate-claude-md.ps1 -ProjectPath "..." -DryRun
   ```

2. **定期更新**
   - 每周运行一次
   - 重大重构后立即运行
   - 添加新依赖后运行

3. **审查变更**
   - 仔细阅读 `changes-report.md`
   - 确保变更合理
   - 测试 Claude 是否能正常工作

4. **保留备份**
   - 脚本会自动备份
   - 也建议提交到 Git

5. **控制长度**
   - 目标: 40-80 行
   - 上限: 200 行
   - 超过 300 行必须精简

### ❌ 避免做法

1. **不要盲目应用**
   - 不看报告直接覆盖

2. **不要忽略警告**
   - 长度超过 200 行的警告

3. **不要手动编辑生成的文件**
   - 应该修改源信息后重新生成

4. **不要在生产环境直接运行**
   - 先在测试项目验证

---

## 进阶技巧

### 技巧 1: 自定义 Claude Prompt

编辑 `regenerate-claude-md.ps1` 中的 `$prompt` 变量,调整生成逻辑。

### 技巧 2: 添加项目特定规则

在配置文件中为每个项目添加自定义字段:

```json
{
  "name": "special-project",
  "path": "D:\\projects\\special",
  "customRules": [
    "Always use async/await",
    "Database access only through repositories"
  ]
}
```

### 技巧 3: 集成到 CI/CD

```yaml
# .github/workflows/update-claude-md.yml
name: Update CLAUDE.md

on:
  schedule:
    - cron: '0 2 * * *'  # 每天凌晨 2 点

jobs:
  update:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Update CLAUDE.md
        run: |
          .\regenerate-claude-md.ps1 -ProjectPath "."
      - name: Commit changes
        run: |
          git config user.name "Claude Bot"
          git config user.email "bot@company.com"
          git add CLAUDE.md
          git commit -m "chore: update CLAUDE.md [bot]"
          git push
```

### 技巧 4: 发送通知

在批量脚本末尾添加:

```powershell
# 发送 Slack 通知
$webhook = "https://hooks.slack.com/services/YOUR/WEBHOOK"
$body = @{
    text = "CLAUDE.md 更新完成: $($stats.Updated) 个项目已更新"
} | ConvertTo-Json

Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType 'application/json'
```

---

## 获取帮助

### 查看脚本帮助

```powershell
Get-Help .\regenerate-claude-md.ps1 -Detailed
Get-Help .\batch-regenerate-claude-md.ps1 -Detailed
Get-Help .\setup-scheduled-task.ps1 -Detailed
```

### 查看示例

```powershell
Get-Help .\regenerate-claude-md.ps1 -Examples
```

### 常见问题

参考 `README-regenerate-claude-md.md` 中的"常见问题"章节。

---

## 下一步

1. ✅ 完成快速测试
2. ✅ 配置批量更新
3. ✅ 设置定时任务
4. ✅ 集成到工作流

现在你已经准备好自动化维护 CLAUDE.md 了! 🎉
