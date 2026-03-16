---
name: project-analyzer
description: Analyze and document current project functionality, modules, and business flows. Make sure to use this skill whenever the user mentions: 项目分析、梳理项目、项目功能、项目流程图、时序图、PlantUML、系统架构图、业务流程、代码分析、项目文档, or wants to understand the structure of their codebase. This skill helps generate comprehensive project documentation including detailed feature lists with corresponding files and PlantUML diagrams (flowcharts, sequence diagrams, activity diagrams).
---

# Project Analyzer

This skill helps analyze a codebase and generate comprehensive documentation including:

1. **Detailed feature list** with corresponding files
2. **Business flow diagrams** in PlantUML format
3. **Sequence diagrams** showing data flow between components

## Workflow

### Step 1: Analyze Project Structure

First, explore the project to understand its architecture:

1. Check project type (Java Maven, Python, JavaScript, etc.)
2. Identify main modules/packages
3. Locate API/service interfaces
4. Find data models/entities
5. Identify configuration files

Use `Glob` to find relevant files by pattern and `Read` to examine key files.

### Step 2: Identify Business Modules

Based on the project structure, identify the main business modules:

- **Service/API Layer**: Look for interfaces `Service`, `Controller`, `Api` suffixes
- **Business Logic**: Look for `Biz`, `Manager`, `Handler` classes
- **Data Access**: Look for `Dao`, `Mapper`, `Repository` classes
- **Models**: Look for `Entity`, `Dto`, `Vo`, `Pojo` classes

**Common patterns to identify:**

**Java Spring Boot:**
- `*Service` interfaces and implementations
- `*Controller` REST endpoints
- `*Mapper` MyBatis data access
- `entity/`, `dto/`, `vo/` packages

**Python Django/Flask:**
- `views.py`, `serializers.py`
- `models.py` (database schema)
- `urls.py` (route definitions)

**Node.js/Express:**
- `routes/`, `controllers/`
- `models/`, `schemas/`
- `services/`, `utils/`

### Step 3: Generate Feature List

Organize findings into a structured feature list format:

```
# 项目功能列表

## 模块名称

### 功能描述
- **功能点1**: 简要描述
  - 相关文件: `path/to/File.java`
- **功能点2**: 简要描述
  - 相关文件: `path/to/File.java`

### API接口
- `GET /api/endpoint`: 描述
  - 文件: `path/to/Controller.java`

### 数据实体
- `EntityName`: 描述
  - 文件: `path/to/Entity.java`
```

### Step 4: Generate PlantUML Diagrams

## PlantUML Flowchart Template

Use this format for business flow diagrams:

```plantuml
@startuml 业务流程图-模块名称
skinparam backgroundColor #FFFFFF
skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}
skinparam arrowColor #424242

start
:用户请求;
:模块处理;
:返回结果;
end
@enduml
```

## PlantUML Sequence Diagram Template

Use this format for sequence diagrams:

```plantuml
@startuml 时序图-模块名称
skinparam backgroundColor #FFFFFF
skinparam sequenceMessageAlign center
skinparam participant {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

actor User as user
participant Controller as "Controller"
participant Service as "Service"
participant Mapper as "Mapper"
participant Database as "Database"

user -> Controller: 请求
activate Controller
Controller -> Service: 调用业务逻辑
activate Service
Service -> Mapper: 查询数据
activate Mapper
Mapper -> Database: SQL查询
activate Database
Database --> Mapper: 返回结果
deactivate Database
Mapper --> Service: 返回实体
deactivate Mapper
Service --> Controller: 返回VO
deactivate Service
Controller --> user: 返回结果
deactivate Controller
@enduml
```

## PlantUML Component Diagram Template

```plantuml
@startuml 组件图-系统架构
skinparam backgroundColor #FFFFFF
skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

package "业务层" {
  [Service 1] as svc1
  [Service 2] as svc2
}

package "数据层" {
  [Mapper 1] as map1
  [Mapper 2] as map2
}

database "Database" as db

svc1 --> map1
svc2 --> map2
map1 --> db
map2 --> db
@enduml
```

### Step 5: Format Output

Provide output in the following structure:

```
# [Project Name] 项目分析文档

## 1. 项目概述
- 项目类型: [Java/Python/JavaScript/...]
- 技术栈: [列出主要框架和库]
- 项目结构: [简要描述目录结构]

## 2. 功能列表

### 2.1 [模块1名称]
... (功能详情)

### 2.2 [模块2名称]
... (功能详情)

## 3. 业务流程图

### 3.1 [流程名称]
```plantuml
...
```

## 4. 时序图

### 4.1 [功能名称]
```plantuml
...
```

## 5. 系统架构图

```plantuml
...
```
```

## Tips for Effective Analysis

### For Java Projects
- Focus on `*Service` interfaces for business functions
- Look at `@RequestPath` or `@RequestMapping` annotations for API endpoints
- Check `pom.xml` for dependency insights
- Entity classes in models show data structure

### For Microservices
- Identify service boundaries by module structure
- Each service typically has independent API/Service/Mapper layers
- Look for Dubbo, Feign, or other RPC configurations

### For Large Projects
- Start with main application entry point
- Follow call chains from Controllers to Services to Mappers
- Group related functionality by business domain

## Output File

Save the analysis to a `.puml` file or markdown file with PlantUML diagrams embedded. Users can then:
- Copy PlantUML code to online editors like PlantText.com
- Use PlantUML IntelliJ plugin
- Generate images with PlantUML command line tool
