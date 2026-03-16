# ============================================
# 项目文档生成器 - 自动分析项目并生成详细文档
# ============================================

<#
.SYNOPSIS
    Project Documentation Generator - Automatically analyze projects and generate detailed documentation

.DESCRIPTION
    This script analyzes a project's structure, files, and modules, then generates four types of documentation:
    - PROJECT-REQUIREMENTS.md: Project requirements document
    - PROJECT-FILES.md: Project files list
    - PROJECT-OVERVIEW.puml: System architecture diagram (PlantUML)
    - MODULE-FLOWCHART.puml: Module flowchart (PlantUML)

.PARAMETER ProjectPath
    Path to the project to analyze (required)

.PARAMETER OutputDir
    Output directory for generated documents (default: .\docs)

.PARAMETER DryRun
    Preview mode - generates documents to a temporary directory without affecting the actual output

.EXAMPLE
    .\generate-project-docs.ps1 -ProjectPath .
    Generate documentation for the current project

.EXAMPLE
    .\generate-project-docs.ps1 -ProjectPath "C:\Projects\MyApp" -OutputDir "C:\Projects\MyApp\docs"
    Generate documentation for a specific project

.EXAMPLE
    .\generate-project-docs.ps1 -ProjectPath . -DryRun
    Preview mode - generate documents to temp directory

.NOTES
    Supported tech stacks: TypeScript/Node.js, Python, Java, C++, C#, VB.NET, Go, Rust
    Author: Claude Opus 4.6
    Version: 1.0
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Path to the project to analyze")]
    [string]$ProjectPath,

    [Parameter(Mandatory=$false, HelpMessage="Output directory for generated documents")]
    [string]$OutputDir = ".\docs",

    [Parameter(Mandatory=$false, HelpMessage="Preview mode - output to temp directory")]
    [switch]$DryRun
)

# Show help if -h or -help is specified
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "--help") {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# 设置错误处理
$ErrorActionPreference = "Stop"

# Load shared function library
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$commonLib = Join-Path $scriptDir "lib\project-analysis-common.ps1"
. $commonLib

# ============================================
# Project Structure Analysis
# ============================================

function Analyze-ProjectStructure {
    param([string]$Path, [array]$TechStack)

    Write-Info "Analyzing project structure..."

    $structure = @{
        ProjectType = "Unknown"
        EntryFiles = @()
        ConfigFiles = @()
    }

    # Identify project type
    if ($TechStack -contains "typescript/nodejs") {
        $structure.ProjectType = "Node.js/TypeScript"

        # Find entry files
        $entryFiles = @("index.ts", "index.js", "main.ts", "main.js", "app.ts", "app.js", "server.ts", "server.js")
        foreach ($file in $entryFiles) {
            if (Test-Path "$Path\$file") {
                $structure.EntryFiles += $file
            }
            if (Test-Path "$Path\src\$file") {
                $structure.EntryFiles += "src\$file"
            }
        }

        # Config files
        $structure.ConfigFiles += "package.json"
        if (Test-Path "$Path\tsconfig.json") { $structure.ConfigFiles += "tsconfig.json" }
    }

    if ($TechStack -contains "python") {
        $structure.ProjectType = "Python"

        # Find entry files
        $entryFiles = @("main.py", "app.py", "manage.py", "__main__.py")
        foreach ($file in $entryFiles) {
            if (Test-Path "$Path\$file") {
                $structure.EntryFiles += $file
            }
        }

        # Config files
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

    Write-Info "  Project type: $($structure.ProjectType)"
    Write-Info "  Entry files: $($structure.EntryFiles.Count)"
    Write-Info "  Config files: $($structure.ConfigFiles.Count)"

    return $structure
}

# ============================================
# File Scanning
# ============================================

function Scan-ProjectFiles {
    param([string]$Path, [array]$TechStack)

    Write-Info "Scanning project files..."

    # Excluded directories
    $excludeDirs = @(
        'node_modules', '.git', '.venv', 'venv', '__pycache__',
        'bin', 'obj', 'target', 'build', 'dist', '.next',
        'coverage', '.pytest_cache', '.idea', '.vscode', 'vendor'
    )

    # Excluded file extensions
    $excludeExtensions = @('.min.js', '.map', '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico', '.woff', '.woff2', '.ttf', '.eot')

    $files = @{
        SourceFiles = @()
        TestFiles = @()
        ConfigFiles = @()
        TotalCount = 0
        TotalSize = 0
    }

    # Recursively scan files
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $file = $_
        $relativePath = $file.FullName.Substring($Path.Length + 1)

        # Check if in excluded directory
        $inExcludedDir = $false
        foreach ($excludeDir in $excludeDirs) {
            if ($relativePath -like "$excludeDir\*" -or $relativePath -like "*\$excludeDir\*") {
                $inExcludedDir = $true
                break
            }
        }

        if ($inExcludedDir) { return }

        # Check file extension
        $ext = $file.Extension.ToLower()
        if ($excludeExtensions -contains $ext) { return }

        # Categorize file
        $fileInfo = @{
            Path = $relativePath
            Size = $file.Length
            Lines = 0
            Extension = $ext
        }

        # Count lines (only first 100 lines for performance)
        try {
            $content = Get-Content $file.FullName -TotalCount 100 -ErrorAction SilentlyContinue
            $fileInfo.Lines = $content.Count
        } catch {
            $fileInfo.Lines = 0
        }

        # Determine if test file
        if ($relativePath -match '(test|spec|__tests__|tests)' -or $file.Name -match '(test|spec)\.') {
            $files.TestFiles += $fileInfo
        }
        # Determine if source code file
        elseif ($ext -in @('.ts', '.js', '.py', '.java', '.cpp', '.c', '.h', '.hpp', '.cs', '.vb', '.go', '.rs')) {
            $files.SourceFiles += $fileInfo
        }
        # Config file
        elseif ($ext -in @('.json', '.yaml', '.yml', '.toml', '.xml', '.config')) {
            $files.ConfigFiles += $fileInfo
        }

        $files.TotalCount++
        $files.TotalSize += $file.Length
    }

    Write-Info "  Source files: $($files.SourceFiles.Count)"
    Write-Info "  Test files: $($files.TestFiles.Count)"
    Write-Info "  Config files: $($files.ConfigFiles.Count)"
    Write-Info "  Total files: $($files.TotalCount)"
    $sizeMB = [math]::Round($files.TotalSize / 1MB, 2)
    Write-Info "  Total size: $sizeMB MB"

    return $files
}

# ============================================
# Business Module Identification
# ============================================

function Identify-BusinessModules {
    param([string]$Path, [array]$TechStack, [hashtable]$ProjectFiles)

    Write-Info "Identifying business modules..."

    $modules = @()

    # Get top-level directories
    $topLevelDirs = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin @('node_modules', '.git', 'build', 'dist', 'target', 'bin', 'obj') }

    foreach ($dir in $topLevelDirs) {
        $module = @{
            Name = $dir.Name
            Path = $dir.FullName.Substring($Path.Length + 1)
            Files = @()
            Type = "Unknown"
        }

        # Determine module type
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

        # Count files in module
        $moduleFiles = $ProjectFiles.SourceFiles | Where-Object { $_.Path -like "$($module.Path)\*" }
        $module.Files = $moduleFiles

        if ($module.Files.Count -gt 0) {
            $modules += $module
        }
    }

    Write-Info "  Identified $($modules.Count) modules"

    return $modules
}

# ============================================
# Document Generation Functions
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

    Write-Info "Generating requirements document..."

    $modulesList = ""
    $index = 1
    foreach ($module in $BusinessModules) {
        $modulesList += "### 2.$index $($module.Name)`n"
        $modulesList += "- Module Type: $($module.Type)`n"
        $modulesList += "- File Count: $($module.Files.Count)`n`n"
        $index++
    }

    $content = @"
# Project Requirements Document

## 1. Project Overview
- Project Description: $ProjectDesc
- Tech Stack: $($TechStack -join ', ')
- Total Files: $($ProjectFiles.TotalCount)
- Source Files: $($ProjectFiles.SourceFiles.Count)

## 2. Functional Requirements

$modulesList

## 3. Non-Functional Requirements
- Performance: To be defined
- Security: To be defined
- Scalability: To be defined

## 4. Technical Constraints
- Tech Stack: $($TechStack -join ', ')

## 5. Acceptance Criteria
- All functional requirements implemented
- All tests passing
- Documentation complete

---
Note: This document was generated automatically. Please review and enhance.
"@

    $content | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Success "Requirements document generated: $OutputPath"
    return $true
}

function Generate-FilesDoc {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [hashtable]$ProjectFiles,
        [string]$OutputPath
    )

    Write-Info "Generating files document..."

    $modulesList = ""
    $index = 1
    foreach ($module in $BusinessModules) {
        $modulesList += "### 2.$index $($module.Name)`n`n"
        $modulesList += "#### Description`n"
        $modulesList += "Module Type: $($module.Type)`n`n"
        $modulesList += "#### Files`n"
        foreach ($file in $module.Files) {
            $modulesList += "- $($file.Path)`n"
        }
        $modulesList += "`n"
        $index++
    }

    $content = @"
# Project Files List

## 1. Project Overview
- Project Type: $($TechStack -join ', ')
- Total Files: $($ProjectFiles.SourceFiles.Count)

## 2. Module List

$modulesList

---
Note: This document was generated automatically. Please review and enhance.
"@

    $content | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Success "Files document generated: $OutputPath"
    return $true
}

function Generate-OverviewDiagram {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [string]$OutputPath
    )

    Write-Info "Generating overview diagram..."

    $content = @"
@startuml System Architecture
skinparam backgroundColor #FFFFFF
skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

$($BusinessModules | ForEach-Object {
"package ""$($_.Name)"" {
  [Component] as $($_.Name -replace '\s','')
}
"
})

note right
  Generated automatically
  Please enhance with relationships
end note

@enduml
"@

    $content | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Success "Overview diagram generated: $OutputPath"
    return $true
}

function Generate-FlowchartDiagram {
    param(
        [string]$ProjectPath,
        [string]$ProjectDesc,
        [array]$TechStack,
        [array]$BusinessModules,
        [string]$OutputPath
    )

    Write-Info "Generating flowchart diagram..."

    $content = @"
@startuml Module Flowchart
skinparam backgroundColor #FFFFFF
skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

start
:User Request;
:Process Logic;
:Return Result;
stop

note right
  Generated automatically
  Please enhance with detailed flows
end note

@enduml
"@

    $content | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Success "Flowchart diagram generated: $OutputPath"
    return $true
}

# ============================================
# Parameter Validation
# ============================================

Write-Step "Validating parameters"

# Validate project path
if (-not (Test-Path $ProjectPath)) {
    Write-Host "Project path does not exist: $ProjectPath" -ForegroundColor Red
    exit 1
}

$ProjectPath = Resolve-Path $ProjectPath
Write-Info "Project path: $ProjectPath"

# Validate output directory
if ($DryRun) {
    $OutputDir = Join-Path $env:TEMP "project-docs-preview"
    Write-Info "DryRun mode: Output to temp directory $OutputDir"
} else {
    Write-Info "Output directory: $OutputDir"
}

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Success "Created output directory"
}

# Create log directory
$logDir = ".\logs"
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# ============================================
# Main Process
# ============================================

try {
    Write-Step "Starting project analysis"

    # 1. Detect tech stack
    $techStack = Detect-TechStack -Path $ProjectPath

    # 2. Get project description
    $projectDesc = Get-ProjectDescription -Path $ProjectPath

    # 3. Get key directories
    $keyDirs = Get-KeyDirectories -Path $ProjectPath

    # 4. Get key commands
    $keyCommands = Get-KeyCommands -Path $ProjectPath -TechStack $techStack

    # 5. Analyze project structure
    $projectStructure = Analyze-ProjectStructure -Path $ProjectPath -TechStack $techStack

    # 6. Scan project files
    $projectFiles = Scan-ProjectFiles -Path $ProjectPath -TechStack $techStack

    # 7. Identify business modules
    $businessModules = Identify-BusinessModules -Path $ProjectPath -TechStack $techStack -ProjectFiles $projectFiles

    Write-Step "Project analysis completed"
    Write-Info "Tech stack: $($techStack -join ', ')"
    Write-Info "Project description: $projectDesc"
    Write-Info "Key directories: $($keyDirs.Count)"
    Write-Info "Key commands: $($keyCommands.Count)"
    Write-Info "Business modules: $($businessModules.Count)"

    # Generate documents
    Write-Step "Generating documents"

    # 8. Generate requirements document
    $reqDocPath = Join-Path $OutputDir "PROJECT-REQUIREMENTS.md"
    Generate-RequirementsDoc `
        -ProjectPath $ProjectPath `
        -ProjectDesc $projectDesc `
        -TechStack $techStack `
        -BusinessModules $businessModules `
        -ProjectFiles $projectFiles `
        -OutputPath $reqDocPath

    # 9. Generate files document
    $filesDocPath = Join-Path $OutputDir "PROJECT-FILES.md"
    Generate-FilesDoc `
        -ProjectPath $ProjectPath `
        -ProjectDesc $projectDesc `
        -TechStack $techStack `
        -BusinessModules $businessModules `
        -ProjectFiles $projectFiles `
        -OutputPath $filesDocPath

    # 10. Generate overview diagram
    $overviewPath = Join-Path $OutputDir "PROJECT-OVERVIEW.puml"
    Generate-OverviewDiagram `
        -ProjectPath $ProjectPath `
        -ProjectDesc $projectDesc `
        -TechStack $techStack `
        -BusinessModules $businessModules `
        -OutputPath $overviewPath

    # 11. Generate flowchart diagram
    $flowchartPath = Join-Path $OutputDir "MODULE-FLOWCHART.puml"
    Generate-FlowchartDiagram `
        -ProjectPath $ProjectPath `
        -ProjectDesc $projectDesc `
        -TechStack $techStack `
        -BusinessModules $businessModules `
        -OutputPath $flowchartPath

    # TODO: Add document validation

    Write-Step "Completed"
    Write-Success "All documents generated to: $OutputDir"

} catch {
    Write-Host "Execution failed: $_" -ForegroundColor Red
    $errorLog = Join-Path $logDir "generate-docs-error.log"
    $_ | Out-File -FilePath $errorLog -Append
    exit 1
}
