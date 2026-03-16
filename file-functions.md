# 文件功能列表

## 1. 项目结构概览

```
project/
├── src/                    # 源代码目录
│   ├── api/               # API 接口层
│   ├── components/        # 可复用组件
│   ├── config/            # 配置文件
│   ├── controllers/       # 控制器层
│   ├── models/            # 数据模型层
│   ├── services/          # 业务逻辑层
│   ├── utils/             # 工具函数
│   ├── middleware/        # 中间件
│   ├── routes/            # 路由定义
│   └── views/             # 视图层
├── tests/                 # 测试文件
├── docs/                  # 文档目录
├── public/                # 静态资源
└── scripts/               # 脚本文件
```

## 2. 核心目录文件功能

### 2.1 API 接口层 (`src/api/`)

#### `src/api/auth.js`
- **功能**：用户认证相关 API 接口
- **职责**：
  - 用户注册接口
  - 用户登录接口
  - Token 刷新接口
  - 用户登出接口
- **依赖**：`controllers/authController.js`

#### `src/api/user.js`
- **功能**：用户管理相关 API 接口
- **职责**：
  - 获取用户信息
  - 更新用户信息
  - 修改密码
  - 用户列表查询
- **依赖**：`controllers/userController.js`

#### `src/api/role.js`
- **功能**：角色管理相关 API 接口
- **职责**：
  - 创建角色
  - 编辑角色
  - 删除角色
  - 角色权限分配
- **依赖**：`controllers/roleController.js`

#### `src/api/business.js`
- **功能**：业务数据相关 API 接口
- **职责**：
  - 数据录入接口
  - 数据查询接口
  - 数据更新接口
  - 数据删除接口
- **依赖**：`controllers/businessController.js`

### 2.2 组件层 (`src/components/`)

#### `src/components/common/Button.jsx`
- **功能**：通用按钮组件
- **职责**：
  - 提供统一的按钮样式
  - 支持多种按钮类型（主要、次要、危险等）
  - 支持加载状态
  - 支持禁用状态

#### `src/components/common/Input.jsx`
- **功能**：通用输入框组件
- **职责**：
  - 提供统一的输入框样式
  - 支持表单验证
  - 支持错误提示
  - 支持多种输入类型

#### `src/components/common/Modal.jsx`
- **功能**：通用模态框组件
- **职责**：
  - 提供弹窗功能
  - 支持自定义内容
  - 支持确认/取消操作
  - 支持关闭回调

#### `src/components/layout/Header.jsx`
- **功能**：页面头部组件
- **职责**：
  - 显示导航菜单
  - 显示用户信息
  - 提供登出功能
  - 响应式布局

#### `src/components/layout/Sidebar.jsx`
- **功能**：侧边栏组件
- **职责**：
  - 显示功能菜单
  - 支持菜单折叠
  - 权限控制显示
  - 路由跳转

#### `src/components/forms/LoginForm.jsx`
- **功能**：登录表单组件
- **职责**：
  - 用户名/密码输入
  - 表单验证
  - 提交登录请求
  - 错误提示

#### `src/components/forms/RegisterForm.jsx`
- **功能**：注册表单组件
- **职责**：
  - 用户信息输入
  - 密码强度验证
  - 验证码验证
  - 提交注册请求

#### `src/components/tables/DataTable.jsx`
- **功能**：数据表格组件
- **职责**：
  - 数据展示
  - 分页功能
  - 排序功能
  - 操作列（编辑、删除等）

### 2.3 配置文件 (`src/config/`)

#### `src/config/database.js`
- **功能**：数据库配置
- **职责**：
  - 数据库连接配置
  - 连接池配置
  - 环境变量读取
  - 数据库初始化

#### `src/config/auth.js`
- **功能**：认证配置
- **职责**：
  - JWT 密钥配置
  - Token 过期时间配置
  - 加密算法配置
  - 第三方登录配置

#### `src/config/app.js`
- **功能**：应用配置
- **职责**：
  - 服务器端口配置
  - 跨域配置
  - 日志级别配置
  - 环境变量管理

#### `src/config/constants.js`
- **功能**：常量定义
- **职责**：
  - 业务常量定义
  - 错误码定义
  - 状态码定义
  - 枚举值定义

### 2.4 控制器层 (`src/controllers/`)

#### `src/controllers/authController.js`
- **功能**：认证控制器
- **职责**：
  - 处理登录请求
  - 处理注册请求
  - Token 验证和刷新
  - 登出处理
- **依赖**：`services/authService.js`

#### `src/controllers/userController.js`
- **功能**：用户控制器
- **职责**：
  - 处理用户信息查询
  - 处理用户信息更新
  - 处理密码修改
  - 处理用户列表查询
- **依赖**：`services/userService.js`

#### `src/controllers/roleController.js`
- **功能**：角色控制器
- **职责**：
  - 处理角色创建
  - 处理角色编辑
  - 处理角色删除
  - 处理权限分配
- **依赖**：`services/roleService.js`

#### `src/controllers/businessController.js`
- **功能**：业务控制器
- **职责**：
  - 处理业务数据录入
  - 处理业务数据查询
  - 处理业务数据更新
  - 处理业务数据删除
- **依赖**：`services/businessService.js`

### 2.5 数据模型层 (`src/models/`)

#### `src/models/User.js`
- **功能**：用户数据模型
- **职责**：
  - 定义用户表结构
  - 用户数据验证
  - 用户关联关系
  - 密码加密方法

#### `src/models/Role.js`
- **功能**：角色数据模型
- **职责**：
  - 定义角色表结构
  - 角色权限关联
  - 角色验证规则

#### `src/models/Permission.js`
- **功能**：权限数据模型
- **职责**：
  - 定义权限表结构
  - 权限层级关系
  - 权限验证规则

#### `src/models/BusinessData.js`
- **功能**：业务数据模型
- **职责**：
  - 定义业务表结构
  - 业务数据验证
  - 业务关联关系

#### `src/models/Log.js`
- **功能**：日志数据模型
- **职责**：
  - 定义日志表结构
  - 日志记录方法
  - 日志查询方法

### 2.6 业务逻辑层 (`src/services/`)

#### `src/services/authService.js`
- **功能**：认证服务
- **职责**：
  - 用户注册业务逻辑
  - 用户登录验证
  - Token 生成和验证
  - 密码加密和验证
- **依赖**：`models/User.js`, `utils/jwt.js`

#### `src/services/userService.js`
- **功能**：用户服务
- **职责**：
  - 用户信息查询逻辑
  - 用户信息更新逻辑
  - 用户权限验证
  - 用户状态管理
- **依赖**：`models/User.js`, `models/Role.js`

#### `src/services/roleService.js`
- **功能**：角色服务
- **职责**：
  - 角色管理业务逻辑
  - 权限分配逻辑
  - 角色权限验证
- **依赖**：`models/Role.js`, `models/Permission.js`

#### `src/services/businessService.js`
- **功能**：业务服务
- **职责**：
  - 业务数据处理逻辑
  - 数据验证和转换
  - 业务规则执行
  - 数据统计分析
- **依赖**：`models/BusinessData.js`

#### `src/services/logService.js`
- **功能**：日志服务
- **职责**：
  - 日志记录逻辑
  - 日志查询逻辑
  - 日志清理逻辑
- **依赖**：`models/Log.js`

### 2.7 工具函数 (`src/utils/`)

#### `src/utils/jwt.js`
- **功能**：JWT 工具
- **职责**：
  - Token 生成
  - Token 验证
  - Token 解析
  - Token 刷新

#### `src/utils/validator.js`
- **功能**：数据验证工具
- **职责**：
  - 邮箱验证
  - 手机号验证
  - 密码强度验证
  - 自定义验证规则

#### `src/utils/crypto.js`
- **功能**：加密工具
- **职责**：
  - 密码加密
  - 数据加密
  - 哈希计算
  - 随机字符串生成

#### `src/utils/logger.js`
- **功能**：日志工具
- **职责**：
  - 日志格式化
  - 日志输出
  - 日志级别控制
  - 日志文件管理

#### `src/utils/response.js`
- **功能**：响应工具
- **职责**：
  - 统一响应格式
  - 成功响应封装
  - 错误响应封装
  - 分页响应封装

#### `src/utils/date.js`
- **功能**：日期工具
- **职责**：
  - 日期格式化
  - 日期计算
  - 时区转换
  - 日期验证

### 2.8 中间件 (`src/middleware/`)

#### `src/middleware/auth.js`
- **功能**：认证中间件
- **职责**：
  - Token 验证
  - 用户身份验证
  - 登录状态检查
  - 未授权处理

#### `src/middleware/permission.js`
- **功能**：权限中间件
- **职责**：
  - 权限验证
  - 角色检查
  - 资源访问控制
  - 权限拒绝处理

#### `src/middleware/validation.js`
- **功能**：验证中间件
- **职责**：
  - 请求参数验证
  - 数据格式验证
  - 业务规则验证
  - 验证错误处理

#### `src/middleware/errorHandler.js`
- **功能**：错误处理中间件
- **职责**：
  - 全局错误捕获
  - 错误日志记录
  - 错误响应格式化
  - 错误码映射

#### `src/middleware/logger.js`
- **功能**：日志中间件
- **职责**：
  - 请求日志记录
  - 响应日志记录
  - 性能监控
  - 访问统计

#### `src/middleware/rateLimit.js`
- **功能**：限流中间件
- **职责**：
  - 请求频率限制
  - IP 限制
  - 用户限制
  - 限流响应

### 2.9 路由定义 (`src/routes/`)

#### `src/routes/index.js`
- **功能**：路由入口
- **职责**：
  - 路由模块整合
  - 路由前缀配置
  - 全局中间件应用

#### `src/routes/auth.js`
- **功能**：认证路由
- **职责**：
  - 注册路由
  - 登录路由
  - 登出路由
  - Token 刷新路由

#### `src/routes/user.js`
- **功能**：用户路由
- **职责**：
  - 用户信息路由
  - 用户管理路由
  - 密码修改路由

#### `src/routes/role.js`
- **功能**：角色路由
- **职责**：
  - 角色管理路由
  - 权限分配路由

#### `src/routes/business.js`
- **功能**：业务路由
- **职责**：
  - 业务数据路由
  - 数据查询路由
  - 数据统计路由

## 3. 测试文件 (`tests/`)

#### `tests/unit/services/authService.test.js`
- **功能**：认证服务单元测试
- **职责**：测试认证相关业务逻辑

#### `tests/unit/utils/validator.test.js`
- **功能**：验证工具单元测试
- **职责**：测试数据验证功能

#### `tests/integration/api/auth.test.js`
- **功能**：认证 API 集成测试
- **职责**：测试认证接口完整流程

#### `tests/e2e/login.test.js`
- **功能**：登录端到端测试
- **职责**：测试用户登录完整场景

## 4. 配置文件（根目录）

#### `package.json`
- **功能**：项目依赖配置
- **职责**：
  - 依赖包管理
  - 脚本命令定义
  - 项目元信息

#### `.env`
- **功能**：环境变量配置
- **职责**：
  - 数据库连接信息
  - API 密钥
  - 环境特定配置

#### `.gitignore`
- **功能**：Git 忽略配置
- **职责**：
  - 忽略 node_modules
  - 忽略环境变量文件
  - 忽略构建产物

#### `Dockerfile`
- **功能**：Docker 镜像配置
- **职责**：
  - 定义镜像构建步骤
  - 配置运行环境
  - 暴露端口

#### `docker-compose.yml`
- **功能**：Docker Compose 配置
- **职责**：
  - 多容器编排
  - 服务依赖定义
  - 网络配置

---

*文档版本：v1.0*
*创建日期：2026-03-17*
*最后更新：2026-03-17*
