# generate-docs-smart.ps1 改进方案

## 📋 当前问题总结

### 问题 1: file-functions.md 仅是罗列,没有文件说明
**现状**:
- 只显示目录结构树
- 只有通用的文件类型说明
- 没有针对每个具体文件的功能描述

**期望**:
- 扫描实际的源代码文件
- 为每个文件生成具体的功能说明
- 包含文件的职责、依赖关系等

### 问题 2: 深度分析经常不可用
**现状**:
- 依赖 `claude -p` 命令调用 skill
- skill 文件路径查找不稳定
- 需要 Claude Code 环境才能运行

**期望**:
- 直接读取 `.claude/skills/project-deep-analyzer.md` 文件
- 使用文件内容作为 prompt 模板
- 无需依赖 skill 机制

### 问题 3: 深度分析结果未被使用
**现状**:
- 生成 `.analysis-report.json` 文件
- 只显示统计信息
- 后续文档生成不使用这些数据

**期望**:
- 将深度分析结果整合到文档中
- 使用分析出的 API、模型、流程信息
- 生成更准确的 PlantUML 图表

---

## 🎯 改进方案

### 方案 1: 增强 file-functions.md 生成

#### 实现思路
```powershell
function New-FileFunctionsDocument-Enhanced {
    # 1. 扫描源代码文件
    $sourceFiles = Get-ChildItem -Path $script:PROJECT_DIR -Recurse -File |
        Where-Object {
            $_.Extension -match '\.(js|ts|jsx|tsx|py|java|go|rs|php|rb)$' -and
            $_.FullName -notmatch '(node_modules|__pycache__|\.git|dist|build)'
        } |
        Select-Object -First 100

    # 2. 对每个文件进行简单分析
    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Replace($script:PROJECT_DIR, "").TrimStart('\')
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue

        # 提取函数/类名
        $functions = Extract-Functions $content $file.Extension
        $classes = Extract-Classes $content $file.Extension

        # 生成文件说明
        $fileDoc = @"
#### `$relativePath`
- **类型**: $(Get-FileType $file.Extension)
- **包含类**: $($classes -join ', ')
- **包含函数**: $($functions -join ', ')
- **行数**: $(($content -split "`n").Count)
"@
    }
}

function Extract-Functions {
    param($content, $extension)

    switch ($extension) {
        {$_ -in '.js','.ts','.jsx','.tsx'} {
            # 匹配: function name() 或 const name = () =>
            $pattern = '(?:function\s+(\w+)|(?:const|let|var)\s+(\w+)\s*=\s*(?:async\s*)?\()'
        }
        '.py' {
            # 匹配: def name(
            $pattern = 'def\s+(\w+)\s*\('
        }
        '.java' {
            # 匹配: public/private/protected type name(
            $pattern = '(?:public|private|protected)\s+\w+\s+(\w+)\s*\('
        }
    }

    $matches = [regex]::Matches($content, $pattern)
    return $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -First 10
}
```

### 方案 2: 简化深度分析调用

#### 当前实现 (有问题)
```powershell
# 依赖 skill 机制
$output = claude -p $prompt 2>&1
```

#### 改进实现
```powershell
function Invoke-DeepAnalysis-Improved {
    # 1. 直接读取 skill 文件作为 prompt 模板
    $skillPath = ".claude\skills\project-deep-analyzer.md"

    if (-not (Test-Path $skillPath)) {
        Write-ColorOutput "未找到深度分析模板,跳过深度分析" "Warning"
        return
    }

    # 2. 读取 skill 内容
    $skillContent = Get-Content $skillPath -Raw

    # 3. 构建完整的 prompt
    $prompt = @"
$skillContent

---

请分析以下项目:
- 项目路径: $script:PROJECT_DIR
- 项目名称: $script:PROJECT_NAME
- 项目类型: $script:PROJECT_TYPE
- 编程语言: $script:LANGUAGES
- 框架: $script:FRAMEWORKS

请生成详细的分析报告,包括:
1. API 端点列表
2. 数据模型列表
3. 业务流程描述
4. 文件功能说明

将结果保存到 .analysis-report.json 文件中。
"@

    # 4. 调用 claude (不依赖 skill 机制)
    try {
        $output = claude -p $prompt 2>&1
        Write-ColorOutput "深度分析完成" "Success"
    } catch {
        Write-ColorOutput "深度分析失败: $_" "Error"
    }
}
```

### 方案 3: 利用深度分析结果

#### 实现思路
```powershell
function New-DetailedDocuments-Enhanced {
    # 1. 尝试读取深度分析报告
    $reportPath = Join-Path $script:PROJECT_DIR ".analysis-report.json"
    $analysisData = $null

    if (Test-Path $reportPath) {
        try {
            $analysisData = Get-Content $reportPath -Raw | ConvertFrom-Json
            Write-ColorOutput "已加载深度分析报告" "Success"
        } catch {
            Write-ColorOutput "无法解析深度分析报告" "Warning"
        }
    }

    # 2. 使用分析数据增强文档生成
    if ($analysisData) {
        New-FileFunctionsDocument-WithAnalysis $analysisData
        New-SystemOverviewDiagram-WithAnalysis $analysisData
        New-SequenceDiagram-WithAnalysis $analysisData
    } else {
        # 使用基础模式
        New-FileFunctionsDocument
        New-SystemOverviewDiagram
        New-SequenceDiagram
    }
}

function New-FileFunctionsDocument-WithAnalysis {
    param($analysisData)

    $content = @"
# $script:PROJECT_NAME - 文件功能列表

## 1. API 端点列表

"@

    # 使用深度分析的 API 数据
    foreach ($api in $analysisData.apis) {
        $content += @"

### $($api.method) $($api.path)
- **功能**: $($api.description)
- **文件**: $($api.file)
- **参数**: $($api.parameters -join ', ')
- **返回**: $($api.response)

"@
    }

    # 使用深度分析的模型数据
    $content += @"

## 2. 数据模型列表

"@

    foreach ($model in $analysisData.models) {
        $content += @"

### $($model.name)
- **文件**: $($model.file)
- **字段**: $($model.fields -join ', ')
- **用途**: $($model.purpose)

"@
    }

    Set-Content -Path (Join-Path $script:PROJECT_DIR "file-functions.md") -Value $content -Encoding UTF8
}
```

---

## 🚀 完整改进版脚本结构

```
generate-docs-smart-v2.ps1
├─ 阶段 0: 智能分析项目 (保持不变)
│  ├─ Get-Languages
│  ├─ Get-TechStack
│  ├─ Get-ProjectType
│  └─ Get-DirectoryStructure
│
├─ 阶段 0.5: 深度代码分析 (改进)
│  ├─ 直接读取 skill 文件作为 prompt
│  ├─ 不依赖 skill 机制
│  └─ 生成 .analysis-report.json
│
├─ 阶段 1: 生成框架版 CLAUDE.md (保持不变)
│
├─ 阶段 2: 生成具体文档 (改进)
│  ├─ New-RequirementsDocument (保持不变)
│  ├─ New-FileFunctionsDocument-Enhanced (新增)
│  │  ├─ 扫描实际源代码文件
│  │  ├─ 提取函数/类名
│  │  └─ 使用深度分析数据 (如果有)
│  │
│  ├─ New-SystemOverviewDiagram-Enhanced (改进)
│  │  └─ 使用深度分析的模块信息
│  │
│  ├─ New-ModuleFlowchart-Enhanced (改进)
│  │  └─ 使用深度分析的流程信息
│  │
│  └─ New-SequenceDiagram-Enhanced (改进)
│     └─ 使用深度分析的 API 信息
│
└─ 阶段 3: 更新最终版 CLAUDE.md (保持不变)
```

---

## 📝 实现优先级

### 高优先级 (立即实现)
1. **简化深度分析调用** - 解决不可用问题
   - 直接读取 skill 文件
   - 不依赖 skill 机制
   - 预计时间: 30 分钟

2. **增强 file-functions.md** - 解决罗列问题
   - 扫描源代码文件
   - 提取函数/类名
   - 生成具体说明
   - 预计时间: 1 小时

### 中优先级 (后续实现)
3. **利用深度分析结果** - 解决未使用问题
   - 读取 .analysis-report.json
   - 整合到文档生成
   - 增强 PlantUML 图表
   - 预计时间: 1.5 小时

---

## 🎯 预期效果

### 改进前
```
file-functions.md:
├─ 目录结构树
├─ 通用文件类型说明
└─ 命名规范

深度分析:
├─ 经常失败
└─ 结果未使用
```

### 改进后
```
file-functions.md:
├─ 目录结构树
├─ 每个文件的具体说明
│  ├─ 文件路径
│  ├─ 包含的类
│  ├─ 包含的函数
│  └─ 行数统计
├─ API 端点列表 (来自深度分析)
└─ 数据模型列表 (来自深度分析)

深度分析:
├─ 稳定可用 (直接读取 .md 文件)
└─ 结果被充分利用
```

---

## 🔧 下一步行动

你希望我:
1. **立即实现改进版脚本** - 创建 `generate-docs-smart-v2.ps1`
2. **先实现高优先级改进** - 修改现有脚本
3. **提供更详细的实现代码** - 展开某个具体函数
4. **其他建议** - 你有其他想法?

请告诉我你的选择,我会立即开始实现。
