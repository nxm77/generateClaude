# .NET 编码规范本地参考

> **更新:** 2025-03-22

---

## 核心规范

### 语言选项

```vb
' ✅ 文件顶部必须声明
Option Strict On
Option Explicit On
```

### 命名约定

```vb
' 类: PascalCase
Public Class DeviceCommunicator
End Class

' 方法: PascalCase
Public Function EstablishConnection() As Boolean
End Function

' 接口: I 前缀 + PascalCase
Public Interface ICommunicator
End Interface

' 变量: camelCase 或匈牙利命名法
Dim deviceId As String
Dim strDeviceId As String  ' 匈牙利命名法
Dim intRetryCount As Integer
```

### 控件命名

| 前缀 | 控件类型 | 示例 |
|------|---------|------|
| btn | Button | btnConnect |
| txt | TextBox | txtDeviceId |
| lbl | Label | lblStatus |
| chk | CheckBox | chkEnabled |
| cmb | ComboBox | cmbEquipmentType |
| lst | ListBox | lstEvents |

### 错误处理

```vb
' ✅ 使用 Try Catch
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

' ❌ 避免 On Error Resume Next
' 不要使用！
```

### 字符串处理

```vb
' ✅ 使用 StringBuilder 处理大量字符串
Dim sb As New System.Text.StringBuilder()
For Each item In items
    sb.AppendLine(item.ToString())
Next
Dim result As String = sb.ToString()

' ✅ 使用字符串插值
Dim message As String = $"Device {deviceId} is {status}"
```

### 事件处理

```vb
' ✅ 使用 Handles
Public Class MainForm
    Private Sub btnConnect_Click(ByVal sender As Object,
                                ByVal e As EventArgs) _
                            Handles btnConnect.Click
        ConnectToDevice()
    End Sub
End Class

' ✅ 使用 AddHandler 动态绑定
Public Sub RegisterEventHandler()
    AddHandler communicator.DataReceived,
        AddressOf OnDataReceived
End Sub
```

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

End Class
```

---

相关文档:
- [VB.NET Skill](../../skills/vbnet/SKILL.md)
- [EAP 编码规范](../../skills/eap/coding-standards.md)
