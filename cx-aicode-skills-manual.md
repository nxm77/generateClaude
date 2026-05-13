# CX-Aicode 技能使用手册

> 基于 v2.3.7 代码深度解析

---

## 一、技能总览与链路

### 1.1 核心技能矩阵

| 技能 | 产出物 | 入口条件 | 出口条件 |
|------|--------|----------|----------|
| **cx-brainstorm** | `design.md` + `tasks.md` | 需求探索 | 用户批准 design |
| **cx-work** | 实现的代码 | design.md 含 `**APPROVED**` | 所有 task checkbox 完成 |
| **cx-codereview** | `.cx/reports/codereview/*.md` | tasks 全部完成 | `reviewStatus: passed/conditional_approved` |
| **cx-verify** | `.cx/reports/verify/*.md` | `reviewStatus` 通过 | `verifyStatus: passed` |
| **cx-finish** | 归档/状态更新 | `reviewStatus` + `verifyStatus` 通过 | 分支收尾 |

### 1.2 标准工作流链路

```
cx-brainstorm (HARD-GATE)
    ↓  (design.md 含 **APPROVED**)
cx-work (逐任务执行 + 两阶段审查)
    ↓  (所有 checkbox - [x])
cx-codereview --scope=spec --spec={SPEC_ID}
    ↓  (reviewStatus passed/conditional_approved)
cx-verify (五维验证)
    ↓  (verifyStatus passed)
cx-finish (本地收尾: keep/discard)
```

---

## 二、SPEC-ID 追踪机制

### 2.1 SPEC-ID 生成与存储

**规范目录结构**:
```
.cx/specs/{SPEC-ID}/
├── source.md          # 需求说明（固定入口）
├── sources/           # 原始需求文件副本
├── design.md          # 设计文档
├── tasks.md           # 任务清单
├── delta-spec.md      # 增量变更（可选）
└── metadata.yaml      # 元数据（spec_id, external_id, status）
```

**SPEC-ID 来源优先级**:
| 优先级 | 来源 | 示例 |
|--------|------|------|
| 1 | 用户显式传入 `--spec-id` | `--spec-id MES-0535` |
| 2 | 自动生成 | `SPEC-YYYYMMDD-NNN` |

**合法性约束**: 只能包含字母、数字、点(.)、下划线(_)、短横线(-)，必须以字母或数字开头。

### 2.2 状态文件位置

| 状态 | 文件路径 |
|------|----------|
| 规范状态 | `.cx/specs/{SPEC-ID}/metadata.yaml` |
| 活跃变更 | `.cx/status/index.json` 的 `activeChange` 字段 |
| 会话 marker | `.cx/work/cx-work-session.json` |

**cx-work-session.json 结构**:
```json
{
  "createdBy": "cx-work",
  "specId": "{SPEC-ID}",
  "initializedAt": "{ISO-8601 timestamp}"
}
```

---

## 三、cx-brainstorm 技能

### 3.1 功能描述

探索式设计技能，通过 Socratic 对话与用户协作澄清需求，输出 `design.md` + `tasks.md`。

### 3.2 命令格式

```
/cx-aicode:cx-brainstorm --spec-id {SPEC-ID}
```

无参数时进入交互式需求探索模式。

### 3.3 输出文件格式

**design.md 章节结构**:
```markdown
# 设计文档 [{SPEC-ID}]

## Goal          # 目标 — 要解决什么问题
## Architecture   # 架构 — 整体结构和关键组件
## Data Model    # 数据模型 — 核心实体和关系
## API           # API — 接口定义和契约
## Flows         # 流程 — 关键操作序列
## Risks         # 风险 — 已知风险和缓解措施
## Approval      # 审批标记（用户批准后追加）
```

**Approval 节格式**（cx-work 入口前置条件）:
```markdown
## Approval

| 角色 | 签名 | 日期 |
|------|------|------|
| 用户 | [用户名] | {批准日期} |
| 状态 | **APPROVED** | |

> 本设计文档已获用户批准，可进入实现阶段。
```

**tasks.md 格式**:
```markdown
# 任务清单 [{SPEC-ID}]

## 1. [分组标题]
- [ ] 1.1 [子任务描述]
- [ ] 1.2 [子任务描述]

## 2. [分组标题]
- [ ] 2.1 [子任务描述]
```

### 3.4 HARD-GATE 铁律

> 在设计文档获得用户批准前，**绝对禁止**：
> - 调用任何实现技能
> - 编写任何代码
> - 搭建任何项目骨架

---

## 四、cx-work 技能

### 4.1 功能描述

按 SPEC-ID 组织任务，通过子代理逐任务执行，实现两阶段审查（规范合规 + 代码质量）。

### 4.2 命令格式

```
/cx-aicode:cx-work --spec={SPEC-ID} [--no-tdd]
```

### 4.3 三文件机制

**文件位置**: `.cx/work/`

| 文件 | 用途 | 关键结构 |
|------|------|----------|
| `task_plan.md` | 执行计划 | `SPEC-ID:` 头、Phase/Task 结构、checkbox `- [ ]` / `- [x]` |
| `findings.md` | 发现记录 | CX Context（技术栈/接口契约/数据模型）、架构决策、研究发现 |
| `progress.md` | 进度追踪 | Session Header、Phase Log（Actions taken + Files modified）、质量门禁表 |

**初始化流程**:
1. 检测 `.cx/work/` 和 `cx-work-session.json` 是否存在且绑定当前 SPEC-ID
2. 无效 → 从 `tasks.md` 重新初始化三文件
3. 有效 → 直接使用（跳过初始化）

**强制更新步骤**（每任务循环后必须执行）:
```
1. Edit task_plan.md  →  checkbox: - [ ] → - [x]
2. Edit progress.md  →  Phase Log 记录完成任务和变更文件
3. Read task_plan.md →  确认下一任务出现在上下文中
```

### 4.4 两阶段审查机制

**顺序绝对不能颠倒**：规范合规审查 → 代码质量审查

| 阶段 | 目的 | Agent | 模型 |
|------|------|-------|------|
| 规范合规审查 | "是否构建了正确的东西？" | `cx-work-spec-reviewer` | **Opus** |
| 代码质量审查 | "是否良好构建？" | `cx-work-quality-reviewer` | **Sonnet** |

**每任务循环流程**:
```
派发实现子代理 → RED-GREEN-REFACTOR
      ↓
派发规范合规审查子代理（Opus）
      ↓
  规范合规？──否→ 修复问题 → 再次审查
      ↓是
派发代码质量审查子代理（Sonnet）
      ↓
  代码质量通过？──否→ 修复问题 → 再次审查
      ↓是
标记任务完成 → 更新三文件
```

### 4.5 子代理模型选择策略

| 模型 | 适用场景 | 任务类型 |
|------|----------|----------|
| **Haiku** | 机械性实现任务 | 隔离函数、清晰规范、1-2 文件 |
| **Sonnet** | 集成和判断任务 | 多文件协调、模式匹配、调试 |
| **Opus** | 架构、设计和审查任务 | 设计决策、跨模块理解、规范合规审查 |

### 4.6 子代理状态处理

| 状态 | 处理方式 |
|------|----------|
| **DONE** | 进入规范合规审查 |
| **DONE_WITH_CONCERNS** | 先读取关注点再决定：若涉及正确性或范围则修复后再审查；若是观察性意见则记录并继续 |
| **NEEDS_CONTEXT** | 提供缺失上下文后重新派发 |
| **BLOCKED** | 评估阻塞原因：① 上下文问题 → 提供更多上下文；② 需要更强推理 → 用更强模型；③ 任务太大 → 拆分；④ 计划错误 → 升级给用户 |

### 4.7 与 cx-codereview 的衔接

**Spec 级 CodeReview Gate**（所有任务完成后）:
```
/cx-aicode:cx-codereview --scope=spec --spec={SPEC_ID} --tech=auto
```

**Review Gate 结果处理**:

| reviewStatus | 处理 |
|--------------|------|
| `passed` | 进入 `/cx-aicode:cx-verify` |
| `conditional_approved` | 记录审批理由后进入 `/cx-aicode:cx-verify` |
| `conditional` | 先用 `/cx-aicode:cx-feedback` 关闭、修复或升级审批 |
| `failed` | 必须修复并重新运行 CodeReview |

---

## 五、cx-codereview 技能

### 5.1 功能描述

代码审查引擎，支持 Spec/增量/全量范围，基于规则与评分标准扫描、识别问题并生成结构化审查报告。

### 5.2 命令格式

```
/cx-aicode:cx-codereview --scope={spec|changed|full} --spec={SPEC-ID} [--base={base}]
/cx-aicode:cx-codereview --since={time} --scope=changed
/cx-aicode:cx-codereview --commits={n} --scope=changed
```

### 5.3 --scope 参数说明

| 范围 | 场景 | 命令示例 |
|------|------|----------|
| **spec** | cx-work 完成后标准门禁 | `/cx-codereview --scope=spec --spec=MES-0535` |
| **changed** | 单开发日常增量任务 | `/cx-codereview --scope=changed --base=origin/main` |
| **full** | 发布前/质量基线/专项治理 | `/cx-codereview --scope=full` |

### 5.4 Spec 模式执行步骤

```
1. 解析 SPEC-ID（优先 --spec，否则 .cx/status/index.json.activeChange，否则最近修改的 spec）
2. 读取规范上下文：design.md, tasks.md, delta-spec.md
3. 确定本次变更文件（git diff 或 progress.md）
4. 用规范过滤问题责任边界
5. 扫描本次变更文件
6. 区分"本次变更问题"与"历史遗留问题"
```

### 5.5 reviewStatus 判定规则

| 条件 | reviewStatus |
|------|--------------|
| L1 > 0 | `failed` |
| L2 > 0 | `failed`（可降为 conditional 或 conditional_approved） |
| 仅 L3/L4 且分数达标 | `passed` 或 `conditional` |
| L2 经负责人显式接受 | `conditional_approved` |

**评分等级**:
| 分数 | 等级 |
|------|------|
| 90-100 | A (优秀) |
| 80-89 | B (良好) |
| 70-79 | C (中等) |
| 60-69 | D (及格) |
| 0-59 | F (不及格) |

### 5.6 报告输出

**路径**: `.cx/reports/codereview/CodeReview-{YYYYMMDD-HHmmss}.md`

**状态写入**: `.cx/status/index.json`
```json
{
  "reviewStatus": "passed|conditional|conditional_approved|failed",
  "codeReview": {
    "scope": "spec|changed|full",
    "specId": "MES-0535",
    "reportPath": ".cx/reports/codereview/...",
    "score": 86,
    "grade": "B",
    "issueCounts": { "L1": 0, "L2": 0, "L3": 4, "L4": 7 },
    "actionableIssues": 4
  }
}
```

### 5.7 与 cx-verify 的边界

| 命令 | 回答的问题 | 典型问题 |
|------|------------|----------|
| `cx-codereview` | 代码写得是否安全、可维护、符合技术栈规则 | SQL 拼接、空指针风险、复杂度过高、命名违规、硬编码密钥 |
| `cx-verify` | 实现是否真的满足 spec/design/tasks | 需求漏做、接口字段不一致、业务规则实现错误、异常路径缺失 |

---

## 六、cx-verify 技能

### 6.1 功能描述

五维验证引擎：需求覆盖 / 接口契约 / 数据模型 / 业务规则 / 异常处理。

### 6.2 命令格式

```
/cx-aicode:cx-verify --spec={SPEC-ID}
```

### 6.3 五维验证检查项

| 维度 | 验证方法 | 证据来源 |
|------|----------|----------|
| **D1 需求覆盖** | 逐条对照 `tasks.md`，Grep/Glob/Read 搜索实现证据 | tasks.md 每条任务 → 源码关键字/文件模式 |
| **D2 接口契约** | 读取 design.md API 节 vs 实现 Controller/Service | API 节定义 vs 路由/方法签名/响应结构 |
| **D3 数据模型** | 读取 design.md Data Model 节 vs 实现 DTO/Entity | Data Model 节 vs 类定义/字段声明/关系映射 |
| **D4 业务规则** | 读取 design.md Flows 节 vs 实现逻辑 | Flows 节关键操作序列/条件分支 vs 业务逻辑实现 |
| **D5 异常处理** | 读取 design.md Risks 节 vs 实现 try-catch | Risks 节已知异常场景 vs catch 块/filter/error response |

**每维 5 步 Gate 函数**:
```
IDENTIFY → RUN → READ → VERIFY → 判定
```

### 6.4 前置条件（reviewStatus 必须通过）

| reviewStatus | cx-verify 行为 |
|--------------|----------------|
| `passed` | 继续执行验证 |
| `conditional_approved` | 继续执行验证，记录审批条件 |
| `conditional` | 停止，提示先修复 |
| `failed` | 停止，提示先修复 CodeReview |
| 缺失 | 停止，提示先运行 CodeReview |

### 6.5 报告输出

**路径**: `.cx/reports/verify/verification-report-{SPEC-ID}-{TIMESTAMP}.md`

**状态写入**:
```json
{
  "verifyStatus": "passed|conditional|failed",
  "qualityGates": {
    "verificationReport": ".cx/reports/verify/...",
    "dimensions": {
      "d1Requirement": { "status": "passed|partial|failed", "coverage": "X/Y" },
      "d2ApiContract": { "status": "consistent|deviation|missing", "coverage": "X/Y" },
      "d3DataModel": { "status": "consistent|deviation|missing", "coverage": "X/Y" },
      "d4BusinessRules": { "status": "satisfied|deviation|missing", "coverage": "X/Y" },
      "d5ExceptionHandling": { "status": "covered|partial|uncovered", "coverage": "X/Y" }
    },
    "overall": "passed|conditional|failed",
    "p0Count": 0,
    "p1Count": 0,
    "p2Count": 0
  }
}
```

---

## 七、cx-finish 技能

### 7.1 功能描述

分支收尾，提供 keep/discard 的本地收尾决策流程。

### 7.2 命令格式

```
/cx-aicode:cx-finish
```

### 7.3 入口条件（强制门禁）

**检查 `.cx/status/index.json` 中的 `reviewStatus` 和 `verifyStatus`**:

| 条件 | 行为 |
|------|------|
| reviewStatus == "failed" | 强制停止，要求修复后重新 CodeReview |
| reviewStatus == "conditional" | 强制停止，要求通过 cx-feedback 关闭 |
| verifyStatus == "failed" | 强制停止，要求修复后重新 verify |
| verifyStatus == "conditional" | 强制停止，要求处理未满足条件 |
| 任一缺失 | 强制停止，要求先运行对应门禁 |

### 7.4 三选项流程

```
Step 1: 验证测试（铁律）— npm test / pytest / mvn test
    ↓
Step 2: 呈现三选项
    ├── 1. 标记完成 — 纳入企业交付记录
    ├── 2. 暂不完成 — 生成遗留问题清单
    └── 3. 废弃任务 — 归档过程记录，不纳入交付
    ↓
Step 3: 用户执行选择
    ↓
Step 4: 确认操作（选项3需打字确认 'discard'）
    ↓
Step 5: 更新项目 CLAUDE.md
```

---

## 八、cx-test / cx-qa 技能

### 8.1 命令格式

```
/cx-aicode:cx-test --type={unit|integration|e2e|all} --lang={java|vue|python|csharp|cpp|vbnet}
/cx-aicode:cx-qa
```

### 8.2 与 SPEC-ID 的关联

通过 `spec-context-loader.js` 读取：
```
.cx/specs/{SPEC-ID}/
├── design.md     → 设计摘要 + 结构化测试语义
├── tasks.md       → 任务列表（含验收标准）
└── delta-spec.md  → 变更需求与场景
```

### 8.3 测试框架映射

| 语言 | 框架 |
|------|------|
| Java | JUnit 5 + Mockito |
| Vue | Vitest + Vue Test Utils |
| Python | pytest |
| C# | xUnit + Moq |
| C++ | Google Test |
| VB.NET | NUnit |

### 8.4 覆盖率门禁

| 层级 | 行覆盖率 | 分支覆盖率 | 函数覆盖率 |
|------|----------|------------|------------|
| Service/Core 层 | >= 80% | >= 75% | >= 90% |
| Controller/API 层 | >= 70% | >= 60% | >= 85% |
| 工具类/Util 层 | >= 90% | >= 80% | 100% |

### 8.5 TDD 铁律

> **没有先写失败的测试，就不能写生产代码。**

---

## 九、关键铁律汇总

### 9.1 HARD-GATE 门禁

| 门禁 | 触发条件 | 阻断行为 |
|------|----------|----------|
| design 未批准 | `design.md` 无 `**APPROVED**` | 禁止进入 cx-work |
| reviewStatus 失败 | `reviewStatus == "failed"` | 禁止进入 cx-verify |
| verifyStatus 失败 | `verifyStatus == "failed"` | 禁止进入 cx-finish |

### 9.2 cx-work 禁止事项

1. **禁止在 design.md 未获批准时开始实现**
2. **禁止跳过任一审查阶段**
3. **禁止在规范合规审查通过前开始代码质量审查**
4. **禁止并行派发多个实现子代理**
5. **禁止忽略子代理提问或 BLOCKED 状态**
6. **禁止跳过 Review Gate**
7. **禁止在 reviewStatus=failed 时进入 cx-verify**

### 9.3 链路原则

- cx-verify 不是 cx-finish 的一部分——两者串联
- cx-work 的两阶段审查是任务内审查；Spec 级 CodeReview 是工作流级 Gate
- 两者都不能替代 cx-verify

---

## 十、文件路径索引

### 10.1 核心文件

| 组件 | 文件路径 |
|------|----------|
| cx-brainstorm | `skills/process/cx-brainstorm/SKILL.md` |
| cx-work | `skills/process/cx-work/SKILL.md` |
| cx-codereview | `skills/process/cx-codereview/SKILL.md` |
| cx-verify | `skills/process/cx-verify/SKILL.md` |
| cx-finish | `skills/process/cx-finish/SKILL.md` |
| cx-test | `skills/process/cx-test/SKILL.md` |
| cx-qa | `skills/process/cx-qa/SKILL.md` |
| cx-entry | `skills/process/cx-entry/SKILL.md` |

### 10.2 Agent 文件

| Agent | 文件路径 |
|-------|----------|
| plan-reviewer | `agents/cx-work-plan-reviewer.md` |
| spec-reviewer | `agents/cx-work-spec-reviewer.md` |
| quality-reviewer | `agents/cx-work-quality-reviewer.md` |
| code-reviewer | `agents/cx-code-reviewer.md` |
| verifier | `agents/cx-verifier.md` |

### 10.3 脚本文件

| 功能 | 文件路径 |
|------|----------|
| Agent 结果校验 | `scripts/agent/validate-agent-result.js` |
| 报告写入 | `scripts/agent/write-report.js` |
| 状态更新 | `scripts/agent/update-status.js` |
| 状态验证 | `scripts/agent/validate-status.js` |

### 10.4 状态文件

| 用途 | 文件路径 |
|------|----------|
| 状态索引 | `.cx/status/index.json` |
| 规范元数据 | `.cx/specs/{SPEC-ID}/metadata.yaml` |
| cx-work 会话 | `.cx/work/cx-work-session.json` |

### 10.5 三文件

| 文件 | 路径 |
|------|------|
| task_plan | `.cx/work/task_plan.md` |
| findings | `.cx/work/findings.md` |
| progress | `.cx/work/progress.md` |

### 10.6 报告输出

| 类型 | 路径 |
|------|------|
| CodeReview | `.cx/reports/codereview/CodeReview-{TIMESTAMP}.md` |
| Verification | `.cx/reports/verify/verification-report-{SPEC-ID}-{TIMESTAMP}.md` |
| QA | `.cx/qa/{module}/test-plan.md` 等 |

---

## 十一、使用场景示例

### 11.1 完整工作流

```bash
# 1. 需求探索
/cx-aicode:cx-brainstorm --spec-id MES-0535

# 2. 用户批准 design.md 后开始实现
/cx-aicode:cx-work --spec=MES-0535

# 3. 所有任务完成后运行 CodeReview
/cx-aicode:cx-codereview --scope=spec --spec=MES-0535 --tech=auto

# 4. CodeReview 通过后运行验证
/cx-aicode:cx-verify --spec=MES-0535

# 5. 验证通过后完成收尾
/cx-aicode:cx-finish
```

### 11.2 日常增量开发

```bash
# 已有 spec，直接开始实现
/cx-aicode:cx-work --spec=MES-0535

# 增量 CodeReview
/cx-aicode:cx-codereview --scope=changed --base=origin/main
```

### 11.3 修复 CodeReview 问题

```bash
# 修复问题后重新审查
/cx-aicode:cx-codereview --scope=spec --spec=MES-0535

# 如果问题较多，可以将 CR-xxx 追加到 task_plan
/cx-aicode:cx-feedback --from-codereview --to-task-plan
```

---

## 十二、统计与上传功能 (Usage Audit)

### 12.1 功能概述

CX-Aicode 内置**本地统计 + 上传 SERVER** 功能，自动追踪技能使用情况并上报。

### 12.2 追踪的命令

| 命令 | 追踪的事件类型 |
|------|---------------|
| `cx-spec` | 规范管理 |
| `cx-brainstorm` | 需求探索 |
| `cx-work` | 工作执行 |
| `cx-codereview` | 代码审查 |
| `cx-verify` | 五维验证 |
| `cx-test` | 测试规划 |

### 12.3 触发机制

| Hook 事件 | 触发时机 |
|-----------|----------|
| `SessionStart` | 会话启动时 flush |
| `UserPromptSubmit` | 用户提交命令时 collect + flush |
| `Stop` | 会话结束时 flush |

### 12.4 核心文件

| 文件路径 | 功能 |
|---------|------|
| `hooks/usage/command-usage.js` | 采集和上传主逻辑 |
| `hooks/usage/local-store.js` | 本地存储管理（JSONL 文件操作） |
| `hooks/usage/event-builder.js` | 事件数据结构构建 |
| `hooks/usage/spec-id-resolver.js` | SPEC-ID 解析逻辑 |
| `hooks/usage/git-identity.js` | Git 用户身份解析 |
| `hooks/usage/command-parser.js` | 命令解析 |
| `hooks/usage/constants.js` | 常量定义 |
| `hooks/usage/uploader.js` | HTTP 上传实现 |
| `hooks/usage/usage-config.js` | 配置加载 |
| `scripts/usage-summary.js` | 本地统计报告生成 |

### 12.5 本地存储文件

| 文件 | 用途 |
|------|------|
| `.cx/usage/cx-command-events.jsonl` | 所有事件记录 |
| `.cx/usage/pending-events.jsonl` | 待上传事件 |
| `.cx/usage/acked-events.jsonl` | 已确认事件 |
| `.cx/usage/usage-errors.log` | 错误日志 |
| `.cx/usage/upload-backoff.json` | 重试退避状态 |
| `.cx/usage/last-flush.json` | 上次刷新时间 |

### 12.6 配置项

**配置文件**: `hooks/usage/usage-config.js`

**项目级配置** (`.cx/config.json`):
```json
{
  "usageAudit": {
    "enabled": true,
    "requireSpecId": false,
    "warnWhenUnbound": true,
    "specId": {
      "pattern": "\\b[A-Z][A-Z0-9]{1,15}-[A-Z0-9][A-Z0-9_-]{1,31}\\b"
    },
    "upload": {
      "enabled": true,
      "endpoint": "https://your-server.com/api/v1/cx-aicode/usage-events/batch",
      "batchSize": 50,
      "minIntervalMs": 60000
    }
  }
}
```

**环境变量**: `CX_USAGE_UPLOAD_TOKEN` — 服务端认证 Token

### 12.7 事件数据格式 (Schema 1.3)

```json
{
  "schemaVersion": "1.3",
  "eventType": "cx_command_invoked",
  "eventId": "evt_xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "timestamp": "2026-05-13T10:20:30.000Z",
  "command": "cx-work",
  "specId": "MES-0508",
  "specIdSource": "flag|nearby|activeChange|cxWorkSession|unbound",
  "projectId": "sha256_hash",
  "gitUserName": "John Doe",
  "gitUserEmail": "john@example.com",
  "sessionId": "session_id",
  "pluginVersion": "2.3.7",
  "source": "UserPromptSubmit",
  "warning": null
}
```

### 12.8 SPEC-ID 解析优先级

| 优先级 | 来源 | 说明 |
|--------|------|------|
| 1 | `--spec-id` 标志 | 显式传入的参数 |
| 2 | 命令附近文本 | 正则匹配 `MES-XXXX` 格式 |
| 3 | `activeChange` | `.cx/status/index.json` |
| 4 | `cxWorkSession` | `.cx/work/cx-work-session.json` |
| 5 | `unbound` | 无法解析时标记 |

### 12.9 上传可靠性机制

| 机制 | 说明 |
|------|------|
| **指数退避** | 初始 60s，最大 1 小时，jitter 20% |
| **批处理** | 默认每批 50 条，最大 100 条 |
| **并发锁** | 文件锁防止多进程冲突（TTL 30s） |
| **幂等上传** | eventId 唯一约束，重复返回 `duplicated` |
| **本地优先** | 网络不可用时事件保留在本地 |

### 12.10 上传流程

```
1. 读取 pending-events.jsonl
2. 检查配置（enabled, endpoint, token）
3. 构造 HTTP POST 请求
   ├── URL: {endpoint}
   ├── Headers: Authorization: Bearer {token}
   └── Body: { "events": [...] }
4. 发送请求，解析响应 { success, accepted, duplicated, failed }
5. 成功 → 写入 acked-events.jsonl，从 pending 移除
6. 失败 → 等待退避时间后重试
```

### 12.11 本地统计报告

**命令**: `node scripts/usage-summary.js`

**输出文件**: `.cx/usage/reports/`

**统计维度**:
- 按 SPEC-ID 聚合命令调用次数
- 按时间范围筛选
- 支持 JSON / MD / CSV 格式输出

**输出示例**:
```markdown
# Usage Summary Report

## Summary
| SPEC-ID | cx-brainstorm | cx-work | cx-codereview | cx-verify | Total |
|---------|---------------|---------|---------------|-----------|-------|
| MES-0508 | 1 | 5 | 2 | 1 | 9 |
| MES-0512 | 1 | 3 | 1 | 0 | 5 |

## Time Range: 2026-05-01 to 2026-05-14
```

### 12.12 SERVER 端 API

**端点**: `POST /api/v1/cx-aicode/usage-events/batch`

**请求格式**:
```json
{
  "events": [
    { /* 事件对象数组 */ }
  ]
}
```

**响应格式**:
```json
{
  "success": true,
  "accepted": 48,
  "duplicated": 2,
  "failed": 0
}
```

**数据库表**:
```sql
CREATE TABLE cx_command_usage_events (
  id BIGSERIAL PRIMARY KEY,
  event_id VARCHAR(80) UNIQUE NOT NULL,
  schema_version VARCHAR(16),
  event_type VARCHAR(64),
  event_time TIMESTAMPTZ,
  command_name VARCHAR(64),
  spec_id VARCHAR(128),
  spec_id_source VARCHAR(32),
  project_id VARCHAR(128),
  git_user_name VARCHAR(128),
  git_user_email VARCHAR(256),
  session_id VARCHAR(128),
  plugin_version VARCHAR(32),
  source VARCHAR(64),
  warning VARCHAR(128),
  raw_event JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 12.13 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `CX_USAGE_UPLOAD_TOKEN` | 服务端认证 Token | (无) |
| `USAGE_API_TOKENS` | SERVER 端允许的 tokens（格式: `name:token`） | (无) |
| `DB_DIALECT` | 数据库类型 | `mysql` |
| `DATABASE_URL` | 数据库连接字符串 | (无) |
| `PORT` | 服务端口 | `3000` |

### 12.14 SERVER 端部署

**技术栈**: Fastify + MySQL/PostgreSQL/Oracle

**部署步骤**:
1. 设置环境变量 `USAGE_API_TOKENS`, `DATABASE_URL`
2. 运行 `node server/usage-api/index.js`
3. 配置项目 `.cx/config.json` 的 `usageAudit.upload.endpoint`

### 12.15 故障排除

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 事件未上传 | `CX_USAGE_UPLOAD_TOKEN` 未设置 | 设置环境变量 |
| 上传被拒绝 | Token 不匹配 | 检查 SERVER 端 `USAGE_API_TOKENS` |
| 事件重复 | 网络超时重试 | 正常，SERVER 端会去重 |
| 退避时间过长 | 连续失败 | 检查 SERVER 可达性，删除 `upload-backoff.json` 重置 |