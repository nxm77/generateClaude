# CX Claude Code 配置 - 研究发现

> **项目:** CX 半导体企业 Claude Code CLI 配置
> **更新:** 2025-03-22

---

## 成熟插件调研

### planning-with-files
- **来源:** planning-with-files
- **用途:** 大型项目上下文管理
- **核心:** 三文件系统 (task_plan.md, findings.md, progress.md)
- **结论:** ✅ 采用

### superpowers
- **来源:** superpowers-dev
- **用途:** 工作流方法论
- **核心技能:** brainstorming, writing-plans, tdd, debugging, code-review
- **结论:** ✅ 采用

### everything-claude-code
- **来源:** everything-claude-code
- **用途:** 生产就绪插件集合
- **核心:** code-reviewer, security-reviewer, tdd, plan
- **结论:** ✅ 采用

### qa-test-planner
- **来源:** agent-toolkit
- **用途:** QA 测试计划生成
- **结论:** ✅ 采用

---

## MES/EAP 技术要点

### SECS/GEM 协议

| 消息 | 功能 | 方向 |
|------|------|------|
| S1F13 | Establish Communication | Host → Equipment |
| S1F14 | Establish Communication Ack | Equipment → Host |
| S1F15 | Online Request | Host → Equipment |
| S1F17 | Online Data | Equipment → Host |
| S6F11 | Event Report | Equipment → Host |
| S6F12 | Event Report Ack | Host → Equipment |
| S2F41 | Host Command Send | Host → Equipment |
| S2F42 | Host Command Ack | Equipment → Host |
| S5F1 | Alarm Report | Equipment → Host |
| S5F2 | Alarm Report Ack | Host → Equipment |

### 设备状态机

```
DISABLED → NOT_CONNECTED → COMMUNICATING → ONLINE
                    ↑              ↓
                    └──── ENABLE_CONTROL ──────┘
```

### 通信超时设置

| 场景 | 超时时间 | 重试次数 |
|------|---------|---------|
| 通信建立 (T1) | 5秒 | 3次 |
| 在线请求 (T2) | 3秒 | 5次 |
| 控制命令 (T3) | 10秒 | - |
| 数据收集 (T4) | 60秒 | - |
| 通用处理 (T5) | 10秒 | - |
| 通信流控 (T6) | 3秒 | - |

---

## 环境约束

- **局域网环境** - 无互联网访问
- **PlantUML** - 文件下载到本地用工具查看
- **Git** - 本地 Git 管理，无 MR 集成
- **团队规模** - 20+ 人，按业务模块分工

---

## IBM SiView MES 特点

- tMSP 制造工具控制应用程序
- 事件驱动、面向服务的多线程逻辑引擎
- 插件式业务逻辑支持
- 控制设备与 MES 之间的通信

---

## EAP 系统特点

- 基于 SECS/GEM 协议
- VB.NET 开发
- 上百项目，每个约 10 万行代码
- 设备通信和控制

---

## 待研究事项

- [ ] IBM SiView 具体 API 文档
- [ ] 各设备厂商的 SECS/GEM 实现差异
- [ ] 现有代码库的详细结构分析
