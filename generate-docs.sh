#!/bin/bash

# 三阶段文档生成脚本
# 用途：自动生成项目文档（需求分析、文件功能列表、PlantUML 图表）
# 作者：自动生成
# 日期：2026-03-17
# 使用方法：
#   ./generate-docs.sh              - 在当前目录生成文档
#   ./generate-docs.sh /path/to/dir - 在指定目录生成文档

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取目标目录：如果提供参数则使用参数，否则使用当前目录
if [ -z "$1" ]; then
    PROJECT_DIR="$(pwd)"
else
    PROJECT_DIR="$1"
fi

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_stage() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# 检查目录是否存在
check_directory() {
    if [ ! -d "$PROJECT_DIR" ]; then
        print_error "项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    print_success "项目目录检查通过: $PROJECT_DIR"
}

# 阶段 1：生成框架版 CLAUDE.md
stage1_generate_framework() {
    print_stage "阶段 1：生成框架版 CLAUDE.md"

    print_info "正在创建文档索引框架..."

    cat > "$PROJECT_DIR/CLAUDE.md" << 'EOF'
# 项目文档索引

本项目的完整文档结构如下：

## 📋 核心文档

### 1. [需求分析文档](./requirements-analysis.md)
项目需求的详细分析，包括功能需求、非功能需求、用户故事等

### 2. [文件功能列表](./file-functions.md)
项目中所有文件的功能说明和职责划分

## 📊 可视化图表

### 3. [系统功能全图](./system-overview.puml)
使用 PlantUML 绘制的系统整体功能架构图

### 4. [模块流程图](./module-flowchart.puml)
使用 PlantUML 绘制的各模块业务流程图

### 5. [时序图](./sequence-diagram.puml)
使用 PlantUML 绘制的系统交互时序图

---

## 📖 如何使用

- **查看 PlantUML 图表**：使用支持 PlantUML 的工具（如 VS Code + PlantUML 插件）打开 `.puml` 文件
- **在线预览**：可以将 `.puml` 文件内容复制到 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)

## 🔄 文档状态

- [ ] 需求分析文档 - 待生成
- [ ] 文件功能列表 - 待生成
- [ ] 系统功能全图 - 待生成
- [ ] 模块流程图 - 待生成
- [ ] 时序图 - 待生成

---

*最后更新时间：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "框架版 CLAUDE.md 创建成功"
    else
        print_error "框架版 CLAUDE.md 创建失败"
        exit 1
    fi

    sleep 1
}

# 阶段 2：生成具体文档
stage2_generate_documents() {
    print_stage "阶段 2：生成具体文档"

    # 2.1 生成需求分析文档
    print_info "正在生成需求分析文档..."
    cat > "$PROJECT_DIR/requirements-analysis.md" << 'EOF'
# 需求分析文档

## 1. 项目概述

### 1.1 项目背景
本项目旨在开发一个完整的软件系统，满足特定业务场景的需求。

### 1.2 项目目标
- 提供高效、稳定的业务处理能力
- 支持多用户并发访问
- 确保数据安全和系统可靠性
- 提供良好的用户体验

### 1.3 项目范围
- 核心业务功能模块
- 用户管理和权限控制
- 数据存储和管理
- 系统监控和日志

## 2. 功能需求

### 2.1 用户管理模块
- 用户注册、登录、信息管理
- 密码管理和找回
- 第三方登录集成

### 2.2 权限管理模块
- 角色管理
- 权限分配
- 基于角色的访问控制（RBAC）

### 2.3 业务功能模块
- 数据录入
- 数据查询
- 数据分析

### 2.4 系统管理模块
- 日志管理
- 系统配置
- 监控告警

## 3. 非功能需求

### 3.1 性能需求
- 响应时间 < 2秒
- 支持 1000+ 并发用户
- 吞吐量 10000+ TPS

### 3.2 安全需求
- 数据加密存储
- HTTPS 传输
- JWT Token 认证
- 防护 SQL 注入、XSS 攻击

### 3.3 可用性需求
- 99.9% 系统可用性
- 故障恢复时间 < 30分钟
- 每日自动备份

---

*文档版本：v1.0*
*创建日期：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "需求分析文档生成成功"
    else
        print_error "需求分析文档生成失败"
        exit 1
    fi

    sleep 1

    # 2.2 生成文件功能列表
    print_info "正在生成文件功能列表..."
    cat > "$PROJECT_DIR/file-functions.md" << 'EOF'
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
- **职责**：用户注册、登录、Token 刷新、登出

#### `src/api/user.js`
- **功能**：用户管理相关 API 接口
- **职责**：获取用户信息、更新用户信息、修改密码

#### `src/api/business.js`
- **功能**：业务数据相关 API 接口
- **职责**：数据录入、查询、更新、删除

### 2.2 控制器层 (`src/controllers/`)

#### `src/controllers/authController.js`
- **功能**：认证控制器
- **职责**：处理登录、注册、Token 验证

#### `src/controllers/userController.js`
- **功能**：用户控制器
- **职责**：处理用户信息查询和更新

### 2.3 服务层 (`src/services/`)

#### `src/services/authService.js`
- **功能**：认证服务
- **职责**：用户注册逻辑、登录验证、Token 生成

#### `src/services/userService.js`
- **功能**：用户服务
- **职责**：用户信息查询、更新、权限验证

---

*文档版本：v1.0*
*创建日期：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "文件功能列表生成成功"
    else
        print_error "文件功能列表生成失败"
        exit 1
    fi

    sleep 1

    # 2.3 生成系统功能全图
    print_info "正在生成系统功能全图..."
    cat > "$PROJECT_DIR/system-overview.puml" << 'EOF'
@startuml 系统功能全图

skinparam rectangle {
    BackgroundColor<<system>> LightBlue
    BackgroundColor<<module>> LightGreen
    BackgroundColor<<external>> LightYellow
}

title 系统功能架构全图

actor "用户" as User
actor "管理员" as Admin

rectangle "应用系统" <<system>> {
    rectangle "前端层" <<module>> {
        rectangle "用户界面" as UI
        rectangle "组件库" as Components
    }

    rectangle "API 网关" <<module>> {
        rectangle "路由管理" as Router
        rectangle "负载均衡" as LoadBalancer
    }

    rectangle "业务服务层" <<module>> {
        rectangle "用户管理" as UserModule
        rectangle "权限管理" as PermModule
        rectangle "业务功能" as BizModule
    }

    rectangle "数据访问层" <<module>> {
        rectangle "数据访问对象" as DAO
        rectangle "缓存管理" as Cache
    }
}

database "数据库" as DB
database "Redis" as Redis

User --> UI
Admin --> UI
UI --> Router
Router --> LoadBalancer
LoadBalancer --> UserModule
LoadBalancer --> PermModule
LoadBalancer --> BizModule
UserModule --> DAO
PermModule --> DAO
BizModule --> DAO
DAO --> DB
Cache --> Redis

@enduml
EOF

    if [ $? -eq 0 ]; then
        print_success "系统功能全图生成成功"
    else
        print_error "系统功能全图生成失败"
        exit 1
    fi

    sleep 1

    # 2.4 生成模块流程图
    print_info "正在生成模块流程图..."
    cat > "$PROJECT_DIR/module-flowchart.puml" << 'EOF'
@startuml 模块流程图

title 用户登录流程

start

:用户访问系统;

if (是否已登录?) then (否)
    :跳转登录页面;
    :输入用户名和密码;
    :提交登录请求;

    :验证用户名格式;
    :验证密码格式;

    if (格式验证通过?) then (是)
        :查询用户信息;

        if (用户存在?) then (是)
            :验证密码;

            if (密码正确?) then (是)
                :生成 JWT Token;
                :记录登录日志;
                :返回 Token;
            else (否)
                :返回密码错误;
                stop
            endif
        else (否)
            :返回用户不存在;
            stop
        endif
    else (否)
        :返回格式错误;
        stop
    endif
else (是)
    :验证 Token 有效性;

    if (Token 有效?) then (否)
        :清除 Token;
        :跳转登录页面;
        stop
    else (是)
        :继续访问;
    endif
endif

:获取用户权限;
:检查访问权限;

if (有权限?) then (是)
    :允许访问;
    :返回数据;
else (否)
    :返回权限不足;
    stop
endif

stop

@enduml
EOF

    if [ $? -eq 0 ]; then
        print_success "模块流程图生成成功"
    else
        print_error "模块流程图生成失败"
        exit 1
    fi

    sleep 1

    # 2.5 生成时序图
    print_info "正在生成时序图..."
    cat > "$PROJECT_DIR/sequence-diagram.puml" << 'EOF'
@startuml 时序图

title 用户登录时序图

actor "用户" as User
participant "前端" as Frontend
participant "API 网关" as Gateway
participant "认证服务" as AuthService
participant "数据库" as DB
participant "缓存" as Cache

User -> Frontend: 输入用户名和密码
activate Frontend

Frontend -> Gateway: POST /api/auth/login
activate Gateway

Gateway -> AuthService: 转发登录请求
activate AuthService

AuthService -> Cache: 检查用户缓存
activate Cache
Cache --> AuthService: 缓存未命中
deactivate Cache

AuthService -> DB: 查询用户信息
activate DB
DB --> AuthService: 返回用户信息
deactivate DB

AuthService -> AuthService: 验证密码
AuthService -> AuthService: 生成 JWT Token

AuthService -> Cache: 缓存用户信息
activate Cache
Cache --> AuthService: 缓存成功
deactivate Cache

AuthService --> Gateway: 返回 Token
deactivate AuthService

Gateway --> Frontend: 200 OK + Token
deactivate Gateway

Frontend -> Frontend: 保存 Token
Frontend --> User: 登录成功
deactivate Frontend

@enduml
EOF

    if [ $? -eq 0 ]; then
        print_success "时序图生成成功"
    else
        print_error "时序图生成失败"
        exit 1
    fi

    sleep 1
}

# 阶段 3：更新最终版 CLAUDE.md
stage3_update_final() {
    print_stage "阶段 3：更新最终版 CLAUDE.md"

    print_info "正在更新 CLAUDE.md 为最终版本..."

    cat > "$PROJECT_DIR/CLAUDE.md" << 'EOF'
# 项目文档索引

本项目的完整文档结构如下：

## 📋 核心文档

### 1. [需求分析文档](./requirements-analysis.md)
**内容概要**：完整的项目需求分析，包含：
- 项目概述和目标
- 功能需求（用户管理、权限管理、业务功能、系统管理）
- 非功能需求（性能、安全、可用性）

### 2. [文件功能列表](./file-functions.md)
**内容概要**：项目文件结构和功能说明，包含：
- 完整的项目目录结构
- API 接口层文件功能
- 控制器、服务层文件职责

## 📊 可视化图表

### 3. [系统功能全图](./system-overview.puml)
**图表说明**：系统整体功能架构图，展示：
- 用户角色和前端层
- API 网关和业务服务层
- 数据访问层和存储层

### 4. [模块流程图](./module-flowchart.puml)
**图表说明**：用户登录业务流程图，展示：
- 登录验证流程
- Token 生成机制
- 权限验证流程

### 5. [时序图](./sequence-diagram.puml)
**图表说明**：用户登录时序交互图，包含：
- 前端与后端交互
- 缓存查询流程
- Token 生成和返回

---

## 📖 如何使用文档

### 查看 Markdown 文档
- 使用任何 Markdown 阅读器或编辑器打开 `.md` 文件
- 推荐工具：VS Code、Typora、Obsidian

### 查看 PlantUML 图表

#### 方法一：VS Code（推荐）
1. 安装 VS Code 扩展：`PlantUML`
2. 打开 `.puml` 文件
3. 按 `Alt + D` 预览图表

#### 方法二：在线预览
1. 访问 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/)
2. 复制 `.puml` 文件内容
3. 粘贴到编辑器中查看

---

## 🔄 文档状态

- [x] 需求分析文档 - ✅ 已完成
- [x] 文件功能列表 - ✅ 已完成
- [x] 系统功能全图 - ✅ 已完成
- [x] 模块流程图 - ✅ 已完成
- [x] 时序图 - ✅ 已完成

---

## 🎯 快速导航

| 需求 | 推荐文档 |
|------|---------|
| 了解项目需求 | [需求分析文档](./requirements-analysis.md) |
| 查找文件功能 | [文件功能列表](./file-functions.md) |
| 理解系统架构 | [系统功能全图](./system-overview.puml) |
| 了解业务流程 | [模块流程图](./module-flowchart.puml) |
| 理解交互逻辑 | [时序图](./sequence-diagram.puml) |

---

*文档版本：v1.0*
*创建日期：$(date +%Y-%m-%d)*
*最后更新：$(date +%Y-%m-%d)*
EOF

    if [ $? -eq 0 ]; then
        print_success "最终版 CLAUDE.md 更新成功"
    else
        print_error "最终版 CLAUDE.md 更新失败"
        exit 1
    fi

    sleep 1
}

# 生成文档统计报告
generate_report() {
    print_stage "生成文档统计报告"

    print_info "统计文档信息..."

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}文档生成完成统计${NC}"
    echo -e "${GREEN}========================================${NC}\n"

    echo -e "${CYAN}生成的文档列表：${NC}"
    echo -e "  1. CLAUDE.md                    $(wc -l < "$PROJECT_DIR/CLAUDE.md") 行"
    echo -e "  2. requirements-analysis.md     $(wc -l < "$PROJECT_DIR/requirements-analysis.md") 行"
    echo -e "  3. file-functions.md            $(wc -l < "$PROJECT_DIR/file-functions.md") 行"
    echo -e "  4. system-overview.puml         $(wc -l < "$PROJECT_DIR/system-overview.puml") 行"
    echo -e "  5. module-flowchart.puml        $(wc -l < "$PROJECT_DIR/module-flowchart.puml") 行"
    echo -e "  6. sequence-diagram.puml        $(wc -l < "$PROJECT_DIR/sequence-diagram.puml") 行"

    echo -e "\n${CYAN}文档存储位置：${NC}"
    echo -e "  $PROJECT_DIR"

    echo -e "\n${CYAN}下一步操作建议：${NC}"
    echo -e "  1. 使用 VS Code 打开项目目录查看文档"
    echo -e "  2. 安装 PlantUML 插件预览图表"
    echo -e "  3. 根据实际需求调整文档内容"

    echo -e "\n${GREEN}========================================${NC}\n"
}

# 主函数
main() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   三阶段文档生成脚本                  ║"
    echo "║   Three-Stage Documentation Generator  ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}\n"

    print_info "开始执行文档生成流程..."
    print_info "目标目录: $PROJECT_DIR"

    # 检查目录
    check_directory

    # 执行三个阶段
    stage1_generate_framework
    stage2_generate_documents
    stage3_update_final

    # 生成报告
    generate_report

    print_success "所有文档生成完成！"
}

# 执行主函数
main
