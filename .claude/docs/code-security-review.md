# 代码审查与安全审查机制

> **版本:** v1.0
> **日期:** 2026-03-22
> **来源:** everything-claude-code (ECC)

---

## 1. 双重审查机制

```
┌─────────────────────────────────────────────────────────┐
│                    代码提交流程                          │
└─────────────────────────────────────────────────────────┘

  代码编写
      ↓
  ┌─────────────────────────────────────┐
  │ Code Reviewer                       │
  │ ├── 代码质量检查                    │
  │ ├── 编码规范验证                    │
  │ ├── 性能问题识别                    │
  │ └── 可维护性评估                    │
  └─────────────────────────────────────┘
      ↓
  ┌─────────────────────────────────────┐
  │ Security Reviewer                   │
  │ ├── 注入攻击检查                    │
  │ ├── 权限问题识别                    │
  │ ├── 敏感数据处理                    │
  │ └── 依赖安全扫描                    │
  └─────────────────────────────────────┘
      ↓
  审查通过 → 合并
```

---

## 2. Code Review (代码审查)

### 2.1 使用方式

```bash
# 命令方式
/review

# 技能调用
everything-claude-code:code-reviewer
```

### 2.2 检查项

| 类别 | 检查项 | 说明 |
|------|--------|------|
| **代码质量** | 命名规范 | 变量/函数/类命名 |
| | 代码结构 | 模块划分、职责分离 |
| | 注释文档 | 关键逻辑是否有注释 |
| | 代码重复 | 是否有重复代码 |
| **编码规范** | 语言规范 | C++ Core Guidelines / PEP 8 |
| | 项目规范 | 项目特定约定 |
| | 文件长度 | 单文件不超过限制 |
| | 函数长度 | 单函数不超过限制 |
| **性能** | 算法复杂度 | 圈复杂度 |
| | 资源管理 | 内存/连接管理 |
| | 并发问题 | 线程安全 |
| **可维护性** | 测试覆盖 | 单元测试覆盖 |
| | 错误处理 | 异常处理完整性 |

### 2.3 输出示例

```
Code Review Report
==================

文件: src/DeviceCommunicator.cpp
总计: 12 条建议

[问题]
❌ L45: 函数 establishConnection() 长度超过 100 行
❌ L78: 使用裸指针 owning，建议使用 shared_ptr
⚠️ L120: 缺少错误处理

[建议]
✓ 建议将 establishConnection() 拆分为更小的函数
✓ 使用 RAII 管理连接资源

[统计]
- 代码行数: 450
- 函数数量: 12
- 最大函数长度: 115 行 (超标)
- 圈复杂度: 8 (合格)
```

---

## 3. Security Review (安全审查)

### 3.1 使用方式

```bash
# 命令方式
/security-review

# 技能调用
everything-claude-code:security-reviewer
```

### 3.2 检查项

| 类别 | 检查项 | 说明 |
|------|--------|------|
| **注入攻击** | SQL 注入 | 用户输入拼接 SQL |
| | 命令注入 | 系统命令执行 |
| | XSS | 前端输出转义 |
| **认证授权** | 权限检查 | 敏感操作权限验证 |
| | 会话管理 | Token/Session 安全 |
| | 密码处理 | 密码存储和传输 |
| **数据安全** | 敏感数据 | 密码/密钥处理 |
| | 数据加密 | 传输/存储加密 |
| | 日志脱敏 | 避免日志泄露 |
| **依赖安全** | 已知漏洞 | 依赖包漏洞扫描 |
| | 版本管理 | 使用最新版本 |

### 3.3 MES/EAP 特定安全检查

| 检查项 | 说明 |
|--------|------|
| **SECS/GEM 消息** | 消息验证，防止恶意消息 |
| **设备控制** | 控制命令权限检查 |
| **状态转换** | 非法状态转换防护 |
| **数据库操作** | 设备数据访问控制 |
| **日志记录** | 敏感操作审计日志 |

### 3.4 输出示例

```
Security Review Report
=====================

文件: src/DeviceCommunicator.cpp
严重程度: 2 高 | 3 中 | 4 低

[高危]
🔴 L67: SQL 查询拼接用户输入，存在注入风险
   Code: string sql = "SELECT * FROM devices WHERE id = " + userInput;
   Fix: 使用参数化查询

🔴 L112: 设备控制命令缺少权限验证
   Fix: 添加权限检查

[中危]
🟡 L89: 错误消息包含设备 IP，可能泄露信息
   Fix: 脱敏处理

🟡 L145: 硬编码数据库连接字符串
   Fix: 使用配置文件/环境变量

[低危]
🟢 L200: 缺少操作审计日志
   Fix: 添加日志记录

[依赖安全]
✓ 未发现已知漏洞的依赖包
⚠️ Boost 1.74 建议升级到 1.80+
```

---

## 4. 自动化审查集成

### 4.1 Pre-commit Hook

```bash
#!/bin/bash
# .claude/hooks/pre-commit/security-check.sh

# 检测敏感文件变更
if git diff --cached --name-only | grep -E "\.(cpp|vb|java|vue)$"; then
    echo "检测到代码变更，运行安全审查..."
    # 调用 security-reviewer
fi

# 检测敏感操作
if git diff --cached | grep -E "password|token|secret|sql.*\+"; then
    echo "⚠️ 检测到可能的敏感操作，请确认"
fi
```

### 4.2 CI/CD 集成

```yaml
# .github/workflows/review.yml
name: Code & Security Review

on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - name: Code Review
        run: claude-code /review

      - name: Security Review
        run: claude-code /security-review

      - name: Report
        if: failure()
        run: echo "审查未通过，请修复问题"
```

---

## 5. 审查触发时机

| 时机 | 触发审查 | 说明 |
|------|---------|------|
| 代码提交前 | `/review` + `/security-review` | 开发者主动触发 |
| Pre-commit | 自动（可选） | 提交前自动检查 |
| 创建 MR/PR | 自动 | GitLab/GitHub 集成 |
| 更新 MR/PR | 自动 | 代码变更后重新审查 |
| 定期审查 | 每周 | 全面审查代码库 |

---

## 6. 审查结果处理

### 6.1 结果分级

| 级别 | 处理方式 |
|------|---------|
| **通过** | 可以合并 |
| **有建议** | 建议修复，可选 |
| **有问题** | 必须修复后合并 |
| **严重** | 阻止合并，必须修复 |

### 6.2 修复验证

```
审查发现问题
    ↓
开发者修复
    ↓
提交修复
    ↓
重新审查
    ↓
  通过 → 合并
    ↓
  不通过 → 继续修复
```

---

## 7. 与 ECC 插件的对应

| 功能 | ECC 技能 | 命令 |
|------|---------|------|
| 代码审查 | code-reviewer | `/review` |
| 安全审查 | security-reviewer | `/security-review` |
| Python 审查 | python-reviewer | `/review:python` |
| Go 审查 | go-reviewer | `/review:go` |
| 数据库审查 | database-reviewer | `/review:db` |

---

## 8. MES/EAP 特定审查规则

### 8.1 C++ (MES)

```cpp
// ❌ 不安全: 裸指针拥有所有权
Device* device = new Device("EQ001");

// ✅ 安全: 智能指针
auto device = std::make_shared<Device>("EQ001");

// ❌ 不安全: SQL 注入风险
string sql = "SELECT * FROM devices WHERE id = " + id;

// ✅ 安全: 参数化查询
// 使用绑定变量或 ORM
```

### 8.2 VB.NET (EAP)

```vb
' ❌ 不安全: 全局共享状态
Public Shared CurrentState As String

' ✅ 安全: 线程安全封装
Public Class DeviceState
    Private _syncLock As New Object()
    Private _state As String

    Public Property State As String
        Get
            SyncLock _syncLock
                Return _state
            End SyncLock
        End Get
    End Property
End Class
```

---

**文档版本:** v1.0
**最后更新:** 2026-03-22
