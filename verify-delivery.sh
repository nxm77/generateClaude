#!/bin/bash

# 项目交付验证脚本
# 用途：验证所有交付文件是否完整

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# 检查文件是否存在
check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        local size=$(wc -l < "$file" 2>/dev/null || echo "N/A")
        print_success "$description ($size 行)"
        return 0
    else
        print_error "$description - 文件不存在"
        return 1
    fi
}

# 主验证流程
main() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   项目交付验证脚本                    ║"
    echo "║   Delivery Verification Script         ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}\n"

    local total=0
    local passed=0

    print_header "1. 核心脚本文件"

    total=$((total + 1))
    check_file "generate-docs-smart.sh" "智能文档生成脚本" && passed=$((passed + 1))

    total=$((total + 1))
    check_file "test-smart-generator.sh" "自动化测试脚本" && passed=$((passed + 1))

    print_header "2. Skill 文件"

    total=$((total + 1))
    check_file ".claude/skills/project-deep-analyzer.md" "深度分析 Skill" && passed=$((passed + 1))

    total=$((total + 1))
    check_file ".claude/skills/examples/analysis-report-example.json" "分析报告示例" && passed=$((passed + 1))

    print_header "3. 文档文件"

    total=$((total + 1))
    check_file "COMPLETE-DELIVERY.md" "完整交付文档" && passed=$((passed + 1))

    total=$((total + 1))
    check_file "README-generate-docs.md" "使用指南" && passed=$((passed + 1))

    total=$((total + 1))
    check_file "SUMMARY-smart-generator.md" "改造总结" && passed=$((passed + 1))

    total=$((total + 1))
    check_file "QUICK-REFERENCE.md" "快速参考" && passed=$((passed + 1))

    total=$((total + 1))
    check_file "PROJECT-COMPLETION.md" "项目完成总结" && passed=$((passed + 1))

    print_header "4. 旧版文件（参考）"

    total=$((total + 1))
    check_file "generate-docs.sh" "原始版本脚本" && passed=$((passed + 1))

    print_header "5. 验证脚本权限"

    total=$((total + 1))
    if [ -x "generate-docs-smart.sh" ]; then
        print_success "generate-docs-smart.sh 有执行权限"
        passed=$((passed + 1))
    else
        print_error "generate-docs-smart.sh 没有执行权限"
        print_info "运行: chmod +x generate-docs-smart.sh"
    fi

    total=$((total + 1))
    if [ -x "test-smart-generator.sh" ]; then
        print_success "test-smart-generator.sh 有执行权限"
        passed=$((passed + 1))
    else
        print_error "test-smart-generator.sh 没有执行权限"
        print_info "运行: chmod +x test-smart-generator.sh"
    fi

    print_header "6. 验证脚本语法"

    total=$((total + 1))
    if bash -n generate-docs-smart.sh 2>/dev/null; then
        print_success "generate-docs-smart.sh 语法正确"
        passed=$((passed + 1))
    else
        print_error "generate-docs-smart.sh 语法错误"
    fi

    total=$((total + 1))
    if bash -n test-smart-generator.sh 2>/dev/null; then
        print_success "test-smart-generator.sh 语法正确"
        passed=$((passed + 1))
    else
        print_error "test-smart-generator.sh 语法错误"
    fi

    print_header "7. 检查依赖工具"

    print_info "必需工具:"
    if command -v bash >/dev/null 2>&1; then
        print_success "bash - $(bash --version | head -1)"
    else
        print_error "bash - 未安装"
    fi

    print_info "可选工具:"
    if command -v tree >/dev/null 2>&1; then
        print_success "tree - $(tree --version | head -1)"
    else
        print_error "tree - 未安装（可选）"
    fi

    if command -v jq >/dev/null 2>&1; then
        print_success "jq - $(jq --version)"
    else
        print_error "jq - 未安装（可选，深度分析需要）"
    fi

    if command -v claude >/dev/null 2>&1; then
        print_success "claude - 已安装"
    else
        print_error "claude - 未安装（深度分析需要）"
    fi

    print_header "验证结果"

    echo -e "${CYAN}总计:${NC} $total 项"
    echo -e "${GREEN}通过:${NC} $passed 项"
    echo -e "${RED}失败:${NC} $((total - passed)) 项"

    local percentage=$((passed * 100 / total))
    echo -e "${CYAN}完成度:${NC} $percentage%"

    if [ $passed -eq $total ]; then
        echo -e "\n${GREEN}========================================${NC}"
        echo -e "${GREEN}✓ 所有验证通过！项目交付完整！${NC}"
        echo -e "${GREEN}========================================${NC}\n"
        return 0
    else
        echo -e "\n${YELLOW}========================================${NC}"
        echo -e "${YELLOW}⚠ 部分验证失败，请检查缺失的文件${NC}"
        echo -e "${YELLOW}========================================${NC}\n"
        return 1
    fi
}

# 执行验证
main
