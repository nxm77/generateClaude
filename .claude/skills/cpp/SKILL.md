# C++ 通用技能

> **更新:** 2025-03-22

---

## 概述

C++ 通用编程技能，适用于非 MES 的 C++ 项目。

---

## 核心规范

### 语言版本
- 使用 C++17 或更高版本
- 遵循 C++ Core Guidelines

### 内存管理
- 智能指针管理内存 (std::unique_ptr, std::shared_ptr)
- RAII 模式管理资源
- 避免裸指针 owning

### 代码风格
- 单文件不超过 1000 行
- 函数不超过 100 行
- 圈复杂度不超过 10

---

## 测试

### 框架
- Google Test
- Catch2

### 覆盖率目标
- 单元测试覆盖率 > 80%

---

## 相关技能

- `.claude/skills/mes` - MES 专用 (优先使用 MES 技能)
- `.claude/skills/cpp` - 本技能 (通用 C++)

---

## 详细规范

详见 [C++ Core Guidelines 本地参考](../docs/references/cpp-core-guidelines.md)
