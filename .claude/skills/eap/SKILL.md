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
