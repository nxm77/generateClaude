# Claude Code 在 Windows 10 虚拟机中出现 Bun `Illegal instruction` 的原因与解决方案

> 文档版本：2026-06-09  
> 适用范围：Windows 10 中文版虚拟机、x64 至强服务器环境、Claude Code 运行期间出现 Bun 崩溃或 `Illegal instruction`  
> 文档目的：用于企业内部故障定位、临时规避和长期整改

---

## 1. 问题概述

部分 Windows 10 虚拟机在运行 Claude Code 时，会在终端日志中出现类似信息：

```text
Bun v1.3.14 (...) Windows x64 (baseline)
panic(main thread): Illegal instruction
oh no: Bun has crashed. This indicates a bug in Bun, not your code.
```

故障可能表现为：

- Claude Code 可以正常启动；
- 简单交互可能暂时正常；
- 执行较复杂操作、加载插件、启动子进程或进入后续处理阶段时稳定崩溃；
- 同一台故障虚拟机可以反复复现；
- 同批次的大多数电脑或虚拟机没有问题。

从错误类型看，首要排查方向不是业务脚本、项目代码或中文操作系统，而是：

1. Claude Code 原生可执行文件使用的内嵌 Bun 运行时；
2. 虚拟机实际暴露给 Windows 10 的 CPU 指令集；
3. 故障虚拟机与正常虚拟机之间的宿主机、虚拟 CPU 配置和 Claude Code 安装差异；
4. 安全软件或应用级防护策略的单机差异。

---

## 2. 核心结论

### 2.1 已确认事实

1. 当前 Claude Code 的原生安装方式使用平台相关的原生可执行文件。
2. 从 Claude Code `2.1.113` 开始，npm 安装方式也改为拉取平台相关的原生二进制文件，而不是继续直接运行 JavaScript 入口。
3. 因此，使用以下命令安装最新版 npm 包，不能绕开原生二进制文件：

```powershell
npm install -g @anthropic-ai/claude-code
```

4. Claude Code 官方故障排查文档将 `Illegal instruction` 归类为“架构或 CPU 指令集不匹配”。
5. 虚拟机环境中，即使底层服务器使用至强处理器，Guest OS 也不一定能够看到完整的 AVX、AVX2 等指令集。
6. Windows 10 中文版不是优先怀疑对象。

### 2.2 当前最可能的原因

故障虚拟机实际可见的 CPU 指令集与 Claude Code 原生可执行文件要求不匹配。常见情况包括：

- 虚拟机未透传 AVX；
- 虚拟机可以看到 AVX，但无法看到 AVX2；
- 宿主机本身使用较老代际至强处理器；
- 虚拟化平台启用了 CPU 兼容模式；
- VMware EVC、Per-VM EVC、CPU Mask 或虚拟 CPU 型号限制了 Guest OS 可用指令；
- 故障虚拟机运行在与正常虚拟机不同代际的宿主机节点。

### 2.3 当前不能直接断言的事项

在没有对比故障虚拟机和正常虚拟机的 CPU 特征之前，不能直接断言一定是“缺少 AVX2”。

官方文档明确指出，需要检查 AVX 或其他二进制文件依赖的 CPU 指令。公开问题中既有“缺少 AVX”导致崩溃的案例，也有“具备 AVX 但缺少 AVX2”后，在 `2.1.113` 原生版本中触发 `SIGILL` 的案例。

因此，正确的表述应为：

> 首要怀疑虚拟机实际暴露的 CPU 指令集不完整。应同时检查 SSE4.2、AVX、AVX2、BMI 和 BMI2，再根据对比结果确定最终原因。

---

## 3. 为什么大多数电脑正常，只有少数机器出错？

这并不矛盾。虚拟机和终端安全问题通常是“机器级差异”，而不是所有电脑统一复现。

### 3.1 不同宿主机节点可能使用不同代际的至强处理器

即使服务器都属于至强系列，也可能存在明显的代际差异。例如，不同型号对 AVX2、BMI2、FMA 等指令的支持不同。

```text
正常虚拟机
  → 运行在较新的宿主机
  → Guest OS 可见 AVX、AVX2
  → Claude Code 正常

故障虚拟机
  → 运行在旧宿主机或兼容模式节点
  → Guest OS 只能看到部分指令集
  → 原生运行时触发 Illegal instruction
```

### 3.2 虚拟化平台可能单独限制某一台虚拟机

虚拟化平台为了支持跨代服务器迁移，可能向虚拟机暴露一个较低的 CPU 能力基线。

常见配置包括：

- Hyper-V Processor Compatibility Mode；
- VMware EVC；
- VMware Per-VM EVC；
- CPU Mask；
- QEMU/KVM 的通用 CPU 型号；
- 旧模板克隆出的虚拟机；
- 快照恢复后保留的兼容配置。

即使两个虚拟机位于同一集群，也可能具有不同的 CPU 兼容配置。

### 3.3 Claude Code 安装路径或版本可能不同

故障电脑可能同时残留多套 Claude Code：

- 原生安装版；
- npm 全局安装版；
- 历史版本；
- PATH 中优先级更高的旧入口；
- 自动升级后异常的可执行文件。

仅比较 `claude --version` 不一定足够，还应比较：

- `where.exe claude` 输出；
- `Get-Command claude -All` 输出；
- 实际入口文件路径；
- 可执行文件 SHA256；
- npm 包版本；
- npm 包入口是否仍为 `cli.js`。

### 3.4 安全软件可能存在单机差异

安全软件不是当前首要怀疑对象，但不能完全排除。

可能存在：

- EDR 客户端版本不同；
- 某台机器属于不同设备组；
- 应用级 Exploit Protection 配置不同；
- 组策略下发未完全一致；
- 终端安全软件升级后尚未重启；
- 某些进程注入或内存保护策略只在个别机器生效。

排查顺序应为：

```text
先比较 CPU 指令集
  ↓
再比较 Claude Code 路径、版本和文件哈希
  ↓
最后比较安全软件和组策略
```

不建议一开始就在全公司范围关闭安全软件。

---

## 4. Claude Code npm 安装方式的版本分界

### 4.1 `2.1.113` 开始发生变化

Claude Code 官方变更日志记录：

```text
2.1.113
Changed the CLI to spawn a native Claude Code binary
(via a per-platform optional dependency)
instead of bundled JavaScript
```

含义是：

```text
2.1.112 及更早的 npm 版本
  → npm 安装 JavaScript 版本
  → Node.js 执行 CLI 入口

2.1.113 及更新的 npm 版本
  → npm 拉取平台相关原生二进制
  → claude 命令启动原生 binary
  → 不再由 Node.js 直接执行 CLI
```

### 4.2 当前 npm 最新版不能规避内嵌运行时问题

当前官方安装文档明确说明：

> npm package installs the same native binary as the standalone installer.

因此，下面的安装方式不能用于绕开原生 Bun 运行时：

```powershell
npm install -g @anthropic-ai/claude-code@latest
```

### 4.3 临时兼容版本

对于必须运行在旧虚拟机环境中的电脑，可临时固定使用：

```text
@anthropic-ai/claude-code@2.1.112
```

公开问题中将 `2.1.112` 描述为最后一个 JavaScript-based npm 版本，并给出了固定安装 `2.1.112` 的临时规避方法。

需要强调：

> `2.1.112` 是临时兼容方案，不是长期支持版本。长期仍应修复虚拟机 CPU 特征透传问题，或迁移到具备完整指令集能力的宿主机。

---

## 5. 标准排查流程

## 5.1 第一步：收集故障日志

保留完整日志，重点提取以下内容：

```text
Bun 版本
Windows x64 / baseline 等构建信息
CPU: ... 行
Features: ... 行
no_avx
no_avx2
Illegal instruction
panic(main thread)
```

示例：

```text
CPU: sse42 avx
Features: ... no_avx2 ...
panic(main thread): Illegal instruction
```

或者：

```text
CPU: sse42 popcnt
Features: ... no_avx2 no_avx ...
CPU lacks AVX support
panic(main thread): Illegal instruction
```

日志中的 CPU 特征能够快速判断排查方向。

---

## 5.2 第二步：在故障虚拟机和正常虚拟机中分别执行检查

建议选择：

- 1 台稳定复现的故障虚拟机；
- 1 台相同用途、正常运行的虚拟机。

分别执行以下命令，并保存输出。

### 系统与虚拟 CPU 信息

```powershell
hostname

Get-CimInstance Win32_Processor |
    Select-Object Name, Manufacturer, Description,
        NumberOfCores, NumberOfLogicalProcessors

$env:PROCESSOR_ARCHITECTURE
```

### Claude Code 安装路径与版本

```powershell
where.exe claude

Get-Command claude -All |
    Format-Table CommandType, Name, Source, Version -AutoSize

claude --version
```

### 当前入口文件 SHA256

```powershell
$claudeCommands = Get-Command claude -All -ErrorAction SilentlyContinue

foreach ($cmd in $claudeCommands) {
    if ($cmd.Source -and (Test-Path $cmd.Source)) {
        Get-FileHash $cmd.Source -Algorithm SHA256 |
            Select-Object Path, Hash
    }
}
```

### npm 全局安装信息

```powershell
npm root -g

npm list -g @anthropic-ai/claude-code --depth=0
```

---

## 5.3 第三步：使用 Coreinfo 检查 Guest OS 实际可见的 CPU 特征

微软 Sysinternals 提供 `Coreinfo` 工具，可用于查看 Windows 实际可见的 CPU 功能。

在故障虚拟机和正常虚拟机中分别执行：

```powershell
.\Coreinfo64.exe -f |
    findstr /i "SSE4.2 AVX AVX2 BMI BMI2 FMA"
```

重点关注：

| CPU 特征 | 正常虚拟机 | 故障虚拟机 | 初步判断 |
|---|---:|---:|---|
| SSE4.2 | `*` | `*` | 基础条件正常 |
| AVX | `*` | `-` | 高度疑似未透传 AVX |
| AVX2 | `*` | `-` | 高度疑似宿主机代际、兼容模式、EVC 或 CPU Mask 差异 |
| BMI2 | `*` | `-` | 可能与 AVX2 同时缺失 |
| 全部一致 | `*` | `*` | 转入 Claude Code 文件和安全策略排查 |

Coreinfo 输出中：

```text
*
```

表示可用；

```text
-
```

表示不可用或未向 Guest OS 暴露。

---

## 5.4 第四步：检查虚拟化平台配置

### Hyper-V

让运维在 Hyper-V 宿主机中检查：

```powershell
Get-VMProcessor -VMName "<虚拟机名称>" |
    Select-Object VMName,
        CompatibilityForMigrationEnabled,
        CompatibilityForOlderOperatingSystemsEnabled
```

如果宿主机本身支持完整指令集，但 Guest OS 看不到，可在确认迁移需求后，关闭兼容模式。

注意：修改处理器兼容模式前，需要关闭虚拟机。

```powershell
Stop-VM -Name "<虚拟机名称>"

Set-VMProcessor -VMName "<虚拟机名称>" `
    -CompatibilityForMigrationEnabled $false

Start-VM -Name "<虚拟机名称>"
```

微软官方文档说明，Hyper-V 处理器兼容模式会隐藏较新的处理器指令集，以便虚拟机能够在不同代际宿主机之间迁移。

### VMware / vSphere

让运维检查：

```text
EVC
Per-VM EVC
CPU Mask
vCPU Model
Host CPU Passthrough
当前 VM 所在宿主机
VM 模板来源
是否曾从旧节点迁移
是否需要完全关机后重新启动
```

### QEMU / KVM / Proxmox

让运维检查虚拟 CPU 型号。不要长期使用只提供最低能力基线的通用型号。

常见整改方向：

```text
通用虚拟 CPU 型号
  → 调整为 host passthrough
```

或选择明确包含 AVX、AVX2 的现代 CPU profile。

---

## 5.5 第五步：检查宿主机能力

如果虚拟机中缺少 AVX 或 AVX2，需要在宿主机上执行相同的 Coreinfo 检查。

判断逻辑：

| 宿主机 | Guest OS | 结论 |
|---|---|---|
| 有 AVX / AVX2 | 无 AVX / AVX2 | 虚拟化配置屏蔽了指令集 |
| 无 AVX / AVX2 | 无 AVX / AVX2 | 宿主机硬件能力不足，需要迁移 |
| 有 AVX / AVX2 | 有 AVX / AVX2 | 继续排查原生 binary、路径和安全软件 |
| 不同宿主机结果不同 | VM 随节点变化 | 集群中混用了不同代际服务器 |

---

## 5.6 第六步：只有在 CPU 特征一致后，才排查安全软件

如果故障虚拟机和正常虚拟机满足以下条件：

```text
CPU 特征一致
Claude Code 版本一致
安装路径一致
SHA256 一致
npm 包版本一致
```

再比较安全软件和组策略。

### 导出组策略结果

```powershell
gpresult /h "$env:TEMP\gpresult.html"
```

### 建议对比项

```text
Windows Defender Exploit Guard
Exploit Protection
Application Control
AppLocker
EDR 客户端版本
EDR 设备组
应用级防护策略
最近一次策略更新时间
最近一次终端重启时间
```

安全软件排查应采用“正常机与故障机对比”的方式，不建议直接全局关闭防护。

---

## 6. 长期解决方案

## 6.1 推荐方案：修复虚拟机 CPU 指令集透传

优先目标：

```text
SSE4.2 = 可用
AVX    = 可用
AVX2   = 可用
BMI2   = 建议可用
```

处理步骤：

1. 确认故障 VM 当前所在宿主机；
2. 查询宿主机具体至强型号；
3. 在宿主机和 Guest OS 中分别运行 Coreinfo；
4. 检查 CPU 兼容模式、EVC、Per-VM EVC、CPU Mask 和虚拟 CPU 型号；
5. 关闭 VM 后调整配置；
6. 重新启动 VM；
7. 再次运行 Coreinfo；
8. 使用企业批准版本的 Claude Code 完成回归测试。

## 6.2 如果宿主机硬件能力不足

如果宿主机本身不支持 AVX 或 AVX2，不能通过虚拟机配置补出缺失的硬件指令。

可选处理方式：

- 将 VM 迁移到较新的宿主机；
- 调整资源池；
- 将旧服务器节点从 AI 编程终端资源池中移出；
- 对旧节点仅保留不依赖 Claude Code 原生版本的工作负载。

## 6.3 企业环境建议建立最低验收标准

对于后续推广，建议将以下检查加入 Claude Code 安装前置检查：

```text
操作系统：Windows 10 / Windows 11 x64
架构：x64
内存：满足企业标准
SSE4.2：可用
AVX：可用
AVX2：建议作为企业最低验收标准
Claude Code：使用企业批准版本
安装路径：唯一
自动更新：受控
```

需要说明：

> Claude Code 官方故障排查文档明确提到 AVX 或其他必要指令集。将 AVX2 纳入企业最低验收标准，是为了降低当前原生运行时和后续版本变化带来的兼容性风险。

---

## 7. 临时兼容方案：固定使用 npm `2.1.112`

当虚拟机无法立即调整，且需要尽快恢复使用时，可临时固定安装最后一个 JavaScript-based npm 版本：

```text
@anthropic-ai/claude-code@2.1.112
```

## 7.1 适用范围

适用于：

- 故障 VM 暂时无法迁移；
- 虚拟化平台调整需要排期；
- 需要先恢复基本使用；
- 已确认新版原生 binary 在该 VM 上触发 `Illegal instruction`。

不建议：

- 全公司统一回退；
- 将 `2.1.112` 作为长期标准版本；
- 在未验证插件兼容性的情况下直接批量部署。

## 7.2 Windows PowerShell 安装步骤

### 第一步：记录现有安装

```powershell
where.exe claude

Get-Command claude -All |
    Format-Table CommandType, Name, Source, Version -AutoSize

claude --version
```

### 第二步：卸载 npm 版本

```powershell
npm uninstall -g @anthropic-ai/claude-code
```

### 第三步：检查原生安装残留

```powershell
Test-Path "$env:USERPROFILE\.local\bin\claude.exe"
```

如果确认该路径属于需要移除的原生 Claude Code 安装，可以先备份：

```powershell
$nativeClaude = "$env:USERPROFILE\.local\bin\claude.exe"

if (Test-Path $nativeClaude) {
    Rename-Item $nativeClaude `
        "claude.exe.native-backup.$(Get-Date -Format yyyyMMdd-HHmmss)"
}
```

### 第四步：安装固定 npm 版本

```powershell
npm install -g @anthropic-ai/claude-code@2.1.112
```

### 第五步：关闭后台自动更新检查

```powershell
setx DISABLE_AUTOUPDATER 1
```

关闭 PowerShell，重新打开后验证：

```powershell
echo $env:DISABLE_AUTOUPDATER
```

预期结果：

```text
1
```

需要注意：

- `DISABLE_AUTOUPDATER=1` 仅关闭后台自动更新检查；
- 手动执行 `claude update` 仍可能更新；
- 不要执行 `claude install`；
- 不要执行 `npm install -g @anthropic-ai/claude-code@latest`；
- 不要执行不带版本号的 npm 安装命令；
- 企业内部应通过私有 npm 仓库、安装脚本和终端策略限制自行升级。

## 7.3 验证是否真正切换到 Node.js 路径

```powershell
where.exe claude

claude --version

$npmRoot = npm root -g

Get-Content "$npmRoot\@anthropic-ai\claude-code\package.json" |
    Select-String '"claude"'

Get-Content "$npmRoot\@anthropic-ai\claude-code\cli.js" -TotalCount 1
```

预期版本：

```text
2.1.112 (Claude Code)
```

预期入口应指向 JavaScript 文件，并由 Node.js 执行。

## 7.4 临时方案的风险

使用 `2.1.112` 需要接受以下限制：

- 无法获得后续新增功能；
- 无法获得后续错误修复；
- 无法获得后续安全修复；
- 新版插件能力可能不完全兼容；
- 官方没有将 `2.1.112` 定义为 LTS 版本；
- 只能作为过渡方案使用。

---

## 8. 不建议采用的处理方式

## 8.1 仅改用 npm 最新版

无效。

```powershell
npm install -g @anthropic-ai/claude-code@latest
```

当前 npm 最新版仍会下载平台相关原生 binary。

## 8.2 单独安装或升级系统 Bun

通常无效。

原因是 Claude Code 使用的是自身原生可执行文件中的运行时路径，不会因为系统安装了另一个 Bun 而自动替换。

## 8.3 重装 Windows 10 中文版

优先级很低。

当前症状更符合 CPU 指令集、虚拟化配置或原生 binary 差异。中文语言包通常不会导致 `Illegal instruction`。

## 8.4 全面关闭终端安全软件

不建议。

应先完成 CPU 特征、版本、路径和哈希对比。安全软件只作为后续对比项处理。

## 8.5 仅切换 stable 通道

只能降低回归风险，不能彻底规避原生 binary。

当前 npm 和原生安装方式都会使用原生可执行文件。即使 stable 通道跳过部分严重回归，也不能解决 Guest OS 缺少必要 CPU 指令的问题。

---

## 9. 推荐处理优先级

| 优先级 | 操作 | 目的 |
|---:|---|---|
| 1 | 对比故障 VM 与正常 VM 的 Coreinfo 输出 | 确认 AVX、AVX2 等 CPU 特征差异 |
| 2 | 对比宿主机 Coreinfo 输出 | 判断是硬件能力不足还是虚拟化配置屏蔽 |
| 3 | 对比 Claude Code 路径、版本、SHA256 | 排除重复安装、自动更新和文件差异 |
| 4 | 检查 Hyper-V 兼容模式、VMware EVC、CPU Mask 或 vCPU 型号 | 修复虚拟化配置 |
| 5 | 将故障 VM 迁移到较新的宿主机 | 解决宿主机能力不足 |
| 6 | 必要时固定 npm `2.1.112` | 临时恢复使用 |
| 7 | 在前述条件一致后比较 EDR 和组策略 | 排除安全软件单机差异 |

---

## 10. 企业发布建议

建议建立两条版本线：

| 适用范围 | 建议方案 |
|---|---|
| CPU 指令集完整、回归测试通过的电脑 | 使用企业批准的较新 Claude Code 版本 |
| 暂时无法整改的旧 VM | 固定 npm `@anthropic-ai/claude-code@2.1.112`，仅作为临时兼容方案 |

建议建立统一发布流程：

```text
外部新版本
  ↓
隔离环境安装
  ↓
Windows 10 / Windows 11 / 虚拟机回归测试
  ↓
检查 AVX、AVX2、BMI2
  ↓
验证长会话、插件加载、子进程和复杂交互
  ↓
生成企业批准版本清单
  ↓
通过内部渠道分发
  ↓
关闭终端自由自动升级
```

建议维护一份企业批准版本表：

| 字段 | 示例 |
|---|---|
| Claude Code 版本 | `2.x.x` |
| 安装方式 | 原生 / npm 固定版本 |
| 适用终端 | 物理机 / 标准 VM / 旧 VM |
| 最低 CPU 特征 | AVX、AVX2 |
| 测试日期 | YYYY-MM-DD |
| 测试负责人 | 姓名 |
| 已知问题 | 简述 |
| 回退版本 | `2.1.112` |

---

## 11. 一键采集脚本

可以在故障 VM 和正常 VM 中分别运行以下 PowerShell 脚本，将结果交给运维对比。

```powershell
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$out = "$env:TEMP\claude-env-check-$env:COMPUTERNAME-$timestamp.txt"

"=== Basic Info ===" | Out-File $out
"ComputerName: $env:COMPUTERNAME" | Out-File $out -Append
"OS Architecture: $env:PROCESSOR_ARCHITECTURE" | Out-File $out -Append

"`n=== CPU ===" | Out-File $out -Append
Get-CimInstance Win32_Processor |
    Select-Object Name, Manufacturer, Description,
        NumberOfCores, NumberOfLogicalProcessors |
    Format-List |
    Out-File $out -Append

"`n=== Claude Paths ===" | Out-File $out -Append
where.exe claude 2>&1 | Out-File $out -Append

"`n=== Claude Commands ===" | Out-File $out -Append
Get-Command claude -All -ErrorAction SilentlyContinue |
    Format-Table CommandType, Name, Source, Version -AutoSize |
    Out-File $out -Append

"`n=== Claude Version ===" | Out-File $out -Append
claude --version 2>&1 | Out-File $out -Append

"`n=== Claude Entry Hashes ===" | Out-File $out -Append
$claudeCommands = Get-Command claude -All -ErrorAction SilentlyContinue
foreach ($cmd in $claudeCommands) {
    if ($cmd.Source -and (Test-Path $cmd.Source)) {
        Get-FileHash $cmd.Source -Algorithm SHA256 |
            Format-List |
            Out-File $out -Append
    }
}

"`n=== npm Root ===" | Out-File $out -Append
npm root -g 2>&1 | Out-File $out -Append

"`n=== npm Claude Package ===" | Out-File $out -Append
npm list -g @anthropic-ai/claude-code --depth=0 2>&1 |
    Out-File $out -Append

"`n=== Coreinfo Features ===" | Out-File $out -Append
if (Test-Path ".\Coreinfo64.exe") {
    .\Coreinfo64.exe -f 2>&1 |
        findstr /i "SSE4.2 AVX AVX2 BMI BMI2 FMA" |
        Out-File $out -Append
} else {
    "Coreinfo64.exe not found in current directory." |
        Out-File $out -Append
}

Write-Host "Environment report written to: $out"
```

---

## 12. 最终建议

当前最合理的处理方式是：

1. 不把问题归因于项目脚本或 Windows 10 中文版；
2. 先用 Coreinfo 对比故障 VM 和正常 VM 的 SSE4.2、AVX、AVX2、BMI、BMI2；
3. 再检查宿主机至强型号、VM 所在节点、Hyper-V 兼容模式、VMware EVC 或 CPU Mask；
4. 比较 Claude Code 路径、版本和 SHA256，排除单机安装差异；
5. 只有在 CPU 特征与 binary 完全一致后，再比较安全软件策略；
6. 长期修复虚拟机 CPU 指令集透传或迁移宿主机；
7. 短期无法整改时，临时固定 npm 安装 `@anthropic-ai/claude-code@2.1.112`。

---

## 13. 参考资料

### Claude Code 官方文档

1. Claude Code Changelog  
   https://code.claude.com/docs/en/changelog

2. Claude Code Advanced Setup  
   https://code.claude.com/docs/en/setup

3. Claude Code Troubleshoot Installation and Login  
   https://code.claude.com/docs/en/troubleshoot-install

4. Claude Code Environment Variables  
   https://code.claude.com/docs/en/env-vars

### Microsoft 官方文档

5. Sysinternals Coreinfo  
   https://learn.microsoft.com/en-us/sysinternals/downloads/coreinfo

6. Processor compatibility for Hyper-V virtual machines  
   https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/processor-compatibility-mode

7. Configure processor compatibility mode in Hyper-V virtual machines  
   https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/configure-processor-compatibility-mode

8. gpresult  
   https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/gpresult

### 公开问题记录

9. Claude Code `2.1.113` 在缺少 AVX2 的 Intel CPU 上触发 SIGILL  
   https://github.com/anthropics/claude-code/issues/50466

10. Claude Code 在未暴露 AVX 的虚拟化环境中触发 `Illegal instruction`  
    https://github.com/anthropics/claude-code/issues/19981

11. `2.1.112` 作为最后一个 JS-based 版本的相关问题记录  
    https://github.com/anthropics/claude-code/issues/50270
