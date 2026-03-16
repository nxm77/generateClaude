# 智能文档生成脚本使用指南

## 📖 概述

`generate-docs-smart.sh` 是一个智能的项目文档生成工具，能够自动分析任何软件项目并生成定制化的文档。

### 与旧版本的区别

| 特性 | 旧版 `generate-docs.sh` | 新版 `generate-docs-smart.sh` |
|------|------------------------|------------------------------|
| 项目分析 | ❌ 无 | ✅ 自动分析项目结构 |
| 语言检测 | ❌ 固定模板 | ✅ 检测多种编程语言 |
| 框架识别 | ❌ 固定模板 | ✅ 识别主流框架 |
| 文档定制 | ❌ 通用内容 | ✅ 根据项目类型定制 |
| 目录扫描 | ❌ 假设的结构 | ✅ 扫描实际目录 |
| 图表生成 | ❌ 固定流程 | ✅ 根据架构生成 |
| 适用范围 | ⚠️ 仅特定项目 | ✅ 任何软件项目 |

## 🚀 快速开始

### 1. 在当前目录生成文档

```bash
./generate-docs-smart.sh
```

### 2. 为指定项目生成文档

```bash
./generate-docs-smart.sh /path/to/your/project
```

## 🔍 智能分析功能

脚本会自动检测以下内容：

### 编程语言
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

### 项目类型
- 全栈 Web 应用
- 前端应用
- 后端服务
- API 服务
- 桌面应用
- 移动应用
- Python 脚本/工具
- 通用软件项目

## 📄 生成的文档

脚本会生成以下 5 个文档：

### 1. `CLAUDE.md` - 项目文档索引
- 项目概览信息
- 技术栈总结
- 文档导航
- 使用说明

### 2. `requirements-analysis.md` - 需求分析文档
- 项目背景和目标
- 功能需求（根据项目类型定制）
- 非功能需求
- 约束条件和验收标准

### 3. `file-functions.md` - 文件功能列表
- 实际的项目目录结构
- 主要配置文件说明
- 源代码组织
- 文件命名规范

### 4. `system-overview.puml` - 系统架构图
根据项目类型生成不同的架构图：
- 全栈应用：前端层 + 后端层 + 数据层
- API 服务：API 层 + 服务层 + 数据层
- 前端应用：展示层 + 逻辑层 + 服务层
- 其他：核心模块 + 支持模块

### 5. `module-flowchart.puml` - 业务流程图
根据项目类型生成不同的流程：
- API 服务：请求处理流程
- 前端应用：用户交互流程
- 其他：核心业务流程

### 6. `sequence-diagram.puml` - 时序图
根据项目类型生成不同的交互时序：
- 全栈应用：前后端完整交互
- API 服务：API 调用流程
- 前端应用：组件交互流程
- 其他：系统交互流程

## 📊 查看 PlantUML 图表

### 方法一：VS Code（推荐）

1. 安装 VS Code 扩展：`PlantUML`
2. 打开 `.puml` 文件
3. 按 `Alt + D` 预览图表

### 方法二：在线预览

1. 访问 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)
2. 复制 `.puml` 文件内容
3. 粘贴到编辑器中查看

### 方法三：导出图片

```bash
# 安装 PlantUML
npm install -g node-plantuml

# 导出为 PNG
puml generate system-overview.puml -o system-overview.png

# 导出为 SVG
puml generate system-overview.puml -o system-overview.svg
```

## 🎯 使用场景

### 场景 1：新项目启动
为新项目快速生成初始文档框架，便于团队理解项目结构。

```bash
cd my-new-project
/path/to/generate-docs-smart.sh
```

### 场景 2：现有项目补充文档
为缺少文档的现有项目生成完整文档。

```bash
/path/to/generate-docs-smart.sh /path/to/existing-project
```

### 场景 3：多项目批量生成
为多个项目批量生成文档。

```bash
for project in project1 project2 project3; do
    /path/to/generate-docs-smart.sh /path/to/$project
done
```

### 场景 4：CI/CD 集成
在持续集成流程中自动生成和更新文档。

```yaml
# .github/workflows/docs.yml
name: Generate Docs
on: [push]
jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Generate Documentation
        run: ./generate-docs-smart.sh
      - name: Commit Documentation
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add *.md *.puml
          git commit -m "docs: auto-generate documentation" || true
          git push
```

## 🔧 自定义和扩展

### 添加新的语言检测

编辑脚本中的 `analyze_languages()` 函数：

```bash
# 添加 Kotlin 检测
if [ -f "build.gradle.kts" ] || find . -maxdepth 3 -name "*.kt" 2>/dev/null | grep -q .; then
    langs+=("Kotlin")
fi
```

### 添加新的框架检测

编辑脚本中的 `analyze_tech_stack()` 函数：

```bash
# 添加 Laravel 检测
if [ -f "composer.json" ]; then
    if grep -q "laravel" composer.json; then
        frameworks+=("Laravel")
        HAS_BACKEND=true
        HAS_API=true
    fi
fi
```

### 自定义文档模板

修改 `generate_requirements_doc()`、`generate_file_functions_doc()` 等函数中的文档内容。

## 📝 输出示例

### 分析报告示例

```
========================================
项目分析报告
========================================
项目名称: my-awesome-app
项目类型: 全栈 Web 应用
编程语言: JavaScript/TypeScript
框架: React, Express
数据库: PostgreSQL, Redis
包含前端: true
包含后端: true
包含 API: true
包含测试: true

主要文件:
  - package.json
  - tsconfig.json
  - .env.example
  - README.md
```

### 生成统计示例

```
========================================
文档生成完成统计
========================================

项目信息：
  项目名称: my-awesome-app
  项目类型: 全栈 Web 应用
  编程语言: JavaScript/TypeScript
  框架: React, Express
  数据库: PostgreSQL, Redis

生成的文档列表：
  1. CLAUDE.md                    156 行
  2. requirements-analysis.md     203 行
  3. file-functions.md            178 行
  4. system-overview.puml         65 行
  5. module-flowchart.puml        89 行
  6. sequence-diagram.puml        72 行

文档存储位置：
  /path/to/my-awesome-app

下一步操作建议：
  1. 使用 VS Code 打开项目目录查看文档
  2. 安装 PlantUML 插件预览图表
  3. 根据实际项目情况调整文档内容
  4. 将文档纳入版本控制
```

## ⚠️ 注意事项

### 1. 依赖工具

脚本使用以下工具（可选）：
- `tree`：生成更美观的目录树（如果未安装会使用 `find` 替代）
- `wc`：统计文档行数

### 2. 目录排除

脚本会自动排除以下目录：
- `node_modules`
- `__pycache__`
- `.git`
- `dist`
- `build`
- `target`
- `venv`/`env`/`.venv`

### 3. 文件覆盖

脚本会覆盖已存在的文档文件，建议：
- 首次运行前备份现有文档
- 或使用版本控制系统

### 4. 手动调整

生成的文档是基于项目结构的智能推断，建议：
- 检查并调整文档内容
- 补充项目特定的细节
- 更新业务逻辑描述

## 🆚 对比测试

### 测试项目 1：React + Express 全栈应用

**旧版输出**：
- 生成通用的用户管理系统文档
- 假设的目录结构
- 固定的登录流程图

**新版输出**：
- 识别为"全栈 Web 应用"
- 扫描实际的 `src/` 目录结构
- 生成前后端分离的架构图
- 包含 React 状态管理和 Express API 的时序图

### 测试项目 2：Python FastAPI 服务

**旧版输出**：
- 仍然生成 Node.js 相关文档
- 不适用的技术栈描述

**新版输出**：
- 识别为"API 服务"
- 检测到 Python + FastAPI
- 生成 API 请求处理流程图
- 包含 Python 特定的文件命名规范

### 测试项目 3：Vue 前端应用

**旧版输出**：
- 包含不相关的后端内容
- 数据库相关的无用描述

**新版输出**：
- 识别为"前端应用"
- 只生成前端相关的文档
- 用户交互流程图
- 组件交互时序图

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个脚本！

### 改进建议
- 添加更多语言和框架的检测
- 支持更多项目类型
- 优化文档模板
- 添加更多图表类型

## 📄 许可证

MIT License

---

*最后更新：2026-03-17*
