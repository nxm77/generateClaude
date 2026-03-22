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
