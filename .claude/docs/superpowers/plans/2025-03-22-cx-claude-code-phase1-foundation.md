# CX Claude Code 基础配置实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标:** 为半导体制造企业配置 Claude Code CLI 的基础环境，包括目录结构、配置文件、主文档和索引系统

**架构:** 创建分层目录结构，配置 settings.json 启用成熟插件，编写项目级 CLAUDE.md 和技术知识库，建立文件索引系统

**技术栈:** Claude Code CLI, JSON, Markdown, Git

---

## 文件结构

```
D:\cx\
├── .claude\
│   ├── CLAUDE.md                          # 主指导文档
│   ├── settings.json                      # 配置文件
│   ├── templates\                         # 模板集合
│   │   ├── project-claude-md.md           # 项目级 CLAUDE.md 模板
│   │   └── session-planning.md            # 会话规划模板
│   │
│   ├── commands\                          # 自定义命令（占位，下阶段实现）
│   │   └── .gitkeep
│   │
│   └── indexes\                          # 文件索引
│       ├── mes-core.md                    # MES 核心文件索引
│       ├── eap-projects.md                # EAP 项目索引
│       └── web-modules.md                 # Web 模块索引
│
├── docs\
│   ├── design\
│   │   └── cx-claude-code-configuration-design.md  # 设计文档（已存在）
│   │
│   └── knowledge\
│       └── mes-eap-technical-knowledge.md  # MES/EAP 技术知识库
│
├── task_plan.md                          # 主任务计划
├── findings.md                           # 知识库
└── progress.md                           # 进度记录
```

---

## Task 1: 创建 .claude 目录结构

**Files:**
- Create: `D:\cx\.claude\templates\.gitkeep`
- Create: `D:\cx\.claude\commands\.gitkeep`
- Create: `D:\cx\.claude\indexes\.gitkeep`
- Create: `D:\cx\.claude\skills\.gitkeep`
- Create: `D:\cx\.claude\agents\.gitkeep`
- Create: `D:\cx\.claude\hooks\.gitkeep`

- [ ] **Step 1: 创建核心目录**

```bash
mkdir -p D:\cx\.claude\templates
mkdir -p D:\cx\.claude\commands
mkdir -p D:\cx\.claude\indexes
mkdir -p D:\cx\.claude\skills
mkdir -p D:\cx\.claude\agents
mkdir -p D:\cx\.claude\hooks
```

- [ ] **Step 2: 创建占位文件**

```bash
touch D:\cx\.claude\templates\.gitkeep
touch D:\cx\.claude\commands\.gitkeep
touch D:\cx\.claude\indexes\.gitkeep
touch D:\cx\.claude\skills\.gitkeep
touch D:\cx\.claude\agents\.gitkeep
touch D:\cx\.claude\hooks\.gitkeep
```

- [ ] **Step 3: 验证目录结构**

```bash
ls -la D:\cx\.claude\
```

Expected: 显示 templates/, commands/, indexes/, skills/, agents/, hooks/ 目录

- [ ] **Step 4: 提交**

```bash
git add .claude/
git commit -m "feat: create .claude directory structure"
```

---

## Task 2: 创建 settings.json 配置文件

**Files:**
- Create: `D:\cx\.claude\settings.json`

- [ ] **Step 1: 创建 settings.json 文件**

```json
{
  "model": "opus[1m]",
  "language": "中文",
  "effortLevel": "high",

  "enabledPlugins": {
    "planning-with-files@planning-with-files": true,
    "superpowers@superpowers-dev": true,
    "everything-claude-code@everything-claude-code": true,
    "agent-toolkit@agent-toolkit": true,
    "cx-extensions": true
  },

  "context": {
    "maxFilesPerSession": 10,
    "maxFileSizeMB": 1,
    "priorityIndexes": [
      ".claude/indexes/mes-core.md",
      ".claude/indexes/eap-projects.md",
      ".claude/indexes/web-modules.md"
    ],
    "autoCompactThreshold": 180000
  },

  "skills": {
    "workflow": {
      "brainstorming": "superpowers:brainstorming",
      "planning": "planning-with-files",
      "writing-plans": "superpowers:writing-plans",
      "tdd": "superpowers:test-driven-development",
      "debugging": "superpowers:systematic-debugging",
      "code-review": "everything-claude-code:code-reviewer",
      "security-review": "everything-claude-code:security-reviewer",
      "qa-planning": "qa-test-planner"
    },
    "techStack": {
      "mes": ".claude/skills/mes",
      "eap": ".claude/skills/eap",
      "cpp": ".claude/skills/cpp",
      "vbnet": ".claude/skills/vbnet",
      "csharp": ".claude/skills/csharp",
      "java": ".claude/skills/java",
      "vue": ".claude/skills/vue",
      "python": ".claude/skills/python",
      "nodejs": ".claude/skills/nodejs"
    }
  },

  "commands": {
    "/init": ".claude/commands/init.sh",
    "/update-claude": ".claude/commands/update-claude.sh",
    "/create-skill": ".claude/commands/create-skill.sh",
    "/learn": ".claude/commands/learn.sh",
    "/review": "everything-claude-code:code-review",
    "/security-review": "everything-claude-code:security-review",
    "/tdd": "everything-claude-code:tdd",
    "/plan": "everything-claude-code:plan",
    "/bug": "superpowers:systematic-debugging",
    "/qa": "qa-test-planner",
    "/doc": ".claude/commands/doc.sh",
    "/diagram": ".claude/commands/diagram.sh",
    "/context": ".claude/commands/context.sh",
    "/status": ".claude/commands/status.sh"
  },

  "hooks": {
    "session-start": [
      "python ~/.claude/plugins/planning-with-files/*/scripts/session-catchup.py $(pwd)"
    ],
    "pre-commit": {
      "run": [".claude/hooks/pre-commit/run-checks.sh"],
      "timeout": 30000,
      "enabled": true
    },
    "pre-push": {
      "run": [".claude/hooks/pre-push/run-tests.sh"],
      "timeout": 120000,
      "enabled": true
    }
  },

  "documentation": {
    "templates": "docs/diagrams/"
  },

  "gitlab": {
    "enabled": true,
    "url": "https://gitlab.company.com",
    "tokenEnvVar": "GITLAB_TOKEN",
    "defaultBranch": "main",
    "mr": {
      "autoCreate": false,
      "requireApproval": true,
      "labels": {
        "mes": ["MES", "C++"],
        "eap": ["EAP", "VB.NET"],
        "web": ["Web", "JAVA", "VUE"]
      }
    }
  },

  "quality": {
    "testCoverageThreshold": 80,
    "maxFileLines": {
      "cpp": 1000,
      "vbnet": 1000,
      "java": 500,
      "vue": 300,
      "python": 300
    },
    "maxFunctionLines": 100,
    "maxComplexity": 10
  }
}
```

- [ ] **Step 2: 验证 JSON 语法**

```bash
# Windows PowerShell
(Get-Content D:\cx\.claude\settings.json -Raw | ConvertFrom-Json) | Out-Null; echo "JSON valid"

# 或使用 python
python -m json.tool D:\cx\.claude\settings.json > nul && echo "JSON valid"
```

Expected: "JSON valid"

- [ ] **Step 3: 提交**

```bash
git add .claude/settings.json
git commit -m "feat: add Claude Code settings configuration"
```

---

## Task 3: 创建主 CLAUDE.md 文档

**Files:**
- Create: `D:\cx\.claude\CLAUDE.md`

- [ ] **Step 1: 创建 CLAUDE.md 主文档**

```markdown
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
- **SECS/GEM 协议** - 设备通信标准

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

## SECS/GEM 协议要点

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
```

- [ ] **Step 2: 验证文件创建**

```bash
cat D:\cx\.claude\CLAUDE.md | head -20
```

Expected: 显示文档开头内容

- [ ] **Step 3: 提交**

```bash
git add .claude/CLAUDE.md
git commit -m "feat: add main CLAUDE.md documentation"
```

---

## Task 4: 创建项目级 CLAUDE.md 模板

**Files:**
- Create: `D:\cx\.claude\templates\project-claude-md.md`

- [ ] **Step 1: 创建项目级 CLAUDE.md 模板**

```markdown
# {{PROJECT_NAME}} 项目 Claude 配置

> **类型:** {{PROJECT_TYPE}} (MES/EAP/Web/Other)
> **技术栈:** {{TECH_STACK}}
> **更新:** {{UPDATE_DATE}}

---

## 项目概述

{{PROJECT_DESCRIPTION}}

---

## 技术栈

### 编程语言和框架
- {{LANGUAGE_FRAMEWORK}}

### 数据库
- {{DATABASE}}

### 第三方依赖
- {{DEPENDENCIES}}

---

## 代码架构

### 关键文件类型说明

| 文件类型 | 说明 | 位置 |
|---------|------|------|
| {{FILE_TYPE_1}} | {{DESCRIPTION}} | {{LOCATION}} |
| {{FILE_TYPE_2}} | {{DESCRIPTION}} | {{LOCATION}} |

### 关键函数

| 函数/类 | 功能 | 文件 |
|---------|------|------|
| {{FUNCTION_1}} | {{DESCRIPTION}} | {{FILE}} |
| {{FUNCTION_2}} | {{DESCRIPTION}} | {{FILE}} |

### 核心方法

```{{LANGUAGE}}
// TODO: 添加核心方法示例
```

### 数据操作

| 表/实体 | 操作类型 | 说明 |
|---------|---------|------|
| {{TABLE_1}} | CRUD | {{DESCRIPTION}} |

### 数据规则

- {{RULE_1}}
- {{RULE_2}}

---

## 主要业务流程

```
[TODO: 添加业务流程图或描述]

1. {{STEP_1}}
2. {{STEP_2}}
3. {{STEP_3}}
```

---

## 环境变量

| 变量名 | 用途 | 默认值 |
|--------|------|--------|
| {{ENV_VAR_1}} | {{DESCRIPTION}} | {{DEFAULT}} |

---

## 编码规范

### 命名约定

- {{NAMING_CONVENTION}}

### 文件结构

- {{FILE_STRUCTURE_RULE}}

### 注释规范

- {{COMMENT_RULE}}

---

## 业务术语

| 术语 | 说明 |
|------|------|
| {{TERM_1}} | {{DESCRIPTION}} |
| {{TERM_2}} | {{DESCRIPTION}} |

---

## 安全问题

- {{SECURITY_CONSIDER_1}}
- {{SECURITY_CONSIDER_2}}

---

## 项目索引

- 核心文件: {{CORE_FILES_INDEX}}
- 配置文件: {{CONFIG_FILES}}

---

## 相关文档

- [主 CLAUDE.md](.claude/CLAUDE.md)
- [设计文档](docs/design/)
```

- [ ] **Step 2: 验证文件创建**

```bash
ls -la D:\cx\.claude\templates/
```

Expected: 显示 project-claude-md.md

- [ ] **Step 3: 提交**

```bash
git add .claude/templates/
git commit -m "feat: add project-level CLAUDE.md template"
```

---

## Task 5: 创建 planning-with-files 三文件系统

**Files:**
- Create: `D:\cx\task_plan.md`
- Create: `D:\cx\findings.md`
- Create: `D:\cx\progress.md`

- [ ] **Step 1: 创建 task_plan.md**

```markdown
# CX Claude Code 配置任务计划

> **项目:** CX 半导体企业 Claude Code CLI 配置
> **开始日期:** 2025-03-22
> **状态:** 进行中

---

## 阶段概览

| 阶段 | 名称 | 状态 | 完成日期 |
|------|------|------|---------|
| Phase 1 | 基础配置 | 🔄 进行中 | - |
| Phase 2 | Skills 和 Commands | ⏳ 待开始 | - |
| Phase 3 | Hooks 和文档模板 | ⏳ 待开始 | - |

---

## Phase 1: 基础配置

### 目标
- 创建 .claude 目录结构
- 配置 settings.json
- 创建 CLAUDE.md 主文档
- 建立文件索引系统

### 任务清单

- [x] 创建 .claude 目录结构
- [x] 配置 settings.json
- [x] 创建 CLAUDE.md 主文档
- [x] 创建项目级 CLAUDE.md 模板
- [ ] 创建 MES/EAP 技术知识库
- [ ] 创建文件索引

### 完成标准
- [ ] 所有配置文件 JSON 语法正确
- [ ] CLAUDE.md 内容完整且可读
- [ ] 目录结构与设计文档一致

---

## Phase 2: Skills 和 Commands

### 目标
- 创建技术栈 Skills (mes, eap, cpp, vbnet, java, vue)
- 实现自定义 Commands (/init, /update-claude, /create-skill, /learn, /doc, /diagram)

### 任务清单
- [ ] 创建 mes skill
- [ ] 创建 eap skill
- [ ] 创建 cpp/vbnet/java/vue skills
- [ ] 实现 /init 命令
- [ ] 实现 /update-claude 命令
- [ ] 实现 /create-skill 命令
- [ ] 实现 /learn 命令
- [ ] 实现 /doc 命令
- [ ] 实现 /diagram 命令

### 完成标准
- [ ] 每个 Skill 有完整的 SKILL.md
- [ ] 每个 Command 可独立执行
- [ ] 命令有帮助文档

---

## Phase 3: Hooks 和文档模板

### 目标
- 配置 Git Hooks (session-start, pre-commit, pre-push)
- 创建 PUML 图表模板
- 创建文档生成模板

### 任务清单
- [ ] 配置 session-start hook
- [ ] 配置 pre-commit hook
- [ ] 配置 pre-push hook
- [ ] 创建 PUML 模板
- [ ] 创建文档模板

### 完成标准
- [ ] Hooks 自动触发
- [ ] PUML 模板可正常使用
- [ ] 文档生成完整

---

## 风险与问题

| 风险/问题 | 影响 | 状态 | 解决方案 |
|-----------|------|------|---------|
| | | | |

---

## 变更记录

| 日期 | 变更内容 | 作者 |
|------|---------|------|
| 2025-03-22 | 创建任务计划 | Claude |
```

- [ ] **Step 2: 创建 findings.md**

```markdown
# CX Claude Code 配置 - 研究发现

> **项目:** CX 半导体企业 Claude Code CLI 配置
> **更新:** 2025-03-22

---

## 成熟插件调研

### planning-with-files
- **来源:** planning-with-files
- **用途:** 大型项目上下文管理
- **核心:** 三文件系统 (task_plan.md, findings.md, progress.md)
- **结论:** ✅ 采用

### superpowers
- **来源:** superpowers-dev
- **用途:** 工作流方法论
- **核心技能:** brainstorming, writing-plans, tdd, debugging, code-review
- **结论:** ✅ 采用

### everything-claude-code
- **来源:** everything-claude-code
- **用途:** 生产就绪插件集合
- **核心:** code-reviewer, security-reviewer, tdd, plan
- **结论:** ✅ 采用

### qa-test-planner
- **来源:** agent-toolkit
- **用途:** QA 测试计划生成
- **结论:** ✅ 采用

---

## MES/EAP 技术要点

### SECS/GEM 协议

| 消息 | 功能 | 方向 |
|------|------|------|
| S1F13 | Establish Communication | Host → Equipment |
| S1F14 | Establish Communication Ack | Equipment → Host |
| S1F15 | Online Request | Host → Equipment |
| S1F17 | Online Data | Equipment → Host |
| S6F11 | Event Report | Equipment → Host |
| S6F12 | Event Report Ack | Host → Equipment |
| S2F41 | Host Command Send | Host → Equipment |
| S2F42 | Host Command Ack | Equipment → Host |
| S5F1 | Alarm Report | Equipment → Host |
| S5F2 | Alarm Report Ack | Host → Equipment |

### 设备状态机

```
DISABLED → NOT_CONNECTED → COMMUNICATING → ONLINE
                    ↑              ↓
                    └──── ENABLE_CONTROL ──────┘
```

### 通信超时设置

| 场景 | 超时时间 | 重试次数 |
|------|---------|---------|
| 通信建立 (T1) | 5秒 | 3次 |
| 在线请求 (T2) | 3秒 | 5次 |
| 控制命令 (T3) | 10秒 | - |
| 数据收集 (T4) | 60秒 | - |
| 通用处理 (T5) | 10秒 | - |
| 通信流控 (T6) | 3秒 | - |

---

## 环境约束

- **局域网环境** - 无互联网访问
- **PlantUML** - 文件下载到本地用工具查看
- **Git** - 本地 Git 管理，无 MR 集成
- **团队规模** - 20+ 人，按业务模块分工

---

## SiView MES 特点

- tMSP 制造工具控制应用程序
- 事件驱动、面向服务的多线程逻辑引擎
- 插件式业务逻辑支持
- 控制设备与 MES 之间的通信

---

## EAP 系统特点

- 基于 SECS/GEM 协议
- VB.NET 开发
- 上百项目，每个约 10 万行代码
- 设备通信和控制

---

## 待研究事项

- [ ] SiView 具体 API 文档
- [ ] 各设备厂商的 SECS/GEM 实现差异
- [ ] 现有代码库的详细结构分析
```

- [ ] **Step 3: 创建 progress.md**

```markdown
# CX Claude Code 配置 - 进度记录

> **项目:** CX 半导体企业 Claude Code CLI 配置
> **更新:** 2025-03-22

---

## 会话记录

### 2025-03-22 - 会话 1

**时间:** 2025-03-22

**目标:** 创建基础配置实施计划

**完成:**
- [x] 分析设计文档
- [x] 创建基础配置实施计划
- [ ] 执行 Phase 1 任务

**进行中:**
- Phase 1: 基础配置

**待办:**
- Phase 2: Skills 和 Commands
- Phase 3: Hooks 和文档模板

**问题:**
- 无

**下一步:** 执行 Phase 1 任务

---

## 代码变更

### 待提交
- 无

### 已提交
- 无

---

## 文档更新

### 待更新
- MES/EAP 技术知识库详细内容
- 文件索引具体内容

### 已更新
- 设计文档 v1.0

---

## 下次会话

### 恢复上下文检查清单
- [ ] 查看 task_plan.md 当前阶段
- [ ] 查看 findings.md 研究内容
- [ ] 查看 progress.md 上次进度
- [ ] 运行 git diff 查看代码变更

### 下一步行动
1. 执行 Phase 1 剩余任务
2. 创建 MES/EAP 技术知识库
3. 创建文件索引
```

- [ ] **Step 4: 验证文件创建**

```bash
ls -la D:\cx\task_plan.md D:\cx\findings.md D:\cx\progress.md
```

Expected: 三个文件都存在

- [ ] **Step 5: 提交**

```bash
git add task_plan.md findings.md progress.md
git commit -m "feat: add planning-with-files system (task_plan, findings, progress)"
```

---

## Task 6: 创建 MES/EAP 技术知识库

**Files:**
- Create: `D:\cx\.claude\docs\knowledge\mes-eap-technical-knowledge.md`

- [ ] **Step 1: 创建技术知识库目录**

```bash
mkdir -p D:\cx\.claude\docs\knowledge
```

- [ ] **Step 2: 创建 MES/EAP 技术知识库**

```markdown
# MES & EAP 技术知识库

> **适用系统:** SiView MES, EAP (VB.NET)
> **协议标准:** SEMI E4, E5, E30, E37
> **更新:** 2025-03-22

---

## SECS/GEM 协议概述

SECS (SEMI Equipment Communications Standard) 是半导体设备通信标准，GEM (Generic Equipment Model) 定义了设备行为模型。

### 协议层次

```
┌─────────────────────────────────────┐
│         应用层 (GEM)                │  设备状态、事件、报警
├─────────────────────────────────────┤
│         消息层 (SECS-II)            │  S1F13, S6F11 等
├─────────────────────────────────────┤
│         传输层 (HSMS)               │  TCP/IP 连接
└─────────────────────────────────────┘
```

---

## 消息结构

### Primary / Secondary 模式

所有 SECS 消息都是 Primary-Secondary 配对：

```
Host → Equipment: S1F13 (Primary)
Equipment → Host: S1F14 (Secondary)
```

### 消息命名规则

```
S<流号>F<功能号>

例如: S1F13
  S = SECS
  1 = 流 1 (Stream 1)
  F = Function
  13 = 功能 13
```

---

## 常用消息类型

### 流 1: 设备通信

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S1F13 | Establish Communication | H→E | 请求建立通信 |
| S1F14 | Establish Comm Ack | E→H | 通信建立确认 |
| S1F15 | Online Request | H→E | 请求设备在线 |
| S1F17 | Online Data | E→H | 在线数据响应 |

### 流 2: 设备控制

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S2F41 | Host Command Send | H→E | 发送控制命令 |
| S2F42 | Host Command Ack | E→H | 命令执行确认 |
| S2F43 | Host Command Cancel | H→E | 取消控制命令 |

### 流 5: 警报

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S5F1 | Alarm Report Send | E→H | 上报警报 |
| S5F2 | Alarm Report Ack | H→E | 警报确认 |

### 流 6: 数据收集

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S6F11 | Event Report | E→H | 事件报告 |
| S6F12 | Event Report Ack | H→E | 事件确认 |
| S6F15 | Event Report Request | H→E | 请求事件报告 |
| S6F23 | Trace Data Send | E→H | 发送追踪数据 |

### 流 14: 数据获取

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S14F1 | GetAttrReq | H→E | 获取属性请求 |
| S14F2 | GetAttrData | E→H | 属性数据响应 |

---

## 设备状态机

### GEM 控制状态模型

```
                    ┌─────────────────┐
                    │   DISABLED      │
                    │  (禁用控制)      │
                    └────────┬────────┘
                             │ ENABLE
                             ▼
                    ┌─────────────────┐
              ┌─────│ NOT_CONNECTED   │─────┐
              │     │  (未连接)        │     │
              │     └────────┬─────────┘     │
              │              │ COMMUNICATE   │
              │              ▼               │
      ┌───────┴──────┐  ┌─────────────────┐  │
      │ ATTEMPTING   │  │  COMMUNICATING  │  │
      │   (尝试中)    │  │   (通信中)      │  │
      └───────┬──────┘  └────────┬─────────┘  │
              │                    │           │
              │                    │ ESTABLISH │
              │                    ▼           ▼
      ┌───────┴─────────────────────┴────────────┐
      │              ONLINE                       │
      │         (在线，准备执行命令)              │
      └──────────────────────────────────────────┘
                    │
                    │ DISABLE / COMMUNICATIONS
                    │ INITIATE
                    ▼
              ┌─────────┐
              │  HOST   │
              │  OFFLINE│
              └─────────┘
```

### 状态转换说明

| 当前状态 | 目标状态 | 触发条件 |
|---------|---------|---------|
| DISABLED | NOT_CONNECTED | Host 发送 S1F17 (ENABLE) |
| NOT_CONNECTED | ATTEMPTING | Host 尝试建立连接 |
| ATTEMPTING | COMMUNICATING | S1F13/S1F14 握手成功 |
| COMMUNICATING | ONLINE | S1F15/S1F17 在线确认 |
| ONLINE | HOST_OFFLINE | 通信丢失或超时 |
| 任意状态 | DISABLED | Host 发送 S1F17 (DISABLE) |

---

## 通信超时设置

### HSMS 超时参数

| 参数 | 超时时间 | 说明 |
|------|---------|------|
| T1 | 5秒 | 通信建立超时 (S1F13 等待 S1F14) |
| T2 | 3秒 | 在线请求超时 (S1F15 等待 S1F17) |
| T3 | 10秒 | 控制命令超时 (S2F41 等待 S2F42) |
| T4 | 60秒 | 数据收集超时 |
| T5 | 10秒 | 通用处理超时 |
| T6 | 3秒 | 通信流控超时 |
| T7 | 3秒 | 网络连接超时 |
| T8 | 3秒 | 选择超时 |

### 重试策略

| 场景 | 重试次数 | 重试间隔 |
|------|---------|---------|
| 通信建立 (T1) | 3次 | 5秒 |
| 在线请求 (T2) | 5次 | 3秒 |
| 控制命令 (T3) | 不重试 | - |
| 数据收集 (T4) | 不重试 | - |

---

## EAP 设备握手流程

### 通信建立流程

```
Host                    Equipment
  │                          │
  │──── S1F13 ──────────────→│  (T1 = 5秒)
  │                          │
  │←──── S1F14 ──────────────│
  │                          │
  │──── S1F15 ──────────────→│  (T2 = 3秒)
  │                          │
  │←──── S1F17 ──────────────│
  │                          │
  │   状态 → ONLINE          │
```

### 超时处理

```
Host                    Equipment
  │                          │
  │──── S1F13 ──────────────→│
  │                          │
  │    (T1 超时 5秒)         │
  │                          │
  │──── S1F13 (重试) ───────→│
  │                          │
  │←──── S1F14 ──────────────│
  │                          │
  │──── S1F15 ──────────────→│
  │                          │
  │←──── S1F17 ──────────────│
  │                          │
  │   状态 → ONLINE          │
```

---

## 设备事件报告

### S6F11 事件报告结构

```
Event Report (S6F11)
├── EventID: 事件ID
├── EquipmentID: 设备ID
├── Timestamp: 时间戳
├── EventCategory: 事件类别
└── DataVariables: 数据变量列表
    ├── Variable1: 值1
    ├── Variable2: 值2
    └── ...
```

### 事件处理流程

```
Equipment                Host
  │                        │
  │←───── S6F11 ──────────│  Event Report
  │                        │
  │───── S6F12 ───────────→│  Acknowledge
  │                        │
  │ (继续执行)             │
```

---

## 常见错误代码

### CEID (Collection Event ID)

| CEID | 名称 | 说明 |
|------|------|------|
| 1 | Power On | 设备上电 |
| 2 | Power Off | 设备断电 |
| 10 | Process Start | 工艺开始 |
| 11 | Process Complete | 工艺完成 |
| 50 | Alarm Occurred | 警报发生 |
| 100 | Cassette Load | Cassette 装载 |

### Alarm Code

| Alarm | 级别 | 说明 |
|-------|------|------|
| A1001 | Critical | 通信失败 |
| A1002 | Warning | 设备超时 |
| A2001 | Major | 工艺异常 |
| A2002 | Minor | 参数偏差 |

---

## 编码注意事项

### EAP (VB.NET)

```vb
' 正确的通信超时处理
Const T1_TIMEOUT As Integer = 5000  ' 5秒
Dim retryCount As Integer = 0
Const MAX_RETRY As Integer = 3

Do While retryCount < MAX_RETRY
    Dim response = SendMessage(S1F13)
    If response IsNot Nothing Then
        Exit Do
    End If
    retryCount += 1
    Threading.Thread.Sleep(5000)
Loop

' 状态机处理
Select Case deviceState
    Case DeviceState.DISABLED
        ' 处理禁用状态
    Case DeviceState.NOT_CONNECTED
        ' 处理未连接状态
    Case DeviceState.ONLINE
        ' 处理在线状态
End Select
```

### MES (C++)

```cpp
// 智能指针管理设备连接
std::shared_ptr<DeviceCommunicator> comm =
    std::make_shared<DeviceCommunicator>(deviceId);

// 超时处理
auto future = std::async(std::launch::async, [&comm]() {
    return comm->establishCommunication();
});

if (future.wait_for(std::chrono::seconds(T1_TIMEOUT)) == std::future_status::timeout) {
    // 处理超时
    throw CommunicationTimeoutException("S1F13 timeout");
}
```

---

## 调试技巧

### 常见问题排查

| 问题 | 可能原因 | 排查方法 |
|------|---------|---------|
| 设备无法上线 | 1. 网络不通<br>2. 设备ID错误<br>3. T1超时 | ping测试<br>检查配置<br>增加超时时间 |
| 事件未上报 | 1. 未使能事件<br>2. CEID错误<br>3. 事件过滤 | 检查S1F3<br>查看设备日志 |
| 命令无响应 | 1. 设备状态不对<br>2. 命令格式错误<br>3. T3超时 | 检查状态机<br>查看命令格式<br>增加超时 |

### 日志记录要点

```vb
' 记录关键消息
LogSECSMessage("TX", "S1F13", deviceId, messageData)
LogSECSMessage("RX", "S1F14", deviceId, responseData)

' 记录状态转换
LogStateChange(deviceId, oldState, newState)

' 记录超时事件
LogTimeout("S1F13", deviceId, T1_TIMEOUT)
```

---

## 参考标准

- SEMI E4 - SECS-I (半驱动通信)
- SEMI E5 - SECS-II (消息内容)
- SEMI E30 - GEM (通用设备模型)
- SEMI E37 - High Speed SECS Message Services (HSMS)

---

## 相关文档

- [SECS/GEM 消息参考](.claude/docs/knowledge/secs-gem-messages.md)
- [设备状态机详解](.claude/docs/knowledge/device-state-machine.md)
- [EAP 编码规范](.claude/skills/eap/coding-standards.md)
```

- [ ] **Step 3: 验证文件创建**

```bash
ls -la D:\cx\.claude\docs\knowledge\
```

Expected: 显示 mes-eap-technical-knowledge.md

- [ ] **Step 4: 提交**

```bash
git add .claude/docs/knowledge/
git commit -m "feat: add MES/EAP technical knowledge base"
```

---

## Task 7: 创建文件索引模板

**Files:**
- Create: `D:\cx\.claude\indexes\mes-core.md`
- Create: `D:\cx\.claude\indexes\eap-projects.md`
- Create: `D:\cx\.claude\indexes\web-modules.md`

- [ ] **Step 1: 创建 MES 核心文件索引**

```markdown
# MES 核心文件索引

> **系统:** SiView MES
> **技术栈:** C++
> **更新:** {{UPDATE_DATE}}

---

## 核心模块

### 执行引擎
```
src/core/executor/Executor.cpp
src/core/executor/Executor.h
```
**功能:** 事件驱动的多线程执行引擎

### 设备通信
```
src/communication/DeviceCommunicator.cpp
src/communication/DeviceCommunicator.h
src/communication/SECSMessage.cpp
```
**功能:** 与 EAP 系统通信

### 数据访问
```
src/database/MESDataAccess.cpp
src/database/MESDataAccess.h
src/database/ConnectionPool.cpp
```
**功能:** 数据库操作

---

## 设备适配器

### 设备类型映射
```
src/adapters/equipment/*/Adapter.cpp
src/adapters/equipment/*/Adapter.h
```

**常见设备:**
- GROWTH - 生长炉
- ETCH - 刻蚀机
- PHOTOLITHOGRAPHY - 光刻机
- DIFFUSION - 扩散炉

---

## 关键配置

```
config/mes.conf                    # MES 主配置
config/equipment-map.json          # 设备映射
config/database-connection.json    # 数据库连接
config/logging.conf                # 日志配置
```

---

## 业务逻辑插件

```
plugins/recipe/RecipeManager.cpp
plugins/tracking/TrackingManager.cpp
plugins/alarm/AlarmManager.cpp
```

---

## TODO: 实际文件路径

请根据实际 MES 系统结构更新以下内容:

1. 核心模块实际路径
2. 设备适配器列表
3. 配置文件位置
4. 关键类和函数列表
```

- [ ] **Step 2: 创建 EAP 项目索引**

```markdown
# EAP 项目索引

> **系统:** Equipment Automation Program
> **技术栈:** VB.NET
> **项目数:** 上百
> **更新:** {{UPDATE_DATE}}

---

## 项目组织结构

```
EAP/
├── Common/                    # 公共模块
│   ├── SECSCommunicator.vb
│   ├── EventHandler.vb
│   └── StateManager.vb
│
├── Equipment/                 # 设备项目
│   ├── EQ001_GROWTH/
│   │   ├── Main.vb
│   │   ├── Config.vb
│   │   └── Commands.vb
│   ├── EQ002_ETCH/
│   └── ...
│
└── Services/                  # 服务模块
    ├── AlarmService.vb
    └── LoggingService.vb
```

---

## 核心通信类

### SECSCommunicator
```
Common/SECSCommunicator.vb
```
**功能:** SECS/GEM 协议通信

**关键方法:**
- `EstablishCommunication()` - S1F13/S1F14
- `GoOnline()` - S1F15/S1F17
- `SendCommand()` - S2F41
- `ReportEvent()` - S6F11

### EventHandler
```
Common/EventHandler.vb
```
**功能:** 设备事件处理

### StateManager
```
Common/StateManager.vb
```
**功能:** 设备状态管理

---

## 设备项目列表

### 生长炉 (GROWTH)
| 设备ID | 项目路径 | 说明 |
|--------|---------|------|
| EQ001 | Equipment/EQ001_GROWTH/ | 主生长炉 |
| EQ002 | Equipment/EQ002_GROWTH/ | 备用生长炉 |

### 刻蚀机 (ETCH)
| 设备ID | 项目路径 | 说明 |
|--------|---------|------|
| EQ101 | Equipment/EQ101_ETCH/ | 主刻蚀机 |

### 光刻机 (PHOTOLITHOGRAPHY)
| 设备ID | 项目路径 | 说明 |
|--------|---------|------|
| EQ201 | Equipment/EQ201_PHOTO/ | 步进光刻机 |

---

## 公共配置

```
Config/SECSConfig.xml         # SECS 协议配置
Config/EquipmentMap.xml       # 设备映射
Config/TimeoutConfig.xml      # 超时配置
```

---

## TODO: 实际项目列表

请根据实际 EAP 系统更新:

1. 完整设备项目列表
2. 各设备类型的项目数量
3. 实际文件路径
4. 配置文件内容
```

- [ ] **Step 3: 创建 Web 模块索引**

```markdown
# Web 模块索引

> **架构:** B/S
> **技术栈:** JAVA + VUE
> **更新:** {{UPDATE_DATE}}

---

## 后端模块 (JAVA)

### 控制器层
```
src/main/java/com/cx/mes/controller/
├── EquipmentController.java      # 设备管理
├── RecipeController.java         # 工艺配方
├── ProductionController.java     # 生产管理
└── AlarmController.java          # 报警管理
```

### 服务层
```
src/main/java/com/cx/mes/service/
├── EquipmentService.java
├── RecipeService.java
├── ProductionService.java
└── AlarmService.java
```

### 数据访问层
```
src/main/java/com/cx/mes/repository/
├── EquipmentRepository.java
├── RecipeRepository.java
└── ProductionRepository.java
```

### 实体模型
```
src/main/java/com/cx/mes/entity/
├── Equipment.java
├── Recipe.java
└── ProductionRecord.java
```

---

## 前端模块 (VUE)

### 页面组件
```
src/pages/
├── equipment/                   # 设备管理
│   ├── EquipmentList.vue
│   ├── EquipmentDetail.vue
│   └── EquipmentMonitor.vue
├── recipe/                      # 工艺配方
│   ├── RecipeList.vue
│   └── RecipeEditor.vue
└── production/                  # 生产管理
    ├── ProductionDashboard.vue
    └── ProductionTracking.vue
```

### 公共组件
```
src/components/
├── StatusIndicator.vue          # 状态指示器
├── AlarmDisplay.vue             # 报警显示
└── DataTable.vue                # 数据表格
```

### API 调用
```
src/api/
├── equipment.js
├── recipe.js
└── production.js
```

---

## 关键配置

### 后端配置
```
src/main/resources/
├── application.yml              # 主配置
├── application-dev.yml          # 开发环境
└── application-prod.yml         # 生产环境
```

### 前端配置
```
vue.config.js                    # VUE 配置
.env.development                 # 开发环境变量
.env.production                  # 生产环境变量
```

---

## TODO: 实际模块列表

请根据实际项目更新:

1. 完整模块列表
2. 各模块功能说明
3. API 端点列表
4. 页面路由配置
```

- [ ] **Step 4: 验证文件创建**

```bash
ls -la D:\cx\.claude\indexes\
```

Expected: 显示 mes-core.md, eap-projects.md, web-modules.md

- [ ] **Step 5: 提交**

```bash
git add .claude/indexes/
git commit -m "feat: add file index templates for MES, EAP, and Web modules"
```

---

## Task 8: 更新 planning-with-files 进度

**Files:**
- Modify: `D:\cx\task_plan.md`
- Modify: `D:\cx\progress.md`

- [ ] **Step 1: 更新 task_plan.md - 标记 Phase 1 完成**

在 task_plan.md 中，将 Phase 1 的任务标记为完成：

```bash
# 将以下内容
- [ ] 创建 MES/EAP 技术知识库
- [ ] 创建文件索引

# 改为
- [x] 创建 MES/EAP 技术知识库
- [x] 创建文件索引
```

并更新完成标准：

```markdown
### 完成标准
- [x] 所有配置文件 JSON 语法正确
- [x] CLAUDE.md 内容完整且可读
- [x] 目录结构与设计文档一致
```

- [ ] **Step 2: 更新 progress.md - 记录完成情况**

```markdown
### 2025-03-22 - 会话 1 (更新)

**完成:**
- [x] 分析设计文档
- [x] 创建基础配置实施计划
- [x] 执行 Phase 1 所有任务

**Phase 1 完成项:**
- [x] 创建 .claude 目录结构
- [x] 配置 settings.json
- [x] 创建 CLAUDE.md 主文档
- [x] 创建项目级 CLAUDE.md 模板
- [x] 创建 planning-with-files 三文件系统
- [x] 创建 MES/EAP 技术知识库
- [x] 创建文件索引模板

**进行中:**
- 无

**待办:**
- Phase 2: Skills 和 Commands
- Phase 3: Hooks 和文档模板

**下一步:** 开始 Phase 2 - 创建 Skills 和 Commands
```

- [ ] **Step 3: 提交**

```bash
git add task_plan.md progress.md
git commit -m "chore: mark Phase 1 as complete"
```

---

## 完成验证

### 最终检查清单

- [ ] `.claude/` 目录结构完整
- [ ] `settings.json` 配置正确
- [ ] `CLAUDE.md` 内容完整
- [ ] 项目级 CLAUDE.md 模板已创建
- [ ] planning-with-files 三文件已创建
- [ ] MES/EAP 技术知识库已创建
- [ ] 文件索引模板已创建
- [ ] 所有更改已提交

### 验证命令

```bash
# 验证目录结构
find D:\cx\.claude -type f -name "*.md" -o -name "*.json" | sort

# 验证 JSON 配置
python -m json.tool D:\cx\.claude\settings.json > nul && echo "Settings OK"

# 查看文档列表
ls -la D:\cx\.claude/docs/
```

---

## 下一步

Phase 1 完成后，继续：

**Phase 2: Skills 和 Commands**
- 创建技术栈 Skills
- 实现自定义 Commands

**Phase 3: Hooks 和文档模板**
- 配置 Git Hooks
- 创建 PUML 模板

---

**计划版本:** v1.0
**创建日期:** 2025-03-22
**预计耗时:** 4-6 小时
