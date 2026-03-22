# MES 代码模式

> **系统:** SiView MES
> **语言:** C++
> **更新:** 2025-03-22

---

## CORBA 分布式对象模式

### IDL 接口定义

```idl
// equipment.idl
module MES {
  module Equipment {
    interface DeviceController {
      string getDeviceId();
      boolean goOnline();
      boolean goOffline();
      void sendCommand(in string command);
      void registerListener(in DeviceListener listener);
    };

    interface DeviceListener {
      void onEvent(in string deviceId, in long eventType, in string eventData);
      void onAlarm(in string deviceId, in long alarmCode, in string message);
    };
  };
};
```

### CORBA 服务端实现

```cpp
#include <CORBA.h>
#include "equipment.hh"

using namespace MES::Equipment;

// 设备控制器服务实现
class DeviceControllerImpl : public virtual POA_MES::Equipment::DeviceController {
public:
    DeviceControllerImpl(const std::string& deviceId)
        : deviceId_(deviceId), online_(false) {}

    // CORBA 接口实现
    char* getDeviceId() override {
        return CORBA::string_dup(deviceId_.c_str());
    }

    CORBA::Boolean goOnline() override {
        // 设备上线逻辑
        online_ = true;
        notifyListeners(EventType::ONLINE, "Device online");
        return true;
    }

    CORBA::Boolean goOffline() override {
        // 设备离线逻辑
        online_ = false;
        notifyListeners(EventType::OFFLINE, "Device offline");
        return true;
    }

    void sendCommand(const char* command) override {
        if (!online_) {
            throw CORBA::NO_RESOURCES();
        }
        // 发送命令到设备
        executeCommand(command);
    }

    void registerListener(DeviceListener_ptr listener) override {
        std::lock_guard<std::mutex> lock(mutex_);
        listeners_.push_back(DeviceListener::_duplicate(listener));
    }

private:
    void notifyListeners(long eventType, const std::string& data) {
        for (auto& listener : listeners_) {
            try {
                listener->onEvent(deviceId_.c_str(), eventType, data.c_str());
            } catch (const CORBA::Exception& e) {
                // 处理通信异常
            }
        }
    }

    std::string deviceId_;
    bool online_;
    std::vector<DeviceListener_var> listeners_;
    std::mutex mutex_;
};
```

### CORBA 客户端调用

```cpp
#include <CORBA.h>
#include "equipment.hh"

class MESClient {
public:
    MESClient(CORBA::ORB_ptr orb, const std::string& deviceId)
        : orb_(CORBA::ORB::_duplicate(orb)) {

        // 通过命名服务获取对象引用
        COSNaming::NamingContext_var rootContext = getRootContext();

        // 构造名称
        COSNaming::Name name;
        name.length(1);
        name[0].id = CORBA::string_dup(deviceId.c_str());

        // 解析对象引用
        CORBA::Object_var obj = rootContext->resolve(name);
        controller_ = MES::Equipment::DeviceController::_narrow(obj);

        if (CORBA::is_nil(controller_)) {
            throw std::runtime_error("Cannot narrow device controller");
        }
    }

    void sendCommand(const std::string& cmd) {
        try {
            controller_->sendCommand(cmd.c_str());
        } catch (const CORBA::COMM_FAILURE& e) {
            // 通信失败处理
            throw std::runtime_error("Communication failure");
        } catch (const CORBA::NO_RESOURCES& e) {
            // 设备离线
            throw std::runtime_error("Device is offline");
        }
    }

    std::string getDeviceId() {
        CORBA::String_var id = controller_->getDeviceId();
        return std::string(id);
    }

private:
    COSNaming::NamingContext_var getRootContext() {
        CORBA::Object_var obj = orb_->resolve_initial_references("NameService");
        return COSNaming::NamingContext::_narrow(obj);
    }

    CORBA::ORB_var orb_;
    MES::Equipment::DeviceController_var controller_;
};
```

### ORB 初始化与注册

```cpp
class CORBAServer {
public:
    void initialize(int argc, char* argv[]) {
        // 初始化 ORB
        orb_ = CORBA::ORB_init(argc, argv);

        // 获取根 POA (Portable Object Adapter)
        CORBA::Object_var obj = orb_->resolve_initial_references("RootPOA");
        poa_ = PortableServer::POA::_narrow(obj);

        // 获取 POA 管理器
        poaManager_ = poa_->the_POAManager();
        poaManager_->activate();
    }

    void registerDevice(const std::string& deviceId, DeviceControllerImpl* servant) {
        // 激活服务对象
        PortableServer::ObjectId_var objectId = poa_->activate_object(servant);

        // 获取对象引用
        CORBA::Object_var ref = poa_->id_to_reference(objectId);

        // 绑定到命名服务
        COSNaming::NamingContext_var rootContext = getRootContext();

        COSNaming::Name name;
        name.length(1);
        name[0].id = CORBA::string_dup(deviceId.c_str());

        rootContext->rebind(name, ref);
    }

    void run() {
        orb_->run();
    }

    void shutdown() {
        orb_->shutdown(true);
    }

private:
    COSNaming::NamingContext_var getRootContext() {
        CORBA::Object_var obj = orb_->resolve_initial_references("NameService");
        return COSNaming::NamingContext::_narrow(obj);
    }

    CORBA::ORB_var orb_;
    PortableServer::POA_var poa_;
    PortableServer::POAManager_var poaManager_;
};

// 使用示例
int main(int argc, char* argv[]) {
    CORBAServer server;
    server.initialize(argc, argv);

    // 创建并注册设备控制器
    auto controller = std::make_unique<DeviceControllerImpl>("EQP001");
    server.registerDevice("EQP001", controller.get());

    // 启动 ORB 事件循环
    server.run();

    return 0;
}
```

### CORBA 异常处理模式

```cpp
class CORBAErrorHandler {
public:
    static void handleException(const CORBA::Exception& ex) {
        try {
            // 尝试重新抛出以获取具体类型
            ex._raise();
        }
        catch (const CORBA::COMM_FAILURE& e) {
            LOG_ERROR("CORBA Communication Failure: " << e);
            // 通信失败 - 可能是网络问题或服务端崩溃
            recoverCommunication();
        }
        catch (const CORBA::NO_RESOURCES& e) {
            LOG_ERROR("CORBA No Resources: " << e);
            // 资源不足 - 可能是设备离线或限流
            handleNoResources();
        }
        catch (const CORBA::OBJECT_NOT_EXIST& e) {
            LOG_ERROR("CORBA Object Not Exist: " << e);
            // 对象不存在 - 可能服务未启动
            handleObjectNotExist();
        }
        catch (const CORBA::TRANSIENT& e) {
            LOG_ERROR("CORBA Transient Failure: " << e);
            // 临时性错误 - 可以重试
            retryWithBackoff();
        }
        catch (const CORBA::SystemException& e) {
            LOG_ERROR("CORBA System Exception: " << e);
            // 系统级错误
            handleSystemError();
        }
    }

private:
    static void recoverCommunication() {
        // 重新建立连接逻辑
    }
    static void handleNoResources() {
        // 处理资源不足
    }
    static void handleObjectNotExist() {
        // 处理对象不存在
    }
    static void retryWithBackoff() {
        // 指数退避重试
    }
    static void handleSystemError() {
        // 处理系统错误
    }
};
```

### CORBA 连接管理

```cpp
class CORBAConnectionPool {
public:
    CORBAConnectionPool(CORBA::ORB_ptr orb, size_t poolSize)
        : orb_(CORBA::ORB::_duplicate(orb)), poolSize_(poolSize) {}

    // 从连接池获取对象引用
    template<typename T>
    typename T::_var_type acquire(const std::string& objectName) {
        auto it = cache_.find(objectName);
        if (it != cache_.end()) {
            // 验证对象是否仍然有效
            if (!CORBA::is_nil(it->second)) {
                return T::_narrow(it->second);
            }
        }

        // 重新解析对象
        CORBA::Object_var obj = resolveObject(objectName);
        cache_[objectName] = CORBA::Object::_duplicate(obj);
        return T::_narrow(obj);
    }

    // 释放对象引用
    void release(const std::string& objectName) {
        // 连接池管理逻辑
    }

private:
    CORBA::Object_var resolveObject(const std::string& name) {
        COSNaming::NamingContext_var rootContext = getRootContext();

        COSNaming::Name namingName;
        namingName.length(1);
        namingName[0].id = CORBA::string_dup(name.c_str());

        return rootContext->resolve(namingName);
    }

    COSNaming::NamingContext_var getRootContext() {
        CORBA::Object_var obj = orb_->resolve_initial_references("NameService");
        return COSNaming::NamingContext::_narrow(obj);
    }

    CORBA::ORB_var orb_;
    std::unordered_map<std::string, CORBA::Object_var> cache_;
    size_t poolSize_;
};
```

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
