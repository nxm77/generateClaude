# ============================================
# 批量更新多个项目的 CLAUDE.md
# ============================================

<#
.SYNOPSIS
    Batch CLAUDE.md Regeneration - Update CLAUDE.md for multiple projects

.DESCRIPTION
    This script reads a configuration file containing multiple project paths and
    regenerates CLAUDE.md for each project. Useful for maintaining documentation
    across multiple repositories.

.PARAMETER ConfigFile
    Path to the JSON configuration file containing project list (default: .\repos-config.json)

.PARAMETER DryRun
    Preview mode - shows what would be generated without writing files

.PARAMETER OutputDir
    Output directory for batch results (default: .\batch-output)

.PARAMETER AutoCommit
    Automatically commit changes to git after generation

.PARAMETER Verbose
    Show detailed output during execution

.EXAMPLE
    .\batch-regenerate-claude-md.ps1
    Process all projects in repos-config.json

.EXAMPLE
    .\batch-regenerate-claude-md.ps1 -ConfigFile ".\my-repos.json" -DryRun
    Preview batch generation with custom config file

.EXAMPLE
    .\batch-regenerate-claude-md.ps1 -AutoCommit -Verbose
    Generate and auto-commit with detailed output

.NOTES
    Config file format: {"projects": [{"name": "ProjectName", "path": "C:\\Path\\To\\Project"}]}
    Author: Claude Opus 4.6
    Version: 1.0
#>

param(
    [Parameter(Mandatory=$false, HelpMessage="Path to JSON config file")]
    [string]$ConfigFile = ".\repos-config.json",

    [Parameter(Mandatory=$false, HelpMessage="Preview mode - don't write files")]
    [switch]$DryRun,

    [Parameter(Mandatory=$false, HelpMessage="Output directory for batch results")]
    [string]$OutputDir = ".\batch-output",

    [Parameter(Mandatory=$false, HelpMessage="Auto-commit changes to git")]
    [switch]$AutoCommit
)

# Show help if -h or -help is specified
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "--help") {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ============================================
# 辅助函数
# ============================================

function Write-Header {
    param([string]$Text)
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
}

function Write-ProjectHeader {
    param([string]$Name, [int]$Current, [int]$Total)
    Write-Host "`n[$Current/$Total] 处理项目: $Name" -ForegroundColor Yellow
    Write-Host ("=" * 60) -ForegroundColor Gray
}

# ============================================
# 读取配置
# ============================================

if (-not (Test-Path $ConfigFile)) {
    Write-Error "配置文件不存在: $ConfigFile"
    Write-Host "请创建配置文件,参考 repos-config.example.json" -ForegroundColor Yellow
    exit 1
}

try {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
} catch {
    Write-Error "无法解析配置文件: $_"
    exit 1
}

# 创建输出目录
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# ============================================
# 主程序
# ============================================

Write-Header "批量更新 CLAUDE.md"
Write-Host "配置文件: $ConfigFile" -ForegroundColor White
Write-Host "输出目录: $OutputDir" -ForegroundColor White
Write-Host "模式: $(if ($DryRun) { '预览 (不修改文件)' } else { '正常' })" -ForegroundColor White
Write-Host "自动提交: $(if ($AutoCommit) { '是' } else { '否' })" -ForegroundColor White

# 统计信息
$stats = @{
    'Total' = 0
    'Success' = 0
    'Failed' = 0
    'Skipped' = 0
    'Updated' = 0
    'NoChange' = 0
}

$results = @()

# 处理每个项目
$projectIndex = 0
foreach ($repo in $config.repositories) {
    $projectIndex++
    $stats.Total++

    # 检查是否启用
    if ($repo.enabled -eq $false) {
        Write-ProjectHeader $repo.name $projectIndex $config.repositories.Count
        Write-Host "  跳过 (已禁用)" -ForegroundColor Gray
        $stats.Skipped++
        continue
    }

    Write-ProjectHeader $repo.name $projectIndex $config.repositories.Count

    # 检查路径
    $projectPath = $repo.path
    if (-not (Test-Path $projectPath)) {
        Write-Host "  ✗ 路径不存在: $projectPath" -ForegroundColor Red
        $stats.Failed++
        $results += @{
            'Name' = $repo.name
            'Status' = 'Failed'
            'Reason' = '路径不存在'
            'Path' = $projectPath
        }
        continue
    }

    # 创建项目输出目录
    $projectOutputDir = "$OutputDir\$($repo.name)"
    if (-not (Test-Path $projectOutputDir)) {
        New-Item -ItemType Directory -Path $projectOutputDir | Out-Null
    }

    # 调用主脚本
    try {
        $scriptArgs = @{
            'ProjectPath' = $projectPath
            'OutputDir' = $projectOutputDir
        }

        if ($DryRun) {
            $scriptArgs['DryRun'] = $true
        }

        if ($Verbose) {
            $scriptArgs['Verbose'] = $true
        }

        Write-Host "  正在生成..." -ForegroundColor Gray

        # 执行脚本
        $scriptPath = Join-Path $PSScriptRoot "regenerate-claude-md.ps1"
        & $scriptPath @scriptArgs

        if ($LASTEXITCODE -eq 0) {
            # 检查是否有变化
            $newFile = "$projectOutputDir\CLAUDE.md.new"
            $oldFile = "$projectPath\CLAUDE.md"

            $hasChanges = $false
            if (Test-Path $newFile) {
                if (Test-Path $oldFile) {
                    $newContent = Get-Content $newFile -Raw
                    $oldContent = Get-Content $oldFile -Raw
                    $hasChanges = ($newContent -ne $oldContent)
                } else {
                    $hasChanges = $true
                }
            }

            if ($hasChanges) {
                Write-Host "  ✓ 成功 (有变更)" -ForegroundColor Green
                $stats.Updated++

                # 自动提交
                if ($AutoCommit -and -not $DryRun) {
                    Write-Host "  正在提交到 Git..." -ForegroundColor Gray

                    Push-Location $projectPath
                    try {
                        # 复制新文件
                        Copy-Item $newFile "$projectPath\CLAUDE.md" -Force

                        # Git 操作
                        git add CLAUDE.md
                        git commit -m "chore: auto-update CLAUDE.md [bot]"

                        if ($LASTEXITCODE -eq 0) {
                            Write-Host "  ✓ 已提交" -ForegroundColor Green

                            # 可选: 自动推送
                            if ($config.gitConfig.autoPush) {
                                git push
                                if ($LASTEXITCODE -eq 0) {
                                    Write-Host "  ✓ 已推送" -ForegroundColor Green
                                } else {
                                    Write-Host "  ⚠️  推送失败" -ForegroundColor Yellow
                                }
                            }
                        } else {
                            Write-Host "  ⚠️  提交失败" -ForegroundColor Yellow
                        }
                    } finally {
                        Pop-Location
                    }
                }

                $results += @{
                    'Name' = $repo.name
                    'Status' = 'Updated'
                    'Path' = $projectPath
                    'Output' = $projectOutputDir
                }
            } else {
                Write-Host "  ✓ 成功 (无变更)" -ForegroundColor Green
                $stats.NoChange++

                $results += @{
                    'Name' = $repo.name
                    'Status' = 'NoChange'
                    'Path' = $projectPath
                }
            }

            $stats.Success++
        } else {
            Write-Host "  ✗ 失败" -ForegroundColor Red
            $stats.Failed++

            $results += @{
                'Name' = $repo.name
                'Status' = 'Failed'
                'Reason' = '脚本执行失败'
                'Path' = $projectPath
            }
        }
    } catch {
        Write-Host "  ✗ 异常: $_" -ForegroundColor Red
        $stats.Failed++

        $results += @{
            'Name' = $repo.name
            'Status' = 'Failed'
            'Reason' = $_.Exception.Message
            'Path' = $projectPath
        }
    }
}

# ============================================
# 生成汇总报告
# ============================================

Write-Header "执行汇总"

Write-Host "`n统计信息:" -ForegroundColor Yellow
Write-Host "  总计: $($stats.Total)" -ForegroundColor White
Write-Host "  成功: $($stats.Success)" -ForegroundColor Green
Write-Host "  失败: $($stats.Failed)" -ForegroundColor Red
Write-Host "  跳过: $($stats.Skipped)" -ForegroundColor Gray
Write-Host "  有更新: $($stats.Updated)" -ForegroundColor Cyan
Write-Host "  无变更: $($stats.NoChange)" -ForegroundColor Gray

# 生成详细报告
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
$reportContent = @"
# CLAUDE.md 批量更新报告

生成时间: $timestamp
配置文件: $ConfigFile
模式: $(if ($DryRun) { '预览模式' } else { '正常模式' })

## 统计信息

- 总计: $($stats.Total)
- 成功: $($stats.Success)
- 失败: $($stats.Failed)
- 跳过: $($stats.Skipped)
- 有更新: $($stats.Updated)
- 无变更: $($stats.NoChange)

## 详细结果

"@

foreach ($result in $results) {
    $reportContent += @"

### $($result.Name)

- 状态: $($result.Status)
- 路径: $($result.Path)
"@

    if ($result.Output) {
        $reportContent += "`n- 输出: $($result.Output)"
    }

    if ($result.Reason) {
        $reportContent += "`n- 原因: $($result.Reason)"
    }
}

$reportContent += @"


## 需要关注的项目

"@

# 失败的项目
$failedProjects = $results | Where-Object { $_.Status -eq 'Failed' }
if ($failedProjects.Count -gt 0) {
    $reportContent += "`n### 失败的项目`n`n"
    foreach ($project in $failedProjects) {
        $reportContent += "- **$($project.Name)**: $($project.Reason)`n"
    }
} else {
    $reportContent += "`n所有项目处理成功!`n"
}

# 有更新的项目
$updatedProjects = $results | Where-Object { $_.Status -eq 'Updated' }
if ($updatedProjects.Count -gt 0) {
    $reportContent += "`n### 有更新的项目`n`n"
    foreach ($project in $updatedProjects) {
        $reportContent += "- **$($project.Name)**`n"
        $reportContent += "  - 查看详细报告: ``$($project.Output)\changes-report.md```n"
    }
}

$reportContent += @"


## 下一步操作

"@

if ($DryRun) {
    $reportContent += @"

这是预览模式,未修改任何文件。

如果确认无误,运行:
``````powershell
.\batch-regenerate-claude-md.ps1 -ConfigFile "$ConfigFile"
``````

"@
} else {
    if ($stats.Updated -gt 0 -and -not $AutoCommit) {
        $reportContent += @"

有 $($stats.Updated) 个项目已更新,但未自动提交。

手动应用更新:
``````powershell
# 对每个项目
Copy-Item "output\[project-name]\CLAUDE.md.new" "[project-path]\CLAUDE.md"
``````

或启用自动提交:
``````powershell
.\batch-regenerate-claude-md.ps1 -ConfigFile "$ConfigFile" -AutoCommit
``````

"@
    } elseif ($AutoCommit) {
        $reportContent += @"

已自动提交 $($stats.Updated) 个项目的更新。

检查提交:
``````bash
cd [project-path]
git log -1
git show HEAD
``````

"@
    }
}

$reportContent += @"

---
报告生成于: $timestamp
"@

# 保存报告
$reportPath = "$OutputDir\batch-summary-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8

Write-Host "`n汇总报告已生成: $reportPath" -ForegroundColor Green

# 显示失败项目
if ($stats.Failed -gt 0) {
    Write-Host "`n⚠️  有 $($stats.Failed) 个项目失败,请查看报告了解详情" -ForegroundColor Yellow
}

Write-Host "`n============================================`n" -ForegroundColor Cyan

# 返回状态码
if ($stats.Failed -gt 0) {
    exit 1
} else {
    exit 0
}
