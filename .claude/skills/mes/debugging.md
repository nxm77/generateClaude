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
