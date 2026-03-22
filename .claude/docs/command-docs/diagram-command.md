# /diagram 命令说明

> **类别:** 图表生成
> **更新:** 2025-03-22

---

## 功能

生成 PUML 图表。

---

## 用法

```
/diagram [类型] [名称]
```

---

## 交互模式

```
/diagram
```

进入交互模式，按提示选择图表类型和内容。

---

## 直接生成

```bash
# 流程图
/diagram flow "设备登录流程"

# 时序图
/diagram sequence "S1F13/S1F14 握手时序"

# 状态机图
/diagram state "EAP 设备状态机"

# 架构图
/diagram architecture "MES 系统架构"

# 查看推荐图表
/diagram suggest
```

---

## 输出

生成 `docs/diagrams/` 目录下的 `.puml` 文件。

---

## 示例

```bash
# 交互式生成
/diagram
# > 选择图表类型: [1] 流程图 [2] 时序图 [3] 状态机 [4] 架构图
# > 输入图表名称: 设备握手流程
# ✅ docs/diagrams/device-handshake.puml 已创建

# 直接生成
/diagram flow "设备登录流程"
# ✅ docs/diagrams/device-login-flow.puml 已创建
```

---

## 查看图表

由于局域网环境，需要：
1. 下载 `.puml` 文件到本地
2. 使用 PlantUML 工具渲染
3. 或使用 IDEA/VSCode 插件预览

---

## 推荐图表 (MES/EAP)

| 优先级 | 图表 | 说明 |
|--------|------|------|
| P0 | 设备握手流程 | S1F13/S1F14 通信建立 |
| P0 | 设备登录时序 | S1F15/S1F17 在线请求 |
| P0 | 设备状态机 | 6 状态转换图 |
| P1 | 事件报告流程 | S6F11/S6F12 处理 |
| P1 | 命令执行流程 | S2F41/S2F42 控制命令 |
