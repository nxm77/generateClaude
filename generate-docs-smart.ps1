# 智能三阶段文档生成脚本（PowerShell 版本）
# 用途：自动分析项目并生成定制化文档
# 作者：自动生成
# 日期：2026-03-17
# 使用方法：
#   .\generate-docs-smart.ps1              - 在当前目录分析并生成文档（基础模式）
#   .\generate-docs-smart.ps1 -Deep        - 在当前目录深度分析并生成文档
#   .\generate-docs-smart.ps1 -Path "C:\path\to\dir" - 在指定目录分析并生成文档
#   .\generate-docs-smart.ps1 -Deep -Path "C:\path\to\dir" - 在指定目录深度分析

param(
    [switch]$Deep,
    [string]$Path = $PWD.Path
)

# 全局变量
$script:PROJECT_DIR = $Path
$script:DEEP_ANALYSIS = $Deep
$script:PROJECT_NAME = ""
$script:PROJECT_TYPE = ""
$script:TECH_STACK = ""
$script:LANGUAGES = ""
$script:FRAMEWORKS = ""
$script:DATABASES = ""
$script:HAS_FRONTEND = $false
$script:HAS_BACKEND = $false
$script:HAS_DATABASE = $false
$script:HAS_API = $false
$script:HAS_TESTS = $false
$script:DIRECTORY_STRUCTURE = ""
$script:FILE_LIST = ""
$script:MAIN_FILES = ""

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )

    switch ($Type) {
        "Info" { Write-Host "[INFO] $Message" -ForegroundColor Blue }
        "Success" { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
        "Warning" { Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
        "Error" { Write-Host "[ERROR] $Message" -ForegroundColor Red }
        "Stage" {
            Write-Host "`n========================================" -ForegroundColor Cyan
            Write-Host $Message -ForegroundColor Cyan
            Write-Host "========================================`n" -ForegroundColor Cyan
        }
        "Analysis" { Write-Host "[ANALYSIS] $Message" -ForegroundColor Magenta }
    }
}

# 检查目录是否存在
function Test-ProjectDirectory {
    if (-not (Test-Path $script:PROJECT_DIR)) {
        Write-ColorOutput "项目目录不存在: $script:PROJECT_DIR" "Error"
        exit 1
    }
    Write-ColorOutput "项目目录检查通过: $script:PROJECT_DIR" "Success"
}

# 阶段 0：智能分析项目
function Invoke-ProjectAnalysis {
    Write-ColorOutput "阶段 0：智能分析项目" "Stage"

    Set-Location $script:PROJECT_DIR

    # 1. 获取项目名称
    $script:PROJECT_NAME = Split-Path $script:PROJECT_DIR -Leaf
    Write-ColorOutput "项目名称: $script:PROJECT_NAME" "Analysis"

    # 2. 分析编程语言
    Get-Languages

    # 3. 分析技术栈
    Get-TechStack

    # 4. 分析项目类型
    Get-ProjectType

    # 5. 分析目录结构
    Get-DirectoryStructure

    # 6. 分析主要文件
    Get-MainFiles

    # 7. 生成分析报告
    Show-AnalysisReport

    Start-Sleep -Seconds 1
}

# 分析编程语言
function Get-Languages {
    Write-ColorOutput "正在分析编程语言..." "Info"

    $langs = @()

    # JavaScript/TypeScript
    if ((Test-Path "package.json") -or
        (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.js","*.ts","*.jsx","*.tsx" -ErrorAction SilentlyContinue)) {
        $langs += "JavaScript/TypeScript"
    }

    # Python
    if ((Test-Path "requirements.txt") -or (Test-Path "setup.py") -or (Test-Path "pyproject.toml") -or
        (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.py" -ErrorAction SilentlyContinue)) {
        $langs += "Python"
    }

    # Java
    if ((Test-Path "pom.xml") -or (Test-Path "build.gradle") -or
        (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.java" -ErrorAction SilentlyContinue)) {
        $langs += "Java"
    }

    # Go
    if ((Test-Path "go.mod") -or
        (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.go" -ErrorAction SilentlyContinue)) {
        $langs += "Go"
    }

    # C/C++
    if (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.c","*.cpp","*.h","*.hpp" -ErrorAction SilentlyContinue) {
        $langs += "C/C++"
    }

    # Rust
    if ((Test-Path "Cargo.toml") -or
        (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.rs" -ErrorAction SilentlyContinue)) {
        $langs += "Rust"
    }

    # PHP
    if (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.php" -ErrorAction SilentlyContinue) {
        $langs += "PHP"
    }

    # Ruby
    if ((Test-Path "Gemfile") -or
        (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.rb" -ErrorAction SilentlyContinue)) {
        $langs += "Ruby"
    }

    if ($langs.Count -eq 0) {
        $script:LANGUAGES = "未检测到"
    } else {
        $script:LANGUAGES = $langs -join ", "
    }

    Write-ColorOutput "检测到的语言: $script:LANGUAGES" "Analysis"
}

# 分析技术栈
function Get-TechStack {
    Write-ColorOutput "正在分析技术栈..." "Info"

    $frameworks = @()
    $databases = @()

    # 前端框架
    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" -Raw

        if ($packageJson -match "react") {
            $frameworks += "React"
            $script:HAS_FRONTEND = $true
        }
        if ($packageJson -match "vue") {
            $frameworks += "Vue"
            $script:HAS_FRONTEND = $true
        }
        if ($packageJson -match "angular") {
            $frameworks += "Angular"
            $script:HAS_FRONTEND = $true
        }
        if ($packageJson -match "next") {
            $frameworks += "Next.js"
            $script:HAS_FRONTEND = $true
            $script:HAS_BACKEND = $true
        }
        if ($packageJson -match "express") {
            $frameworks += "Express"
            $script:HAS_BACKEND = $true
            $script:HAS_API = $true
        }
        if ($packageJson -match "nest") {
            $frameworks += "NestJS"
            $script:HAS_BACKEND = $true
            $script:HAS_API = $true
        }

        # 数据库
        if ($packageJson -match "mysql|mysql2") {
            $databases += "MySQL"
            $script:HAS_DATABASE = $true
        }
        if ($packageJson -match "pg|postgres") {
            $databases += "PostgreSQL"
            $script:HAS_DATABASE = $true
        }
        if ($packageJson -match "mongodb|mongoose") {
            $databases += "MongoDB"
            $script:HAS_DATABASE = $true
        }
        if ($packageJson -match "redis") {
            $databases += "Redis"
        }
        if ($packageJson -match "sqlite") {
            $databases += "SQLite"
            $script:HAS_DATABASE = $true
        }

        # 测试框架
        if ($packageJson -match "jest|mocha|vitest|playwright|cypress") {
            $script:HAS_TESTS = $true
        }
    }

    # Python 框架
    if (Test-Path "requirements.txt") {
        $requirements = Get-Content "requirements.txt" -Raw

        if ($requirements -match "(?i)django") {
            $frameworks += "Django"
            $script:HAS_BACKEND = $true
            $script:HAS_API = $true
        }
        if ($requirements -match "(?i)flask") {
            $frameworks += "Flask"
            $script:HAS_BACKEND = $true
            $script:HAS_API = $true
        }
        if ($requirements -match "(?i)fastapi") {
            $frameworks += "FastAPI"
            $script:HAS_BACKEND = $true
            $script:HAS_API = $true
        }

        # 数据库
        if ($requirements -match "(?i)mysql|pymysql") {
            $databases += "MySQL"
            $script:HAS_DATABASE = $true
        }
        if ($requirements -match "(?i)psycopg|postgresql") {
            $databases += "PostgreSQL"
            $script:HAS_DATABASE = $true
        }
        if ($requirements -match "(?i)pymongo") {
            $databases += "MongoDB"
            $script:HAS_DATABASE = $true
        }
        if ($requirements -match "(?i)redis") {
            $databases += "Redis"
        }

        # 测试框架
        if ($requirements -match "(?i)pytest|unittest") {
            $script:HAS_TESTS = $true
        }
    }

    # Java 框架
    if (Test-Path "pom.xml") {
        $pomXml = Get-Content "pom.xml" -Raw

        if ($pomXml -match "spring-boot") {
            $frameworks += "Spring Boot"
            $script:HAS_BACKEND = $true
            $script:HAS_API = $true
        }
    }

    if ($frameworks.Count -eq 0) {
        $script:FRAMEWORKS = "未检测到"
    } else {
        $script:FRAMEWORKS = $frameworks -join ", "
    }

    if ($databases.Count -eq 0) {
        $script:DATABASES = "未检测到"
    } else {
        $script:DATABASES = $databases -join ", "
    }

    Write-ColorOutput "检测到的框架: $script:FRAMEWORKS" "Analysis"
    Write-ColorOutput "检测到的数据库: $script:DATABASES" "Analysis"
}

# 分析项目类型
function Get-ProjectType {
    Write-ColorOutput "正在分析项目类型..." "Info"

    if ($script:HAS_FRONTEND -and $script:HAS_BACKEND) {
        $script:PROJECT_TYPE = "全栈 Web 应用"
    } elseif ($script:HAS_FRONTEND) {
        $script:PROJECT_TYPE = "前端应用"
    } elseif ($script:HAS_BACKEND) {
        $script:PROJECT_TYPE = "后端服务"
    } elseif ($script:HAS_API) {
        $script:PROJECT_TYPE = "API 服务"
    } elseif ((Test-Path "package.json") -and ((Get-Content "package.json" -Raw) -match "electron")) {
        $script:PROJECT_TYPE = "桌面应用"
    } elseif ((Test-Path "package.json") -and ((Get-Content "package.json" -Raw) -match "react-native")) {
        $script:PROJECT_TYPE = "移动应用"
    } else {
        $script:PROJECT_TYPE = "通用软件项目"
    }

    Write-ColorOutput "项目类型: $script:PROJECT_TYPE" "Analysis"
}

# 分析目录结构
function Get-DirectoryStructure {
    Write-ColorOutput "正在分析目录结构..." "Info"

    # 获取目录树（排除常见的无关目录）
    $excludeDirs = @("node_modules", "__pycache__", ".git", "dist", "build", "target", "venv", "env", ".venv")

    try {
        $dirs = Get-ChildItem -Path $script:PROJECT_DIR -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
                Where-Object {
                    $dirName = $_.Name
                    -not ($excludeDirs | Where-Object { $dirName -eq $_ })
                } |
                Select-Object -First 50 -ExpandProperty FullName

        $script:DIRECTORY_STRUCTURE = $dirs -join "`n"
    } catch {
        $script:DIRECTORY_STRUCTURE = "目录扫描失败"
    }

    Write-ColorOutput "目录结构已分析" "Analysis"
}

# 分析主要文件
function Get-MainFiles {
    Write-ColorOutput "正在分析主要文件..." "Info"

    $files = @()

    # 配置文件
    if (Test-Path "package.json") { $files += "package.json" }
    if (Test-Path "requirements.txt") { $files += "requirements.txt" }
    if (Test-Path "pom.xml") { $files += "pom.xml" }
    if (Test-Path "build.gradle") { $files += "build.gradle" }
    if (Test-Path "go.mod") { $files += "go.mod" }
    if (Test-Path "Cargo.toml") { $files += "Cargo.toml" }
    if (Test-Path "composer.json") { $files += "composer.json" }
    if (Test-Path "Gemfile") { $files += "Gemfile" }

    # 配置文件
    if (Test-Path ".env") { $files += ".env" }
    if (Test-Path ".env.example") { $files += ".env.example" }
    if (Test-Path "config.json") { $files += "config.json" }
    if (Test-Path "tsconfig.json") { $files += "tsconfig.json" }

    # 文档文件
    if (Test-Path "README.md") { $files += "README.md" }
    if (Test-Path "CHANGELOG.md") { $files += "CHANGELOG.md" }
    if (Test-Path "LICENSE") { $files += "LICENSE" }

    # 入口文件
    if (Test-Path "index.js") { $files += "index.js" }
    if (Test-Path "index.ts") { $files += "index.ts" }
    if (Test-Path "main.py") { $files += "main.py" }
    if (Test-Path "app.py") { $files += "app.py" }
    if (Test-Path "server.js") { $files += "server.js" }
    if (Test-Path "main.go") { $files += "main.go" }

    $script:MAIN_FILES = $files -join "`n"

    Write-ColorOutput "检测到 $($files.Count) 个主要文件" "Analysis"
}

# 生成分析报告
function Show-AnalysisReport {
    Write-ColorOutput "项目分析报告" "Stage"

    Write-Host "项目名称: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:PROJECT_NAME
    Write-Host "项目类型: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:PROJECT_TYPE
    Write-Host "编程语言: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:LANGUAGES
    Write-Host "框架: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:FRAMEWORKS
    Write-Host "数据库: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:DATABASES
    Write-Host "包含前端: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:HAS_FRONTEND
    Write-Host "包含后端: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:HAS_BACKEND
    Write-Host "包含 API: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:HAS_API
    Write-Host "包含测试: " -NoNewline -ForegroundColor Cyan
    Write-Host $script:HAS_TESTS

    Write-Host "`n主要文件:" -ForegroundColor Cyan
    $script:MAIN_FILES -split "`n" | ForEach-Object {
        if ($_) { Write-Host "  - $_" }
    }
}

# 阶段 0.5：深度代码分析（可选）
function Invoke-DeepAnalysis {
    if (-not $script:DEEP_ANALYSIS) {
        Write-ColorOutput "跳过深度分析（使用 -Deep 参数启用）" "Info"
        return
    }

    Write-ColorOutput "阶段 0.5：深度代码分析" "Stage"
    Write-ColorOutput "正在调用 project-deep-analyzer skill 进行深度分析..." "Info"
    Write-ColorOutput "这可能需要几分钟时间，请耐心等待..." "Warning"

    # 检查 skill 是否存在
    $skillPaths = @(
        "$env:USERPROFILE\.claude\skills\project-deep-analyzer.md",
        ".claude\skills\project-deep-analyzer.md"
    )

    $skillExists = $false
    foreach ($skillPath in $skillPaths) {
        if (Test-Path $skillPath) {
            $skillExists = $true
            break
        }
    }

    if (-not $skillExists) {
        Write-ColorOutput "找不到 project-deep-analyzer skill" "Error"
        Write-ColorOutput "请确保 skill 文件存在于以下位置之一：" "Info"
        foreach ($skillPath in $skillPaths) {
            Write-ColorOutput "  - $skillPath" "Info"
        }
        Write-ColorOutput "将继续使用基础分析模式" "Warning"
        return
    }

    # 检查 claude 命令是否可用
    try {
        $claudeVersion = claude --version 2>&1
        Write-ColorOutput "正在执行深度分析..." "Info"

        # 创建临时提示
        $prompt = @"
请使用 project-deep-analyzer skill 深度分析当前项目（$script:PROJECT_DIR）。

分析完成后，请将结果保存到 .analysis-report.json 文件中。

项目基本信息：
- 项目名称: $script:PROJECT_NAME
- 项目类型: $script:PROJECT_TYPE
- 编程语言: $script:LANGUAGES
- 框架: $script:FRAMEWORKS
- 数据库: $script:DATABASES
"@

        # 使用 claude -p 调用分析
        $output = claude -p $prompt 2>&1

        # 检查分析报告是否生成
        $reportPath = Join-Path $script:PROJECT_DIR ".analysis-report.json"
        if (Test-Path $reportPath) {
            Write-ColorOutput "深度分析完成，报告已生成" "Success"

            # 显示分析统计（如果有 jq 或可以解析 JSON）
            try {
                $report = Get-Content $reportPath -Raw | ConvertFrom-Json
                Write-ColorOutput "分析统计：" "Info"
                Write-Host "  API 端点数: $($report.statistics.total_endpoints)"
                Write-Host "  数据模型数: $($report.statistics.total_models)"
                Write-Host "  业务流程数: $($report.statistics.total_flows)"
                Write-Host "  分析文件数: $($report.statistics.code_files_analyzed)"
            } catch {
                Write-ColorOutput "无法解析分析报告统计信息" "Warning"
            }
        } else {
            Write-ColorOutput "深度分析未生成报告文件" "Warning"
            Write-ColorOutput "将继续使用基础分析模式" "Warning"
        }
    } catch {
        Write-ColorOutput "未找到 claude 命令" "Error"
        Write-ColorOutput "深度分析需要在 Claude Code 环境中运行" "Info"
        Write-ColorOutput "将继续使用基础分析模式" "Warning"
    }
}

# 阶段 1：生成框架版 CLAUDE.md
function New-FrameworkDocument {
    Write-ColorOutput "阶段 1：生成框架版 CLAUDE.md" "Stage"
    Write-ColorOutput "正在创建文档索引框架..." "Info"

    $content = @"
# $script:PROJECT_NAME - 项目文档索引

> **项目类型**: $script:PROJECT_TYPE
> **技术栈**: $script:LANGUAGES
> **框架**: $script:FRAMEWORKS

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

- **查看 PlantUML 图表**：使用支持 PlantUML 的工具（如 VS Code + PlantUML 插件）打开 ``.puml`` 文件
- **在线预览**：可以将 ``.puml`` 文件内容复制到 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)

## 🔄 文档状态

- [ ] 需求分析文档 - 待生成
- [ ] 文件功能列表 - 待生成
- [ ] 系统功能全图 - 待生成
- [ ] 模块流程图 - 待生成
- [ ] 时序图 - 待生成

---

*最后更新时间：$(Get-Date -Format 'yyyy-MM-dd')*
"@

    $claudePath = Join-Path $script:PROJECT_DIR "CLAUDE.md"
    Set-Content -Path $claudePath -Value $content -Encoding UTF8

    Write-ColorOutput "框架版 CLAUDE.md 创建成功" "Success"
    Start-Sleep -Seconds 1
}

# 阶段 2：生成具体文档
function New-DetailedDocuments {
    Write-ColorOutput "阶段 2：生成具体文档" "Stage"

    # 2.1 生成需求分析文档
    New-RequirementsDocument

    # 2.2 生成文件功能列表
    New-FileFunctionsDocument

    # 2.3 生成系统功能全图
    New-SystemOverviewDiagram

    # 2.4 生成模块流程图
    New-ModuleFlowchart

    # 2.5 生成时序图
    New-SequenceDiagram
}

# 生成需求分析文档
function New-RequirementsDocument {
    Write-ColorOutput "正在生成需求分析文档..." "Info"

    # 根据项目类型生成不同的需求文档
    $functionalRequirements = ""
    $nonfunctionalRequirements = ""

    if ($script:HAS_FRONTEND) {
        $functionalRequirements += @"

### 2.1 前端功能模块
- 用户界面设计和交互
- 响应式布局适配
- 前端路由管理
- 状态管理
- 组件化开发
"@
    }

    if ($script:HAS_BACKEND) {
        $functionalRequirements += @"

### 2.2 后端功能模块
- 业务逻辑处理
- 数据持久化
- 服务端渲染（如适用）
- 后台任务处理
"@
    }

    if ($script:HAS_API) {
        $functionalRequirements += @"

### 2.3 API 接口模块
- RESTful API 设计
- 接口文档和规范
- 请求验证和响应处理
- API 版本管理
"@
    }

    if ($script:HAS_DATABASE) {
        $functionalRequirements += @"

### 2.4 数据管理模块
- 数据库设计和优化
- 数据迁移和备份
- 数据查询和索引
- 数据安全和加密
"@
    }

    if ($script:HAS_TESTS) {
        $nonfunctionalRequirements += @"

### 3.4 测试需求
- 单元测试覆盖率 > 80%
- 集成测试覆盖核心流程
- 端到端测试覆盖关键场景
- 持续集成和自动化测试
"@
    }

    $content = @"
# $script:PROJECT_NAME - 需求分析文档

## 1. 项目概述

### 1.1 项目背景
本项目是一个 **$script:PROJECT_TYPE**，使用 **$script:LANGUAGES** 开发，基于 **$script:FRAMEWORKS** 框架构建。

### 1.2 项目目标
- 提供高效、稳定的系统功能
- 确保良好的用户体验
- 保证系统的可扩展性和可维护性
- 满足性能和安全要求

### 1.3 技术栈
- **编程语言**: $script:LANGUAGES
- **框架**: $script:FRAMEWORKS
- **数据库**: $script:DATABASES
- **项目类型**: $script:PROJECT_TYPE

## 2. 功能需求
$functionalRequirements

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
$nonfunctionalRequirements

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
*创建日期：$(Get-Date -Format 'yyyy-MM-dd')*
*最后更新：$(Get-Date -Format 'yyyy-MM-dd')*
"@

    $reqPath = Join-Path $script:PROJECT_DIR "requirements-analysis.md"
    Set-Content -Path $reqPath -Value $content -Encoding UTF8

    Write-ColorOutput "需求分析文档生成成功" "Success"
    Start-Sleep -Seconds 1
}

# 生成文件功能列表
function New-FileFunctionsDocument {
    Write-ColorOutput "正在生成文件功能列表..." "Info"

    # 扫描实际的目录结构
    $dirTree = $script:DIRECTORY_STRUCTURE

    $content = @"
# $script:PROJECT_NAME - 文件功能列表

## 1. 项目结构概览

``````
$dirTree
``````

## 2. 主要文件说明

### 2.1 配置文件
"@

    # 添加实际存在的配置文件
    if (Test-Path (Join-Path $script:PROJECT_DIR "package.json")) {
        $content += @"

#### ``package.json``
- **功能**: Node.js 项目配置文件
- **职责**:
  - 定义项目依赖
  - 配置脚本命令
  - 设置项目元信息
"@
    }

    if (Test-Path (Join-Path $script:PROJECT_DIR "requirements.txt")) {
        $content += @"

#### ``requirements.txt``
- **功能**: Python 项目依赖文件
- **职责**:
  - 列出 Python 包依赖
  - 指定包版本
  - 便于环境复制
"@
    }

    if (Test-Path (Join-Path $script:PROJECT_DIR "pom.xml")) {
        $content += @"

#### ``pom.xml``
- **功能**: Maven 项目配置文件
- **职责**:
  - 定义项目依赖
  - 配置构建流程
  - 管理插件
"@
    }

    if (Test-Path (Join-Path $script:PROJECT_DIR "go.mod")) {
        $content += @"

#### ``go.mod``
- **功能**: Go 模块定义文件
- **职责**:
  - 定义模块路径
  - 声明依赖包
  - 管理版本
"@
    }

    # 添加通用的源代码目录说明
    $content += @"

### 2.2 源代码目录

根据项目实际结构，主要包含以下类型的文件：

"@

    if ($script:HAS_FRONTEND) {
        $content += @"
#### 前端相关文件
- **组件文件**: 可复用的 UI 组件
- **页面文件**: 完整的页面视图
- **样式文件**: CSS/SCSS/Less 样式定义
- **路由文件**: 前端路由配置
- **状态管理**: Redux/Vuex/Pinia 等状态管理

"@
    }

    if ($script:HAS_BACKEND) {
        $content += @"
#### 后端相关文件
- **控制器**: 处理 HTTP 请求
- **服务层**: 业务逻辑实现
- **模型层**: 数据模型定义
- **中间件**: 请求处理中间件
- **工具类**: 通用工具函数

"@
    }

    if ($script:HAS_API) {
        $content += @"
#### API 相关文件
- **路由定义**: API 端点配置
- **接口文档**: API 规范说明
- **验证器**: 请求参数验证
- **响应格式**: 统一响应处理

"@
    }

    if ($script:HAS_TESTS) {
        $content += @"
#### 测试相关文件
- **单元测试**: 函数和模块测试
- **集成测试**: 模块间集成测试
- **端到端测试**: 完整流程测试
- **测试配置**: 测试框架配置

"@
    }

    $content += @"

## 3. 文件命名规范

根据项目使用的技术栈，遵循以下命名规范：

"@

    if ($script:LANGUAGES -match "JavaScript|TypeScript") {
        $content += @"
### JavaScript/TypeScript 规范
- 组件文件: PascalCase (如 ``UserProfile.tsx``)
- 工具文件: camelCase (如 ``formatDate.js``)
- 常量文件: UPPER_SNAKE_CASE (如 ``API_CONSTANTS.js``)
- 测试文件: ``*.test.js`` 或 ``*.spec.js``

"@
    }

    if ($script:LANGUAGES -match "Python") {
        $content += @"
### Python 规范
- 模块文件: snake_case (如 ``user_service.py``)
- 类文件: PascalCase (如 ``UserModel.py``)
- 测试文件: ``test_*.py`` 或 ``*_test.py``

"@
    }

    $content += @"

---

*文档版本：v1.0*
*创建日期：$(Get-Date -Format 'yyyy-MM-dd')*
*最后更新：$(Get-Date -Format 'yyyy-MM-dd')*
"@

    $filePath = Join-Path $script:PROJECT_DIR "file-functions.md"
    Set-Content -Path $filePath -Value $content -Encoding UTF8

    Write-ColorOutput "文件功能列表生成成功" "Success"
    Start-Sleep -Seconds 1
}

# 生成系统功能全图
function New-SystemOverviewDiagram {
    Write-ColorOutput "正在生成系统功能全图..." "Info"

    # 根据项目类型生成不同的架构图
    $diagramContent = ""

    if ($script:PROJECT_TYPE -eq "全栈 Web 应用") {
        $diagramContent = @"
@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<frontend>> LightBlue
    BackgroundColor<<backend>> LightGreen
    BackgroundColor<<data>> LightYellow
    BackgroundColor<<external>> LightCoral
}

title $script:PROJECT_NAME - 系统功能架构全图

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

@enduml
"@
    } elseif ($script:HAS_BACKEND -and $script:HAS_API) {
        $diagramContent = @"
@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<api>> LightBlue
    BackgroundColor<<service>> LightGreen
    BackgroundColor<<data>> LightYellow
}

title $script:PROJECT_NAME - API 服务架构全图

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

@enduml
"@
    } elseif ($script:HAS_FRONTEND) {
        $diagramContent = @"
@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<ui>> LightBlue
    BackgroundColor<<logic>> LightGreen
    BackgroundColor<<external>> LightYellow
}

title $script:PROJECT_NAME - 前端应用架构全图

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

@enduml
"@
    } else {
        $diagramContent = @"
@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<core>> LightBlue
    BackgroundColor<<support>> LightGreen
}

title $script:PROJECT_NAME - 系统架构全图

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

@enduml
"@
    }

    $diagramPath = Join-Path $script:PROJECT_DIR "system-overview.puml"
    Set-Content -Path $diagramPath -Value $diagramContent -Encoding UTF8

    Write-ColorOutput "系统功能全图生成成功" "Success"
    Start-Sleep -Seconds 1
}

# 生成模块流程图
function New-ModuleFlowchart {
    Write-ColorOutput "正在生成模块流程图..." "Info"

    # 根据项目类型生成不同的流程图
    $flowchartContent = ""

    if ($script:HAS_API) {
        $flowchartContent = @"
@startuml 模块流程图

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

@enduml
"@
    } elseif ($script:HAS_FRONTEND) {
        $flowchartContent = @"
@startuml 模块流程图

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

@enduml
"@
    } else {
        $flowchartContent = @"
@startuml 模块流程图

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

@enduml
"@
    }

    $flowchartPath = Join-Path $script:PROJECT_DIR "module-flowchart.puml"
    Set-Content -Path $flowchartPath -Value $flowchartContent -Encoding UTF8

    Write-ColorOutput "模块流程图生成成功" "Success"
    Start-Sleep -Seconds 1
}

# 生成时序图
function New-SequenceDiagram {
    Write-ColorOutput "正在生成时序图..." "Info"

    # 根据项目类型生成不同的时序图
    $sequenceContent = ""

    if ($script:PROJECT_TYPE -eq "全栈 Web 应用") {
        $sequenceContent = @"
@startuml 时序图

title $script:PROJECT_NAME - 典型交互时序图

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

@enduml
"@
    } elseif ($script:HAS_API) {
        $sequenceContent = @"
@startuml 时序图

title $script:PROJECT_NAME - API 调用时序图

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

@enduml
"@
    } elseif ($script:HAS_FRONTEND) {
        $sequenceContent = @"
@startuml 时序图

title $script:PROJECT_NAME - 前端交互时序图

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

@enduml
"@
    } else {
        $sequenceContent = @"
@startuml 时序图

title $script:PROJECT_NAME - 系统交互时序图

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

@enduml
"@
    }

    $sequencePath = Join-Path $script:PROJECT_DIR "sequence-diagram.puml"
    Set-Content -Path $sequencePath -Value $sequenceContent -Encoding UTF8

    Write-ColorOutput "时序图生成成功" "Success"
    Start-Sleep -Seconds 1
}

# 阶段 3：更新最终版 CLAUDE.md
function Update-FinalDocument {
    Write-ColorOutput "阶段 3：更新最终版 CLAUDE.md" "Stage"
    Write-ColorOutput "正在更新 CLAUDE.md 为最终版本..." "Info"

    $content = @"
# $script:PROJECT_NAME - 项目文档索引

> **项目类型**: $script:PROJECT_TYPE
> **编程语言**: $script:LANGUAGES
> **框架**: $script:FRAMEWORKS
> **数据库**: $script:DATABASES

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
- 使用任何 Markdown 阅读器或编辑器打开 ``.md`` 文件
- 推荐工具：VS Code、Typora、Obsidian

### 查看 PlantUML 图表

#### 方法一：VS Code（推荐）
1. 安装 VS Code 扩展：``PlantUML``
2. 打开 ``.puml`` 文件
3. 按 ``Alt + D`` 预览图表

#### 方法二：在线预览
1. 访问 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)
2. 复制 ``.puml`` 文件内容
3. 粘贴到编辑器中查看

#### 方法三：导出图片
``````bash
# 安装 PlantUML
npm install -g node-plantuml

# 导出为 PNG
puml generate system-overview.puml -o system-overview.png

# 导出为 SVG
puml generate system-overview.puml -o system-overview.svg
``````

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

- **编程语言**: $script:LANGUAGES
- **框架**: $script:FRAMEWORKS
- **数据库**: $script:DATABASES
- **包含前端**: $script:HAS_FRONTEND
- **包含后端**: $script:HAS_BACKEND
- **包含 API**: $script:HAS_API
- **包含测试**: $script:HAS_TESTS

---

*文档版本：v1.0*
*创建日期：$(Get-Date -Format 'yyyy-MM-dd')*
*最后更新：$(Get-Date -Format 'yyyy-MM-dd')*
"@

    $claudePath = Join-Path $script:PROJECT_DIR "CLAUDE.md"
    Set-Content -Path $claudePath -Value $content -Encoding UTF8

    Write-ColorOutput "最终版 CLAUDE.md 更新成功" "Success"
    Start-Sleep -Seconds 1
}

# 生成文档统计报告
function Show-GenerationReport {
    Write-ColorOutput "生成文档统计报告" "Stage"
    Write-ColorOutput "统计文档信息..." "Info"

    Write-Host "`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "文档生成完成统计" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    Write-Host "项目信息：" -ForegroundColor Cyan
    Write-Host "  项目名称: $script:PROJECT_NAME"
    Write-Host "  项目类型: $script:PROJECT_TYPE"
    Write-Host "  编程语言: $script:LANGUAGES"
    Write-Host "  框架: $script:FRAMEWORKS"
    Write-Host "  数据库: $script:DATABASES"

    Write-Host "`n生成的文档列表：" -ForegroundColor Cyan

    $files = @(
        "CLAUDE.md",
        "requirements-analysis.md",
        "file-functions.md",
        "system-overview.puml",
        "module-flowchart.puml",
        "sequence-diagram.puml"
    )

    $index = 1
    foreach ($file in $files) {
        $filePath = Join-Path $script:PROJECT_DIR $file
        if (Test-Path $filePath) {
            $lineCount = (Get-Content $filePath).Count
            Write-Host "  $index. $file" -NoNewline
            Write-Host " ($lineCount 行)" -ForegroundColor Gray
        } else {
            Write-Host "  $index. $file" -NoNewline
            Write-Host " (N/A)" -ForegroundColor Gray
        }
        $index++
    }

    Write-Host "`n文档存储位置：" -ForegroundColor Cyan
    Write-Host "  $script:PROJECT_DIR"

    Write-Host "`n下一步操作建议：" -ForegroundColor Cyan
    Write-Host "  1. 使用 VS Code 打开项目目录查看文档"
    Write-Host "  2. 安装 PlantUML 插件预览图表"
    Write-Host "  3. 根据实际项目情况调整文档内容"
    Write-Host "  4. 将文档纳入版本控制"

    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host ""
}

# 主函数
function Main {
    Write-Host "`n" -NoNewline
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   智能三阶段文档生成脚本              ║" -ForegroundColor Cyan
    Write-Host "║   Smart Documentation Generator        ║" -ForegroundColor Cyan
    Write-Host "║   (PowerShell 完整版)                  ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`n"

    Write-ColorOutput "开始执行智能文档生成流程..." "Info"
    Write-ColorOutput "目标目录: $script:PROJECT_DIR" "Info"

    # 检查目录
    Test-ProjectDirectory

    # 执行所有阶段
    Invoke-ProjectAnalysis
    Invoke-DeepAnalysis
    New-FrameworkDocument
    New-DetailedDocuments
    Update-FinalDocument

    # 生成报告
    Show-GenerationReport

    Write-ColorOutput "所有文档生成完成！" "Success"
}

# 执行主函数
Main
