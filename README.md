# CX Claude Code 配置

> **版本:** v1.1
> **更新:** 2025-03-23
> **项目类型:** 半导体制造 MES/EAP 系统

---

## 简介

本项目为 CX 半导体制造企业配置的 Claude Code CLI 环境，提供针对 MES (IBM SiView)、EAP (设备自动化)、以及 Web 技术栈的 AI 辅助开发支持。

---

## 快速开始

### 环境要求

- Windows 11 + Git Bash
- Claude Code CLI
- Python 3.x (可选，用于 JSON 验证)

### 目录结构

```
.claude/
├── CLAUDE.md              # 主指导文档
├── settings.json          # 配置文件
├── skills/                # 技术栈技能
│   ├── mes/              # MES 专用
│   ├── eap/              # EAP 专用
│   ├── cpp/              # C++ 通用
│   ├── vbnet/            # VB.NET 通用
│   ├── java/             # JAVA 通用
│   └── vue/              # VUE 通用
├── commands/             # 自定义命令
├── hooks/                # Git Hooks
├── templates/            # 文档模板
├── docs/                 # 文档和知识库
│   └── references/       # 本地技术参考文档 ⭐
└── indexes/              # 文件索引
```

### 核心功能

| 功能 | 说明 |
|------|------|
| 上下文恢复 | 会话开始时自动恢复任务进度 |
| 代码检查 | 提交前自动检查 JSON 语法、大文件、行长度 |
| 测试运行 | 推送前自动运行 Maven/npm/Gradle 测试 |
| 技能指导 | 编码时自动触发 MES/EAP 技术栈指导 |
| 图表生成 | 快速生成 PUML 流程图、时序图等 |
| 知识积累 | 记录和复用编码经验 |

---

## 常用命令

| 命令 | 功能 |
|------|------|
| `/init` | 初始化项目 CLAUDE.md |
| `/update-claude` | 更新 CLAUDE.md |
| `/create-skill` | 生成项目 Skill |
| `/learn` | 记录编码经验 |
| `/review` | 代码审查 |
| `/diagram` | 生成 PUML 图表 |

详细说明参见 [使用手册.md](./使用手册.md)

---

## 技术栈支持

### MES (IBM SiView)

- **语言:** C++
- **规模:** 数百万行
- **支持:** 编码规范、代码模式、调试指南

### EAP (设备自动化)

- **语言:** VB.NET
- **规模:** 上百项目
- **协议:** SECS/GEM
- **支持:** 编码规范、通信模式、协议参考

### Web (JAVA + VUE)

- **后端:** Spring Boot 3.x, Java 17
- **前端:** Vue 2/3
- **支持:** RESTful API、组件规范

---

## 文档索引

| 文档 | 路径 | 说明 |
|------|------|------|
| 主文档 | `.claude/CLAUDE.md` | 完整使用指南 |
| 使用手册 | `使用手册.md` | 详细操作手册 |
| 设计文档 | `.claude/docs/design/` | 架构设计 |
| 技术知识库 | `.claude/docs/knowledge/` | MES/EAP 技术知识 |
| 命令文档 | `.claude/docs/command-docs/` | 命令参考 |
| **本地参考** | `.claude/docs/references/` | **技术栈离线文档** ⭐ |
| 文件索引 | `.claude/indexes/` | 代码文件索引 |

### 本地参考文档 (离线可用)

| 文件 | 技术栈 | 内容 |
|------|--------|------|
| vue3-reference.md | Vue 3 | Composition API、响应式、生命周期 |
| vue2-reference.md | Vue 2 | Options API、Vuex、Vue Router |
| cpp-core-guidelines.md | C++ | 智能指针、RAII、内存管理 |
| csharp-reference.md | C# | async/await、LINQ、依赖注入 |
| python-reference.md | Python | PEP 8、类型注解、asyncio |
| spring-boot-reference.md | Java | Spring Boot、RESTful API |
| dotnet-coding-standards.md | VB.NET/.NET | Option Strict、命名约定 |

---

## 工作流推荐

### 新功能开发

```
需求分析 → @brainstorming → @planning → @tdd → @review → 完成
```

### Bug 修复

```
问题定位 → @systematic-debugging → @tdd → @review → 完成
```

### 文档生成

```
/diagram → 下载 PUML 到本地查看
```

---

## 配置说明

### Git Hooks

自动触发的工作流：

| Hook | 触发时机 | 功能 |
|------|---------|------|
| session-start | 会话开始 | 恢复上下文 |
| pre-commit | git commit | 代码检查 |
| pre-push | git push | 运行测试 |

### 技能触发

Claude Code 会根据当前代码自动触发相关技能：

- 编辑 `.cpp` 文件 → MES/C++ 技能
- 编辑 `.vb` 文件 → EAP/VB.NET 技能
- 编辑 `.java` 文件 → JAVA 技能
- 编辑 `.vue` 文件 → VUE 技能

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.1 | 2025-03-23 | 添加本地参考文档 (Vue2/3, C++, C#, Python, Java, VB.NET) |
| v1.0 | 2025-03-22 | 初始版本，完成 Phase 1-3 |

---

## 许可

内部使用 - CX 半导体制造企业

---

## 联系

如有问题，请查看 [使用手册.md](./使用手册.md) 或联系 Claude Code 配置团队。
