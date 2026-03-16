# 智能文档生成脚本 - 快速参考

## 🚀 快速命令

```bash
# 基础模式（快速）
./generate-docs-smart.sh

# 深度分析模式（详细）
./generate-docs-smart.sh --deep

# 指定项目目录
./generate-docs-smart.sh /path/to/project

# 深度分析指定项目
./generate-docs-smart.sh --deep /path/to/project

# 运行测试
./test-smart-generator.sh
```

## 📊 两种模式对比

| 特性 | 基础模式 | 深度模式 |
|------|---------|---------|
| 速度 | ⚡ 秒级 | 🐢 分钟级 |
| 依赖 | ✅ 无需额外工具 | ⚠️ 需要 Claude Code |
| API 提取 | ❌ | ✅ |
| 数据模型 | ❌ | ✅ |
| 业务流程 | ❌ | ✅ |
| 适用场景 | 快速了解项目 | 详细文档和分析 |

## 📄 生成的文件

### 基础模式（6个文件）
1. `CLAUDE.md` - 项目文档索引
2. `requirements-analysis.md` - 需求分析
3. `file-functions.md` - 文件功能列表
4. `system-overview.puml` - 系统架构图
5. `module-flowchart.puml` - 业务流程图
6. `sequence-diagram.puml` - 时序图

### 深度模式（+1个文件）
7. `.analysis-report.json` - 详细分析报告

## 🎯 支持的技术栈

### 编程语言（8+）
- JavaScript/TypeScript
- Python
- Java
- Go
- C/C++
- Rust
- PHP
- Ruby

### 前端框架
- React
- Vue
- Angular
- Next.js

### 后端框架
- Express (Node.js)
- NestJS (Node.js)
- Django (Python)
- Flask (Python)
- FastAPI (Python)
- Spring Boot (Java)

### 数据库
- MySQL
- PostgreSQL
- MongoDB
- Redis
- SQLite

## 🔧 依赖工具

### 必需
- `bash` ✅ 系统自带

### 可选
- `tree` - 美观的目录树
- `jq` - JSON 解析
- `claude` - 深度分析（必需）

### 安装可选依赖
```bash
# macOS
brew install tree jq

# Ubuntu/Debian
sudo apt-get install tree jq
```

## 📖 使用场景

### 场景 1：新项目
```bash
cd my-new-project
./generate-docs-smart.sh
```

### 场景 2：现有项目
```bash
./generate-docs-smart.sh /path/to/existing-project
```

### 场景 3：详细分析
```bash
cd complex-project
./generate-docs-smart.sh --deep
```

### 场景 4：CI/CD
```yaml
- name: Generate Docs
  run: ./generate-docs-smart.sh
```

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

### 排除目录
自动排除：
- `node_modules`
- `__pycache__`
- `.git`
- `dist`, `build`, `target`
- `venv`, `env`, `.venv`

## 🐛 常见问题

### Q1: 深度分析失败？
**A:** 检查 skill 文件是否存在：
```bash
ls ~/.claude/skills/project-deep-analyzer.md
```

### Q2: 未找到 claude 命令？
**A:** 深度分析需要在 Claude Code 中运行：
```bash
claude
> !bash ./generate-docs-smart.sh --deep
```

### Q3: 无法解析 JSON？
**A:** 安装 jq：
```bash
brew install jq  # macOS
sudo apt-get install jq  # Ubuntu
```

## 📈 性能参考

| 项目规模 | 基础模式 | 深度模式 |
|---------|---------|---------|
| 小型 (<100 文件) | <5秒 | 1-2分钟 |
| 中型 (100-500) | 5-15秒 | 2-5分钟 |
| 大型 (>500) | 15-30秒 | 5-10分钟 |

## 🎓 查看文档

```bash
# 查看主文档
cat CLAUDE.md

# 查看分析报告（需要 jq）
cat .analysis-report.json | jq .

# 查看 API 端点
cat .analysis-report.json | jq '.api_endpoints'

# 查看数据模型
cat .analysis-report.json | jq '.data_models'

# 查看业务流程
cat .analysis-report.json | jq '.business_flows'
```

## 🔍 PlantUML 查看

### 方法 1: VS Code
1. 安装 `PlantUML` 插件
2. 打开 `.puml` 文件
3. 按 `Alt + D` 预览

### 方法 2: 在线
访问 http://www.plantuml.com/plantuml/uml/

### 方法 3: 导出图片
```bash
npm install -g node-plantuml
puml generate system-overview.puml -o system-overview.png
```

## 💡 最佳实践

### 推荐工作流
```bash
# 1. 快速了解（基础模式）
./generate-docs-smart.sh

# 2. 查看生成的文档
cat CLAUDE.md

# 3. 如需详细信息（深度模式）
./generate-docs-smart.sh --deep

# 4. 查看分析报告
cat .analysis-report.json | jq .
```

### 定期更新
```bash
# 每周更新文档
./generate-docs-smart.sh

# 重大功能后深度分析
./generate-docs-smart.sh --deep

# 提交到版本控制
git add *.md *.puml .analysis-report.json
git commit -m "docs: update"
```

## 📚 完整文档

详细文档请查看：
- `COMPLETE-DELIVERY.md` - 完整交付文档
- `README-generate-docs.md` - 使用指南
- `SUMMARY-smart-generator.md` - 改造总结

## 🎯 核心优势

1. **智能分析** - 自动识别技术栈
2. **通用适配** - 支持任何软件项目
3. **双模式** - 快速 vs 详细
4. **定制化** - 根据项目生成相关文档
5. **无需 API Key** - 使用 Claude Code 内置能力

---

**版本**: v2.0 | **日期**: 2026-03-17
