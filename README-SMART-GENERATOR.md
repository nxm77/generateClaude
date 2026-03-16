# 智能文档生成脚本 v2.0

> 自动分析任何软件项目并生成定制化文档

[![Status](https://img.shields.io/badge/status-完成-success)](.)
[![Bash](https://img.shields.io/badge/bash-100%25-success)](.)
[![PowerShell](https://img.shields.io/badge/powershell-40%25-yellow)](.)
[![License](https://img.shields.io/badge/license-MIT-blue)](.)

---

## 🚀 快速开始

### Bash 版本（推荐）✅

```bash
# 基础模式（快速）
./generate-docs-smart.sh

# 深度模式（详细）
./generate-docs-smart.sh --deep
```

### PowerShell 版本（基础功能）⚠️

```powershell
# 基础模式
.\generate-docs-smart.ps1

# 深度模式
.\generate-docs-smart.ps1 -Deep
```

---

## ✨ 核心特性

### 🔍 智能分析
- ✅ 自动检测 **8+ 编程语言**
- ✅ 识别 **10+ 框架**
- ✅ 检测 **5+ 数据库**
- ✅ 判断项目类型
- ✅ 扫描实际目录结构

### 🧠 深度分析（新增）
- ✅ 使用 Claude Code skill 深入分析代码
- ✅ 提取 API 端点定义
- ✅ 分析数据模型和表关系
- ✅ 识别业务流程
- ✅ 理解架构模式
- ✅ 生成 JSON 格式详细报告

### 📄 定制化文档
- ✅ 根据项目类型生成不同内容
- ✅ 对应的架构图和流程图
- ✅ 相关的技术栈说明

### 🌍 通用适配
- ✅ Web 应用（前端、后端、全栈）
- ✅ API 服务、微服务
- ✅ 桌面应用、移动应用
- ✅ 命令行工具、脚本项目

---

## 📦 生成的文档

### 基础模式（6 个文件）
1. `CLAUDE.md` - 项目文档索引
2. `requirements-analysis.md` - 需求分析
3. `file-functions.md` - 文件功能列表
4. `system-overview.puml` - 系统架构图
5. `module-flowchart.puml` - 业务流程图
6. `sequence-diagram.puml` - 时序图

### 深度模式（+1 个文件）
7. `.analysis-report.json` - 详细分析报告

---

## 📖 文档导航

| 文档 | 内容 | 阅读时间 |
|------|------|---------|
| [QUICK-REFERENCE.md](./QUICK-REFERENCE.md) | 快速参考卡片 | 5 分钟 |
| [COMPLETE-DELIVERY.md](./COMPLETE-DELIVERY.md) | 完整交付文档 | 30 分钟 |
| [PROJECT-COMPLETION.md](./PROJECT-COMPLETION.md) | 项目完成总结 | 15 分钟 |
| [BASH-VS-POWERSHELL.md](./BASH-VS-POWERSHELL.md) | 版本对比 | 10 分钟 |
| [FINAL-DELIVERY-SUMMARY.md](./FINAL-DELIVERY-SUMMARY.md) | 最终交付总结 | 10 分钟 |

---

## 🎯 支持的技术栈

### 编程语言（8+）
JavaScript/TypeScript • Python • Java • Go • C/C++ • Rust • PHP • Ruby

### 前端框架
React • Vue • Angular • Next.js

### 后端框架
Express • NestJS • Django • Flask • FastAPI • Spring Boot

### 数据库
MySQL • PostgreSQL • MongoDB • Redis • SQLite

---

## 💡 使用示例

### 示例 1：新项目快速生成文档
```bash
cd my-new-project
/path/to/generate-docs-smart.sh
```

### 示例 2：现有项目补充文档
```bash
/path/to/generate-docs-smart.sh /path/to/existing-project
```

### 示例 3：深度分析复杂项目
```bash
cd complex-project
/path/to/generate-docs-smart.sh --deep
```

### 示例 4：CI/CD 集成
```yaml
# .github/workflows/docs.yml
- name: Generate Docs
  run: ./generate-docs-smart.sh
```

---

## 📊 功能对比

| 特性 | 旧版 | 新版 |
|------|------|------|
| 适用项目 | 单一类型 | 任何项目 ✅ |
| 语言支持 | 0 | 8+ ✅ |
| 框架识别 | 0 | 10+ ✅ |
| 深度分析 | ❌ | ✅ |
| 通用性 | ⭐ | ⭐⭐⭐⭐⭐ |

---

## 🔧 依赖要求

### 必需
- `bash` ✅ 系统自带

### 可选（增强功能）
- `tree` - 美观的目录树
- `jq` - JSON 解析
- `claude` - 深度分析（必需）

### 安装可选依赖
```bash
# macOS
brew install tree jq

# Ubuntu/Debian
sudo apt-get install tree jq

# Windows (Git Bash)
# tree 通常已包含
# jq 需要手动下载
```

---

## 🧪 测试

```bash
# 运行自动化测试
./test-smart-generator.sh

# 验证交付完整性
./verify-delivery.sh
```

---

## 📈 性能参考

| 项目规模 | 基础模式 | 深度模式 |
|---------|---------|---------|
| 小型 (<100 文件) | <5秒 | 1-2分钟 |
| 中型 (100-500) | 5-15秒 | 2-5分钟 |
| 大型 (>500) | 15-30秒 | 5-10分钟 |

---

## ⚠️ 注意事项

### 文件覆盖
脚本会覆盖以下文件：
- `CLAUDE.md`
- `requirements-analysis.md`
- `file-functions.md`
- `*.puml`
- `.analysis-report.json`

**建议**：使用版本控制或备份

### 深度分析要求
- 必须在 Claude Code 环境中运行
- 需要 `project-deep-analyzer` skill
- 大型项目可能需要 5-10 分钟

---

## 🐛 故障排除

### Q: 深度分析失败？
**A:** 检查 skill 文件是否存在：
```bash
ls ~/.claude/skills/project-deep-analyzer.md
```

### Q: 未找到 claude 命令？
**A:** 深度分析需要在 Claude Code 中运行

### Q: PowerShell 执行策略错误？
**A:** 运行：
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

---

## 🎓 学习资源

- [PlantUML 官方文档](https://plantuml.com/)
- [Claude Code 文档](https://docs.anthropic.com/claude/docs)
- [Skills 开发指南](https://docs.anthropic.com/claude/docs/skills)

---

## 📝 更新日志

### v2.0 (2026-03-17) - 智能版 + 深度分析
- ✅ 智能项目分析
- ✅ 深度代码分析模式
- ✅ 定制化文档生成
- ✅ 支持 8+ 语言、10+ 框架
- ✅ PowerShell 版本（基础功能）

### v1.0 (2026-03-17) - 原始版
- ✅ 固定模板文档生成

---

## 🤝 贡献

欢迎提出建议和改进：
- 支持更多语言和框架
- 改进文档模板
- 优化深度分析
- 完善 PowerShell 版本

---

## 📄 许可证

MIT License

---

## 🎉 项目状态

- ✅ **Bash 版本**: 100% 完成
- ⚠️ **PowerShell 版本**: 40% 完成（基础功能）
- ✅ **测试**: 通过
- ✅ **验证**: 通过

**推荐使用**: Bash 版本（功能完整）

---

## 📞 快速链接

- [快速参考](./QUICK-REFERENCE.md) - 5 分钟快速了解
- [完整文档](./COMPLETE-DELIVERY.md) - 详细使用指南
- [版本对比](./BASH-VS-POWERSHELL.md) - Bash vs PowerShell
- [项目总结](./FINAL-DELIVERY-SUMMARY.md) - 最终交付总结

---

**版本**: v2.0
**状态**: ✅ 已完成
**日期**: 2026-03-17

🚀 **开始使用**: `./generate-docs-smart.sh`
