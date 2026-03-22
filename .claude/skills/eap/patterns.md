# EAP 代码模式

> **系统:** Equipment Automation Program
> **语言:** VB.NET
> **更新:** 2025-03-22

---

## 设备握手模式

### S1F13/S1F14 握手

```vb
Public Class DeviceHandshake

    Public Function EstablishCommunication() As Boolean
        ' 发送 S1F13
        Dim s1f13 As New SECSMessage(1, 13)
        s1f13.AddItem("SESSIONID", 1)

        ' 等待 S1F14
        Dim s1f14 As SECSMessage = SendMessageWithRetry(
            s1f13,
            SECSConstants.T1_TIMEOUT,
            SECSConstants.MAX_RETRY_T1
        )

        If s1f14 IsNot Nothing AndAlso s1f14.Function = 14 Then
            Return GoOnline()
        End If

        Return False
    End Function

    Private Function GoOnline() As Boolean
        ' 发送 S1F15
        Dim s1f15 As New SECSMessage(1, 15)
        s1f15.AddItem("ONLINE", True)

        ' 等待 S1F17
        Dim s1f17 As SECSMessage = SendMessageWithRetry(
            s1f15,
            SECSConstants.T2_TIMEOUT,
            SECSConstants.MAX_RETRY_T2
        )

        If s1f17 IsNot Nothing AndAlso s1f17.Function = 17 Then
            objStateManager.SetState(DeviceState.ONLINE)
            Return True
        End If

        Return False
    End Function

End Class
```

---

## 状态机模式

### 设备状态管理

```vb
Public Enum DeviceState
    DISABLED           ' 禁用控制
    NOT_CONNECTED      ' 未连接
    ATTEMPTING         ' 尝试连接中
    COMMUNICATING      ' 通信中
    ONLINE             ' 在线
    HOST_OFFLINE       ' 主机离线
End Enum

Public Class StateManager

    Private objCurrentState As DeviceState = DeviceState.DISABLED

    Public Function CanTransitionTo(ByVal newState As DeviceState) As Boolean
        Select Case objCurrentState
            Case DeviceState.DISABLED
                Return newState = DeviceState.NOT_CONNECTED

            Case DeviceState.NOT_CONNECTED
                Return newState = DeviceState.ATTEMPTING OrElse
                       newState = DeviceState.DISABLED

            Case DeviceState.ATTEMPTING
                Return newState = DeviceState.COMMUNICATING OrElse
                       newState = DeviceState.NOT_CONNECTED

            Case DeviceState.COMMUNICATING
                Return newState = DeviceState.ONLINE OrElse
                       newState = DeviceState.NOT_CONNECTED

            Case DeviceState.ONLINE
                Return newState = DeviceState.COMMUNICATING OrElse
                       newState = DeviceState.HOST_OFFLINE OrElse
                       newState = DeviceState.DISABLED

            Case Else
                Return False
        End Select
    End Function

    Public Sub SetState(ByVal newState As DeviceState)
        If CanTransitionTo(newState) Then
            Dim oldState = objCurrentState
            objCurrentState = newState
            OnStateChanged(oldState, newState)
        Else
            Throw New InvalidOperationException(
                "Cannot transition from " & objCurrentState &
                " to " & newState
            )
        End If
    End Sub

    Public Event StateChanged(ByVal oldState As DeviceState,
                             ByVal newState As DeviceState)

    Protected Sub OnStateChanged(ByVal oldState As DeviceState,
                                ByVal newState As DeviceState)
        RaiseEvent StateChanged(oldState, newState)
    End Sub

End Class
```

---

## 事件处理模式

### S6F11 事件报告处理

```vb
Public Class EventHandler

    Public Sub HandleEventReport(ByVal s6f11 As SECSMessage)
        ' 解析事件报告
        Dim eventId As Integer = s6f11.GetItem("CEID").GetValue()
        Dim reportData As Dictionary(Of String, Object) =
            ParseEventData(s6f11)

        ' 根据事件 ID 分发
        Select Case eventId
            Case 1   ' Power On
                HandlePowerOn(reportData)

            Case 10  ' Process Start
                HandleProcessStart(reportData)

            Case 11  ' Process Complete
                HandleProcessComplete(reportData)

            Case 50  ' Alarm Occurred
                HandleAlarm(reportData)

            Case Else
                LogWarning("Unknown event ID: " & eventId)
        End Select

        ' 发送 S6F12 确认
        SendEventAck(s6f11)
    End Sub

    Private Sub HandleAlarm(ByVal data As Dictionary(Of String, Object))
        Dim alarmCode As Integer = data("ALID")
        Dim alarmText As String = data("ALTX")

        Select Case alarmCode
            Case 1001  ' 通信失败
                HandleCommFailure(alarmText)

            Case 2001  ' 工艺异常
                HandleProcessError(alarmText)

            Case Else
                LogAlarm("AL" & alarmCode & ": " & alarmText)
        End Select
    End Sub

End Class
```

---

## 命令执行模式

### S2F41 控制命令

```vb
Public Class CommandExecutor

    Public Function SendCommand(ByVal commandName As String,
                               ByVal parameters As Dictionary(Of String, Object)) As Boolean
        ' 构造 S2F41 消息
        Dim s2f41 As New SECSMessage(2, 41)
        s2f41.AddItem("OCENAME", commandName)

        ' 添加参数
        For Each param In parameters
            s2f41.AddItem(param.Key, param.Value)
        Next

        ' 发送命令
        Dim s2f42 As SECSMessage = SendMessageWithRetry(
            s2f41,
            SECSConstants.T3_TIMEOUT,
            1  ' T3 不重试
        )

        If s2f42 IsNot Nothing AndAlso s2f42.Function = 42 Then
            Dim ackCode As Integer = s2f42.GetItem("ACKC5").GetValue()
            Return ackCode = 0  ' 0 = OK
        End If

        Return False
    End Function

    ''' <summary>
    ''' 启动设备
    ''' </summary>
    Public Function StartEquipment() As Boolean
        Dim params As New Dictionary(Of String, Object)
        params.Add("PROCESS_ID", strCurrentProcessId)
        Return SendCommand("START", params)
    End Function

    ''' <summary>
    ''' 暂停设备
    ''' </summary>
    Public Function PauseEquipment() As Boolean
        Return SendCommand("PAUSE", New Dictionary(Of String, Object))
    End Function

    ''' <summary>
    ''' 停止设备
    ''' </summary>
    Public Function StopEquipment() As Boolean
        Return SendCommand("STOP", New Dictionary(Of String, Object))
    End Function

End Class
```

---

## 数据收集模式

### Trace 数据收集

```vb
Public Class DataCollector

    Public Sub RequestTraceData(ByVal eventId As Integer)
        ' 发送 S6F15 请求事件数据
        Dim s6f15 As New SECSMessage(6, 15)
        s6f15.AddItem("CEID", eventId)
        s6f15.AddItem("DATAID", 0)

        SendMessage(s6f15, SECSConstants.T4_TIMEOUT)
    End Sub

    Public Sub HandleTraceData(ByVal s6f23 As SECSMessage)
        ' 解析 S6F23 Trace 数据
        Dim traceData As List(Of Dictionary(Of String, Object)) =
            ParseTraceData(s6f23)

        ' 保存到数据库
        For Each data In traceData
            SaveTraceData(data)
        Next
    End Sub

    Private Function ParseTraceData(ByVal msg As SECSMessage) _
        As List(Of Dictionary(Of String, Object))

        Dim result As New List(Of Dictionary(Of String, Object))

        ' 获取变量列表
        Dim varList As List(Of Object) = msg.GetItem("V").GetList()

        For Each var In varList
            Dim rowData As New Dictionary(Of String, Object)
            ' 解析变量名和值
            rowData.Add("NAME", var("NAME"))
            rowData.Add("VALUE", var("VALUE"))
            result.Add(rowData)
        Next

        Return result
    End Function

End Class
```

---

## 设备模板模式

### 添加新设备模板

```vb
' === 设备配置常量 ===
Public Class EquipmentConfig
    Public Const EQUIPMENT_ID As String = "EQxxx"      ' [必改] 设备ID
    Public Const EQUIPMENT_TYPE As String = "GROWTH"   ' [必改] 设备类型
    Public Const IP_ADDRESS As String = "192.168.1.xxx" ' [必改] IP地址
    Public Const PORT As Integer = 5000                ' [必改] 端口
End Class

' === 设备特定事件处理 ===
Private Sub HandleEquipmentSpecificEvent(ByVal eventId As Integer,
                                         ByVal data As Dictionary(Of String, Object))
    Select Case eventId
        Case 100  ' 设备特定事件
            ' [可选] 根据需要修改
        Case Else
            ' [禁止] 不要修改通用处理
            MyBase.HandleEvent(eventId, data)
    End Select
End Sub

' === 设备特定命令 ===
Public Function SendEquipmentCommand(ByVal cmd As String) As Boolean
    ' [可选] 根据需要添加设备特定命令
    Return SendCommand(cmd, New Dictionary(Of String, Object))
End Function
```

---

## 相关文档

- [编码规范](coding-standards.md)
- [调试指南](debugging.md)
- [SECS/GEM 参考](secs-gem-reference.md)
