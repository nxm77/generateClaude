# CX Claude Code 使用手册

> **版本:** v1.1
> **更新:** 2025-03-23

---

## 目录

1. [快速入门](#快速入门)
2. [核心功能](#核心功能)
3. [命令参考](#命令参考)
4. [技术栈技能](#技术栈技能)
5. [工作流程](#工作流程)
6. [常见问题](#常见问题)

---

## 快速入门

### 第一次使用

1. **确认环境**
   ```bash
   # 检查 Claude Code 是否安装
   claude --version

   # 检查配置文件
   cat .claude/settings.json
   ```

2. **启动会话**
   ```bash
   # 在项目根目录启动
   cd D:\cx
   claude
   ```

3. **查看上下文**（自动恢复）
   - 会话开始时自动显示：
     - 当前任务阶段
     - 上次进度
     - 代码变更

### 日常使用

```
开始编码 → AI 自动指导 → 提交代码 → 自动检查 → 推送 → 自动测试
```

---

## 核心功能

### 1. 上下文恢复

**自动触发:** 会话开始时

**显示内容:**
```
=== CX Claude Code - 上下文恢复 ===

📋 任务计划: task_plan.md
当前阶段:
✅ Phase 1: 基础配置
✅ Phase 2: Skills 和 Commands
✅ Phase 3: Hooks 和文档模板

📈 进度记录: progress.md
上次活动:
[显示最近的工作内容]

📝 代码变更:
[显示 git diff 统计]
```

### 2. 代码检查

**自动触发:** `git commit` 时

**检查项目:**
- JSON 文件语法
- 大文件警告 (>1MB)
- 代码行长度 (>120 字符)

```bash
# 提交代码
git add .
git commit -m "feat: xxx"

# 自动运行检查
=== Pre-commit 检查 ===
检查 JSON 文件语法...
✅ settings.json
✅ package.json
✅ Pre-commit 检查通过
```

### 3. 测试运行

**自动触发:** `git push` 时

**支持的测试框架:**
- Maven (pom.xml)
- npm (package.json)
- Gradle (build.gradle)
- Makefile

```bash
git push

# 自动运行测试
=== Pre-push 检查 ===
检测到 Maven 项目，运行测试...
[INFO] BUILD SUCCESS
✅ Pre-push 检查通过
```

### 4. 技能自动触发

根据文件类型自动提供技术栈指导：

| 文件扩展名 | 触发技能 |
|-----------|---------|
| .cpp, .h | MES / C++ |
| .vb | EAP / VB.NET |
| .java | JAVA |
| .vue | VUE |

---

## 命令参考

### /init - 初始化项目文档

```bash
/init
```

**功能:** 生成项目级 CLAUDE.md

**输出:** `CLAUDE.md` 文件

---

### /update-claude - 更新项目文档

```bash
/update-claude
```

**功能:** 增量更新 CLAUDE.md 中的自动生成部分

**更新内容:**
- 函数列表
- API 端点
- 类/组件索引

---

### /create-skill - 生成项目技能

```bash
/create-skill --scope all --depth standard
```

**参数:**
- `--scope`: all | core | module
- `--depth`: quick | standard | deep

**输出:** `.claude/skills/<project-name>/` 目录

---

### /learn - 记录编码经验

```bash
/learn --type error "C++ 智能指针循环引用导致内存泄漏"
```

**类型:**
- `error` - 编码错误
- `pattern` - 代码模式
- `performance` - 性能优化
- `anti-pattern` - 反模式
- `convention` - 编码规范
- `debug` - 调试经验

**输出:** 追加到 `.claude/lessons.md`

---

### /review - 代码审查

```bash
/review
```

**检查内容:**
- 代码规范
- 安全问题
- 性能问题
- 测试覆盖率

---

### /diagram - 生成图表

```bash
# 交互式
/diagram

# 直接生成
/diagram flow "设备登录流程"
/diagram sequence "S1F13 握手时序"
/diagram state "EAP 设备状态机"
/diagram system-overview "系统全景图"
```

**支持的图表类型:**
- `flow` - 流程图
- `sequence` - 时序图
- `component` - 组件图
- `state` - 状态图
- `class` - 类图
- `system-overview` - 系统全景图  ← 新增

**输出:** `docs/diagrams/*.puml`

---

## 技术栈技能

### MES (SiView)

**位置:** `.claude/skills/mes/`

**包含文档:**
- SKILL.md - 技能概述
- coding-standards.md - C++ 编码规范
- patterns.md - 代码模式
- debugging.md - 调试指南

**何时触发:** 编辑 `.cpp` 或 `.h` 文件时

**核心指导:**
- 智能指针使用
- RAII 模式
- 线程安全
- 设备通信模式

---

### EAP (设备自动化)

**位置:** `.claude/skills/eap/`

**包含文档:**
- SKILL.md - 技能概述
- coding-standards.md - VB.NET 编码规范
- patterns.md - 代码模式
- debugging.md - 调试指南
- secs-gem-reference.md - SECS/GEM 协议参考

**何时触发:** 编辑 `.vb` 文件时

**核心指导:**
- SECS/GEM 通信
- 设备状态机
- 事件处理
- 命令执行

---

### 通用技术栈

| 技能 | 语言 | 本地参考文档 |
|------|------|--------------|
| CPP | C++ | [cpp-core-guidelines.md](../.claude/docs/references/cpp-core-guidelines.md) |
| VBNET | VB.NET | [dotnet-coding-standards.md](../.claude/docs/references/dotnet-coding-standards.md) |
| JAVA | Java 17 / Spring Boot | [spring-boot-reference.md](../.claude/docs/references/spring-boot-reference.md) |
| VUE | Vue 2/3 | [vue2-reference.md](../.claude/docs/references/vue2-reference.md) / [vue3-reference.md](../.claude/docs/references/vue3-reference.md) |
| CSHARP | C# | [csharp-reference.md](../.claude/docs/references/csharp-reference.md) |
| PYTHON | Python | [python-reference.md](../.claude/docs/references/python-reference.md) |

---

## 本地参考文档

### 概述

由于局域网环境无法访问外部文档，所有技术栈参考文档均已本地化，存储在 `.claude/docs/references/` 目录下。

### 可用参考

| 文档 | 技术栈 | 主要内容 |
|------|--------|---------|
| vue3-reference.md | Vue 3 | Composition API、响应式系统、生命周期 |
| vue2-reference.md | Vue 2 | Options API、Vuex、Vue Router、指令 |
| cpp-core-guidelines.md | C++ | 智能指针、RAII、内存管理、命名规范 |
| csharp-reference.md | C# | async/await、LINQ、依赖注入、记录类型 |
| python-reference.md | Python | PEP 8、类型注解、asyncio、单元测试 |
| spring-boot-reference.md | Java | Spring Boot、RESTful API、JPA |
| dotnet-coding-standards.md | VB.NET | Option Strict、事件处理、Region 组织 |

### 使用方式

在编码时，Claude Code 会自动参考这些本地文档提供指导：

```
用户: 如何在 Vue 3 中创建响应式变量？

Claude: 根据 Vue 3 本地参考文档，使用 ref() 或 reactive()：
       const count = ref(0)
       const state = reactive({ count: 0 })
```

### 离线访问

所有参考文档均为 Markdown 格式，可：
- 使用任何 Markdown 查看器打开
- 在 IDE 中直接查看
- 打印为 PDF 离线阅读

---

## 新项目开发指南

### 概述

CX 项目包含多种技术栈，每种技术栈的新功能开发流程有所不同。本节针对不同系统提供专门的使用建议。

---

### MES 系统（SiView C++）

#### 技术特点
- **语言:** C++
- **规模:** 数百万行代码
- **架构:** CORBA（公共对象请求代理架构）分布式架构 + 事件驱动多线程
- **通信:** CORBA ORB（对象请求代理）+ tMSP（制造工具控制程序）与设备通信

#### 推荐初始化流程

```bash
# 1. 新项目/模块初始化
/init

# 2. 需求探索（复杂功能推荐）
@brainstorming

# 3. 创建规划文件
plan-zh

# 4. 更新 task_plan.md，添加 MES 特定任务
```

#### MES 新功能开发工作流

```
需求分析 → @brainstorming
    ↓
制定计划 → plan-zh → 编辑 task_plan.md
    ↓
设计接口 → 定义 tMSP（制造工具控制程序）插件接口
    ↓
TDD 开发 → @tdd
    ├── 编写单元测试 (Google Test)
    ├── 实现 C++ 代码
    └── 遵循 RAII、智能指针规范
    ↓
代码审查 → /review + /security-review
    ↓
文档生成 → /diagram
```

#### MES 推荐文档

| 优先级 | 文档类型 | 命令 |
|--------|----------|------|
| **P0** | 系统全景图 | `/diagram system-overview "系统全景图"` |
| **P0** | 设备握手流程 | `/diagram flow "设备握手流程"` |
| **P0** | 设备登录时序 | `/diagram sequence "设备登录时序"` |
| **P0** | 设备状态机 | `/diagram state "设备状态机"` |
| **P1** | 事件报告流程 | `/diagram flow "事件报告流程"` |
| **P1** | tMSP 插件架构 | `/diagram component "tMSP（制造工具控制程序）插件架构"` |

#### MES 编码规范要点

```cpp
// ✅ 推荐：使用智能指针
auto device = std::make_shared<Device>();

// ✅ 推荐：RAII 模式
class ConnectionGuard {
    ConnectionGuard(Connection* conn) : conn_(conn) { conn->connect(); }
    ~ConnectionGuard() { conn_->disconnect(); }
private:
    Connection* conn_;
};

// ❌ 避免：裸指针 owning
Device* device = new Device();  // 不要这样做
```

#### MES 模块级开发说明

日常开发多为**具体模块功能**，全景图应聚焦当前模块：

| 开发场景 | 全景图范围 | 示例 |
|----------|------------|------|
| 新设备适配 | 适配器 + EAP + 目标设备 + MES | `/diagram system-overview "XXX设备适配模块"` |
| 事件上报优化 | 事件模块 + EAP + 处理器 + DB | `/diagram system-overview "事件上报模块"` |
| 命令处理增强 | 命令模块 + EAP + 设备 | `/diagram system-overview "命令处理模块"` |

**模块级全景图要素:**
- **当前开发模块** - 高亮显示，标注新增/修改内容
- **直接交互的系统** - MES、EAP、数据库等
- **目标设备** - 涉及的具体设备
- **数据流向** - 只显示相关的接口调用

**不相关的内容可以省略**，保持图示清晰聚焦。

#### MES 相关技能

| 技能 | 用途 |
|------|------|
| `.claude/skills/mes` | MES 专用指导 |
| `.claude/skills/cpp` | C++ 通用规范 |

---

### EAP 系统（VB.NET）

#### 技术特点
- **语言:** VB.NET
- **规模:** 上百项目，各 ~10 万行
- **协议:** SECS/GEM（半导体设备通信标准）
- **架构:** 设备通信和控制

#### 推荐初始化流程

```bash
# 1. 新 EAP 项目初始化
/init

# 2. 需求探索（设备相关功能推荐）
@brainstorming

# 3. 创建规划文件
plan-zh

# 4. 更新 task_plan.md，添加 EAP 特定任务
```

#### EAP 新功能开发工作流

```
需求分析 → @brainstorming
    ↓
制定计划 → plan-zh → 编辑 task_plan.md
    ↓
设计状态机 → 定义 ControlState/CommState
    ↓
TDD 开发 → @tdd
    ├── 编写单元测试 (MSTest/NUnit)
    ├── 实现 VB.NET 代码
    └── Option Strict On
    ↓
代码审查 → /review + /security-review
    ↓
文档生成 → /diagram
```

#### EAP 推荐文档

| 优先级 | 文档类型 | 命令 |
|--------|----------|------|
| **P0** | 设备通信时序 | `/diagram sequence "设备通信时序"` |
| **P0** | EAP 状态机 | `/diagram state "EAP状态机"` |
| **P0** | 设备登录流程 | `/diagram flow "设备登录流程"` |
| **P1** | 事件处理流程 | `/diagram flow "事件处理流程"` |
| **P1** | 命令发送流程 | `/diagram sequence "命令发送流程"` |
| **P1** | 误码恢复流程 | `/diagram flow "误码恢复流程"` |

#### EAP 编码规范要点

```vb
' ✅ 推荐：Option Strict On
Option Strict On
Option Explicit On

' ✅ 推荐：匈牙利命名约定
Dim nErrorCode As Integer
Dim strDeviceName As String
Dim objConnection As Connection

' ✅ 推荐：使用 Using 语句管理资源
Using conn As New Connection()
    ' 处理连接
End Using

' ❌ 避免：On Error Resume Next
On Error Resume Next  ' 不要这样做
' 使用 Try...Catch 代替
```

#### EAP 模块级开发说明

日常 EAP 开发多为**单个设备项目**的功能修改：

| 开发场景 | 全景图范围 | 示例 |
|----------|------------|------|
| 新增设备支持 | EAP 项目 + SECS 通信 + 目标设备 | `/diagram system-overview "XXX设备EAP支持"` |
| 通信优化 | 通信模块 + SECS Client + 设备 | `/diagram system-overview "通信模块优化"` |
| 事件处理修改 | 事件处理 + MES 回调 + DB | `/diagram system-overview "事件处理模块"` |

**EAP 模块级全景图要素:**
- **当前 EAP 项目** - 具体的 VB.NET 项目
- **SECS 通信组件** - 消息收发
- **目标设备** - 具体设备型号
- **MES 接口点** - 回调接口

#### EAP 相关技能

| 技能 | 用途 |
|------|------|
| `.claude/skills/eap` | EAP 专用指导 |
| `.claude/skills/vbnet` | VB.NET 通用规范 |

---

### JAVA + Vue2 系统（B/S 架构）

#### 技术特点
- **后端:** Java 17 / Spring Boot
- **前端:** Vue 2 / Vuex / Vue Router
- **架构:** RESTful API
- **通信:** HTTP/JSON

#### 推荐初始化流程

```bash
# 1. 新 Web 项目初始化
/init

# 2. 需求探索（复杂交互功能推荐）
@brainstorming

# 3. 创建规划文件
plan-zh

# 4. 更新 task_plan.md，添加 Web 特定任务
```

#### JAVA + Vue2 新功能开发工作流

```
需求分析 → @brainstorming
    ↓
制定计划 → plan-zh → 编辑 task_plan.md
    ↓
API 设计 → 定义 RESTful 端点
    ↓
后端开发 → @tdd
    ├── 编写 JUnit 测试
    ├── 实现 Spring Boot 代码
    └── JPA/MyBatis 数据层
    ↓
前端开发 → @tdd
    ├── 编写组件测试 (Jest)
    ├── 实现 Vue 2 组件
    └── Vuex 状态管理
    ↓
联调测试 → 前后端集成
    ↓
代码审查 → /review + /security-review
    ↓
文档生成 → /diagram
```

#### JAVA + Vue2 推荐文档

| 优先级 | 文档类型 | 命令 |
|--------|----------|------|
| **P0** | API 时序图 | `/diagram sequence "API交互时序"` |
| **P1** | 组件关系图 | `/diagram component "前端组件关系"` |
| **P1** | 数据流图 | `/diagram flow "数据流转流程"` |
| **P1** | 状态机 | `/diagram state "应用状态机"` |

#### 后端编码规范要点

```java
// ✅ 推荐：RESTful API 设计
@GetMapping("/api/v1/devices/{id}")
public ResponseEntity<DeviceDto> getDevice(@PathVariable Long id) {
    // 实现
}

// ✅ 推荐：Service 层事务管理
@Service
@Transactional
public class DeviceService {
    // 业务逻辑
}

// ✅ 推荐：依赖注入
private final DeviceRepository deviceRepository;

public DeviceService(DeviceRepository deviceRepository) {
    this.deviceRepository = deviceRepository;
}
```

#### 前端编码规范要点

```javascript
// ✅ 推荐：Vue 2 Composition API 风格
export default {
  name: 'DeviceList',
  data() {
    return {
      devices: [],
      loading: false
    }
  },
  mounted() {
    this.fetchDevices()
  },
  methods: {
    async fetchDevices() {
      this.loading = true
      try {
        const response = await api.getDevices()
        this.devices = response.data
      } finally {
        this.loading = false
      }
    }
  }
}

// ✅ 推荐：Vuex 模块化
// store/modules/device.js
export default {
  namespaced: true,
  state: { /* ... */ },
  mutations: { /* ... */ },
  actions: { /* ... */ }
}
```

#### Web 相关技能

| 技能 | 用途 |
|------|------|
| `.claude/skills/java` | Java/Spring Boot 指导 |
| `.claude/skills/vue` | Vue 2/3 指导 |

---

### C# 系统（Windows 桌面/服务）

#### 技术特点
- **语言:** C# (.NET 6+)
- **架构:** 桌面应用 (WPF/WinForms) 或 Windows 服务
- **异步:** async/await 模式
- **通信:** WCF / gRPC / Named Pipe

#### 推荐初始化流程

```bash
# 1. 新 C# 项目初始化
/init

# 2. 需求探索（UI 复杂或通信功能推荐）
@brainstorming

# 3. 创建规划文件
plan-zh

# 4. 更新 task_plan.md，添加 C# 特定任务
```

#### C# 新功能开发工作流

```
需求分析 → @brainstorming
    ↓
制定计划 → plan-zh → 编辑 task_plan.md
    ↓
设计架构 → MVVM 模式 (WPF) 或 服务分层
    ↓
TDD 开发 → @tdd
    ├── 编写 xUnit 测试
    ├── 实现 C# 代码
    └── async/await 异步处理
    ↓
代码审查 → /review + /security-review
    ↓
文档生成 → /diagram
```

#### C# 推荐文档

| 优先级 | 文档类型 | 命令 |
|--------|----------|------|
| **P0** | 类关系图 | `/diagram class "核心类关系"` |
| **P1** | 组件图 | `/diagram component "系统组件架构"` |
| **P1** | 通信时序 | `/diagram sequence "服务通信时序"` |

#### C# 编码规范要点

```csharp
// ✅ 推荐：async/await 最佳实践
public async Task<Result> ProcessAsync(CancellationToken cancellationToken)
{
    // 使用 cancellationToken
    var data = await _repository.GetAsync(cancellationToken);
    return Process(data);
}

// ✅ 推荐：依赖注入
public class DeviceService
{
    private readonly IDeviceRepository _repository;
    private readonly ILogger<DeviceService> _logger;

    public DeviceService(IDeviceRepository repository, ILogger<DeviceService> logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// ✅ 推荐：记录类型 (C# 9+)
public record DeviceDto(int Id, string Name, DeviceStatus Status);

// ✅ 推荐：模式匹配
public string GetStatusText(DeviceStatus status) => status switch
{
    DeviceStatus.Online => "在线",
    DeviceStatus.Offline => "离线",
    DeviceStatus.Error => "故障",
    _ => "未知"
};
```

#### C# 相关技能

| 技能 | 用途 |
|------|------|
| `.claude/docs/references/csharp-reference.md` | C# 本地参考 |

---

### 各系统快速对比

| 系统 | 语言 | 规模 | 核心技能 | 主要文档 |
|------|------|------|----------|----------|
| **MES** | C++ | 百万行 | mes, cpp | 状态机、时序图 |
| **EAP** | VB.NET | 上百项目 | eap, vbnet | 状态机、时序图 |
| **Web** | Java + Vue2 | 中型 | java, vue | API 时序、组件图 |
| **C#** | C# | 中小型 | csharp-ref | 类图、组件图 |

---

## 工作流程

### 新功能开发

```
1. 需求分析
   → 与 Claude 讨论需求
   → /diagram flow 绘制流程图

2. 制定计划
   → @planning 编写实施计划
   → 更新 task_plan.md

3. TDD 开发
   → @tdd 编写测试
   → 实现代码
   → 运行测试

4. 代码审查
   → /review 检查代码
   → 修复问题

5. 提交推送
   → git commit (自动检查)
   → git push (自动测试)
```

### Bug 修复

```
1. 问题定位
   → @systematic-debugging 系统化调试
   → 分析根因

2. 修复验证
   → @tdd 编写回归测试
   → 修复代码

3. 记录经验
   → /learn --type error "xxx问题原因"
```

### 文档生成

```
1. 生成图表
   → /diagram flow "xxx流程"
   → /diagram sequence "xxx时序"

2. 下载查看
   → 由于局域网环境
   → 下载 .puml 文件到本地
   → 使用 PlantUML 工具渲染

3. 生成文档
   → /doc --requirements
   → /doc --files
```

---

## 常见问题

### Q: 如何查看当前任务?

A: 会话开始时自动显示，或手动查看：
```bash
cat task_plan.md
cat progress.md
```

### Q: PUML 图表如何查看?

A: 局域网环境无在线渲染：
1. 下载 `docs/diagrams/*.puml` 到本地
2. 使用 PlantUML 插件（IDEA/VSCode）
3. 或使用本地 PlantUML 工具

### Q: 如何避免 AI 幻觉?

A: 遵循"操作前验证"原则：
```bash
# 检查文件是否存在
ls path/to/file

# 检查 API 是否存在
grep "api_name" codebase

# 使用验证命令
/verify code
/verify api <name>
```

### Q: 如何处理大型代码库?

A: 使用索引系统：
```bash
# 1. 查看索引
ls .claude/indexes/

# 2. 使用 Glob 精确匹配
# 3. 按需读取，单次不超过 10 个文件
```

### Q: 如何创建项目 Skill?

A: 使用命令：
```bash
/create-skill --scope core --depth standard
```

### Q: 代码检查失败怎么办?

A:
1. 查看错误信息
2. 修复问题
3. 重新提交

```bash
# 检查具体错误
cat .claude/hooks/pre-commit/run-checks.sh

# 手动运行测试
bash .claude/hooks/pre-commit/run-checks.sh
```

---

## 附录

### 文件结构总览

```
D:\cx\
├── .claude/
│   ├── CLAUDE.md                    # 主指导文档 ⭐
│   ├── settings.json                # 配置文件
│   ├── skills/                      # 技术栈技能
│   │   ├── mes/                     # MES 专用 (4 文件)
│   │   ├── eap/                     # EAP 专用 (5 文件)
│   │   ├── cpp/, vbnet/, java/, vue/
│   ├── commands/                    # 自定义命令 (8 个)
│   ├── hooks/                       # Git Hooks (3 个)
│   ├── templates/                   # 文档模板
│   ├── docs/                        # 文档和知识库
│   │   └── references/              # 本地技术参考 ⭐
│   └── indexes/                     # 文件索引
├── docs/                            # 生成的文档
├── task_plan.md                     # 任务计划
├── progress.md                      # 进度记录
├── findings.md                      # 研究发现
├── README.md                        # 项目说明 ⭐
└── 使用手册.md                       # 本文档 ⭐
```

### 快速命令参考

| 命令 | 功能 | 时机 |
|------|------|------|
| `/init` | 初始化 CLAUDE.md | 新项目 |
| `/update-claude` | 更新 CLAUDE.md | 代码变更后 |
| `/create-skill` | 生成项目 Skill | 深入分析代码 |
| `/learn` | 记录经验 | 遇到问题时 |
| `/review` | 代码审查 | 提交前 |
| `/diagram` | 生成图表 | 需要文档时 |

---

**更新日期:** 2025-03-23
**维护:** CX Claude Code 配置团队
