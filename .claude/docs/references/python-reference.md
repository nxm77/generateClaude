# Python 本地参考

> **更新:** 2025-03-22

---

## PEP 8 编码规范

### 命名约定

```python
# 类: PascalCase
class DeviceCommunicator:
    pass

# 函数/变量: snake_case
def establish_connection():
    pass

device_count = 0

# 常量: UPPER_SNAKE_CASE
MAX_RETRY_COUNT = 3
CONNECTION_TIMEOUT = 60

# 私有成员: _前缀
class MyClass:
    def __init__(self):
        self._internal_value = 0  # 受保护
        self.__private_value = 0   # 私有（名称改写）
```

### 代码风格

```python
# ✅ 缩进使用 4 空格
def process_device(device_id):
    if device_id:
        return get_device(device_id)

# ✅ 每行不超过 88-100 字符
# ✅ 空行分隔（2 行顶层，1 行方法内）
class Device:
    """设备类"""

    def __init__(self, device_id):
        self.device_id = device_id

    def connect(self):
        """建立连接"""
        pass


# ✅ 导入顺序
# 1. 标准库
import os
import sys
from datetime import datetime

# 2. 第三方库
import requests
from sqlalchemy import Column, Integer

# 3. 本地模块
from myapp.models import Device
from myapp.utils import parse_id
```

---

## 类型注解

```python
# ✅ 基本类型注解
def add(a: int, b: int) -> int:
    return a + b

# ✅ 可选类型
from typing import Optional

def get_device(device_id: str) -> Optional[Device]:
    return devices.get(device_id)

# ✅ 列表/字典
from typing import List, Dict

def get_all_devices() -> List[Device]:
    return list(devices.values())

def get_device_map() -> Dict[str, Device]:
    return devices

# ✅ 联合类型 (Python 3.10+)
def process(value: int | str | None) -> str:
    return str(value)

# ✅ 泛型
from typing import TypeVar, Sequence

T = TypeVar('T')

def first(items: Sequence[T]) -> T | None:
    return items[0] if items else None
```

---

## 异步编程

### asyncio

```python
import asyncio

# ✅ 异步函数
async def fetch_device(device_id: str) -> Device:
    await asyncio.sleep(0.1)  # 模拟 IO
    return Device(device_id)

# ✅ 并发执行
async def main():
    results = await asyncio.gather(
        fetch_device("EQ001"),
        fetch_device("EQ002"),
        fetch_device("EQ003")
    )
    return results

# ✅ 超时控制
async def fetch_with_timeout(device_id: str):
    try:
        result = await asyncio.wait_for(
            fetch_device(device_id),
            timeout=5.0
        )
        return result
    except asyncio.TimeoutError:
        logger.warning(f"Timeout: {device_id}")

# ✅ 并发限制
async def fetch_all(device_ids: List[str]):
    semaphore = asyncio.Semaphore(10)

    async def limited_fetch(device_id: str):
        async with semaphore:
            return await fetch_device(device_id)

    return await asyncio.gather(
        *[limited_fetch(did) for did in device_ids]
    )
```

### async/await 最佳实践

```python
# ✅ 使用 run_coroutine_threadsafe 跨线程
import asyncio
from concurrent.futures import ThreadPoolExecutor

def sync_to_async(coroutine):
    loop = asyncio.get_event_loop()
    return asyncio.run_coroutine_threadsafe(
        coroutine,
        loop
    ).result()

# ✅ 在同步代码中运行异步
def main():
    result = asyncio.run(fetch_device("EQ001"))
    return result
```

---

## 上下文管理器

```python
# ✅ 基础上下文管理器
class DatabaseConnection:
    def __enter__(self):
        self.conn = self._connect()
        return self.conn

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.conn.close()
        return False  # 不抑制异常

# ✅ 使用
with DatabaseConnection() as conn:
    conn.execute("SELECT * FROM devices")

# ✅ contextlib 简化
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.time()
    yield
    elapsed = time.time() - start
    print(f"{name}: {elapsed:.3f}s")

# ✅ 异步上下文管理器
from contextlib import asynccontextmanager

@asynccontextmanager
async def async_session():
    session = create_session()
    try:
        yield session
    finally:
        await session.close()
```

---

## 数据类

```python
from dataclasses import dataclass, field
from typing import List

# ✅ 基础数据类
@dataclass
class Device:
    device_id: str
    name: str
    state: str = "OFFLINE"  # 默认值

    def __post_init__(self):
        self.device_id = self.device_id.upper()

# ✅ 不可变数据类
@dataclass(frozen=True)
class Point:
    x: float
    y: float

# ✅ 字段默认值
@dataclass
class Batch:
    items: List[str] = field(default_factory=list)
    count: int = field(init=False)

    def __post_init__(self):
        self.count = len(self.items)

# ✅ slots 节省内存
@dataclass(slots=True)
class CompactDevice:
    id: str
    name: str
```

---

## 装饰器

```python
# ✅ 基础装饰器
def log_calls(func):
    def wrapper(*args, **kwargs):
        logger.info(f"Calling {func.__name__}")
        result = func(*args, **kwargs)
        logger.info(f"{func.__name__} returned {result}")
        return result
    return wrapper

@log_calls
def process_device(device_id: str):
    return get_device(device_id)

# ✅ 带参数装饰器
def retry(max_attempts: int, delay: float = 1.0):
    def decorator(func):
        async def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return await func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_attempts - 1:
                        raise
                    await asyncio.sleep(delay)
        return wrapper
    return decorator

@retry(max_attempts=3, delay=0.5)
async def fetch_device(device_id: str):
    ...
```

---

## 列表推导与生成器

```python
# ✅ 列表推导
squares = [x ** 2 for x in range(10)]
even_squares = [x ** 2 for x in range(10) if x % 2 == 0]

# ✅ 字典推导
device_map = {d.id: d for d in devices}
status_map = {d.id: d.state for d in devices if d.state == "ONLINE"}

# ✅ 生成器表达式（内存高效）
squares = (x ** 2 for x in range(1000000))
total = sum(squares)

# ✅ 生成器函数
def batch_iter(items, batch_size: int):
    for i in range(0, len(items), batch_size):
        yield items[i:i + batch_size]

for batch in batch_iter(large_list, 100):
    process_batch(batch)
```

---

## 异常处理

```python
# ✅ 具体异常
try:
    device = get_device(device_id)
except DeviceNotFoundError:
    logger.warning(f"Device not found: {device_id}")
except DatabaseError as e:
    logger.error(f"Database error: {e}")
    raise
else:
    # 无异常时执行
    logger.info(f"Got device: {device}")
finally:
    # 总是执行
    cleanup()

# ✅ 自定义异常
class DeviceError(Exception):
    """设备错误基类"""
    pass

class DeviceNotFoundError(DeviceError):
    def __init__(self, device_id: str):
        self.device_id = device_id
        super().__init__(f"Device '{device_id}' not found")

# ✅ 异常链
try:
    process_device(device_id)
except DeviceNotFoundError as e:
    raise ProcessingError(f"Failed to process {device_id}") from e
```

---

## 路径与文件操作

```python
from pathlib import Path

# ✅ Pathlib（推荐）
config_path = Path("config") / "settings.json"

# 读取
content = config_path.read_text()
lines = config_path.read_text().splitlines()

# 写入
config_path.write_text(json.dumps(config))
config_path.write_bytes(data)

# 检查
if config_path.exists():
    print(f"Size: {config_path.stat().st_size}")

# 遍历
for py_file in Path("src").rglob("*.py"):
    print(py_file)

# ✅ 临时文件
import tempfile

with tempfile.NamedTemporaryFile(mode='w', suffix='.txt') as f:
    f.write("temp data")
    temp_path = Path(f.name)
# 自动删除
```

---

## JSON 处理

```python
import json
from dataclasses import asdict
from typing import List, TypeVar, Type

T = TypeVar('T')

# ✅ 基础序列化
config = {"name": "test", "count": 10}
json_str = json.dumps(config, indent=2, ensure_ascii=False)
config = json.loads(json_str)

# ✅ 文件操作
config_path = Path("config.json")
config_path.write_text(json.dumps(config, indent=2))
config = json.loads(config_path.read_text())

# ✅ dataclass 序列化
@dataclass
class Device:
    id: str
    name: str

device = Device("EQ001", "设备1")
json_str = json.dumps(asdict(device), ensure_ascii=False)

# ✅ 自定义编码器
class DeviceEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Device):
            return {"id": obj.id, "name": obj.name}
        return super().default(obj)

json_str = json.dumps(device, cls=DeviceEncoder, ensure_ascii=False)
```

---

## 日志

```python
import logging

# ✅ 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ✅ 日志级别
logger.debug("调试信息")
logger.info("一般信息")
logger.warning("警告信息")
logger.error("错误信息")
logger.exception("异常（会记录堆栈）")

# ✅ 结构化日志
logger.info("Device connected", extra={
    "device_id": "EQ001",
    "ip": "192.168.1.100"
})
```

---

## 单元测试

```python
import pytest
from unittest.mock import Mock, AsyncMock, patch

# ✅ 基础测试
def test_add():
    assert add(1, 2) == 3

# ✅ 异步测试
@pytest.mark.asyncio
async def test_fetch_device():
    device = await fetch_device("EQ001")
    assert device.id == "EQ001"

# ✅ Mock
def test_with_mock():
    mock_repo = Mock()
    mock_repo.get_device.return_value = Device("EQ001")

    service = DeviceService(mock_repo)
    device = service.get_device("EQ001")

    assert device.id == "EQ001"
    mock_repo.get_device.assert_called_once_with("EQ001")

# ✅ 异步 Mock
@pytest.mark.asyncio
async def test_async_with_mock():
    mock_client = AsyncMock()
    mock_client.fetch_device.return_value = Device("EQ001")

    result = await mock_client.fetch_device("EQ001")
    assert result.id == "EQ001"

# ✅ Fixture
@pytest.fixture
def sample_device():
    return Device("EQ001", "测试设备")

def test_with_fixture(sample_device):
    assert sample_device.id == "EQ001"

# ✅ 参数化测试
@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

---

## 虚拟环境与依赖

```bash
# ✅ 虚拟环境
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
.venv\Scripts\activate     # Windows

# ✅ 依赖管理
pip freeze > requirements.txt
pip install -r requirements.txt

# ✅ pipenv
pipenv install requests
pipenv install --dev pytest
pipenv run python main.py

# ✅ poetry
poetry add requests
poetry add --group dev pytest
poetry run python main.py
```

---

## 常用库速查

```python
# requests - HTTP
import requests
response = requests.get("https://api.example.com/devices")
data = response.json()

# pydantic - 数据验证
from pydantic import BaseModel, validator

class Device(BaseModel):
    id: str
    name: str

    @validator('id')
    def id_must_be_uppercase(cls, v):
        if not v.isupper():
            raise ValueError('id must be uppercase')
        return v

# click - CLI
import click

@click.command()
@click.option('--count', default=1, help='Number of devices.')
def main(count):
    for i in range(count):
        print(f"Device {i}")

# rich - 终端输出
from rich.console import Console
from rich.table import Table

console = Console()
console.print("[bold green]Connected![/bold green]")

table = Table(title="Devices")
table.add_column("ID", style="cyan")
table.add_column("Name", style="magenta")
console.print(table)
```

---

相关文档:
- [更多 Python 最佳实践](https://docs.python.org/3/参考/本地参考-离线-版本)
