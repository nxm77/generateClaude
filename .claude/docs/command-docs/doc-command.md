# /doc 命令说明

> **类别:** 文档生成
> **更新:** 2025-03-22

---

## 功能

生成项目文档。

---

## 用法

```
/doc [--requirements] [--files] [--diagram]
```

---

## 选项

| 参数 | 功能 |
|------|------|
| --requirements | 生成需求文档 |
| --files | 生成文件结构文档 |
| --diagram <类型> | 生成图表 |

---

## 图表类型

| 类型 | 说明 |
|------|------|
| overview | 系统概览图 |
| architecture | 架构图 |
| flow | 流程图 |
| sequence | 时序图 |
| state | 状态机图 |

---

## 输出

生成 `docs/` 目录下的文档文件。

---

## 示例

```bash
# 生成需求文档
/doc --requirements

# 生成文件结构文档
/doc --files

# 生成系统概览图
/doc --diagram overview

# 输出:
# ✅ 文档已生成
# 📁 docs/requirements.md
# 📁 docs/files.md
# 📁 docs/diagrams/overview.puml
```

---

## 注意事项

- PUML 图表需下载到本地查看
- 文档生成后需人工审核
- 大型项目生成时间较长
