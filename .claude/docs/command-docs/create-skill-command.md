# /create-skill 命令说明

> **类别:** 技能生成
> **更新:** 2025-03-22

---

## 功能

深入分析项目代码，生成项目 Skill。

---

## 用法

```
/create-skill [--scope] [--depth]
```

---

## 选项

| 参数 | 值 | 说明 |
|------|-----|------|
| --scope | all \| core \| module | 分析范围 |
| --depth | quick \| standard \| deep | 分析深度 |

### scope 说明
- `all` - 分析所有代码
- `core` - 仅核心模块
- `module` - 指定模块

### depth 说明
- `quick` - 快速扫描，生成基础信息
- `standard` - 标准分析，包含模式和规范
- `deep` - 深度分析，包含完整文档

---

## 输出

生成 `.claude/skills/<project-name>/` 目录：
- SKILL.md
- coding-standards.md
- patterns.md
- debugging.md

---

## 示例

```bash
# 标准分析
/create-skill --scope all --depth standard

# 快速扫描核心模块
/create-skill --scope core --depth quick

# 输出:
# ✅ Project Skill 已创建
# 📁 .claude/skills/my-project/
# 📄 4 个文件已生成
```

---

## 注意事项

- deep 模式耗时较长
- 大型项目建议使用 core 或 standard
- 输出需人工审核和调整
