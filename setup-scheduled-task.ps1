# ============================================
# 设置 Windows 定时任务
# ============================================

<#
.SYNOPSIS
    Setup Windows Scheduled Task - Automate CLAUDE.md updates

.DESCRIPTION
    This script creates a Windows scheduled task to automatically run the batch
    CLAUDE.md regeneration script at a specified time each day.

.PARAMETER TaskName
    Name of the scheduled task (default: Claude-MD-Auto-Update)

.PARAMETER ScriptPath
    Path to the batch regeneration script (default: D:\cx\batch-regenerate-claude-md.ps1)

.PARAMETER ConfigPath
    Path to the repos configuration file (default: D:\cx\repos-config.json)

.PARAMETER Time
    Time to run the task daily in HH:mm format (default: 02:00)

.PARAMETER AutoCommit
    Enable auto-commit for the scheduled task

.PARAMETER Remove
    Remove the scheduled task instead of creating it

.EXAMPLE
    .\setup-scheduled-task.ps1
    Create scheduled task with default settings (runs at 2:00 AM daily)

.EXAMPLE
    .\setup-scheduled-task.ps1 -Time "09:00" -AutoCommit
    Create task to run at 9:00 AM with auto-commit enabled

.EXAMPLE
    .\setup-scheduled-task.ps1 -Remove
    Remove the scheduled task

.NOTES
    Requires administrator privileges to create scheduled tasks
    Author: Claude Opus 4.6
    Version: 1.0
#>

param(
    [Parameter(Mandatory=$false, HelpMessage="Name of the scheduled task")]
    [string]$TaskName = "Claude-MD-Auto-Update",

    [Parameter(Mandatory=$false, HelpMessage="Path to batch regeneration script")]
    [string]$ScriptPath = "D:\cx\batch-regenerate-claude-md.ps1",

    [Parameter(Mandatory=$false, HelpMessage="Path to repos config file")]
    [string]$ConfigPath = "D:\cx\repos-config.json",

    [Parameter(Mandatory=$false, HelpMessage="Time to run task (HH:mm format)")]
    [string]$Time = "02:00",

    [Parameter(Mandatory=$false, HelpMessage="Enable auto-commit")]
    [switch]$AutoCommit,

    [Parameter(Mandatory=$false, HelpMessage="Remove the scheduled task")]
    [switch]$Remove
)

# Show help if -h or -help is specified
if ($args -contains "-h" -or $args -contains "-help" -or $args -contains "--help") {
    Get-Help $MyInvocation.MyCommand.Path -Detailed
    exit 0
}

# ============================================
# 删除现有任务
# ============================================

if ($Remove) {
    Write-Host "正在删除定时任务: $TaskName" -ForegroundColor Yellow

    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction Stop
        Write-Host "✓ 定时任务已删除" -ForegroundColor Green
    } catch {
        Write-Host "✗ 删除失败: $_" -ForegroundColor Red
    }

    exit
}

# ============================================
# 验证路径
# ============================================

if (-not (Test-Path $ScriptPath)) {
    Write-Error "脚本文件不存在: $ScriptPath"
    exit 1
}

if (-not (Test-Path $ConfigPath)) {
    Write-Error "配置文件不存在: $ConfigPath"
    exit 1
}

# ============================================
# 创建定时任务
# ============================================

Write-Host "正在创建定时任务..." -ForegroundColor Cyan
Write-Host "  任务名称: $TaskName" -ForegroundColor White
Write-Host "  脚本路径: $ScriptPath" -ForegroundColor White
Write-Host "  配置文件: $ConfigPath" -ForegroundColor White
Write-Host "  执行时间: 每天 $Time" -ForegroundColor White
Write-Host "  自动提交: $(if ($AutoCommit) { '是' } else { '否' })" -ForegroundColor White

# 构建参数
$arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" -ConfigFile `"$ConfigPath`""
if ($AutoCommit) {
    $arguments += " -AutoCommit"
}

# 创建任务动作
$action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument $arguments

# 创建触发器 (每天指定时间)
$trigger = New-ScheduledTaskTrigger `
    -Daily `
    -At $Time

# 创建任务设置
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RunOnlyIfNetworkAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

# 创建任务主体 (使用当前用户)
$principal = New-ScheduledTaskPrincipal `
    -UserId $env:USERNAME `
    -LogonType S4U `
    -RunLevel Highest

# 注册任务
try {
    # 检查任务是否已存在
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if ($existingTask) {
        Write-Host "`n⚠️  任务已存在,是否覆盖? (y/N): " -ForegroundColor Yellow -NoNewline
        $confirm = Read-Host

        if ($confirm -ne 'y' -and $confirm -ne 'Y') {
            Write-Host "已取消" -ForegroundColor Gray
            exit
        }

        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    Register-ScheduledTask `
        -TaskName $TaskName `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Principal $principal `
        -Description "自动更新项目的 CLAUDE.md 文件" | Out-Null

    Write-Host "`n✓ 定时任务创建成功!" -ForegroundColor Green

    # 显示任务信息
    Write-Host "`n任务详情:" -ForegroundColor Cyan
    $task = Get-ScheduledTask -TaskName $TaskName
    Write-Host "  状态: $($task.State)" -ForegroundColor White
    Write-Host "  下次运行: $((Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo).NextRunTime)" -ForegroundColor White

    # 提供管理命令
    Write-Host "`n管理命令:" -ForegroundColor Cyan
    Write-Host "  查看任务: Get-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "  立即运行: Start-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "  禁用任务: Disable-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "  启用任务: Enable-ScheduledTask -TaskName '$TaskName'" -ForegroundColor Gray
    Write-Host "  删除任务: .\setup-scheduled-task.ps1 -Remove" -ForegroundColor Gray
    Write-Host "  查看日志: Get-WinEvent -LogName 'Microsoft-Windows-TaskScheduler/Operational' | Where-Object {`$_.Message -like '*$TaskName*'} | Select-Object -First 10" -ForegroundColor Gray

} catch {
    Write-Host "`n✗ 创建失败: $_" -ForegroundColor Red
    exit 1
}

# ============================================
# 测试运行 (可选)
# ============================================

Write-Host "`n是否要立即测试运行? (y/N): " -ForegroundColor Yellow -NoNewline
$testRun = Read-Host

if ($testRun -eq 'y' -or $testRun -eq 'Y') {
    Write-Host "`n正在测试运行..." -ForegroundColor Cyan

    try {
        Start-ScheduledTask -TaskName $TaskName
        Write-Host "✓ 任务已启动" -ForegroundColor Green
        Write-Host "  查看任务状态: Get-ScheduledTask -TaskName '$TaskName' | Get-ScheduledTaskInfo" -ForegroundColor Gray
    } catch {
        Write-Host "✗ 启动失败: $_" -ForegroundColor Red
    }
}

Write-Host ""
