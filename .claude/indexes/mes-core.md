# MES 核心文件索引

> **系统:** SiView MES
> **技术栈:** C++
> **更新:** {{UPDATE_DATE}}

---

## 核心模块

### 执行引擎
```
src/core/executor/Executor.cpp
src/core/executor/Executor.h
```
**功能:** 事件驱动的多线程执行引擎

### 设备通信
```
src/communication/DeviceCommunicator.cpp
src/communication/DeviceCommunicator.h
src/communication/SECSMessage.cpp
```
**功能:** 与 EAP 系统通信

### 数据访问
```
src/database/MESDataAccess.cpp
src/database/MESDataAccess.h
src/database/ConnectionPool.cpp
```
**功能:** 数据库操作

---

## 设备适配器

### 设备类型映射
```
src/adapters/equipment/*/Adapter.cpp
src/adapters/equipment/*/Adapter.h
```

**常见设备:**
- GROWTH - 生长炉
- ETCH - 刻蚀机
- PHOTOLITHOGRAPHY - 光刻机
- DIFFUSION - 扩散炉

---

## 关键配置

```
config/mes.conf                    # MES 主配置
config/equipment-map.json          # 设备映射
config/database-connection.json    # 数据库连接
config/logging.conf                # 日志配置
```

---

## 业务逻辑插件

```
plugins/recipe/RecipeManager.cpp
plugins/tracking/TrackingManager.cpp
plugins/alarm/AlarmManager.cpp
```

---

## TODO: 实际文件路径

请根据实际 MES 系统结构更新以下内容:

1. 核心模块实际路径
2. 设备适配器列表
3. 配置文件位置
4. 关键类和函数列表
