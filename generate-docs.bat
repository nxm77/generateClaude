@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM 三阶段文档生成脚本 (Windows 批处理版本)
REM 用途：自动生成项目文档（需求分析、文件功能列表、PlantUML 图表）
REM 作者：自动生成
REM 日期：2026-03-17
REM 使用方法：
REM   generate-docs.bat              - 在当前目录生成文档
REM   generate-docs.bat E:\my-project - 在指定目录生成文档

REM 获取目标目录：如果提供参数则使用参数，否则使用当前目录
if "%~1"=="" (
    set "PROJECT_DIR=%CD%"
) else (
    set "PROJECT_DIR=%~1"
)

REM 颜色代码（Windows 10+）
set "COLOR_INFO=[94m"
set "COLOR_SUCCESS=[92m"
set "COLOR_WARNING=[93m"
set "COLOR_ERROR=[91m"
set "COLOR_STAGE=[96m"
set "COLOR_RESET=[0m"

echo.
echo %COLOR_STAGE%╔════════════════════════════════════════╗%COLOR_RESET%
echo %COLOR_STAGE%║   三阶段文档生成脚本                  ║%COLOR_RESET%
echo %COLOR_STAGE%║   Three-Stage Documentation Generator  ║%COLOR_RESET%
echo %COLOR_STAGE%╚════════════════════════════════════════╝%COLOR_RESET%
echo.

echo %COLOR_INFO%[INFO]%COLOR_RESET% 开始执行文档生成流程...
echo %COLOR_INFO%[INFO]%COLOR_RESET% 目标目录: %PROJECT_DIR%
echo.

REM 检查目录是否存在
if not exist "%PROJECT_DIR%" (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 项目目录不存在: %PROJECT_DIR%
    exit /b 1
)
echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 项目目录检查通过: %PROJECT_DIR%
timeout /t 1 /nobreak >nul

REM ========================================
REM 阶段 1：生成框架版 CLAUDE.md
REM ========================================
echo.
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo %COLOR_STAGE%阶段 1：生成框架版 CLAUDE.md%COLOR_RESET%
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo.

echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在创建文档索引框架...

(
echo # 项目文档索引
echo.
echo 本项目的完整文档结构如下：
echo.
echo ## 📋 核心文档
echo.
echo ### 1. [需求分析文档](./requirements-analysis.md^)
echo 项目需求的详细分析，包括功能需求、非功能需求、用户故事等
echo.
echo ### 2. [文件功能列表](./file-functions.md^)
echo 项目中所有文件的功能说明和职责划分
echo.
echo ## 📊 可视化图表
echo.
echo ### 3. [系统功能全图](./system-overview.puml^)
echo 使用 PlantUML 绘制的系统整体功能架构图
echo.
echo ### 4. [模块流程图](./module-flowchart.puml^)
echo 使用 PlantUML 绘制的各模块业务流程图
echo.
echo ### 5. [时序图](./sequence-diagram.puml^)
echo 使用 PlantUML 绘制的系统交互时序图
echo.
echo ---
echo.
echo ## 📖 如何使用
echo.
echo - **查看 PlantUML 图表**：使用支持 PlantUML 的工具（如 VS Code + PlantUML 插件）打开 `.puml` 文件
echo - **在线预览**：可以将 `.puml` 文件内容复制到 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/^)
echo.
echo ## 🔄 文档状态
echo.
echo - [ ] 需求分析文档 - 待生成
echo - [ ] 文件功能列表 - 待生成
echo - [ ] 系统功能全图 - 待生成
echo - [ ] 模块流程图 - 待生成
echo - [ ] 时序图 - 待生成
echo.
echo ---
echo.
echo *最后更新时间：%date%*
) > "%PROJECT_DIR%\CLAUDE.md"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 框架版 CLAUDE.md 创建成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 框架版 CLAUDE.md 创建失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM ========================================
REM 阶段 2：生成具体文档
REM ========================================
echo.
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo %COLOR_STAGE%阶段 2：生成具体文档%COLOR_RESET%
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo.

REM 2.1 生成需求分析文档
echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在生成需求分析文档...

(
echo # 需求分析文档
echo.
echo ## 1. 项目概述
echo.
echo ### 1.1 项目背景
echo 本项目旨在开发一个完整的软件系统，满足特定业务场景的需求。
echo.
echo ### 1.2 项目目标
echo - 提供高效、稳定的业务处理能力
echo - 支持多用户并发访问
echo - 确保数据安全和系统可靠性
echo - 提供良好的用户体验
echo.
echo ### 1.3 项目范围
echo - 核心业务功能模块
echo - 用户管理和权限控制
echo - 数据存储和管理
echo - 系统监控和日志
echo.
echo ## 2. 功能需求
echo.
echo ### 2.1 用户管理模块
echo - 用户注册、登录、信息管理
echo - 密码管理和找回
echo - 第三方登录集成
echo.
echo ### 2.2 权限管理模块
echo - 角色管理
echo - 权限分配
echo - 基于角色的访问控制（RBAC）
echo.
echo ### 2.3 业务功能模块
echo - 数据录入
echo - 数据查询
echo - 数据分析
echo.
echo ### 2.4 系统管理模块
echo - 日志管理
echo - 系统配置
echo - 监控告警
echo.
echo ## 3. 非功能需求
echo.
echo ### 3.1 性能需求
echo - 响应时间 ^< 2秒
echo - 支持 1000+ 并发用户
echo - 吞吐量 10000+ TPS
echo.
echo ### 3.2 安全需求
echo - 数据加密存储
echo - HTTPS 传输
echo - JWT Token 认证
echo - 防护 SQL 注入、XSS 攻击
echo.
echo ### 3.3 可用性需求
echo - 99.9%% 系统可用性
echo - 故障恢复时间 ^< 30分钟
echo - 每日自动备份
echo.
echo ---
echo.
echo *文档版本：v1.0*
echo *创建日期：%date%*
) > "%PROJECT_DIR%\requirements-analysis.md"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 需求分析文档生成成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 需求分析文档生成失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM 2.2 生成文件功能列表
echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在生成文件功能列表...

(
echo # 文件功能列表
echo.
echo ## 1. 项目结构概览
echo.
echo ```
echo project/
echo ├── src/                    # 源代码目录
echo │   ├── api/               # API 接口层
echo │   ├── components/        # 可复用组件
echo │   ├── config/            # 配置文件
echo │   ├── controllers/       # 控制器层
echo │   ├── models/            # 数据模型层
echo │   ├── services/          # 业务逻辑层
echo │   ├── utils/             # 工具函数
echo │   ├── middleware/        # 中间件
echo │   ├── routes/            # 路由定义
echo │   └── views/             # 视图层
echo ├── tests/                 # 测试文件
echo ├── docs/                  # 文档目录
echo ├── public/                # 静态资源
echo └── scripts/               # 脚本文件
echo ```
echo.
echo ## 2. 核心目录文件功能
echo.
echo ### 2.1 API 接口层 (`src/api/`^)
echo.
echo #### `src/api/auth.js`
echo - **功能**：用户认证相关 API 接口
echo - **职责**：用户注册、登录、Token 刷新、登出
echo.
echo #### `src/api/user.js`
echo - **功能**：用户管理相关 API 接口
echo - **职责**：获取用户信息、更新用户信息、修改密码
echo.
echo #### `src/api/business.js`
echo - **功能**：业务数据相关 API 接口
echo - **职责**：数据录入、查询、更新、删除
echo.
echo ### 2.2 控制器层 (`src/controllers/`^)
echo.
echo #### `src/controllers/authController.js`
echo - **功能**：认证控制器
echo - **职责**：处理登录、注册、Token 验证
echo.
echo #### `src/controllers/userController.js`
echo - **功能**：用户控制器
echo - **职责**：处理用户信息查询和更新
echo.
echo ### 2.3 服务层 (`src/services/`^)
echo.
echo #### `src/services/authService.js`
echo - **功能**：认证服务
echo - **职责**：用户注册逻辑、登录验证、Token 生成
echo.
echo #### `src/services/userService.js`
echo - **功能**：用户服务
echo - **职责**：用户信息查询、更新、权限验证
echo.
echo ---
echo.
echo *文档版本：v1.0*
echo *创建日期：%date%*
) > "%PROJECT_DIR%\file-functions.md"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 文件功能列表生成成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 文件功能列表生成失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM 2.3 生成系统功能全图
echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在生成系统功能全图...

(
echo @startuml 系统功能全图
echo.
echo skinparam rectangle {
echo     BackgroundColor^<^<system^>^> LightBlue
echo     BackgroundColor^<^<module^>^> LightGreen
echo     BackgroundColor^<^<external^>^> LightYellow
echo }
echo.
echo title 系统功能架构全图
echo.
echo actor "用户" as User
echo actor "管理员" as Admin
echo.
echo rectangle "应用系统" ^<^<system^>^> {
echo     rectangle "前端层" ^<^<module^>^> {
echo         rectangle "用户界面" as UI
echo         rectangle "组件库" as Components
echo     }
echo.
echo     rectangle "API 网关" ^<^<module^>^> {
echo         rectangle "路由管理" as Router
echo         rectangle "负载均衡" as LoadBalancer
echo     }
echo.
echo     rectangle "业务服务层" ^<^<module^>^> {
echo         rectangle "用户管理" as UserModule
echo         rectangle "权限管理" as PermModule
echo         rectangle "业务功能" as BizModule
echo     }
echo.
echo     rectangle "数据访问层" ^<^<module^>^> {
echo         rectangle "数据访问对象" as DAO
echo         rectangle "缓存管理" as Cache
echo     }
echo }
echo.
echo database "数据库" as DB
echo database "Redis" as Redis
echo.
echo User --^> UI
echo Admin --^> UI
echo UI --^> Router
echo Router --^> LoadBalancer
echo LoadBalancer --^> UserModule
echo LoadBalancer --^> PermModule
echo LoadBalancer --^> BizModule
echo UserModule --^> DAO
echo PermModule --^> DAO
echo BizModule --^> DAO
echo DAO --^> DB
echo Cache --^> Redis
echo.
echo @enduml
) > "%PROJECT_DIR%\system-overview.puml"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 系统功能全图生成成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 系统功能全图生成失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM 2.4 生成模块流程图
echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在生成模块流程图...

(
echo @startuml 模块流程图
echo.
echo title 用户登录流程
echo.
echo start
echo.
echo :用户访问系统;
echo.
echo if (是否已登录?^) then (否^)
echo     :跳转登录页面;
echo     :输入用户名和密码;
echo     :提交登录请求;
echo.
echo     :验证用户名格式;
echo     :验证密码格式;
echo.
echo     if (格式验证通过?^) then (是^)
echo         :查询用户信息;
echo.
echo         if (用户存在?^) then (是^)
echo             :验证密码;
echo.
echo             if (密码正确?^) then (是^)
echo                 :生成 JWT Token;
echo                 :记录登录日志;
echo                 :返回 Token;
echo             else (否^)
echo                 :返回密码错误;
echo                 stop
echo             endif
echo         else (否^)
echo             :返回用户不存在;
echo             stop
echo         endif
echo     else (否^)
echo         :返回格式错误;
echo         stop
echo     endif
echo else (是^)
echo     :验证 Token 有效性;
echo.
echo     if (Token 有效?^) then (否^)
echo         :清除 Token;
echo         :跳转登录页面;
echo         stop
echo     else (是^)
echo         :继续访问;
echo     endif
echo endif
echo.
echo :获取用户权限;
echo :检查访问权限;
echo.
echo if (有权限?^) then (是^)
echo     :允许访问;
echo     :返回数据;
echo else (否^)
echo     :返回权限不足;
echo     stop
echo endif
echo.
echo stop
echo.
echo @enduml
) > "%PROJECT_DIR%\module-flowchart.puml"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 模块流程图生成成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 模块流程图生成失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM 2.5 生成时序图
echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在生成时序图...

(
echo @startuml 时序图
echo.
echo title 用户登录时序图
echo.
echo actor "用户" as User
echo participant "前端" as Frontend
echo participant "API 网关" as Gateway
echo participant "认证服务" as AuthService
echo participant "数据库" as DB
echo participant "缓存" as Cache
echo.
echo User -^> Frontend: 输入用户名和密码
echo activate Frontend
echo.
echo Frontend -^> Gateway: POST /api/auth/login
echo activate Gateway
echo.
echo Gateway -^> AuthService: 转发登录请求
echo activate AuthService
echo.
echo AuthService -^> Cache: 检查用户缓存
echo activate Cache
echo Cache --^> AuthService: 缓存未命中
echo deactivate Cache
echo.
echo AuthService -^> DB: 查询用户信息
echo activate DB
echo DB --^> AuthService: 返回用户信息
echo deactivate DB
echo.
echo AuthService -^> AuthService: 验证密码
echo AuthService -^> AuthService: 生成 JWT Token
echo.
echo AuthService -^> Cache: 缓存用户信息
echo activate Cache
echo Cache --^> AuthService: 缓存成功
echo deactivate Cache
echo.
echo AuthService --^> Gateway: 返回 Token
echo deactivate AuthService
echo.
echo Gateway --^> Frontend: 200 OK + Token
echo deactivate Gateway
echo.
echo Frontend -^> Frontend: 保存 Token
echo Frontend --^> User: 登录成功
echo deactivate Frontend
echo.
echo @enduml
) > "%PROJECT_DIR%\sequence-diagram.puml"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 时序图生成成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 时序图生成失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM ========================================
REM 阶段 3：更新最终版 CLAUDE.md
REM ========================================
echo.
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo %COLOR_STAGE%阶段 3：更新最终版 CLAUDE.md%COLOR_RESET%
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo.

echo %COLOR_INFO%[INFO]%COLOR_RESET% 正在更新 CLAUDE.md 为最终版本...

(
echo # 项目文档索引
echo.
echo 本项目的完整文档结构如下：
echo.
echo ## 📋 核心文档
echo.
echo ### 1. [需求分析文档](./requirements-analysis.md^)
echo **内容概要**：完整的项目需求分析，包含：
echo - 项目概述和目标
echo - 功能需求（用户管理、权限管理、业务功能、系统管理）
echo - 非功能需求（性能、安全、可用性）
echo.
echo ### 2. [文件功能列表](./file-functions.md^)
echo **内容概要**：项目文件结构和功能说明，包含：
echo - 完整的项目目录结构
echo - API 接口层文件功能
echo - 控制器、服务层文件职责
echo.
echo ## 📊 可视化图表
echo.
echo ### 3. [系统功能全图](./system-overview.puml^)
echo **图表说明**：系统整体功能架构图，展示：
echo - 用户角色和前端层
echo - API 网关和业务服务层
echo - 数据访问层和存储层
echo.
echo ### 4. [模块流程图](./module-flowchart.puml^)
echo **图表说明**：用户登录业务流程图，展示：
echo - 登录验证流程
echo - Token 生成机制
echo - 权限验证流程
echo.
echo ### 5. [时序图](./sequence-diagram.puml^)
echo **图表说明**：用户登录时序交互图，包含：
echo - 前端与后端交互
echo - 缓存查询流程
echo - Token 生成和返回
echo.
echo ---
echo.
echo ## 📖 如何使用文档
echo.
echo ### 查看 Markdown 文档
echo - 使用任何 Markdown 阅读器或编辑器打开 `.md` 文件
echo - 推荐工具：VS Code、Typora、Obsidian
echo.
echo ### 查看 PlantUML 图表
echo.
echo #### 方法一：VS Code（推荐）
echo 1. 安装 VS Code 扩展：`PlantUML`
echo 2. 打开 `.puml` 文件
echo 3. 按 `Alt + D` 预览图表
echo.
echo #### 方法二：在线预览
echo 1. 访问 [PlantUML Online Editor](http://www.plantuml.com/plantuml/uml/^)
echo 2. 复制 `.puml` 文件内容
echo 3. 粘贴到编辑器中查看
echo.
echo ---
echo.
echo ## 🔄 文档状态
echo.
echo - [x] 需求分析文档 - ✅ 已完成
echo - [x] 文件功能列表 - ✅ 已完成
echo - [x] 系统功能全图 - ✅ 已完成
echo - [x] 模块流程图 - ✅ 已完成
echo - [x] 时序图 - ✅ 已完成
echo.
echo ---
echo.
echo ## 🎯 快速导航
echo.
echo ^| 需求 ^| 推荐文档 ^|
echo ^|------^|---------^|
echo ^| 了解项目需求 ^| [需求分析文档](./requirements-analysis.md^) ^|
echo ^| 查找文件功能 ^| [文件功能列表](./file-functions.md^) ^|
echo ^| 理解系统架构 ^| [系统功能全图](./system-overview.puml^) ^|
echo ^| 了解业务流程 ^| [模块流程图](./module-flowchart.puml^) ^|
echo ^| 理解交互逻辑 ^| [时序图](./sequence-diagram.puml^) ^|
echo.
echo ---
echo.
echo *文档版本：v1.0*
echo *创建日期：%date%*
echo *最后更新：%date%*
) > "%PROJECT_DIR%\CLAUDE.md"

if %errorlevel% equ 0 (
    echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 最终版 CLAUDE.md 更新成功
) else (
    echo %COLOR_ERROR%[ERROR]%COLOR_RESET% 最终版 CLAUDE.md 更新失败
    exit /b 1
)
timeout /t 1 /nobreak >nul

REM ========================================
REM 生成文档统计报告
REM ========================================
echo.
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo %COLOR_STAGE%生成文档统计报告%COLOR_RESET%
echo %COLOR_STAGE%========================================%COLOR_RESET%
echo.

echo %COLOR_INFO%[INFO]%COLOR_RESET% 统计文档信息...
echo.

echo %COLOR_SUCCESS%========================================%COLOR_RESET%
echo %COLOR_SUCCESS%文档生成完成统计%COLOR_RESET%
echo %COLOR_SUCCESS%========================================%COLOR_RESET%
echo.

echo %COLOR_STAGE%生成的文档列表：%COLOR_RESET%
echo   1. CLAUDE.md
echo   2. requirements-analysis.md
echo   3. file-functions.md
echo   4. system-overview.puml
echo   5. module-flowchart.puml
echo   6. sequence-diagram.puml
echo.

echo %COLOR_STAGE%文档存储位置：%COLOR_RESET%
echo   %PROJECT_DIR%
echo.

echo %COLOR_STAGE%下一步操作建议：%COLOR_RESET%
echo   1. 使用 VS Code 打开项目目录查看文档
echo   2. 安装 PlantUML 插件预览图表
echo   3. 根据实际需求调整文档内容
echo.

echo %COLOR_SUCCESS%========================================%COLOR_RESET%
echo.

echo %COLOR_SUCCESS%[SUCCESS]%COLOR_RESET% 所有文档生成完成！
echo.

pause
