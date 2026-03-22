# PUML 图表模板

> **用途:** /diagram 命令生成 PUML 的参考模板
> **日期:** 2026-03-22

---

## 1. 流程图模板 (Flowchart)

```plantuml
@startuml [name]

skinparam backgroundColor #FEFEFE
skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
  FontColor #000000
}
skinparam decision {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}
skinparam note {
  BackgroundColor #E8F5E9
  BorderColor #4CAF50
}

start

:[起始步骤];

if (条件判断?) then (是)
  :分支处理 A;
else (否)
  :分支处理 B;
endif

:后续处理;

note right
  注释说明
  可多行
end note

stop

@enduml
```

**示例 - EAP 设备握手流程:**

```plantuml
@startuml eap-handshake

skinparam backgroundColor #FEFEFE
skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

start

:Host 发送 S1F13 (Establish Communication);

note right
  超时 T1: 5秒
  重试 3 次
end note

:设备回复 S1F14 (Ack);

if (通信建立成功?) then (yes)
  :Host 发送 S1F15 (Online Request);
  :设备回复 S1F17 (Online Data);
  :状态 → ONLINE;
  :开始事件报告;
else (no)
  :记录错误日志;
  if (重试次数 < 3?) then (yes)
    :重新发送 S1F13;
  else (no)
    :触发告警;
    stop
  endif
endif

@enduml
```

---

## 2. 时序图模板 (Sequence)

```plantuml
@startuml [name]

skinparam backgroundColor #FEFEFE
skinparam sequence {
  ArrowColor #2196F3
  LifeLineBorderColor #9E9E9E
  ParticipantBackgroundColor #E3F2FD
  ParticipantBorderColor #2196F3
}

actor "用户" as User
participant "前端" as Frontend
participant "后端" as Backend
participant "数据库" as DB

User -> Frontend: 请求
activate Frontend

Frontend -> Backend: API 调用
activate Backend

Backend -> DB: 查询
activate DB
DB --> Backend: 返回数据
deactivate DB

Backend --> Frontend: 响应
deactivate Backend

Frontend --> User: 显示结果
deactivate Frontend

@enduml
```

**示例 - EAP 设备登录时序:**

```plantuml
@startuml equipment-login

skinparam backgroundColor #FEFEFE

participant "Host (EAP)" as Host
participant "SECS Client" as SECS
participant "Equipment" as EQ

Host -> SECS: 发起连接
activate SECS
SECS -> EQ: TCP Connect (HSMS)
EQ --> SECS: Connected

Host -> SECS: S1F13 EstablishComm
SECS -> EQ: S1F13 (Primary)
activate EQ
EQ --> SECS: S1F14 (Secondary)
deactivate EQ
SECS --> Host: 通信建立成功

Host -> SECS: S1F15 Online Request
SECS -> EQ: S1F15 (Primary)
activate EQ
EQ --> SECS: S1F17 Online Data
deactivate EQ
SECS --> Host: 设备在线

deactivate SECS

@enduml
```

---

## 3. 组件图模板 (Component)

```plantuml
@startuml [name]

skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
  FontColor #000000
}
skinparam componentInterface {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}

[组件 A] as CompA
[组件 B] as CompB
[组件 C] as CompC
database "数据库" as DB

CompA --> CompB: 调用
CompB --> CompC: 依赖
CompB --> DB: 存取

interface "接口 I" as I
CompA ..|> I: 实现

@enduml
```

**示例 - MES 系统组件:**

```plantuml
@startuml mes-components

skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

[MES Core] as MES
[EAP Module] as EAP
[Equipment 1] as EQ1
[Equipment 2] as EQ2
database "Oracle DB" as DB

MES --> EAP: 派工指令
EAP --> EQ1: SECS/GEM
EAP --> EQ2: SECS/GEM

MES --> DB: 状态存储
EAP --> DB: 通信日志

note right of EAP
  设备自动化程序
  支持 200+ 设备
end note

@enduml
```

---

## 4. 状态图模板 (State)

```plantuml
@startuml [name]

skinparam state {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

[*] --> State1

State1: 状态描述
State1: 可多行说明

State1 --> State2: 事件1
State2 --> State1: 事件2

State2 --> State3: 事件3
State3 --> [*]: 结束

@enduml
```

**示例 - EAP 设备状态机:**

```plantuml
@startuml equipment-state

skinparam state {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

[*] --> DISABLED

DISABLED: 设备禁用
DISABLED: 不接受命令

DISABLED --> NOT_CONNECTED: ENABLE 设备

NOT_CONNECTED: 未连接
NOT_CONNECTED: 尝试建立通信

NOT_CONNECTED --> CONNECTING: 发起通信
CONNECTING --> ONLINE: 通信成功
CONNECTING --> NOT_CONNECTED: 通信失败 (重试)

ONLINE: 设备在线
ONLINE: 可接受命令

ONLINE --> EXCHANGE_DISABLED: DISABLE 请求
EXCHANGE_DISABLED --> DISABLED: 确认

ONLINE --> NOT_CONNECTED: 连接断开

note right of ONLINE
  正常工作状态
  可发送 S2F41 命令
  接收 S6F11 事件
end note

@enduml
```

---

## 5. 类图模板 (Class)

```plantuml
@startuml [name]

skinparam class {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

class "类名" as ClassName {
  - 私有成员: 类型
  # 保护成员: 类型
  + 公有方法(): 返回类型
}

class "基类" as BaseClass
class "子类" as SubClass

BaseClass <|-- SubClass: 继承

class "接口" as Interface
Interface <|.. ClassName: 实现

@enduml
```

**示例 - EAP 通信类:**

```plantuml
@startuml eap-classes

skinparam class {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

abstract class Device {
  # String deviceId_
  # CommState state_
  + establishConnection(): bool
  + sendCommand(cmd: Command): Result
  + {abstract} processEvent(event: Event): void
}

class SECSCommunicator {
  - int port_
  - Socket socket_
  + connect(): bool
  + sendPrimary(msg: Message): void
  + waitForSecondary(): Message
}

class EquipmentState {
  - String status_
  - DateTime lastUpdate_
  + getStatus(): String
  + setStatus(status: String): void
}

interface IMessageHandler {
  + handleMessage(msg: Message): void
}

Device <|-- SECSCommunicator
Device *-- EquipmentState: 使用
SECSCommunicator ..|> IMessageHandler: 实现

@enduml
```

---

## 6. 系统全景图模板 (System Overview)

```plantuml
@startuml [name]

skinparam rectangle {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
  FontColor #000000
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}
skinparam queue {
  BackgroundColor #E8F5E9
  BorderColor #4CAF50
}

rectangle "系统名称" {
  rectangle "子系统 A" as SubA
  rectangle "子系统 B" as SubB
  rectangle "子系统 C" as SubC

  database "数据库" as DB
  queue "消息队列" as MQ
}

rectangle "外部系统" {
  rectangle "第三方服务" as Ext
}

SubA --> SubB: 调用
SubB --> SubC: 依赖
SubB --> DB: 存取
SubB --> MQ: 消息
Ext --> SubA: 接口

note right of SubB
  核心子系统
  处理主要业务逻辑
end note

@enduml
```

**示例 - CX 半导体制造系统全景:**

```plantuml
@startuml cx-system-overview

skinparam rectangle {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}
skinparam agent {
  BackgroundColor #F3E5F5
  BorderColor #9C27B0
}

rectangle "CX 半导体制造系统" {

  rectangle "MES (制造执行系统)" as MES {
    rectangle "执行引擎" as Engine
    rectangle "业务逻辑" as Logic
    rectangle "设备适配器" as Adapter
  }

  rectangle "EAP (设备自动化程序)" as EAP {
    rectangle "通信管理" as Comm
    rectangle "设备控制" as Control
  }

  agent "生产设备" as Equipments {
    agent "Growth 炉" as Growth
    agent "刻蚀机" as Etch
    agent "光刻机" as Stepper
  }

  database "Oracle 数据库" as DB
  queue "事件队列" as EQ
}

rectangle "外部系统" {
  rectangle "ERP (企业资源计划)" as ERP
  rectangle "WMS (仓库管理系统)" as WMS
}

note top of MES
  <b>MES - 制造执行系统</b>
  - CORBA（公共对象请求代理架构）分布式架构
  - 数百万行 C++ 代码
end note

note top of EAP
  <b>EAP - 设备自动化程序</b>
  - 上百项目
  - VB.NET + SECS/GEM（半导体设备通信标准）
end note

' MES 内部
Engine --> Logic
Logic --> Adapter

' MES - EAP 通信
Adapter --> Comm: CORBA ORB
Comm --> Control

' EAP - 设备通信
Control --> Growth: SECS/GEM
Control --> Etch: SECS/GEM
Control --> Stepper: SECS/GEM

' 数据流
MES --> DB: 状态存储
EAP --> DB: 通信日志
MES --> EQ: 事件分发

' 外部集成
ERP --> MES: 工单下发
WMS --> MES: 物料信息
MES --> ERP: 完工回报

@enduml
```

**示例 - 系统分层架构:**

```plantuml
@startuml layered-architecture

skinparam rectangle {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}

rectangle "展示层" {
  rectangle "Web 界面" as Web
  rectangle "移动端" as Mobile
}

rectangle "应用层" {
  rectangle "MES 服务" as MES
  rectangle "EAP 服务" as EAP
  rectangle "API 网关" as Gateway
}

rectangle "业务层" {
  rectangle "工单管理" as OQ
  rectangle "设备管理" as EQ
  rectangle "质量管理" as QM
}

rectangle "数据层" {
  database "Oracle DB" as DB
  database "Redis 缓存" as Cache
}

rectangle "设备层" {
  agent "生产设备" as Devices
}

note right of Gateway
  CORBA ORB
  REST API
end note

Web --> Gateway
Mobile --> Gateway
Gateway --> MES
Gateway --> EAP

MES --> OQ
MES --> EQ
MES --> QM
EAP --> EQ

MES --> DB
EAP --> DB
MES --> Cache

EAP --> Devices: SECS/GEM

@enduml
```

**示例 - 模块级全景图 (日常功能开发):**

> **适用场景:** 开发具体模块功能时，聚焦当前模块与周边系统的关系

```plantuml
@startuml module-overview

skinparam rectangle {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}
skinparam agent {
  BackgroundColor #F3E5F5
  BorderColor #9C27B0
}

' 当前开发的模块 - 高亮显示
rectangle "当前开发模块" as CurrentModule {
  rectangle "新增功能 A" as FeatureA
  rectangle "新增功能 B" as FeatureB
  rectangle "修改的组件" as Modified
}

' 相关系统 - 简化展示
rectangle "MES (制造执行系统)" as MES {
  rectangle "执行引擎" as Engine
  rectangle "其他业务" as OtherBiz
}

rectangle "EAP (设备自动化程序)" as EAP {
  rectangle "通信管理" as Comm
}

agent "目标设备" as Device
database "数据库" as DB

note top of CurrentModule
  <b>当前开发: XXX 模块</b>
  新增: FeatureA, FeatureB
  修改: Modified
end note

' 交互关系 - 只显示相关的，包含接口信息
CurrentModule --> MES: <b>CORBA: IEventCallback.onEvent()</b>
MES --> CurrentModule: <b>CORBA: IDeviceController.getDeviceId()</b>
CurrentModule --> EAP: <b>CORBA: IEAPControl.sendCommand()</b>
EAP --> Device: <b>SECS/GEM: S2F41</b>
CurrentModule --> DB: <b>JDBC: equip_status 表</b>

CurrentModule ..> Modified: 依赖
MES ..> Engine: 调用

@enduml
```

**接口标注规范:**

| 通信类型 | 标注格式 | 示例 |
|----------|----------|------|
| CORBA 调用 | `CORBA（公共对象请求代理）: 接口.方法()` | `CORBA: IEventCallback.onEvent()` |
| SECS/GEM | `SECS/GEM（半导体设备通信标准）: SxFy` | `SECS: S2F41`, `SECS: S6F11` |
| 数据库 | `JDBC（Java数据库连接）: 表名` 或 `SQL: 操作` | `JDBC: equip_status 表` |
| REST API | `HTTP: POST /api/xxx` | `HTTP: POST /api/devices` |
| 文件 | `FILE: /path/to/file` | `FILE: /data/equip.log` |

> **建议:** 首次出现时使用"中文（英文）"格式，后续可直接使用英文缩写
MES --> CurrentModule: 回调
CurrentModule --> EAP: 设备指令
EAP --> Device: SECS/GEM
CurrentModule --> DB: 数据读写

CurrentModule ..> Modified: 依赖修改
MES ..> Engine: 调用

@enduml
```

**示例 - 设备事件上报模块全景:**

```plantuml
@startuml event-report-module

skinparam rectangle {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}
skinparam database {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}

' 当前开发模块
rectangle "事件上报模块 (开发中)" as EventModule {
  rectangle "事件接收" as Receiver
  rectangle "事件过滤" as Filter
  rectangle "事件分发" as Dispatcher
}

' 相关系统组件
rectangle "EAP (设备自动化程序)" as EAP {
  rectangle "SECS（半导体设备通信标准）通信" as SECS
}

rectangle "MES (制造执行系统)" as MES {
  rectangle "事件处理器池" as Handlers
  rectangle "报警管理" as Alarm
}

database "Oracle 数据库" as DB
queue "事件队列" as EQ

note top of EventModule
  <b>当前开发: 设备事件上报优化</b>
  - 增加事件过滤
  - 优化分发机制
end note

EAP --> SECS: 接收设备事件
SECS --> Receiver: <b>SECS/GEM: S6F11</b>
Receiver --> Filter: 原始事件
Filter --> Dispatcher: 有效事件

Dispatcher --> EQ: <b>队列: event_queue</b>
Dispatcher --> Handlers: <b>CORBA: IEventHandler.handle()</b>
Handlers --> Alarm: <b>CORBA: IAlarmManager.report()</b>
Handlers --> DB: <b>SQL: INSERT INTO event_log</b>

note right of Filter
  新增过滤规则:
  - 去重
  - 限流
  - 优先级
end note

@enduml
```

**示例 - 新设备适配模块全景:**

```plantuml
@startuml new-device-adapter

skinparam rectangle {
  BackgroundColor #E3F2FD
  BorderColor #2196F3
}
skinparam agent {
  BackgroundColor #F3E5F5
  BorderColor #9C27B0
}

' 当前开发模块
rectangle "新设备适配器 (开发中)" as Adapter {
  rectangle "命令适配" as CmdAdapter
  rectangle "事件适配" as EventAdapter
  rectangle "数据转换" as DataConvert
}

' 相关系统
rectangle "MES (制造执行系统) 核心" as MES {
  rectangle "适配器工厂" as Factory
  rectangle "设备管理" as DeviceMgr
}

rectangle "EAP (设备自动化程序) 通信" as EAP {
  rectangle "SECS Client" as SECS
}

agent "新设备 XXX" as NewDevice
agent "其他设备" as OtherDevices

database "数据库" as DB

note top of Adapter
  <b>当前开发: XXX 设备适配器</b>
  支持命令: S2F41, S2F42
  支持事件: S6F11
end note

Factory --> Adapter: <b>CORBA: IDeviceAdapterFactory.create()</b>
Adapter --> DeviceMgr: <b>CORBA: IDeviceManager.register()</b>

MES --> Adapter: <b>CORBA: IDeviceCommand.execute()</b>
Adapter --> CmdAdapter: 转换
CmdAdapter --> EAP: <b>SECS/GEM: S2F41</b>
EAP --> SECS: <b>Socket: TCP Port</b>
SECS --> NewDevice: SECS/GEM

NewDevice --> SECS: <b>SECS/GEM: S6F11</b>
SECS --> EventAdapter: 接收
EventAdapter --> DataConvert: 解析
DataConvert --> MES: <b>CORBA: IEventCallback.onEvent()</b>
Adapter --> DB: <b>SQL: UPDATE device_status</b>

note right of DataConvert
  XXX 设备特殊处理:
  - 数据格式转换
  - 状态码映射
  - 自定义 DC ID
end note

@enduml
```

---

## 7. 宏定义（可复用样式）

```plantuml
@startuml
!define THEME_COLOR #2196F3
!define BG_COLOR #FEFEFE

skinparam backgroundColor BG_COLOR
skinparam defaultFontColor #000000

skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor THEME_COLOR
}
skinparam decision {
  BackgroundColor #FFF3E0
  BorderColor #FF9800
}
skinparam note {
  BackgroundColor #E8F5E9
  BorderColor #4CAF50
}

@enduml
```

---

**模板版本:** v1.0
**最后更新:** 2026-03-22
