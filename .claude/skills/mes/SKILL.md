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

- **tMSP（制造工具控制程序）** - 制造工具控制应用程序
- **CORBA（公共对象请求代理架构）** - 分布式对象通信，ORB（对象请求代理）中间件
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

### SECS/GEM（半导体设备通信标准）消息

- [技术知识库](.claude/docs/knowledge/mes-eap-technical-knowledge.md)

### 调试技巧

- [调试指南](debugging.md)

---

## 详细文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [调试指南](debugging.md)
