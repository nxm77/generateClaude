# C++ Core Guidelines 本地参考

> **标准:** C++ Core Guidelines
> **更新:** 2025-03-22

---

## 核心原则

### 1. 内存管理

**使用智能指针：**

```cpp
// ✅ 使用 unique_ptr 拥有独占所有权
std::unique_ptr<Device> device = std::make_unique<Device>();

// ✅ 使用 shared_ptr 共享所有权
std::shared_ptr<Communicator> comm = std::make_shared<Communicator>();

// ✅ 使用 weak_ptr 打破循环引用
std::weak_ptr<Parent> parent weak_parent_;
```

**RAII 模式：**

```cpp
// 资源获取即初始化
class DatabaseConnection {
public:
    DatabaseConnection(const std::string& connStr)
        : conn_(connStr) {}

    ~DatabaseConnection() {
        // 自动关闭连接
    }

private:
    pqxx::connection conn_;
};
```

### 2. 类型安全

```cpp
// ✅ 使用 auto
auto deviceId = getDeviceId();  // 推导类型
auto events = std::vector<Event>{};

// ✅ 使用 constexpr
constexpr int MAX_RETRY = 3;
constexpr double PI = 3.1415926;

// ✅ 使用 enum class 代替 enum
enum class DeviceState {
    DISABLED,
    ONLINE,
    ERROR
};
```

### 3. 参数传递

```cpp
// ✅ 传递只读对象：使用 const T&
void processEvent(const Event& event);

// ✅ 传递小型值：使用值
void setCount(int count);

// ✅ 传递可修改对象：使用 T*
void modifyData(Data* data);

// ✅ 转移所有权：使用 std::move
void addEvent(std::unique_ptr<Event> event);
```

---

## 编码规范

### 文件长度

| 文件类型 | 最大行数 |
|---------|---------|
| .cpp | 1000 行 |
| .h | 500 行 |

### 函数长度

- 单函数不超过 100 行
- 圈复杂度不超过 10

### 命名约定

```cpp
// 类: PascalCase
class DeviceCommunicator { };

// 函数: camelCase
void establishConnection();

// 变量: camelCase，成员变量加后缀 _
int deviceId_;
std::string connectionString_;

// 常量: UPPER_CASE
const int MAX_RETRY_COUNT = 3;
```

---

相关文档:
- [C++ Skill](../../skills/cpp/SKILL.md)
- [MES 编码规范](../../skills/mes/coding-standards.md)
