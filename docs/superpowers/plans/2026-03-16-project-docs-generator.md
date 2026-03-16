# 项目文档生成器实现计划

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 PowerShell 脚本工具，自动分析项目代码并生成四种详细文档（需求说明书、文件功能列表、全景图、流程图）

**Architecture:** 主脚本 generate-project-docs.ps1 复用现有的技术栈检测函数，新增深度分析函数（项目结构、业务模块、文件扫描），调用 Claude API 生成四种文档，包含完整的验证和错误处理机制。批量处理脚本支持多项目文档生成。

**Tech Stack:** PowerShell 5.1+, Claude CLI, PlantUML

---

## 文件结构

本实现将创建以下文件：

**核心脚本**:
- `lib/project-analysis-common.ps1` - 共享函数库（从 regenerate-claude-md.ps1 提取）
- `generate-project-docs.ps1` - 主文档生成脚本
- `batch-generate-project-docs.ps1` - 批量处理脚本

**输出文档**（由脚本生成）:
- `docs/PROJECT-REQUIREMENTS.md` - 项目需求说明书
- `docs/PROJECT-FILES.md` - 项目文件功能列表
- `docs/PROJECT-OVERVIEW.puml` - 项目全景图
- `docs/MODULE-FLOWCHART.puml` - 模块流程图

**日志**:
- `logs/generate-docs-error.log` - 错误日志

---

## Chunk 1: 共享函数库和脚本框架

### Task 1: 创建共享函数库

**Files:**
- Create: `lib/project-analysis-common.ps1`

- [ ] **Step 1: 创建共享函数库文件头部**

创建文件并添加基本结构和辅助函数。

- [ ] **Step 2: 添加技术栈检测函数**

从 regenerate-claude-md.ps1 复制 Detect-TechStack 函数，并扩展支持 Go 和 Rust。

- [ ] **Step 3: 添加项目描述和命令提取函数**

从 regenerate-claude-md.ps1 复制 Get-ProjectDescription, Get-KeyCommands, Get-KeyDirectories 函数。

- [ ] **Step 4: 测试共享函数库**

运行: `. .\lib\project-analysis-common.ps1; Detect-TechStack -Path "."`

预期: 成功加载并检测当前项目技术栈

- [ ] **Step 5: 提交共享函数库**

```bash
git add lib/project-analysis-common.ps1
git commit -m "feat: 创建项目分析共享函数库

- 提取技术栈检测、项目描述、命令提取等函数
- 支持 TypeScript, Python, Java, C++, C#, VB.NET, Go, Rust
- 为多个脚本提供共享基础

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 2: 创建主脚本框架

**Files:**
- Create: `generate-project-docs.ps1`

- [ ] **Step 1: 创建脚本参数定义**

```powershell
# generate-project-docs.ps1
# 项目文档生成器 - 自动分析项目并生成详细文档

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,

    [Parameter(Mandatory=$false)]
    [string]$OutputDir = ".\docs",

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

# 设置错误处理
$ErrorActionPreference = "Stop"

# 加载共享函数库
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\lib\project-analysis-common.ps1"
```

- [ ] **Step 2: 添加参数验证**

```powershell
# ============================================
# 参数验证
# ============================================

Write-Step "验证参数"

# 验证项目路径
if (-not (Test-Path $ProjectPath)) {
    Write-Error "项目路径不存在: $ProjectPath"
    exit 1
}

$ProjectPath = Resolve-Path $ProjectPath
Write-Info "项目路径: $ProjectPath"

# 验证输出目录
if ($DryRun) {
    $OutputDir = Join-Path $env:TEMP "project-docs-preview"
    Write-Info "DryRun 模式: 输出到临时目录 $OutputDir"
} else {
    Write-Info "输出目录: $OutputDir"
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Success "创建输出目录"
}

# 创建日志目录
$logDir = ".\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}
```

- [ ] **Step 3: 添加主流程框架**

```powershell
# ============================================
# 主流程
# ============================================

try {
    Write-Step "开始分析项目"

    # 1. 检测技术栈
    $techStack = Detect-TechStack -Path $ProjectPath

    # 2. 获取项目描述
    $projectDesc = Get-ProjectDescription -Path $ProjectPath

    # 3. 获取关键目录
    $keyDirs = Get-KeyDirectories -Path $ProjectPath

    # 4. 获取关键命令
    $keyCommands = Get-KeyCommands -Path $ProjectPath -TechStack $techStack

    Write-Step "项目分析完成"
    Write-Info "技术栈: $($techStack -join ', ')"
    Write-Info "项目描述: $projectDesc"
    Write-Info "关键目录: $($keyDirs.Count) 个"
    Write-Info "关键命令: $($keyCommands.Count) 个"

    # TODO: 添加深度分析和文档生成

    Write-Step "完成"
    Write-Success "所有文档已生成到: $OutputDir"

} catch {
    Write-Error "执行失败: $_"
    $_ | Out-File -FilePath "$logDir\generate-docs-error.log" -Append
    exit 1
}
```

- [ ] **Step 4: 测试脚本框架**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

预期: 成功执行参数验证和基本分析，输出项目信息

- [ ] **Step 5: 提交脚本框架**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 创建文档生成器脚本框架

- 参数定义和验证
- 加载共享函数库
- 基本项目分析流程
- 错误处理和日志记录

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

## Chunk 2: 深度项目分析函数

### Task 3: 实现项目结构分析

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Analyze-ProjectStructure 函数**

```powershell
# ============================================
# 项目结构分析
# ============================================

function Analyze-ProjectStructure {
    param([string]$Path, [array]$TechStack)

    Write-Info "分析项目结构..."

    $structure = @{
        ProjectType = "Unknown"
        EntryFiles = @()
        ConfigFiles = @()
    }

    # 识别项目类型
    if ($TechStack -contains "typescript/nodejs") {
        $structure.ProjectType = "Node.js/TypeScript"

        # 查找入口文件
        $entryFiles = @("index.ts", "index.js", "main.ts", "main.js", "app.ts", "app.js", "server.ts", "server.js")
        foreach ($file in $entryFiles) {
            if (Test-Path "$Path\$file") {
                $structure.EntryFiles += $file
            }
            if (Test-Path "$Path\src\$file") {
                $structure.EntryFiles += "src\$file"
            }
        }

        # 配置文件
        $structure.ConfigFiles += "package.json"
        if (Test-Path "$Path\tsconfig.json") { $structure.ConfigFiles += "tsconfig.json" }
    }

    if ($TechStack -contains "python") {
        $structure.ProjectType = "Python"

        # 查找入口文件
        $entryFiles = @("main.py", "app.py", "manage.py", "__main__.py")
        foreach ($file in $entryFiles) {
            if (Test-Path "$Path\$file") {
                $structure.EntryFiles += $file
            }
        }

        # 配置文件
        if (Test-Path "$Path\requirements.txt") { $structure.ConfigFiles += "requirements.txt" }
        if (Test-Path "$Path\setup.py") { $structure.ConfigFiles += "setup.py" }
        if (Test-Path "$Path\pyproject.toml") { $structure.ConfigFiles += "pyproject.toml" }
    }

    if ($TechStack -contains "java-maven") {
        $structure.ProjectType = "Java Maven"
        $structure.ConfigFiles += "pom.xml"
    }

    if ($TechStack -contains "java-gradle") {
        $structure.ProjectType = "Java Gradle"
        $structure.ConfigFiles += "build.gradle"
    }

    if ($TechStack -contains "cpp") {
        $structure.ProjectType = "C++"
        if (Test-Path "$Path\CMakeLists.txt") { $structure.ConfigFiles += "CMakeLists.txt" }
    }

    if ($TechStack -contains "csharp") {
        $structure.ProjectType = "C#"
        $csprojFiles = Get-ChildItem -Path $Path -Filter "*.csproj" -ErrorAction SilentlyContinue
        foreach ($file in $csprojFiles) {
            $structure.ConfigFiles += $file.Name
        }
    }

    if ($TechStack -contains "go") {
        $structure.ProjectType = "Go"
        $structure.ConfigFiles += "go.mod"
        if (Test-Path "$Path\main.go") { $structure.EntryFiles += "main.go" }
    }

    if ($TechStack -contains "rust") {
        $structure.ProjectType = "Rust"
        $structure.ConfigFiles += "Cargo.toml"
        if (Test-Path "$Path\src\main.rs") { $structure.EntryFiles += "src\main.rs" }
    }

    Write-Info "  项目类型: $($structure.ProjectType)"
    Write-Info "  入口文件: $($structure.EntryFiles.Count) 个"
    Write-Info "  配置文件: $($structure.ConfigFiles.Count) 个"

    return $structure
}
```

- [ ] **Step 2: 在主流程中调用**

在主流程的 "获取关键命令" 之后添加：

```powershell
# 5. 分析项目结构
$projectStructure = Analyze-ProjectStructure -Path $ProjectPath -TechStack $techStack
```

- [ ] **Step 3: 测试项目结构分析**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun -Verbose`

预期: 输出项目类型、入口文件和配置文件信息

- [ ] **Step 4: 提交项目结构分析**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加项目结构分析功能

- 识别项目类型（Web应用、库、CLI工具等）
- 定位主要入口文件
- 识别配置文件
- 支持多种技术栈

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 4: 实现文件扫描功能

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Scan-ProjectFiles 函数**

```powershell
# ============================================
# 文件扫描
# ============================================

function Scan-ProjectFiles {
    param([string]$Path, [array]$TechStack)

    Write-Info "扫描项目文件..."

    # 排除的目录
    $excludeDirs = @(
        'node_modules', '.git', '.venv', 'venv', '__pycache__',
        'bin', 'obj', 'target', 'build', 'dist', '.next',
        'coverage', '.pytest_cache', '.idea', '.vscode', 'vendor'
    )

    # 排除的文件类型
    $excludeExtensions = @('.min.js', '.map', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2', '.ttf', '.eot')

    $files = @{
        SourceFiles = @()
        TestFiles = @()
        ConfigFiles = @()
        TotalCount = 0
        TotalSize = 0
    }

    # 递归扫描文件
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $file = $_
        $relativePath = $file.FullName.Substring($Path.Length + 1)

        # 检查是否在排除目录中
        $inExcludedDir = $false
        foreach ($excludeDir in $excludeDirs) {
            if ($relativePath -like "$excludeDir\*" -or $relativePath -like "*\$excludeDir\*") {
                $inExcludedDir = $true
                break
            }
        }

        if ($inExcludedDir) { return }

        # 检查文件扩展名
        $ext = $file.Extension.ToLower()
        if ($excludeExtensions -contains $ext) { return }

        # 分类文件
        $fileInfo = @{
            Path = $relativePath
            Size = $file.Length
            Lines = 0
            Extension = $ext
        }

        # 计算行数（只读取前100行用于性能优化）
        try {
            $content = Get-Content $file.FullName -TotalCount 100 -ErrorAction SilentlyContinue
            $fileInfo.Lines = $content.Count
        } catch {
            $fileInfo.Lines = 0
        }

        # 判断是否为测试文件
        if ($relativePath -match '(test|spec|__tests__|tests)' -or $file.Name -match '(test|spec)\.') {
            $files.TestFiles += $fileInfo
        }
        # 判断是否为源代码文件
        elseif ($ext -in @('.ts', '.js', '.py', '.java', '.cpp', '.c', '.h', '.hpp', '.cs', '.vb', '.go', '.rs')) {
            $files.SourceFiles += $fileInfo
        }
        # 配置文件
        elseif ($ext -in @('.json', '.yaml', '.yml', '.toml', '.xml', '.config')) {
            $files.ConfigFiles += $fileInfo
        }

        $files.TotalCount++
        $files.TotalSize += $file.Length
    }

    Write-Info "  源代码文件: $($files.SourceFiles.Count) 个"
    Write-Info "  测试文件: $($files.TestFiles.Count) 个"
    Write-Info "  配置文件: $($files.ConfigFiles.Count) 个"
    Write-Info "  总文件数: $($files.TotalCount) 个"
    Write-Info "  总大小: $([math]::Round($files.TotalSize / 1MB, 2)) MB"

    return $files
}
```

- [ ] **Step 2: 在主流程中调用**

```powershell
# 6. 扫描项目文件
$projectFiles = Scan-ProjectFiles -Path $ProjectPath -TechStack $techStack
```

- [ ] **Step 3: 测试文件扫描**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun -Verbose`

预期: 输出文件统计信息，正确分类源代码、测试和配置文件

- [ ] **Step 4: 提交文件扫描功能**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加项目文件扫描功能

- 递归扫描所有源代码文件
- 排除 node_modules, build 等目录
- 按类型分类（源代码、测试、配置）
- 记录文件大小和行数

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 5: 实现业务模块识别

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Identify-BusinessModules 函数（第一部分：文件名模式识别）**

```powershell
# ============================================
# 业务模块识别
# ============================================

function Identify-BusinessModules {
    param([string]$Path, [array]$TechStack, [hashtable]$ProjectFiles)

    Write-Info "识别业务模块..."

    $modules = @()

    # 通用命名模式
    $patterns = @{
        Controller = @('*Controller.java', '*Controller.ts', '*Controller.js', '*Controller.cs', '*controller.py')
        Service = @('*Service.java', '*Service.ts', '*Service.js', '*Service.cs', '*service.py')
        Repository = @('*Repository.java', '*Mapper.java', '*Dao.java', '*repository.py')
        Model = @('*Entity.java', '*Model.java', '*model.py', '*models.py', '*.entity.ts')
        Util = @('*Util.java', '*Helper.java', '*Utils.ts', '*utils.py')
        Handler = @('*Handler.java', '*Handler.ts', '*handler.py')
    }

    # 按模式查找文件
    foreach ($patternType in $patterns.Keys) {
        $matchedFiles = @()
        foreach ($pattern in $patterns[$patternType]) {
            $found = $ProjectFiles.SourceFiles | Where-Object { $_.Path -like "*$pattern" }
            $matchedFiles += $found
        }

        if ($matchedFiles.Count -gt 0) {
            Write-Info "  发现 $patternType: $($matchedFiles.Count) 个文件"
        }
    }

    # 基于目录结构识别模块
    $topLevelDirs = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @('node_modules', '.git', 'build', 'dist', 'target', 'bin', 'obj') }

    foreach ($dir in $topLevelDirs) {
        $module = @{
            Name = $dir.Name
            Path = $dir.FullName.Substring($Path.Length + 1)
            Files = @()
            Type = "Unknown"
        }

        # 判断模块类型
        if ($dir.Name -match '(controller|api|route)') {
            $module.Type = "Controller"
        } elseif ($dir.Name -match '(service|business|biz)') {
            $module.Type = "Service"
        } elseif ($dir.Name -match '(model|entity|domain)') {
            $module.Type = "Model"
        } elseif ($dir.Name -match '(util|helper|common)') {
            $module.Type = "Utility"
        } elseif ($dir.Name -match '(test|spec)') {
            $module.Type = "Test"
        }

        # 统计模块中的文件
        $moduleFiles = $ProjectFiles.SourceFiles | Where-Object { $_.Path -like "$($module.Path)\*" }
        $module.Files = $moduleFiles

        if ($module.Files.Count -gt 0) {
            $modules += $module
        }
    }

    Write-Info "  识别到 $($modules.Count) 个模块"

    return $modules
}
```

- [ ] **Step 2: 在主流程中调用**

```powershell
# 7. 识别业务模块
$businessModules = Identify-BusinessModules -Path $ProjectPath -TechStack $techStack -ProjectFiles $projectFiles
```

- [ ] **Step 3: 测试业务模块识别**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun -Verbose`

预期: 输出识别到的模块数量和类型

- [ ] **Step 4: 提交业务模块识别**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加业务模块识别功能

- 基于文件名模式识别（Controller, Service, Repository等）
- 基于目录结构划分模块
- 支持多种技术栈的命名约定
- 统计每个模块的文件数量

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

## Chunk 3: 文档生成功能

### Task 6: 实现需求说明书生成

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Generate-RequirementsDoc 函数**

```powershell
# ============================================
# 生成需求说明书
# ============================================

function Generate-RequirementsDoc {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [hashtable]$ProjectFiles,
        [string]$OutputPath
    )

    Write-Info "生成项目需求说明书..."

    # 准备输入数据
    $modulesInfo = $BusinessModules | ForEach-Object {
        "- 模块: $($_.Name) (类型: $($_.Type), 文件数: $($_.Files.Count))"
    } | Out-String

    $filesInfo = "总文件数: $($ProjectFiles.TotalCount), 源代码: $($ProjectFiles.SourceFiles.Count), 测试: $($ProjectFiles.TestFiles.Count)"

    # 构建 Claude 提示词
    $prompt = @"
你是一个软件需求分析专家。基于以下项目信息，生成详细的项目需求说明书（100-300行）。

项目信息:
- 项目描述: $ProjectDesc
- 技术栈: $($TechStack -join ', ')
- 文件统计: $filesInfo

业务模块:
$modulesInfo

任务要求:
1. 生成完整的 Markdown 格式需求说明书
2. 包含以下章节:
   - 项目概述（项目名称、描述、技术栈、项目类型）
   - 功能需求（按模块组织，每个需求包含编号FR-XXX、描述、实现文件）
   - 非功能需求（性能、安全、可扩展性）
   - 技术约束（语言版本、框架版本、依赖库）
   - 验收标准
3. 使用中文撰写
4. 功能需求要具体，基于识别的模块推断功能
5. 文档长度控制在 100-300 行

请直接输出完整的 Markdown 文档，不要有任何前缀或后缀说明。
"@

    # 调用 Claude
    try {
        Write-Info "  调用 Claude API..."
        $content = claude -p $prompt

        if (-not $content) {
            throw "Claude 返回空内容"
        }

        # 保存文档
        $content | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Success "需求说明书已生成: $OutputPath"

        return $true
    } catch {
        Write-Warning-Custom "生成需求说明书失败: $_"

        # 降级方案：生成简化版
        Write-Info "  使用降级方案生成简化版..."
        $fallbackContent = @"
# 项目需求说明书

## 1. 项目概述
- 项目描述: $ProjectDesc
- 技术栈: $($TechStack -join ', ')
- 文件统计: $filesInfo

## 2. 功能需求

$($BusinessModules | ForEach-Object {
"### 2.$($BusinessModules.IndexOf($_) + 1) $($_.Name)
- 模块类型: $($_.Type)
- 文件数: $($_.Files.Count)
- 主要文件: $($_.Files | Select-Object -First 3 | ForEach-Object { $_.Path } | Out-String)
"
})

## 3. 非功能需求
（需要手动补充）

## 4. 技术约束
- 技术栈: $($TechStack -join ', ')

## 5. 验收标准
（需要手动补充）

---
注意: 此文档由静态分析生成，建议手动审查和补充。
"@
        $fallbackContent | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Warning-Custom "已生成简化版需求说明书（需手动补充）"
        return $false
    }
}
```

- [ ] **Step 2: 在主流程中调用**

```powershell
# 8. 生成需求说明书
$reqDocPath = Join-Path $OutputDir "PROJECT-REQUIREMENTS.md"
$reqSuccess = Generate-RequirementsDoc `
    -ProjectPath $ProjectPath `
    -ProjectDesc $projectDesc `
    -TechStack $techStack `
    -BusinessModules $businessModules `
    -ProjectFiles $projectFiles `
    -OutputPath $reqDocPath
```

- [ ] **Step 3: 测试需求说明书生成**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

预期: 生成 PROJECT-REQUIREMENTS.md 文件，包含项目概述和功能需求

- [ ] **Step 4: 提交需求说明书生成功能**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加需求说明书生成功能

- 调用 Claude API 分析项目并生成需求文档
- 包含项目概述、功能需求、非功能需求等章节
- 提供降级方案（静态分析）
- 输出 100-300 行的详细文档

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 7: 实现文件功能列表生成

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Generate-FilesDoc 函数**

```powershell
# ============================================
# 生成文件功能列表
# ============================================

function Generate-FilesDoc {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [hashtable]$ProjectFiles,
        [string]$OutputPath
    )

    Write-Info "生成项目文件功能列表..."

    # 准备文件列表（限制数量以避免超过 token 限制）
    $maxFiles = 200
    $sourceFilesList = $ProjectFiles.SourceFiles | Select-Object -First $maxFiles | ForEach-Object {
        "- $($_.Path) ($($_.Lines) 行)"
    } | Out-String

    $modulesInfo = $BusinessModules | ForEach-Object {
        $moduleFiles = $_.Files | Select-Object -First 10 | ForEach-Object { $_.Path }
        "模块: $($_.Name) (类型: $($_.Type))
文件: $($moduleFiles -join ', ')"
    } | Out-String

    # 构建 Claude 提示词
    $prompt = @"
你是一个代码文档专家。基于以下项目信息，生成详细的项目文件功能列表。

项目信息:
- 项目描述: $ProjectDesc
- 技术栈: $($TechStack -join ', ')
- 总文件数: $($ProjectFiles.SourceFiles.Count)

业务模块:
$modulesInfo

源代码文件列表（前 $maxFiles 个）:
$sourceFilesList

任务要求:
1. 生成完整的 Markdown 格式文件功能列表
2. 包含以下章节:
   - 项目概述（项目类型、技术栈、项目结构）
   - 模块列表（按模块组织，每个模块包含功能描述、API接口、数据实体）
3. 为每个文件生成简短功能描述
4. 识别 API 接口和数据实体
5. 使用中文撰写

请直接输出完整的 Markdown 文档，不要有任何前缀或后缀说明。
"@

    # 调用 Claude
    try {
        Write-Info "  调用 Claude API..."
        $content = claude -p $prompt

        if (-not $content) {
            throw "Claude 返回空内容"
        }

        # 保存文档
        $content | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Success "文件功能列表已生成: $OutputPath"

        return $true
    } catch {
        Write-Warning-Custom "生成文件功能列表失败: $_"

        # 降级方案
        Write-Info "  使用降级方案生成简化版..."
        $fallbackContent = @"
# 项目文件功能列表

## 1. 项目概述
- 项目类型: $($TechStack -join ', ')
- 技术栈: $($TechStack -join ', ')
- 总文件数: $($ProjectFiles.SourceFiles.Count)

## 2. 模块列表

$($BusinessModules | ForEach-Object {
"### 2.$($BusinessModules.IndexOf($_) + 1) $($_.Name)

#### 功能描述
模块类型: $($_.Type)

#### 文件列表
$($_.Files | ForEach-Object { "- ``$($_.Path)``" } | Out-String)
"
})

---
注意: 此文档由静态分析生成，建议手动审查和补充文件功能描述。
"@
        $fallbackContent | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Warning-Custom "已生成简化版文件功能列表（需手动补充）"
        return $false
    }
}
```

- [ ] **Step 2: 在主流程中调用**

```powershell
# 9. 生成文件功能列表
$filesDocPath = Join-Path $OutputDir "PROJECT-FILES.md"
$filesSuccess = Generate-FilesDoc `
    -ProjectPath $ProjectPath `
    -ProjectDesc $projectDesc `
    -TechStack $techStack `
    -BusinessModules $businessModules `
    -ProjectFiles $projectFiles `
    -OutputPath $filesDocPath
```

- [ ] **Step 3: 测试文件功能列表生成**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

预期: 生成 PROJECT-FILES.md 文件，包含模块和文件列表

- [ ] **Step 4: 提交文件功能列表生成功能**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加文件功能列表生成功能

- 调用 Claude API 分析文件并生成功能描述
- 按模块组织文件列表
- 识别 API 接口和数据实体
- 提供降级方案

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 8: 实现项目全景图生成

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Generate-OverviewDiagram 函数**

```powershell
# ============================================
# 生成项目全景图
# ============================================

function Generate-OverviewDiagram {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [string]$OutputPath
    )

    Write-Info "生成项目全景图..."

    # 准备模块信息
    $modulesInfo = $BusinessModules | ForEach-Object {
        "- $($_.Name) (类型: $($_.Type), 文件数: $($_.Files.Count))"
    } | Out-String

    # 构建 Claude 提示词
    $prompt = @"
你是一个软件架构师。基于以下项目信息，生成 PlantUML 组件图，展示系统架构。

项目信息:
- 项目描述: $ProjectDesc
- 技术栈: $($TechStack -join ', ')

业务模块:
$modulesInfo

任务要求:
1. 生成完整的 PlantUML 组件图代码
2. 展示系统分层架构（表现层/业务层/数据层）
3. 展示主要组件及其依赖关系
4. 使用以下样式模板:

``````plantuml
@startuml 组件图-系统架构
skinparam backgroundColor #FFFFFF
skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

package "表现层" {
  [组件1] as comp1
}

package "业务层" {
  [组件2] as comp2
}

package "数据层" {
  [组件3] as comp3
}

database "Database" as db

comp1 --> comp2
comp2 --> comp3
comp3 --> db
@enduml
``````

5. 使用中文标注
6. 至少包含 3 层架构

请直接输出完整的 PlantUML 代码，不要有任何前缀或后缀说明。
"@

    # 调用 Claude
    try {
        Write-Info "  调用 Claude API..."
        $content = claude -p $prompt

        if (-not $content) {
            throw "Claude 返回空内容"
        }

        # 提取 PlantUML 代码块（如果 Claude 添加了说明文字）
        if ($content -match '(?s)```plantuml\s*(.+?)\s*```') {
            $content = $Matches[1]
        } elseif ($content -match '(?s)@startuml.+?@enduml') {
            # 已经是纯 PlantUML 代码
        } else {
            throw "无法识别 PlantUML 代码格式"
        }

        # 保存文档
        $content | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Success "项目全景图已生成: $OutputPath"

        return $true
    } catch {
        Write-Warning-Custom "生成项目全景图失败: $_"

        # 降级方案
        Write-Info "  使用降级方案生成基本结构图..."
        $fallbackContent = @"
@startuml 组件图-系统架构
skinparam backgroundColor #FFFFFF
skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

$($BusinessModules | ForEach-Object {
"package ""$($_.Name)"" {
  [模块组件] as $($_.Name -replace '\s','')
}
"
})

note right
  此图由静态分析生成
  建议手动补充组件关系
end note

@enduml
"@
        $fallbackContent | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Warning-Custom "已生成基本结构图（需手动补充）"
        return $false
    }
}
```

- [ ] **Step 2: 在主流程中调用**

```powershell
# 10. 生成项目全景图
$overviewPath = Join-Path $OutputDir "PROJECT-OVERVIEW.puml"
$overviewSuccess = Generate-OverviewDiagram `
    -ProjectPath $ProjectPath `
    -ProjectDesc $projectDesc `
    -TechStack $techStack `
    -BusinessModules $businessModules `
    -OutputPath $overviewPath
```

- [ ] **Step 3: 测试全景图生成**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

预期: 生成 PROJECT-OVERVIEW.puml 文件，包含 PlantUML 组件图代码

- [ ] **Step 4: 提交全景图生成功能**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加项目全景图生成功能

- 调用 Claude API 生成 PlantUML 组件图
- 展示系统分层架构和组件关系
- 使用 analyzer.md 的样式模板
- 提供降级方案

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 9: 实现模块流程图生成

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Generate-FlowchartDiagram 函数**

```powershell
# ============================================
# 生成模块流程图
# ============================================

function Generate-FlowchartDiagram {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [string]$OutputPath
    )

    Write-Info "生成模块流程图..."

    # 选择主要模块（最多5个）
    $mainModules = $BusinessModules | Where-Object { $_.Type -in @('Controller', 'Service') } | Select-Object -First 5

    $modulesInfo = $mainModules | ForEach-Object {
        "- $($_.Name) (类型: $($_.Type))"
    } | Out-String

    # 构建 Claude 提示词
    $prompt = @"
你是一个软件架构师。基于以下项目信息，生成 PlantUML 流程图，包含业务流程图和时序图。

项目信息:
- 项目描述: $ProjectDesc
- 技术栈: $($TechStack -join ', ')

主要业务模块:
$modulesInfo

任务要求:
1. 为每个主要模块生成业务流程图（活动图）
2. 为关键功能生成时序图
3. 在一个 .puml 文件中包含多个图表
4. 使用以下样式模板:

业务流程图模板:
``````plantuml
@startuml 业务流程图-模块名称
skinparam backgroundColor #FFFFFF
skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}
skinparam arrowColor #424242

start
:用户请求;
:处理逻辑;
:返回结果;
stop
@enduml
``````

时序图模板:
``````plantuml
@startuml 时序图-模块名称
skinparam backgroundColor #FFFFFF
skinparam sequenceMessageAlign center
skinparam participant {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

actor User as user
participant Controller as "Controller"
participant Service as "Service"
participant Database as "Database"

user -> Controller: 请求
Controller -> Service: 调用
Service -> Database: 查询
Database --> Service: 返回
Service --> Controller: 返回
Controller --> user: 响应
@enduml
``````

5. 使用中文标注
6. 至少生成 2 个业务流程图和 2 个时序图

请直接输出完整的 PlantUML 代码，不要有任何前缀或后缀说明。
"@

    # 调用 Claude
    try {
        Write-Info "  调用 Claude API..."
        $content = claude -p $prompt

        if (-not $content) {
            throw "Claude 返回空内容"
        }

        # 提取 PlantUML 代码块
        if ($content -match '(?s)```plantuml\s*(.+?)\s*```') {
            $content = $Matches[1]
        }

        # 保存文档
        $content | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Success "模块流程图已生成: $OutputPath"

        return $true
    } catch {
        Write-Warning-Custom "生成模块流程图失败: $_"

        # 降级方案
        Write-Info "  跳过流程图生成..."
        $fallbackContent = @"
@startuml 占位符
note
  流程图生成失败
  请手动补充业务流程图和时序图

  建议包含:
  - 业务流程图（活动图）
  - 时序图（展示组件交互）
end note
@enduml
"@
        $fallbackContent | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Warning-Custom "已生成占位符（需手动补充）"
        return $false
    }
}
```

- [ ] **Step 2: 在主流程中调用**

```powershell
# 11. 生成模块流程图
$flowchartPath = Join-Path $OutputDir "MODULE-FLOWCHART.puml"
$flowchartSuccess = Generate-FlowchartDiagram `
    -ProjectPath $ProjectPath `
    -ProjectDesc $projectDesc `
    -TechStack $techStack `
    -BusinessModules $businessModules `
    -OutputPath $flowchartPath
```

- [ ] **Step 3: 测试流程图生成**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

预期: 生成 MODULE-FLOWCHART.puml 文件，包含多个流程图和时序图

- [ ] **Step 4: 提交流程图生成功能**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加模块流程图生成功能

- 调用 Claude API 生成业务流程图和时序图
- 为每个主要模块生成流程图
- 使用 analyzer.md 的样式模板
- 在一个文件中包含多个图表

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

## Chunk 4: 文档验证和错误处理

### Task 10: 实现文档验证功能

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Validate-MarkdownDoc 函数**

```powershell
# ============================================
# 文档验证
# ============================================

function Validate-MarkdownDoc {
    param([string]$FilePath, [string]$DocType)

    Write-Info "验证 $DocType..."

    $issues = @()
    $warnings = @()

    if (-not (Test-Path $FilePath)) {
        $issues += "文件不存在"
        return @{ Valid = $false; Issues = $issues; Warnings = $warnings }
    }

    $content = Get-Content $FilePath -Raw
    $lines = $content -split "`n"

    # 长度验证
    $lineCount = $lines.Count
    if ($DocType -eq "需求说明书") {
        if ($lineCount -lt 100) {
            $warnings += "文档过短（$lineCount 行），建议至少 100 行"
        } elseif ($lineCount -gt 300) {
            $warnings += "文档过长（$lineCount 行），建议不超过 300 行"
        }
    } elseif ($DocType -eq "文件功能列表") {
        if ($lineCount -lt 50) {
            $warnings += "文档过短（$lineCount 行），建议至少 50 行"
        }
    }

    # 标题层级验证
    $headers = $lines | Where-Object { $_ -match '^#+\s' }
    $prevLevel = 0
    foreach ($header in $headers) {
        if ($header -match '^(#+)\s') {
            $level = $Matches[1].Length
            if ($prevLevel -eq 0 -and $level -ne 1) {
                $issues += "文档必须以 # 开头"
            }
            if ($level - $prevLevel -gt 1) {
                $warnings += "标题层级跳跃: $header"
            }
            $prevLevel = $level
        }
    }

    # 必需章节检查
    if ($DocType -eq "需求说明书") {
        $requiredSections = @("项目概述", "功能需求", "验收标准")
        foreach ($section in $requiredSections) {
            if ($content -notmatch $section) {
                $issues += "缺少必需章节: $section"
            }
        }
    } elseif ($DocType -eq "文件功能列表") {
        $requiredSections = @("项目概述", "模块列表")
        foreach ($section in $requiredSections) {
            if ($content -notmatch $section) {
                $issues += "缺少必需章节: $section"
            }
        }
    }

    $valid = $issues.Count -eq 0
    return @{
        Valid = $valid
        LineCount = $lineCount
        Issues = $issues
        Warnings = $warnings
    }
}

function Validate-PlantUMLDoc {
    param([string]$FilePath, [string]$DocType)

    Write-Info "验证 $DocType..."

    $issues = @()
    $warnings = @()

    if (-not (Test-Path $FilePath)) {
        $issues += "文件不存在"
        return @{ Valid = $false; Issues = $issues; Warnings = $warnings }
    }

    $content = Get-Content $FilePath -Raw

    # 语法验证
    $startumlCount = ([regex]::Matches($content, '@startuml')).Count
    $endumlCount = ([regex]::Matches($content, '@enduml')).Count

    if ($startumlCount -ne $endumlCount) {
        $issues += "@startuml/@enduml 不配对（$startumlCount vs $endumlCount）"
    }

    if ($startumlCount -eq 0) {
        $issues += "未找到 @startuml 标记"
    }

    # 结构验证
    if ($DocType -eq "项目全景图") {
        if ($content -notmatch 'package') {
            $warnings += "未找到 package 定义，建议至少包含 3 个 package"
        }
    } elseif ($DocType -eq "模块流程图") {
        if ($startumlCount -lt 2) {
            $warnings += "图表数量较少（$startumlCount 个），建议至少包含 2 个流程图"
        }
    }

    $valid = $issues.Count -eq 0
    return @{
        Valid = $valid
        DiagramCount = $startumlCount
        Issues = $issues
        Warnings = $warnings
    }
}
```

- [ ] **Step 2: 添加验证报告生成**

```powershell
# ============================================
# 生成验证报告
# ============================================

function Generate-ValidationReport {
    param([hashtable]$Results, [string]$OutputDir)

    Write-Step "生成验证报告"

    $report = @"
[验证报告]

"@

    foreach ($docType in $Results.Keys) {
        $result = $Results[$docType]
        $status = if ($result.Valid) { "✓" } else { "✗" }

        $report += "$status $docType"
        if ($result.LineCount) {
            $report += " ($($result.LineCount) 行)"
        } elseif ($result.DiagramCount) {
            $report += " ($($result.DiagramCount) 个图表)"
        }
        $report += "`n"

        if ($result.Issues.Count -gt 0) {
            $report += "  问题:`n"
            foreach ($issue in $result.Issues) {
                $report += "  - $issue`n"
            }
        }

        if ($result.Warnings.Count -gt 0) {
            $report += "  警告:`n"
            foreach ($warning in $result.Warnings) {
                $report += "  - $warning`n"
            }
        }
    }

    Write-Host $report
    return $report
}
```

- [ ] **Step 3: 在主流程中添加验证**

在文档生成完成后添加：

```powershell
# 12. 验证生成的文档
Write-Step "验证文档质量"

$validationResults = @{}

$validationResults["PROJECT-REQUIREMENTS.md"] = Validate-MarkdownDoc `
    -FilePath $reqDocPath `
    -DocType "需求说明书"

$validationResults["PROJECT-FILES.md"] = Validate-MarkdownDoc `
    -FilePath $filesDocPath `
    -DocType "文件功能列表"

$validationResults["PROJECT-OVERVIEW.puml"] = Validate-PlantUMLDoc `
    -FilePath $overviewPath `
    -DocType "项目全景图"

$validationResults["MODULE-FLOWCHART.puml"] = Validate-PlantUMLDoc `
    -FilePath $flowchartPath `
    -DocType "模块流程图"

$report = Generate-ValidationReport -Results $validationResults -OutputDir $OutputDir
```

- [ ] **Step 4: 测试文档验证**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

预期: 输出验证报告，显示每个文档的验证状态

- [ ] **Step 5: 提交文档验证功能**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 添加文档质量验证功能

- 验证 Markdown 文档（长度、格式、必需章节）
- 验证 PlantUML 文档（语法、结构）
- 生成详细的验证报告
- 区分错误和警告

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 11: 增强错误处理和重试机制

**Files:**
- Modify: `generate-project-docs.ps1`

- [ ] **Step 1: 添加 Invoke-ClaudeWithRetry 函数**

```powershell
# ============================================
# Claude API 调用（带重试）
# ============================================

function Invoke-ClaudeWithRetry {
    param(
        [string]$Prompt,
        [int]$MaxRetries = 3,
        [string]$Operation
    )

    $retryDelays = @(5, 10, 20)  # 秒

    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Write-Info "  调用 Claude API ($Operation, 尝试 $attempt/$MaxRetries)..."
            $result = claude -p $Prompt

            if (-not $result) {
                throw "Claude 返回空内容"
            }

            Write-Success "Claude API 调用成功"
            return $result

        } catch {
            $errorMsg = $_.Exception.Message

            # 判断错误类型
            if ($errorMsg -match '(quota|limit|rate)') {
                Write-Error "API 配额超限: $errorMsg"
                throw
            } elseif ($errorMsg -match '(auth|unauthorized)') {
                Write-Error "认证失败: $errorMsg"
                throw
            }

            # 可重试的错误
            if ($attempt -lt $MaxRetries) {
                $delay = $retryDelays[$attempt - 1]
                Write-Warning-Custom "调用失败: $errorMsg"
                Write-Info "  等待 $delay 秒后重试..."
                Start-Sleep -Seconds $delay
            } else {
                Write-Error "Claude API 调用失败（已重试 $MaxRetries 次）: $errorMsg"
                throw
            }
        }
    }
}
```

- [ ] **Step 2: 更新文档生成函数使用重试机制**

在 Generate-RequirementsDoc, Generate-FilesDoc, Generate-OverviewDiagram, Generate-FlowchartDiagram 函数中，将：

```powershell
$content = claude -p $prompt
```

替换为：

```powershell
$content = Invoke-ClaudeWithRetry -Prompt $prompt -Operation "生成$DocType"
```

- [ ] **Step 3: 测试重试机制**

模拟网络错误测试重试逻辑（可以临时修改 claude 命令路径）

预期: 遇到临时错误时自动重试，配额错误时立即失败

- [ ] **Step 4: 提交错误处理增强**

```bash
git add generate-project-docs.ps1
git commit -m "feat: 增强 Claude API 错误处理和重试机制

- 实现指数退避重试策略（5/10/20秒）
- 区分可重试错误和不可重试错误
- 配额超限和认证失败立即报错
- 网络错误自动重试最多3次

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

## Chunk 5: 批量处理脚本

### Task 12: 创建批量处理脚本

**Files:**
- Create: `batch-generate-project-docs.ps1`

- [ ] **Step 1: 创建批量处理脚本框架**

```powershell
# batch-generate-project-docs.ps1
# 批量项目文档生成器

param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".\repos-config.json",

    [Parameter(Mandatory=$false)]
    [string]$OutputBaseDir = ".\docs"
)

$ErrorActionPreference = "Stop"

# 加载共享函数库
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\lib\project-analysis-common.ps1"

Write-Step "批量文档生成器"

# 验证配置文件
if (-not (Test-Path $ConfigFile)) {
    Write-Error "配置文件不存在: $ConfigFile"
    exit 1
}

# 读取配置
try {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
    $projects = $config.projects
    Write-Info "找到 $($projects.Count) 个项目"
} catch {
    Write-Error "无法解析配置文件: $_"
    exit 1
}

# 初始化统计
$stats = @{
    Total = $projects.Count
    Success = 0
    Failed = 0
    StartTime = Get-Date
    Results = @()
}
```

- [ ] **Step 2: 添加批量处理逻辑**

```powershell
# 处理每个项目
foreach ($project in $projects) {
    Write-Step "处理项目: $($project.name)"

    $projectResult = @{
        Name = $project.name
        Path = $project.path
        Status = "Unknown"
        Error = $null
        Duration = 0
        TechStack = @()
        FileCount = 0
        DocSize = 0
    }

    $projectStartTime = Get-Date

    try {
        # 验证项目路径
        if (-not (Test-Path $project.path)) {
            throw "项目路径不存在: $($project.path)"
        }

        # 创建项目输出目录
        $projectOutputDir = Join-Path $OutputBaseDir $project.name
        if (-not (Test-Path $projectOutputDir)) {
            New-Item -ItemType Directory -Path $projectOutputDir -Force | Out-Null
        }

        # 调用主脚本
        $generateScript = Join-Path $scriptDir "generate-project-docs.ps1"
        & $generateScript -ProjectPath $project.path -OutputDir $projectOutputDir

        # 统计生成的文档
        $docs = Get-ChildItem -Path $projectOutputDir -File
        $projectResult.DocSize = ($docs | Measure-Object -Property Length -Sum).Sum
        $projectResult.FileCount = $docs.Count

        $projectResult.Status = "Success"
        $stats.Success++
        Write-Success "项目处理成功"

    } catch {
        $projectResult.Status = "Failed"
        $projectResult.Error = $_.Exception.Message
        $stats.Failed++
        Write-Error "项目处理失败: $_"
    }

    $projectResult.Duration = ((Get-Date) - $projectStartTime).TotalSeconds
    $stats.Results += $projectResult
}

$stats.EndTime = Get-Date
$stats.TotalDuration = ($stats.EndTime - $stats.StartTime).TotalSeconds
```

- [ ] **Step 3: 添加汇总报告生成**

```powershell
# 生成汇总报告
Write-Step "生成汇总报告"

$summaryPath = Join-Path $OutputBaseDir "batch-summary.md"

$summary = @"
# 批量文档生成报告

生成时间: $($stats.EndTime.ToString('yyyy-MM-dd HH:mm:ss'))
总项目数: $($stats.Total)
成功: $($stats.Success)
失败: $($stats.Failed)

## 成功项目 ($($stats.Success)/$($stats.Total))

| 项目名称 | 技术栈 | 文件数 | 耗时 | 文档大小 | 状态 |
|---------|--------|--------|------|---------|------|
$($stats.Results | Where-Object { $_.Status -eq "Success" } | ForEach-Object {
"| $($_.Name) | $($_.TechStack -join ', ') | $($_.FileCount) | $([math]::Round($_.Duration, 0))s | $([math]::Round($_.DocSize / 1KB, 0))KB | ✓ |"
} | Out-String)

## 失败项目 ($($stats.Failed)/$($stats.Total))

| 项目名称 | 错误原因 | 建议操作 |
|---------|---------|---------|
$($stats.Results | Where-Object { $_.Status -eq "Failed" } | ForEach-Object {
"| $($_.Name) | $($_.Error) | 检查项目路径和配置 |"
} | Out-String)

## 统计信息

- 总耗时: $([math]::Round($stats.TotalDuration, 0))s
- 平均耗时: $([math]::Round($stats.TotalDuration / $stats.Total, 0))s/项目
- 生成文档总数: $(($stats.Results | Measure-Object -Property FileCount -Sum).Sum) 个
- 总文档大小: $([math]::Round((($stats.Results | Measure-Object -Property DocSize -Sum).Sum) / 1MB, 2))MB
"@

$summary | Out-File -FilePath $summaryPath -Encoding UTF8

Write-Success "汇总报告已生成: $summaryPath"
Write-Step "批量处理完成"
Write-Info "成功: $($stats.Success), 失败: $($stats.Failed)"

# 返回失败项目数作为退出码
exit $stats.Failed
```

- [ ] **Step 4: 测试批量处理**

创建测试配置文件 `repos-config.json`:
```json
{
  "projects": [
    {
      "name": "test-project",
      "path": "."
    }
  ]
}
```

运行: `.\batch-generate-project-docs.ps1`

预期: 成功处理项目并生成汇总报告

- [ ] **Step 5: 提交批量处理脚本**

```bash
git add batch-generate-project-docs.ps1
git commit -m "feat: 添加批量文档生成脚本

- 读取 repos-config.json 配置文件
- 遍历多个项目并生成文档
- 生成详细的汇总报告
- 错误隔离（单个项目失败不影响其他项目）
- 返回失败项目数作为退出码

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

## Chunk 6: 测试和文档

### Task 13: 集成测试

**Files:**
- Test: `generate-project-docs.ps1`
- Test: `batch-generate-project-docs.ps1`

- [ ] **Step 1: 测试单个项目文档生成**

运行: `.\generate-project-docs.ps1 -ProjectPath . -OutputDir ".\test-output"`

验证:
- [ ] 生成 4 个文档文件
- [ ] 所有文档内容完整
- [ ] 验证报告显示通过
- [ ] 无错误日志

- [ ] **Step 2: 测试 DryRun 模式**

运行: `.\generate-project-docs.ps1 -ProjectPath . -DryRun`

验证:
- [ ] 文档生成到临时目录
- [ ] 不影响实际输出目录
- [ ] 显示预览信息

- [ ] **Step 3: 测试错误处理**

测试场景:
- [ ] 不存在的项目路径
- [ ] 无权限的输出目录
- [ ] Claude API 不可用（模拟）

验证:
- [ ] 清晰的错误信息
- [ ] 降级方案生效
- [ ] 错误日志记录

- [ ] **Step 4: 测试批量处理**

运行: `.\batch-generate-project-docs.ps1`

验证:
- [ ] 所有项目都被处理
- [ ] 汇总报告准确
- [ ] 部分失败不影响其他项目

- [ ] **Step 5: 性能测试**

测试不同规模的项目:
- [ ] 小型项目（< 100 文件）: < 1 分钟
- [ ] 中型项目（100-500 文件）: < 3 分钟
- [ ] 大型项目（500+ 文件）: < 5 分钟

- [ ] **Step 6: 提交测试结果**

```bash
git add test-output/
git commit -m "test: 完成集成测试

- 单个项目文档生成测试通过
- DryRun 模式测试通过
- 错误处理测试通过
- 批量处理测试通过
- 性能测试达标

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 14: 编写使用文档

**Files:**
- Create: `README-DOCS-GENERATOR.md`

- [ ] **Step 1: 创建使用文档**

```markdown
# 项目文档生成器使用指南

## 概述

项目文档生成器是一个 PowerShell 工具，用于自动分析项目代码并生成四种详细文档。

## 功能

- 项目需求说明书（PROJECT-REQUIREMENTS.md）
- 项目文件功能列表（PROJECT-FILES.md）
- 项目全景图（PROJECT-OVERVIEW.puml）
- 模块流程图（MODULE-FLOWCHART.puml）

## 前置要求

- PowerShell 5.1+
- Claude CLI 工具
- Git（用于批量处理）

## 基本使用

### 单个项目

```powershell
# 为当前项目生成文档
.\generate-project-docs.ps1 -ProjectPath .

# 为指定项目生成文档
.\generate-project-docs.ps1 -ProjectPath "C:\Projects\MyApp"

# 自定义输出目录
.\generate-project-docs.ps1 -ProjectPath . -OutputDir ".\documentation"

# DryRun 模式（预览）
.\generate-project-docs.ps1 -ProjectPath . -DryRun

# 详细输出
.\generate-project-docs.ps1 -ProjectPath . -Verbose
```

### 批量处理

```powershell
# 批量为多个项目生成文档
.\batch-generate-project-docs.ps1

# 自定义配置文件
.\batch-generate-project-docs.ps1 -ConfigFile ".\my-repos.json"
```

## 配置文件格式

`repos-config.json`:
```json
{
  "projects": [
    {
      "name": "project-name",
      "path": "C:\\path\\to\\project"
    }
  ]
}
```

## 支持的技术栈

- Java (Maven/Gradle)
- Python
- TypeScript/Node.js
- C++
- C#
- VB.NET
- Go
- Rust
- 其他（通用分析策略）

## 输出文档

所有文档默认生成到 `.\docs\` 目录：

- `PROJECT-REQUIREMENTS.md` - 项目需求说明书（100-300行）
- `PROJECT-FILES.md` - 项目文件功能列表
- `PROJECT-OVERVIEW.puml` - PlantUML 组件图
- `MODULE-FLOWCHART.puml` - PlantUML 流程图和时序图

## 查看 PlantUML 图表

1. 在线查看: https://www.plantuml.com/plantuml/uml/
2. VS Code 插件: PlantUML
3. IntelliJ IDEA 插件: PlantUML integration

## 故障排除

### Claude API 调用失败

- 检查 Claude CLI 是否正确安装: `claude --version`
- 检查 API 配额是否充足
- 查看错误日志: `.\logs\generate-docs-error.log`

### 文档质量问题

- 使用 `-Verbose` 参数查看详细信息
- 检查验证报告中的警告
- 手动审查和补充生成的文档

### 性能问题

- 大型项目（1000+ 文件）可能需要 5-10 分钟
- 使用 DryRun 模式预览而不实际生成
- 考虑分批处理大型项目

## 最佳实践

1. 定期更新文档（代码变化后）
2. 将生成的文档纳入版本控制
3. 在 CLAUDE.md 中引用生成的文档
4. 手动审查和补充 AI 生成的内容
5. 使用批量处理保持多项目文档同步

## 许可证

MIT License
```

- [ ] **Step 2: 提交使用文档**

```bash
git add README-DOCS-GENERATOR.md
git commit -m "docs: 添加项目文档生成器使用指南

- 基本使用说明
- 配置文件格式
- 支持的技术栈
- 故障排除指南
- 最佳实践

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Task 15: 最终验收

**Files:**
- All project files

- [ ] **Step 1: 功能验收检查清单**

验证所有功能需求:
- [ ] FR-001: 项目结构深度分析 ✓
- [ ] FR-002: 生成项目需求说明书 ✓
- [ ] FR-003: 生成项目文件功能列表 ✓
- [ ] FR-004: 生成项目全景图 ✓
- [ ] FR-005: 生成模块流程图 ✓
- [ ] FR-006: 批量处理支持 ✓

- [ ] **Step 2: 质量验收检查清单**

- [ ] 所有文档使用中文撰写
- [ ] PlantUML 图表可以正常渲染
- [ ] 错误处理完善，提供清晰的错误信息
- [ ] DryRun 模式正常工作
- [ ] 文档验证功能正常

- [ ] **Step 3: 性能验收检查清单**

- [ ] 中等规模项目（100-500 文件）< 3 分钟
- [ ] 大型项目（1000+ 文件）< 10 分钟
- [ ] 内存使用合理（< 2GB）

- [ ] **Step 4: 创建最终提交**

```bash
git add .
git commit -m "feat: 完成项目文档生成器实现

实现功能:
- 共享函数库（支持多种技术栈）
- 深度项目分析（结构、模块、文件扫描）
- 四种文档生成（需求、文件列表、全景图、流程图）
- 文档质量验证
- 错误处理和重试机制
- 批量处理支持
- 完整的使用文档

技术栈: PowerShell 5.1+, Claude CLI, PlantUML

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

---

## 实现完成

计划完成！所有任务已定义，准备执行。

**下一步**: 使用 `superpowers:executing-plans` 或 `superpowers:subagent-driven-development` 执行此计划。
