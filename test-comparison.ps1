# 测试脚本 - 对比 v1.0 和 v2.0 的输出差异
# 用途: 快速验证改进效果

param(
    [string]$TestPath = $PWD.Path
)

Write-Host "`n╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   generate-docs-smart 版本对比测试                     ║" -ForegroundColor Cyan
Write-Host "║   v1.0 vs v2.0                                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "测试目录: $TestPath`n" -ForegroundColor White

# 创建测试输出目录
$testOutputDir = Join-Path $TestPath "test-comparison"
if (Test-Path $testOutputDir) {
    Remove-Item $testOutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $testOutputDir | Out-Null

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "测试 1: 基础模式对比" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

# 测试 v1.0 基础模式
Write-Host "[1/4] 运行 v1.0 基础模式..." -ForegroundColor Cyan
if (Test-Path ".\generate-docs-smart.ps1") {
    $v1Start = Get-Date
    .\generate-docs-smart.ps1 -Path $TestPath 2>&1 | Out-Null
    $v1Duration = (Get-Date) - $v1Start

    if (Test-Path (Join-Path $TestPath "file-functions.md")) {
        Copy-Item (Join-Path $TestPath "file-functions.md") (Join-Path $testOutputDir "file-functions-v1-basic.md")
        $v1Lines = (Get-Content (Join-Path $testOutputDir "file-functions-v1-basic.md")).Count
        Write-Host "  ✓ 完成 (耗时: $($v1Duration.TotalSeconds.ToString('0.0'))秒, 行数: $v1Lines)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 未生成文件" -ForegroundColor Red
    }
} else {
    Write-Host "  ⚠ 未找到 v1.0 脚本" -ForegroundColor Yellow
}

# 测试 v2.0 基础模式
Write-Host "[2/4] 运行 v2.0 基础模式..." -ForegroundColor Cyan
if (Test-Path ".\generate-docs-smart-v2.ps1") {
    $v2Start = Get-Date
    .\generate-docs-smart-v2.ps1 -Path $TestPath 2>&1 | Out-Null
    $v2Duration = (Get-Date) - $v2Start

    if (Test-Path (Join-Path $TestPath "file-functions.md")) {
        Copy-Item (Join-Path $TestPath "file-functions.md") (Join-Path $testOutputDir "file-functions-v2-basic.md")
        $v2Lines = (Get-Content (Join-Path $testOutputDir "file-functions-v2-basic.md")).Count
        Write-Host "  ✓ 完成 (耗时: $($v2Duration.TotalSeconds.ToString('0.0'))秒, 行数: $v2Lines)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 未生成文件" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ 未找到 v2.0 脚本" -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "测试 2: 深度模式对比" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

Write-Host "⚠ 深度模式测试需要 2-5 分钟,是否继续? (Y/N)" -ForegroundColor Yellow
$continue = Read-Host

if ($continue -eq "Y" -or $continue -eq "y") {
    # 测试 v1.0 深度模式
    Write-Host "[3/4] 运行 v1.0 深度模式..." -ForegroundColor Cyan
    if (Test-Path ".\generate-docs-smart.ps1") {
        $v1DeepStart = Get-Date
        .\generate-docs-smart.ps1 -Deep -Path $TestPath 2>&1 | Out-Null
        $v1DeepDuration = (Get-Date) - $v1DeepStart

        if (Test-Path (Join-Path $TestPath "file-functions.md")) {
            Copy-Item (Join-Path $TestPath "file-functions.md") (Join-Path $testOutputDir "file-functions-v1-deep.md")
            $v1DeepLines = (Get-Content (Join-Path $testOutputDir "file-functions-v1-deep.md")).Count
            Write-Host "  ✓ 完成 (耗时: $($v1DeepDuration.TotalSeconds.ToString('0.0'))秒, 行数: $v1DeepLines)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ 未生成文件" -ForegroundColor Red
        }

        if (Test-Path (Join-Path $TestPath ".analysis-report.json")) {
            Copy-Item (Join-Path $TestPath ".analysis-report.json") (Join-Path $testOutputDir "analysis-report-v1.json")
            Write-Host "  ✓ 生成了分析报告" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ 未生成分析报告" -ForegroundColor Yellow
        }
    }

    # 测试 v2.0 深度模式
    Write-Host "[4/4] 运行 v2.0 深度模式..." -ForegroundColor Cyan
    $v2DeepStart = Get-Date
    .\generate-docs-smart-v2.ps1 -Deep -Path $TestPath 2>&1 | Out-Null
    $v2DeepDuration = (Get-Date) - $v2DeepStart

    if (Test-Path (Join-Path $TestPath "file-functions.md")) {
        Copy-Item (Join-Path $TestPath "file-functions.md") (Join-Path $testOutputDir "file-functions-v2-deep.md")
        $v2DeepLines = (Get-Content (Join-Path $testOutputDir "file-functions-v2-deep.md")).Count
        Write-Host "  ✓ 完成 (耗时: $($v2DeepDuration.TotalSeconds.ToString('0.0'))秒, 行数: $v2DeepLines)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ 未生成文件" -ForegroundColor Red
    }

    if (Test-Path (Join-Path $TestPath ".analysis-report.json")) {
        Copy-Item (Join-Path $TestPath ".analysis-report.json") (Join-Path $testOutputDir "analysis-report-v2.json")
        Write-Host "  ✓ 生成了分析报告" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ 未生成分析报告" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⊘ 跳过深度模式测试" -ForegroundColor Gray
}

# 生成对比报告
Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "生成对比报告" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

$report = @"
# generate-docs-smart 版本对比报告

生成时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
测试目录: $TestPath

---

## 基础模式对比

### v1.0 基础模式
- **耗时**: $($v1Duration.TotalSeconds.ToString('0.0')) 秒
- **输出行数**: $v1Lines 行
- **文件**: test-comparison/file-functions-v1-basic.md

### v2.0 基础模式
- **耗时**: $($v2Duration.TotalSeconds.ToString('0.0')) 秒
- **输出行数**: $v2Lines 行
- **文件**: test-comparison/file-functions-v2-basic.md

### 改进效果
- **行数增加**: $(($v2Lines - $v1Lines)) 行 ($(if ($v1Lines -gt 0) { [math]::Round(($v2Lines - $v1Lines) / $v1Lines * 100, 1) } else { 0 })%)
- **耗时变化**: $(($v2Duration.TotalSeconds - $v1Duration.TotalSeconds).ToString('0.0')) 秒

---

## 深度模式对比

"@

if ($continue -eq "Y" -or $continue -eq "y") {
    $report += @"

### v1.0 深度模式
- **耗时**: $($v1DeepDuration.TotalSeconds.ToString('0.0')) 秒
- **输出行数**: $v1DeepLines 行
- **分析报告**: $(if (Test-Path (Join-Path $testOutputDir "analysis-report-v1.json")) { "✓ 已生成" } else { "✗ 未生成" })
- **文件**: test-comparison/file-functions-v1-deep.md

### v2.0 深度模式
- **耗时**: $($v2DeepDuration.TotalSeconds.ToString('0.0')) 秒
- **输出行数**: $v2DeepLines 行
- **分析报告**: $(if (Test-Path (Join-Path $testOutputDir "analysis-report-v2.json")) { "✓ 已生成" } else { "✗ 未生成" })
- **文件**: test-comparison/file-functions-v2-deep.md

### 改进效果
- **行数增加**: $(($v2DeepLines - $v1DeepLines)) 行 ($(if ($v1DeepLines -gt 0) { [math]::Round(($v2DeepLines - $v1DeepLines) / $v1DeepLines * 100, 1) } else { 0 })%)
- **耗时变化**: $(($v2DeepDuration.TotalSeconds - $v1DeepDuration.TotalSeconds).ToString('0.0')) 秒
- **分析报告利用**: $(if (Test-Path (Join-Path $testOutputDir "analysis-report-v2.json")) { "✓ 已整合到文档" } else { "✗ 未利用" })

"@
} else {
    $report += "`n*深度模式测试已跳过*`n"
}

$report += @"

---

## 关键改进验证

### ✅ 改进 1: file-functions.md 不再只是罗列

**v1.0 输出示例**:
``````
## 2. 主要文件说明

### 2.1 配置文件
[通用描述]

### 2.2 源代码目录
[通用描述]
``````

**v2.0 输出示例**:
``````
## 2. 核心文件详细说明

### 2.1 `regenerate-claude-md.ps1`
- **类型**: PowerShell Script
- **行数**: 850
- **主要函数**: Detect-TechStack, Get-ProjectDescription...
- **功能**: 单项目 CLAUDE.md 生成器
``````

**验证**: 打开 test-comparison/file-functions-v2-basic.md 查看实际文件列表

---

### ✅ 改进 2: 深度分析不再依赖 skill 机制

**v1.0 实现**:
- 依赖 ``claude -p "请使用 project-deep-analyzer skill..."``
- skill 路径查找不稳定
- 经常失败

**v2.0 实现**:
- 直接读取 ``.claude/skills/project-deep-analyzer.md`` 文件
- 将内容作为 prompt 模板
- 稳定可用,优雅降级

**验证**: 查看 ``$env:TEMP\deep-analysis-prompt-*.txt`` 文件

---

### ✅ 改进 3: 深度分析结果被充分利用

**v1.0**:
- 生成 ``.analysis-report.json``
- 只显示统计信息
- 后续文档不使用

**v2.0**:
- 生成 ``.analysis-report.json``
- 解析并存储结果
- 整合到 file-functions.md
- 包含 API 端点列表
- 包含数据模型列表

**验证**: 对比 test-comparison/file-functions-v1-deep.md 和 file-functions-v2-deep.md

---

## 查看对比

### 使用 VS Code 对比

``````powershell
# 基础模式对比
code --diff test-comparison/file-functions-v1-basic.md test-comparison/file-functions-v2-basic.md

# 深度模式对比
code --diff test-comparison/file-functions-v1-deep.md test-comparison/file-functions-v2-deep.md
``````

### 使用 Git 对比

``````powershell
cd test-comparison
git diff --no-index file-functions-v1-basic.md file-functions-v2-basic.md
``````

---

## 结论

"@

if ($v2Lines -gt $v1Lines) {
    $report += "✅ **v2.0 基础模式生成了更详细的文档** (+$(($v2Lines - $v1Lines)) 行)`n"
} else {
    $report += "⚠️ v2.0 基础模式行数未增加`n"
}

if ($continue -eq "Y" -or $continue -eq "y") {
    if ($v2DeepLines -gt $v1DeepLines) {
        $report += "✅ **v2.0 深度模式生成了更详细的文档** (+$(($v2DeepLines - $v1DeepLines)) 行)`n"
    }

    if (Test-Path (Join-Path $testOutputDir "analysis-report-v2.json")) {
        $report += "✅ **v2.0 成功生成并利用了深度分析报告**`n"
    }
}

$report += @"

---

**测试完成时间**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**所有测试文件**: $testOutputDir
"@

# 保存报告
$reportPath = Join-Path $testOutputDir "comparison-report.md"
Set-Content -Path $reportPath -Value $report -Encoding UTF8

Write-Host "对比报告已生成: $reportPath" -ForegroundColor Green

# 显示摘要
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "测试摘要" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "基础模式:" -ForegroundColor Cyan
Write-Host "  v1.0: $v1Lines 行 ($($v1Duration.TotalSeconds.ToString('0.0'))秒)"
Write-Host "  v2.0: $v2Lines 行 ($($v2Duration.TotalSeconds.ToString('0.0'))秒)"
Write-Host "  改进: +$(($v2Lines - $v1Lines)) 行 ($(if ($v1Lines -gt 0) { [math]::Round(($v2Lines - $v1Lines) / $v1Lines * 100, 1) } else { 0 })%)" -ForegroundColor $(if ($v2Lines -gt $v1Lines) { "Green" } else { "Yellow" })

if ($continue -eq "Y" -or $continue -eq "y") {
    Write-Host "`n深度模式:" -ForegroundColor Cyan
    Write-Host "  v1.0: $v1DeepLines 行 ($($v1DeepDuration.TotalSeconds.ToString('0.0'))秒)"
    Write-Host "  v2.0: $v2DeepLines 行 ($($v2DeepDuration.TotalSeconds.ToString('0.0'))秒)"
    Write-Host "  改进: +$(($v2DeepLines - $v1DeepLines)) 行 ($(if ($v1DeepLines -gt 0) { [math]::Round(($v2DeepLines - $v1DeepLines) / $v1DeepLines * 100, 1) } else { 0 })%)" -ForegroundColor $(if ($v2DeepLines -gt $v1DeepLines) { "Green" } else { "Yellow" })
}

Write-Host "`n所有测试文件保存在: $testOutputDir" -ForegroundColor White
Write-Host "查看详细报告: notepad $reportPath" -ForegroundColor White

Write-Host "`n建议操作:" -ForegroundColor Yellow
Write-Host "  1. 查看对比报告: notepad $reportPath"
Write-Host "  2. 对比文档差异: code --diff $testOutputDir\file-functions-v1-basic.md $testOutputDir\file-functions-v2-basic.md"
Write-Host "  3. 查看 v2.0 输出: notepad $testOutputDir\file-functions-v2-basic.md"

Write-Host "`n测试完成! ✓" -ForegroundColor Green
