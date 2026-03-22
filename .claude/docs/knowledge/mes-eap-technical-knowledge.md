# MES & EAP 技术知识库

> **适用系统:** SiView MES, EAP (VB.NET)
> **协议标准:** SEMI E4, E5, E30, E37
> **更新:** 2025-03-22

---

## SECS/GEM 协议概述

SECS (SEMI Equipment Communications Standard) 是半导体设备通信标准，GEM (Generic Equipment Model) 定义了设备行为模型。

### 协议层次

```
┌─────────────────────────────────────┐
│         应用层 (GEM)                │  设备状态、事件、报警
├─────────────────────────────────────┤
│         消息层 (SECS-II)            │  S1F13, S6F11 等
├─────────────────────────────────────┤
│         传输层 (HSMS)               │  TCP/IP 连接
└─────────────────────────────────────┘
```

---

## 消息结构

### Primary / Secondary 模式

所有 SECS 消息都是 Primary-Secondary 配对：

```
Host → Equipment: S1F13 (Primary)
Equipment → Host: S1F14 (Secondary)
```

### 消息命名规则

```
S<流号>F<功能号>

例如: S1F13
  S = SECS
  1 = 流 1 (Stream 1)
  F = Function
  13 = 功能 13
```

---

## 常用消息类型

### 流 1: 设备通信

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S1F13 | Establish Communication | H→E | 请求建立通信 |
| S1F14 | Establish Comm Ack | E→H | 通信建立确认 |
| S1F15 | Online Request | H→E | 请求设备在线 |
| S1F17 | Online Data | E→H | 在线数据响应 |

### 流 2: 设备控制

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S2F41 | Host Command Send | H→E | 发送控制命令 |
| S2F42 | Host Command Ack | E→H | 命令执行确认 |
| S2F43 | Host Command Cancel | H→E | 取消控制命令 |

### 流 5: 警报

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S5F1 | Alarm Report Send | E→H | 上报警报 |
| S5F2 | Alarm Report Ack | H→E | 警报确认 |

### 流 6: 数据收集

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S6F11 | Event Report | E→H | 事件报告 |
| S6F12 | Event Report Ack | H→E | 事件确认 |
| S6F15 | Event Report Request | H→E | 请求事件报告 |
| S6F23 | Trace Data Send | E→H | 发送追踪数据 |

### 流 14: 数据获取

| 消息 | 名称 | 方向 | 用途 |
|------|------|------|------|
| S14F1 | GetAttrReq | H→E | 获取属性请求 |
| S14F2 | GetAttrData | E→H | 属性数据响应 |

---

## 设备状态机

### GEM 控制状态模型

```
                    ┌─────────────────┐
                    │   DISABLED      │
                    │  (禁用控制)      │
                    └────────┬────────┘
                             │ ENABLE
                             ▼
                    ┌─────────────────┐
              ┌─────│ NOT_CONNECTED   │─────┐
              │     │  (未连接)        │     │
              │     └────────┬─────────┘     │
              │              │ COMMUNICATE   │
              │              ▼               │
      ┌───────┴──────┐  ┌─────────────────┐  │
      │ ATTEMPTING   │  │  COMMUNICATING  │  │
      │   (尝试中)    │  │   (通信中)      │  │
      └───────┬──────┘  └────────┬─────────┘  │
              │                    │           │
              │                    │ ESTABLISH │
              │                    ▼           ▼
      ┌───────┴─────────────────────┴────────────┐
      │              ONLINE                       │
      │         (在线，准备执行命令)              │
      └──────────────────────────────────────────┘
                    │
                    │ DISABLE / COMMUNICATIONS
                    │ INITIATE
                    ▼
              ┌─────────┐
              │  HOST   │
              │  OFFLINE│
              └─────────┘
```

### 状态转换说明

| 当前状态 | 目标状态 | 触发条件 |
|---------|---------|---------|
| DISABLED | NOT_CONNECTED | Host 发送 S1F17 (ENABLE) |
| NOT_CONNECTED | ATTEMPTING | Host 尝试建立连接 |
| ATTEMPTING | COMMUNICATING | S1F13/S1F14 握手成功 |
| COMMUNICATING | ONLINE | S1F15/S1F17 在线确认 |
| ONLINE | HOST_OFFLINE | 通信丢失或超时 |
| 任意状态 | DISABLED | Host 发送 S1F17 (DISABLE) |

---

## 通信超时设置

### HSMS 超时参数

| 参数 | 超时时间 | 说明 |
|------|---------|------|
| T1 | 5秒 | 通信建立超时 (S1F13 等待 S1F14) |
| T2 | 3秒 | 在线请求超时 (S1F15 等待 S1F17) |
| T3 | 10秒 | 控制命令超时 (S2F41 等待 S2F42) |
| T4 | 60秒 | 数据收集超时 |
| T5 | 10秒 | 通用处理超时 |
| T6 | 3秒 | 通信流控超时 |
| T7 | 3秒 | 网络连接超时 |
| T8 | 3秒 | 选择超时 |

### 重试策略

| 场景 | 重试次数 | 重试间隔 |
|------|---------|---------|
| 通信建立 (T1) | 3次 | 5秒 |
| 在线请求 (T2) | 5次 | 3秒 |
| 控制命令 (T3) | 不重试 | - |
| 数据收集 (T4) | 不重试 | - |

---

## EAP 设备握手流程

### 通信建立流程

```
Host                    Equipment
  │                          │
  │──── S1F13 ──────────────→│  (T1 = 5秒)
  │                          │
  │←──── S1F14 ──────────────│
  │                          │
  │──── S1F15 ──────────────→│  (T2 = 3秒)
  │                          │
  │←──── S1F17 ──────────────│
  │                          │
  │   状态 → ONLINE          │
```

### 超时处理

```
Host                    Equipment
  │                          │
  │──── S1F13 ──────────────→│
  │                          │
  │    (T1 超时 5秒)         │
  │                          │
  │──── S1F13 (重试) ───────→│
  │                          │
  │←──── S1F14 ──────────────│
  │                          │
  │──── S1F15 ──────────────→│
  │                          │
  │←──── S1F17 ──────────────│
  │                          │
  │   状态 → ONLINE          │
```

---

## 设备事件报告

### S6F11 事件报告结构

```
Event Report (S6F11)
├── EventID: 事件ID
├── EquipmentID: 设备ID
├── Timestamp: 时间戳
├── EventCategory: 事件类别
└── DataVariables: 数据变量列表
    ├── Variable1: 值1
    ├── Variable2: 值2
    └── ...
```

### 事件处理流程

```
Equipment                Host
  │                        │
  │←───── S6F11 ──────────│  Event Report
  │                        │
  │───── S6F12 ───────────→│  Acknowledge
  │                        │
  │ (继续执行)             │
```

---

## 常见错误代码

### CEID (Collection Event ID)

| CEID | 名称 | 说明 |
|------|------|------|
| 1 | Power On | 设备上电 |
| 2 | Power Off | 设备断电 |
| 10 | Process Start | 工艺开始 |
| 11 | Process Complete | 工艺完成 |
| 50 | Alarm Occurred | 警报发生 |
| 100 | Cassette Load | Cassette 装载 |

### Alarm Code

| Alarm | 级别 | 说明 |
|-------|------|------|
| A1001 | Critical | 通信失败 |
| A1002 | Warning | 设备超时 |
| A2001 | Major | 工艺异常 |
| A2002 | Minor | 参数偏差 |

---

## 编码注意事项

### EAP (VB.NET)

```vb
' 正确的通信超时处理
Const T1_TIMEOUT As Integer = 5000  ' 5秒
Dim retryCount As Integer = 0
Const MAX_RETRY As Integer = 3

Do While retryCount < MAX_RETRY
    Dim response = SendMessage(S1F13)
    If response IsNot Nothing Then
        Exit Do
    End If
    retryCount += 1
    Threading.Thread.Sleep(5000)
Loop

' 状态机处理
Select Case deviceState
    Case DeviceState.DISABLED
        ' 处理禁用状态
    Case DeviceState.NOT_CONNECTED
        ' 处理未连接状态
    Case DeviceState.ONLINE
        ' 处理在线状态
End Select
```

### MES (C++)

```cpp
// 智能指针管理设备连接
std::shared_ptr<DeviceCommunicator> comm =
    std::make_shared<DeviceCommunicator>(deviceId);

// 超时处理
auto future = std::async(std::launch::async, [&comm]() {
    return comm->establishCommunication();
});

if (future.wait_for(std::chrono::seconds(T1_TIMEOUT)) == std::future_status::timeout) {
    // 处理超时
    throw CommunicationTimeoutException("S1F13 timeout");
}
```

---

## 调试技巧

### 常见问题排查

| 问题 | 可能原因 | 排查方法 |
|------|---------|---------|
| 设备无法上线 | 1. 网络不通<br>2. 设备ID错误<br>3. T1超时 | ping测试<br>检查配置<br>增加超时时间 |
| 事件未上报 | 1. 未使能事件<br>2. CEID错误<br>3. 事件过滤 | 检查S1F3<br>查看设备日志 |
| 命令无响应 | 1. 设备状态不对<br>2. 命令格式错误<br>3. T3超时 | 检查状态机<br>查看命令格式<br>增加超时 |

### 日志记录要点

```vb
' 记录关键消息
LogSECSMessage("TX", "S1F13", deviceId, messageData)
LogSECSMessage("RX", "S1F14", deviceId, responseData)

' 记录状态转换
LogStateChange(deviceId, oldState, newState)

' 记录超时事件
LogTimeout("S1F13", deviceId, T1_TIMEOUT)
```

---

## 参考标准

- SEMI E4 - SECS-I (半驱动通信)
- SEMI E5 - SECS-II (消息内容)
- SEMI E30 - GEM (通用设备模型)
- SEMI E37 - High Speed SECS Message Services (HSMS)

---

## 相关文档

- [SECS/GEM 消息参考](.claude/docs/knowledge/secs-gem-messages.md)
- [设备状态机详解](.claude/docs/knowledge/device-state-machine.md)
- [EAP 编码规范](.claude/skills/eap/coding-standards.md)
