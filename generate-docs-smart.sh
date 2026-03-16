#!/bin/bash

# 智能三阶段文档生成脚本（支持深度分析）
# 用途：自动分析项目并生成定制化文档
# 作者：自动生成
# 日期：2026-03-17
# 使用方法：
#   ./generate-docs-smart.sh              - 在当前目录分析并生成文档（基础模式）
#   ./generate-docs-smart.sh --deep       - 在当前目录深度分析并生成文档
#   ./generate-docs-smart.sh /path/to/dir - 在指定目录分析并生成文档
#   ./generate-docs-smart.sh --deep /path/to/dir - 在指定目录深度分析

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 获取目标目录和模式
DEEP_ANALYSIS=false
PROJECT_DIR=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --deep)
            DEEP_ANALYSIS=true
            shift
            ;;
        *)
            if [ -z "$PROJECT_DIR" ]; then
                PROJECT_DIR="$1"
            fi
            shift
            ;;
    esac
done

# 如果没有指定目录，使用当前目录
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR="$(pwd)"
fi

# 全局变量存储分析结果
PROJECT_NAME=""
PROJECT_TYPE=""
TECH_STACK=""
LANGUAGES=""
FRAMEWORKS=""
DATABASES=""
HAS_FRONTEND=false
HAS_BACKEND=false
HAS_DATABASE=false
HAS_API=false
HAS_TESTS=false
DIRECTORY_STRUCTURE=""
FILE_LIST=""
MAIN_FILES=""

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_stage() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

print_analysis() {
    echo -e "${MAGENTA}[ANALYSIS]${NC} $1"
}

# 检查目录是否存在
check_directory() {
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    print_success "项目目录检查通过: $PROJECT_DIR"
}

# 阶段 0：智能分析项目
stage0_analyze_project() {
    print_stage "阶段 0：智能分析项目"

    cd "$PROJECT_DIR" || exit 1

    # 1. 获取项目名称
    PROJECT_NAME=$(basename "$PROJECT_DIR")
    print_analysis "项目名称: $PROJECT_NAME"

    # 2. 分析编程语言
    analyze_languages

    # 3. 分析技术栈
    analyze_tech_stack

    # 4. 分析项目类型
    analyze_project_type

    # 5. 分析目录结构
    analyze_directory_structure

    # 6. 分析主要文件
    analyze_main_files

    # 7. 生成分析报告
    generate_analysis_report

    sleep 1
}

# 分析编程语言
analyze_languages() {
    print_info "正在分析编程语言..."

    local langs=()

    # JavaScript/TypeScript
    if [ -f "package.json" ] || find . -maxdepth 3 -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" 2>/dev/null | grep -q .; then
        langs+=("JavaScript/TypeScript")
    fi

    # Python
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || find . -maxdepth 3 -name "*.py" 2>/dev/null | grep -q .; then
        langs+=("Python")
    fi

    # Java
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || find . -maxdepth 3 -name "*.java" 2>/dev/null | grep -q .; then
        langs+=("Java")
    fi

    # Go
    if [ -f "go.mod" ] || find . -maxdepth 3 -name "*.go" 2>/dev/null | grep -q .; then
        langs+=("Go")
    fi

    # C/C++
    if find . -maxdepth 3 -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" 2>/dev/null | grep -q .; then
        langs+=("C/C++")
    fi

    # Rust
    if [ -f "Cargo.toml" ] || find . -maxdepth 3 -name "*.rs" 2>/dev/null | grep -q .; then
        langs+=("Rust")
    fi

    # PHP
    if find . -maxdepth 3 -name "*.php" 2>/dev/null | grep -q .; then
        langs+=("PHP")
    fi

    # Ruby
    if [ -f "Gemfile" ] || find . -maxdepth 3 -name "*.rb" 2>/dev/null | grep -q .; then
        langs+=("Ruby")
    fi

    if [ ${#langs[@]} -eq 0 ]; then
        LANGUAGES="未检测到"
    else
        LANGUAGES=$(IFS=", "; echo "${langs[*]}")
    fi

    print_analysis "检测到的语言: $LANGUAGES"
}

# 分析技术栈
analyze_tech_stack() {
    print_info "正在分析技术栈..."

    local frameworks=()
    local databases=()

    # 前端框架
    if [ -f "package.json" ]; then
        if grep -q "react" package.json; then
            frameworks+=("React")
            HAS_FRONTEND=true
        fi
        if grep -q "vue" package.json; then
            frameworks+=("Vue")
            HAS_FRONTEND=true
        fi
        if grep -q "angular" package.json; then
            frameworks+=("Angular")
            HAS_FRONTEND=true
        fi
        if grep -q "next" package.json; then
            frameworks+=("Next.js")
            HAS_FRONTEND=true
            HAS_BACKEND=true
        fi
        if grep -q "express" package.json; then
            frameworks+=("Express")
            HAS_BACKEND=true
            HAS_API=true
        fi
        if grep -q "nest" package.json; then
            frameworks+=("NestJS")
            HAS_BACKEND=true
            HAS_API=true
        fi
    fi

    # Python 框架
    if [ -f "requirements.txt" ]; then
        if grep -qi "django" requirements.txt; then
            frameworks+=("Django")
            HAS_BACKEND=true
            HAS_API=true
        fi
        if grep -qi "flask" requirements.txt; then
            frameworks+=("Flask")
            HAS_BACKEND=true
            HAS_API=true
        fi
        if grep -qi "fastapi" requirements.txt; then
            frameworks+=("FastAPI")
            HAS_BACKEND=true
            HAS_API=true
        fi
    fi

    # Java 框架
    if [ -f "pom.xml" ]; then
        if grep -q "spring-boot" pom.xml; then
            frameworks+=("Spring Boot")
            HAS_BACKEND=true
            HAS_API=true
        fi
    fi

    # 数据库
    if [ -f "package.json" ]; then
        if grep -q "mysql" package.json || grep -q "mysql2" package.json; then
            databases+=("MySQL")
            HAS_DATABASE=true
        fi
        if grep -q "pg" package.json || grep -q "postgres" package.json; then
            databases+=("PostgreSQL")
            HAS_DATABASE=true
        fi
        if grep -q "mongodb" package.json || grep -q "mongoose" package.json; then
            databases+=("MongoDB")
            HAS_DATABASE=true
        fi
        if grep -q "redis" package.json; then
            databases+=("Redis")
        fi
        if grep -q "sqlite" package.json; then
            databases+=("SQLite")
            HAS_DATABASE=true
        fi
    fi

    if [ -f "requirements.txt" ]; then
        if grep -qi "mysql" requirements.txt || grep -qi "pymysql" requirements.txt; then
            databases+=("MySQL")
            HAS_DATABASE=true
        fi
        if grep -qi "psycopg" requirements.txt || grep -qi "postgresql" requirements.txt; then
            databases+=("PostgreSQL")
            HAS_DATABASE=true
        fi
        if grep -qi "pymongo" requirements.txt; then
            databases+=("MongoDB")
            HAS_DATABASE=true
        fi
        if grep -qi "redis" requirements.txt; then
            databases+=("Redis")
        fi
    fi

    # 检测测试框架
    if [ -f "package.json" ]; then
        if grep -q "jest\|mocha\|vitest\|playwright\|cypress" package.json; then
            HAS_TESTS=true
        fi
    fi

    if [ -f "requirements.txt" ]; then
        if grep -qi "pytest\|unittest" requirements.txt; then
            HAS_TESTS=true
        fi
    fi

    if [ ${#frameworks[@]} -eq 0 ]; then
        FRAMEWORKS="未检测到"
    else
        FRAMEWORKS=$(IFS=", "; echo "${frameworks[*]}")
    fi

    if [ ${#databases[@]} -eq 0 ]; then
        DATABASES="未检测到"
    else
        DATABASES=$(IFS=", "; echo "${databases[*]}")
    fi

    print_analysis "检测到的框架: $FRAMEWORKS"
    print_analysis "检测到的数据库: $DATABASES"
}

# 分析项目类型
analyze_project_type() {
    print_info "正在分析项目类型..."

    if [ "$HAS_FRONTEND" = true ] && [ "$HAS_BACKEND" = true ]; then
        PROJECT_TYPE="全栈 Web 应用"
    elif [ "$HAS_FRONTEND" = true ]; then
        PROJECT_TYPE="前端应用"
    elif [ "$HAS_BACKEND" = true ]; then
        PROJECT_TYPE="后端服务"
    elif [ "$HAS_API" = true ]; then
        PROJECT_TYPE="API 服务"
    elif [ -f "package.json" ] && grep -q "electron" package.json; then
        PROJECT_TYPE="桌面应用"
    elif [ -f "package.json" ] && grep -q "react-native" package.json; then
        PROJECT_TYPE="移动应用"
    elif find . -maxdepth 2 -name "*.py" | head -1 | xargs grep -l "if __name__" >/dev/null 2>&1; then
        PROJECT_TYPE="Python 脚本/工具"
    else
        PROJECT_TYPE="通用软件项目"
    fi

    print_analysis "项目类型: $PROJECT_TYPE"
}

# 分析目录结构
analyze_directory_structure() {
    print_info "正在分析目录结构..."

    # 生成目录树（排除常见的无关目录）
    DIRECTORY_STRUCTURE=$(tree -L 3 -I 'node_modules|__pycache__|.git|dist|build|target|venv|env|.venv' -d "$PROJECT_DIR" 2>/dev/null || find "$PROJECT_DIR" -maxdepth 3 -type d ! -path "*/node_modules/*" ! -path "*/__pycache__/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" 2>/dev/null | head -50)

    print_analysis "目录结构已分析（前 50 个目录）"
}

# 分析主要文件
analyze_main_files() {
    print_info "正在分析主要文件..."

    local files=()

    # 配置文件
    [ -f "package.json" ] && files+=("package.json")
    [ -f "requirements.txt" ] && files+=("requirements.txt")
    [ -f "pom.xml" ] && files+=("pom.xml")
    [ -f "build.gradle" ] && files+=("build.gradle")
    [ -f "go.mod" ] && files+=("go.mod")
    [ -f "Cargo.toml" ] && files+=("Cargo.toml")
    [ -f "composer.json" ] && files+=("composer.json")
    [ -f "Gemfile" ] && files+=("Gemfile")

    # 配置文件
    [ -f ".env" ] && files+=(".env")
    [ -f ".env.example" ] && files+=(".env.example")
    [ -f "config.json" ] && files+=("config.json")
    [ -f "tsconfig.json" ] && files+=("tsconfig.json")

    # 文档文件
    [ -f "README.md" ] && files+=("README.md")
    [ -f "CHANGELOG.md" ] && files+=("CHANGELOG.md")
    [ -f "LICENSE" ] && files+=("LICENSE")

    # 入口文件
    [ -f "index.js" ] && files+=("index.js")
    [ -f "index.ts" ] && files+=("index.ts")
    [ -f "main.py" ] && files+=("main.py")
    [ -f "app.py" ] && files+=("app.py")
    [ -f "server.js" ] && files+=("server.js")
    [ -f "main.go" ] && files+=("main.go")

    MAIN_FILES=$(IFS=$'\n'; echo "${files[*]}")

    print_analysis "检测到 ${#files[@]} 个主要文件"
}

# 阶段 0.5：深度代码分析（可选）
stage0_5_deep_analysis() {
    if [ "$DEEP_ANALYSIS" = false ]; then
        print_info "跳过深度分析（使用 --deep 参数启用）"
        return 0
    fi

    print_stage "阶段 0.5：深度代码分析"

    print_info "正在调用 project-deep-analyzer skill 进行深度分析..."
    print_warning "这可能需要几分钟时间，请耐心等待..."

    # 检查 skill 是否存在
    if [ ! -f "$HOME/.claude/skills/project-deep-analyzer.md" ] && [ ! -f ".claude/skills/project-deep-analyzer.md" ]; then
        print_error "找不到 project-deep-analyzer skill"
        print_info "请确保 skill 文件存在于以下位置之一："
        print_info "  - $HOME/.claude/skills/project-deep-analyzer.md"
        print_info "  - .claude/skills/project-deep-analyzer.md"
        print_warning "将继续使用基础分析模式"
        return 1
    fi

    # 调用 Claude Code skill 进行深度分析
    cd "$PROJECT_DIR" || exit 1

    # 创建临时提示文件
    cat > /tmp/deep-analysis-prompt.txt << EOF
请使用 project-deep-analyzer skill 深度分析当前项目（$PROJECT_DIR）。

分析完成后，请将结果保存到 .analysis-report.json 文件中。

项目基本信息：
- 项目名称: $PROJECT_NAME
- 项目类型: $PROJECT_TYPE
- 编程语言: $LANGUAGES
- 框架: $FRAMEWORKS
- 数据库: $DATABASES
EOF

    # 使用 claude -p 调用分析
    print_info "正在执行深度分析..."

    # 检查是否在 Claude Code 环境中
    if command -v claude >/dev/null 2>&1; then
        claude -p "$(cat /tmp/deep-analysis-prompt.txt)" > /tmp/deep-analysis-output.txt 2>&1

        # 检查分析报告是否生成
        if [ -f "$PROJECT_DIR/.analysis-report.json" ]; then
            print_success "深度分析完成，报告已生成"

            # 显示分析统计
            if command -v jq >/dev/null 2>&1; then
                print_info "分析统计："
                echo -e "  API 端点数: $(jq '.statistics.total_endpoints // 0' "$PROJECT_DIR/.analysis-report.json")"
                echo -e "  数据模型数: $(jq '.statistics.total_models // 0' "$PROJECT_DIR/.analysis-report.json")"
                echo -e "  业务流程数: $(jq '.statistics.total_flows // 0' "$PROJECT_DIR/.analysis-report.json")"
                echo -e "  分析文件数: $(jq '.statistics.code_files_analyzed // 0' "$PROJECT_DIR/.analysis-report.json")"
            fi

            # 清理临时文件
            rm -f /tmp/deep-analysis-prompt.txt /tmp/deep-analysis-output.txt

            return 0
        else
            print_warning "深度分析未生成报告文件"
            print_info "分析输出："
            cat /tmp/deep-analysis-output.txt
            print_warning "将继续使用基础分析模式"

            # 清理临时文件
            rm -f /tmp/deep-analysis-prompt.txt /tmp/deep-analysis-output.txt

            return 1
        fi
    else
        print_error "未找到 claude 命令"
        print_info "深度分析需要在 Claude Code 环境中运行"
        print_warning "将继续使用基础分析模式"

        # 清理临时文件
        rm -f /tmp/deep-analysis-prompt.txt

        return 1
    fi
}

# 从深度分析报告中提取信息
extract_from_deep_analysis() {
    local report_file="$PROJECT_DIR/.analysis-report.json"

    if [ ! -f "$report_file" ]; then
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        print_warning "未安装 jq，无法解析深度分析报告"
        return 1
    fi

    print_info "从深度分析报告中提取信息..."

    # 提取 API 端点信息
    API_ENDPOINTS=$(jq -r '.api_endpoints[]? | "\(.method) \(.path) - \(.description)"' "$report_file" 2>/dev/null || echo "")

    # 提取数据模型信息
    DATA_MODELS=$(jq -r '.data_models[]? | "\(.name) (\(.table))"' "$report_file" 2>/dev/null || echo "")

    # 提取业务流程信息
    BUSINESS_FLOWS=$(jq -r '.business_flows[]? | .name' "$report_file" 2>/dev/null || echo "")

    # 提取架构信息
    ARCHITECTURE_PATTERN=$(jq -r '.architecture.pattern // "未知"' "$report_file" 2>/dev/null || echo "未知")

    return 0
}

# 生成分析报告
generate_analysis_report() {
    print_stage "项目分析报告"

    echo -e "${CYAN}项目名称:${NC} $PROJECT_NAME"
    echo -e "${CYAN}项目类型:${NC} $PROJECT_TYPE"
    echo -e "${CYAN}编程语言:${NC} $LANGUAGES"
    echo -e "${CYAN}框架:${NC} $FRAMEWORKS"
    echo -e "${CYAN}数据库:${NC} $DATABASES"
    echo -e "${CYAN}包含前端:${NC} $HAS_FRONTEND"
    echo -e "${CYAN}包含后端:${NC} $HAS_BACKEND"
    echo -e "${CYAN}包含 API:${NC} $HAS_API"
    echo -e "${CYAN}包含测试:${NC} $HAS_TESTS"

    echo -e "\n${CYAN}主要文件:${NC}"
    echo "$MAIN_FILES" | while read -r file; do
        [ -n "$file" ] && echo "  - $file"
    done
}

# 阶段 1：生成框架版 CLAUDE.md
stage1_generate_framework() {
    print_stage "阶段 1：生成框架版 CLAUDE.md"

    print_info "正在创建文档索引框架..."

    cat > "$PROJECT_DIR/CLAUDE.md" << EOF
# $PROJECT_NAME - 项目文档索引

> **项目类型**: $PROJECT_TYPE
> **技术栈**: $LANGUAGES
> **框架**: $FRAMEWORKS

本项目的完整文档结构如下：

## 📋 核心文档

### 1. [需求分析文档](./requirements-analysis.md)
项目需求的详细分析，包括功能需求、非功能需求、用户故事等

### 2. [文件功能列表](./file-functions.md)
项目中所有文件的功能说明和职责划分

## 📊 可视化图表

### 3. [系统功能全图](./system-overview.puml)
使用 PlantUML 绘制的系统整体功能架构图

### 4. [模块流程图](./module-flowchart.puml)
使用 PlantUML 绘制的各模块业务流程图

### 5. [时序图](./sequence-diagram.puml)
使用 PlantUML 绘制的系统交互时序图

---

## 📖 如何使用

- **查看 PlantUML 图表**：使用支持 PlantUML 的工具（如 VS Code + PlantUML 插件）打开 \`.puml\` 文件
- **在线预览**：可以将 \`.puml\` 文件内容复制到 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)

## 🔄 文档状态

- [ ] 需求分析文档 - 待生成
- [ ] 文件功能列表 - 待生成
- [ ] 系统功能全图 - 待生成
- [ ] 模块流程图 - 待生成
- [ ] 时序图 - 待生成

---

*最后更新时间：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "框架版 CLAUDE.md 创建成功"
    else
        print_error "框架版 CLAUDE.md 创建失败"
        exit 1
    fi

    sleep 1
}

# 阶段 2：生成具体文档
stage2_generate_documents() {
    print_stage "阶段 2：生成具体文档"

    # 2.1 生成需求分析文档
    generate_requirements_doc

    # 2.2 生成文件功能列表
    generate_file_functions_doc

    # 2.3 生成系统功能全图
    generate_system_overview_diagram

    # 2.4 生成模块流程图
    generate_module_flowchart

    # 2.5 生成时序图
    generate_sequence_diagram
}

# 生成需求分析文档
generate_requirements_doc() {
    print_info "正在生成需求分析文档..."

    # 根据项目类型生成不同的需求文档
    local functional_requirements=""
    local nonfunctional_requirements=""

    if [ "$HAS_FRONTEND" = true ]; then
        functional_requirements+="
### 2.1 前端功能模块
- 用户界面设计和交互
- 响应式布局适配
- 前端路由管理
- 状态管理
- 组件化开发"
    fi

    if [ "$HAS_BACKEND" = true ]; then
        functional_requirements+="

### 2.2 后端功能模块
- 业务逻辑处理
- 数据持久化
- 服务端渲染（如适用）
- 后台任务处理"
    fi

    if [ "$HAS_API" = true ]; then
        functional_requirements+="

### 2.3 API 接口模块
- RESTful API 设计
- 接口文档和规范
- 请求验证和响应处理
- API 版本管理"
    fi

    if [ "$HAS_DATABASE" = true ]; then
        functional_requirements+="

### 2.4 数据管理模块
- 数据库设计和优化
- 数据迁移和备份
- 数据查询和索引
- 数据安全和加密"
    fi

    if [ "$HAS_TESTS" = true ]; then
        nonfunctional_requirements+="
### 3.4 测试需求
- 单元测试覆盖率 > 80%
- 集成测试覆盖核心流程
- 端到端测试覆盖关键场景
- 持续集成和自动化测试"
    fi

    cat > "$PROJECT_DIR/requirements-analysis.md" << EOF
# $PROJECT_NAME - 需求分析文档

## 1. 项目概述

### 1.1 项目背景
本项目是一个 **$PROJECT_TYPE**，使用 **$LANGUAGES** 开发，基于 **$FRAMEWORKS** 框架构建。

### 1.2 项目目标
- 提供高效、稳定的系统功能
- 确保良好的用户体验
- 保证系统的可扩展性和可维护性
- 满足性能和安全要求

### 1.3 技术栈
- **编程语言**: $LANGUAGES
- **框架**: $FRAMEWORKS
- **数据库**: $DATABASES
- **项目类型**: $PROJECT_TYPE

## 2. 功能需求
$functional_requirements

### 2.5 用户管理模块（如适用）
- 用户注册和登录
- 用户信息管理
- 权限和角色管理
- 会话管理

## 3. 非功能需求

### 3.1 性能需求
- 页面加载时间 < 3秒
- API 响应时间 < 500ms
- 支持并发用户访问
- 数据库查询优化

### 3.2 安全需求
- 数据传输加密（HTTPS）
- 用户认证和授权
- 防护常见 Web 攻击（XSS, CSRF, SQL 注入）
- 敏感数据加密存储

### 3.3 可用性需求
- 系统稳定性 > 99%
- 错误处理和日志记录
- 友好的错误提示
- 完善的文档和帮助
$nonfunctional_requirements

### 3.5 兼容性需求
- 跨浏览器兼容（如适用）
- 移动端适配（如适用）
- 不同操作系统支持
- API 版本兼容

### 3.6 可维护性需求
- 代码规范和注释
- 模块化和组件化设计
- 完善的测试覆盖
- 清晰的项目文档

## 4. 约束条件

### 4.1 技术约束
- 必须使用指定的技术栈
- 遵循框架的最佳实践
- 符合代码规范和标准

### 4.2 时间约束
- 按照项目计划推进
- 关键里程碑按时交付

### 4.3 资源约束
- 开发团队规模
- 服务器和基础设施资源
- 第三方服务依赖

## 5. 验收标准

### 5.1 功能验收
- 所有功能模块正常运行
- 通过功能测试用例
- 满足业务需求

### 5.2 性能验收
- 达到性能指标要求
- 通过压力测试
- 资源使用合理

### 5.3 质量验收
- 代码审查通过
- 测试覆盖率达标
- 无严重 Bug

---

*文档版本：v1.0*
*创建日期：$(date +%Y-%m-%d)*
*最后更新：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "需求分析文档生成成功"
    else
        print_error "需求分析文档生成失败"
        exit 1
    fi

    sleep 1
}

# 生成文件功能列表
generate_file_functions_doc() {
    print_info "正在生成文件功能列表..."

    # 扫描实际的目录结构
    local dir_tree=""
    if command -v tree >/dev/null 2>&1; then
        dir_tree=$(tree -L 3 -I 'node_modules|__pycache__|.git|dist|build|target|venv|env|.venv' "$PROJECT_DIR" 2>/dev/null || echo "目录树生成失败")
    else
        dir_tree=$(find "$PROJECT_DIR" -maxdepth 3 -type d ! -path "*/node_modules/*" ! -path "*/__pycache__/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" 2>/dev/null | head -50 | sed 's|'"$PROJECT_DIR"'|.|g' || echo "目录列表生成失败")
    fi

    cat > "$PROJECT_DIR/file-functions.md" << EOF
# $PROJECT_NAME - 文件功能列表

## 1. 项目结构概览

\`\`\`
$dir_tree
\`\`\`

## 2. 主要文件说明

### 2.1 配置文件
EOF

    # 添加实际存在的配置文件
    if [ -f "$PROJECT_DIR/package.json" ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'

#### `package.json`
- **功能**: Node.js 项目配置文件
- **职责**:
  - 定义项目依赖
  - 配置脚本命令
  - 设置项目元信息
EOF
    fi

    if [ -f "$PROJECT_DIR/requirements.txt" ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'

#### `requirements.txt`
- **功能**: Python 项目依赖文件
- **职责**:
  - 列出 Python 包依赖
  - 指定包版本
  - 便于环境复制
EOF
    fi

    if [ -f "$PROJECT_DIR/pom.xml" ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'

#### `pom.xml`
- **功能**: Maven 项目配置文件
- **职责**:
  - 定义项目依赖
  - 配置构建流程
  - 管理插件
EOF
    fi

    if [ -f "$PROJECT_DIR/go.mod" ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'

#### `go.mod`
- **功能**: Go 模块定义文件
- **职责**:
  - 定义模块路径
  - 声明依赖包
  - 管理版本
EOF
    fi

    # 添加通用的源代码目录说明
    cat >> "$PROJECT_DIR/file-functions.md" << EOF

### 2.2 源代码目录

根据项目实际结构，主要包含以下类型的文件：

EOF

    if [ "$HAS_FRONTEND" = true ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'
#### 前端相关文件
- **组件文件**: 可复用的 UI 组件
- **页面文件**: 完整的页面视图
- **样式文件**: CSS/SCSS/Less 样式定义
- **路由文件**: 前端路由配置
- **状态管理**: Redux/Vuex/Pinia 等状态管理

EOF
    fi

    if [ "$HAS_BACKEND" = true ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'
#### 后端相关文件
- **控制器**: 处理 HTTP 请求
- **服务层**: 业务逻辑实现
- **模型层**: 数据模型定义
- **中间件**: 请求处理中间件
- **工具类**: 通用工具函数

EOF
    fi

    if [ "$HAS_API" = true ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'
#### API 相关文件
- **路由定义**: API 端点配置
- **接口文档**: API 规范说明
- **验证器**: 请求参数验证
- **响应格式**: 统一响应处理

EOF
    fi

    if [ "$HAS_TESTS" = true ]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'
#### 测试相关文件
- **单元测试**: 函数和模块测试
- **集成测试**: 模块间集成测试
- **端到端测试**: 完整流程测试
- **测试配置**: 测试框架配置

EOF
    fi

    cat >> "$PROJECT_DIR/file-functions.md" << EOF

## 3. 文件命名规范

根据项目使用的技术栈，遵循以下命名规范：

EOF

    if [[ "$LANGUAGES" == *"JavaScript"* ]] || [[ "$LANGUAGES" == *"TypeScript"* ]]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'
### JavaScript/TypeScript 规范
- 组件文件: PascalCase (如 `UserProfile.tsx`)
- 工具文件: camelCase (如 `formatDate.js`)
- 常量文件: UPPER_SNAKE_CASE (如 `API_CONSTANTS.js`)
- 测试文件: `*.test.js` 或 `*.spec.js`

EOF
    fi

    if [[ "$LANGUAGES" == *"Python"* ]]; then
        cat >> "$PROJECT_DIR/file-functions.md" << 'EOF'
### Python 规范
- 模块文件: snake_case (如 `user_service.py`)
- 类文件: PascalCase (如 `UserModel.py`)
- 测试文件: `test_*.py` 或 `*_test.py`

EOF
    fi

    cat >> "$PROJECT_DIR/file-functions.md" << EOF

---

*文档版本：v1.0*
*创建日期：$(date +%Y-%m-%d)*
*最后更新：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "文件功能列表生成成功"
    else
        print_error "文件功能列表生成失败"
        exit 1
    fi

    sleep 1
}

# 生成系统功能全图
generate_system_overview_diagram() {
    print_info "正在生成系统功能全图..."

    # 根据项目类型生成不同的架构图
    local diagram_content=""

    if [ "$PROJECT_TYPE" = "全栈 Web 应用" ]; then
        diagram_content='@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<frontend>> LightBlue
    BackgroundColor<<backend>> LightGreen
    BackgroundColor<<data>> LightYellow
    BackgroundColor<<external>> LightCoral
}

title '"$PROJECT_NAME"' - 系统功能架构全图

actor "用户" as User

rectangle "前端层" <<frontend>> {
    rectangle "用户界面" as UI
    rectangle "组件库" as Components
    rectangle "状态管理" as State
    rectangle "路由管理" as Router
}

rectangle "后端层" <<backend>> {
    rectangle "API 网关" as Gateway {
        rectangle "路由" as APIRouter
        rectangle "中间件" as Middleware
    }

    rectangle "业务服务层" as Services {
        rectangle "用户服务" as UserService
        rectangle "业务逻辑" as BizLogic
        rectangle "数据处理" as DataProcess
    }

    rectangle "数据访问层" as DataAccess {
        rectangle "ORM/DAO" as ORM
        rectangle "缓存管理" as Cache
    }
}

rectangle "数据层" <<data>> {
    database "主数据库" as MainDB
    database "缓存" as Redis
}

User --> UI
UI --> Components
UI --> State
UI --> Router
Router --> Gateway
Gateway --> APIRouter
APIRouter --> Middleware
Middleware --> Services
Services --> UserService
Services --> BizLogic
Services --> DataProcess
UserService --> DataAccess
BizLogic --> DataAccess
DataProcess --> DataAccess
DataAccess --> ORM
DataAccess --> Cache
ORM --> MainDB
Cache --> Redis

@enduml'
    elif [ "$HAS_BACKEND" = true ] && [ "$HAS_API" = true ]; then
        diagram_content='@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<api>> LightBlue
    BackgroundColor<<service>> LightGreen
    BackgroundColor<<data>> LightYellow
}

title '"$PROJECT_NAME"' - API 服务架构全图

actor "客户端" as Client

rectangle "API 层" <<api>> {
    rectangle "API 网关" as Gateway
    rectangle "路由管理" as Router
    rectangle "认证中间件" as Auth
    rectangle "验证中间件" as Validator
}

rectangle "服务层" <<service>> {
    rectangle "业务服务" as BizService
    rectangle "数据服务" as DataService
    rectangle "工具服务" as UtilService
}

rectangle "数据层" <<data>> {
    database "数据库" as DB
    database "缓存" as Cache
}

Client --> Gateway
Gateway --> Router
Router --> Auth
Auth --> Validator
Validator --> BizService
BizService --> DataService
DataService --> DB
DataService --> Cache
BizService --> UtilService

@enduml'
    elif [ "$HAS_FRONTEND" = true ]; then
        diagram_content='@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<ui>> LightBlue
    BackgroundColor<<logic>> LightGreen
    BackgroundColor<<external>> LightYellow
}

title '"$PROJECT_NAME"' - 前端应用架构全图

actor "用户" as User

rectangle "展示层" <<ui>> {
    rectangle "页面组件" as Pages
    rectangle "UI 组件" as Components
    rectangle "布局组件" as Layouts
}

rectangle "逻辑层" <<logic>> {
    rectangle "状态管理" as State
    rectangle "路由管理" as Router
    rectangle "业务逻辑" as Logic
}

rectangle "服务层" <<external>> {
    rectangle "API 调用" as API
    rectangle "数据处理" as DataProcess
    rectangle "工具函数" as Utils
}

cloud "后端 API" as Backend

User --> Pages
Pages --> Components
Pages --> Layouts
Pages --> State
State --> Router
Router --> Logic
Logic --> API
API --> DataProcess
DataProcess --> Utils
API --> Backend

@enduml'
    else
        diagram_content='@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<core>> LightBlue
    BackgroundColor<<support>> LightGreen
}

title '"$PROJECT_NAME"' - 系统架构全图

actor "用户/客户端" as User

rectangle "核心模块" <<core>> {
    rectangle "主要功能" as MainFunc
    rectangle "业务逻辑" as Logic
}

rectangle "支持模块" <<support>> {
    rectangle "工具类" as Utils
    rectangle "配置管理" as Config
}

database "数据存储" as Storage

User --> MainFunc
MainFunc --> Logic
Logic --> Utils
Logic --> Config
Logic --> Storage

@enduml'
    fi

    echo "$diagram_content" > "$PROJECT_DIR/system-overview.puml"

    if [ $? -eq 0 ]; then
        print_success "系统功能全图生成成功"
    else
        print_error "系统功能全图生成失败"
        exit 1
    fi

    sleep 1
}

# 生成模块流程图
generate_module_flowchart() {
    print_info "正在生成模块流程图..."

    # 根据项目类型生成不同的流程图
    local flowchart_content=""

    if [ "$HAS_API" = true ]; then
        flowchart_content='@startuml 模块流程图

title API 请求处理流程

start

:客户端发起请求;

:API 网关接收请求;

:验证请求格式;

if (格式正确?) then (是)
    :认证检查;

    if (认证通过?) then (是)
        :权限验证;

        if (有权限?) then (是)
            :参数验证;

            if (参数有效?) then (是)
                :调用业务服务;

                :处理业务逻辑;

                if (需要数据库?) then (是)
                    :查询/更新数据库;

                    if (操作成功?) then (是)
                        :返回成功响应;
                    else (否)
                        :返回数据库错误;
                        stop
                    endif
                else (否)
                    :返回处理结果;
                endif

                :记录日志;
                :返回 200 OK;
            else (否)
                :返回 400 参数错误;
                stop
            endif
        else (否)
            :返回 403 权限不足;
            stop
        endif
    else (否)
        :返回 401 未授权;
        stop
    endif
else (否)
    :返回 400 格式错误;
    stop
endif

stop

@enduml'
    elif [ "$HAS_FRONTEND" = true ]; then
        flowchart_content='@startuml 模块流程图

title 用户交互流程

start

:用户访问应用;

:加载初始页面;

:检查用户状态;

if (已登录?) then (否)
    :显示登录页面;
    :用户输入凭证;
    :提交登录请求;

    if (登录成功?) then (是)
        :保存用户状态;
        :跳转主页面;
    else (否)
        :显示错误信息;
        stop
    endif
else (是)
    :加载用户数据;
endif

:显示主界面;

:用户进行操作;

if (需要数据?) then (是)
    :发起 API 请求;

    if (请求成功?) then (是)
        :更新界面数据;
    else (否)
        :显示错误提示;
    endif
endif

:用户继续操作;

stop

@enduml'
    else
        flowchart_content='@startuml 模块流程图

title 核心业务流程

start

:系统启动;

:加载配置;

:初始化模块;

if (初始化成功?) then (是)
    :执行主要功能;

    :处理业务逻辑;

    if (需要存储?) then (是)
        :读写数据;
    endif

    :生成结果;

    :输出/返回结果;
else (否)
    :记录错误;
    :退出程序;
    stop
endif

stop

@enduml'
    fi

    echo "$flowchart_content" > "$PROJECT_DIR/module-flowchart.puml"

    if [ $? -eq 0 ]; then
        print_success "模块流程图生成成功"
    else
        print_error "模块流程图生成失败"
        exit 1
    fi

    sleep 1
}

# 生成时序图
generate_sequence_diagram() {
    print_info "正在生成时序图..."

    # 根据项目类型生成不同的时序图
    local sequence_content=""

    if [ "$PROJECT_TYPE" = "全栈 Web 应用" ]; then
        sequence_content='@startuml 时序图

title '"$PROJECT_NAME"' - 典型交互时序图

actor "用户" as User
participant "前端" as Frontend
participant "API 网关" as Gateway
participant "业务服务" as Service
participant "数据库" as DB
participant "缓存" as Cache

User -> Frontend: 发起操作请求
activate Frontend

Frontend -> Frontend: 验证输入
Frontend -> Gateway: POST /api/endpoint
activate Gateway

Gateway -> Gateway: 验证 Token
Gateway -> Service: 转发请求
activate Service

Service -> Cache: 检查缓存
activate Cache
Cache --> Service: 缓存未命中
deactivate Cache

Service -> DB: 查询数据
activate DB
DB --> Service: 返回数据
deactivate DB

Service -> Service: 处理业务逻辑

Service -> Cache: 更新缓存
activate Cache
Cache --> Service: 缓存成功
deactivate Cache

Service --> Gateway: 返回结果
deactivate Service

Gateway --> Frontend: 200 OK + 数据
deactivate Gateway

Frontend -> Frontend: 更新界面
Frontend --> User: 显示结果
deactivate Frontend

@enduml'
    elif [ "$HAS_API" = true ]; then
        sequence_content='@startuml 时序图

title '"$PROJECT_NAME"' - API 调用时序图

actor "客户端" as Client
participant "API 网关" as Gateway
participant "认证服务" as Auth
participant "业务服务" as Service
participant "数据库" as DB

Client -> Gateway: API 请求 + Token
activate Gateway

Gateway -> Auth: 验证 Token
activate Auth
Auth --> Gateway: Token 有效
deactivate Auth

Gateway -> Service: 转发请求
activate Service

Service -> DB: 数据操作
activate DB
DB --> Service: 返回结果
deactivate DB

Service -> Service: 业务处理

Service --> Gateway: 返回数据
deactivate Service

Gateway --> Client: 200 OK + 响应
deactivate Gateway

@enduml'
    elif [ "$HAS_FRONTEND" = true ]; then
        sequence_content='@startuml 时序图

title '"$PROJECT_NAME"' - 前端交互时序图

actor "用户" as User
participant "页面组件" as Page
participant "状态管理" as State
participant "API 服务" as API
participant "后端" as Backend

User -> Page: 触发操作
activate Page

Page -> State: 更新状态
activate State
State --> Page: 状态已更新
deactivate State

Page -> API: 调用 API
activate API

API -> Backend: HTTP 请求
activate Backend
Backend --> API: 返回数据
deactivate Backend

API --> Page: 处理后的数据
deactivate API

Page -> State: 更新数据状态
activate State
State --> Page: 完成
deactivate State

Page -> Page: 重新渲染
Page --> User: 显示更新
deactivate Page

@enduml'
    else
        sequence_content='@startuml 时序图

title '"$PROJECT_NAME"' - 系统交互时序图

actor "用户/客户端" as User
participant "主模块" as Main
participant "业务逻辑" as Logic
participant "数据存储" as Storage

User -> Main: 发起请求
activate Main

Main -> Logic: 调用功能
activate Logic

Logic -> Storage: 读取/写入数据
activate Storage
Storage --> Logic: 返回结果
deactivate Storage

Logic -> Logic: 处理逻辑

Logic --> Main: 返回处理结果
deactivate Logic

Main --> User: 返回响应
deactivate Main

@enduml'
    fi

    echo "$sequence_content" > "$PROJECT_DIR/sequence-diagram.puml"

    if [ $? -eq 0 ]; then
        print_success "时序图生成成功"
    else
        print_error "时序图生成失败"
        exit 1
    fi

    sleep 1
}

# 阶段 3：更新最终版 CLAUDE.md
stage3_update_final() {
    print_stage "阶段 3：更新最终版 CLAUDE.md"

    print_info "正在更新 CLAUDE.md 为最终版本..."

    cat > "$PROJECT_DIR/CLAUDE.md" << EOF
# $PROJECT_NAME - 项目文档索引

> **项目类型**: $PROJECT_TYPE
> **编程语言**: $LANGUAGES
> **框架**: $FRAMEWORKS
> **数据库**: $DATABASES

本项目的完整文档结构如下：

## 📋 核心文档

### 1. [需求分析文档](./requirements-analysis.md)
**内容概要**：完整的项目需求分析，包含：
- 项目概述和目标
- 功能需求（根据项目类型定制）
- 非功能需求（性能、安全、可用性、可维护性）
- 约束条件和验收标准

### 2. [文件功能列表](./file-functions.md)
**内容概要**：项目文件结构和功能说明，包含：
- 实际的项目目录结构
- 主要配置文件说明
- 源代码目录组织
- 文件命名规范

## 📊 可视化图表

### 3. [系统功能全图](./system-overview.puml)
**图表说明**：系统整体功能架构图，展示：
- 系统分层架构
- 模块间的依赖关系
- 数据流向
- 外部系统集成

### 4. [模块流程图](./module-flowchart.puml)
**图表说明**：核心业务流程图，展示：
- 主要业务流程
- 决策分支
- 异常处理
- 状态转换

### 5. [时序图](./sequence-diagram.puml)
**图表说明**：系统交互时序图，包含：
- 组件间的交互顺序
- 消息传递
- 生命周期管理
- 异步处理流程

---

## 📖 如何使用文档

### 查看 Markdown 文档
- 使用任何 Markdown 阅读器或编辑器打开 \`.md\` 文件
- 推荐工具：VS Code、Typora、Obsidian

### 查看 PlantUML 图表

#### 方法一：VS Code（推荐）
1. 安装 VS Code 扩展：\`PlantUML\`
2. 打开 \`.puml\` 文件
3. 按 \`Alt + D\` 预览图表

#### 方法二：在线预览
1. 访问 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)
2. 复制 \`.puml\` 文件内容
3. 粘贴到编辑器中查看

#### 方法三：导出图片
\`\`\`bash
# 安装 PlantUML
npm install -g node-plantuml

# 导出为 PNG
puml generate system-overview.puml -o system-overview.png

# 导出为 SVG
puml generate system-overview.puml -o system-overview.svg
\`\`\`

---

## 🔄 文档状态

- [x] 需求分析文档 - ✅ 已完成
- [x] 文件功能列表 - ✅ 已完成
- [x] 系统功能全图 - ✅ 已完成
- [x] 模块流程图 - ✅ 已完成
- [x] 时序图 - ✅ 已完成

---

## 📝 文档维护说明

### 更新频率
- **需求分析文档**：需求变更时更新
- **文件功能列表**：新增/修改文件时更新
- **系统功能全图**：架构调整时更新
- **模块流程图**：业务流程变更时更新
- **时序图**：交互逻辑变更时更新

### 版本控制
所有文档均包含版本号和更新日期，便于追踪变更历史。

---

## 🎯 快速导航

| 需求 | 推荐文档 |
|------|---------|
| 了解项目需求 | [需求分析文档](./requirements-analysis.md) |
| 查找文件功能 | [文件功能列表](./file-functions.md) |
| 理解系统架构 | [系统功能全图](./system-overview.puml) |
| 了解业务流程 | [模块流程图](./module-flowchart.puml) |
| 理解交互逻辑 | [时序图](./sequence-diagram.puml) |

---

## 🛠️ 技术栈详情

- **编程语言**: $LANGUAGES
- **框架**: $FRAMEWORKS
- **数据库**: $DATABASES
- **包含前端**: $HAS_FRONTEND
- **包含后端**: $HAS_BACKEND
- **包含 API**: $HAS_API
- **包含测试**: $HAS_TESTS

---

*文档版本：v1.0*
*创建日期：$(date +%Y-%m-%d)*
*最后更新：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "最终版 CLAUDE.md 更新成功"
    else
        print_error "最终版 CLAUDE.md 更新失败"
        exit 1
    fi

    sleep 1
}

# 生成文档统计报告
generate_report() {
    print_stage "生成文档统计报告"

    print_info "统计文档信息..."

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}文档生成完成统计${NC}"
    echo -e "${GREEN}========================================${NC}\n"

    echo -e "${CYAN}项目信息：${NC}"
    echo -e "  项目名称: $PROJECT_NAME"
    echo -e "  项目类型: $PROJECT_TYPE"
    echo -e "  编程语言: $LANGUAGES"
    echo -e "  框架: $FRAMEWORKS"
    echo -e "  数据库: $DATABASES"

    echo -e "\n${CYAN}生成的文档列表：${NC}"
    echo -e "  1. CLAUDE.md                    $(wc -l < "$PROJECT_DIR/CLAUDE.md" 2>/dev/null || echo "N/A") 行"
    echo -e "  2. requirements-analysis.md     $(wc -l < "$PROJECT_DIR/requirements-analysis.md" 2>/dev/null || echo "N/A") 行"
    echo -e "  3. file-functions.md            $(wc -l < "$PROJECT_DIR/file-functions.md" 2>/dev/null || echo "N/A") 行"
    echo -e "  4. system-overview.puml         $(wc -l < "$PROJECT_DIR/system-overview.puml" 2>/dev/null || echo "N/A") 行"
    echo -e "  5. module-flowchart.puml        $(wc -l < "$PROJECT_DIR/module-flowchart.puml" 2>/dev/null || echo "N/A") 行"
    echo -e "  6. sequence-diagram.puml        $(wc -l < "$PROJECT_DIR/sequence-diagram.puml" 2>/dev/null || echo "N/A") 行"

    echo -e "\n${CYAN}文档存储位置：${NC}"
    echo -e "  $PROJECT_DIR"

    echo -e "\n${CYAN}下一步操作建议：${NC}"
    echo -e "  1. 使用 VS Code 打开项目目录查看文档"
    echo -e "  2. 安装 PlantUML 插件预览图表"
    echo -e "  3. 根据实际项目情况调整文档内容"
    echo -e "  4. 将文档纳入版本控制"

    echo -e "\n${GREEN}========================================${NC}\n"
}

# 主函数
main() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   智能三阶段文档生成脚本              ║"
    echo "║   Smart Documentation Generator        ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}\n"

    print_info "开始执行智能文档生成流程..."
    print_info "目标目录: $PROJECT_DIR"

    # 检查目录
    check_directory

    # 执行阶段
    stage0_analyze_project
    stage0_5_deep_analysis  # 新增：深度分析阶段
    stage1_generate_framework
    stage2_generate_documents
    stage3_update_final

    # 生成报告
    generate_report

    print_success "所有文档生成完成！"
}

# 执行主函数
main
