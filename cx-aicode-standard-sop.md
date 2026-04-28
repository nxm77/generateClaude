# CX-Aicode 插件标准 SOP 流程

> 适用对象：使用 `cx-aicode` 插件进行 AI 编程的项目经理、技术负责人、开发人员、测试人员、代码审查人员。  
> 适用技术栈：C++、Java、Vue、Python、C#、VB.NET，以及 MES / EAP 等企业业务项目。  
> 适用场景：新项目开发、已有项目需求修改、已有项目 Bug 修复、测试计划与测试执行、代码审查与交付收尾。  
> 推荐版本：cx-aicode v2.3.x 及以上。  

---

## 1. SOP 总原则

### 1.1 核心工作流

CX-Aicode 推荐采用“先设计、后实现、再审查、最后验证”的强约束流程：

```text
/cx-entry
   ↓
/cx-brainstorm 或 /cx-spec
   ↓
用户审批设计 / 规范
   ↓
/cx-work
   ↓
/cx-codereview
   ↓
/cx-feedback（如有问题）
   ↓
/cx-verify
   ↓
/cx-test（按需补充或专项测试）
   ↓
/cx-finish
```

### 1.2 四条铁律

| 铁律 | 说明 | 对应命令 |
|---|---|---|
| 先规范，后编码 | 没有 `design.md` / `tasks.md` / `delta-spec.md`，不得直接写业务代码 | `/cx-brainstorm`、`/cx-spec` |
| 设计需审批 | 设计或变更规范未被用户确认前，不进入实现 | `/cx-work` 前人工审批 |
| 先根因，后修复 | Bug 修复必须先定位根因，禁止只修症状 | `/cx-debug` |
| 有证据，才算完成 | 没有测试、审查、验证证据，不能宣称完成 | `/cx-codereview`、`/cx-verify`、`/cx-test` |

### 1.3 标准产出目录

```text
项目根目录/
├── .cx/
│   ├── config.json
│   ├── specs/
│   │   └── SPEC-YYYYMMDD-NNN/
│   │       ├── proposal.md        # 完整规范时使用
│   │       ├── design.md          # 设计文档
│   │       ├── delta-spec.md      # 增量变更时使用
│   │       ├── tasks.md           # 任务清单
│   │       └── metadata.yaml      # 元数据，可选
│   ├── work/
│   │   ├── task_plan.md           # 执行计划
│   │   ├── progress.md            # 执行进度
│   │   └── findings.md            # 问题、发现、决策记录
│   ├── docs/
│   ├── diagrams/
│   ├── status/
│   │   └── index.json
│   └── archive/
└── 源码目录/
```

---

## 2. 角色与职责

| 角色 | 主要职责 | 必须确认的内容 |
|---|---|---|
| 业务负责人 / 产品负责人 | 提供需求、确认范围、审批设计 | 需求范围、验收标准、优先级 |
| 技术负责人 | 确认架构、接口、数据模型、技术风险 | `design.md`、`delta-spec.md`、关键技术方案 |
| 开发人员 | 使用 `/cx-work` 执行任务，处理审查反馈 | 任务完成、单元测试、代码提交 |
| 测试人员 | 生成测试计划、执行测试、确认缺陷闭环 | `test-plan.md`、测试用例、测试报告 |
| 代码审查人员 | 审查规范符合度、质量、安全、可维护性 | `/cx-codereview` 报告、问题清单 |
| 发布负责人 | 合并、PR、版本记录、归档 | `/cx-finish` 输出、发布说明 |

---

## 3. 通用前置检查 SOP

所有项目、所有场景开始前，先执行本节检查。

### 3.1 插件安装检查

```bash
claude plugin list
```

确认 `cx-aicode` 已安装。

如需安装：

```bash
claude plugin marketplace add ./
claude plugin install cx-aicode
```

### 3.2 项目状态检查

```bash
git status
```

要求：

- 工作区没有不明来源的大量未提交文件。
- 当前分支明确，禁止直接在生产主分支上试验性开发。
- 已确认项目构建方式、测试方式、主要技术栈。

### 3.3 初始化 CX-Aicode

首次在项目中使用：

```text
/cx-init
```

按项目类型选择：

```text
/cx-init --tech=java,vue --name=project-name
/cx-init --tech=cpp --name=project-name
/cx-init --tech=python --name=project-name
/cx-init --tech=csharp --name=project-name
/cx-init --tech=vb --name=project-name
/cx-init --flavor=mes --name=mes-project
/cx-init --flavor=eap --name=eap-project
```

初始化后检查：

```text
/cx-status
/cx-doctor
```

### 3.4 建议新建工作分支

```bash
git checkout -b feature/SPEC-YYYYMMDD-NNN-short-name
```

命名建议：

| 类型 | 分支命名 |
|---|---|
| 新功能 | `feature/SPEC-YYYYMMDD-NNN-feature-name` |
| Bug 修复 | `bugfix/SPEC-YYYYMMDD-NNN-bug-name` |
| 重构 | `refactor/SPEC-YYYYMMDD-NNN-refactor-name` |
| 测试补强 | `test/SPEC-YYYYMMDD-NNN-test-name` |
| 紧急修复 | `hotfix/SPEC-YYYYMMDD-NNN-issue-name` |

---

## 4. SOP-A：某技术栈新项目开发

### 4.1 适用场景

适用于以下情况：

- 新建 Java + Vue、Python、C#、C++、VB.NET 等项目。
- 需求尚不完整，需要 AI 辅助梳理方案。
- 已有高层需求，但尚未形成可开发任务。
- 需要从 0 到 1 建立项目目录、规范、开发任务、测试任务。

### 4.2 输入材料

| 输入 | 是否必须 | 说明 |
|---|---|---|
| 项目名称 | 必须 | 用于初始化配置和分支命名 |
| 技术栈 | 必须 | 如 Java + Vue、C++、Python |
| 业务目标 | 必须 | 项目要解决什么问题 |
| 非功能要求 | 建议 | 性能、安全、权限、部署、兼容性 |
| UI / API / 数据库要求 | 建议 | 有则提供，无则由 `/cx-brainstorm` 补问 |

### 4.3 标准流程

```text
Step 1  初始化项目
Step 2  需求探索
Step 3  生成设计与任务
Step 4  用户审批
Step 5  执行开发
Step 6  代码审查
Step 7  设计验证
Step 8  测试补强
Step 9  交付收尾
```

### 4.4 操作步骤

#### Step 1：初始化

Java + Vue 示例：

```text
/cx-init --tech=java,vue --name=equipment-monitor
```

C++ 示例：

```text
/cx-init --tech=cpp --name=mes-adapter
```

MES 示例：

```text
/cx-init --flavor=mes --name=line-mes-extension
```

EAP 示例：

```text
/cx-init --flavor=eap --name=eqp-eap-adapter
```

检查状态：

```text
/cx-status
/cx-doctor
```

#### Step 2：需求探索

当需求不清楚时：

```text
/cx-brainstorm
```

推荐向 Claude 提供如下内容：

```text
请使用 /cx-brainstorm 帮我梳理一个 Java + Vue 新项目。
项目目标：建设设备状态监控系统。
需要包含：设备列表、实时状态、告警记录、角色权限、操作日志。
请输出 design.md 和 tasks.md，并列出需要我确认的问题。
```

#### Step 3：生成规范文件

`/cx-brainstorm` 应产出：

```text
.cx/specs/SPEC-YYYYMMDD-NNN/
├── design.md
└── tasks.md
```

`design.md` 最少应包含：

```markdown
# Design Document

## 1. Background

## 2. Goals / Non-Goals

## 3. Architecture

## 4. API Design

## 5. Data Model

## 6. Frontend Design

## 7. Business Rules

## 8. Error Handling

## 9. Security / Permission

## 10. Test Strategy

## 11. Risks
```

`tasks.md` 最少应包含：

```markdown
# Task List

## 1. 后端基础能力
- [ ] 1.1 创建实体、DTO、Mapper
- [ ] 1.2 创建 Service
- [ ] 1.3 创建 Controller
- [ ] 1.4 编写单元测试

## 2. 前端基础能力
- [ ] 2.1 创建页面路由
- [ ] 2.2 创建列表页面
- [ ] 2.3 创建表单组件
- [ ] 2.4 编写组件测试

## 3. 集成验证
- [ ] 3.1 前后端联调
- [ ] 3.2 异常场景验证
- [ ] 3.3 权限验证
```

#### Step 4：用户审批

在 `design.md` 或任务评论中明确审批：

```markdown
## Approval

**APPROVED** by <负责人> on YYYY-MM-DD
```

审批前禁止进入实现。

#### Step 5：执行开发

```text
/cx-work --spec=SPEC-YYYYMMDD-NNN
```

执行要求：

- 每次只执行一个任务。
- 每个任务都要经过“规范合规审查”和“代码质量审查”。
- 如启用 TDD，先写失败测试，再写实现。
- 修改过程中所有关键发现写入 `.cx/work/findings.md`。

#### Step 6：代码审查

开发完成后执行：

```text
/cx-codereview --scope=spec --spec=SPEC-YYYYMMDD-NNN
```

如是发布前质量基线，可执行全量：

```text
/cx-codereview --scope=full --tech=java,vue
```

若有问题：

```text
/cx-feedback --from-codereview --to-task-plan
/cx-work --spec=SPEC-YYYYMMDD-NNN
```

#### Step 7：设计合规验证

```text
/cx-verify --spec=SPEC-YYYYMMDD-NNN
```

验证维度：

| 维度 | 说明 |
|---|---|
| 需求覆盖 | `tasks.md` 是否全部完成 |
| 接口契约 | API 路径、参数、响应是否符合设计 |
| 数据模型 | 字段、类型、关系是否符合设计 |
| 业务规则 | 规则是否被实现 |
| 异常处理 | 错误码、空值、超时、失败路径是否覆盖 |

#### Step 8：测试补强

```text
/cx-test --type=all --lang=java
/cx-test --type=all --lang=vue
```

必要时按类型执行：

```text
/cx-test --type=unit --lang=java
/cx-test --type=integration --lang=java
/cx-test --type=e2e --lang=vue
```

#### Step 9：收尾

```text
/cx-finish
```

根据实际情况选择：

| 选项 | 使用场景 |
|---|---|
| merge | 本地已验证，可直接合并 |
| PR | 需要团队审查 |
| keep | 暂不合并，保留分支 |
| discard | 放弃本次变更 |

### 4.5 新项目完成标准

- [ ] `design.md` 已审批。
- [ ] `tasks.md` 全部任务完成。
- [ ] 单元测试通过。
- [ ] 集成测试通过。
- [ ] 前端构建通过。
- [ ] `/cx-codereview` 通过或条件通过。
- [ ] `/cx-verify` 通过。
- [ ] 关键文档、接口说明、部署说明已生成或更新。
- [ ] 已完成 `/cx-finish`。

---

## 5. SOP-B：已有项目修改需求 / 增加功能

### 5.1 适用场景

- 老项目新增一个功能模块。
- 对已有接口增加字段或调整逻辑。
- 修改现有业务规则。
- 前端页面新增按钮、查询条件、表格列、审批动作。
- 后端已有服务需要扩展能力。

### 5.2 核心原则

已有项目不要直接创建完整新规范，优先使用 Delta Spec 描述增量变更：

```text
/cx-spec new --delta
```

Delta Spec 只描述本次变化，避免把历史系统问题混入本次任务。

### 5.3 标准流程

```text
Step 1  读取现有项目结构
Step 2  创建 Delta Spec
Step 3  明确影响范围
Step 4  生成任务清单
Step 5  用户审批
Step 6  执行修改
Step 7  Spec 范围代码审查
Step 8  回归测试
Step 9  归档 Delta Spec
Step 10 收尾
```

### 5.4 操作步骤

#### Step 1：检查当前状态

```text
/cx-status
/cx-doctor
```

建议先让 Claude 做影响分析：

```text
请先阅读项目结构和相关代码，不要修改代码。
需求：在设备状态查询接口中增加 alarmStatus 字段。
请输出影响范围、涉及文件、风险点和建议的 Delta Spec。
```

#### Step 2：创建增量规范

```text
/cx-spec new --name 新增设备告警状态字段 --delta
```

生成目录：

```text
.cx/specs/SPEC-YYYYMMDD-NNN/
├── delta-spec.md
└── tasks.md
```

#### Step 3：编写 Delta Spec

推荐格式：

```markdown
# Delta: 新增设备告警状态字段

## ADDED Requirements

### Requirement: 设备状态查询返回告警状态
设备状态查询接口应返回 `alarmStatus` 字段，用于表示当前设备是否存在未处理告警。

#### Scenario: 设备存在未处理告警
- GIVEN: 设备存在未处理告警
- WHEN: 调用设备状态查询接口
- THEN: 响应中 `alarmStatus` = `ACTIVE`

#### Scenario: 设备不存在未处理告警
- GIVEN: 设备不存在未处理告警
- WHEN: 调用设备状态查询接口
- THEN: 响应中 `alarmStatus` = `NONE`

## MODIFIED Requirements

### Requirement: 设备状态查询响应结构 [MODIFIED]
响应结构增加 `alarmStatus` 字段。

(Previously: 只返回设备在线状态、设备名称、更新时间)

## REMOVED Requirements

无。

## RENAMED

无。

## Impact Scope

- Backend DTO: `EquipmentStatusDTO`
- Backend Service: `EquipmentStatusService`
- Backend Controller: `EquipmentStatusController`
- Frontend API: `equipment.ts`
- Frontend View: `EquipmentStatus.vue`
- Tests: Service unit test, Controller test, Vue component test
```

#### Step 4：确认任务清单

`tasks.md` 应体现可执行任务：

```markdown
# Task List

## 1. 后端修改
- [ ] 1.1 修改 `EquipmentStatusDTO` 增加 `alarmStatus`
- [ ] 1.2 修改 Service 聚合告警状态
- [ ] 1.3 修改 Controller 响应
- [ ] 1.4 增加后端单元测试

## 2. 前端修改
- [ ] 2.1 修改 API 类型定义
- [ ] 2.2 修改页面展示列
- [ ] 2.3 增加前端组件测试

## 3. 回归验证
- [ ] 3.1 验证原有状态查询不受影响
- [ ] 3.2 验证无告警和有告警两种场景
```

#### Step 5：审批

审批内容包括：

- 本次变更范围是否正确。
- 是否会影响旧接口兼容性。
- 是否需要数据库变更。
- 是否需要同步前端、测试、接口文档。

#### Step 6：执行修改

```text
/cx-work --spec=SPEC-YYYYMMDD-NNN
```

#### Step 7：代码审查

日常需求修改优先使用 Spec 范围审查：

```text
/cx-codereview --scope=spec --spec=SPEC-YYYYMMDD-NNN
```

或按分支增量审查：

```text
/cx-codereview --scope=changed --base=origin/main --tech=java,vue
```

#### Step 8：处理审查问题

```text
/cx-feedback --from-codereview --to-task-plan
/cx-work --spec=SPEC-YYYYMMDD-NNN
/cx-codereview --scope=spec --spec=SPEC-YYYYMMDD-NNN
```

#### Step 9：验证与测试

```text
/cx-verify --spec=SPEC-YYYYMMDD-NNN
/cx-test --type=unit --lang=java
/cx-test --type=unit --lang=vue
```

如涉及接口或数据库：

```text
/cx-test --type=integration --lang=java
```

如涉及关键页面：

```text
/cx-test --type=e2e --lang=vue
```

#### Step 10：归档变更

```text
/cx-spec archive SPEC-YYYYMMDD-NNN
```

归档要求：

- Delta Spec 合并到主规范或归档目录。
- 本次变更的审查报告、验证报告、测试报告保留。

### 5.5 已有项目修改完成标准

- [ ] Delta Spec 已编写并审批。
- [ ] 影响范围明确。
- [ ] `tasks.md` 任务全部完成。
- [ ] 新增或修改测试已通过。
- [ ] 旧功能回归测试通过。
- [ ] `/cx-codereview --scope=spec` 通过。
- [ ] `/cx-verify` 通过。
- [ ] Delta Spec 已归档。

---

## 6. SOP-C：已有项目修复 Bug

### 6.1 适用场景

- 线上或测试环境出现异常。
- 接口返回错误。
- 页面展示不正确。
- 批处理、定时任务、消息处理异常。
- MES / EAP / 设备通信流程异常。

### 6.2 核心原则

Bug 修复必须先执行根因调查：

```text
/cx-debug
```

禁止：

- 未复现就修改代码。
- 只根据报错文本猜测修复。
- 连续多次尝试随机修改。
- 没有回归测试就宣称修复完成。

### 6.3 标准流程

```text
Step 1  收集 Bug 信息
Step 2  使用 /cx-debug 定位根因
Step 3  形成根因报告
Step 4  创建修复 Delta Spec
Step 5  先写失败测试
Step 6  执行修复
Step 7  验证修复和回归
Step 8  代码审查
Step 9  收尾归档
```

### 6.4 Bug 信息模板

```markdown
# Bug Report

## 1. 基本信息
- Bug 编号：BUG-YYYYMMDD-NNN
- 发现环境：dev / test / staging / production
- 发现时间：YYYY-MM-DD HH:mm
- 影响系统：
- 影响模块：
- 严重等级：P0 / P1 / P2 / P3

## 2. 现象
- 用户看到什么：
- 系统实际行为：
- 期望行为：

## 3. 复现步骤
1. 
2. 
3. 

## 4. 错误证据
- 错误日志：
- 截图：
- 请求参数：
- 响应内容：
- 相关 TraceId / RequestId：

## 5. 初步影响范围
- 是否影响生产：
- 是否影响数据准确性：
- 是否影响设备控制：
- 是否存在安全风险：
```

### 6.5 操作步骤

#### Step 1：启动调试

```text
/cx-debug --error="设备状态查询接口返回 500，日志显示 NullPointerException"
```

或：

```text
/cx-debug
```

然后提交 Bug Report。

#### Step 2：根因调查

Claude 应按四阶段执行：

```text
阶段 1：重现问题
阶段 2：分析调用链和类似代码
阶段 3：提出单一根因假设并验证
阶段 4：制定修复方案
```

必须产出根因说明：

```markdown
## Root Cause Analysis

### 问题现象

### 复现步骤

### 根因

### 证据

### 影响范围

### 修复策略

### 回归测试范围
```

#### Step 3：创建修复规范

```text
/cx-spec new --name 修复设备状态查询空指针 --delta
```

`delta-spec.md` 示例：

```markdown
# Delta: 修复设备状态查询空指针

## MODIFIED Requirements

### Requirement: 设备状态为空时安全返回 [MODIFIED]
当设备状态字段为空时，系统应返回 `UNKNOWN`，不得抛出 NullPointerException。

#### Scenario: 状态字段为空
- GIVEN: 数据库中设备状态字段为 null
- WHEN: 查询设备状态
- THEN: 接口返回 HTTP 200
- AND: `status` 字段为 `UNKNOWN`
- AND: 记录可追踪日志
```

#### Step 4：先写失败测试

推荐指令：

```text
请基于 delta-spec.md 先补充一个能稳定复现该 Bug 的失败测试，不要先修改生产代码。
```

或使用：

```text
/cx-tdd --phase=red
```

#### Step 5：执行修复

```text
/cx-work --spec=SPEC-YYYYMMDD-NNN
```

修复要求：

- 一次只修复一个根因。
- 不引入无关重构。
- 不扩大需求范围。
- 必须补充回归测试。
- 修复后重新运行失败测试，确认从失败变为通过。

#### Step 6：验证

```text
/cx-verify --spec=SPEC-YYYYMMDD-NNN
```

专项测试：

```text
/cx-test --type=unit --lang=java
/cx-test --type=integration --lang=java
```

也可直接执行项目命令：

```bash
mvn test
npm test
pytest
dotnet test
ctest
```

#### Step 7：代码审查

```text
/cx-codereview --scope=spec --spec=SPEC-YYYYMMDD-NNN
```

重点检查：

- 是否真正修复根因。
- 是否遗漏边界条件。
- 是否影响历史逻辑。
- 是否引入新的异常路径。
- 是否包含回归测试。

#### Step 8：收尾

```text
/cx-finish
```

### 6.6 Bug 修复完成标准

- [ ] Bug 可稳定复现或有充分证据说明不可复现原因。
- [ ] 已输出根因分析。
- [ ] 已创建修复 Delta Spec。
- [ ] 已补充失败测试。
- [ ] 修复后失败测试变为通过。
- [ ] 回归测试通过。
- [ ] `/cx-codereview` 通过。
- [ ] `/cx-verify` 通过。
- [ ] Bug 报告、修复说明、测试证据已归档。

---

## 7. SOP-D：测试流程

### 7.1 适用场景

- 新功能开发完成后需要生成测试计划。
- 老项目变更后需要回归测试。
- Bug 修复后需要补充回归用例。
- 需要生成单元测试、集成测试、E2E 测试、测试数据、测试报告。

### 7.2 测试类型选择

| 测试类型 | 使用场景 | 命令 |
|---|---|---|
| 单元测试 | Service、工具类、组件、函数 | `/cx-test --type=unit` |
| 集成测试 | Controller、数据库、接口、消息、外部服务 | `/cx-test --type=integration` |
| E2E 测试 | 前端页面、完整业务流程 | `/cx-test --type=e2e` |
| 全量测试工件 | 测试计划、矩阵、用例、报告 | `/cx-test --type=all` |
| 从代码生成 | 老项目没有规范或测试缺失 | `/cx-test --from-code` |

### 7.3 标准流程

```text
Step 1  确认测试对象和 SPEC-ID
Step 2  读取 design.md / delta-spec.md / tasks.md
Step 3  生成测试计划
Step 4  生成测试用例和测试数据
Step 5  执行测试
Step 6  生成测试报告
Step 7  根据失败结果补强测试或修复代码
Step 8  回归确认
```

### 7.4 操作步骤

#### Step 1：生成完整测试计划

```text
/cx-test --type=all --lang=java
/cx-test --type=all --lang=vue
```

对于自动检测不准确的项目，必须显式指定技术栈：

```text
/cx-test --type=all --lang=python
/cx-test --type=all --lang=cpp
/cx-test --type=all --lang=csharp
/cx-test --type=all --lang=vbnet
```

#### Step 2：生成专项测试

单元测试：

```text
/cx-test --type=unit --lang=java
```

集成测试：

```text
/cx-test --type=integration --lang=java
```

E2E 测试：

```text
/cx-test --type=e2e --lang=vue
```

#### Step 3：测试计划最少内容

```markdown
# Test Plan

## 1. 测试范围

## 2. 不测试范围

## 3. 测试环境

## 4. 测试数据

## 5. 单元测试

## 6. 集成测试

## 7. E2E 测试

## 8. 回归测试

## 9. 风险与阻塞

## 10. 通过标准
```

#### Step 4：需求追踪矩阵

每个需求都要追踪到测试用例：

```markdown
# Requirement Traceability Matrix

| Requirement | Source | Test Case | Test Type | Status |
|---|---|---|---|---|
| 设备状态查询返回 alarmStatus | delta-spec.md | TC-001 | integration | pass |
| 告警为空时返回 NONE | delta-spec.md | TC-002 | unit | pass |
| 前端显示告警状态 | delta-spec.md | TC-003 | e2e | pass |
```

#### Step 5：执行测试

根据技术栈执行：

```bash
# Java
mvn test
mvn verify

# Vue
npm test
npm run test:unit
npm run test:e2e
npm run build

# Python
pytest

# C#
dotnet test

# C++
cmake --build .
ctest
```

#### Step 6：失败反馈闭环

如测试失败：

```text
/cx-feedback --list
/cx-debug --error="粘贴失败日志"
```

修复后：

```text
/cx-work --spec=SPEC-YYYYMMDD-NNN
/cx-test --type=unit --lang=<tech>
/cx-verify --spec=SPEC-YYYYMMDD-NNN
```

### 7.5 测试完成标准

- [ ] 测试计划已生成。
- [ ] 需求追踪矩阵已生成。
- [ ] 正向场景测试通过。
- [ ] 异常场景测试通过。
- [ ] 边界值测试通过。
- [ ] 回归测试通过。
- [ ] 失败用例已闭环。
- [ ] 测试报告已归档。

---

## 8. SOP-E：代码审查与质量门禁

### 8.1 审查范围选择

| 场景 | 推荐命令 |
|---|---|
| 当前 Spec 的日常任务 | `/cx-codereview --scope=spec --spec=SPEC-YYYYMMDD-NNN` |
| 当前分支相对主分支的变更 | `/cx-codereview --scope=changed --base=origin/main` |
| 发布前全量质量基线 | `/cx-codereview --scope=full` |
| 最近几天变更 | `/cx-codereview --since=3d` |
| 最近 N 个提交 | `/cx-codereview --commits=5` |

### 8.2 审查重点

| 维度 | 检查内容 |
|---|---|
| 规范符合度 | 是否按 `design.md` / `delta-spec.md` 实现 |
| 代码质量 | 可读性、复杂度、重复代码、命名、异常处理 |
| 安全性 | 权限、输入校验、敏感信息、SQL 注入、日志泄露 |
| 兼容性 | 旧接口、旧数据、旧流程是否受影响 |
| 测试充分性 | 是否覆盖正向、异常、边界、回归场景 |
| 企业规范 | 是否符合项目编码规范和架构约束 |

### 8.3 问题处理流程

```text
/cx-codereview
   ↓
发现问题
   ↓
/cx-feedback --from-codereview --to-task-plan
   ↓
/cx-work 继续修复
   ↓
重新 /cx-codereview
   ↓
通过后 /cx-verify
```

### 8.4 通过标准

- Critical 问题：必须全部修复。
- High 问题：原则上全部修复，例外需技术负责人批准。
- Medium 问题：可合并为后续任务，但必须记录。
- Low 问题：可作为优化建议。

---

## 9. SOP-F：验证与交付收尾

### 9.1 验证流程

```text
/cx-verify --spec=SPEC-YYYYMMDD-NNN
```

五维验证：

| 维度 | 验证对象 |
|---|---|
| D1 需求覆盖 | `tasks.md` 中每项任务是否有实现证据 |
| D2 接口契约 | API 路径、参数、响应码、响应体 |
| D3 数据模型 | DTO、Entity、表结构、字段类型 |
| D4 业务规则 | 规则、状态机、计算逻辑、审批逻辑 |
| D5 异常处理 | 空值、超时、错误码、失败重试、日志 |

### 9.2 收尾流程

```text
/cx-finish
```

执行前确认：

- [ ] `/cx-codereview` 已通过。
- [ ] `/cx-verify` 已通过。
- [ ] 测试命令已执行并通过。
- [ ] 工作区只包含本次相关变更。
- [ ] 变更说明已准备。

### 9.3 交付记录模板

```markdown
# Delivery Note

## 1. 变更编号
SPEC-YYYYMMDD-NNN

## 2. 变更摘要

## 3. 涉及文件

## 4. 测试结果

## 5. CodeReview 结果

## 6. Verify 结果

## 7. 已知风险

## 8. 回滚方案
```

---

## 10. SOP-G：会话中断与恢复

### 10.1 查看状态

```text
/cx-status
```

检查：

```text
.cx/work/task_plan.md
.cx/work/progress.md
.cx/work/findings.md
.cx/status/index.json
```

### 10.2 恢复执行

```text
/cx-work --spec=SPEC-YYYYMMDD-NNN --status
/cx-work --spec=SPEC-YYYYMMDD-NNN
```

### 10.3 恢复时禁止事项

- 不要跳过未完成任务。
- 不要在不读取 `.cx/work/` 文件的情况下继续修改代码。
- 不要假设上一轮测试已经通过，应重新执行关键测试。

---

## 11. SOP-H：紧急修复流程

### 11.1 适用场景

- 生产故障。
- P0 / P1 严重问题。
- 设备控制、生产流程、数据准确性受影响。

### 11.2 最小强制流程

紧急情况下可以缩短设计文档，但不能跳过根因、测试、审查证据。

```text
/cx-debug
   ↓
创建最小 delta-spec.md
   ↓
补充失败测试或复现脚本
   ↓
/cx-work
   ↓
运行专项测试
   ↓
/cx-codereview --scope=changed
   ↓
/cx-verify
   ↓
/cx-finish
```

### 11.3 紧急 Delta Spec 模板

```markdown
# Emergency Delta: <问题名称>

## Incident
- 时间：
- 影响：
- 严重等级：

## Root Cause

## Fix Scope

## MODIFIED Requirements

### Requirement: <修复要求>

#### Scenario: <复现场景>
- GIVEN:
- WHEN:
- THEN:

## Validation
- 专项测试：
- 回归测试：
- 监控确认：

## Rollback Plan
```

---

## 12. 常用指令模板

### 12.1 新项目需求探索

```text
请使用 /cx-brainstorm 为一个 <技术栈> 新项目生成设计和任务。
项目目标：<目标>
必须包含：<模块列表>
非功能要求：<性能/权限/安全/审计/部署>
请输出 design.md、tasks.md，并列出需要我审批的问题。
```

### 12.2 已有项目增加功能

```text
请先阅读现有代码，不要修改代码。
需求：<需求描述>
请输出影响范围、涉及文件、兼容性风险、建议的 delta-spec.md 和 tasks.md。
确认后再进入 /cx-work。
```

### 12.3 Bug 修复

```text
请使用 /cx-debug 定位 Bug 根因。
现象：<现象>
错误日志：<日志>
复现步骤：<步骤>
要求：先输出根因分析和修复 Delta Spec，不要直接修改代码。
```

### 12.4 生成测试

```text
请使用 /cx-test 基于 SPEC-YYYYMMDD-NNN 生成测试计划、测试用例、测试数据和需求追踪矩阵。
测试类型：unit / integration / e2e / all
技术栈：<tech>
```

### 12.5 代码审查

```text
请执行 /cx-codereview --scope=spec --spec=SPEC-YYYYMMDD-NNN。
重点关注：规范符合度、异常处理、兼容性、安全性、测试覆盖。
```

---

## 13. 总检查清单

### 13.1 开始前

- [ ] 插件已安装。
- [ ] 项目已 `/cx-init`。
- [ ] 当前分支明确。
- [ ] Git 工作区状态清晰。
- [ ] 技术栈、构建命令、测试命令明确。

### 13.2 编码前

- [ ] 已有 `design.md` 或 `delta-spec.md`。
- [ ] 已有 `tasks.md`。
- [ ] 设计或变更已审批。
- [ ] 影响范围已确认。
- [ ] 测试策略已明确。

### 13.3 编码中

- [ ] 每次只执行一个任务。
- [ ] 关键发现写入 `.cx/work/findings.md`。
- [ ] 进度写入 `.cx/work/progress.md`。
- [ ] 任务完成后更新 checkbox。
- [ ] 遇到异常时使用 `/cx-debug`。

### 13.4 提交前

- [ ] 单元测试通过。
- [ ] 集成测试或专项测试通过。
- [ ] 前端构建通过。
- [ ] `/cx-codereview` 通过。
- [ ] `/cx-verify` 通过。
- [ ] 没有无关文件变更。

### 13.5 交付前

- [ ] 变更说明已完成。
- [ ] 测试报告已完成。
- [ ] 审查问题已关闭。
- [ ] 风险和回滚方案已记录。
- [ ] 已执行 `/cx-finish`。

---

## 14. 推荐落地策略

### 14.1 团队级强制规则

建议企业内部规定：

1. 所有 AI 编程任务必须有 `SPEC-ID`。
2. 所有新增功能必须走 `/cx-brainstorm` 或 `/cx-spec`。
3. 所有老项目变更必须走 Delta Spec。
4. 所有 Bug 修复必须走 `/cx-debug`。
5. 所有合并前必须通过 `/cx-codereview` 和 `/cx-verify`。
6. 所有测试缺陷必须通过 `/cx-feedback` 回流到任务清单。

### 14.2 项目级目录规范

建议每个项目保留：

```text
.cx/specs/       # 规范与变更记录
.cx/work/        # 当前执行状态
.cx/archive/     # 已完成归档
.cx/docs/        # 自动生成文档
.cx/diagrams/    # 自动生成图表
reference/       # 项目级审查规则、编码规范、评分规则
```

### 14.3 审批建议

小需求：

- 产品负责人审批 Delta Spec。
- 技术负责人审批影响范围。

中大型需求：

- 产品负责人审批需求。
- 技术负责人审批设计。
- 测试负责人审批测试计划。
- 发布负责人审批上线方案。

高风险需求：

- 必须增加回滚方案。
- 必须增加灰度或开关策略。
- 必须执行全量 `/cx-codereview`。
- 必须执行完整回归测试。

---

## 15. 一页版流程速查

```text
新项目需求不明确：
/cx-init → /cx-brainstorm → 审批 → /cx-work → /cx-codereview → /cx-verify → /cx-test → /cx-finish

新项目已有设计：
/cx-init → /cx-spec new → 填充 design.md/tasks.md → 审批 → /cx-work → /cx-codereview → /cx-verify → /cx-test → /cx-finish

已有项目新增/修改需求：
/cx-status → /cx-spec new --delta → 审批 → /cx-work → /cx-codereview --scope=spec → /cx-verify → /cx-test → /cx-spec archive → /cx-finish

已有项目修 Bug：
/cx-debug → 根因分析 → /cx-spec new --delta → 失败测试 → /cx-work → /cx-test → /cx-codereview → /cx-verify → /cx-finish

专项测试：
/cx-test --type=all → 执行测试 → /cx-feedback → /cx-debug 或 /cx-work → 回归验证
```

---

*本文档可作为企业内部《CX-Aicode 插件用户标准操作流程》基础版本。实际落地时，建议为每个技术栈补充项目自己的构建命令、测试命令、代码规范、分支策略和发布审批规则。*
