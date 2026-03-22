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

- [C++ Core Guidelines 本地参考](../docs/references/cpp-core-guidelines.md)
- [MES 代码模式](patterns.md)
- [调试指南](debugging.md)
