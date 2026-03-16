---
name: project-deep-analyzer
description: 深度分析项目代码，提取 API 端点、数据模型、业务流程和架构信息，生成结构化分析报告用于文档生成
---

# 项目深度分析 Skill

## 🎯 目标

深入分析项目代码，提取关键技术信息，生成结构化的分析报告，用于自动生成准确的技术文档。

## 📋 分析流程

### 阶段 1：项目扫描和初步分析

1. **扫描项目结构**
   - 识别项目根目录
   - 扫描所有源代码文件
   - 识别配置文件
   - 确定项目类型和技术栈

2. **确定分析策略**
   - 根据项目类型选择分析重点
   - 识别关键文件和目录
   - 确定需要深入分析的模块

### 阶段 2：深度代码分析

#### 2.1 API 端点分析

**目标**：提取所有 API 路由定义

**分析内容**：
- HTTP 方法（GET, POST, PUT, DELETE, PATCH）
- 路由路径和路径参数
- 查询参数
- 请求体结构
- 响应格式
- 认证和权限要求
- 中间件使用

**支持的框架**：
- Express.js: `app.get()`, `router.post()`, `app.use()`
- NestJS: `@Get()`, `@Post()`, `@Controller()`
- FastAPI: `@app.get()`, `@router.post()`
- Django: `path()`, `url()`, `@api_view()`
- Flask: `@app.route()`, `@blueprint.route()`
- Spring Boot: `@GetMapping`, `@PostMapping`, `@RestController`
- Gin (Go): `router.GET()`, `router.POST()`

**示例输出**：
```json
{
  "method": "POST",
  "path": "/api/users",
  "params": [],
  "query": [],
  "body": {
    "username": "string",
    "email": "string",
    "password": "string"
  },
  "auth": "JWT",
  "middleware": ["validateUser", "checkDuplicate"],
  "response": {
    "201": {"id": "number", "username": "string"},
    "400": {"error": "string"}
  }
}
```

#### 2.2 数据模型分析

**目标**：提取数据库模型和表结构

**分析内容**：
- 模型/实体类定义
- 字段名称和类型
- 主键和外键
- 索引定义
- 关系类型（一对一、一对多、多对多）
- 验证规则和约束
- 默认值

**支持的 ORM/框架**：
- Sequelize (Node.js)
- TypeORM (Node.js)
- Prisma (Node.js)
- SQLAlchemy (Python)
- Django ORM (Python)
- JPA/Hibernate (Java)
- GORM (Go)

**示例输出**：
```json
{
  "name": "User",
  "table": "users",
  "fields": [
    {
      "name": "id",
      "type": "integer",
      "primary_key": true,
      "auto_increment": true
    },
    {
      "name": "username",
      "type": "string",
      "unique": true,
      "nullable": false,
      "max_length": 50
    },
    {
      "name": "email",
      "type": "string",
      "unique": true,
      "nullable": false
    }
  ],
  "relationships": [
    {
      "type": "hasMany",
      "target": "Post",
      "foreign_key": "user_id"
    }
  ],
  "indexes": [
    {"fields": ["email"], "unique": true},
    {"fields": ["username"], "unique": true}
  ]
}
```

#### 2.3 业务流程分析

**目标**：识别核心业务逻辑和流程

**分析内容**：
- 服务层函数和方法
- 业务逻辑流程
- 事务处理
- 错误处理机制
- 数据验证逻辑
- 业务规则

**关注点**：
- 用户认证和授权流程
- 数据 CRUD 操作流程
- 支付/订单处理流程
- 通知/消息流程
- 文件上传/下载流程
- 批处理任务

**示例输出**：
```json
{
  "name": "用户注册流程",
  "steps": [
    {
      "step": 1,
      "action": "验证用户输入",
      "function": "validateUserInput",
      "validations": ["email格式", "密码强度", "用户名唯一性"]
    },
    {
      "step": 2,
      "action": "加密密码",
      "function": "hashPassword",
      "method": "bcrypt"
    },
    {
      "step": 3,
      "action": "创建用户记录",
      "function": "createUser",
      "transaction": true
    },
    {
      "step": 4,
      "action": "发送欢迎邮件",
      "function": "sendWelcomeEmail",
      "async": true
    },
    {
      "step": 5,
      "action": "生成 JWT Token",
      "function": "generateToken",
      "return": "token"
    }
  ],
  "error_handling": [
    "用户已存在 -> 返回 409",
    "邮件发送失败 -> 记录日志但不阻断",
    "数据库错误 -> 回滚事务"
  ]
}
```

#### 2.4 架构分析

**目标**：理解项目架构和设计模式

**分析内容**：
- 分层架构（Controller/Service/Repository）
- 中间件和拦截器
- 依赖注入
- 设计模式使用
- 配置管理
- 日志系统
- 缓存策略
- 错误处理机制

**示例输出**：
```json
{
  "architecture_pattern": "三层架构",
  "layers": {
    "controller": {
      "path": "src/controllers",
      "responsibility": "处理 HTTP 请求和响应"
    },
    "service": {
      "path": "src/services",
      "responsibility": "业务逻辑处理"
    },
    "repository": {
      "path": "src/repositories",
      "responsibility": "数据访问"
    }
  },
  "middleware": [
    {
      "name": "authMiddleware",
      "purpose": "JWT 认证",
      "order": 1
    },
    {
      "name": "errorHandler",
      "purpose": "统一错误处理",
      "order": 99
    }
  ],
  "design_patterns": [
    "Singleton (数据库连接)",
    "Factory (服务创建)",
    "Repository (数据访问)"
  ],
  "caching": {
    "enabled": true,
    "provider": "Redis",
    "strategy": "Cache-Aside"
  }
}
```

### 阶段 3：生成分析报告

**输出文件**：`.analysis-report.json`

**完整报告结构**：
```json
{
  "project_info": {
    "name": "项目名称",
    "type": "项目类型",
    "languages": ["语言列表"],
    "frameworks": ["框架列表"],
    "analyzed_at": "2026-03-17T10:30:00Z"
  },
  "api_endpoints": [
    {
      "method": "GET",
      "path": "/api/users/:id",
      "description": "获取用户信息",
      "auth": "JWT",
      "params": [...],
      "response": {...}
    }
  ],
  "data_models": [
    {
      "name": "User",
      "table": "users",
      "fields": [...],
      "relationships": [...]
    }
  ],
  "business_flows": [
    {
      "name": "用户注册流程",
      "steps": [...],
      "error_handling": [...]
    }
  ],
  "architecture": {
    "pattern": "三层架构",
    "layers": {...},
    "middleware": [...],
    "design_patterns": [...]
  },
  "statistics": {
    "total_endpoints": 25,
    "total_models": 8,
    "total_flows": 12,
    "code_files_analyzed": 156
  }
}
```

## 🔍 分析策略

### 对于不同项目类型的分析重点

#### 全栈 Web 应用
- ✅ API 端点（重点）
- ✅ 数据模型（重点）
- ✅ 业务流程（重点）
- ✅ 前端路由
- ✅ 状态管理

#### API 服务
- ✅ API 端点（核心）
- ✅ 数据模型（核心）
- ✅ 认证授权（重点）
- ✅ 中间件（重点）
- ⚠️ 业务流程（适度）

#### 前端应用
- ✅ 页面路由（重点）
- ✅ 组件结构（重点）
- ✅ 状态管理（重点）
- ✅ API 调用（重点）
- ⚠️ 数据模型（轻度）

#### 微服务
- ✅ 服务边界（核心）
- ✅ API 端点（核心）
- ✅ 服务间通信（重点）
- ✅ 数据模型（重点）
- ✅ 消息队列（如有）

## 📝 使用方法

### 方法 1：直接调用 skill

```bash
# 分析当前目录
claude skill project-deep-analyzer

# 分析指定目录
claude skill project-deep-analyzer /path/to/project
```

### 方法 2：在脚本中调用

```bash
# 在 generate-docs-smart.sh 中
if [ "$DEEP_ANALYSIS" = true ]; then
    claude skill project-deep-analyzer "$PROJECT_DIR"

    if [ -f "$PROJECT_DIR/.analysis-report.json" ]; then
        # 使用分析报告生成更准确的文档
        generate_docs_from_analysis
    fi
fi
```

### 方法 3：交互式使用

```bash
# 启动交互式分析
claude
> /skill project-deep-analyzer
```

## 🎯 输出使用

生成的 `.analysis-report.json` 可以被以下工具使用：

1. **文档生成脚本** - 生成更准确的技术文档
2. **API 文档生成器** - 生成 OpenAPI/Swagger 规范
3. **架构图生成器** - 生成更详细的架构图
4. **代码审查工具** - 识别潜在问题
5. **测试生成器** - 生成测试用例

## ⚠️ 注意事项

### 1. 分析范围
- 默认分析 `src/`, `app/`, `lib/` 等常见源码目录
- 排除 `node_modules`, `vendor`, `dist`, `build` 等目录
- 最多分析 500 个文件（可配置）

### 2. 性能考虑
- 大型项目（>1000 文件）可能需要较长时间
- 建议先运行基础分析，再选择性深度分析
- 可以指定只分析特定模块

### 3. 准确性
- 分析结果基于代码静态分析和 AI 理解
- 复杂的动态逻辑可能无法完全捕获
- 建议人工审核关键业务流程

### 4. 隐私和安全
- 分析过程不会上传代码到外部服务
- 使用本地 Claude Code 会话
- 敏感信息（密钥、密码）会被自动过滤

## 🔧 配置选项

可以通过创建 `.analysis-config.json` 自定义分析行为：

```json
{
  "include_dirs": ["src", "app", "lib"],
  "exclude_dirs": ["node_modules", "dist", "build"],
  "max_files": 500,
  "analysis_depth": "deep",
  "focus_areas": ["api", "models", "flows"],
  "output_format": "json",
  "include_examples": true,
  "filter_sensitive": true
}
```

## 📊 示例输出

完整的分析报告示例请参考：`examples/analysis-report-example.json`

---

**版本**: v1.0
**创建日期**: 2026-03-17
**最后更新**: 2026-03-17
