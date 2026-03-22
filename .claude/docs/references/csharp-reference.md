# C# 本地参考

> **更新:** 2025-03-22

---

## 核心规范

### 命名约定

```csharp
// 类: PascalCase
public class DeviceCommunicator { }

// 接口: I 前缀 + PascalCase
public interface ICommunicator { }

// 方法: PascalCase
public void EstablishConnection() { }

// 属性: PascalCase
public int DeviceId { get; set; }

// 字段: _camelCase (私有), PascalCase (公共常量)
private int _deviceId;
public const int MaxRetry = 3;

// 局部变量: camelCase
int deviceCount = 0;
```

### 属性定义

```csharp
// ✅ 自动属性
public string Name { get; set; }

// ✅ 只读属性
public string Id { get; }

// ✅ 带默认值
public int Count { get; set; } = 0;

// ✅ 私有 set
public string Status { get; private set; }

// ✅ 表达式主体
public string FullName => $"{FirstName} {LastName}";

// ✅ 验证
private string _email;
public string Email
{
    get => _email;
    set => _email = !string.IsNullOrEmpty(value) ? value : throw new ArgumentException();
}
```

---

## 现代语言特性

### 模式匹配

```csharp
// 类型模式
if (obj is string str)
{
    Console.WriteLine(str.Length);
}

// switch 表达式 (C# 8+)
string message = status switch
{
    DeviceState.Online => "设备在线",
    DeviceState.Offline => "设备离线",
    DeviceState.Error => "设备故障",
    _ => "未知状态"
};

// 属性模式
if (device is { State: DeviceState.Online, Type: "GROWTH" })
{
    // 处理
}
```

### 记录类型 (C# 9+)

```csharp
// ✅ 不可变记录
public record Device(string Id, string Name, DeviceState State);

// ✅ 可变记录
public record DeviceConfig
{
    public string IpAddress { get; init; }
    public int Port { get; init; }
};

// ✅ with 表达式创建副本
var newDevice = device with { Name = "新设备" };
```

### 异步流 (C# 8+)

```csharp
public async IAsyncEnumerable<Device> GetDevicesAsync()
{
    await foreach (var device in _deviceSource.ReadAllAsync())
    {
        yield return device;
    }
}

// 消费
await foreach (var device in GetDevicesAsync())
{
    Console.WriteLine(device.Name);
}
```

---

## 异步编程

### async/await

```csharp
// ✅ 正确的异步方法
public async Task<Device> GetDeviceAsync(string id)
{
    var device = await _repository.FindAsync(id);
    return device;
}

// ✅ 使用 CancellationToken
public async Task<Device> GetDeviceAsync(string id, CancellationToken ct = default)
{
    var device = await _repository.FindAsync(id, ct);
    return device;
}

// ✅ 正确取消
public async Task ProcessAsync(CancellationToken ct)
{
    while (!ct.IsCancellationRequested)
    {
        await DoWorkAsync(ct);
    }
}

// ❌ 避免 async void
private async void Button_Click(object sender, EventArgs e)
{
    // 只用于事件处理
}
```

### Task 配置

```csharp
// ✅ ConfigureAwait(false) - 库代码
public async Task ProcessAsync()
{
    await Task.Delay(1000).ConfigureAwait(false);
    // 后续代码不回到原始上下文
}

// ✅ 不使用 ConfigureAwait - UI/应用代码
public async Task UpdateAsync()
{
    await Task.Delay(1000);
    // 回到原始上下文（如 UI 线程）
}
```

---

## 依赖注入

### 服务注册

```csharp
// ✅ 构造函数注入
public class DeviceService
{
    private readonly IDeviceRepository _repository;
    private readonly ILogger<DeviceService> _logger;

    public DeviceService(IDeviceRepository repository, ILogger<DeviceService> logger)
    {
        _repository = repository;
        _logger = logger;
    }
}

// ✅ 注册服务
builder.Services.AddScoped<IDeviceService, DeviceService>();
builder.Services.AddSingleton<IMessageQueue, RabbitMqQueue>();
builder.Services.AddTransient<IProcessor, DeviceProcessor>();
```

### 生命周期

| 生命周期 | 说明 | 适用场景 |
|---------|------|---------|
| Singleton | 单例，整个应用生命周期 | 无状态服务、配置 |
| Scoped | 作用域，每次请求一个实例 | EF DbContext、业务服务 |
| Transient | 瞬态，每次获取新实例 | 轻量无状态服务 |

---

## 异常处理

```csharp
// ✅ 异常过滤
try
{
    await ProcessAsync();
}
catch (TimeoutException ex) when (ex.Message.Contains("device"))
{
    // 只处理设备超时
}

// ✅ 抛出异常
public Device GetDevice(string id)
{
    return _devices.TryGetValue(id, out var device)
        ? device
        : throw new DeviceNotFoundException(id);
}

// ✅ 自定义异常
public class DeviceNotFoundException : Exception
{
    public string DeviceId { get; }

    public DeviceNotFoundException(string deviceId)
        : base($"Device '{deviceId}' not found")
    {
        DeviceId = deviceId;
    }
}
```

---

## LINQ

```csharp
// ✅ 查询语法
var onlineDevices = from d in devices
                    where d.State == DeviceState.Online
                    orderby d.Name
                    select d;

// ✅ 方法语法
var onlineDevices = devices
    .Where(d => d.State == DeviceState.Online)
    .OrderBy(d => d.Name);

// ✅ 即时执行
var firstOnline = devices.First(d => d.State == DeviceState.Online);
var anyOnline = devices.Any(d => d.State == DeviceState.Online);

// ✅ 聚合
var count = devices.Count();
var sum = devices.Sum(d => d.Capacity);
var avg = devices.Average(d => d.Capacity);

// ✅ 分组
var grouped = devices
    .GroupBy(d => d.Type)
    .Select(g => new { Type = g.Key, Count = g.Count() });
```

---

## 集合与字典

```csharp
// ✅ 字典初始化
var deviceMap = new Dictionary<string, Device>
{
    ["EQ001"] = new Device("EQ001"),
    ["EQ002"] = new Device("EQ002")
};

// ✅ 安全访问
if (deviceMap.TryGetValue("EQ001", out var device))
{
    Console.WriteLine(device.Name);
}

// ✅ 集合表达式 (C# 12+)
HashSet<string> onlineDeviceIds = [eq1.Id, eq2.Id, eq3.Id];

// ✅ Span<T> 零拷贝
Span<char> chars = stackalloc char[100];
```

---

## 字符串处理

```csharp
// ✅ 字符串插值
string message = $"设备 {deviceId} 状态为 {status}";

// ✅ 复合格式化
string message = string.Format("设备 {0} 状态为 {1}", deviceId, status);

// ✅ 原始字符串 (C# 11+)
string json = """
    {
        "deviceId": "EQ001",
        "status": "online"
    }
    """;

// ✅ StringBuilder 处理大量拼接
var sb = new StringBuilder();
for (int i = 0; i < 1000; i++)
{
    sb.AppendLine($"Item {i}");
}
```

---

## 日期时间

```csharp
// ✅ 使用 DateTime
var now = DateTime.Now;
var utcNow = DateTime.UtcNow;
var tomorrow = now.AddDays(1);

// ✅ 时间计算
var elapsed = DateTime.Now - startTime;
if (elapsed > TimeSpan.FromSeconds(30))
{
    // 超时
}

// ✅ DateOnly / TimeOnly (C# 11+)
DateOnly date = new DateOnly(2025, 3, 22);
TimeOnly time = new TimeOnly(14, 30);

// ✅ DateTime 分析
if (DateTime.TryParse(input, out var dateTime))
{
    // 成功
}
```

---

## 文件 I/O

```csharp
// ✅ 异步文件读取
string content = await File.ReadAllTextAsync(path);
string[] lines = await File.ReadAllLinesAsync(path);

// ✅ 异步文件写入
await File.WriteAllTextAsync(path, content);
await File.AppendAllLinesAsync(path, lines);

// ✅ 流处理
await using var stream = File.OpenRead(path);
await using var reader = new StreamReader(stream);
var line = await reader.ReadLineAsync();

// ✅ using 声明 (自动释放)
using var scope = _serviceProvider.CreateScope();
```

---

## 最佳实践

### IDisposable

```csharp
// ✅ using 语句
using (var connection = new DatabaseConnection(connectionString))
{
    connection.Open();
    // 自动 Dispose
}

// ✅ using 声明
using var connection = new DatabaseConnection(connectionString);
connection.Open();
// 代码块结束时自动 Dispose
```

### NULL 处理

```csharp
// ✅ 可空值类型
int? count = null;
if (count.HasValue)
{
    Console.WriteLine(count.Value);
}

// ✅ 空合并运算符
string name = device.Name ?? "未命名";
int count = device?.Count ?? 0;

// ✅ 空条件运算符
int? length = device?.Name?.Length;

// ✅ null-forgiving（确认非空）
string name = device.Name!; // 我知道它不为 null
```

### 性能考虑

```csharp
// ✅ StringBuilder 大量字符串拼接
var sb = new StringBuilder();
for (int i = 0; i < 1000; i++)
{
    sb.Append(i);
}

// ✅ Span<T> 避免分配
Span<int> numbers = stackalloc int[100];

// ✅ 避免不必要的 LINQ
// ❌ 低效
var count = devices.Count(d => d.Id == targetId);
// ✅ 高效
var count = devices.Count(d => d.Id == targetId);
```

---

相关文档:
- [.NET 编码规范](dotnet-coding-standards.md)
