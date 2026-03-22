# EAP 调试指南

> **系统:** Equipment Automation Program
> **语言:** VB.NET
> **协议:** SECS/GEM
> **更新:** 2025-03-22

---

## 常见问题

### 1. 通信建立失败

**症状:**
- S1F13 发送后没有收到 S1F14
- 设备无法上线

**排查步骤:**

```vb
' 1. 检查网络连接
Dim pingResult As Boolean = PingDevice(EquipmentConfig.IP_ADDRESS)
If Not pingResult Then
    LogError("Cannot ping device at " & EquipmentConfig.IP_ADDRESS)
    Return False
End If

' 2. 检查端口
Dim portOpen As Boolean = CheckPort(EquipmentConfig.IP_ADDRESS,
                                     EquipmentConfig.PORT)
If Not portOpen Then
    LogError("Port " & EquipmentConfig.PORT & " is not open")
    Return False
End If

' 3. 检查超时设置
LogInfo("T1 timeout: " & SECSConstants.T1_TIMEOUT & "ms")
```

**常见原因:**

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| T1 超时 | 设备未启动 | 启动设备 |
| T1 超时 | IP 地址错误 | 检查配置 |
| T1 超时 | 端口不正确 | 检查端口配置 |
| T1 超时 | 网络不通 | 检查网络连接 |

### 2. 在线请求失败

**症状:**
- S1F15 发送后没有收到 S1F17
- 设备停留在 COMMUNICATING 状态

**排查步骤:**

```vb
' 检查设备状态
If objStateManager.CurrentState <> DeviceState.COMMUNICATING Then
    LogError("Device not in COMMUNICATING state")
    Return False
End If

' 检查 S1F15 消息格式
Dim s1f15 As New SECSMessage(1, 15)
s1f15.AddItem("ONLINE", True)
LogInfo("S1F15 message: " & s1f15.ToString())
```

### 3. 事件未上报

**症状:**
- 设备操作后没有收到 S6F11
- MES 未收到事件通知

**排查步骤:**

```vb
' 1. 检查事件是否使能
Private Function IsEventEnabled(ByVal eventId As Integer) As Boolean
    ' 发送 S1F3 查询使能状态
    Dim s1f3 As New SECSMessage(1, 3)
    s1f3.AddItem("CEID", eventId)

    Dim s1f4 As SECSMessage = SendMessage(s1f3, 5000)
    If s1f4 IsNot Nothing Then
        Return s1f4.GetItem("ENABLED").GetValue()
    End If
    Return False
End Function

' 2. 使能事件
Public Sub EnableEvent(ByVal eventId As Integer)
    Dim s1f1 As New SECSMessage(1, 1)
    s1f1.AddItem("CEID", eventId)
    s1f1.AddItem("ENABLED", True)
    SendMessage(s1f1, 5000)
End Sub
```

### 4. 命令执行超时

**症状:**
- S2F41 发送后 T3 超时
- 设备无响应

**排查步骤:**

```vb
' 1. 检查设备状态
If objStateManager.CurrentState <> DeviceState.ONLINE Then
    LogError("Device not in ONLINE state")
    Return False
End If

' 2. 检查命令格式
LogInfo("Sending S2F41: " & commandName)
For Each param In parameters
    LogInfo("  " & param.Key & " = " & param.Value)
Next

' 3. 增加超时时间
If commandName = "LONG_RUNNING_CMD" Then
    ' 使用更长超时
    Return SendMessage(s2f41, 30000)  ' 30秒
End If
```

---

## 调试工具

### 日志记录

```vb
' 消息日志
Public Sub LogSECSMessage(ByVal direction As String,
                         ByVal msg As SECSMessage)
    Dim log As String = String.Format(
        "{0:yyyy-MM-dd HH:mm:ss.fff} [{1}] S{2}F{3} {4}",
        DateTime.Now,
        direction,
        msg.Stream,
        msg.Function,
        msg.ToString()
    )
    WriteLog(log)
End Sub

' 状态变化日志
Public Sub LogStateChange(ByVal oldState As DeviceState,
                          ByVal newState As DeviceState)
    Dim log As String = String.Format(
        "{0:yyyy-MM-dd HH:mm:ss} State: {1} -> {2}",
        DateTime.Now,
        oldState,
        newState
    )
    WriteLog(log)
End Sub

' 超时日志
Public Sub LogTimeout(ByVal msg As String,
                      ByVal timeout As Integer)
    Dim log As String = String.Format(
        "{0:yyyy-MM-dd HH:mm:ss} TIMEOUT: {1} after {2}ms",
        DateTime.Now,
        msg,
        timeout
    )
    WriteLog(log)
End Sub
```

### 网络抓包

```bash
# 使用 Wireshark 抓包
# 过滤条件: tcp.port == 5000

# 或使用 tcpdump
tcpdump -i any -s 0 -w capture.pcap host 192.168.1.100 and port 5000
```

---

## 常用调试代码

### 测试连接

```vb
Public Function TestConnection() As Boolean
    LogInfo("Testing connection to " & EquipmentConfig.IP_ADDRESS)

    ' 1. Ping 测试
    Dim ping As New System.Net.NetworkInformation.Ping()
    Dim reply = ping.Send(EquipmentConfig.IP_ADDRESS, 5000)
    If reply.Status <> IPStatus.Success Then
        LogError("Ping failed: " & reply.Status)
        Return False
    End If

    ' 2. 端口测试
    Dim tcp As New System.Net.Sockets.TcpClient()
    Try
        tcp.Connect(EquipmentConfig.IP_ADDRESS, EquipmentConfig.PORT)
        LogInfo("Port " & EquipmentConfig.PORT & " is open")
        tcp.Close()
        Return True
    Catch ex As Exception
        LogError("Port test failed: " & ex.Message)
        Return False
    End Try
End Function
```

### 诊断信息

```vb
Public Sub PrintDiagnostics()
    LogInfo("=== Device Diagnostics ===")
    LogInfo("Equipment ID: " & EquipmentConfig.EQUIPMENT_ID)
    LogInfo("Equipment Type: " & EquipmentConfig.EQUIPMENT_TYPE)
    LogInfo("IP Address: " & EquipmentConfig.IP_ADDRESS)
    LogInfo("Port: " & EquipmentConfig.PORT)
    LogInfo("Current State: " & objStateManager.CurrentState)
    LogInfo("Communication Status: " & objCommunicator.IsConnected)
    LogInfo("========================")
End Sub
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [代码模式](patterns.md)
- [SECS/GEM 参考](secs-gem-reference.md)
