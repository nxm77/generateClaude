# 📖 文档索引

快速找到你需要的信息!

---

## 🚀 我想...

### 快速开始使用

👉 阅读 [QUICKSTART.md](QUICKSTART.md) (5 分钟)

**包含内容**:
- 5 分钟快速上手
- 基本使用示例
- 常见场景演示

---

### 了解如何安装和配置

👉 阅读 [INSTALLATION.md](INSTALLATION.md) (5 分钟)

**包含内容**:
- 3 步快速开始
- 环境要求
- 完整使用流程
- 验收标准

---

### 了解工具的全部功能

👉 阅读 [OVERVIEW.md](OVERVIEW.md) (10 分钟)

**包含内容**:
- 三种使用模式详解
- 核心特性说明
- 工作流程图
- 最佳实践建议

---

### 查看详细的参数和配置

👉 阅读 [README-regenerate-claude-md.md](README-regenerate-claude-md.md) (20 分钟)

**包含内容**:
- 完整功能文档
- 参数详细说明
- 支持的技术栈
- CLAUDE.md 最佳实践
- 进阶用法

---

### 了解项目背景和价值

👉 阅读 [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) (5 分钟)

**包含内容**:
- 项目完成总结
- 核心价值说明
- 技术亮点
- 使用场景

---

### 查看交付清单和验证

👉 阅读 [DELIVERY-CHECKLIST.md](DELIVERY-CHECKLIST.md) (5 分钟)

**包含内容**:
- 已交付文件清单
- 功能完成度
- 质量指标
- 最终检查清单

---

### 了解探索过程

👉 阅读 [EXPLORATION-SUMMARY.md](EXPLORATION-SUMMARY.md) (10 分钟)

**包含内容**:
- 对话回顾
- 探索过程
- 关键转折点
- 探索模式的价值

---

## 🔧 我遇到了问题...

### 环境配置问题

**问题**: Claude CLI 未找到
```powershell
npm install -g @anthropic-ai/claude-code
```

**问题**: 执行策略错误
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

**问题**: 不确定环境是否正确
```powershell
.\check-environment.ps1
```

👉 更多问题查看 [QUICKSTART.md](QUICKSTART.md) 的"故障排查"章节

---

### 使用问题

**问题**: 不知道如何开始
```powershell
# 1. 检查环境
.\check-environment.ps1

# 2. 测试单个项目
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun
```

**问题**: 生成的 CLAUDE.md 太长
👉 查看 `output/changes-report.md` 中的精简建议

**问题**: 批量处理某些项目失败
👉 查看 `batch-output/batch-summary-*.md` 了解失败原因

**问题**: 定时任务不运行
```powershell
# 查看任务状态
Get-ScheduledTask -TaskName "Claude-MD-Auto-Update"

# 查看任务信息
Get-ScheduledTaskInfo -TaskName "Claude-MD-Auto-Update"
```

👉 更多问题查看 [README-regenerate-claude-md.md](README-regenerate-claude-md.md) 的"常见问题"章节

---

## 📋 我想查看...

### 配置文件示例

👉 查看 [repos-config.example.json](repos-config.example.json)

**示例内容**:
```json
{
  "repositories": [
    {
      "name": "project-alpha",
      "path": "D:\\projects\\project-alpha",
      "enabled": true
    }
  ],
  "gitConfig": {
    "user": "Claude Bot",
    "email": "claude-bot@company.com"
  }
}
```

---

### 脚本帮助信息

```powershell
# 查看详细帮助
Get-Help .\regenerate-claude-md.ps1 -Detailed

# 查看示例
Get-Help .\regenerate-claude-md.ps1 -Examples

# 查看参数
Get-Help .\regenerate-claude-md.ps1 -Parameter *
```

---

### 生成的报告

**单项目模式**:
- `output/CLAUDE.md.new` - 新生成的文件
- `output/CLAUDE.md.old` - 原文件备份
- `output/changes-report.md` - 详细变更报告

**批量模式**:
- `batch-output/batch-summary-*.md` - 汇总报告
- `batch-output/[project-name]/changes-report.md` - 各项目详细报告

---

## 🎯 按使用场景查找

### 场景 1: 第一次使用

1. [README.md](README.md) - 了解项目
2. [INSTALLATION.md](INSTALLATION.md) - 安装配置
3. [QUICKSTART.md](QUICKSTART.md) - 快速上手

### 场景 2: 单个项目

1. [QUICKSTART.md](QUICKSTART.md) - 基本使用
2. [README-regenerate-claude-md.md](README-regenerate-claude-md.md) - 详细参数

### 场景 3: 批量处理

1. [OVERVIEW.md](OVERVIEW.md) - 了解批量模式
2. [repos-config.example.json](repos-config.example.json) - 配置示例
3. [README-regenerate-claude-md.md](README-regenerate-claude-md.md) - 批量处理详解

### 场景 4: 定时任务

1. [OVERVIEW.md](OVERVIEW.md) - 了解定时任务模式
2. [INSTALLATION.md](INSTALLATION.md) - 设置步骤
3. [README-regenerate-claude-md.md](README-regenerate-claude-md.md) - 定时任务管理

### 场景 5: 企业部署

1. [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) - 了解价值
2. [OVERVIEW.md](OVERVIEW.md) - 企业级功能
3. [README-regenerate-claude-md.md](README-regenerate-claude-md.md) - 完整配置

---

## 📚 按阅读时间查找

### 5 分钟快速了解

- [README.md](README.md) - 项目概述
- [INSTALLATION.md](INSTALLATION.md) - 快速开始
- [QUICKSTART.md](QUICKSTART.md) - 快速上手
- [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) - 项目总结
- [DELIVERY-CHECKLIST.md](DELIVERY-CHECKLIST.md) - 交付清单

### 10-20 分钟深入了解

- [OVERVIEW.md](OVERVIEW.md) - 工具总览 (10 分钟)
- [EXPLORATION-SUMMARY.md](EXPLORATION-SUMMARY.md) - 探索过程 (10 分钟)
- [README-regenerate-claude-md.md](README-regenerate-claude-md.md) - 完整文档 (20 分钟)

---

## 🗂️ 文件类型索引

### 脚本文件 (.ps1)

- `regenerate-claude-md.ps1` - 单项目生成脚本
- `batch-regenerate-claude-md.ps1` - 批量处理脚本
- `setup-scheduled-task.ps1` - 定时任务设置脚本
- `check-environment.ps1` - 环境检查脚本

### 配置文件 (.json)

- `repos-config.example.json` - 配置文件模板

### 文档文件 (.md)

#### 入门文档
- `README.md` - 项目入口
- `INSTALLATION.md` - 安装指南
- `QUICKSTART.md` - 快速开始

#### 详细文档
- `OVERVIEW.md` - 工具总览
- `README-regenerate-claude-md.md` - 完整文档

#### 总结文档
- `PROJECT-SUMMARY.md` - 项目总结
- `DELIVERY-CHECKLIST.md` - 交付清单
- `EXPLORATION-SUMMARY.md` - 探索总结
- `INDEX.md` - 本文件 (文档索引)

---

## 🔍 按关键词查找

### 关键词: 安装
👉 [INSTALLATION.md](INSTALLATION.md)

### 关键词: 快速开始
👉 [QUICKSTART.md](QUICKSTART.md)

### 关键词: 配置
👉 [repos-config.example.json](repos-config.example.json)
👉 [README-regenerate-claude-md.md](README-regenerate-claude-md.md)

### 关键词: 批量处理
👉 [OVERVIEW.md](OVERVIEW.md) - 模式 2
👉 [README-regenerate-claude-md.md](README-regenerate-claude-md.md)

### 关键词: 定时任务
👉 [OVERVIEW.md](OVERVIEW.md) - 模式 3
👉 [INSTALLATION.md](INSTALLATION.md)

### 关键词: 故障排查
👉 [QUICKSTART.md](QUICKSTART.md)
👉 [README-regenerate-claude-md.md](README-regenerate-claude-md.md)

### 关键词: 最佳实践
👉 [OVERVIEW.md](OVERVIEW.md)
👉 [README-regenerate-claude-md.md](README-regenerate-claude-md.md)

### 关键词: 技术栈
👉 [README-regenerate-claude-md.md](README-regenerate-claude-md.md)

---

## 💡 推荐阅读路径

### 路径 1: 快速上手 (15 分钟)

1. [README.md](README.md) (5 分钟)
2. [INSTALLATION.md](INSTALLATION.md) (5 分钟)
3. [QUICKSTART.md](QUICKSTART.md) (5 分钟)

### 路径 2: 深入了解 (30 分钟)

1. [README.md](README.md) (5 分钟)
2. [INSTALLATION.md](INSTALLATION.md) (5 分钟)
3. [OVERVIEW.md](OVERVIEW.md) (10 分钟)
4. [README-regenerate-claude-md.md](README-regenerate-claude-md.md) (20 分钟)

### 路径 3: 完整学习 (60 分钟)

1. [README.md](README.md) (5 分钟)
2. [INSTALLATION.md](INSTALLATION.md) (5 分钟)
3. [QUICKSTART.md](QUICKSTART.md) (5 分钟)
4. [OVERVIEW.md](OVERVIEW.md) (10 分钟)
5. [README-regenerate-claude-md.md](README-regenerate-claude-md.md) (20 分钟)
6. [PROJECT-SUMMARY.md](PROJECT-SUMMARY.md) (5 分钟)
7. [EXPLORATION-SUMMARY.md](EXPLORATION-SUMMARY.md) (10 分钟)

---

## 🎯 快速命令参考

```powershell
# 环境检查
.\check-environment.ps1

# 单项目生成 (预览)
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun

# 单项目生成 (正式)
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"

# 批量处理 (预览)
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -DryRun

# 批量处理 (正式)
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json

# 批量处理 (自动提交)
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -AutoCommit

# 设置定时任务
.\setup-scheduled-task.ps1 -Time "02:00"

# 删除定时任务
.\setup-scheduled-task.ps1 -Remove

# 查看帮助
Get-Help .\regenerate-claude-md.ps1 -Detailed
```

---

**找不到你需要的信息?**

1. 使用 Ctrl+F 在本页面搜索关键词
2. 查看 [README.md](README.md) 的"获取帮助"章节
3. 阅读 [QUICKSTART.md](QUICKSTART.md) 的"故障排查"章节

---

最后更新: 2026-03-15
