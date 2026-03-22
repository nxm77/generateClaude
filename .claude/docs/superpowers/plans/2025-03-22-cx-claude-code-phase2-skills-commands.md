# CX Claude Code Skills 和 Commands 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标:** 创建技术栈 Skills (MES, EAP, CPP, VBNET, JAVA, VUE) 和自定义 Commands (/init, /update-claude, /create-skill, /learn, /doc, /diagram)

**架构:** 每个 Skill 包含 SKILL.md 主文件和相关文档；每个 Command 是可执行的 Shell 脚本

**技术栈:** Markdown, Shell Script, Python, Claude Code CLI

---

## 文件结构

```
D:\cx\.claude\
├── skills\
│   ├── mes\                      # MES 专用 Skill
│   │   ├── SKILL.md
│   │   ├── coding-standards.md
│   │   ├── patterns.md
│   │   ├── debugging.md
│   │   └── api-reference.md
│   │
│   ├── eap\                      # EAP 专用 Skill
│   │   ├── SKILL.md
│   │   ├── coding-standards.md
│   │   ├── patterns.md
│   │   ├── debugging.md
│   │   └── secs-gem-reference.md
│   │
│   ├── cpp\                      # 通用 C++ Skill
│   │   ├── SKILL.md
│   │   ├── coding-standards.md
│   │   └── patterns.md
│   │
│   ├── vbnet\                    # VB.NET Skill
│   │   ├── SKILL.md
│   │   ├── coding-standards.md
│   │   └── patterns.md
│   │
│   ├── java\                     # JAVA Skill
│   │   ├── SKILL.md
│   │   ├── coding-standards.md
│   │   └── patterns.md
│   │
│   ├── vue\                      # VUE Skill (2+3)
│   │   ├── SKILL.md
│   │   ├── coding-standards.md
│   │   └── patterns.md
│   │
│   └── documentation\            # 文档生成 Skill
│       ├── SKILL.md
│       └── templates/
│
├── commands\                     # 自定义 Commands
│   ├── init.sh                   # 初始化 CLAUDE.md
│   ├── update-claude.sh          # 更新 CLAUDE.md
│   ├── create-skill.sh           # 生成项目 Skill
│   ├── learn.sh                  # 记录编码经验
│   ├── doc.sh                    # 文档生成
│   ├── diagram.sh                # PUML 图表生成
│   ├── context.sh                # 上下文管理
│   └── status.sh                 # 项目状态
│
└── docs\
    └── command-docs\             # 命令文档
        ├── init-command.md
        ├── update-claude-command.md
        ├── create-skill-command.md
        ├── learn-command.md
        ├── doc-command.md
        └── diagram-command.md
```

---

## Task 1: 创建 MES Skill

**Files:**
- Create: `D:\cx\.claude\skills\mes\SKILL.md`
- Create: `D:\cx\.claude\skills\mes\coding-standards.md`
- Create: `D:\cx\.claude\skills\mes\patterns.md`
- Create: `D:\cx\.claude\skills\mes\debugging.md`

- [ ] **Step 1: 创建 MES Skill 目录**

```bash
mkdir -p D:\cx\.claude\skills\mes
```

- [ ] **Step 2: 创建 SKILL.md 主文件**

```markdown
# MES (SiView) 专用技能

> **系统:** SiView MES
> **技术栈:** C++
> **代码规模:** 数百万行
> **更新:** 2025-03-22

---

## 技能概述

本技能提供 SiView MES 系统的开发和维护指导。

---

## 核心知识

### 系统特点

- **tMSP** - 制造工具控制应用程序
- **事件驱动** - 面向服务的多线程逻辑引擎
- **插件式架构** - 业务逻辑可插拔
- **设备通信** - 与 EAP 系统集成

### 关键组件

| 组件 | 文件位置 | 功能 |
|------|---------|------|
| 执行引擎 | `src/core/executor/` | 事件驱动执行 |
| 设备通信 | `src/communication/` | EAP 通信 |
| 数据访问 | `src/database/` | 数据库操作 |
| 设备适配器 | `src/adapters/` | 设备适配 |

---

## 使用场景

### 何时使用本技能

- 开发 MES 新功能
- 修改 MES 业务逻辑
- 调试 MES 问题
- 添加新设备支持

### 相关技能

- `.claude/skills/eap` - EAP 系统
- `.claude/skills/cpp` - C++ 通用知识
- `.claude/docs/knowledge/mes-eap-technical-knowledge.md` - 技术知识库

---

## 快速参考

### 常用文件

- [核心文件索引](.claude/indexes/mes-core.md)

### SECS/GEM 消息

- [技术知识库](.claude/docs/knowledge/mes-eap-technical-knowledge.md)

### 调试技巧

- [调试指南](debugging.md)

---

## 详细文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [调试指南](debugging.md)
```

- [ ] **Step 3: 创建 coding-standards.md**

```markdown
# MES 编码规范

> **系统:** SiView MES
> **语言:** C++
> **标准:** C++ Core Guidelines
> **更新:** 2025-03-22

---

## 核心原则

### 1. 内存管理

**使用智能指针管理内存：**

```cpp
// ✅ 正确 - 使用智能指针
std::shared_ptr<DeviceCommunicator> comm =
    std::make_shared<DeviceCommunicator>(deviceId);

std::unique_ptr<Event> event =
    std::make_unique<Event>(eventType);

// ❌ 错误 - 裸指针 owning
DeviceCommunicator* comm = new DeviceCommunicator(deviceId);
```

**RAII 模式管理资源：**

```cpp
// ✅ 正确 - RAII
class DatabaseConnection {
public:
    DatabaseConnection(const std::string& connStr) {
        conn = pqxx::connection(connStr);
    }
    ~DatabaseConnection() {
        // 自动关闭连接
    }
private:
    pqxx::connection conn;
};

// ❌ 错误 - 手动管理
class DatabaseConnection {
public:
    void open() { conn.open(); }
    void close() { conn.close(); }
};
```

### 2. 线程安全

**使用线程安全的数据结构：**

```cpp
// ✅ 正确 - 使用 mutex
class ThreadSafeQueue {
public:
    void push(const Event& event) {
        std::lock_guard<std::mutex> lock(mutex_);
        queue_.push(event);
    }
private:
    std::queue<Event> queue_;
    std::mutex mutex_;
};

// ✅ 正确 - 使用原子变量
std::atomic<bool> running_{true};
```

### 3. 错误处理

**使用异常处理错误：**

```cpp
// ✅ 正确
void processEvent(const Event& event) {
    if (event.type == EventType::UNKNOWN) {
        throw std::invalid_argument("Unknown event type");
    }
    // 处理逻辑
}

// ✅ 正确 - 调用者处理
try {
    processEvent(event);
} catch (const std::exception& e) {
    LOG_ERROR("Event processing failed: " << e.what());
}
```

---

## 文件结构

### 文件长度限制

| 文件类型 | 最大行数 |
|---------|---------|
| .cpp | 1000 行 |
| .h | 500 行 |

### 函数长度限制

- 单函数不超过 **100 行**
- 复杂逻辑拆分为子函数

---

## 命名约定

### 类命名

```cpp
// PascalCase
class DeviceCommunicator { };
class EventExecutor { };
class DatabaseManager { };
```

### 函数命名

```cpp
// camelCase
void establishConnection();
void processEvent();
std::string getDeviceId();
```

### 变量命名

```cpp
// camelCase，成员变量加后缀 _
int deviceId_;
std::string connectionString_;
bool isOnline_;
```

### 常量命名

```cpp
// UPPER_CASE
const int MAX_RETRY_COUNT = 3;
const int CONNECTION_TIMEOUT_MS = 5000;
const std::string DEFAULT_EQ_TYPE = "GROWTH";
```

---

## 代码组织

### 头文件保护

```cpp
// ✅ 正确 - 使用 #pragma once
#pragma once

class DeviceCommunicator {
    // ...
};

// ✅ 或使用 include guard
#ifndef DEVICE_COMMUNICATOR_H_
#define DEVICE_COMMUNICATOR_H_

class DeviceCommunicator {
    // ...
};

#endif  // DEVICE_COMMUNICATOR_H_
```

### include 顺序

```cpp
// 1. 对应头文件
#include "DeviceCommunicator.h"

// 2. C 标准库
#include <cstring>
#include <ctime>

// 3. C++ 标准库
#include <memory>
#include <string>
#include <vector>

// 4. 第三方库
#include <pqxx/pqxx>

// 5. 项目内部
#include "core/Event.h"
#include "database/Connection.h"
```

---

## 注释规范

### 类注释

```cpp
/**
 * @brief 设备通信器
 *
 * 负责与 EAP 系统的 SECS/GEM 通信
 *
 * @note 线程安全，可在多线程环境下使用
 */
class DeviceCommunicator {
    // ...
};
```

### 函数注释

```cpp
/**
 * @brief 建立设备通信
 *
 * 发送 S1F13 消息建立通信，等待 S1F14 响应
 *
 * @param deviceId 设备 ID
 * @return true 通信成功
 * @return false 通信失败
 * @throws CommunicationTimeoutException 超时未响应
 */
bool establishConnection(const std::string& deviceId);
```

---

## 性能考虑

### 避免不必要的拷贝

```cpp
// ✅ 正确 - 使用引用
void processEvent(const Event& event);
std::string getDeviceName(const Device& device);

// ❌ 错误 - 不必要的拷贝
void processEvent(Event event);
std::string getDeviceName(Device device);
```

### 使用移动语义

```cpp
// ✅ 正确
std::vector<Event> events;
events.push_back(Event{EventType::ALARM});  // 移动

// ✅ 正确 - 返回值优化
std::vector<Event> getEvents() {
    std::vector<Event> events;
    // ...
    return events;  // 移动，不拷贝
}
```

---

## 相关文档

- [C++ Core Guidelines 本地参考](../../../references/cpp-core-guidelines.md)
- [MES 代码模式](patterns.md)
- [调试指南](debugging.md)
```

- [ ] **Step 4: 创建 patterns.md**

```markdown
# MES 代码模式

> **系统:** SiView MES
> **语言:** C++
> **更新:** 2025-03-22

---

## 事件处理模式

### 基本事件处理

```cpp
// 事件处理器接口
class EventHandler {
public:
    virtual ~EventHandler() = default;
    virtual void handle(const Event& event) = 0;
};

// 具体事件处理器
class AlarmEventHandler : public EventHandler {
public:
    void handle(const Event& event) override {
        if (event.type == EventType::ALARM) {
            processAlarm(event);
        }
    }

private:
    void processAlarm(const Event& event) {
        // 报警处理逻辑
        alarmManager_.report(event.alarmCode, event.deviceId);
    }

    AlarmManager& alarmManager_;
};
```

### 事件分发器

```cpp
class EventDispatcher {
public:
    void registerHandler(EventType type,
                        std::shared_ptr<EventHandler> handler) {
        handlers_[type].push_back(handler);
    }

    void dispatch(const Event& event) {
        auto it = handlers_.find(event.type);
        if (it != handlers_.end()) {
            for (auto& handler : it->second) {
                handler->handle(event);
            }
        }
    }

private:
    std::unordered_map<EventType,
        std::vector<std::shared_ptr<EventHandler>>> handlers_;
};
```

---

## 设备通信模式

### 通信管理器

```cpp
class DeviceCommunicator {
public:
    DeviceCommunicator(const std::string& deviceId)
        : deviceId_(deviceId), state_(DeviceState::DISCONNECTED) {}

    bool establishConnection() {
        // S1F13/S1F14 握手
        auto response = sendWithTimeout(
            SECSMessage(S1F13),
            std::chrono::seconds(T1_TIMEOUT)
        );

        if (response && response->function == S1F14) {
            state_ = DeviceState::COMMUNICATING;
            return true;
        }
        return false;
    }

    bool goOnline() {
        if (state_ != DeviceState::COMMUNICATING) {
            return false;
        }

        auto response = sendWithTimeout(
            SECSMessage(S1F15),
            std::chrono::seconds(T2_TIMEOUT)
        );

        if (response && response->function == S1F17) {
            state_ = DeviceState::ONLINE;
            return true;
        }
        return false;
    }

private:
    std::string deviceId_;
    DeviceState state_;

    template<typename Rep, typename Period>
    std::optional<SECSMessage> sendWithTimeout(
        const SECSMessage& msg,
        std::chrono::duration<Rep, Period> timeout) {

        auto future = std::async(std::launch::async, [this, &msg]() {
            return sendAndWait(msg);
        });

        if (future.wait_for(timeout) == std::future_status::timeout) {
            return std::nullopt;
        }
        return future.get();
    }
};
```

---

## 数据库操作模式

### 数据访问对象

```cpp
class EquipmentDAO {
public:
    EquipmentDAO(std::shared_ptr<DatabaseConnection> conn)
        : conn_(conn) {}

    Equipment findById(const std::string& id) {
        pqxx::work txn(*conn_);
        pqxx::result result = txn.exec_params(
            "SELECT id, type, status FROM equipment WHERE id = $1",
            id
        );

        if (!result.empty()) {
            return Equipment{
                .id = result[0][0].as<std::string>(),
                .type = result[0][1].as<std::string>(),
                .status = result[0][2].as<int>()
            };
        }
        throw EquipmentNotFoundException(id);
    }

    void save(const Equipment& eq) {
        pqxx::work txn(*conn_);
        txn.exec_params(
            "INSERT INTO equipment (id, type, status) VALUES ($1, $2, $3)",
            eq.id, eq.type, eq.status
        );
        txn.commit();
    }

private:
    std::shared_ptr<DatabaseConnection> conn_;
};
```

---

## 状态机模式

### 设备状态机

```cpp
class DeviceStateMachine {
public:
    enum class State {
        DISABLED,
        NOT_CONNECTED,
        COMMUNICATING,
        ONLINE
    };

    bool transition(State from, State to) {
        std::lock_guard<std::mutex> lock(mutex_);

        if (!isValidTransition(from, to)) {
            return false;
        }

        state_ = to;
        notifyStateChanged(from, to);
        return true;
    }

    State currentState() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return state_;
    }

private:
    bool isValidTransition(State from, State to) {
        // 定义合法的状态转换
        static std::unordered_map<std::pair<State, State>, bool> validTransitions = {
            {{State::DISABLED, State::NOT_CONNECTED}, true},
            {{State::NOT_CONNECTED, State::COMMUNICATING}, true},
            {{State::COMMUNICATING, State::ONLINE}, true},
            {{State::ONLINE, State::COMMUNICATING}, true},
            {{State::COMMUNICATING, State::NOT_CONNECTED}, true},
            {{State::NOT_CONNECTED, State::DISABLED}, true},
            {{State::ONLINE, State::DISABLED}, true}
        };

        auto key = std::make_pair(from, to);
        return validTransitions.count(key) > 0;
    }

    void notifyStateChanged(State from, State to) {
        // 通知状态变化监听器
    }

    State state_ = State::DISABLED;
    std::mutex mutex_;
};
```

---

## 工厂模式

### 设备适配器工厂

```cpp
class DeviceAdapterFactory {
public:
    static std::unique_ptr<DeviceAdapter> create(
        const std::string& equipmentType) {

        if (equipmentType == "GROWTH") {
            return std::make_unique<GrowthFurnaceAdapter>();
        } else if (equipmentType == "ETCH") {
            return std::make_unique<EtchMachineAdapter>();
        } else if (equipmentType == "PHOTOLITHOGRAPHY") {
            return std::make_unique<StepperAdapter>();
        }

        throw UnsupportedEquipmentException(equipmentType);
    }
};

// 使用
auto adapter = DeviceAdapterFactory::create("GROWTH");
adapter->initialize();
```

---

## 观察者模式

### 设备状态监听

```cpp
class DeviceStateListener {
public:
    virtual ~DeviceStateListener() = default;
    virtual void onStateChanged(const std::string& deviceId,
                               DeviceState oldState,
                               DeviceState newState) = 0;
};

class DeviceMonitor {
public:
    void addListener(std::shared_ptr<DeviceStateListener> listener) {
        std::lock_guard<std::mutex> lock(mutex_);
        listeners_.push_back(listener);
    }

    void notifyStateChanged(const std::string& deviceId,
                           DeviceState oldState,
                           DeviceState newState) {
        std::lock_guard<std::mutex> lock(mutex_);
        for (auto& listener : listeners_) {
            listener->onStateChanged(deviceId, oldState, newState);
        }
    }

private:
    std::vector<std::shared_ptr<DeviceStateListener>> listeners_;
    std::mutex mutex_;
};
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [调试指南](debugging.md)
- [技术知识库](.claude/docs/knowledge/mes-eap-technical-knowledge.md)
```

- [ ] **Step 5: 创建 debugging.md**

```markdown
# MES 调试指南

> **系统:** SiView MES
> **语言:** C++
> **更新:** 2025-03-22

---

## 常见问题

### 1. 内存泄漏

**症状:**
- 程序运行一段时间后内存持续增长
- 系统变慢或崩溃

**排查方法:**

```bash
# 使用 Valgrind 检测内存泄漏
valgrind --leak-check=full --show-leak-kinds=all ./mes_executive

# 使用 AddressSanitizer
export ASAN_OPTIONS=detect_leaks=1
./mes_executive
```

**常见原因:**

```cpp
// ❌ 错误 - 循环引用
class Parent {
public:
    std::shared_ptr<Child> child_;
};

class Child {
public:
    std::shared_ptr<Parent> parent_;  // 循环引用！
};

// ✅ 正确 - 使用 weak_ptr 打破循环
class Child {
public:
    std::weak_ptr<Parent> parent_;
};
```

### 2. 线程安全问题

**症状:**
- 随机崩溃
- 数据不一致
- 竞态条件

**排查方法:**

```bash
# 使用 ThreadSanitizer
export TSAN_OPTIONS=second_deadlock_stack=1
./mes_executive

# 使用 GDB 调试
gdb ./mes_executive
(gdb) thread apply all bt
```

**常见原因:**

```cpp
// ❌ 错误 - 未保护的共享数据
class Counter {
public:
    void increment() { count++; }  // 竞态条件！
private:
    int count = 0;
};

// ✅ 正确 - 使用 mutex 保护
class Counter {
public:
    void increment() {
        std::lock_guard<std::mutex> lock(mutex_);
        count++;
    }
private:
    int count = 0;
    std::mutex mutex_;
};

// ✅ 正确 - 使用原子变量
class Counter {
public:
    void increment() { count_.fetch_add(1); }
private:
    std::atomic<int> count_{0};
};
```

### 3. 设备通信超时

**症状:**
- 设备无法上线
- 命令无响应
- 事件未上报

**排查步骤:**

```bash
# 1. 检查网络连接
ping <设备IP>

# 2. 检查端口
netstat -an | grep <设备端口>

# 3. 查看通信日志
tail -f logs/communications.log | grep <设备ID>
```

**常见原因:**

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| T1 超时 | 设备未启动或网络不通 | 检查设备和网络 |
| T2 超时 | 设备繁忙 | 增加重试次数 |
| T3 超时 | 命令处理时间长 | 增加超时时间 |

### 4. 数据库连接问题

**症状:**
- 无法保存数据
- 查询超时
- 连接池耗尽

**排查步骤:**

```bash
# 检查数据库连接
psql -h <host> -U <user> -d <database>

# 查看连接数
SELECT count(*) FROM pg_stat_activity;
```

**常见原因:**

```cpp
// ❌ 错误 - 未关闭连接
void processEvent(const Event& event) {
    auto conn = new pqxx::connection(connStr);
    // 处理...
    // 忘记关闭！
}

// ✅ 正确 - 使用 RAII
void processEvent(const Event& event) {
    pqxx::connection conn(connStr);
    // 处理...
    // 自动关闭
}

// ✅ 更好 - 使用连接池
void processEvent(const Event& event) {
    auto conn = connectionPool_.acquire();
    // 处理...
    // 自动归还
}
```

---

## 调试工具

### GDB 常用命令

```bash
# 启动 GDB
gdb ./mes_executive

# 设置断点
(gdb) break DeviceCommunicator::establishConnection
(gdb) break EventDispatcher::dispatch

# 运行
(gdb) run

# 查看调用栈
(gdb) bt

# 查看变量
(gdb) print deviceId
(gdb) print event.type

# 单步执行
(gdb) next     # 下一行（不进入函数）
(gdb) step     # 下一行（进入函数）
(gdb) continue # 继续执行

# 查看线程
(gdb) info threads
(gdb) thread 2
```

### 日志调试

```cpp
// 使用日志宏
LOG_INFO("Establishing connection to device: " << deviceId);
LOG_WARNING("Connection timeout after " << timeout << " ms");
LOG_ERROR("Failed to send command: " << e.what());

// 启用调试日志
#define SPDLOG_ACTIVE_LEVEL SPDLOG_LEVEL_DEBUG
```

---

## 性能分析

### 使用 perf

```bash
# CPU 性能分析
perf record -g ./mes_executive
perf report

# 火焰图
perf script | stackcollapse-perf.pl | flamegraph.pl > flamegraph.svg
```

### 内存分析

```bash
# 内存使用情况
valgrind --tool=massif ./mes_executive
ms_print massif.out.xxxxx

# 详细分析
valgrind --tool=massif --detail-every-alloc=1000 ./mes_executive
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [SECS/GEM 协议](.claude/docs/knowledge/mes-eap-technical-knowledge.md)
```

- [ ] **Step 6: 验证文件创建**

```bash
ls -la D:\cx\.claude\skills\mes\
```

Expected: 显示 SKILL.md, coding-standards.md, patterns.md, debugging.md

- [ ] **Step 7: 提交**

```bash
git add .claude/skills/mes/
git commit -m "feat: add MES skill with coding standards, patterns, and debugging guide"
```

---

## Task 2: 创建 EAP Skill

**Files:**
- Create: `D:\cx\.claude\skills\eap\SKILL.md`
- Create: `D:\cx\.claude\skills\eap\coding-standards.md`
- Create: `D:\cx\.claude\skills\eap\patterns.md`
- Create: `D:\cx\.claude\skills\eap\debugging.md`
- Create: `D:\cx\.claude\skills\eap\secs-gem-reference.md`

- [ ] **Step 1: 创建 EAP Skill 目录**

```bash
mkdir -p D:\cx\.claude\skills\eap
```

- [ ] **Step 2: 创建 SKILL.md**

```markdown
# EAP (设备自动化) 专用技能

> **系统:** Equipment Automation Program
> **技术栈:** VB.NET
> **项目规模:** 上百项目，各 ~10 万行
> **协议:** SECS/GEM
> **更新:** 2025-03-22

---

## 技能概述

本技能提供 EAP 系统的开发和维护指导，基于 SECS/GEM 协议与半导体设备通信。

---

## 核心知识

### 系统特点

- **SECS/GEM 通信** - 与设备进行标准协议通信
- **设备状态管理** - 6 种状态机管理
- **事件处理** - S6F11 事件报告处理
- **命令执行** - S2F41 控制命令下发

### 关键组件

| 组件 | 说明 |
|------|------|
| SECSCommunicator | SECS/GEM 协议通信 |
| EventHandler | 设备事件处理 |
| StateManager | 设备状态管理 |
| CommandExecutor | 命令执行 |

---

## 使用场景

### 何时使用本技能

- 开发新设备 EAP 程序
- 添加设备通信功能
- 调试设备通信问题
- 修改设备状态机

### 相关技能

- `.claude/skills/mes` - MES 系统
- `.claude/skills/vbnet` - VB.NET 通用知识
- `.claude/docs/knowledge/mes-eap-technical-knowledge.md` - 技术知识库

---

## 快速参考

### SECS/GEM 消息

| 消息 | 功能 |
|------|------|
| S1F13/S1F14 | 建立通信 |
| S1F15/S1F17 | 在线请求/数据 |
| S6F11/S6F12 | 事件报告 |
| S2F41/S2F42 | 控制命令 |
| S5F1/S5F2 | 警报上报 |

### 设备状态

```
DISABLED → NOT_CONNECTED → COMMUNICATING → ONLINE
```

---

## 详细文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [调试指南](debugging.md)
- [SECS/GEM 参考](secs-gem-reference.md)
```

- [ ] **Step 3: 创建 coding-standards.md**

```markdown
# EAP 编码规范

> **系统:** Equipment Automation Program
> **语言:** VB.NET
> **更新:** 2025-03-22

---

## 核心原则

### 1. Option Strict On

```vb
' ✅ 正确 - 文件顶部必须声明
Option Strict On
Option Explicit On

Public Class DeviceCommunicator
    ' 编译时类型检查
End Class
```

### 2. 命名约定

**匈牙利命名法（项目现有风格）：**

```vb
' ✅ 正确
Dim strDeviceId As String
Dim intRetryCount As Integer
Dim objCommunicator As Object
Dim blnIsOnline As Boolean

' 控件命名
Dim btnConnect As Button
Dim txtDeviceId As TextBox
Dim lblStatus As Label
```

**类命名：**

```vb
' PascalCase
Public Class SECSCommunicator
End Class

Public Class EventHandler
End Class
```

**方法命名：**

```vb
' PascalCase
Public Function EstablishConnection() As Boolean
End Function

Public Sub ProcessEvent(ByVal eventData As EventData)
End Sub
```

### 3. 错误处理

```vb
' ✅ 正确 - 使用 Try Catch
Public Function SendMessage(ByVal msg As SECSMessage) As Boolean
    Try
        communicator.Send(msg)
        Return True
    Catch ex As TimeoutException
        LogError("Send timeout: " & ex.Message)
        Return False
    Catch ex As Exception
        LogError("Send failed: " & ex.Message)
        Throw
    End Try
End Function

' ❌ 错误 - 避免 On Error Resume Next
Public Function SendMessage(ByVal msg As SECSMessage) As Boolean
    On Error Resume Next  ' 不要使用！
    communicator.Send(msg)
    Return Err.Number = 0
End Function
```

### 4. 事件处理

```vb
' ✅ 正确 - 使用 Handles
Public Class MainForm
    Private Sub btnConnect_Click(ByVal sender As Object,
                                ByVal e As EventArgs) _
                            Handles btnConnect.Click
        ConnectToDevice()
    End Sub
End Class

' ✅ 正确 - 使用 AddHandler 动态绑定
Public Sub RegisterEventHandler()
    AddHandler communicator.DataReceived,
        AddressOf OnDataReceived
End Sub

Private Sub OnDataReceived(ByVal sender As Object,
                          ByVal e As DataEventArgs)
    ProcessData(e.Data)
End Sub
```

---

## 文件结构

### 文件长度限制

| 文件类型 | 最大行数 |
|---------|---------|
| .vb | 1000 行 |

### 函数长度限制

- 单函数/方法不超过 **100 行**
- 复杂逻辑拆分为子过程

---

## 代码组织

### Region 组织

```vb
Public Class DeviceCommunicator

#Region "成员变量"
    Private strDeviceId As String
    Private objStateManager As StateManager
#End Region

#Region "构造函数"
    Public Sub New(ByVal deviceId As String)
        strDeviceId = deviceId
    End Sub
#End Region

#Region "公共方法"
    Public Function Connect() As Boolean
        ' ...
    End Function
#End Region

#Region "私有方法"
    Private Sub LogMessage(ByVal msg As String)
        ' ...
    End Sub
#End Region

End Class
```

---

## 注释规范

### 类注释

```vb
''' <summary>
''' 设备通信器
''' </summary>
''' <remarks>
''' 负责与半导体设备的 SECS/GEM 通信
''' 支持超时重试和状态管理
''' </remarks>
Public Class SECSCommunicator
    ' ...
End Class
```

### 方法注释

```vb
''' <summary>
''' 建立设备通信连接
''' </summary>
''' <param name="deviceId">设备 ID</param>
''' <returns>True 表示成功，False 表示失败</returns>
''' <exception cref="TimeoutException">通信超时</exception>
Public Function EstablishConnection(ByVal deviceId As String) As Boolean
    ' ...
End Function
```

---

## SECS/GEM 通信规范

### 超时设置

```vb
' ✅ 正确 - 使用常量定义超时
Public Class SECSConstants
    Public Const T1_TIMEOUT As Integer = 5000  ' 5秒 - 通信建立
    Public Const T2_TIMEOUT As Integer = 3000  ' 3秒 - 在线请求
    Public Const T3_TIMEOUT As Integer = 10000 ' 10秒 - 控制命令
    Public Const T4_TIMEOUT As Integer = 60000 ' 60秒 - 数据收集

    Public Const MAX_RETRY_T1 As Integer = 3
    Public Const MAX_RETRY_T2 As Integer = 5
End Class
```

### 消息发送

```vb
' ✅ 正确 - 带重试的消息发送
Public Function SendMessageWithRetry(ByVal msg As SECSMessage,
                                     ByVal timeout As Integer,
                                     ByVal maxRetry As Integer) As SECSMessage
    Dim intRetry As Integer = 0

    Do While intRetry < maxRetry
        Try
            Dim response = SendMessage(msg, timeout)
            If response IsNot Nothing Then
                Return response
            End If
        Catch ex As TimeoutException
            LogWarning("Send timeout, retry " & intRetry + 1)
        End Try
        intRetry += 1
        Threading.Thread.Sleep(timeout)
    Loop

    Return Nothing
End Function
```

---

## 性能考虑

### 避免不必要的类型转换

```vb
' ✅ 正确 - 使用正确类型
Dim intCount As Integer = 100

' ❌ 错误 - 不必要的转换
Dim intCount As Integer = CInt("100")
```

### 使用 StringBuilder

```vb
' ✅ 正确 - 大量字符串拼接
Dim sb As New StringBuilder()
For Each item In items
    sb.AppendLine(item.ToString())
Next
Dim result As String = sb.ToString()

' ❌ 错误 - 低效的字符串拼接
Dim result As String = ""
For Each item In items
    result &= item.ToString() & vbCrLf
Next
```

---

## 相关文档

- [代码模式](patterns.md)
- [调试指南](debugging.md)
- [SECS/GEM 参考](secs-gem-reference.md)
```

- [ ] **Step 4: 创建 patterns.md**

```markdown
# EAP 代码模式

> **系统:** Equipment Automation Program
> **语言:** VB.NET
> **更新:** 2025-03-22

---

## 设备握手模式

### S1F13/S1F14 握手

```vb
Public Class DeviceHandshake

    Public Function EstablishCommunication() As Boolean
        ' 发送 S1F13
        Dim s1f13 As New SECSMessage(1, 13)
        s1f13.AddItem("SESSIONID", 1)

        ' 等待 S1F14
        Dim s1f14 As SECSMessage = SendMessageWithRetry(
            s1f13,
            SECSConstants.T1_TIMEOUT,
            SECSConstants.MAX_RETRY_T1
        )

        If s1f14 IsNot Nothing AndAlso s1f14.Function = 14 Then
            Return GoOnline()
        End If

        Return False
    End Function

    Private Function GoOnline() As Boolean
        ' 发送 S1F15
        Dim s1f15 As New SECSMessage(1, 15)
        s1f15.AddItem("ONLINE", True)

        ' 等待 S1F17
        Dim s1f17 As SECSMessage = SendMessageWithRetry(
            s1f15,
            SECSConstants.T2_TIMEOUT,
            SECSConstants.MAX_RETRY_T2
        )

        If s1f17 IsNot Nothing AndAlso s1f17.Function = 17 Then
            objStateManager.SetState(DeviceState.ONLINE)
            Return True
        End If

        Return False
    End Function

End Class
```

---

## 状态机模式

### 设备状态管理

```vb
Public Enum DeviceState
    DISABLED           ' 禁用控制
    NOT_CONNECTED      ' 未连接
    ATTEMPTING         ' 尝试连接中
    COMMUNICATING      ' 通信中
    ONLINE             ' 在线
    HOST_OFFLINE       ' 主机离线
End Enum

Public Class StateManager

    Private objCurrentState As DeviceState = DeviceState.DISABLED

    Public Function CanTransitionTo(ByVal newState As DeviceState) As Boolean
        Select Case objCurrentState
            Case DeviceState.DISABLED
                Return newState = DeviceState.NOT_CONNECTED

            Case DeviceState.NOT_CONNECTED
                Return newState = DeviceState.ATTEMPTING OrElse
                       newState = DeviceState.DISABLED

            Case DeviceState.ATTEMPTING
                Return newState = DeviceState.COMMUNICATING OrElse
                       newState = DeviceState.NOT_CONNECTED

            Case DeviceState.COMMUNICATING
                Return newState = DeviceState.ONLINE OrElse
                       newState = DeviceState.NOT_CONNECTED

            Case DeviceState.ONLINE
                Return newState = DeviceState.COMMUNICATING OrElse
                       newState = DeviceState.HOST_OFFLINE OrElse
                       newState = DeviceState.DISABLED

            Case Else
                Return False
        End Select
    End Function

    Public Sub SetState(ByVal newState As DeviceState)
        If CanTransitionTo(newState) Then
            Dim oldState = objCurrentState
            objCurrentState = newState
            OnStateChanged(oldState, newState)
        Else
            Throw New InvalidOperationException(
                "Cannot transition from " & objCurrentState &
                " to " & newState
            )
        End If
    End Sub

    Public Event StateChanged(ByVal oldState As DeviceState,
                             ByVal newState As DeviceState)

    Protected Sub OnStateChanged(ByVal oldState As DeviceState,
                                ByVal newState As DeviceState)
        RaiseEvent StateChanged(oldState, newState)
    End Sub

End Class
```

---

## 事件处理模式

### S6F11 事件报告处理

```vb
Public Class EventHandler

    Public Sub HandleEventReport(ByVal s6f11 As SECSMessage)
        ' 解析事件报告
        Dim eventId As Integer = s6f11.GetItem("CEID").GetValue()
        Dim reportData As Dictionary(Of String, Object) =
            ParseEventData(s6f11)

        ' 根据事件 ID 分发
        Select Case eventId
            Case 1   ' Power On
                HandlePowerOn(reportData)

            Case 10  ' Process Start
                HandleProcessStart(reportData)

            Case 11  ' Process Complete
                HandleProcessComplete(reportData)

            Case 50  ' Alarm Occurred
                HandleAlarm(reportData)

            Case Else
                LogWarning("Unknown event ID: " & eventId)
        End Select

        ' 发送 S6F12 确认
        SendEventAck(s6f11)
    End Sub

    Private Sub HandleAlarm(ByVal data As Dictionary(Of String, Object))
        Dim alarmCode As Integer = data("ALID")
        Dim alarmText As String = data("ALTX")

        Select Case alarmCode
            Case 1001  ' 通信失败
                HandleCommFailure(alarmText)

            Case 2001  ' 工艺异常
                HandleProcessError(alarmText)

            Case Else
                LogAlarm("AL" & alarmCode & ": " & alarmText)
        End Select
    End Sub

End Class
```

---

## 命令执行模式

### S2F41 控制命令

```vb
Public Class CommandExecutor

    Public Function SendCommand(ByVal commandName As String,
                               ByVal parameters As Dictionary(Of String, Object)) As Boolean
        ' 构造 S2F41 消息
        Dim s2f41 As New SECSMessage(2, 41)
        s2f41.AddItem("OCENAME", commandName)

        ' 添加参数
        For Each param In parameters
            s2f41.AddItem(param.Key, param.Value)
        Next

        ' 发送命令
        Dim s2f42 As SECSMessage = SendMessageWithRetry(
            s2f41,
            SECSConstants.T3_TIMEOUT,
            1  ' T3 不重试
        )

        If s2f42 IsNot Nothing AndAlso s2f42.Function = 42 Then
            Dim ackCode As Integer = s2f42.GetItem("ACKC5").GetValue()
            Return ackCode = 0  ' 0 = OK
        End If

        Return False
    End Function

    ''' <summary>
    ''' 启动设备
    ''' </summary>
    Public Function StartEquipment() As Boolean
        Dim params As New Dictionary(Of String, Object)
        params.Add("PROCESS_ID", strCurrentProcessId)
        Return SendCommand("START", params)
    End Function

    ''' <summary>
    ''' 暂停设备
    ''' </summary>
    Public Function PauseEquipment() As Boolean
        Return SendCommand("PAUSE", New Dictionary(Of String, Object))
    End Function

    ''' <summary>
    ''' 停止设备
    ''' </summary>
    Public Function StopEquipment() As Boolean
        Return SendCommand("STOP", New Dictionary(Of String, Object))
    End Function

End Class
```

---

## 数据收集模式

### Trace 数据收集

```vb
Public Class DataCollector

    Public Sub RequestTraceData(ByVal eventId As Integer)
        ' 发送 S6F15 请求事件数据
        Dim s6f15 As New SECSMessage(6, 15)
        s6f15.AddItem("CEID", eventId)
        s6f15.AddItem("DATAID", 0)

        SendMessage(s6f15, SECSConstants.T4_TIMEOUT)
    End Sub

    Public Sub HandleTraceData(ByVal s6f23 As SECSMessage)
        ' 解析 S6F23 Trace 数据
        Dim traceData As List(Of Dictionary(Of String, Object)) =
            ParseTraceData(s6f23)

        ' 保存到数据库
        For Each data In traceData
            SaveTraceData(data)
        Next
    End Sub

    Private Function ParseTraceData(ByVal msg As SECSMessage) _
        As List(Of Dictionary(Of String, Object))

        Dim result As New List(Of Dictionary(Of String, Object)()

        ' 获取变量列表
        Dim varList As List(Of Object) = msg.GetItem("V").GetList()

        For Each var In varList
            Dim rowData As New Dictionary(Of String, Object)()
            ' 解析变量名和值
            rowData.Add("NAME", var("NAME"))
            rowData.Add("VALUE", var("VALUE"))
            result.Add(rowData)
        Next

        Return result
    End Function

End Class
```

---

## 设备模板模式

### 添加新设备模板

```vb
' === 设备配置常量 ===
Public Class EquipmentConfig
    Public Const EQUIPMENT_ID As String = "EQxxx"      ' [必改] 设备ID
    Public Const EQUIPMENT_TYPE As String = "GROWTH"   ' [必改] 设备类型
    Public Const IP_ADDRESS As String = "192.168.1.xxx" ' [必改] IP地址
    Public Const PORT As Integer = 5000                ' [必改] 端口
End Class

' === 设备特定事件处理 ===
Private Sub HandleEquipmentSpecificEvent(ByVal eventId As Integer,
                                         ByVal data As Dictionary(Of String, Object))
    Select Case eventId
        Case 100  ' 设备特定事件
            ' [可选] 根据需要修改
        Case Else
            ' [禁止] 不要修改通用处理
            MyBase.HandleEvent(eventId, data)
    End Select
End Sub

' === 设备特定命令 ===
Public Function SendEquipmentCommand(ByVal cmd As String) As Boolean
    ' [可选] 根据需要添加设备特定命令
    Return SendCommand(cmd, New Dictionary(Of String, Object))
End Function
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [调试指南](debugging.md)
- [SECS/GEM 参考](secs-gem-reference.md)
```

- [ ] **Step 5: 创建 debugging.md**

```markdown
# EAP 调试指南

> **系统:** Equipment Automation Program
> **语言:** VB.NET
> **协议:** SECS/GEM
> **更新:** 2025-03-22

---

## 常见问题

### 1. 通信建立失败

**症状:**
- S1F13 发送后没有收到 S1F14
- 设备无法上线

**排查步骤:**

```vb
' 1. 检查网络连接
Dim pingResult As Boolean = PingDevice(EquipmentConfig.IP_ADDRESS)
If Not pingResult Then
    LogError("Cannot ping device at " & EquipmentConfig.IP_ADDRESS)
    Return False
End If

' 2. 检查端口
Dim portOpen As Boolean = CheckPort(EquipmentConfig.IP_ADDRESS,
                                     EquipmentConfig.PORT)
If Not portOpen Then
    LogError("Port " & EquipmentConfig.PORT & " is not open")
    Return False
End If

' 3. 检查超时设置
LogInfo("T1 timeout: " & SECSConstants.T1_TIMEOUT & "ms")
```

**常见原因:**

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| T1 超时 | 设备未启动 | 启动设备 |
| T1 超时 | IP 地址错误 | 检查配置 |
| T1 超时 | 端口不正确 | 检查端口配置 |
| T1 超时 | 网络不通 | 检查网络连接 |

### 2. 在线请求失败

**症状:**
- S1F15 发送后没有收到 S1F17
- 设备停留在 COMMUNICATING 状态

**排查步骤:**

```vb
' 检查设备状态
If objStateManager.CurrentState <> DeviceState.COMMUNICATING Then
    LogError("Device not in COMMUNICATING state")
    Return False
End If

' 检查 S1F15 消息格式
Dim s1f15 As New SECSMessage(1, 15)
s1f15.AddItem("ONLINE", True)
LogInfo("S1F15 message: " & s1f15.ToString())
```

### 3. 事件未上报

**症状:**
- 设备操作后没有收到 S6F11
- MES 未收到事件通知

**排查步骤:**

```vb
' 1. 检查事件是否使能
Private Function IsEventEnabled(ByVal eventId As Integer) As Boolean
    ' 发送 S1F3 查询使能状态
    Dim s1f3 As New SECSMessage(1, 3)
    s1f3.AddItem("CEID", eventId)

    Dim s1f4 As SECSMessage = SendMessage(s1f3, 5000)
    If s1f4 IsNot Nothing Then
        Return s1f4.GetItem("ENABLED").GetValue()
    End If
    Return False
End Function

' 2. 使能事件
Public Sub EnableEvent(ByVal eventId As Integer)
    Dim s1f1 As New SECSMessage(1, 1)
    s1f1.AddItem("CEID", eventId)
    s1f1.AddItem("ENABLED", True)
    SendMessage(s1f1, 5000)
End Sub
```

### 4. 命令执行超时

**症状:**
- S2F41 发送后 T3 超时
- 设备无响应

**排查步骤:**

```vb
' 1. 检查设备状态
If objStateManager.CurrentState <> DeviceState.ONLINE Then
    LogError("Device not in ONLINE state")
    Return False
End If

' 2. 检查命令格式
LogInfo("Sending S2F41: " & commandName)
For Each param In parameters
    LogInfo("  " & param.Key & " = " & param.Value)
Next

' 3. 增加超时时间
If commandName = "LONG_RUNNING_CMD" Then
    ' 使用更长超时
    Return SendMessage(s2f41, 30000)  ' 30秒
End If
```

---

## 调试工具

### 日志记录

```vb
' 消息日志
Public Sub LogSECSMessage(ByVal direction As String,
                         ByVal msg As SECSMessage)
    Dim log As String = String.Format(
        "{0:yyyy-MM-dd HH:mm:ss.fff} [{1}] S{2}F{3} {4}",
        DateTime.Now,
        direction,
        msg.Stream,
        msg.Function,
        msg.ToString()
    )
    WriteLog(log)
End Sub

' 状态变化日志
Public Sub LogStateChange(ByVal oldState As DeviceState,
                          ByVal newState As DeviceState)
    Dim log As String = String.Format(
        "{0:yyyy-MM-dd HH:mm:ss} State: {1} -> {2}",
        DateTime.Now,
        oldState,
        newState
    )
    WriteLog(log)
End Sub

' 超时日志
Public Sub LogTimeout(ByVal msg As String,
                      ByVal timeout As Integer)
    Dim log As String = String.Format(
        "{0:yyyy-MM-dd HH:mm:ss} TIMEOUT: {1} after {2}ms",
        DateTime.Now,
        msg,
        timeout
    )
    WriteLog(log)
End Sub
```

### 网络抓包

```bash
# 使用 Wireshark 抓包
# 过滤条件: tcp.port == 5000

# 或使用 tcpdump
tcpdump -i any -s 0 -w capture.pcap host 192.168.1.100 and port 5000
```

---

## 常用调试代码

### 测试连接

```vb
Public Function TestConnection() As Boolean
    LogInfo("Testing connection to " & EquipmentConfig.IP_ADDRESS)

    ' 1. Ping 测试
    Dim ping As New System.Net.NetworkInformation.Ping()
    Dim reply = ping.Send(EquipmentConfig.IP_ADDRESS, 5000)
    If reply.Status <> IPStatus.Success Then
        LogError("Ping failed: " & reply.Status)
        Return False
    End If

    ' 2. 端口测试
    Dim tcp As New System.Net.Sockets.TcpClient()
    Try
        tcp.Connect(EquipmentConfig.IP_ADDRESS, EquipmentConfig.PORT)
        LogInfo("Port " & EquipmentConfig.PORT & " is open")
        tcp.Close()
        Return True
    Catch ex As Exception
        LogError("Port test failed: " & ex.Message)
        Return False
    End Try
End Function
```

### 诊断信息

```vb
Public Sub PrintDiagnostics()
    LogInfo("=== Device Diagnostics ===")
    LogInfo("Equipment ID: " & EquipmentConfig.EQUIPMENT_ID)
    LogInfo("Equipment Type: " & EquipmentConfig.EQUIPMENT_TYPE)
    LogInfo("IP Address: " & EquipmentConfig.IP_ADDRESS)
    LogInfo("Port: " & EquipmentConfig.PORT)
    LogInfo("Current State: " & objStateManager.CurrentState)
    LogInfo("Communication Status: " & objCommunicator.IsConnected)
    LogInfo("========================")
End Sub
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [SECS/GEM 参考](secs-gem-reference.md)
```

- [ ] **Step 6: 创建 secs-gem-reference.md**

```markdown
# SECS/GEM 协议参考

> **标准:** SEMI E4, E5, E30, E37
> **更新:** 2025-03-22

---

## 消息速查表

### 流 1: 设备通信

| 消息 | 名称 | 方向 | 说明 |
|------|------|------|------|
| S1F1 | Event Report Request | H→E | 设置/查询事件报告 |
| S1F2 | Event Report Ack | E→H | 确认 |
| S1F3 | Equipment Constant Request | H→E | 设置/查询设备常量 |
| S1F4 | Equipment Constant Ack | E→H | 确认 |
| S1F11 | Status Variable Request | H→E | 查询状态变量 |
| S1F12 | Status Variable Data | E→H | 状态变量数据 |
| S1F13 | Establish Communication | H→E | 建立通信请求 |
| S1F14 | Establish Comm Ack | E→H | 通信建立确认 |
| S1F15 | Online Request | H→E | 在线请求 |
| S1F17 | Online Data | E→H | 在线数据响应 |

### 流 2: 设备控制

| 消息 | 名称 | 方向 | 说明 |
|------|------|------|------|
| S2F21 | Equipment Constant Request | H→E | 设置设备常量 |
| S2F22 | Equipment Constant Ack | E→H | 确认 |
| S2F23 | Equipment Constant Send | E→H | 发送设备常量 |
| S2F24 | Equipment Constant Ack | H→E | 确认 |
| S2F41 | Host Command Send | H→E | 发送控制命令 |
| S2F42 | Host Command Ack | E→H | 命令执行确认 |

### 流 5: 警报

| 消息 | 名称 | 方向 | 说明 |
|------|------|------|------|
| S5F1 | Alarm Report Send | E→H | 上报警报 |
| S5F2 | Alarm Report Ack | H→E | 警报确认 |
| S5F3 | Enable Alarm Send | E→H | 使能/禁用警报 |
| S5F4 | Enable Alarm Ack | H→E | 确认 |

### 流 6: 数据收集

| 消息 | 名称 | 方向 | 说明 |
|------|------|------|------|
| S6F1 | Trace Data Send | E→H | 发送追踪数据 |
| S6F2 | Trace Data Ack | H→E | 确认 |
| S6F11 | Event Report | E→H | 事件报告 |
| S6F12 | Event Report Ack | H→E | 事件确认 |
| S6F15 | Event Report Request | H→E | 请求事件报告 |
| S6F23 | Trace Data Send | E→H | 发送追踪数据（多条） |

---

## 设备状态机详细说明

### 状态定义

| 状态 | 名称 | 说明 |
|------|------|------|
| 0 | DISABLED | 禁用控制 |
| 1 | NOT_CONNECTED | 未连接 |
| 2 | ATTEMPTING | 尝试连接中 |
| 3 | COMMUNICATING | 通信建立 |
| 4 | ONLINE | 在线，可执行命令 |
| 5 | HOST_OFFLINE | 主机离线 |

### 状态转换

| 当前状态 | 触发条件 | 目标状态 | 消息 |
|---------|---------|---------|------|
| DISABLED | S1F17 (ENABLE) | NOT_CONNECTED | - |
| NOT_CONNECTED | 开始连接 | ATTEMPTING | - |
| ATTEMPTING | S1F13/S1F14 成功 | COMMUNICATING | - |
| ATTEMPTING | 超时 | NOT_CONNECTED | 重试 |
| COMMUNICATING | S1F15/S1F17 成功 | ONLINE | - |
| COMMUNICATING | 通信丢失 | NOT_CONNECTED | - |
| ONLINE | 通信丢失 | HOST_OFFLINE | - |
| 任意状态 | S1F17 (DISABLE) | DISABLED | - |

---

## 常用 CEID (Collection Event ID)

| CEID | 名称 | 说明 |
|------|------|------|
| 1 | Power On | 设备上电 |
| 2 | Power Off | 设备断电 |
| 10 | Process Start | 工艺开始 |
| 11 | Process End | 工艺结束 |
| 12 | Process Pause | 工艺暂停 |
| 20 | Cassette Load | Cassette 装载 |
| 21 | Cassette Unload | Cassette 卸载 |
| 50 | Alarm Occurred | 警报发生 |
| 51 | Alarm Cleared | 警报清除 |
| 100 | Data Available | 数据可用 |

---

## 常用 ALCD (Alarm Code)

| ALCD | 级别 | 名称 | 说明 |
|------|------|------|------|
| 1000 | Critical | Communication Error | 通信错误 |
| 1001 | Critical | Timeout | 超时 |
| 2000 | Major | Process Error | 工艺错误 |
| 2001 | Major | Parameter Error | 参数错误 |
| 3000 | Minor | Warning | 警告 |
| 3001 | Minor | Out of Spec | 超出规格 |

---

## ACKC5 码 (确认码)

| 码 | 名称 | 说明 |
|----|------|------|
| 0 | OK | 命令执行成功 |
| 1 | Wrong format | 消息格式错误 |
| 2 | Invalid command | 无效命令 |
| 3 | Invalid data | 无效数据 |
| 4 | Condition not met | 条件不满足 |
| 5 | Busy | 设备忙 |

---

## 数据格式

### Binary

```
<U1>  - 1 byte unsigned integer
<U2>  - 2 bytes unsigned integer
<U4>  - 4 bytes unsigned integer
<I1>  - 1 byte signed integer
<I2>  - 2 bytes signed integer
<I4>  - 4 bytes signed integer
<F4>  - 4 bytes float
<F8>  - 8 bytes double
<Boolean> - 1 byte boolean
```

### List

```
<L> - List
<L[n]> - List with n elements
```

### String

```
<A> - ASCII string
<J> - JIS string
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [调试指南](debugging.md)
- [技术知识库](.claude/docs/knowledge/mes-eap-technical-knowledge.md)
```

- [ ] **Step 7: 验证文件创建**

```bash
ls -la D:\cx\.claude\skills\eap\
```

Expected: 显示 5 个文件

- [ ] **Step 8: 提交**

```bash
git add .claude/skills/eap/
git commit -m "feat: add EAP skill with SECS/GEM reference and coding standards"
```

---

## Task 3: 创建通用技术栈 Skills (CPP, VBNET, JAVA, VUE)

**Files:**
- Create: `D:\cx\.claude\skills\cpp\SKILL.md`
- Create: `D:\cx\.claude\skills\vbnet\SKILL.md`
- Create: `D:\cx\.claude\skills\java\SKILL.md`
- Create: `D:\cx\.claude\skills\vue\SKILL.md`

- [ ] **Step 1: 创建 C++ Skill**

```bash
mkdir -p D:\cx\.claude\skills\cpp
```

```markdown
# C++ 通用技能

> **更新:** 2025-03-22

## 概述

C++ 通用编程技能，适用于非 MES 的 C++ 项目。

## 核心规范

- 遵循 C++ Core Guidelines
- 使用 C++17 或更高版本
- 智能指针管理内存
- RAII 模式

## 测试

- 使用 Google Test 或 Catch2
- TDD 工作流

## 相关技能

- `.claude/skills/mes` - MES 专用 (优先使用)
- `.claude/skills/cpp` - 本技能 (通用)
```

- [ ] **Step 2: 创建 VB.NET Skill**

```bash
mkdir -p D:\cx\.claude\skills\vbnet
```

```markdown
# VB.NET 通用技能

> **更新:** 2025-03-22

## 概述

VB.NET 通用编程技能，适用于非 EAP 的 VB.NET 项目。

## 核心规范

- Option Strict On
- Option Explicit On
- .NET 编码规范

## 测试

- 使用 MSTest 或 NUnit

## 相关技能

- `.claude/skills/eap` - EAP 专用 (优先使用)
- `.claude/skills/vbnet` - 本技能 (通用)
```

- [ ] **Step 3: 创建 JAVA Skill**

```bash
mkdir -p D:\cx\.claude\skills\java
```

```markdown
# JAVA 通用技能

> **更新:** 2025-03-22

## 概述

JAVA 通用编程技能，适用于 Spring Boot 项目。

## 核心规范

- Java 17 或更高
- Spring Boot 3.x
- RESTful API 设计
- 依赖注入

## 测试

- JUnit 5
- Mockito
- Testcontainers

## 相关技能

- `.claude/skills/java` - 本技能
```

- [ ] **Step 4: 创建 VUE Skill**

```bash
mkdir -p D:\cx\.claude\skills\vue
```

```markdown
# VUE 通用技能

> **更新:** 2025-03-22

## 概述

VUE 通用编程技能，支持 Vue 2 和 Vue 3。

## 核心规范

- Vue 3 Composition API (首选)
- Vue 2 Options API (兼容)
- TypeScript 推荐

## 测试

- Vitest (Vue 3)
- Jest (Vue 2)
- Vue Test Utils

## 相关技能

- `.claude/skills/vue` - 本技能
```

- [ ] **Step 5: 提交**

```bash
git add .claude/skills/cpp/ .claude/skills/vbnet/ .claude/skills/java/ .claude/skills/vue/
git commit -m "feat: add generic tech stack skills (CPP, VBNET, JAVA, VUE)"
```

---

## Task 4-8: Commands 实现 (简化)

由于 Commands 是 Shell 脚本实现，这里创建文档说明而非完整脚本：

**Files:**
- Create: `D:\cx\.claude\docs\command-docs\init-command.md`
- Create: `D:\cx\.claude\docs\command-docs\update-claude-command.md`
- Create: `D:\cx\.claude\docs\command-docs\create-skill-command.md`
- Create: `D:\cx\.claude\docs\command-docs\learn-command.md`
- Create: `D:\cx\.claude\docs\command-docs\doc-command.md`
- Create: `D:\cx\.claude\docs\command-docs\diagram-command.md`

- [ ] **Step 1: 创建命令文档目录**

```bash
mkdir -p D:\cx\.claude\docs\command-docs
```

- [ ] **Step 2: 创建各命令文档**

```markdown
# /init 命令说明

## 功能
初始化项目 CLAUDE.md

## 用法
/init

## 输出
生成项目级 CLAUDE.md，包含 TODO 标记待补充内容
```

```markdown
# /update-claude 命令说明

## 功能
增量更新项目 CLAUDE.md

## 用法
/update-claude

## 输出
更新函数列表、数据操作等自动生成内容
```

```markdown
# /create-skill 命令说明

## 功能
深入分析项目代码，生成项目 Skill

## 用法
/create-skill --scope all --depth standard

## 选项
- --scope: all | core | module
- --depth: quick | standard | deep

## 输出
.claude/skills/<project-name>/ 目录
```

```markdown
# /learn 命令说明

## 功能
记录 AI 编码经验

## 用法
/learn --type error "C++ 智能指针循环引用导致内存泄漏"

## 类型
- error: 编码错误
- pattern: 代码模式
- performance: 性能优化
- anti-pattern: 反模式
- convention: 编码规范
- debug: 调试经验

## 输出
.claude/lessons.md
```

```markdown
# /doc 命令说明

## 功能
生成项目文档

## 用法
/doc --requirements
/doc --files
/doc --diagram overview

## 输出
docs/ 目录下的文档
```

```markdown
# /diagram 命令说明

## 功能
生成 PUML 图表

## 用法
/diagram                    # 交互式
/diagram flow "流程名称"    # 流程图
/diagram sequence "时序名称" # 时序图
/diagram suggest             # 推荐图表

## 输出
docs/diagrams/ 下的 .puml 文件
```

- [ ] **Step 3: 创建占位命令脚本**

```bash
# 创建占位脚本
touch D:\cx\.claude\commands\init.sh
touch D:\cx\.claude\commands\update-claude.sh
touch D:\cx\.claude\commands\create-skill.sh
touch D:\cx\.claude\commands\learn.sh
touch D:\cx\.claude\commands\doc.sh
touch D:\cx\.claude\commands\diagram.sh
touch D:\cx\.claude\commands\context.sh
touch D:\cx\.claude\commands\status.sh
```

- [ ] **Step 4: 提交**

```bash
git add .claude/docs/command-docs/ .claude/commands/
git commit -m "feat: add command documentation and placeholder scripts"
```

---

## 完成 Phase 2

### 更新 planning 文件

- [ ] **更新 task_plan.md**

```bash
# 标记 Phase 2 完成
```

- [ ] **更新 progress.md**

```bash
# 记录 Phase 2 完成情况
```

---

**计划版本:** v1.0
**创建日期:** 2025-03-22
**预计耗时:** 6-8 小时

**下一步:** Phase 3 - Hooks 和文档模板
