#!/bin/bash

# 测试智能文档生成脚本
# 用途：创建不同类型的测试项目并验证脚本功能

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_test() {
    echo -e "\n${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}\n"
}

# 清理测试目录
cleanup() {
    print_info "清理测试目录..."
    rm -rf test-projects
}

# 创建测试项目 1：React + Express 全栈应用
create_fullstack_project() {
    print_test "创建测试项目 1：React + Express 全栈应用"

    mkdir -p test-projects/fullstack-app
    cd test-projects/fullstack-app

    # 创建 package.json
    cat > package.json << 'EOF'
{
  "name": "fullstack-app",
  "version": "1.0.0",
  "description": "A full-stack web application",
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "express": "^4.18.2",
    "pg": "^8.11.0",
    "redis": "^4.6.0"
  },
  "devDependencies": {
    "jest": "^29.5.0",
    "typescript": "^5.0.0"
  }
}
EOF

    # 创建目录结构
    mkdir -p src/client/components
    mkdir -p src/client/pages
    mkdir -p src/server/controllers
    mkdir -p src/server/services
    mkdir -p src/server/models
    mkdir -p src/server/routes
    mkdir -p tests

    # 创建示例文件
    touch src/client/App.tsx
    touch src/client/components/Header.tsx
    touch src/server/server.js
    touch src/server/controllers/userController.js
    touch src/server/services/authService.js
    touch tests/app.test.js

    # 创建 README
    echo "# Fullstack App" > README.md

    cd ../..
    print_success "全栈应用项目创建完成"
}

# 创建测试项目 2：Python FastAPI 服务
create_api_project() {
    print_test "创建测试项目 2：Python FastAPI 服务"

    mkdir -p test-projects/fastapi-service
    cd test-projects/fastapi-service

    # 创建 requirements.txt
    cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
redis==5.0.1
pytest==7.4.3
EOF

    # 创建目录结构
    mkdir -p app/api/endpoints
    mkdir -p app/core
    mkdir -p app/models
    mkdir -p app/services
    mkdir -p tests

    # 创建示例文件
    touch app/main.py
    touch app/api/endpoints/users.py
    touch app/core/config.py
    touch app/models/user.py
    touch app/services/auth_service.py
    touch tests/test_api.py

    # 创建 README
    echo "# FastAPI Service" > README.md

    cd ../..
    print_success "FastAPI 服务项目创建完成"
}

# 创建测试项目 3：Vue 前端应用
create_frontend_project() {
    print_test "创建测试项目 3：Vue 前端应用"

    mkdir -p test-projects/vue-frontend
    cd test-projects/vue-frontend

    # 创建 package.json
    cat > package.json << 'EOF'
{
  "name": "vue-frontend",
  "version": "1.0.0",
  "description": "A Vue.js frontend application",
  "dependencies": {
    "vue": "^3.3.4",
    "vue-router": "^4.2.4",
    "pinia": "^2.1.6",
    "axios": "^1.5.0"
  },
  "devDependencies": {
    "vite": "^4.4.9",
    "vitest": "^0.34.6",
    "@vue/test-utils": "^2.4.1"
  }
}
EOF

    # 创建目录结构
    mkdir -p src/components
    mkdir -p src/views
    mkdir -p src/store
    mkdir -p src/router
    mkdir -p src/api
    mkdir -p tests

    # 创建示例文件
    touch src/App.vue
    touch src/components/Header.vue
    touch src/views/Home.vue
    touch src/store/index.js
    touch src/router/index.js
    touch src/api/userApi.js
    touch tests/components.spec.js

    # 创建 README
    echo "# Vue Frontend" > README.md

    cd ../..
    print_success "Vue 前端应用项目创建完成"
}

# 创建测试项目 4：Java Spring Boot 服务
create_springboot_project() {
    print_test "创建测试项目 4：Java Spring Boot 服务"

    mkdir -p test-projects/springboot-service
    cd test-projects/springboot-service

    # 创建 pom.xml
    cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>springboot-service</artifactId>
    <version>1.0.0</version>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
        </dependency>
    </dependencies>
</project>
EOF

    # 创建目录结构
    mkdir -p src/main/java/com/example/controller
    mkdir -p src/main/java/com/example/service
    mkdir -p src/main/java/com/example/model
    mkdir -p src/main/java/com/example/repository
    mkdir -p src/test/java

    # 创建示例文件
    touch src/main/java/com/example/Application.java
    touch src/main/java/com/example/controller/UserController.java
    touch src/main/java/com/example/service/UserService.java
    touch src/main/java/com/example/model/User.java
    touch src/test/java/ApplicationTests.java

    # 创建 README
    echo "# Spring Boot Service" > README.md

    cd ../..
    print_success "Spring Boot 服务项目创建完成"
}

# 创建测试项目 5：Go 微服务
create_go_project() {
    print_test "创建测试项目 5：Go 微服务"

    mkdir -p test-projects/go-microservice
    cd test-projects/go-microservice

    # 创建 go.mod
    cat > go.mod << 'EOF'
module github.com/example/go-microservice

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/go-redis/redis/v8 v8.11.5
    gorm.io/gorm v1.25.5
    gorm.io/driver/postgres v1.5.4
)
EOF

    # 创建目录结构
    mkdir -p cmd/server
    mkdir -p internal/handler
    mkdir -p internal/service
    mkdir -p internal/model
    mkdir -p internal/repository
    mkdir -p pkg/utils

    # 创建示例文件
    touch cmd/server/main.go
    touch internal/handler/user_handler.go
    touch internal/service/user_service.go
    touch internal/model/user.go
    touch internal/repository/user_repository.go
    touch pkg/utils/logger.go

    # 创建 README
    echo "# Go Microservice" > README.md

    cd ../..
    print_success "Go 微服务项目创建完成"
}

# 运行文档生成脚本
run_generator() {
    local project_path=$1
    local project_name=$2

    print_test "为 $project_name 生成文档"

    if [ ! -f "./generate-docs-smart.sh" ]; then
        print_error "找不到 generate-docs-smart.sh 脚本"
        return 1
    fi

    ./generate-docs-smart.sh "$project_path"

    if [ $? -eq 0 ]; then
        print_success "$project_name 文档生成成功"

        # 验证生成的文件
        print_info "验证生成的文件..."
        local files=("CLAUDE.md" "requirements-analysis.md" "file-functions.md" "system-overview.puml" "module-flowchart.puml" "sequence-diagram.puml")
        local all_exist=true

        for file in "${files[@]}"; do
            if [ -f "$project_path/$file" ]; then
                echo -e "  ${GREEN}✓${NC} $file"
            else
                echo -e "  ${RED}✗${NC} $file (缺失)"
                all_exist=false
            fi
        done

        if [ "$all_exist" = true ]; then
            print_success "所有文档文件已生成"
        else
            print_error "部分文档文件缺失"
        fi
    else
        print_error "$project_name 文档生成失败"
        return 1
    fi
}

# 主测试流程
main() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════╗"
    echo "║   智能文档生成脚本测试工具            ║"
    echo "║   Smart Generator Test Suite           ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${NC}\n"

    # 清理旧的测试目录
    cleanup

    # 创建测试项目
    mkdir -p test-projects

    create_fullstack_project
    create_api_project
    create_frontend_project
    create_springboot_project
    create_go_project

    print_test "开始测试文档生成"

    # 为每个项目生成文档
    run_generator "test-projects/fullstack-app" "React + Express 全栈应用"
    run_generator "test-projects/fastapi-service" "Python FastAPI 服务"
    run_generator "test-projects/vue-frontend" "Vue 前端应用"
    run_generator "test-projects/springboot-service" "Java Spring Boot 服务"
    run_generator "test-projects/go-microservice" "Go 微服务"

    print_test "测试完成"

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}测试结果总结${NC}"
    echo -e "${GREEN}========================================${NC}\n"

    echo -e "${CYAN}生成的测试项目：${NC}"
    echo -e "  1. test-projects/fullstack-app"
    echo -e "  2. test-projects/fastapi-service"
    echo -e "  3. test-projects/vue-frontend"
    echo -e "  4. test-projects/springboot-service"
    echo -e "  5. test-projects/go-microservice"

    echo -e "\n${CYAN}查看生成的文档：${NC}"
    echo -e "  cd test-projects/fullstack-app && ls -la *.md *.puml"

    echo -e "\n${CYAN}清理测试项目：${NC}"
    echo -e "  rm -rf test-projects"

    echo -e "\n${GREEN}========================================${NC}\n"

    print_success "所有测试完成！"
}

# 执行主函数
main
