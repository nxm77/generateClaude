# CX Claude Code Hooks 和文档模板实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标:** 配置 Git Hooks (session-start, pre-commit, pre-push) 和创建 PUML/文档模板

**架构:** Hooks 自动触发工作流；模板提供文档生成的标准格式

**技术栈:** Shell Script, Python, PlantUML (Markdown)

**环境要求:**
- Windows 11 + Git Bash (用于执行 Bash 脚本)
- 或 WSL (Windows Subsystem for Linux)
- Python 3.x (用于 JSON 验证)

---

## 文件结构

```
D:\cx\.claude\
├── hooks\
│   ├── session-start\
│   │   └── catchup-context.sh      # 会话开始时恢复上下文
│   ├── pre-commit\
│   │   └── run-checks.sh           # 提交前检查
│   └── pre-push\
│       └── run-tests.sh            # 推送前运行测试
│
└── templates\
    ├── puml\
    │   ├── flow.puml               # 流程图模板
    │   ├── sequence.puml           # 时序图模板
    │   ├── component.puml          # 组件图模板
    │   ├── state.puml              # 状态图模板
    │   └── class.puml              # 类图模板
    │
    └── docs\
        ├── requirements-analysis.md # 需求分析模板
        └── file-description.md     # 文件说明模板
```

---

## Task 1: 配置 session-start Hook

**Files:**
- Create: `D:\cx\.claude\hooks\session-start\catchup-context.sh`

- [ ] **Step 1: 创建 hooks 目录**

```bash
mkdir -p D:\cx\.claude\hooks\session-start
```

- [ ] **Step 2: 创建会话恢复脚本**

```bash
cat > D:\cx\.claude\hooks\session-start\catchup-context.sh << 'EOF'
#!/bin/bash

# CX Claude Code - Session Start Hook
# 功能: 恢复上次会话的上下文

PROJECT_ROOT="$(pwd)"
PLAN_FILE="$PROJECT_ROOT/task_plan.md"
FINDINGS_FILE="$PROJECT_ROOT/findings.md"
PROGRESS_FILE="$PROJECT_ROOT/progress.md"

echo "=== CX Claude Code - 上下文恢复 ==="
echo ""

# 1. 检查三文件系统
if [ -f "$PLAN_FILE" ]; then
    echo "📋 任务计划: $PLAN_FILE"
    echo "当前阶段:"
    grep -A 2 "^## Phase" "$PLAN_FILE" | grep "状态:" | head -3
    echo ""
else
    echo "⚠️  未找到 task_plan.md"
fi

if [ -f "$FINDINGS_FILE" ]; then
    echo "📚 研究发现: $FINDINGS_FILE"
    echo "最新发现:"
    tail -5 "$FINDINGS_FILE"
    echo ""
else
    echo "⚠️  未找到 findings.md"
fi

if [ -f "$PROGRESS_FILE" ]; then
    echo "📈 进度记录: $PROGRESS_FILE"
    echo "上次活动:"
    tail -10 "$PROGRESS_FILE" | head -5
    echo ""
else
    echo "⚠️  未找到 progress.md"
fi

# 2. 检查代码变更
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "📝 代码变更:"
    git diff --stat 2>/dev/null | head -5
    echo ""
fi

# 3. 提示下一步
echo "=== 恢复完成 ==="
echo ""
echo "建议操作:"
if [ -f "$PLAN_FILE" ]; then
    echo "  - 查看 task_plan.md 了解当前任务"
fi
if [ -f "$FINDINGS_FILE" ]; then
    echo "  - 查看 findings.md 了解研究发现"
fi
if [ -f "$PROGRESS_FILE" ]; then
    echo "  - 查看 progress.md 了解上次进度"
fi

echo ""
EOF

chmod +x D:\cx\.claude\hooks\session-start\catchup-context.sh
```

- [ ] **Step 3: 验证脚本**

```bash
ls -la D:\cx\.claude\hooks\session-start/
```

Expected: 显示 catchup-context.sh 且可执行

- [ ] **Step 4: 提交**

```bash
git add .claude/hooks/session-start/
git commit -m "feat: add session-start hook for context recovery"
```

---

## Task 2: 配置 pre-commit Hook

**Files:**
- Create: `D:\cx\.claude\hooks\pre-commit\run-checks.sh`

- [ ] **Step 1: 创建 pre-commit 目录**

```bash
mkdir -p D:\cx\.claude\hooks\pre-commit
```

- [ ] **Step 2: 创建提交前检查脚本**

```bash
cat > D:\cx\.claude\hooks\pre-commit\run-checks.sh << 'EOF'
#!/bin/bash

# CX Claude Code - Pre-commit Hook
# 功能: 提交前运行基础检查

echo "=== Pre-commit 检查 ==="

# 错误计数
ERRORS=0

# 1. 检查 JSON 文件语法
echo "检查 JSON 文件语法..."
for json_file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.json$'); do
    if [ -f "$json_file" ]; then
        if ! python -m json.tool "$json_file" > /dev/null 2>&1; then
            echo "❌ JSON 语法错误: $json_file"
            ERRORS=$((ERRORS + 1))
        else
            echo "✅ $json_file"
        fi
    fi
done

# 2. 检查大文件
echo ""
echo "检查大文件..."
MAX_SIZE=$((1000 * 1024))  # 1MB
for file in $(git diff --cached --name-only --diff-filter=ACM); do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        if [ "$size" -gt "$MAX_SIZE" ]; then
            echo "⚠️  大文件: $file ($((size / 1024))KB)"
        fi
    fi
done

# 3. 检查行长度 (C++/VB.NET/JAVA)
echo ""
echo "检查代码行长度..."
MAX_LINE_LENGTH=120
for file in $(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(cpp|vb|java)$'); do
    if [ -f "$file" ]; then
        long_lines=$(awk "length > $MAX_LINE_LENGTH" "$file" | wc -l)
        if [ "$long_lines" -gt 0 ]; then
            echo "⚠️  $file: $long_lines 行超过 $MAX_LINE_LENGTH 字符"
        fi
    fi
done

# 结果
echo ""
if [ $ERRORS -gt 0 ]; then
    echo "❌ 发现 $ERRORS 个错误，提交中止"
    exit 1
else
    echo "✅ Pre-commit 检查通过"
    exit 0
fi
EOF

chmod +x D:\cx\.claude\hooks\pre-commit\run-checks.sh
```

- [ ] **Step 3: 提交**

```bash
git add .claude/hooks/pre-commit/
git commit -m "feat: add pre-commit hook for basic checks"
```

---

## Task 3: 配置 pre-push Hook

**Files:**
- Create: `D:\cx\.claude\hooks\pre-push\run-tests.sh`

- [ ] **Step 1: 创建 pre-push 目录**

```bash
mkdir -p D:\cx\.claude\hooks\pre-push
```

- [ ] **Step 2: 创建推送前测试脚本**

```bash
cat > D:\cx\.claude\hooks\pre-push\run-tests.sh << 'EOF'
#!/bin/bash

# CX Claude Code - Pre-push Hook
# 功能: 推送前运行测试

echo "=== Pre-push 检查 ==="

# 检查是否有测试
if [ -f "pom.xml" ]; then
    echo "检测到 Maven 项目，运行测试..."
    mvn test
    if [ $? -ne 0 ]; then
        echo "❌ Maven 测试失败"
        exit 1
    fi
elif [ -f "package.json" ]; then
    echo "检测到 Node.js 项目，运行测试..."
    npm test
    if [ $? -ne 0 ]; then
        echo "❌ npm 测试失败"
        exit 1
    fi
elif [ -f "Makefile" ]; then
    echo "检测到 Makefile，运行 make test..."
    make test
    if [ $? -ne 0 ]; then
        echo "❌ make test 失败"
        exit 1
    fi
else
    echo "⚠️  未检测到测试配置，跳过测试"
fi

echo "✅ Pre-push 检查通过"
exit 0
EOF

chmod +x D:\cx\.claude\hooks\pre-push\run-tests.sh
```

- [ ] **Step 3: 提交**

```bash
git add .claude/hooks/pre-push/
git commit -m "feat: add pre-push hook for test execution"
```

---

## Task 4: 创建 PUML 流程图模板

**Files:**
- Create: `D:\cx\.claude\templates\puml\flow.puml`

- [ ] **Step 1: 创建 PUML 模板目录**

```bash
mkdir -p D:\cx\.claude\templates\puml
```

- [ ] **Step 2: 创建流程图模板**

```bash
cat > D:\cx\.claude\templates\puml\flow.puml << 'EOF'
@startuml {{NAME}}

title {{TITLE}}

start

:{{START_ACTION}};

if ({{CONDITION}}) then (yes)
  :{{THEN_ACTION}};
else (no)
  :{{ELSE_ACTION}};
endif

:{{END_ACTION}};

stop

@enduml
EOF
```

- [ ] **Step 3: 创建时序图模板**

```bash
cat > D:\cx\.claude\templates\puml\sequence.puml << 'EOF'
@startuml {{NAME}}

title {{TITLE}}

actor {{ACTOR1}} as User
participant {{PARTICIPANT1}} as System1
participant {{PARTICIPANT2}} as System2
database {{DATABASE}} as DB

User -> System1: {{REQUEST1}}
activate System1

System1 -> System2: {{REQUEST2}}
activate System2

System2 -> DB: {{QUERY}}
activate DB
DB --> System2: {{RESPONSE}}
deactivate DB

System2 --> System1: {{RESPONSE2}}
deactivate System2

System1 --> User: {{RESPONSE1}}
deactivate System1

@enduml
EOF
```

- [ ] **Step 4: 创建组件图模板**

```bash
cat > D:\cx\.claude\templates\puml\component.puml << 'EOF'
@startuml {{NAME}}

title {{TITLE}}

package "{{PACKAGE1}}" {
  [{{COMPONENT1}}]
  [{{COMPONENT2}}]
}

package "{{PACKAGE2}}" {
  [{{COMPONENT3}}]
  [{{COMPONENT4}}]
}

database "{{DATABASE}}" {
  [{{DATA_STORE}}]
}

[{{COMPONENT1}}] --> [{{COMPONENT3}}] : {{RELATION1}}
[{{COMPONENT2}}] --> [{{DATA_STORE}}] : {{RELATION2}}

@enduml
EOF
```

- [ ] **Step 5: 创建状态图模板**

```bash
cat > D:\cx\.claude\templates\puml\state.puml << 'EOF'
@startuml {{NAME}}

title {{TITLE}}

[*] --> {{STATE1}} : {{TRANSITION1}}

{{STATE1}} --> {{STATE2}} : {{TRANSITION2}}
{{STATE1}} --> {{STATE3}} : {{TRANSITION3}}

{{STATE2}} --> {{STATE4}} : {{TRANSITION4}}
{{STATE3}} --> {{STATE4}} : {{TRANSITION5}}

{{STATE4}} --> [*] : {{TRANSITION6}}

@enduml
EOF
```

- [ ] **Step 6: 创建类图模板**

```bash
cat > D:\cx\.claude\templates\puml\class.puml << 'EOF'
@startuml {{NAME}}

title {{TITLE}}

class {{CLASS1}} {
  -{{FIELD1}} : {{TYPE1}}
  -{{FIELD2}} : {{TYPE2}}
  +{{METHOD1}}({{PARAMS}}) : {{RETURN_TYPE}}
  +{{METHOD2}}({{PARAMS}}) : {{RETURN_TYPE}}
}

class {{CLASS2}} {
  -{{FIELD3}} : {{TYPE3}}
  +{{METHOD3}}({{PARAMS}}) : {{RETURN_TYPE}}
}

interface {{INTERFACE1}} {
  +{{METHOD4}}({{PARAMS}}) : {{RETURN_TYPE}}
}

{{CLASS1}} ..|> {{INTERFACE1}} : implements
{{CLASS2}} --> {{CLASS1}} : uses

@enduml
EOF
```

- [ ] **Step 7: 验证文件创建**

```bash
ls -la D:\cx\.claude\templates\puml/
```

Expected: 显示 flow.puml, sequence.puml, component.puml, state.puml, class.puml

- [ ] **Step 8: 提交**

```bash
git add .claude/templates/puml/
git commit -m "feat: add PUML diagram templates (flow, sequence, component, state, class)"
```

---

## Task 5: 创建文档模板

**Files:**
- Create: `D:\cx\.claude\templates\docs\requirements-analysis.md`
- Create: `D:\cx\.claude\templates\docs\file-description.md`

- [ ] **Step 1: 创建文档模板目录**

```bash
mkdir -p D:\cx\.claude\templates\docs
```

- [ ] **Step 2: 创建需求分析模板**

```bash
cat > D:\cx\.claude\templates\docs\requirements-analysis.md << 'EOF'
# {{FEATURE_NAME}} 需求分析

> **项目:** {{PROJECT_NAME}}
> **日期:** {{DATE}}
> **作者:** {{AUTHOR}}

---

## 背景说明

{{BACKGROUND}}

---

## 功能需求

### 用户故事

{{USER_STORY}}

### 验收标准

- [ ] {{CRITERION_1}}
- [ ] {{CRITERION_2}}
- [ ] {{CRITERION_3}}

---

## 技术需求

### 性能要求

- {{PERFORMANCE_1}}
- {{PERFORMANCE_2}}

### 安全要求

- {{SECURITY_1}}
- {{SECURITY_2}}

---

## 依赖项

| 依赖 | 类型 | 说明 |
|------|------|------|
| {{DEPENDENCY_1}} | 内部/外部 | {{DESCRIPTION}} |
| {{DEPENDENCY_2}} | 内部/外部 | {{DESCRIPTION}} |

---

## 风险评估

| 风险 | 可能性 | 影响 | 缓解措施 |
|------|--------|------|---------|
| {{RISK_1}} | 高/中/低 | 高/中/低 | {{MITIGATION}} |

---

## 实施计划

### 阶段划分

1. **阶段 1:** {{PHASE_1_DESCRIPTION}}
2. **阶段 2:** {{PHASE_2_DESCRIPTION}}
3. **阶段 3:** {{PHASE_3_DESCRIPTION}}

---

## 附录

### 参考文档

- {{REFERENCE_1}}
- {{REFERENCE_2}}
EOF
```

- [ ] **Step 3: 创建文件说明模板**

```bash
cat > D:\cx\.claude\templates\docs\file-description.md << 'EOF'
# {{MODULE_NAME}} 文件说明

> **项目:** {{PROJECT_NAME}}
> **更新:** {{DATE}}

---

## 概述

{{MODULE_OVERVIEW}}

---

## 文件结构

```
{{FILE_STRUCTURE_TREE}}
```

---

## 核心文件

### {{FILE_1}}

**路径:** `{{FILE_1_PATH}}`

**功能:** {{FILE_1_FUNCTION}}

**关键类/函数:**
- `{{CLASS_OR_FUNCTION_1}}` - {{DESCRIPTION}}
- `{{CLASS_OR_FUNCTION_2}}` - {{DESCRIPTION}}

**依赖:**
- {{DEPENDENCY_1}}
- {{DEPENDENCY_2}}

---

### {{FILE_2}}

**路径:** `{{FILE_2_PATH}}`

**功能:** {{FILE_2_FUNCTION}}

**关键类/函数:**
- `{{CLASS_OR_FUNCTION_3}}` - {{DESCRIPTION}}

**依赖:**
- {{DEPENDENCY_3}}

---

## 数据流

```
{{DATA_FLOW_DIAGRAM}}
```

---

## 配置文件

### {{CONFIG_FILE_1}}

**路径:** `{{CONFIG_FILE_1_PATH}}`

**关键配置:**
| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| {{CONFIG_KEY_1}} | {{DESCRIPTION}} | {{DEFAULT_VALUE}} |
| {{CONFIG_KEY_2}} | {{DESCRIPTION}} | {{DEFAULT_VALUE}} |

---

## 相关文档

- [需求分析](../requirements/{{FEATURE_NAME}}.md)
- [API 文档](../api/{{MODULE_NAME}}.md)
EOF
```

- [ ] **Step 4: 验证文件创建**

```bash
ls -la D:\cx\.claude\templates\docs/
```

Expected: 显示 requirements-analysis.md, file-description.md

- [ ] **Step 5: 提交**

```bash
git add .claude/templates/docs/
git commit -m "feat: add documentation templates (requirements, file description)"
```

---

## Task 6: 创建会话规划模板

**Files:**
- Create: `D:\cx\.claude\templates\session-planning.md`

- [ ] **Step 1: 创建会话规划模板**

```bash
cat > D:\cx\.claude\templates\session-planning.md << 'EOF'
# 会话规划 - {{SESSION_TITLE}}

> **日期:** {{DATE}}
> **预计时长:** {{DURATION}}

---

## 会话目标

{{SESSION_GOALS}}

---

## 前置条件

- [ ] {{PREREQUISITE_1}}
- [ ] {{PREREQUISITE_2}}

---

## 任务分解

### 任务 1: {{TASK_1_TITLE}}

**描述:** {{TASK_1_DESCRIPTION}}

**步骤:**
1. {{STEP_1}}
2. {{STEP_2}}
3. {{STEP_3}}

**预计时间:** {{ESTIMATED_TIME}}

**完成标准:**
- [ ] {{COMPLETION_CRITERION_1}}
- [ ] {{COMPLETION_CRITERION_2}}

---

### 任务 2: {{TASK_2_TITLE}}

**描述:** {{TASK_2_DESCRIPTION}}

**步骤:**
1. {{STEP_1}}
2. {{STEP_2}}

**预计时间:** {{ESTIMATED_TIME}}

**完成标准:**
- [ ] {{COMPLETION_CRITERION_1}}

---

## 需要的上下文

- {{CONTEXT_NEEDED_1}}
- {{CONTEXT_NEEDED_2}}

---

## 风险与问题

| 风险 | 缓解措施 |
|------|---------|
| {{RISK_1}} | {{MITIGATION_1}} |
| {{RISK_2}} | {{MITIGATION_2}} |

---

## 会话后总结

### 完成情况

- [x] {{COMPLETED_1}}
- [x] {{COMPLETED_2}}
- [ ] {{INCOMPLETE_1}}

### 遗留问题

{{OUTSTANDING_ISSUES}}

### 下次计划

{{NEXT_SESSION_PLAN}}
EOF
```

- [ ] **Step 2: 验证文件创建**

```bash
ls -la D:\cx\.claude\templates/session-planning.md
```

Expected: 显示 session-planning.md

- [ ] **Step 3: 提交**

```bash
git add .claude/templates/session-planning.md
git commit -m "feat: add session planning template"
```

---

## Task 7: 更新 settings.json 配置 Hooks 路径

**Files:**
- Modify: `D:\cx\.claude\settings.json`

- [ ] **Step 1: 读取当前 settings.json**

```bash
cat D:\cx\.claude\settings.json
```

- [ ] **Step 2: 验证 hooks 配置已存在**

检查 settings.json 中是否已包含以下配置（应在 Phase 1 创建）：

```json
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
  }
```

- [ ] **Step 3: 如需更新，添加自定义 session-start hook**

如果要使用自定义的 session-start hook 而非 planning-with-files 的默认脚本：

```bash
# 备份原配置
cp D:\cx\.claude\settings.json D:\cx\.claude\settings.json.bak

# 更新配置（手动编辑或使用 jq）
# 将 session-start 改为:
# "session-start": [".claude/hooks/session-start/catchup-context.sh"]
```

- [ ] **Step 4: 验证 JSON 语法**

```bash
python -m json.tool D:\cx\.claude\settings.json > nul && echo "JSON valid"
```

Expected: "JSON valid"

- [ ] **Step 5: 提交**

```bash
git add .claude/settings.json
git commit -m "chore: update settings.json with hooks configuration"
```

---

## 完成 Phase 3

### 更新 planning 文件

- [ ] **更新 task_plan.md**

```bash
# 标记 Phase 3 所有任务完成
```

- [ ] **更新 progress.md**

```bash
# 记录 Phase 3 完成情况
```

---

## 最终验证

### 完整性检查

- [ ] 所有 Hooks 已创建并可执行
- [ ] 所有 PUML 模板已创建
- [ ] 所有文档模板已创建
- [ ] settings.json 已配置 Hooks 路径
- [ ] planning-with-files 三文件系统已更新

### 功能测试

```bash
# 1. 测试 session-start hook
.claude/hooks/session-start/catchup-context.sh

# 2. 测试 pre-commit hook
.claude/hooks/pre-commit/run-checks.sh

# 3. 测试 pre-push hook
.claude/hooks/pre-push/run-tests.sh

# 4. 验证模板文件
ls -la .claude/templates/puml/
ls -la .claude/templates/docs/
```

---

## 项目完成总结

### 所有阶段完成情况

| 阶段 | 名称 | 状态 |
|------|------|------|
| Phase 1 | 基础配置 | ✅ 完成 |
| Phase 2 | Skills 和 Commands | ✅ 完成 |
| Phase 3 | Hooks 和文档模板 | ✅ 完成 |

### 交付物清单

**Phase 1 - 基础配置:**
- [x] .claude/ 目录结构
- [x] settings.json 配置
- [x] CLAUDE.md 主文档
- [x] 项目级 CLAUDE.md 模板
- [x] planning-with-files 三文件系统
- [x] MES/EAP 技术知识库
- [x] 文件索引模板

**Phase 2 - Skills 和 Commands:**
- [x] MES Skill (SKILL.md + 4 个文档)
- [x] EAP Skill (SKILL.md + 5 个文档)
- [x] CPP/VBNET/JAVA/VUE Skills
- [x] Commands 文档说明

**Phase 3 - Hooks 和文档模板:**
- [x] session-start hook
- [x] pre-commit hook
- [x] pre-push hook
- [x] PUML 图表模板 (5 个)
- [x] 文档模板 (3 个)

---

**计划版本:** v1.0
**创建日期:** 2025-03-22
**总预计耗时:** 16-20 小时 (3 个阶段)

**状态:** 🎉 所有阶段完成！
