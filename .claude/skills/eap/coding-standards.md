# EAP 编码规范

> **系统:** Equipment Automation Program
> **语言:** VB.NET
> **更新:** 2025-03-22

---

## 核心原则

### 1. Option Strict On

```vb
' ✅ 正确 - 文件顶部必须声明
Option Strict On
Option Explicit On

Public Class DeviceCommunicator
    ' 编译时类型检查
End Class
```

### 2. 命名约定

**匈牙利命名法（项目现有风格）：**

```vb
' ✅ 正确
Dim strDeviceId As String
Dim intRetryCount As Integer
Dim objCommunicator As Object
Dim blnIsOnline As Boolean

' 控件命名
Dim btnConnect As Button
Dim txtDeviceId As TextBox
Dim lblStatus As Label
```

**类命名：**

```vb
' PascalCase
Public Class SECSCommunicator
End Class

Public Class EventHandler
End Class
```

**方法命名：**

```vb
' PascalCase
Public Function EstablishConnection() As Boolean
End Function

Public Sub ProcessEvent(ByVal eventData As EventData)
End Sub
```

### 3. 错误处理

```vb
' ✅ 正确 - 使用 Try Catch
Public Function SendMessage(ByVal msg As SECSMessage) As Boolean
    Try
        communicator.Send(msg)
        Return True
    Catch ex As TimeoutException
        LogError("Send timeout: " & ex.Message)
        Return False
    Catch ex As Exception
        LogError("Send failed: " & ex.Message)
        Throw
    End Try
End Function

' ❌ 错误 - 避免 On Error Resume Next
Public Function SendMessage(ByVal msg As SECSMessage) As Boolean
    On Error Resume Next  ' 不要使用！
    communicator.Send(msg)
    Return Err.Number = 0
End Function
```

### 4. 事件处理

```vb
' ✅ 正确 - 使用 Handles
Public Class MainForm
    Private Sub btnConnect_Click(ByVal sender As Object,
                                ByVal e As EventArgs) _
                            Handles btnConnect.Click
        ConnectToDevice()
    End Sub
End Class

' ✅ 正确 - 使用 AddHandler 动态绑定
Public Sub RegisterEventHandler()
    AddHandler communicator.DataReceived,
        AddressOf OnDataReceived
End Sub

Private Sub OnDataReceived(ByVal sender As Object,
                          ByVal e As DataEventArgs)
    ProcessData(e.Data)
End Sub
```

---

## 文件结构

### 文件长度限制

| 文件类型 | 最大行数 |
|---------|---------|
| .vb | 1000 行 |

### 函数长度限制

- 单函数/方法不超过 **100 行**
- 复杂逻辑拆分为子过程

---

## 代码组织

### Region 组织

```vb
Public Class DeviceCommunicator

#Region "成员变量"
    Private strDeviceId As String
    Private objStateManager As StateManager
#End Region

#Region "构造函数"
    Public Sub New(ByVal deviceId As String)
        strDeviceId = deviceId
    End Sub
#End Region

#Region "公共方法"
    Public Function Connect() As Boolean
        ' ...
    End Function
#End Region

#Region "私有方法"
    Private Sub LogMessage(ByVal msg As String)
        ' ...
    End Sub
#End Region

End Class
```

---

## 注释规范

### 类注释

```vb
''' <summary>
''' 设备通信器
''' </summary>
''' <remarks>
''' 负责与半导体设备的 SECS/GEM 通信
''' 支持超时重试和状态管理
''' </remarks>
Public Class SECSCommunicator
    ' ...
End Class
```

### 方法注释

```vb
''' <summary>
''' 建立设备通信连接
''' </summary>
''' <param name="deviceId">设备 ID</param>
''' <returns>True 表示成功，False 表示失败</returns>
''' <exception cref="TimeoutException">通信超时</exception>
Public Function EstablishConnection(ByVal deviceId As String) As Boolean
    ' ...
End Function
```

---

## SECS/GEM 通信规范

### 超时设置

```vb
' ✅ 正确 - 使用常量定义超时
Public Class SECSConstants
    Public Const T1_TIMEOUT As Integer = 5000  ' 5秒 - 通信建立
    Public Const T2_TIMEOUT As Integer = 3000  ' 3秒 - 在线请求
    Public Const T3_TIMEOUT As Integer = 10000 ' 10秒 - 控制命令
    Public Const T4_TIMEOUT As Integer = 60000 ' 60秒 - 数据收集

    Public Const MAX_RETRY_T1 As Integer = 3
    Public Const MAX_RETRY_T2 As Integer = 5
End Class
```

### 消息发送

```vb
' ✅ 正确 - 带重试的消息发送
Public Function SendMessageWithRetry(ByVal msg As SECSMessage,
                                     ByVal timeout As Integer,
                                     ByVal maxRetry As Integer) As SECSMessage
    Dim intRetry As Integer = 0

    Do While intRetry < maxRetry
        Try
            Dim response = SendMessage(msg, timeout)
            If response IsNot Nothing Then
                Return response
            End If
        Catch ex As TimeoutException
            LogWarning("Send timeout, retry " & intRetry + 1)
        End Try
        intRetry += 1
        Threading.Thread.Sleep(timeout)
    Loop

    Return Nothing
End Function
```

---

## 性能考虑

### 避免不必要的类型转换

```vb
' ✅ 正确 - 使用正确类型
Dim intCount As Integer = 100

' ❌ 错误 - 不必要的转换
Dim intCount As Integer = CInt("100")
```

### 使用 StringBuilder

```vb
' ✅ 正确 - 大量字符串拼接
Dim sb As New StringBuilder()
For Each item In items
    sb.AppendLine(item.ToString())
Next
Dim result As String = sb.ToString()

' ❌ 错误 - 低效的字符串拼接
Dim result As String = ""
For Each item In items
    result &= item.ToString() & vbCrLf
Next
```

---

## 相关文档

- [代码模式](patterns.md)
- [调试指南](debugging.md)
- [SECS/GEM 参考](secs-gem-reference.md)
