# CLAUDE.md 重新生成工具

基于 2026 年最新最佳实践的 CLAUDE.md 自动生成和更新工具。

## 功能特点

- ✅ 自动检测多种技术栈 (TypeScript, Python, Java, C++, C#, VB.NET)
- ✅ 遵循 2026 年最佳实践 (40-80 行理想长度)
- ✅ 智能提取项目信息 (命令、结构、描述)
- ✅ 生成详细的变更报告
- ✅ 长度验证和警告
- ✅ 安全的备份机制

## 快速开始

### 基本使用

```powershell
# 为指定项目生成 CLAUDE.md
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"
```

### 参数说明

| 参数 | 必需 | 说明 | 默认值 |
|------|------|------|--------|
| `-ProjectPath` | 是 | 项目根目录路径 | - |
| `-DryRun` | 否 | 只生成不覆盖原文件 | false |
| `-OutputDir` | 否 | 输出目录 | `.\output` |
| `-Verbose` | 否 | 显示详细日志 | false |

### 使用示例

```powershell
# 1. 基本使用 - 生成并提示是否覆盖
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"

# 2. 只生成不覆盖 (预览模式)
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun

# 3. 指定输出目录
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -OutputDir "D:\reports"

# 4. 显示详细日志
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -Verbose

# 5. 组合使用
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app" -DryRun -Verbose
```

## 工作流程

```
1. 检测技术栈
   ├─ 扫描项目文件 (package.json, pom.xml, CMakeLists.txt 等)
   └─ 识别使用的语言和框架

2. 提取项目信息
   ├─ 从 README.md 提取项目描述
   ├─ 从 package.json 等提取关键命令
   └─ 分析目录结构

3. 生成新的 CLAUDE.md
   ├─ 调用 Claude CLI
   ├─ 遵循 40-80 行最佳实践
   └─ 只包含 Claude 需要的核心信息

4. 验证长度
   ├─ 40-80 行: ✓✓✓ 理想
   ├─ 81-200 行: ✓ 可接受
   ├─ 201-300 行: ⚠️ 需要精简
   └─ 300+ 行: ✗ 过长

5. 对比差异
   ├─ 使用 git diff 生成详细对比
   └─ 统计行数变化

6. 生成报告
   ├─ 变更摘要
   ├─ 详细差异
   ├─ 最佳实践检查清单
   └─ 下一步操作建议
```

## 输出文件

运行后会在输出目录生成以下文件:

```
output/
├─ CLAUDE.md.new          # 新生成的 CLAUDE.md
├─ CLAUDE.md.old          # 原文件备份 (如果存在)
└─ changes-report.md      # 详细变更报告
```

## 支持的技术栈

| 技术栈 | 检测文件 | 提取的命令 |
|--------|---------|-----------|
| TypeScript/Node.js | `package.json` | npm scripts (dev, build, test 等) |
| Python | `requirements.txt`, `pyproject.toml` | pip install, pytest 等 |
| Java Maven | `pom.xml` | mvn clean install, mvn test 等 |
| Java Gradle | `build.gradle` | gradle build, gradle test 等 |
| C++ | `CMakeLists.txt` | cmake, ctest 等 |
| C# | `*.csproj` | dotnet build, dotnet test 等 |
| VB.NET | `*.vbproj` | dotnet build, dotnet run 等 |

## CLAUDE.md 最佳实践 (2026)

### 推荐长度

- **理想**: 40-80 行 ✓✓✓
- **可接受**: 81-200 行 ✓
- **需要精简**: 201-300 行 ⚠️
- **过长**: 300+ 行 ✗

### 应该包含的内容

1. **项目一句话描述** - 让 Claude 快速理解项目
2. **关键命令** - Claude 无法推断的命令 (5-8 个)
3. **架构说明** - 关键目录和架构边界 (5-10 行)
4. **代码规范** - 非默认的、项目特定的规则 (3-5 条)
5. **验证步骤** - 修改后应该运行的命令 (3-5 行)
6. **常见陷阱** - 容易出错的地方 (2-4 条)
7. **文档引用** - 链接到详细文档 (2-3 行)

### 应该避免的内容

- ❌ 标准语言约定 (Claude 已经知道)
- ❌ Linter 强制的规则 (配置文件已定义)
- ❌ 详细 API 文档 (太长,会过时)
- ❌ 代码示例 (重构后会过时)
- ❌ 依赖列表 (Claude 可以读 package.json)
- ❌ "写干净代码"等泛泛建议 (无用噪音)

### 推荐结构

```markdown
# [项目名] - [一句话描述]

## Commands
[5-8 个关键命令]

## Architecture
[关键目录 + 架构边界]

## Code Conventions
[非默认规则]

## Verification
[验证步骤]

## Gotchas
[常见陷阱]

## References
[文档链接]
```

## 变更报告示例

生成的 `changes-report.md` 包含:

```markdown
# CLAUDE.md 重新生成报告

生成时间: 2026-03-15 14:30:25
项目路径: D:\projects\my-app

## 检测信息
- 技术栈: typescript/nodejs, python
- 关键目录: src/, tests/, docs/

## 长度检查
- 旧版本: 156 行
- 新版本: 68 行
- 减少: -88 行
- 状态: ✓✓✓ 理想

## 最佳实践检查清单
- [x] 是否包含项目一句话描述?
- [x] 是否只包含 Claude 无法推断的命令?
- [x] 是否避免了标准语言约定?
- [x] 总长度是否在 200 行以内?

## 详细差异
[git diff 输出]

## 下一步操作
[应用建议]
```

## 常见问题

### Q: 生成的 CLAUDE.md 太长怎么办?

A: 脚本会自动警告。建议:
1. 检查是否包含了 Claude 可以从代码推断的信息
2. 将详细内容移到 `.claude/rules/` 目录
3. 使用文件引用代替代码示例
4. 删除标准语言约定

### Q: 如何处理多技术栈项目?

A: 脚本会自动检测所有技术栈,并为每个技术栈提取相应的命令和规范。

### Q: 生成的内容不准确怎么办?

A:
1. 使用 `-DryRun` 预览生成结果
2. 手动编辑 `output/CLAUDE.md.new`
3. 添加 `<!-- MANUAL -->` 标记保护手动内容
4. 重新运行脚本

### Q: 如何保留手动添加的内容?

A: 使用标记保护:

```markdown
<!-- MANUAL: custom-section -->
这部分内容不会被脚本修改
<!-- END MANUAL -->
```

### Q: 可以批量处理多个项目吗?

A: 可以,创建一个批处理脚本:

```powershell
# batch-regenerate.ps1
$projects = @(
    "D:\projects\project-alpha",
    "D:\projects\project-beta",
    "D:\projects\project-gamma"
)

foreach ($project in $projects) {
    Write-Host "处理: $project" -ForegroundColor Cyan
    .\regenerate-claude-md.ps1 -ProjectPath $project -DryRun
}
```

## 定时任务设置

### 使用 Windows Task Scheduler

```powershell
# 创建定时任务
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File D:\cx\regenerate-claude-md.ps1 -ProjectPath 'D:\projects\my-app'"

$trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM

Register-ScheduledTask -TaskName "Update-ClaudeMD-MyApp" `
    -Action $action -Trigger $trigger
```

### 使用简单循环

```powershell
# 每天运行一次
while ($true) {
    .\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"
    Start-Sleep -Seconds (24 * 60 * 60)
}
```

## 进阶用法

### 与 Git 集成

```powershell
# 生成后自动提交
.\regenerate-claude-md.ps1 -ProjectPath "D:\projects\my-app"

if ($LASTEXITCODE -eq 0) {
    cd "D:\projects\my-app"
    git add CLAUDE.md
    git commit -m "chore: update CLAUDE.md [bot]"
    git push
}
```

### 生成多个项目的汇总报告

```powershell
$projects = @("project-alpha", "project-beta", "project-gamma")
$summary = @()

foreach ($project in $projects) {
    $result = .\regenerate-claude-md.ps1 -ProjectPath "D:\projects\$project" -DryRun
    $summary += "- $project: $result"
}

$summary | Out-File "summary-report.txt"
```

## 最佳实践建议

1. **定期运行** - 建议每周或每次重大变更后运行
2. **先预览** - 使用 `-DryRun` 查看变更再决定是否应用
3. **保留备份** - 脚本会自动备份,但建议也提交到 Git
4. **审查报告** - 仔细阅读 `changes-report.md` 确保变更合理
5. **测试验证** - 应用后运行 `claude` 命令测试是否正常工作
6. **渐进式改进** - 根据使用反馈逐步优化 CLAUDE.md 内容

## 故障排查

### 问题: Claude CLI 未找到

```
错误: 'claude' 不是内部或外部命令
```

**解决方案**:
```powershell
# 安装 Claude Code CLI
npm install -g @anthropic-ai/claude-code

# 验证安装
claude --version
```

### 问题: 权限不足

```
错误: 无法写入文件
```

**解决方案**:
```powershell
# 以管理员身份运行 PowerShell
# 或检查文件权限
```

### 问题: Git diff 不可用

```
警告: git diff 不可用,使用简单对比
```

**解决方案**:
```powershell
# 安装 Git for Windows
# https://git-scm.com/download/win

# 或忽略此警告,脚本会使用备用方案
```

## 参考资源

- [Claude Code 官方文档](https://docs.anthropic.com/claude/docs/claude-code)
- [CLAUDE.md 最佳实践 (2026)](https://paul-schick.com/posts/how-to-write-claude-md/)
- [7 Sacred Tips to Best Use Claude Code](https://www.sentisight.ai/7-sacred-tips-to-best-use-claude-code/)

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request!
