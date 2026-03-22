#!/bin/bash

# CX Claude Code - Pre-commit Hook
# 功能: 提交前运行基础检查

echo "=== Pre-commit 检查 ==="

# 错误计数
ERRORS=0

# 1. 检查 JSON 文件语法
echo "检查 JSON 文件语法..."
for json_file in $(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep '\.json$' || true); do
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
for file in $(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true); do
    if [ -f "$file" ]; then
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
        if [ "$size" -gt "$MAX_SIZE" ]; then
            echo "⚠️  大文件: $file ($((size / 1024))KB)"
        fi
    fi
done

# 3. 检查行长度 (C++/VB.NET/JAVA)
echo ""
echo "检查代码行长度..."
MAX_LINE_LENGTH=120
for file in $(git diff --cached --name-only --diff-filter=ACM 2>/dev/null | grep -E '\.(cpp|vb|java)$' || true); do
    if [ -f "$file" ]; then
        long_lines=$(awk "length > $MAX_LINE_LENGTH" "$file" 2>/dev/null | wc -l || echo 0)
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
