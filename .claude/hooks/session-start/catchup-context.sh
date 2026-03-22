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
