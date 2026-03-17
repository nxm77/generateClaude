# 智能三阶段文档生成脚本 v2.0 (改进版)
# 改进点:
# 1. file-functions.md 包含实际文件的详细说明
# 2. 深度分析直接读取 .md 文件,不依赖 skill 机制
# 3. 深度分析结果被充分利用于文档生成

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
$script:ANALYSIS_REPORT = $null  # 新增: 存储深度分析结果

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

# 阶段 0: 智能分析项目 (保持原有逻辑)
function Invoke-ProjectAnalysis {
    Write-ColorOutput "阶段 0: 智能分析项目" "Stage"

    Set-Location $script:PROJECT_DIR

    $script:PROJECT_NAME = Split-Path $script:PROJECT_DIR -Leaf
    Write-ColorOutput "项目名称: $script:PROJECT_NAME" "Analysis"

    Get-Languages
    Get-TechStack
    Get-ProjectType
    Get-DirectoryStructure
    Get-MainFiles
    Show-AnalysisReport

    Start-Sleep -Seconds 1
}

# [保留原有的分析函数 - Get-Languages, Get-TechStack 等]
# 为了简洁,这里省略,实际脚本中需要包含

# 分析编程语言
function Get-Languages {
    Write-ColorOutput "正在分析编程语言..." "Info"
    $langs = @()

    if ((Test-Path "package.json") -or (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.js","*.ts","*.jsx","*.tsx" -ErrorAction SilentlyContinue)) {
        $langs += "JavaScript/TypeScript"
    }
    if ((Test-Path "requirements.txt") -or (Test-Path "setup.py") -or (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.py" -ErrorAction SilentlyContinue)) {
        $langs += "Python"
    }
    if ((Test-Path "pom.xml") -or (Test-Path "build.gradle") -or (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.java" -ErrorAction SilentlyContinue)) {
        $langs += "Java"
    }
    if ((Test-Path "go.mod") -or (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.go" -ErrorAction SilentlyContinue)) {
        $langs += "Go"
    }
    if (Get-ChildItem -Path . -Recurse -Depth 3 -Include "*.c","*.cpp","*.h","*.hpp" -ErrorAction SilentlyContinue) {
        $langs += "C/C++"
    }

    $script:LANGUAGES = if ($langs.Count -eq 0) { "未检测到" } else { $langs -join ", " }
    Write-ColorOutput "检测到的语言: $script:LANGUAGES" "Analysis"
}

function Get-TechStack {
    Write-ColorOutput "正在分析技术栈..." "Info"
    $frameworks = @()
    $databases = @()

    if (Test-Path "package.json") {
        $packageJson = Get-Content "package.json" -Raw
        if ($packageJson -match "react") { $frameworks += "React"; $script:HAS_FRONTEND = $true }
        if ($packageJson -match "vue") { $frameworks += "Vue"; $script:HAS_FRONTEND = $true }
        if ($packageJson -match "express") { $frameworks += "Express"; $script:HAS_BACKEND = $true; $script:HAS_API = $true }
        if ($packageJson -match "mysql|mysql2") { $databases += "MySQL"; $script:HAS_DATABASE = $true }
        if ($packageJson -match "pg|postgres") { $databases += "PostgreSQL"; $script:HAS_DATABASE = $true }
    }

    $script:FRAMEWORKS = if ($frameworks.Count -eq 0) { "未检测到" } else { $frameworks -join ", " }
    $script:DATABASES = if ($databases.Count -eq 0) { "未检测到" } else { $databases -join ", " }
}

function Get-ProjectType {
    if ($script:HAS_FRONTEND -and $script:HAS_BACKEND) {
        $script:PROJECT_TYPE = "全栈 Web 应用"
    } elseif ($script:HAS_FRONTEND) {
        $script:PROJECT_TYPE = "前端应用"
    } elseif ($script:HAS_BACKEND) {
        $script:PROJECT_TYPE = "后端服务"
    } else {
        $script:PROJECT_TYPE = "通用软件项目"
    }
}

function Get-DirectoryStructure {
    $excludeDirs = @("node_modules", "__pycache__", ".git", "dist", "build", "target", "venv")
    $dirs = Get-ChildItem -Path $script:PROJECT_DIR -Directory -Recurse -Depth 3 -ErrorAction SilentlyContinue |
            Where-Object { $dirName = $_.Name; -not ($excludeDirs | Where-Object { $dirName -eq $_ }) } |
            Select-Object -First 50 -ExpandProperty FullName
    $script:DIRECTORY_STRUCTURE = $dirs -join "`n"
}

function Get-MainFiles {
    $files = @()
    @("package.json", "requirements.txt", "pom.xml", "README.md", "index.js", "main.py") | ForEach-Object {
        if (Test-Path $_) { $files += $_ }
    }
    $script:MAIN_FILES = $files -join "`n"
}

function Show-AnalysisReport {
    Write-ColorOutput "项目分析报告" "Stage"
    Write-Host "项目名称: $script:PROJECT_NAME"
    Write-Host "项目类型: $script:PROJECT_TYPE"
    Write-Host "编程语言: $script:LANGUAGES"
    Write-Host "框架: $script:FRAMEWORKS"
}

# ============================================
# 改进 1: 深度分析 - 直接读取 .md 文件
# ============================================
function Invoke-DeepAnalysis-Improved {
    if (-not $script:DEEP_ANALYSIS) {
        Write-ColorOutput "跳过深度分析 (使用 -Deep 参数启用)" "Info"
        return $null
    }

    Write-ColorOutput "阶段 0.5: 深度代码分析 (改进版)" "Stage"

    # 1. 查找 skill 文件
    $skillPaths = @(
        ".claude\skills\project-deep-analyzer.md",
        "$env:USERPROFILE\.claude\skills\project-deep-analyzer.md"
    )

    $skillPath = $null
    foreach ($path in $skillPaths) {
        if (Test-Path $path) {
            $skillPath = $path
            break
        }
    }

    if (-not $skillPath) {
        Write-ColorOutput "未找到深度分析模板文件" "Warning"
        Write-ColorOutput "查找路径:" "Info"
        $skillPaths | ForEach-Object { Write-ColorOutput "  - $_" "Info" }
        Write-ColorOutput "将使用基础分析模式" "Warning"
        return $null
    }

    # 2. 直接读取 skill 文件内容作为 prompt 模板
    Write-ColorOutput "正在加载深度分析模板: $skillPath" "Info"
    $skillTemplate = Get-Content $skillPath -Raw -Encoding UTF8
    Write-ColorOutput "模板加载成功 ($($skillTemplate.Length) 字符)" "Success"

    # 3. 构建完整的 prompt (不依赖 skill 机制)
    $prompt = @"
$skillTemplate

---

# 项目深度分析任务

请深度分析以下项目并生成详细报告:

## 项目基本信息
- **项目路径**: $script:PROJECT_DIR
- **项目名称**: $script:PROJECT_NAME
- **项目类型**: $script:PROJECT_TYPE
- **编程语言**: $script:LANGUAGES
- **框架**: $script:FRAMEWORKS
- **数据库**: $script:DATABASES

## 分析要求

请执行以下分析任务:

1. **文件扫描**: 扫描所有源代码文件,提取:
   - 文件路径
   - 文件类型
   - 行数
   - 包含的类名
   - 包含的函数名
   - 文件功能描述

2. **API 端点识别**: 识别所有 API 端点,包括:
   - HTTP 方法 (GET/POST/PUT/DELETE)
   - 路径
   - 所在文件和行号
   - 功能描述
   - 参数列表
   - 返回值类型

3. **数据模型识别**: 识别所有数据模型,包括:
   - 模型名称
   - 所在文件和行号
   - 字段列表 (名称、类型、描述)
   - 关系 (一对多、多对多等)
   - 用途说明

4. **业务流程识别**: 识别主要业务流程,包括:
   - 流程名称
   - 涉及的模块
   - 流程步骤
   - 数据流向

## 输出格式

请将分析结果保存为 JSON 格式到 `.analysis-report.json` 文件,结构如下:

\`\`\`json
{
  "files": [
    {
      "path": "相对路径",
      "type": "文件类型",
      "lines": 行数,
      "classes": ["类名1", "类名2"],
      "functions": ["函数名1", "函数名2"],
      "description": "文件功能描述",
      "dependencies": ["依赖文件1", "依赖文件2"]
    }
  ],
  "apis": [
    {
      "method": "GET",
      "path": "/api/endpoint",
      "file": "文件路径:行号",
      "description": "功能描述",
      "parameters": ["参数1", "参数2"],
      "response": "返回值类型",
      "auth": "认证方式"
    }
  ],
  "models": [
    {
      "name": "模型名称",
      "file": "文件路径:行号",
      "type": "Entity/DTO/VO",
      "fields": [
        {
          "name": "字段名",
          "type": "字段类型",
          "description": "字段描述"
        }
      ],
      "relationships": ["关系描述"],
      "purpose": "用途说明"
    }
  ],
  "flows": [
    {
      "name": "流程名称",
      "modules": ["模块1", "模块2"],
      "steps": ["步骤1", "步骤2"],
      "dataFlow": "数据流向描述"
    }
  ],
  "statistics": {
    "total_files": 0,
    "total_endpoints": 0,
    "total_models": 0,
    "total_flows": 0,
    "code_files_analyzed": 0
  }
}
\`\`\`

现��开始分析...
"@

    # 4. 保存 prompt 到临时文件 (便于调试)
    $tempPromptPath = Join-Path $env:TEMP "deep-analysis-prompt-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    Set-Content -Path $tempPromptPath -Value $prompt -Encoding UTF8
    Write-ColorOutput "Prompt 已保存到: $tempPromptPath" "Info"

    # 5. 检查 claude 命令是否可用
    try {
        $claudeVersion = claude --version 2>&1
        Write-ColorOutput "Claude CLI 版本: $claudeVersion" "Info"
    } catch {
        Write-ColorOutput "未找到 claude 命令" "Error"
        Write-ColorOutput "深度分析需要 Claude Code CLI" "Info"
        Write-ColorOutput "将使用基础分析模式" "Warning"
        return $null
    }

    # 6. 执行深度分析
    Write-ColorOutput "正在执行深度分析 (这可能需要 2-5 分钟)..." "Info"
    Write-ColorOutput "请耐心等待..." "Warning"

    try {
        $output = claude -p $prompt 2>&1
        Write-ColorOutput "深度分析执行完成" "Success"

        # 7. 检查分析报告是否生成
        $reportPath = Join-Path $script:PROJECT_DIR ".analysis-report.json"

        if (Test-Path $reportPath) {
            Write-ColorOutput "分析报告已生成: $reportPath" "Success"

            # 8. 读取并解析报告
            try {
                $report = Get-Content $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json
                Write-ColorOutput "分析报告解析成功" "Success"

                # 显示统计信息
                Write-Host "`n分析统计:" -ForegroundColor Cyan
                Write-Host "  文件总数: $($report.statistics.total_files)"
                Write-Host "  API 端点: $($report.statistics.total_endpoints)"
                Write-Host "  数据模型: $($report.statistics.total_models)"
                Write-Host "  业务流程: $($report.statistics.total_flows)"
                Write-Host "  已分析文件: $($report.statistics.code_files_analyzed)"

                return $report  # 返回结构化数据

            } catch {
                Write-ColorOutput "无法解析分析报告: $_" "Error"
                Write-ColorOutput "将使用基础分析模式" "Warning"
                return $null
            }

        } else {
            Write-ColorOutput "未生成分析报告文件" "Warning"
            Write-ColorOutput "Claude 输出:" "Info"
            Write-Host $output
            Write-ColorOutput "将使用基础分析模式" "Warning"
            return $null
        }

    } catch {
        Write-ColorOutput "深度分析执行失败: $_" "Error"
        Write-ColorOutput "将使用基础分析模式" "Warning"
        return $null
    }
}

# ============================================
# 改进 2: 增强的文件功能列表生成
# ============================================
function New-FileFunctionsDocument-Enhanced {
    param($analysisReport)

    Write-ColorOutput "正在生成增强版文件功能列表..." "Info"

    if ($analysisReport -and $analysisReport.files) {
        # 使用深度分析数据
        Write-ColorOutput "使用深度分析数据生成文件列表" "Success"
        New-FileFunctionsWithAnalysis $analysisReport
    } else {
        # 使用基础扫描
        Write-ColorOutput "使用基础扫描生成文件列表" "Info"
        New-FileFunctionsBasic
    }
}

function New-FileFunctionsWithAnalysis {
    param($report)

    $content = @"
# $script:PROJECT_NAME - 文件功能列表

> 本文档基于深度代码分析自动生成
> 生成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## 1. 项目结构概览

``````
$script:DIRECTORY_STRUCTURE
``````

## 2. 核心文件详细说明

"@

    # 按文件类型分组
    $filesByType = $report.files | Group-Object -Property type

    foreach ($typeGroup in $filesByType) {
        $content += @"

### 2.$($filesByType.IndexOf($typeGroup) + 1) $($typeGroup.Name) 文件

"@

        foreach ($file in $typeGroup.Group) {
            $content += @"

#### ``$($file.path)``
- **类型**: $($file.type)
- **行数**: $($file.lines)
"@

            if ($file.classes -and $file.classes.Count -gt 0) {
                $content += "`n- **包含类**: $($file.classes -join ', ')"
            }

            if ($file.functions -and $file.functions.Count -gt 0) {
                $funcList = $file.functions | Select-Object -First 10
                $content += "`n- **主要函数**: $($funcList -join ', ')"
                if ($file.functions.Count -gt 10) {
                    $content += " (共 $($file.functions.Count) 个)"
                }
            }

            if ($file.description) {
                $content += "`n- **功能**: $($file.description)"
            }

            if ($file.dependencies -and $file.dependencies.Count -gt 0) {
                $content += "`n- **依赖**: $($file.dependencies -join ', ')"
            }

            $content += "`n"
        }
    }

    # 添加 API 端点列表
    if ($report.apis -and $report.apis.Count -gt 0) {
        $content += @"

## 3. API 端点列表

"@

        foreach ($api in $report.apis) {
            $content += @"

### $($api.method) $($api.path)
- **文件**: ``$($api.file)``
- **功能**: $($api.description)
- **参数**: $($api.parameters -join ', ')
- **返回**: $($api.response)
- **认证**: $($api.auth)

"@
        }
    }

    # 添加数据模型列表
    if ($report.models -and $report.models.Count -gt 0) {
        $content += @"

## 4. 数据模型列表

"@

        foreach ($model in $report.models) {
            $content += @"

### $($model.name)
- **文件**: ``$($model.file)``
- **类型**: $($model.type)
- **字段**:
"@

            foreach ($field in $model.fields) {
                $content += "`n  - ``$($field.name)``: $($field.type) - $($field.description)"
            }

            if ($model.relationships -and $model.relationships.Count -gt 0) {
                $content += "`n- **关系**: $($model.relationships -join ', ')"
            }

            $content += "`n- **用途**: $($model.purpose)`n"
        }
    }

    $content += @"

---

*文档版本: v2.0 (深度分析版)*
*创建日期: $(Get-Date -Format 'yyyy-MM-dd')*
*分析文件数: $($report.statistics.code_files_analyzed)*
"@

    $filePath = Join-Path $script:PROJECT_DIR "file-functions.md"
    Set-Content -Path $filePath -Value $content -Encoding UTF8

    Write-ColorOutput "增强版文件功能列表生成成功" "Success"
}

function New-FileFunctionsBasic {
    # 基础扫描模式 - 扫描实际文件
    Write-ColorOutput "正在扫描源代码文件..." "Info"

    $sourceFiles = Get-ChildItem -Path $script:PROJECT_DIR -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -match '\.(ps1|js|ts|jsx|tsx|py|java|go|rs|php|rb|c|cpp|h|hpp)$' -and
            $_.FullName -notmatch '(node_modules|__pycache__|\.git|dist|build|target|venv|\.venv)'
        } |
        Select-Object -First 50

    $content = @"
# $script:PROJECT_NAME - 文件功能列表

> 本文档基于基础文件扫描生成
> 生成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
> 提示: 使用 -Deep 参数可获得更详细的分析

## 1. 项目结构概览

``````
$script:DIRECTORY_STRUCTURE
``````

## 2. 源代码文件列表

"@

    $index = 1
    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Replace($script:PROJECT_DIR, "").TrimStart('\')
        $lineCount = (Get-Content $file.FullName -ErrorAction SilentlyContinue).Count

        $content += @"

### 2.$index ``$relativePath``
- **类型**: $($file.Extension) 文件
- **大小**: $([math]::Round($file.Length / 1KB, 2)) KB
- **行数**: $lineCount
- **最后修改**: $($file.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))

"@
        $index++
    }

    $content += @"

---

*文档版本: v2.0 (基础扫描版)*
*创建日期: $(Get-Date -Format 'yyyy-MM-dd')*
*扫描文件数: $($sourceFiles.Count)*
*提示: 使用 ``.\generate-docs-smart-v2.ps1 -Deep`` 获得详细分析*
"@

    $filePath = Join-Path $script:PROJECT_DIR "file-functions.md"
    Set-Content -Path $filePath -Value $content -Encoding UTF8

    Write-ColorOutput "基础版文件功能列表生成成功" "Success"
}

# [保留其他文档生成函数...]
# 为简洁省略,实际需要包含所有原有函数

# 主函数
function Main {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   智能文档生成脚本 v2.0 (改进版)      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝`n" -ForegroundColor Cyan

    Test-ProjectDirectory
    Invoke-ProjectAnalysis

    # 执行深度分析 (改进版)
    $script:ANALYSIS_REPORT = Invoke-DeepAnalysis-Improved

    # 生成文档 (使用深度分析结果)
    New-FileFunctionsDocument-Enhanced $script:ANALYSIS_REPORT

    Write-ColorOutput "所有文档生成完成!" "Success"

    if ($script:ANALYSIS_REPORT) {
        Write-ColorOutput "已使用深度分析数据生成文档" "Success"
    } else {
        Write-ColorOutput "已使用基础模式生成文档" "Info"
        Write-ColorOutput "提示: 使用 -Deep 参数可获得更详细的分析" "Info"
    }
}

# 执行
Main
