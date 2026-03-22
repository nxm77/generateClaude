# /create-skill 命令设计

> **版本:** v1.0
> **日期:** 2026-03-22
> **用途:** 深入解析项目代码，生成项目知识库 Skill

---

## 1. 命令概述

**功能:** 扫描项目代码，自动生成项目级 Skill 文件

```
/create-skill [选项]

选项:
  --scope <范围>    扫描范围: all | core | module
  --depth <深度>    分析深度: quick | standard | deep
  --output <路径>   输出路径
  --force           强制覆盖已存在文件
```

---

## 2. 工作流程

```
┌─────────────────────────────────────────────────────────────┐
│  /create-skill 执行流程                                     │
└─────────────────────────────────────────────────────────────┘

  1. 项目类型识别
     ├── 扫描文件类型 (.cpp, .vb, .java, .vue, etc.)
     ├── 检测构建文件 (pom.xml, .sln, package.json)
     └── 确定项目类型 (MES/EAP/Web/etc.)

  2. 代码结构分析
     ├── 目录结构解析
     ├── 模块划分识别
     └── 依赖关系分析

  3. 代码模式提取
     ├── 类/接口定义
     ├── 函数签名提取
     ├── 设计模式识别
     └── 编码规范推断

  4. 数据操作分析
     ├── 数据库表识别
     ├── 数据访问模式
     └── 数据流转路径

  5. API/函数索引
     ├── 公共接口列表
     ├── 关键函数签名
     └── 调用关系分析

  6. 业务逻辑提取
     ├── 关键业务流程
     ├── 状态机识别
     └── 事件处理模式

  7. 生成 Skill 文件
     ├── SKILL.md (主文件)
     ├── patterns.md (代码模式)
     ├── api-reference.md (API 参考)
     └── data-model.md (数据模型)
```

---

## 3. 分析深度

| 深度 | 扫描文件 | 分析内容 | 耗时 |
|------|---------|---------|------|
| **quick** | 抽样 50 文件 | 目录结构、主要类、文件类型 | ~5 分钟 |
| **standard** | 抽样 200 文件 | + 函数签名、设计模式、数据访问 | ~15 分钟 |
| **deep** | 全部文件 | + 调用关系、状态机、完整业务逻辑 | ~60 分钟 |

---

## 4. 扫描范围

| 范围 | 说明 | 适用场景 |
|------|------|---------|
| **all** | 扫描整个项目 | 首次创建 |
| **core** | 仅核心目录 | 核心模块分析 |
| **module** | 指定模块 | 单独模块 Skill |

---

## 5. 生成文件结构

```
.claude/skills/<project-name>/
├── SKILL.md                 # Skill 主文件
├── overview.md              # 项目概述
├── structure.md             # 代码结构
├── patterns.md              # 代码模式
├── api-reference.md         # API 参考
├── data-model.md            # 数据模型
├── business-flows.md        # 业务流程
└── conventions.md           # 编码规范
```

---

## 6. SKILL.md 模板

```markdown
# <项目名称> Skill

> 自动生成时间: 2026-03-22
> 项目类型: MES / EAP / Web
> 技术栈: C++ / VB.NET / JAVA+VUE

---

## 项目概述

[自动生成的项目概述]

---

## 快速导航

### 关键目录
- `src/core/` - 核心业务逻辑
- `src/communication/` - 设备通信
- `src/database/` - 数据访问

### 关键类
- `Executor` - 执行器
- `DeviceCommunicator` - 设备通信
- `MESDataAccess` - 数据访问

### 常用操作
- 建立设备通信: `DeviceCommunicator::establishConnection()`
- 发送控制命令: `DeviceCommunicator::sendCommand()`
- 查询设备状态: `DeviceCommunicator::getDeviceState()`

---

## 代码规范

### 命名约定
- 类名: PascalCase
- 函数名: camelCase
- 常量: UPPER_SNAKE_CASE

### 文件组织
- 头文件: `.h`
- 实现文件: `.cpp`
- 单文件不超过: 1000 行

---

## 设计模式

[自动识别的设计模式]

---

## 数据模型

[自动提取的数据模型]

---

## 业务流程

[自动提取的业务流程]

---

## API 参考

详细 API: [api-reference.md](api-reference.md)

---

## 相关文档

- [代码结构](structure.md)
- [代码模式](patterns.md)
- [数据模型](data-model.md)
- [业务流程](business-flows.md)
- [编码规范](conventions.md)
```

---

## 7. 使用示例

### 7.1 基础使用

```bash
$ /create-skill

检测项目类型...
扫描代码结构...
提取代码模式...
生成 Skill 文件...

✅ 已生成: .claude/skills/mes-communication/
   - SKILL.md
   - overview.md
   - structure.md
   - patterns.md
   - api-reference.md

📊 统计:
   - 扫描文件: 156 个
   - 识别类: 42 个
   - 提取函数: 234 个
   - 识别模式: 8 种
```

### 7.2 指定模块

```bash
$ /create-skill --scope module --path src/communication

✅ 已生成: .claude/skills/mes-communication/
   仅包含通信模块的知识
```

### 7.3 深度分析

```bash
$ /create-skill --depth deep

⏳ 深度分析模式，预计需要 60 分钟...
扫描全部文件...
分析调用关系...
提取状态机...
```

---

## 8. 更新策略

### 增量更新

```bash
# 首次创建
/create-skill --depth standard

# 后续增量更新
/create-skill --update
```

### 自动更新触发

| 触发条件 | 行为 |
|---------|------|
| 代码变更 > 10% | 提示更新 Skill |
| 新增模块 | 建议创建子 Skill |
| API 变更 | 更新 API 参考 |

---

## 9. 与其它命令配合

```
/create-skill → 生成 Skill 文件
     ↓
/init → 使用 Skill 生成 CLAUDE.md
     ↓
/update-claude → 代码变更后更新文档
     ↓
/learn → 记录新经验
```

---

## 10. 输出示例

### MES 通信模块 Skill

```markdown
# MES Communication Skill

## 项目概述
MES 设备通信模块，基于 SECS/GEM 协议实现与设备的双向通信。

## 关键类

| 类 | 文件 | 职责 |
|---|------|------|
| DeviceCommunicator | DeviceCommunicator.cpp/h | 设备通信管理 |
| SECSClient | SECSClient.cpp/h | SECS/GEM 协议实现 |
| EventHandler | EventHandler.cpp/h | 事件报告处理 |
| AlarmHandler | AlarmHandler.cpp/h | 报警处理 |

## 常用操作

### 建立通信
```cpp
auto comm = std::make_shared<DeviceCommunicator>("EQ001");
if (comm->establishConnection()) {
    // 通信成功
}
```

### 发送命令
```cpp
comm->sendCommand(S2F41, commandData);
```

### 等待响应
```cpp
auto response = comm->waitForSecondary(10000); // 10秒超时
```

## 状态机
DISABLED → NOT_CONNECTED → CONNECTING → ONLINE

## 超时设置
- T1 (通信建立): 5秒
- T2 (在线请求): 3秒
- T3 (控制命令): 10秒
```

---

## 11. 实现要点

### 11.1 文件类型识别

```python
FILE_TYPE_PATTERNS = {
    'cpp': ['.cpp', '.h', '.hpp'],
    'vbnet': ['.vb'],
    'java': ['.java'],
    'vue': ['.vue'],
    'python': ['.py'],
    'nodejs': ['.js', '.ts']
}
```

### 11.2 类/函数提取

```python
# C++ 类提取
class_pattern = r'class\s+(\w+)\s*(?::\s*[^{]+)?\{'

# 函数签名提取
func_pattern = r'(\w+)\s+(\w+)\s*\([^)]*\)\s*(?:const)?'
```

### 11.3 设计模式识别

```python
DESIGN_PATTERNS = {
    'singleton': ['getInstance', 'static.*instance'],
    'factory': ['create', 'make', 'factory'],
    'observer': ['notify', 'attach', 'detach'],
    'strategy': ['strategy', '.*strategy$'],
    'state': ['state', 'transition', 'handle']
}
```

---

## 12. 注意事项

1. **大型项目处理**
   - MES 数百万行代码需要分批处理
   - 建议使用 `--scope core` 先处理核心模块

2. **敏感信息过滤**
   - 自动过滤密码、密钥等敏感信息
   - API Token 仅记录名称，不记录值

3. **人工审核**
   - 生成后需要人工审核和补充
   - 业务逻辑部分需要人工确认

---

**命令版本:** v1.0
**最后更新:** 2026-03-22
