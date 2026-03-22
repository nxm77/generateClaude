# /learn 命令说明

> **类别:** 知识积累
> **更新:** 2025-03-22

---

## 功能

记录 AI 编码经验，积累项目知识。

---

## 用法

```
/learn --type <类型> "<内容>"
```

---

## 类型

| 类型 | 说明 | 示例 |
|------|------|------|
| error | 编码错误 | C++ 智能指针循环引用导致内存泄漏 |
| pattern | 代码模式 | SECS/GEM 通信握手模式 |
| performance | 性能优化 | 使用 move 语义减少拷贝 |
| anti-pattern | 反模式 | 避免在循环中创建数据库连接 |
| convention | 编码规范 | VB.NET 使用 Option Strict On |
| debug | 调试经验 | GDB 调试多线程程序 |

---

## 输出

追加到 `.claude/lessons.md`

---

## 示例

```bash
# 记录错误经验
/learn --type error "C++ shared_ptr 循环引用导致内存泄漏，使用 weak_ptr 解决"

# 记录代码模式
/learn --type pattern "EAP 设备状态机使用 6 状态模型"

# 记录编码规范
/learn --type convention "MES C++ 代码使用智能指针管理内存"

# 输出:
# ✅ 已记录到 lessons.md
# 📚 类型: error
```

---

## 注意事项

- 记录前确认内容准确
- 使用简洁明确的语言
- 包含解决方案或最佳实践
