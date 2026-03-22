# VUE 通用技能

> **更新:** 2025-03-22

---

## 概述

VUE 通用编程技能，支持 Vue 2 和 Vue 3。

---

## 核心规范

### 版本支持
- **Vue 3** - 首选，使用 Composition API
- **Vue 2** - 兼容支持，使用 Options API

### TypeScript
- 推荐使用 TypeScript
- 类型定义完整

### 代码风格
- 单文件不超过 300 行
- 组件职责单一
- 使用 Composition API 组织逻辑

---

## 组件规范

### 命名
- 组件文件: PascalCase (如 UserProfile.vue)
- 组件注册: PascalCase 或 kebab-case

### Props
- 使用 TypeScript 定义类型
- 提供默认值
- 验证必填项

### Events
- 使用 kebab-case 命名事件
- 提供事件参数类型

---

## 测试

### 框架
- Vitest (Vue 3)
- Jest (Vue 2)
- Vue Test Utils

### 覆盖率目标
- 组件测试覆盖率 > 80%

---

## 相关技能

- `.claude/skills/vue` - 本技能

---

## 详细规范

### 版本参考

| 版本 | 参考文档 |
|------|---------|
| Vue 3 | [Vue 3 本地参考](../docs/references/vue3-reference.md) |
| Vue 2 | [Vue 2 本地参考](../docs/references/vue2-reference.md) |
