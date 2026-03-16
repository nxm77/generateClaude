# CLAUDE.md 自动化工具套件

完整的 CLAUDE.md 生成和维护解决方案,基于 2026 年最佳实践。

## 📦 文件清单

```
D:\cx\
├─ regenerate-claude-md.ps1           # 核心脚本 - 单项目 CLAUDE.md 生成
├─ batch-regenerate-claude-md.ps1     # 批量脚本 - 多项目批量处理
├─ setup-scheduled-task.ps1           # 定时任务设置脚本
├─ repos-config.example.json          # 配置文件模板
├─ README-regenerate-claude-md.md     # 完整文档
├─ QUICKSTART.md                      # 快速开始指南
└─ 本文件.md                          # 总结文档
```

## 🚀 三种使用模式

### 模式 1: 单项目模式 (适合手动操作)

**使用场景**: 为单个项目生成或更新 CLAUDE.md

```powershell
# 基本使用
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"

# 预览模式 (不修改文件)
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun

# 详细日志
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -Verbose
```

**输出**:
- `output/CLAUDE.md.new` - 新生成的文件
- `output/CLAUDE.md.old` - 原文件备份
- `output/changes-report.md` - 详细变更报告

---

### 模式 2: 批量模式 (适合多项目管理)

**使用场景**: 一次性处理多个项目

**步骤 1: 创建配置文件**

```powershell
# 复制模板
Copy-Item repos-config.example.json repos-config.json

# 编辑配置
notepad repos-config.json
```

**配置示例**:
```json
{
  "repositories": [
    {
      "name": "frontend-app",
      "path": "D:\\projects\\frontend-app",
      "enabled": true
    },
    {
      "name": "backend-api",
      "path": "D:\\projects\\backend-api",
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

**步骤 2: 运行批量更新**

```powershell
# 预览模式
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -DryRun

# 正式运行
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json

# 自动提交到 Git
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -AutoCommit
```

**输出**:
- `batch-output/batch-summary-*.md` - 汇总报告
- `batch-output/[project-name]/` - 每个项目的详细输出

---

### 模式 3: 定时任务模式 (适合自动化)

**使用场景**: 凌晨自动运行,无需人工干预

**设置定时任务**:

```powershell
# 设置每天凌晨 2 点运行
.\setup-scheduled-task.ps1 `
    -ScriptPath "D:\cx\batch-regenerate-claude-md.ps1" `
    -ConfigPath "D:\cx\repos-config.json" `
    -Time "02:00" `
    -AutoCommit

# 立即测试
Start-ScheduledTask -TaskName "Claude-MD-Auto-Update"

# 查看任务状态
Get-ScheduledTask -TaskName "Claude-MD-Auto-Update"

# 删除任务
.\setup-scheduled-task.ps1 -Remove
```

---

## 🎯 核心特性

### ✅ 智能检测

- **多技术栈支持**: TypeScript, Python, Java, C++, C#, VB.NET
- **自动提取信息**: 项目描述、关键命令、目录结构
- **智能分析**: 从 README.md, package.json 等文件提取信息

### ✅ 最佳实践遵循

- **长度控制**: 目标 40-80 行,上限 200 行
- **内容精简**: 只包含 Claude 需要的核心信息
- **避免冗余**: 不包含 Claude 可以推断的信息

### ✅ 安全机制

- **自动备份**: 修改前自动备份原文件
- **预览模式**: DryRun 模式先预览再应用
- **详细报告**: 完整的变更对比和统计

### ✅ 企业级功能

- **批量处理**: 一次处理多个项目
- **Git 集成**: 自动提交和推送
- **定时任务**: Windows Task Scheduler 集成
- **详细日志**: 完整的执行报告

---

## 📊 工作流程图

```
┌─────────────────────────────────────────────────────────┐
│                    单项目模式                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  用户运行脚本                                            │
│       ↓                                                 │
│  检测技术栈 (package.json, pom.xml, etc.)               │
│       ↓                                                 │
│  提取项目信息 (描述、命令、结构)                          │
│       ↓                                                 │
│  调用 Claude CLI 生成新 CLAUDE.md                        │
│       ↓                                                 │
│  验证长度 (40-80 行理想)                                 │
│       ↓                                                 │
│  对比新旧版本 (git diff)                                 │
│       ↓                                                 │
│  生成变更报告                                            │
│       ↓                                                 │
│  用户确认后应用                                          │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    批量模式                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  读取配置文件 (repos-config.json)                        │
│       ↓                                                 │
│  遍历所有启用的项目                                       │
│       ↓                                                 │
│  对每个项目:                                             │
│    ├─ 调用单项目脚本                                     │
│    ├─ 收集结果                                          │
│    └─ 可选: 自动提交到 Git                               │
│       ↓                                                 │
│  生成汇总报告                                            │
│       ↓                                                 │
│  统计: 成功/失败/更新/无变化                              │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  定时任务模式                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Windows Task Scheduler                                 │
│       ↓                                                 │
│  每天凌晨 2:00 触发                                      │
│       ↓                                                 │
│  运行批量脚本                                            │
│       ↓                                                 │
│  自动提交更新                                            │
│       ↓                                                 │
│  生成报告 (可选: 发送通知)                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎓 使用建议

### 第一次使用

1. **从单个项目开始**
   ```powershell
   .\regenerate-claude-md.ps1 -ProjectPath "D:\projects\test-app" -DryRun
   ```

2. **查看生成结果**
   ```powershell
   notepad .\output\CLAUDE.md.new
   notepad .\output\changes-report.md
   ```

3. **如果满意,正式应用**
   ```powershell
   .\regenerate-claude-md.ps1 -ProjectPath "D:\projects\test-app"
   ```

4. **测试 Claude 是否能正常读取**
   ```powershell
   cd D:\projects\test-app
   claude
   # Claude 会自动读取 CLAUDE.md
   ```

### 日常使用

**每周例行更新**:
```powershell
# 批量更新所有项目
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json

# 查看汇总报告
notepad .\batch-output\batch-summary-*.md
```

**重构后立即更新**:
```powershell
# 单个项目快速更新
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\refactored-app"
```

**新项目初始化**:
```powershell
# 为新项目生成 CLAUDE.md
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\new-project"
```

### 企业部署

1. **配置所有项目**
   - 编辑 `repos-config.json`
   - 添加所有需要维护的项目

2. **设置定时任务**
   - 凌晨服务器空闲时运行
   - 启用自动提交

3. **配置通知** (可选)
   - 邮件通知
   - Slack 通知

4. **定期审查**
   - 每周查看汇总报告
   - 检查失败的项目
   - 优化配置

---

## 📋 检查清单

### 生成前检查

- [ ] Claude CLI 已安装并配置
- [ ] 项目路径正确
- [ ] 有足够的磁盘空间
- [ ] 网络连接正常 (调用 Claude API)

### 生成后检查

- [ ] 长度在 200 行以内
- [ ] 包含项目一句话描述
- [ ] 包含关键命令 (5-8 个)
- [ ] 包含架构说明
- [ ] 包含验证步骤
- [ ] 没有标准语言约定
- [ ] 没有代码示例 (使用文件引用)
- [ ] 测试 Claude 能正常读取

### 应用前检查

- [ ] 查看了变更报告
- [ ] 理解了所有变更
- [ ] 备份了原文件
- [ ] 在测试项目验证过

---

## 🔧 故障排查

### 常见问题速查

| 问题 | 解决方案 |
|------|---------|
| Claude CLI 未找到 | `npm install -g @anthropic-ai/claude-code` |
| 执行策略错误 | `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` |
| 路径不存在 | 检查路径是否正确,使用引号包裹含空格的路径 |
| 生成内容太长 | 查看报告中的精简建议 |
| Git 操作失败 | 检查 Git 配置和权限 |
| 定时任务不运行 | 检查任务状态和日志 |

详细故障排查参考 `README-regenerate-claude-md.md`。

---

## 📚 文档导航

- **快速开始**: 阅读 `QUICKSTART.md`
- **完整文档**: 阅读 `README-regenerate-claude-md.md`
- **配置示例**: 查看 `repos-config.example.json`
- **脚本源码**: 查看 `*.ps1` 文件

---

## 🎉 开始使用

```powershell
# 1. 快速测试
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun

# 2. 查看结果
notepad .\output\changes-report.md

# 3. 正式应用
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"

# 4. 测试 Claude
cd D:\projects\my-app
claude
```

---

## 📞 获取帮助

```powershell
# 查看脚本帮助
Get-Help .\regenerate-claude-md.ps1 -Detailed
Get-Help .\batch-regenerate-claude-md.ps1 -Detailed

# 查看示例
Get-Help .\regenerate-claude-md.ps1 -Examples
```

---

## 🌟 核心价值

```
传统方式:
  /init 生成 → 静态快照 → 逐渐过时 → 手动维护

自动化方式:
  定期运行 → 动态更新 → 始终准确 → 零维护成本

  + 遵循 2026 最佳实践 (40-80 行)
  + 多技术栈支持
  + 企业级批量处理
  + 完整的审计日志
```

---

**现在你已经拥有完整的 CLAUDE.md 自动化解决方案!** 🚀

从单个项目测试开始,逐步扩展到批量处理和定时任务。
