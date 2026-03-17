# generate-docs-smart-v2.ps1 使用指南

## 🎯 改进内容总结

### ✅ 已实现的改进

1. **file-functions.md 增强**
   - ✅ 扫描实际源代码文件
   - ✅ 显示文件路径、类型、行数
   - ✅ 提取类名和函数名 (深度模式)
   - ✅ 包含文件功能描述 (深度模式)
   - ✅ 显示依赖关系 (深度模式)
   - ✅ 整合 API 端点列表 (深度模式)
   - ✅ 整合数据模型列表 (深度模式)

2. **深度分析改进**
   - ✅ 直接读取 `.claude/skills/project-deep-analyzer.md` 文件
   - ✅ 不依赖 skill 机制
   - ✅ 完全控制 prompt 内容
   - ✅ 保存 prompt 到临时文件便于调试
   - ✅ 优雅降级到基础模式
   - ✅ 返回结构化数据供后续使用

3. **深度分析结果利用**
   - ✅ 将分析结果存储在全局变量
   - ✅ 传递给文档生成函数
   - ✅ 生成准确的文件列表
   - ✅ 包含实际的 API 端点
   - ✅ 包含实际的数据模型

---

## 🚀 快速开始

### 基础模式 (快速扫描)

```powershell
# 在当前目录生成文档
.\generate-docs-smart-v2.ps1

# 在指定目录生成文档
.\generate-docs-smart-v2.ps1 -Path "D:\projects\my-app"
```

**输出**:
- `file-functions.md` - 基于文件扫描的列表 (文件路径、大小、行数)
- 生成速度: 快 (10-30 秒)

### 深度模式 (详细分析)

```powershell
# 在当前目录深度分析
.\generate-docs-smart-v2.ps1 -Deep

# 在指定目录深度分析
.\generate-docs-smart-v2.ps1 -Deep -Path "D:\projects\my-app"
```

**输出**:
- `file-functions.md` - 详细的文件功能说明 (包含类、函数、API、模型)
- `.analysis-report.json` - 完整的分析报告
- 生成速度: 慢 (2-5 分钟,取决于项目大小)

---

## 📊 输出对比

### 基础模式输出示例

```markdown
# generateClaude - 文件功能列表

> 本文档基于基础文件扫描生成
> 提示: 使用 -Deep 参数可获得更详细的分析

## 2. 源代码文件列表

### 2.1 `regenerate-claude-md.ps1`
- **类型**: .ps1 文件
- **大小**: 21.5 KB
- **行数**: 850
- **最后修改**: 2026-03-17 10:30

### 2.2 `batch-regenerate-claude-md.ps1`
- **类型**: .ps1 文件
- **大小**: 11.2 KB
- **行数**: 450
- **最后修改**: 2026-03-17 09:15
```

### 深度模式输出示例

```markdown
# generateClaude - 文件功能列表

> 本文档基于深度代码分析自动生成

## 2. 核心文件详细说明

### 2.1 PowerShell 脚本文件

#### `regenerate-claude-md.ps1`
- **类型**: PowerShell Script
- **行数**: 850
- **主要函数**: Detect-TechStack, Get-ProjectDescription, Get-KeyCommands, Get-KeyDirectories, Generate-ClaudeMd
- **功能**: 单项目 CLAUDE.md 自动生成器,支持多种技术栈检测
- **依赖**: lib/project-analysis-common.ps1

#### `batch-regenerate-claude-md.ps1`
- **类型**: PowerShell Script
- **行数**: 450
- **主要函数**: Process-Repository, Generate-BatchReport, Commit-Changes
- **功能**: 批量处理多个项目的 CLAUDE.md 生成
- **依赖**: regenerate-claude-md.ps1, repos-config.json

## 3. API 端点列表

### POST /api/generate
- **文件**: `regenerate-claude-md.ps1:245`
- **功能**: 触发 CLAUDE.md 生成任务
- **参数**: projectPath, dryRun, outputDir
- **返回**: GenerationResult (JSON)
- **认证**: None

## 4. 数据模型列表

### ProjectAnalysis
- **文件**: `lib/project-analysis-common.ps1:50`
- **类型**: Data Transfer Object
- **字段**:
  - `TechStack`: string[] - 检测到的技术栈列表
  - `ProjectDescription`: string - 项目描述
  - `KeyCommands`: string[] - 关键命令列表
  - `KeyDirectories`: string[] - 关键目录列表
- **用途**: 存储项目分析结果,用于生成 CLAUDE.md
```

---

## 🔍 工作流程

### 基础模式流程

```
1. 项目分析 (10秒)
   ├─ 检测编程语言
   ├─ 检测技术栈
   ├─ 分析项目类型
   └─ 扫描目录结构

2. 文件扫描 (10秒)
   ├─ 递归扫描源代码文件
   ├─ 过滤无关文件
   ├─ 统计文件大小和行数
   └─ 记录最后修改时间

3. 生成文档 (5秒)
   └─ 生成 file-functions.md

总耗时: ~25秒
```

### 深度模式流程

```
1. 项目分析 (10秒)
   [同基础模式]

2. 深度代码分析 (2-5分钟)
   ├─ 读取 skill 模板文件
   ├─ 构建完整 prompt
   ├─ 调用 claude CLI
   ├─ 等待分析完成
   ├─ 生成 .analysis-report.json
   └─ 解析分析结果

3. 增强文档生成 (10秒)
   ├─ 使用分析数据
   ├─ 生成详细文件列表
   ├─ 包含 API 端点
   ├─ 包含数据模型
   └─ 生成 file-functions.md

总耗时: ~3-6分钟
```

---

## 🛠️ 故障排查

### 问题 1: 深度分析找不到 skill 文件

**错误信息**:
```
[WARNING] 未找到深度分析模板文件
查找路径:
  - .claude\skills\project-deep-analyzer.md
  - C:\Users\xxx\.claude\skills\project-deep-analyzer.md
[WARNING] 将使用基础分析模式
```

**解决方案**:
1. 检查 skill 文件是否存在:
   ```powershell
   Test-Path ".claude\skills\project-deep-analyzer.md"
   ```

2. 如果不存在,从项目根目录复制:
   ```powershell
   Copy-Item ".claude\skills\project-deep-analyzer.md" "$env:USERPROFILE\.claude\skills\" -Force
   ```

3. 或者在项目目录下运行脚本 (会优先查找本地 skill)

### 问题 2: 深度分析未生成报告文件

**错误信息**:
```
[WARNING] 未生成分析报告文件
[WARNING] 将使用基础分析模式
```

**可能原因**:
1. Claude CLI 执行失败
2. Prompt 格式问题
3. 项目太大,分析超时

**解决方案**:
1. 查看保存的 prompt 文件:
   ```powershell
   notepad $env:TEMP\deep-analysis-prompt-*.txt
   ```

2. 手动测试 Claude CLI:
   ```powershell
   claude -p "测试消息"
   ```

3. 检查项目大小,考虑排除大文件:
   ```powershell
   # 统计源代码文件数
   (Get-ChildItem -Recurse -File | Where-Object { $_.Extension -match '\.(js|py|java)$' }).Count
   ```

### 问题 3: 基础模式扫描文件太多

**现象**:
- 扫描时间过长
- 生成的文档太大

**解决方案**:
脚本已限制扫描前 50 个文件,如需调整:

```powershell
# 在脚本中找到这一行:
Select-Object -First 50

# 修改为:
Select-Object -First 100  # 或其他数量
```

---

## 📝 与原版本对比

| 特性 | 原版本 (v1.0) | 改进版 (v2.0) |
|------|--------------|--------------|
| **file-functions.md** | 通用模板 | 实际文件列表 ✅ |
| **深度分析调用** | 依赖 skill 机制 | 直接读取 .md 文件 ✅ |
| **深度分析稳定性** | 经常失败 | 稳定可用 ✅ |
| **分析结果利用** | 仅显示统计 | 充分整合到文档 ✅ |
| **API 端点列表** | 无 | 有 (深度模式) ✅ |
| **数据模型列表** | 无 | 有 (深度模式) ✅ |
| **优雅降级** | 无 | 有 ✅ |
| **调试支持** | 无 | 保存 prompt 文件 ✅ |

---

## 🎯 下一步计划

### 已完成 ✅
- [x] 增强 file-functions.md 生成
- [x] 改进深度分析调用机制
- [x] 利用深度分析结果

### 待实现 (可选)
- [ ] 增强 system-overview.puml (使用分析数据)
- [ ] 增强 sequence-diagram.puml (使用 API 数据)
- [ ] 增强 module-flowchart.puml (使用流程数据)
- [ ] 添加缓存机制 (避免重复分析)
- [ ] 支持增量更新 (只分析变更文件)

---

## 🧪 测试建议

### 测试 1: 基础模式测试

```powershell
# 在当前项目测试
.\generate-docs-smart-v2.ps1

# 检查输出
notepad file-functions.md

# 预期: 看到实际的文件列表,包含文件路径、大小、行数
```

### 测试 2: 深度模式测试

```powershell
# 深度分析
.\generate-docs-smart-v2.ps1 -Deep

# 等待 2-5 分钟...

# 检查输出
notepad file-functions.md
notepad .analysis-report.json

# 预期:
# - file-functions.md 包含详细的类、函数、API、模型信息
# - .analysis-report.json 包含完整的分析数据
```

### 测试 3: 降级测试

```powershell
# 临时重命名 skill 文件
Rename-Item ".claude\skills\project-deep-analyzer.md" "project-deep-analyzer.md.bak"

# 运行深度模式
.\generate-docs-smart-v2.ps1 -Deep

# 预期: 显示警告,自动降级到基础模式

# 恢复 skill 文件
Rename-Item ".claude\skills\project-deep-analyzer.md.bak" "project-deep-analyzer.md"
```

---

## 💡 使用技巧

### 技巧 1: 快速预览

```powershell
# 先用基础模式快速预览
.\generate-docs-smart-v2.ps1

# 如果需要更详细的信息,再用深度模式
.\generate-docs-smart-v2.ps1 -Deep
```

### 技巧 2: 调试深度分析

```powershell
# 运行深度模式
.\generate-docs-smart-v2.ps1 -Deep

# 查看生成的 prompt
notepad $env:TEMP\deep-analysis-prompt-*.txt

# 手动测试 prompt
$prompt = Get-Content $env:TEMP\deep-analysis-prompt-*.txt -Raw
claude -p $prompt
```

### 技巧 3: 对比新旧版本

```powershell
# 用旧版本生成
.\generate-docs-smart.ps1
Rename-Item file-functions.md file-functions-v1.md

# 用新版本生成
.\generate-docs-smart-v2.ps1
Rename-Item file-functions.md file-functions-v2.md

# 对比
code --diff file-functions-v1.md file-functions-v2.md
```

---

## 📞 获取帮助

如果遇到问题:

1. 查看脚本输出的错误信息
2. 检查 `$env:TEMP\deep-analysis-prompt-*.txt` 文件
3. 测试 `claude --version` 是否可用
4. 确认 skill 文件路径是否正确

---

**版本**: v2.0
**更新日期**: 2026-03-17
**改进内容**: 解决了 file-functions.md 罗列问题、深度分析不可用问题、分析结果未使用问题
