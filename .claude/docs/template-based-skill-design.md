# 模板化开发 Skill 设计

> **版本:** v1.0
> **日期:** 2026-03-22
> **场景:** EAP 添加新设备，参考现有程序修改

---

## 1. 使用场景

| 场景 | 操作 | 参考物 |
|------|------|--------|
| **EAP 添加新设备** | 复制现有设备程序，修改配置 | 类似设备代码 |
| **MES 新增模块** | 参考现有模块结构 | 类似模块 |
| **Web 新增页面** | 复制现有页面模板 | 类似页面 |

---

## 2. Skill 类型：template-based

**与普通 Skill 的区别:**

| 特性 | 普通 Skill | Template-based Skill |
|------|-----------|---------------------|
| 知识来源 | 代码分析 + 文档 | 现有代码模板 |
| 使用方式 | 参考规范 | 直接复制修改 |
| 关键内容 | API/函数列表 | 修改点清单 |
| 验证方式 | 代码审查 | 对比模板差异 |

---

## 3. Skill 文件结构

```
.claude/skills/templates/
├── eap-add-device/
│   ├── SKILL.md                    # 主文件
│   ├── template-code/              # 模板代码
│   │   ├── EquipmentTemplate.vb
│   │   └── DeviceConfig.xml
│   ├── modification-checklist.md   # 修改点清单
│   ├── validation-list.md          # 验证清单
│   └── examples/                   # 示例
│       ├── EQ001_Growth.py         # 原始设备
│       └── EQ002_Etch.py           # 新增设备
```

---

## 4. SKILL.md 模板

```markdown
# EAP 添加新设备模板

## 适用场景
为 EAP 系统添加新设备支持时，参考现有设备程序进行修改

## 参考模板
- 模板文件: `template-code/EquipmentTemplate.vb`
- 参考设备: EQ001 (光刻机)
- 目标设备: [新设备名称]

## 修改点清单

### 必须修改
- [ ] 设备 ID (EquipmentId)
- [ ] 设备类型 (EquipmentType)
- [ ] SECS/GEM 端口 (Port)
- [ ] 通信超时配置
- [ ] 支持的命令列表

### 可能需要修改
- [ ] 状态机逻辑 (如果设备状态不同)
- [ ] 事件处理 (如果事件类型不同)
- [ ] 报警映射 (如果报警定义不同)
- [ ] 数据解析 (如果数据格式不同)

### 不建议修改
- [ ] 通信框架 (SECS/GEM 协议层)
- [ ] 日志记录格式
- [ ] 错误处理机制

## 操作步骤

1. 复制模板文件
2. 按照修改点清单逐项修改
3. 使用验证清单检查
4. 与设备联调测试

## 常见问题

Q: 设备不支持 S2F41 命令怎么办？
A: 在命令列表中移除，或在发送前检查设备能力。

Q: 两个设备状态机不同怎么办？
A: 复制状态机部分，根据新设备规范修改。

## 参考
- 原始设备代码: `examples/EQ001_Growth.py`
- 类似设备: EQ002, EQ003
```

---

## 5. 修改点清单 (modification-checklist.md)

```markdown
# EAP 设备添加修改点清单

## 文件级修改

| 文件 | 必须修改 | 可能修改 | 不修改 |
|------|---------|---------|--------|
| EquipmentConfig.xml | ✓ | | |
| DeviceCommunicator.vb | ✓ | | |
| StateMachine.vb | | ✓ | |
| EventHandler.vb | | ✓ | |
| SECSClient.vb | | | ✓ |

## 代码级修改点

### 1. 设备标识

**模板代码:**
```vb
Public Const EQUIPMENT_ID As String = "TEMPLATE_EQ"
Public Const EQUIPMENT_TYPE As String = "GROWTH"
```

**修改为:**
```vb
Public Const EQUIPMENT_ID As String = "EQ002"
Public Const EQUIPMENT_TYPE As String = "ETCH"
```

---

### 2. 通信配置

**模板代码:**
```vb
Public Const HSMS_PORT As Integer = 5000
Public Const T1_TIMEOUT As Integer = 5000
```

**修改为:**
```vb
Public Const HSMS_PORT As Integer = 5001  ' 新设备端口
Public Const T1_TIMEOUT As Integer = 7000  ' 设备要求更长超时
```

---

### 3. 支持命令列表

**模板代码:**
```vb
Public ReadOnly SupportedCommands As String() = {
    "S2F41",  ' Host Command
    "S2F13",  ' Equipment Constant Request
    "S2F15"   ' Equipment Constant Send
}
```

**修改为:**
```vb
' 如果新设备不支持 S2F13/S2F15，移除
Public ReadOnly SupportedCommands As String() = {
    "S2F41"   ' Host Command
}
```

---

### 4. 状态转换

**如果状态不同，需要修改:**

```vb
' 模板状态机
Enum EquipmentState
    DISABLED
    NOT_CONNECTED
    CONNECTED
    ONLINE
End Enum

' 新设备可能需要添加 PAUSED 状态
Enum EquipmentState
    DISABLED
    NOT_CONNECTED
    CONNECTED
    ONLINE
    PAUSED      ' 新增
    MAINTENANCE ' 新增
End Enum
```

---

### 5. 事件处理

**模板事件:**
```vb
Private Sub OnEventReport(eventData As EventData)
    Select Case eventId
        Case 1001 : HandleProcessStateChange()
        Case 1002 : HandleCarrierArrival()
    End Select
End Sub
```

**新设备可能需要:**
```vb
Private Sub OnEventReport(eventData As EventData)
    Select Case eventId
        Case 2001 : HandleEtchProcessComplete()  ' 蚀刻特有
        Case 2002 : HandleChamberClean()          ' 蚀刻特有
        Case 1001 : HandleProcessStateChange()
    End Select
End Sub
```
```

---

## 6. 验证清单 (validation-list.md)

```markdown
# EAP 设备添加验证清单

## 编译验证
- [ ] 编译无错误
- [ ] 编译无警告（或警告已确认）

## 配置验证
- [ ] 设备 ID 已更新
- [ ] 设备类型已更新
- [ ] 端口配置正确
- [ ] 超时配置符合设备规格

## 代码对比验证
- [ ] 与模板代码对比，只修改了必要的部分
- [ ] 使用 diff 工具确认修改范围

## 功能验证
- [ ] 通信建立成功 (S1F13→S1F14)
- [ ] 在线登录成功 (S1F15→S1F17)
- [ ] 发送控制命令成功
- [ ] 接收事件报告成功
- [ ] 超时重试正常
- [ ] 错误处理正常

## SECS/GEM 验证
- [ ] 支持的命令列表与设备规格一致
- [ ] 状态机转换符合 GEM 标准
- [ ] 事件 ID 映射正确
- [ ] 报警 ID 映射正确

## 日志验证
- [ ] 关键操作有日志记录
- [ ] 错误信息记录完整
- [ ] 日志格式与现有设备一致
```

---

## 7. /create-template-skill 命令

**功能:** 基于现有代码创建模板化 Skill

```bash
/create-template-skill --type <类型> --reference <参考代码>

类型:
  eap-device      - EAP 添加设备
  mes-module       - MES 添加模块
  web-page        - Web 添加页面
  api-endpoint    - API 添加接口

示例:
  /create-template-skill --type eap-device --reference src/devices/EQ001
  /create-template-skill --type web-page --reference src/pages/Dashboard.vue
```

**执行流程:**

```
1. 分析参考代码
   ├── 识别代码结构
   ├── 提取变量/常量
   └── 识别可修改部分

2. 生成模板代码
   ├── 将固定值替换为占位符
   ├── 生成修改点说明
   └── 生成对比工具

3. 生成修改清单
   ├── 必须修改项
   ├── 可选修改项
   └── 禁止修改项

4. 生成验证清单
   ├── 编译验证
   ├── 功能验证
   └── 对比验证
```

---

## 8. 使用示例

### 8.1 创建模板 Skill

```bash
$ /create-template-skill --type eap-device --reference src/devices/EQ001_Growth

分析参考代码: EQ001_Growth.vb
识别代码结构...
提取可修改部分...
生成模板 Skill...

✅ 已生成: .claude/skills/templates/eap-growth-device/
   ├── SKILL.md
   ├── template-code/EquipmentTemplate.vb
   ├── modification-checklist.md
   └── validation-list.md

📋 模板信息:
   参考设备: EQ001 (光刻机)
   设备类型: GROWTH
   支持命令: 12 种
   修改点: 8 处必须修改
```

### 8.2 使用模板添加新设备

```bash
$ /use-skill templates/eap-growth-device

📋 EAP 光刻类设备添加模板

参考设备: EQ001 (光刻机)
目标设备: [请输入新设备 ID]

选择参考:
  [1] EQ001 - 光刻机 (最相似)
  [2] EQ003 - 光刻机 (类似)
  [3] 自定义

请选择参考设备: 1

生成修改清单...
[✓] 已生成: new-device-checklist.md
[✓] 已复制: template-code/EquipmentTemplate.vb

按清单修改完成后运行验证:
  /validate-against-template
```

---

## 9. 模板代码格式

**将固定值替换为占位符:**

```vb
' 原始代码
Public Const EQUIPMENT_ID As String = "EQ001"
Public Const EQUIPMENT_TYPE As String = "GROWTH"
Public Const HSMS_PORT As Integer = 5000

' 模板代码
Public Const EQUIPMENT_ID As String = "{{EQUIPMENT_ID}}"      ' [必改] 设备 ID
Public Const EQUIPMENT_TYPE As String = "{{EQUIPMENT_TYPE}}"  ' [必改] 设备类型
Public Const HSMS_PORT As Integer = {{HSMS_PORT}}             ' [必改] SECS 端口
```

**占位符说明:**

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `{{EQUIPMENT_ID}}` | 设备 ID | EQ002 |
| `{{EQUIPMENT_TYPE}}` | 设备类型 | ETCH |
| `{{HSMS_PORT}}` | SECS 端口 | 5001 |
| `{{T1_TIMEOUT}}` | 超时时间 | 7000 |
| `{{SUPPORTED_COMMANDS}}` | 支持的命令 | S2F41,S2F13 |

---

## 10. 对比验证工具

```bash
/validate-against-template --new new-device.vb --template template.vb

对比结果:
✅ 必须修改项已全部修改
⚠️  检测到额外修改:
  - StateMachine.vb: 添加了 PAUSED 状态 (需确认)
✅ 通信框架未修改 (正确)

建议: 确认 PAUSED 状态是否为新设备特性
```

---

## 11. 各种模板类型

### EAP 设备模板
- 参考文件: `.vb` 设备程序
- 修改点: 设备ID、端口、命令列表、事件处理

### MES 模块模板
- 参考文件: `.cpp/.h` 模块代码
- 修改点: 模块名、类名、数据表、接口定义

### Web 页面模板
- 参考文件: `.vue` 页面组件
- 修改点: 路由、标题、API 接口、表单字段

### API 接口模板
- 参考文件: Controller/Service 代码
- 修改点: 路径、参数、返回值、业务逻辑

---

## 12. 与普通 Skill 配合

```
template-based Skill    普通 Skill
       │                    │
   模板代码              API 文档
   修改清单              编码规范
   验证清单              业务逻辑
       │                    │
       └────────┬───────────┘
               ↓
        完整的开发支持
```

---

**文档版本:** v1.0
**最后更新:** 2026-03-22
