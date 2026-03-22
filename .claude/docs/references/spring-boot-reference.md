# Spring Boot 最佳实践本地参考

> **更新:** 2025-03-22

---

## 核心规范

### 项目结构

```
src/main/java/com/company/project/
├── controller/      # 控制器
├── service/         # 业务逻辑
├── repository/      # 数据访问
├── entity/          # 实体
├── dto/             # 数据传输对象
├── config/          # 配置
└── exception/       # 异常处理
```

### RESTful API 设计

```java
@RestController
@RequestMapping("/api/equipment")
public class EquipmentController {

    @GetMapping
    public List<Equipment> findAll() {
        return equipmentService.findAll();
    }

    @GetMapping("/{id}")
    public Equipment findById(@PathVariable String id) {
        return equipmentService.findById(id);
    }

    @PostMapping
    public Equipment create(@Valid @RequestBody EquipmentDto dto) {
        return equipmentService.create(dto);
    }

    @PutMapping("/{id}")
    public Equipment update(@PathVariable String id,
                           @Valid @RequestBody EquipmentDto dto) {
        return equipmentService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        equipmentService.delete(id);
    }
}
```

### 依赖注入

```java
// ✅ 构造器注入 (推荐)
@Service
public class EquipmentService {
    private final EquipmentRepository repository;

    public EquipmentService(EquipmentRepository repository) {
        this.repository = repository;
    }
}

// ✅ 使用 Lombok 简化
@Service
@RequiredArgsConstructor
public class EquipmentService {
    private final EquipmentRepository repository;
}
```

### 异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(
            ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGeneric(
            Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ErrorResponse("Internal server error"));
    }
}
```

### 配置

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/mes
    username: ${DB_USER:mes}
    password: ${DB_PASSWORD:password}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

server:
  port: 8080
```

---

相关文档:
- [JAVA Skill](../../skills/java/SKILL.md)
