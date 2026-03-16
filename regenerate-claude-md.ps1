# ============================================
# CLAUDE.md 重新生成脚本
# 基于 2026 年最佳实践
# ============================================

<#
.SYNOPSIS
    CLAUDE.md Regeneration Script - Generate concise CLAUDE.md based on 2026 best practices

.DESCRIPTION
    This script analyzes a project and generates a concise CLAUDE.md file (40-80 lines) containing:
    - Project title and description
    - Key commands
    - Architecture overview
    - Code conventions
    - Verification steps
    - Gotchas and references

.PARAMETER ProjectPath
    Path to the project to analyze (required)

.PARAMETER DryRun
    Preview mode - shows what would be generated without writing files

.PARAMETER OutputDir
    Output directory for generated CLAUDE.md (default: .\output)

.PARAMETER Verbose
    Show detailed output during execution

.EXAMPLE
    .\regenerate-claude-md.ps1 -ProjectPath .
    Generate CLAUDE.md for the current project

.EXAMPLE
    .\regenerate-claude-md.ps1 -ProjectPath "C:\Projects\MyApp" -DryRun
    Preview CLAUDE.md generation without writing files

.EXAMPLE
    .\regenerate-claude-md.ps1 -ProjectPath . -Verbose
    Generate with detailed output

.NOTES
    Supported tech stacks: TypeScript/Node.js, Python, Java, C++, C#, VB.NET
    Target length: 40-80 lines (max 200 lines)
    Author: Claude Opus 4.6
    Version: 1.0
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the project to analyze")]
    [string]$ProjectPath,

    [Parameter(Mandatory=$false, HelpMessage="Preview mode - don't write files")]
    [switch]$DryRun,

    [Parameter(Mandatory=$false, HelpMessage="Output directory for CLAUDE.md")]
    [string]$OutputDir = ".\output"
)

# Show help if -h or -help is specified
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "--help") {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ============================================
# 辅助函数
# ============================================

function Write-Step {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host "`n$Message" -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    if ($Verbose) {
        Write-Host "  $Message" -ForegroundColor Gray
    }
}

# ============================================
# 技术栈检测
# ============================================

function Detect-TechStack {
    param([string]$Path)

    Write-Info "检测技术栈..."

    $detected = @()

    # TypeScript/Node.js
    if (Test-Path "$Path\package.json") {
        $detected += "typescript/nodejs"
        Write-Info "  发现: package.json (TypeScript/Node.js)"
    }

    # Python
    if (Test-Path "$Path\requirements.txt") {
        $detected += "python"
        Write-Info "  发现: requirements.txt (Python)"
    }
    if (Test-Path "$Path\pyproject.toml") {
        if ($detected -notcontains "python") {
            $detected += "python"
        }
        Write-Info "  发现: pyproject.toml (Python)"
    }

    # Java Maven
    if (Test-Path "$Path\pom.xml") {
        $detected += "java-maven"
        Write-Info "  发现: pom.xml (Java Maven)"
    }

    # Java Gradle
    if ((Test-Path "$Path\build.gradle") -or (Test-Path "$Path\build.gradle.kts")) {
        $detected += "java-gradle"
        Write-Info "  发现: build.gradle (Java Gradle)"
    }

    # C++
    if (Test-Path "$Path\CMakeLists.txt") {
        $detected += "cpp"
        Write-Info "  发现: CMakeLists.txt (C++)"
    }

    # C#
    $csprojFiles = Get-ChildItem -Path $Path -Filter "*.csproj" -ErrorAction SilentlyContinue
    if ($csprojFiles) {
        $detected += "csharp"
        Write-Info "  发现: *.csproj (C#)"
    }

    # VB.NET
    $vbprojFiles = Get-ChildItem -Path $Path -Filter "*.vbproj" -ErrorAction SilentlyContinue
    if ($vbprojFiles) {
        $detected += "vbnet"
        Write-Info "  发现: *.vbproj (VB.NET)"
    }

    if ($detected.Count -eq 0) {
        Write-Warning-Custom "未检测到已知技术栈"
    }

    return $detected
}

# ============================================
# 项目描述提取
# ============================================

function Get-ProjectDescription {
    param([string]$Path)

    Write-Info "提取项目描述..."

    # 尝试从 README.md 提取
    $readmePath = "$Path\README.md"
    if (Test-Path $readmePath) {
        $readme = Get-Content $readmePath -Raw

        # 提取第一个标题后的第一段
        if ($readme -match '(?m)^#\s+(.+?)$') {
            $title = $Matches[1]

            # 提取第一段描述
            if ($readme -match '(?ms)^#\s+.+?\n\n(.+?)(\n\n|$)') {
                $description = $Matches[1] -replace '\n', ' '
                return "$title - $description"
            }

            return $title
        }
    }

    # 尝试从 package.json 提取
    if (Test-Path "$Path\package.json") {
        try {
            $packageJson = Get-Content "$Path\package.json" | ConvertFrom-Json
            if ($packageJson.description) {
                return $packageJson.description
            }
        } catch {
            Write-Info "  无法解析 package.json"
        }
    }

    # 使用目录名作为后备
    $projectName = Split-Path $Path -Leaf
    return $projectName
}

# ============================================
# 关键命令提取
# ============================================

function Get-KeyCommands {
    param([string]$Path, [array]$TechStack)

    Write-Info "提取关键命令..."

    $commands = @()

    # Node.js/TypeScript
    if ($TechStack -contains "typescript/nodejs") {
        if (Test-Path "$Path\package.json") {
            try {
                $packageJson = Get-Content "$Path\package.json" | ConvertFrom-Json
                $scripts = $packageJson.scripts

                # 优先提取常用命令
                $priorityScripts = @('dev', 'start', 'build', 'test', 'lint', 'typecheck')

                foreach ($script in $priorityScripts) {
                    if ($scripts.$script) {
                        $commands += "npm run $script"
                    }
                }

                # 添加其他重要命令 (最多 8 个)
                $otherScripts = $scripts.PSObject.Properties |
                    Where-Object { $priorityScripts -notcontains $_.Name } |
                    Select-Object -First 2

                foreach ($script in $otherScripts) {
                    $commands += "npm run $($script.Name)"
                }
            } catch {
                Write-Info "  无法解析 package.json scripts"
            }
        }
    }

    # Python
    if ($TechStack -contains "python") {
        $commands += "python -m venv venv"
        $commands += "pip install -r requirements.txt"
        $commands += "python main.py"
        $commands += "pytest"
    }

    # Java Maven
    if ($TechStack -contains "java-maven") {
        $commands += "mvn clean install"
        $commands += "mvn test"
        $commands += "mvn spring-boot:run"
    }

    # Java Gradle
    if ($TechStack -contains "java-gradle") {
        $commands += "gradle build"
        $commands += "gradle test"
        $commands += "gradle bootRun"
    }

    # C++
    if ($TechStack -contains "cpp") {
        $commands += "cmake -B build"
        $commands += "cmake --build build"
        $commands += "ctest --test-dir build"
    }

    # C#
    if ($TechStack -contains "csharp") {
        $commands += "dotnet restore"
        $commands += "dotnet build"
        $commands += "dotnet test"
        $commands += "dotnet run"
    }

    # VB.NET
    if ($TechStack -contains "vbnet") {
        $commands += "dotnet restore"
        $commands += "dotnet build"
        $commands += "dotnet run"
    }

    # 限制最多 8 个命令
    return $commands | Select-Object -First 8
}

# ============================================
# 关键目录提取
# ============================================

function Get-KeyDirectories {
    param([string]$Path)

    Write-Info "分析项目结构..."

    # 排除的目录
    $excludeDirs = @(
        'node_modules', '.git', '.venv', 'venv', '__pycache__',
        'bin', 'obj', 'target', 'build', 'dist', '.next',
        'coverage', '.pytest_cache', '.idea', '.vscode'
    )

    # 获取顶层目录
    $dirs = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue |
        Where-Object { $excludeDirs -notcontains $_.Name } |
        Select-Object -ExpandProperty Name

    return $dirs
}

# ============================================
# 生成 CLAUDE.md
# ============================================

function Get-ProjectDocuments {
    param([string]$Path)

    $docs = @()

    # Check for generated documentation
    $docPaths = @(
        "docs\PROJECT-REQUIREMENTS.md",
        "docs\PROJECT-FILES.md",
        "docs\PROJECT-OVERVIEW.puml",
        "docs\MODULE-FLOWCHART.puml"
    )

    foreach ($docPath in $docPaths) {
        $fullPath = Join-Path $Path $docPath
        if (Test-Path $fullPath) {
            $docs += $docPath
        }
    }

    return $docs
}

function Generate-ClaudeMd {
    param(
        [string]$ProjectPath,
        [string]$ProjectDescription,
        [array]$TechStack,
        [array]$Commands,
        [array]$KeyDirs
    )

    Write-Info "调用 Claude 生成 CLAUDE.md..."

    # 构建项目结构字符串
    $structureStr = $KeyDirs | ForEach-Object { "- ``$_/``" } | Out-String

    # 构建命令字符串
    $commandsStr = $Commands | ForEach-Object { "- $_" } | Out-String

    # 构建技术栈字符串
    $techStackStr = $TechStack | ForEach-Object { "- $_" } | Out-String

    # 检测项目文档
    $projectDocs = Get-ProjectDocuments -Path $ProjectPath
    $docsStr = ""
    if ($projectDocs.Count -gt 0) {
        $docsStr = @"

可用的详细文档:
$($projectDocs | ForEach-Object { "- $_" } | Out-String)
"@
    }

    $prompt = @"
你是 CLAUDE.md 维护助手,基于 2026 年最佳实践生成精简的 CLAUDE.md。

重要约束:
- 目标长度: 40-80 行 (绝对不超过 200 行)
- 每一行都必须有价值,不要泛泛而谈
- 不要包含 Claude 可以从代码推断的信息
- 不要包含标准语言约定
- 不要包含 linter 已经强制的规则

项目信息:
- 描述: $ProjectDescription
- 技术栈:
$techStackStr
- 检测到的命令:
$commandsStr
- 关键目录:
$structureStr$docsStr

任务: 生成精简的 CLAUDE.md,包含以下部分:

1. **项目标题和一句话描述** (1-2 行)
   格式: # [项目名] - [简短描述]

2. **Commands 区域** (5-8 个命令)
   只包含 Claude 无法推断的关键命令
   格式:
   ## Commands
   command  # 简短说明

3. **Architecture 区域** (5-10 行)
   只列出关键目录和架构边界
   说明哪些地方有特殊规则
   格式:
   ## Architecture
   - ``dir/`` - 用途说明

4. **Code Conventions 区域** (3-5 条)
   只包含非默认的、项目特定的规则
   跳过 linter 已经强制的规则
   格式:
   ## Code Conventions
   - 具体规则

5. **Verification 区域** (3-5 行)
   Claude 修改代码后应该运行的验证命令
   格式:
   ## Verification
   After changes:
   1. command
   2. command

6. **Gotchas 区域** (可选,2-4 条)
   常见陷阱和注意事项
   格式:
   ## Gotchas
   - 具体的陷阱

7. **References 区域** (2-3 行)
   链接到详细文档
   格式:
   ## References
   - Topic: ``path/to/doc.md``

要求:
- 总长度控制在 40-80 行
- 使用简洁、具体的语言
- 每条规则都要具体,不要"写干净代码"这类泛泛而谈
- 使用中文撰写说明,命令和代码保持原样
- 不要添加代码示例,用文件引用代替

请直接输出完整的 CLAUDE.md 内容,不要有任何前缀或后缀说明。
"@

    # 调用 claude CLI
    try {
        $newContent = claude -p $prompt
        return $newContent
    } catch {
        Write-Error "调用 Claude 失败: $_"
        return $null
    }
}

# ============================================
# 验证 CLAUDE.md 长度
# ============================================

function Test-ClaudeMdLength {
    param([string]$Content)

    $lineCount = ($Content -split "`n").Count

    Write-Step "[长度检查]"
    Write-Host "  当前行数: $lineCount" -ForegroundColor White

    if ($lineCount -gt 300) {
        Write-Host "  状态: ✗ 过长" -ForegroundColor Red
        Write-Warning-Custom "CLAUDE.md 超过 300 行,Claude 可能会忽略部分内容"
        Write-Host "  建议: 必须精简到 200 行以内" -ForegroundColor Yellow
        return $false
    } elseif ($lineCount -gt 200) {
        Write-Host "  状态: ⚠️  偏长" -ForegroundColor Yellow
        Write-Warning-Custom "CLAUDE.md 超过 200 行,建议精简"
        return $true
    } elseif ($lineCount -gt 80) {
        Write-Host "  状态: ✓ 可接受" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  状态: ✓✓✓ 理想" -ForegroundColor Green
        return $true
    }
}

# ============================================
# 对比差异
# ============================================

function Compare-ClaudeMd {
    param(
        [string]$OldContent,
        [string]$NewContent
    )

    Write-Info "对比新旧版本..."

    $diff = @{
        'HasChanges' = $false
        'Summary' = @()
        'Details' = ''
        'OldLineCount' = 0
        'NewLineCount' = 0
    }

    if ([string]::IsNullOrEmpty($OldContent)) {
        $diff.HasChanges = $true
        $diff.Summary += "首次生成 CLAUDE.md"
        $diff.NewLineCount = ($NewContent -split "`n").Count
        return $diff
    }

    $diff.OldLineCount = ($OldContent -split "`n").Count
    $diff.NewLineCount = ($NewContent -split "`n").Count

    if ($OldContent -ne $NewContent) {
        $diff.HasChanges = $true

        # 保存到临时文件用于 diff
        $tempOld = [System.IO.Path]::GetTempFileName()
        $tempNew = [System.IO.Path]::GetTempFileName()

        $OldContent | Out-File -FilePath $tempOld -Encoding UTF8
        $NewContent | Out-File -FilePath $tempNew -Encoding UTF8

        # 尝试使用 git diff
        try {
            $gitDiff = git diff --no-index --color=never $tempOld $tempNew 2>$null
            if ($LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 1) {
                $diff.Details = $gitDiff -join "`n"
            }
        } catch {
            Write-Info "  git diff 不可用,使用简单对比"
        }

        # 如果 git diff 失败,使用简单对比
        if ([string]::IsNullOrEmpty($diff.Details)) {
            $oldLines = $OldContent -split "`n"
            $newLines = $NewContent -split "`n"

            $comparison = Compare-Object -ReferenceObject $oldLines -DifferenceObject $newLines
            $diff.Details = $comparison | Format-Table -AutoSize | Out-String
        }

        # 生成摘要
        $diff.Summary += "旧版本: $($diff.OldLineCount) 行"
        $diff.Summary += "新版本: $($diff.NewLineCount) 行"

        $lineDiff = $diff.NewLineCount - $diff.OldLineCount
        if ($lineDiff -gt 0) {
            $diff.Summary += "增加: +$lineDiff 行"
        } elseif ($lineDiff -lt 0) {
            $diff.Summary += "减少: $lineDiff 行"
        } else {
            $diff.Summary += "行数不变,内容有更新"
        }

        # 清理临时文件
        Remove-Item $tempOld, $tempNew -ErrorAction SilentlyContinue
    } else {
        $diff.Summary += "无变化"
    }

    return $diff
}

# ============================================
# 生成变更报告
# ============================================

function New-ChangeReport {
    param(
        [string]$ProjectPath,
        [array]$TechStack,
        [array]$KeyDirs,
        [hashtable]$Diff,
        [string]$OutputPath
    )

    Write-Info "生成变更报告..."

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

    $report = @"
# CLAUDE.md 重新生成报告

生成时间: $timestamp
项目路径: $ProjectPath

## 检测信息

### 技术栈
$($TechStack | ForEach-Object { "- $_" } | Out-String)

### 项目结构 (关键目录)
``````
$($KeyDirs | ForEach-Object { "$_/" } | Out-String)
``````

## 长度检查

$($Diff.Summary | ForEach-Object { "- $_" } | Out-String)

状态评估:
- 理想长度: 40-80 行 ✓✓✓
- 可接受: 81-200 行 ✓
- 需要精简: 201-300 行 ⚠️
- 过长: 300+ 行 ✗

当前状态: $(
    if ($Diff.NewLineCount -le 80) { "✓✓✓ 理想" }
    elseif ($Diff.NewLineCount -le 200) { "✓ 可接受" }
    elseif ($Diff.NewLineCount -le 300) { "⚠️  需要精简" }
    else { "✗ 过长" }
)

## 最佳实践检查清单

- [ ] 是否包含项目一句话描述?
- [ ] 是否只包含 Claude 无法推断的命令?
- [ ] 是否避免了标准语言约定?
- [ ] 是否避免了代码示例 (使用文件引用)?
- [ ] 是否包含验证步骤?
- [ ] 总长度是否在 200 行以内?
- [ ] 每条规则是否具体 (避免"写干净代码")?

## 详细差异

``````diff
$($Diff.Details)
``````

## 下一步操作

### 如果确认无误,应用新版本:

``````powershell
# 备份原文件
Copy-Item "$ProjectPath\CLAUDE.md" "$ProjectPath\CLAUDE.md.backup" -ErrorAction SilentlyContinue

# 应用新版本
Copy-Item "$OutputPath\CLAUDE.md.new" "$ProjectPath\CLAUDE.md"
``````

### 如果需要进一步精简:

1. 检查是否有可以移到 ``.claude/rules/`` 的详细内容
2. 删除 Claude 可以从代码推断的信息
3. 删除标准语言约定
4. 使用文件引用代替代码示例

### 推荐的文件结构:

``````
project/
├─ CLAUDE.md                    (40-80 行,核心信息)
├─ .claude/
│  ├─ rules/                    (详细规范,按需加载)
│  │  ├─ api-patterns.md
│  │  ├─ database-rules.md
│  │  └─ testing-guide.md
│  └─ skills/                   (领域知识,按需加载)
│     └─ domain-specific.md
└─ docs/                        (完整文档)
   ├─ api.md
   ├─ deployment.md
   └─ troubleshooting.md
``````

---
报告生成于: $timestamp
"@

    $reportPath = "$OutputPath\changes-report.md"
    $report | Out-File -FilePath $reportPath -Encoding UTF8

    return $reportPath
}

# ============================================
# 主程序
# ============================================

# 验证路径
if (-not (Test-Path $ProjectPath)) {
    Write-Error "项目路径不存在: $ProjectPath"
    exit 1
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  CLAUDE.md 重新生成工具 (2026 最佳实践)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "项目路径: $ProjectPath" -ForegroundColor Yellow

# 步骤 1: 检测技术栈
Write-Step "[1/6] 检测技术栈"
$techStack = Detect-TechStack -Path $ProjectPath

if ($techStack.Count -eq 0) {
    Write-Warning-Custom "未检测到技术栈,将生成通用 CLAUDE.md"
} else {
    Write-Success "检测到: $($techStack -join ', ')"
}

# 步骤 2: 提取项目信息
Write-Step "[2/6] 提取项目信息"

$projectDescription = Get-ProjectDescription -Path $ProjectPath
Write-Info "项目描述: $projectDescription"

$keyCommands = Get-KeyCommands -Path $ProjectPath -TechStack $techStack
Write-Info "找到 $($keyCommands.Count) 个关键命令"

$keyDirs = Get-KeyDirectories -Path $ProjectPath
Write-Info "找到 $($keyDirs.Count) 个关键目录"

Write-Success "项目信息收集完成"

# 步骤 3: 生成新的 CLAUDE.md
Write-Step "[3/6] 生成新的 CLAUDE.md"
Write-Host "  正在调用 Claude..." -ForegroundColor Gray

$newContent = Generate-ClaudeMd `
    -ProjectPath $ProjectPath `
    -ProjectDescription $projectDescription `
    -TechStack $techStack `
    -Commands $keyCommands `
    -KeyDirs $keyDirs

if ($null -eq $newContent) {
    Write-Error "生成失败"
    exit 1
}

$newFilePath = "$OutputDir\CLAUDE.md.new"
$newContent | Out-File -FilePath $newFilePath -Encoding UTF8
Write-Success "新版本已生成: $newFilePath"

# 步骤 4: 验证长度
$lengthOk = Test-ClaudeMdLength -Content $newContent

# 步骤 5: 对比差异
Write-Step "[4/6] 对比差异"

$oldClaudeMd = "$ProjectPath\CLAUDE.md"
$diff = $null

if (Test-Path $oldClaudeMd) {
    $oldContent = Get-Content $oldClaudeMd -Raw
    Copy-Item $oldClaudeMd "$OutputDir\CLAUDE.md.old"
    Write-Info "已备份原文件到: $OutputDir\CLAUDE.md.old"

    $diff = Compare-ClaudeMd -OldContent $oldContent -NewContent $newContent

    if ($diff.HasChanges) {
        Write-Host "  检测到变更:" -ForegroundColor Yellow
        $diff.Summary | ForEach-Object { Write-Host "    $_" -ForegroundColor White }
    } else {
        Write-Success "无变更"
    }
} else {
    Write-Info "原 CLAUDE.md 不存在,这是首次生成"
    $diff = @{
        'HasChanges' = $true
        'Summary' = @("首次生成")
        'Details' = "新文件"
        'OldLineCount' = 0
        'NewLineCount' = ($newContent -split "`n").Count
    }
}

# 步骤 6: 生成报告
Write-Step "[5/6] 生成变更报告"

$reportPath = New-ChangeReport `
    -ProjectPath $ProjectPath `
    -TechStack $techStack `
    -KeyDirs $keyDirs `
    -Diff $diff `
    -OutputPath $OutputDir

Write-Success "变更报告已生成: $reportPath"

# 总结
Write-Step "[6/6] 完成" "Green"

Write-Host "`n输出文件:" -ForegroundColor Yellow
Write-Host "  - 新版本: $newFilePath" -ForegroundColor White
if (Test-Path "$OutputDir\CLAUDE.md.old") {
    Write-Host "  - 旧版本备份: $OutputDir\CLAUDE.md.old" -ForegroundColor White
}
Write-Host "  - 变更报告: $reportPath" -ForegroundColor White

# 长度警告
if (-not $lengthOk) {
    Write-Host "`n⚠️  警告: CLAUDE.md 长度超过推荐值" -ForegroundColor Red
    Write-Host "   建议精简到 200 行以内以确保 Claude 能有效使用" -ForegroundColor Yellow
}

# 应用更改
if (-not $DryRun) {
    Write-Host "`n是否要覆盖原 CLAUDE.md? (y/N): " -ForegroundColor Yellow -NoNewline
    $confirm = Read-Host

    if ($confirm -eq 'y' -or $confirm -eq 'Y') {
        # 备份原文件
        if (Test-Path $oldClaudeMd) {
            $backupPath = "$ProjectPath\CLAUDE.md.backup"
            Copy-Item $oldClaudeMd $backupPath
            Write-Info "原文件已备份到: $backupPath"
        }

        # 应用新版本
        Copy-Item $newFilePath $oldClaudeMd
        Write-Success "已更新 $oldClaudeMd"

        Write-Host "`n建议: 运行 'claude' 命令测试新的 CLAUDE.md 是否正常工作" -ForegroundColor Cyan
    } else {
        Write-Host "`n已取消,请手动审查后决定是否应用" -ForegroundColor Yellow
        Write-Host "应用命令: Copy-Item '$newFilePath' '$oldClaudeMd'" -ForegroundColor Gray
    }
} else {
    Write-Host "`n[DryRun 模式] 未修改原文件" -ForegroundColor Cyan
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  查看详细报告: $reportPath" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan
