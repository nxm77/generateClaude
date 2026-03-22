# AI 编码经验积累工具设计

> **版本:** v1.0
> **日期:** 2026-03-22
> **用途:** 持续记录 AI 编码过程中的错误和经验，迭代改进

---

## 核心概念

**AI Lessons (经验教训库)** - 项目级的 AI 编码经验积累文件

```
编码 → 遇到问题 → 解决 → /learn 记录 → 项目经验库
              ↓
         后续参考 → 避免重复错误 → 提高效率
```

---

## 文件结构

```
项目根目录/
└── .claude/
    └── lessons.md                 # AI 编码经验库
```

---

## /learn 命令

### 功能

记录 AI 编码过程中的错误、解决方案和经验。

### 语法

```bash
/learn [类型] "[标题]"
# 然后输入详细内容
```

### 类型分类

| 类型 | 说明 | 示例标题 |
|------|------|---------|
| `error` | 编码错误 | C++ 智能指针内存泄漏 |
| `pattern` | 代码模式 | MES 设备通信状态机模式 |
| `performance` | 性能优化 | 大批量数据查询优化 |
| `anti-pattern` | 反模式警告 | 避免 EAP 全局变量共享状态 |
| `convention` | 编码规范 | MES 项目命名约定更新 |
| `debug` | 调试经验 | SECS/GEM 通信超时排查 |

### 使用示例

```bash
# 记录错误
$ /learn error "C++ 智能指针循环引用导致内存泄漏"
> 输入详细内容...

# 记录模式
$ /learn pattern "EAP 设备通信状态机实现"
> 输入详细内容...

# 记录性能优化
$ /learn performance "Oracle 批量插入优化"
> 输入详细内容...
```

---

## lessons.md 格式

```markdown
# AI 编码经验库 - [项目名称]

> 最后更新: 2026-03-22
> 总条目: 12

---

## 错误 (Errors)

### [E001] C++ 智能指针循环引用导致内存泄漏

**日期:** 2026-03-20
**影响:** 内存持续增长，程序最终崩溃

**问题代码:**
```cpp
class Device {
    std::shared_ptr<Communicator> comm_;
};

class Communicator {
    std::shared_ptr<Device> device_;  // 循环引用!
};
```

**解决方案:**
```cpp
class Communicator {
    std::weak_ptr<Device> device_;  // 使用 weak_ptr 打破循环
};
```

**验证:** Valgrind 确认内存泄漏已修复

**相关文件:** src/core/Device.cpp, src/core/Communicator.cpp

---

## 代码模式 (Patterns)

### [P001] EAP 设备通信状态机实现

**日期:** 2026-03-18
**适用场景:** 设备通信模块

**模式描述:**
```cpp
enum class CommState {
    DISABLED,
    NOT_CONNECTED,
    CONNECTING,
    ONLINE,
    ERROR
};

class DeviceStateMachine {
    CommState state_ = CommState::DISABLED;
    std::map<CommState, std::vector<Transition>> transitions_;

    void transition(CommState newState) {
        // 验证转换合法性
        // 记录状态变更
        // 触发相应事件
    }
};
```

**注意事项:**
- 所有状态转换必须通过 transition() 方法
- 状态变更必须记录日志
- 超时后自动恢复到 NOT_CONNECTED

---

## 性能优化 (Performance)

### [PF001] Oracle 批量插入优化

**日期:** 2026-03-15
**问题:** 单条插入 1000 条记录耗时 45 秒

**优化前:**
```cpp
for (const auto& record : records) {
    executeInsert("INSERT INTO ...");  // 逐条插入
}
```

**优化后:**
```cpp
std::string sql = "INSERT ALL ";
for (const auto& record : records) {
    sql += "INTO table_name (...) VALUES (...) ";
}
sql += "SELECT 1 FROM DUAL";
executeInsert(sql);  // 批量插入
```

**效果:** 耗时降至 2 秒

---

## 反模式警告 (Anti-Patterns)

### [AP001] 避免 EAP 全局变量共享状态

**日期:** 2026-03-10
**问题:** 全局变量导致多线程竞争

**反模式:**
```vb
Public Shared CurrentDeviceState As String  ' 全局共享!
```

**推荐模式:**
```vb
Public Class DeviceContext
    Private ReadOnly _syncLock As New Object()
    Private _state As String

    Public Property State As String
        Get
            SyncLock _syncLock
                Return _state
            End SyncLock
        End Get
        Set(value As String)
            SyncLock _syncLock
                _state = value
            End SyncLock
        End Set
    End Property
End Class
```

---

## 编码规范 (Conventions)

### [C001] MES 项目命名约定

**日期:** 2026-03-01

**类命名:**
- 设备类: `XxxDevice` (如: `PhotolithographyDevice`)
- 通信类: `XxxCommunicator` (如: `SECSCommunicator`)
- 状态类: `XxxState` (如: `EquipmentState`)

**函数命名:**
- 建立连接: `establishXxx()` (如: `establishConnection()`)
- 发送消息: `sendXxx()` (如: `sendEventReport()`)
- 等待响应: `waitForXxx()` (如: `waitForSecondary()`)

**文件命名:**
- 头文件: `PascalCase.h` (如: `DeviceCommunicator.h`)
- 源文件: `PascalCase.cpp` (如: `DeviceCommunicator.cpp`)

---

## 调试经验 (Debug)

### [D001] SECS/GEM 通信超时排查步骤

**日期:** 2026-03-05

**现象:** S1F13 建立通信请求无响应

**排查步骤:**
1. 检查网络连通性: `ping <设备IP>`
2. 检查端口监听: `netstat -an | grep 5000`
3. 抓包分析: Wireshark 过滤 `tcp.port == 5000`
4. 检查设备状态: 设备是否在 ENABLED 状态
5. 检查超时设置: T1 超时是否过短

**常见原因:**
- 设备未初始化完成
- HSMS 端口不匹配
- 防火墙阻止连接

---

## 索引

| ID | 类型 | 标题 | 日期 |
|----|------|------|------|
| E001 | error | C++ 智能指针循环引用 | 2026-03-20 |
| P001 | pattern | EAP 状态机实现 | 2026-03-18 |
| PF001 | performance | Oracle 批量插入 | 2026-03-15 |
| AP001 | anti-pattern | EAP 全局变量 | 2026-03-10 |
| C001 | convention | MES 命名约定 | 2026-03-01 |
| D001 | debug | SECS 超时排查 | 2026-03-05 |
```

---

## 自动化建议

### 编码错误后自动提示

```bash
# 当 AI 修复错误后，自动提示
"错误已修复。是否记录到经验库？"
- [A] 记录
- [B] 跳过
```

### Pre-commit Hook 提醒

```bash
#!/bin/bash
# .claude/hooks/pre-commit/check-lessons.sh

# 检测是否修复了编译错误或测试失败
if git diff --cached | grep -q "fix\|bug\|error"; then
    echo "检测到错误修复，建议运行 /learn 记录经验"
fi
```

---

## 使用流程

```
┌────────────────────────────────────────────────────────┐
│  AI 编码过程                                          │
│       ↓                                               │
│  遇到错误 / 发现新模式 / 优化性能                      │
│       ↓                                               │
│  解决问题                                             │
│       ↓                                               │
│  /learn 记录 → 选择类型 → 输入详细内容                │
│       ↓                                               │
│  更新 lessons.md                                      │
│       ↓                                               │
│  后续参考 → 避免重复错误                              │
└────────────────────────────────────────────────────────┘
```

---

## 搜索经验

```bash
# 按类型搜索
/learn search error
/learn search pattern

# 按关键词搜索
/learn search "内存泄漏"
/learn search "状态机"

# 查看最新
/learn recent
```

---

## 与 findings.md 的关系

| 文件 | 用途 | 更新频率 |
|------|------|---------|
| `lessons.md` | **AI 编码经验**，技术性 | 每次解决问题后 |
| `findings.md` | **项目研究发现**，业务性 | 规划-with-files，每发现新知识 |
| `instincts/` | **编码模式习惯**，自动 | continuous-learning-v2，自动捕获 |

## 与 continuous-learning-v2 配合

**continuous-learning-v2** 是 everything-claude-code 插件的一部分，功能：

| 特性 | continuous-learning-v2 | /learn (lessons.md) |
|------|------------------------|-------------------|
| 触发方式 | 自动（Hooks 观察） | 手动命令 |
| 存储格式 | Instinct（JSON） | Markdown 文档 |
| 知识类型 | 编码模式、惯例 | 错误、优化、规范 |
| 查阅方式 | AI 自动读取 | 人工阅读 |
| 项目隔离 | ✅ 项目级/全局 | ✅ 项目级 |

**配合使用场景：**

```
编码过程
    │
    ├─── 自动捕获 (continuous-learning-v2)
    │    └── 编码模式、命名惯例、常用结构
    │         ↓
    │    Instincts 文件
    │         ↓
    │    AI 后续自动应用
    │
    └─── 手动记录 (/learn)
         └── 具体错误、解决方案、性能优化
              ↓
         lessons.md
              ↓
         可查阅、可分享
```

**三者互补，各司其职。**

---

**文档版本:** v1.1
**最后更新:** 2026-03-22
