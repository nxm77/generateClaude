# CX 半导体制造企业 Claude Code 指导

> **版本:** v1.0
> **更新:** 2025-03-22
> **项目类型:** 半导体制造 MES/EAP 系统

---

## 快速开始

### 核心工作流命令

| 命令 | 功能 | 时机 |
|------|------|------|
| `/init` | 初始化项目 CLAUDE.md | 新项目首次使用 |
| `/update-claude` | 更新 CLAUDE.md | 代码变更后 |
| `/create-skill` | 生成项目 Skill | 深入分析代码 |
| `/learn` | 记录编码经验 | 遇到问题时 |
| `/review` | 代码审查 | 提交前 |
| `/diagram` | 生成 PUML 图表 | 需要文档时 |

### 工作流选择

```
新功能开发 → @brainstorming → @planning → @tdd → @review → 完成
Bug 修复    → @bug → @tdd → @review → 完成
文档生成    → @diagram → 下载 PUML 到本地查看
代码审查    → @review + @security-review
```

---

## 项目环境

### 系统组成

| 系统 | 技术栈 | 代码规模 |
|------|--------|---------|
| **MES** | C++ (SiView) | 数百万行 |
| **EAP** | VB.NET | 上百项目，各 ~10 万行 |
| **新项目** | JAVA + VUE 2/3 | B/S 架构 |
| **其它** | C++, C#, Python, Node.js | 辅助系统 |

### 关键约束

- **局域网环境** - 无互联网访问，PUML 下载到本地查看
- **GitLab** - 代码托管，严格 MR 审查
- **20+ 人团队** - 按业务模块分工
- **SECS/GEM（半导体设备通信标准）协议** - 设备通信标准

---

## 上下文管理策略

### 大型代码库处理

本项目有数百万行代码，必须遵守以下规则：

```bash
# ✅ 正确做法
1. 先查看 .claude/indexes/ 目录下的索引文件
2. 使用 Glob 精确匹配文件
3. 按需读取，单次不超过 10 个文件

# ❌ 错误做法
1. 直接 Grep 搜索整个项目
2. 一次性读取大量文件
3. 不查看索引直接操作
```

### 文件索引

| 索引文件 | 用途 |
|---------|------|
| `.claude/indexes/mes-core.md` | MES 核心模块文件 |
| `.claude/indexes/eap-projects.md` | EAP 项目索引 |
| `.claude/indexes/web-modules.md` | Web 模块索引 |

### 会话恢复

每次启动会话时，自动读取 `task_plan.md`、`findings.md`、`progress.md` 恢复上下文。

---

## SECS/GEM（半导体设备通信标准）协议要点

### 常用消息类型

| 消息 | 功能 |
|------|------|
| S1F13/S1F14 | 建立通信 |
| S1F15/S1F17 | 在线请求/数据 |
| S6F11/S6F12 | 事件报告 |
| S2F41 | Host 命令发送 |
| S5F1 | 警报上报 |

### 通信超时

| 场景 | 超时 | 重试 |
|------|------|------|
| 通信建立 (T1) | 5秒 | 3次 |
| 在线请求 (T2) | 3秒 | 5次 |
| 控制命令 (T3) | 10秒 | - |
| 数据收集 (T4) | 60秒 | - |

---

## 编码规范

### 通用规则

- 单文件不超过 1000 行 (C++/VB.NET) / 500 行 (JAVA) / 300 行 (VUE/Python)
- 函数不超过 100 行
- 圈复杂度不超过 10
- 测试覆盖率目标 > 80%

### MES (C++)

- 使用智能指针管理内存
- RAII 模式管理资源
- 避免裸指针 owning

### EAP (VB.NET)

- Option Strict On
- 遵循匈牙利命名约定
- 避免 On Error Resume Next

### Web (JAVA + VUE)

- JAVA: 遵循 Spring Boot 最佳实践
- VUE: 支持 Vue 2 和 Vue 3
- API RESTful 设计

---

## AI 幻觉防护

### 核心规则

```
操作文件 → Glob 检查存在性 → 确认后操作
使用 API → Grep 搜索代码库 → 参考实际用法
生成代码 → 自审语法规范 → 标记不确定部分
```

### 验证命令

| 命令 | 功能 |
|------|------|
| `/verify code` | 验证代码中的 API |
| `/verify api <name>` | 查证 API 存在性 |
| `/verify path <path>` | 验证文件路径 |

---

## 代码审查流程

### 审查类型

| 类型 | 命令 | 重点 |
|------|------|------|
| 代码审查 | `/review` | 质量、规范、性能 |
| 安全审查 | `/security-review` | 注入、权限、数据安全 |

### 审查检查点

- [ ] 代码符合规范
- [ ] 测试覆盖率 > 80%
- [ ] 文档已同步更新
- [ ] 无高严重性问题

---

## 文档生成

### PUML 图表

由于局域网环境，PUML 文件生成后下载到本地用工具查看。

| 命令 | 功能 |
|------|------|
| `/diagram` | 交互式生成（推荐） |
| `/diagram flow` | 生成流程图 |
| `/diagram sequence` | 生成时序图 |
| `/diagram suggest` | 显示推荐图表 |

### 推荐图表

**MES/EAP 项目:**
- 设备握手流程 (P0)
- 设备登录时序 (P0)
- 设备状态机 (P0)
- 事件报告流程 (P1)

---

## 持续学习

### 双轨制知识积累

| 工具 | 触发方式 | 存储位置 |
|------|---------|---------|
| continuous-learning-v2 | 自动 | `.claude/instincts/` |
| `/learn` | 手动 | `.claude/lessons.md` |

### /learn 类型

- `error` - 编码错误
- `pattern` - 代码模式
- `performance` - 性能优化
- `anti-pattern` - 反模式
- `convention` - 编码规范
- `debug` - 调试经验

---

## 技术栈相关 Skills

### 工作流 Skills

- `superpowers:brainstorming` - 需求探索
- `superpowers:writing-plans` - 计划编写
- `superpowers:test-driven-development` - TDD
- `superpowers:systematic-debugging` - 系统化调试
- `everything-claude-code:code-reviewer` - 代码审查
- `everything-claude-code:security-reviewer` - 安全审查
- `qa-test-planner` - QA 测试计划

### 技术栈 Skills

- `.claude/skills/mes` - MES 专用
- `.claude/skills/eap` - EAP 专用
- `.claude/skills/cpp` - C++
- `.claude/skills/vbnet` - VB.NET
- `.claude/skills/java` - JAVA
- `.claude/skills/vue` - VUE

---

## 常见问题

### Q: 如何处理大型项目？
A: 使用 planning-with-files 的三文件系统 (task_plan.md, findings.md, progress.md) 管理上下文。

### Q: 如何避免 AI 幻觉？
A: 遵循"操作前验证"原则，使用 Glob/Grep 确认文件和 API 存在性。

### Q: PUML 图表如何查看？
A: 生成 .puml 文件后，下载到本地使用 PlantUML 工具渲染。

### Q: 如何创建项目 Skill？
A: 使用 `/create-skill --depth standard` 分析代码生成项目知识库。

---

## 相关文档

- [设计文档](.claude/docs/design/cx-claude-code-configuration-design.md)
- [MES/EAP 技术知识库](.claude/docs/knowledge/mes-eap-technical-knowledge.md)
- [CLAUDE.md 工作流](.claude/docs/claude-md-workflow.md)
- [AI 幻觉防护](.claude/docs/ai-hallucination-prevention.md)
- [代码审查机制](.claude/docs/code-security-review.md)
