# EAP 项目索引

> **系统:** Equipment Automation Program
> **技术栈:** VB.NET
> **项目数:** 上百
> **更新:** {{UPDATE_DATE}}

---

## 项目组织结构

```
EAP/
├── Common/                    # 公共模块
│   ├── SECSCommunicator.vb
│   ├── EventHandler.vb
│   └── StateManager.vb
│
├── Equipment/                 # 设备项目
│   ├── EQ001_GROWTH/
│   │   ├── Main.vb
│   │   ├── Config.vb
│   │   └── Commands.vb
│   ├── EQ002_ETCH/
│   └── ...
│
└── Services/                  # 服务模块
    ├── AlarmService.vb
    └── LoggingService.vb
```

---

## 核心通信类

### SECSCommunicator
```
Common/SECSCommunicator.vb
```
**功能:** SECS/GEM 协议通信

**关键方法:**
- `EstablishCommunication()` - S1F13/S1F14
- `GoOnline()` - S1F15/S1F17
- `SendCommand()` - S2F41
- `ReportEvent()` - S6F11

### EventHandler
```
Common/EventHandler.vb
```
**功能:** 设备事件处理

### StateManager
```
Common/StateManager.vb
```
**功能:** 设备状态管理

---

## 设备项目列表

### 生长炉 (GROWTH)
| 设备ID | 项目路径 | 说明 |
|--------|---------|------|
| EQ001 | Equipment/EQ001_GROWTH/ | 主生长炉 |
| EQ002 | Equipment/EQ002_GROWTH/ | 备用生长炉 |

### 刻蚀机 (ETCH)
| 设备ID | 项目路径 | 说明 |
|--------|---------|------|
| EQ101 | Equipment/EQ101_ETCH/ | 主刻蚀机 |

### 光刻机 (PHOTOLITHOGRAPHY)
| 设备ID | 项目路径 | 说明 |
|--------|---------|------|
| EQ201 | Equipment/EQ201_PHOTO/ | 步进光刻机 |

---

## 公共配置

```
Config/SECSConfig.xml         # SECS 协议配置
Config/EquipmentMap.xml       # 设备映射
Config/TimeoutConfig.xml      # 超时配置
```

---

## TODO: 实际项目列表

请根据实际 EAP 系统更新:

1. 完整设备项目列表
2. 各设备类型的项目数量
3. 实际文件路径
4. 配置文件内容
