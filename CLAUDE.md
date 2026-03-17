# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

CLAUDE.md 自动化维护工具 - 基于 2026 年最佳实践的企业级 CLAUDE.md 生成和维护解决方案。支持单项目生成、批量处理和定时任务自动化。

## 核心命令

### 环境检查
```powershell
.\check-environment.ps1
```

### 单项目生成
```powershell
# 预览模式
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun

# 正式生成
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"
```

### 批量处理
```powershell
# 预览批量更新
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -DryRun

# 正式批量更新
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json

# 自动提交到 Git
.\batch-regenerate-claude-md.ps1 -ConfigFile repos-config.json -AutoCommit
```

### 定时任务设置
```powershell
# 设置每天凌晨 2 点自动运行
.\setup-scheduled-task.ps1 -ScriptPath "D:\cx\batch-regenerate-claude-md.ps1" -ConfigPath "D:\cx\repos-config.json" -Time "02:00"

# 测试运行
Start-ScheduledTask -TaskName "Claude-MD-Auto-Update"
```

### 智能文档生成
```powershell
# 基础模式
.\generate-docs-smart.ps1

# 深度分析模式
.\generate-docs-smart.ps1 -Deep

# 指定目录
.\generate-docs-smart.ps1 -Path "C:\path\to\project"
```

## 项目架构

### 核心脚本
- `regenerate-claude-md.ps1` - 单项目 CLAUDE.md 生成引擎
- `batch-regenerate-claude-md.ps1` - 批量处理多个项目
- `generate-docs-smart.ps1` - 智能三阶段文档生成（需求分析、文件功能、PlantUML 图表）
- `setup-scheduled-task.ps1` - Windows 定时任务配置
- `check-environment.ps1` - 环境依赖检查

### 配置文件
- `repos-config.json` - 批量处理项目配置（基于 repos-config.example.json）
- `openspec/config.yaml` - OpenSpec 工作流配置

### 输出目录
- `output/` - 单项目生成结果
- `batch-output/` - 批量处理结果和汇总报告

## 技术栈支持

自动检测并支持以下技术栈：
- TypeScript/Node.js (package.json)
- Python (requirements.txt, pyproject.toml)
- Java (pom.xml, build.gradle)
- C++ (CMakeLists.txt, Makefile)
- C# (.csproj, .sln)
- VB.NET (.vbproj)

## 代码规范

### CLAUDE.md 生成规范
- **目标长度**: 40-80 行（理想）
- **上限**: 200 行（可接受）
- **超过 300 行**: 必须精简

### 内容原则
- 只包含 Claude 无法推断的信息
- 避免标准语言约定和 Linter 规则
- 使用文件引用代替代码示例
- 关注项目特定的架构和陷阱

### PowerShell 脚本规范
- 使用详细的注释和帮助文档
- 提供 -DryRun 预览模式
- 自动备份原文件
- 生成详细的变更报告

## 验证步骤

### 生成后验证
```powershell
# 检查生成的文件长度
(Get-Content .\output\CLAUDE.md.new).Count

# 查看变更报告
notepad .\output\changes-report.md

# 对比新旧版本
git diff .\output\CLAUDE.md.old .\output\CLAUDE.md.new
```

### 测试 Claude 读取
```powershell
cd D:\projects\target-project
claude
# Claude 会自动读取 CLAUDE.md
```

## 常见陷阱

1. **路径包含空格** - 必须使用引号包裹路径
2. **执行策略限制** - 运行 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`
3. **Claude CLI 未安装** - 运行 `npm install -g @anthropic-ai/claude-code`
4. **配置文件格式错误** - 参考 repos-config.example.json 的 JSON 格式
5. **生成内容过长** - 查看 changes-report.md 中的精简建议

## 参考文档

- [QUICKSTART.md](QUICKSTART.md) - 5 分钟快速上手
- [OVERVIEW.md](OVERVIEW.md) - 工具套件总览
- [README.md](README.md) - 项目主文档
- [INSTALLATION.md](INSTALLATION.md) - 安装指南
