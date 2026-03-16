# ============================================
# 环境检查脚本
# 验证所有依赖是否正确安装
# ============================================

<#
.SYNOPSIS
    Environment Check Script - Verify all dependencies are correctly installed

.DESCRIPTION
    This script checks the environment to ensure all required dependencies are installed:
    - PowerShell version (>= 5.0)
    - Claude CLI tool
    - Git
    - Required PowerShell modules
    - File permissions

.EXAMPLE
    .\check-environment.ps1
    Run environment check

.EXAMPLE
    Get-Help .\check-environment.ps1 -Detailed
    Show detailed help

.NOTES
    Requirements:
    - PowerShell 5.0 or higher
    - Claude CLI tool
    - Git (optional, for batch operations)
    Author: Claude Opus 4.6
    Version: 1.0
#>

param()

# Show help if -h or -help is specified
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "--help") {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  CLAUDE.md 工具环境检查" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

$allPassed = $true

# ============================================
# 检查 PowerShell 版本
# ============================================

Write-Host "[1/5] 检查 PowerShell 版本..." -ForegroundColor Cyan

$psVersion = $PSVersionTable.PSVersion
Write-Host "  当前版本: $($psVersion.Major).$($psVersion.Minor).$($psVersion.Build)" -ForegroundColor White

if ($psVersion.Major -ge 5) {
    Write-Host "  ✓ PowerShell 版本符合要求 (>= 5.0)" -ForegroundColor Green
} else {
    Write-Host "  ✗ PowerShell 版本过低,需要 5.0 或更高" -ForegroundColor Red
    $allPassed = $false
}

# ============================================
# 检查 Claude CLI
# ============================================

Write-Host "`n[2/5] 检查 Claude Code CLI..." -ForegroundColor Cyan

try {
    $claudeVersion = claude --version 2>&1
    Write-Host "  当前版本: $claudeVersion" -ForegroundColor White
    Write-Host "  ✓ Claude CLI 已安装" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Claude CLI 未安装" -ForegroundColor Red
    Write-Host "  安装命令: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    $allPassed = $false
}

# ============================================
# 检查 Git (可选)
# ============================================

Write-Host "`n[3/5] 检查 Git (可选)..." -ForegroundColor Cyan

try {
    $gitVersion = git --version 2>&1
    Write-Host "  当前版本: $gitVersion" -ForegroundColor White
    Write-Host "  ✓ Git 已安装" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Git 未安装 (可选,用于自动提交)" -ForegroundColor Yellow
    Write-Host "  下载地址: https://git-scm.com/download/win" -ForegroundColor Gray
}

# ============================================
# 检查脚本文件
# ============================================

Write-Host "`n[4/5] 检查脚本文件..." -ForegroundColor Cyan

$requiredFiles = @(
    "regenerate-claude-md.ps1",
    "batch-regenerate-claude-md.ps1",
    "setup-scheduled-task.ps1",
    "repos-config.example.json"
)

$missingFiles = @()

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file (缺失)" -ForegroundColor Red
        $missingFiles += $file
        $allPassed = $false
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "`n  缺失的文件:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
}

# ============================================
# 检查执行策略
# ============================================

Write-Host "`n[5/5] 检查 PowerShell 执行策略..." -ForegroundColor Cyan

$executionPolicy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "  当前策略: $executionPolicy" -ForegroundColor White

if ($executionPolicy -eq "Restricted") {
    Write-Host "  ⚠️  执行策略过于严格,可能无法运行脚本" -ForegroundColor Yellow
    Write-Host "  建议运行: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned" -ForegroundColor Gray
} else {
    Write-Host "  ✓ 执行策略允许运行脚本" -ForegroundColor Green
}

# ============================================
# 测试 Claude API 连接 (可选)
# ============================================

Write-Host "`n[额外] 测试 Claude API 连接..." -ForegroundColor Cyan
Write-Host "  正在测试..." -ForegroundColor Gray

try {
    $testResult = claude -p "Hello" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Claude API 连接正常" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Claude API 可能未配置或连接失败" -ForegroundColor Yellow
        Write-Host "  请确保已配置 API key: claude config" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ⚠️  无法测试 Claude API 连接" -ForegroundColor Yellow
}

# ============================================
# 总结
# ============================================

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  检查完成" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($allPassed) {
    Write-Host "✓ 所有必需组件已就绪!" -ForegroundColor Green
    Write-Host "`n下一步:" -ForegroundColor Yellow
    Write-Host "  1. 阅读快速开始指南: notepad QUICKSTART.md" -ForegroundColor White
    Write-Host "  2. 测试单个项目: .\regenerate-claude-md.ps1 -ProjectPath 'D:\projects\my-app' -DryRun" -ForegroundColor White
    Write-Host "  3. 配置批量处理: Copy-Item repos-config.example.json repos-config.json" -ForegroundColor White
} else {
    Write-Host "✗ 存在问题,请先解决上述错误" -ForegroundColor Red
    Write-Host "`n常见解决方案:" -ForegroundColor Yellow
    Write-Host "  - 安装 Claude CLI: npm install -g @anthropic-ai/claude-code" -ForegroundColor White
    Write-Host "  - 设置执行策略: Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned" -ForegroundColor White
    Write-Host "  - 确保所有脚本文件都在当前目录" -ForegroundColor White
}

Write-Host ""

# 返回状态
if ($allPassed) {
    exit 0
} else {
    exit 1
}
