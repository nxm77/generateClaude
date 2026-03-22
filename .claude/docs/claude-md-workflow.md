# CLAUDE.md 生成与更新命令说明

> **版本:** v1.0
> **日期:** 2026-03-22

---

## 命令概述

| 命令 | 用途 | 执行时机 |
|------|------|---------|
| `/init` | 初始化 CLAUDE.md | 新项目/模块首次使用 |
| `/update-claude` | 更新 CLAUDE.md | 代码变更后 |

---

## /init 命令

### 功能

扫描项目结构，生成初始 CLAUDE.md 文件。

### 执行流程

```
1. 扫描项目根目录，识别技术栈
   ├── 检测文件类型 (.cpp, .vb, .java, .vue, etc.)
   ├── 检测构建文件 (pom.xml, package.json, .sln, etc.)
   └── 检测数据库配置

2. 分析目录结构
   ├── 识别源码目录
   ├── 识别配置目录
   └── 识别测试目录

3. 扫描关键文件（抽样）
   ├── 读取主要头文件/接口定义
   ├── 提取类/函数签名
   └── 识别数据库操作

4. 生成 CLAUDE.md
   ├── 使用模板框架
   ├── 填充自动识别内容
   └── 标记待补充章节（[TODO]）
```

### 输出示例

```bash
$ /init

扫描项目: D:\cx\mes\modules\equipment-communication
识别技术栈: C++11, Boost.Asio, Oracle
扫描关键文件: 15 个文件
生成 CLAUDE.md: 完成

[TODO] 请手动补充以下章节:
- 项目概述
- 主要业务流程
- 业务术语
- 编码规范（团队约定）
- 安全问题
```

### 生成的 CLAUDE.md 结构

```markdown
# [项目名称] - 自动生成

## 项目概述
[TODO] 请补充项目概述

## 技术栈
### 编程语言和框架
- C++11
- Boost.Asio 1.74

### 数据库
- Oracle 12c
- 主要表: [自动识别的表]

## 代码架构
### 关键文件类型说明
[自动生成]

### 关键函数
[自动扫描生成]

### 核心方法
[自动扫描生成]

### 数据操作
[TODO] 请补充数据操作说明

### 数据规则
[TODO] 请补充数据规则

## 主要业务流程
[TODO] 请补充业务流程

## 环境变量
[自动扫描配置文件生成]

## 编码规范
[TODO] 请补充编码规范

## 业务术语
[TODO] 请补充业务术语

## 安全问题
[TODO] 请补充安全问题
```

---

## /update-claude 命令

### 功能

基于代码变更，更新 CLAUDE.md 内容。

### 执行流程

```
1. 检测变更（git diff 或文件时间戳）
   ├── 新增文件
   ├── 修改文件
   └── 删除文件

2. 分析变更影响
   ├── 是否影响关键函数
   ├── 是否影响数据操作
   ├── 是否影响业务流程
   └── 是否影响接口定义

3. 更新 CLAUDE.md
   ├── 更新关键函数列表
   ├── 更新核心方法签名
   ├── 更新数据操作说明
   └── 保留手动标记的章节

4. 输出更新摘要
```

### 使用场景

| 场景 | 命令 |
|------|------|
| 新增类/函数 | `/update-claude` |
| 修改函数签名 | `/update-claude` |
| 重构代码结构 | `/update-claude` |
| 添加数据库表 | `/update-claude` |
| 修改配置项 | `/update-claude` |

### 执行示例

```bash
$ /update-claude

检测变更: 3 个文件修改, 1 个文件新增
- DeviceCommunicator.cpp (修改)
- EventHandler.h (修改)
- DatabaseUtil.cpp (新增)

更新 CLAUDE.md:
- 更新关键函数: establishCommunication (签名变更)
- 新增核心方法: queryDeviceStatus
- 更新数据操作: 新增设备状态查询

更新完成: CLAUDE.md 已更新
```

### 更新策略

| 章节 | 更新方式 | 说明 |
|------|---------|------|
| 项目概述 | 保留 | 不自动覆盖 |
| 技术栈 | 合并 | 新增技术栈会追加 |
| 关键文件类型 | 自动 | 基于文件扫描 |
| 关键函数 | 自动 | 增量更新 |
| 核心方法 | 自动 | 增量更新 |
| 数据操作 | 自动 | 增量更新 |
| 主要业务流程 | 保留 | 不自动覆盖 |
| 环境变量 | 合并 | 新增变量会追加 |
| 编码规范 | 保留 | 不自动覆盖 |
| 业务术语 | 保留 | 不自动覆盖 |
| 安全问题 | 保留 | 不自动覆盖 |

---

## 手动标记

### 保护手动内容

在 CLAUDE.md 中使用 `[MANUAL]` 标记保护手动编写的内容：

```markdown
## 业务术语 [MANUAL]
| 术语 | 英文 | 说明 |
|------|------|------|
| Lot | 批次 | 晶圆生产批次 |
```

带有 `[MANUAL]` 标记的章节，`/update-claude` 不会自动覆盖。

---

## Git 集成建议

### Pre-commit Hook

```bash
#!/bin/bash
# .claude/hooks/pre-commit/check-claude-md.sh

# 检测是否修改了关键文件
CHANGED_FILES=$(git diff --cached --name-only | grep -E "\.(cpp|vb|java|vue)$")

if [ -n "$CHANGED_FILES" ]; then
    echo "检测到代码变更，建议运行 /update-claude 更新文档"
    echo "变更文件:"
    echo "$CHANGED_FILES"
fi
```

### 建议工作流

```
代码修改 → git add → [提示运行 /update-claude] → /update-claude → git commit
```

---

## 命令实现位置

```
.claude/
├── commands/
│   ├── init.sh              # /init 命令脚本
│   └── update-claude.sh     # /update-claude 命令脚本
└── templates/
    └── project-claude-md.md  # CLAUDE.md 模板
```

---

**文档版本:** v1.0
**最后更新:** 2026-03-22
