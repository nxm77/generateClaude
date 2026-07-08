# 新人 JPA 编程培训文档

> 适用技术栈：JDK 25、Spring Boot、Spring Data JPA、Hibernate、DDD、合一模式 / 分离模式  
> 适用对象：刚进入 Java + Spring Boot 项目的新人、从 C++ / C# / VB.NET 转 Java 的开发人员、准备参与企业级业务系统开发的工程师  
> 文档目标：让新人不仅会“写 Repository”，还要理解事务、聚合、实体生命周期、JPA 性能坑，以及如何在企业项目中选择合一模式或分离模式。

---

## 0. 版本口径与学习前提

### 0.1 推荐版本基线

| 类别 | 推荐口径 | 说明 |
|---|---|---|
| JDK | JDK 25 | Java 25 已正式发布，适合作为新项目长期基线之一。 |
| Spring Boot | Spring Boot 4.1.x 或企业统一 BOM 指定版本 | 新项目建议统一通过 Spring Boot BOM 管理依赖版本，不手工指定 Hibernate、Jackson、Validation 等版本。 |
| Spring Data JPA | 随 Spring Boot BOM | 不单独覆盖版本，避免依赖冲突。 |
| Hibernate ORM | 随 Spring Boot BOM | Hibernate 是 JPA Provider，不建议新人绕过 Spring Boot BOM 自行升级。 |
| 数据库迁移 | Flyway 或 Liquibase | 数据库结构变更必须版本化。 |
| 测试数据库 | Testcontainers 或企业标准测试库 | 不建议只依赖 H2 模拟生产数据库。 |
| 包命名 | `com.company.project` | 按业务上下文拆包，避免所有代码堆在 `service`、`entity`、`repository` 下。 |

### 0.2 学习目标

新人学完本文档后，应该能够做到：

1. 理解 JPA 不是“自动 SQL 生成器”，而是 ORM + 持久化上下文 + 事务边界的组合。
2. 能正确设计 Entity、Value Object、Aggregate、Repository、Application Service。
3. 能区分 DDD 的“领域模型”与数据库表模型。
4. 能在合一模式和分离模式之间做工程取舍。
5. 能避免常见 JPA 问题：N+1、懒加载异常、事务边界混乱、双向关联失控、错误的 cascade、批量更新后缓存脏数据。
6. 能写出符合企业项目要求的 Spring Boot + JPA 代码。

---

## 1. JPA、Hibernate、Spring Data JPA 的关系

### 1.1 三者关系

很多新人容易把 JPA、Hibernate、Spring Data JPA 混为一谈。实际关系如下：

```text
业务代码
  ↓
Spring Data JPA Repository
  ↓
JPA API / Jakarta Persistence API
  ↓
Hibernate ORM 具体实现
  ↓
JDBC / 连接池
  ↓
关系型数据库
```

- **JPA / Jakarta Persistence**：Java 持久化规范，定义 `@Entity`、`@Id`、`EntityManager`、JPQL、事务语义等。
- **Hibernate**：JPA 最常用的实现之一，负责真正的 ORM、SQL 生成、一级缓存、脏检查、关联加载等。
- **Spring Data JPA**：Spring 对 JPA Repository 的封装，减少样板代码，例如 `JpaRepository`、方法名查询、分页查询、自定义查询等。
- **Spring Boot**：自动配置 DataSource、EntityManagerFactory、TransactionManager、Hibernate 属性、Repository 扫描等。

### 1.2 新人必须掌握的核心概念

| 概念 | 简要解释 | 新人常见误区 |
|---|---|---|
| Entity | 可持久化对象，映射数据库表 | 以为 Entity 只是 DTO |
| Persistence Context | 持久化上下文，也就是一级缓存和变更追踪环境 | 不知道同一个事务内查询同一 ID 会返回同一对象 |
| Dirty Checking | 脏检查，事务提交时自动检测 Entity 变更并更新数据库 | 以为必须每次调用 `save()` 才会更新 |
| Lazy Loading | 懒加载，关联对象需要时才查询 | 在事务外访问导致 `LazyInitializationException` |
| Transaction | 事务边界 | 在 Controller 里随意开启事务，或在私有方法上加 `@Transactional` |
| Aggregate | DDD 聚合，一组强一致对象的边界 | 把数据库外键关系误认为聚合边界 |
| Repository | 聚合的持久化抽象 | 把 Repository 当成任意 SQL 工具类 |

---

## 2. JDK 25 下的 Java 编码建议

JDK 25 可以正常用于现代 Spring Boot 服务开发。新人需要注意：不是所有新语法都适合直接放进企业核心业务代码。

### 2.1 推荐使用的现代 Java 写法

#### 2.1.1 `record` 适合 DTO、Command、Query Result，不适合 JPA Entity

推荐：

```java
public record CreateOrderCommand(
        Long customerId,
        List<CreateOrderItemCommand> items
) {}

public record OrderSummaryView(
        Long orderId,
        String orderNo,
        String status,
        BigDecimal totalAmount
) {}
```

不推荐：

```java
// 不推荐作为 JPA Entity
// JPA Entity 通常需要无参构造、代理、生命周期管理和可变状态。
public record Order(Long id, String orderNo) {}
```

#### 2.1.2 `sealed` 可用于受控领域类型

```java
public sealed interface PaymentResult permits PaymentSucceeded, PaymentFailed {
}

public record PaymentSucceeded(String paymentNo) implements PaymentResult {
}

public record PaymentFailed(String reason) implements PaymentResult {
}
```

适用场景：

- 领域结果类型有限。
- 领域事件类型有限。
- 状态转换结果有限。

#### 2.1.3 `switch` 表达式提升可读性

```java
public BigDecimal discountRate(CustomerLevel level) {
    return switch (level) {
        case NORMAL -> BigDecimal.ZERO;
        case SILVER -> new BigDecimal("0.05");
        case GOLD -> new BigDecimal("0.10");
        case VIP -> new BigDecimal("0.15");
    };
}
```

### 2.2 谨慎使用的能力

#### 2.2.1 预览特性不要直接进入企业生产代码

JDK 25 包含一些预览、实验或孵化特性。新人可以学习，但企业项目应遵守统一编译参数和生产规范。默认建议：

- 不在核心业务代码中使用 preview feature。
- 不在共享库中使用 preview feature。
- 不因为语法新而破坏团队维护成本。

#### 2.2.2 虚拟线程不是 JPA 性能万能药

虚拟线程适合大量阻塞 I/O 场景，但 JPA 仍受数据库连接池限制。

错误理解：

```text
开启虚拟线程 = 数据库并发能力无限提升
```

正确理解：

```text
虚拟线程可以降低线程资源成本，但 JDBC 访问仍需要数据库连接。
真正限制通常是：连接池大小、数据库锁、慢 SQL、事务持有时间。
```

使用建议：

- 对外 HTTP 请求、文件 I/O 等阻塞场景可以评估虚拟线程。
- JPA 事务不要包住远程调用、长耗时计算、批量大循环。
- 连接池大小必须按数据库承载能力设置，不是越大越好。

---

## 3. DDD 基础：先理解业务边界，再写 JPA

### 3.1 为什么 JPA 项目要讲 DDD

JPA 的 Entity 看起来很像数据库表映射对象，但企业系统的复杂性不在 CRUD，而在：

- 业务规则如何封装。
- 状态如何转换。
- 多对象之间的一致性如何保证。
- 跨模块更新如何避免互相污染。
- 数据库表结构变化如何不拖垮业务代码。

DDD 的作用不是增加复杂度，而是帮助团队把业务复杂度放在正确位置。

### 3.2 DDD 常见对象

| 对象 | 含义 | 示例 |
|---|---|---|
| Entity | 有身份标识，生命周期内可变 | `Order`、`Customer`、`Product` |
| Value Object | 无身份标识，用值表达概念，通常不可变 | `Money`、`Address`、`DateRange` |
| Aggregate | 一组需要强一致维护的对象集合 | `Order` + `OrderItem` |
| Aggregate Root | 聚合根，外部只能通过它修改聚合内部 | `Order` |
| Repository | 按聚合根进行持久化 | `OrderRepository` |
| Domain Service | 放置不属于单个实体的领域规则 | `PricingService` |
| Application Service | 编排用例、事务、权限、调用外部系统 | `OrderApplicationService` |
| Domain Event | 表示领域中已经发生的事实 | `OrderSubmittedEvent` |

### 3.3 典型分层

```text
interfaces / adapter-in
  ├─ controller
  ├─ request
  └─ response

application
  ├─ command
  ├─ query
  └─ service

domain
  ├─ model
  ├─ repository
  ├─ service
  └─ event

infrastructure / adapter-out
  ├─ persistence
  ├─ mapper
  ├─ client
  └─ config
```

说明：

- Controller 不写业务规则。
- Application Service 负责事务和用例编排。
- Domain Model 负责核心业务状态和规则。
- Infrastructure 负责数据库、MQ、外部接口、缓存等技术细节。

---

## 4. 合一模式与分离模式

### 4.1 什么是合一模式

**合一模式**是指：

```text
DDD 领域对象 = JPA Entity
```

也就是说，一个类同时承担：

- 领域模型职责：封装业务规则、状态转换、聚合一致性。
- JPA 持久化职责：映射表、字段、关联关系、版本号等。

示意：

```text
Order.java
  ├─ DDD 聚合根
  ├─ JPA @Entity
  ├─ 业务方法 submit/cancel/addItem
  └─ 数据库映射 @Table/@OneToMany/@Version
```

### 4.2 什么是分离模式

**分离模式**是指：

```text
DDD 领域对象 ≠ JPA Entity
```

领域对象保持纯净，不引入 JPA 注解；JPA Entity 只负责数据库映射。

示意：

```text
Order        // domain model，纯业务对象
OrderJpaEntity // persistence model，JPA 持久化对象
OrderMapper  // domain model <-> JPA entity
OrderRepositoryAdapter // 实现 domain repository
```

### 4.3 两种模式对比

| 维度 | 合一模式 | 分离模式 |
|---|---|---|
| 代码量 | 少 | 多 |
| 上手难度 | 低 | 高 |
| JPA 侵入领域 | 有 | 无或很少 |
| 性能控制 | 直接 | 需要 mapper 配合 |
| 复杂业务适应性 | 中等 | 强 |
| 复杂遗留库适应性 | 中等偏弱 | 强 |
| 领域模型纯净度 | 一般 | 高 |
| 新人学习成本 | 低 | 较高 |
| 推荐场景 | 中小型模块、表结构和领域模型接近 | 核心复杂业务、遗留库、跨上下文集成、表结构与业务模型差异大 |

### 4.4 企业项目建议

建议采用分级策略：

| 项目 / 模块类型 | 推荐模式 |
|---|---|
| 简单配置表、字典表、查询型模块 | 合一模式 |
| 普通业务模块，聚合简单，表结构清晰 | 合一模式优先 |
| 核心交易、订单、库存、账户、设备状态等强规则模块 | 分离模式优先 |
| 表结构历史包袱重、字段含义混乱、一个表承载多个业务概念 | 分离模式 |
| 跨系统同步、跨模块写入、需要防腐层 | 分离模式 |
| 团队 JPA 经验较少的早期项目 | 从合一模式开始，但预留向分离模式演进的边界 |

### 4.5 一句话原则

```text
表结构接近业务模型，用合一模式；
表结构污染业务模型，用分离模式；
规则简单，用合一模式；
规则复杂、生命周期长、跨模块多，用分离模式。
```

---

## 5. 合一模式示例：订单聚合

### 5.1 包结构

```text
com.example.order
  ├─ interfaces
  │   └─ OrderController.java
  ├─ application
  │   ├─ OrderApplicationService.java
  │   └─ command
  │       ├─ CreateOrderCommand.java
  │       └─ CreateOrderItemCommand.java
  ├─ domain
  │   ├─ Order.java
  │   ├─ OrderItem.java
  │   ├─ OrderStatus.java
  │   ├─ Money.java
  │   └─ OrderRepository.java
  └─ infrastructure
      └─ JpaOrderRepository.java
```

### 5.2 Maven 示例

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>4.1.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>jpa-ddd-training</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>25</java.version>
    </properties>

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
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

### 5.3 application.yml

```yaml
spring:
  application:
    name: jpa-ddd-training

  datasource:
    url: jdbc:postgresql://localhost:5432/training
    username: training
    password: training
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 3000

  jpa:
    open-in-view: false
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: true
        jdbc:
          batch_size: 50
        order_inserts: true
        order_updates: true

  flyway:
    enabled: true
    locations: classpath:db/migration

logging:
  level:
    org.hibernate.SQL: debug
    org.hibernate.orm.jdbc.bind: trace
```

关键说明：

- `open-in-view: false`：避免 Controller 层隐式触发懒加载，强迫开发者在事务内组织好查询数据。
- `ddl-auto: validate`：生产和准生产环境不允许 Hibernate 自动改表。
- 表结构必须通过 Flyway / Liquibase 版本化。

### 5.4 Flyway 建表脚本

```sql
-- V1__create_order_tables.sql
CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    order_no VARCHAR(64) NOT NULL UNIQUE,
    customer_id BIGINT NOT NULL,
    status VARCHAR(32) NOT NULL,
    total_amount NUMERIC(18, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    version BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id),
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(18, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL
);

CREATE INDEX idx_order_customer_id ON orders(customer_id);
CREATE INDEX idx_order_item_order_id ON order_items(order_id);
```

### 5.5 Value Object：Money

```java
package com.example.order.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Objects;

@Embeddable
public class Money {

    @Column(name = "total_amount", precision = 18, scale = 2, nullable = false)
    private BigDecimal amount;

    @Column(name = "currency", length = 3, nullable = false)
    private String currency;

    protected Money() {
        // JPA only
    }

    private Money(BigDecimal amount, String currency) {
        if (amount == null) {
            throw new IllegalArgumentException("金额不能为空");
        }
        if (currency == null || currency.isBlank()) {
            throw new IllegalArgumentException("币种不能为空");
        }
        this.amount = amount.setScale(2, RoundingMode.HALF_UP);
        this.currency = currency;
    }

    public static Money of(BigDecimal amount, String currency) {
        return new Money(amount, currency);
    }

    public static Money zero(String currency) {
        return new Money(BigDecimal.ZERO, currency);
    }

    public Money add(Money other) {
        requireSameCurrency(other);
        return new Money(this.amount.add(other.amount), this.currency);
    }

    public Money multiply(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("数量必须大于 0");
        }
        return new Money(this.amount.multiply(BigDecimal.valueOf(quantity)), this.currency);
    }

    private void requireSameCurrency(Money other) {
        if (!Objects.equals(this.currency, other.currency)) {
            throw new IllegalArgumentException("币种不一致");
        }
    }

    public BigDecimal amount() {
        return amount;
    }

    public String currency() {
        return currency;
    }
}
```

说明：

- `Money` 是值对象。
- 值对象的修改应该返回新对象，而不是直接修改自身。
- 合一模式下，值对象可以使用 `@Embeddable`。

### 5.6 Entity：OrderItem

```java
package com.example.order.domain;

import jakarta.persistence.*;

@Entity
@Table(name = "order_items")
public class OrderItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "product_id", nullable = false)
    private Long productId;

    @Column(name = "product_name", nullable = false, length = 200)
    private String productName;

    @Column(name = "quantity", nullable = false)
    private int quantity;

    @AttributeOverrides({
            @AttributeOverride(name = "amount", column = @Column(name = "unit_price", precision = 18, scale = 2, nullable = false)),
            @AttributeOverride(name = "currency", column = @Column(name = "currency", length = 3, nullable = false))
    })
    private Money unitPrice;

    protected OrderItem() {
        // JPA only
    }

    private OrderItem(Long productId, String productName, int quantity, Money unitPrice) {
        if (productId == null) {
            throw new IllegalArgumentException("商品 ID 不能为空");
        }
        if (productName == null || productName.isBlank()) {
            throw new IllegalArgumentException("商品名称不能为空");
        }
        if (quantity <= 0) {
            throw new IllegalArgumentException("数量必须大于 0");
        }
        if (unitPrice == null) {
            throw new IllegalArgumentException("单价不能为空");
        }
        this.productId = productId;
        this.productName = productName;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public static OrderItem create(Long productId, String productName, int quantity, Money unitPrice) {
        return new OrderItem(productId, productName, quantity, unitPrice);
    }

    void attachTo(Order order) {
        this.order = order;
    }

    Money subtotal() {
        return unitPrice.multiply(quantity);
    }

    public Long id() {
        return id;
    }

    public Long productId() {
        return productId;
    }

    public String productName() {
        return productName;
    }

    public int quantity() {
        return quantity;
    }

    public Money unitPrice() {
        return unitPrice;
    }
}
```

### 5.7 Aggregate Root：Order

```java
package com.example.order.domain;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_no", nullable = false, unique = true, length = 64)
    private String orderNo;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 32)
    private OrderStatus status;

    @Embedded
    private Money totalAmount;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    protected Order() {
        // JPA only
    }

    private Order(String orderNo, Long customerId) {
        if (orderNo == null || orderNo.isBlank()) {
            throw new IllegalArgumentException("订单号不能为空");
        }
        if (customerId == null) {
            throw new IllegalArgumentException("客户 ID 不能为空");
        }
        this.orderNo = orderNo;
        this.customerId = customerId;
        this.status = OrderStatus.DRAFT;
        this.totalAmount = Money.zero("CNY");
        this.createdAt = LocalDateTime.now();
        this.updatedAt = this.createdAt;
    }

    public static Order create(String orderNo, Long customerId) {
        return new Order(orderNo, customerId);
    }

    public void addItem(OrderItem item) {
        requireDraft();
        item.attachTo(this);
        this.items.add(item);
        recalculateTotalAmount();
        touch();
    }

    public void submit() {
        requireDraft();
        if (items.isEmpty()) {
            throw new IllegalStateException("订单明细不能为空");
        }
        this.status = OrderStatus.SUBMITTED;
        touch();
    }

    public void cancel() {
        if (this.status == OrderStatus.COMPLETED) {
            throw new IllegalStateException("已完成订单不能取消");
        }
        this.status = OrderStatus.CANCELLED;
        touch();
    }

    private void requireDraft() {
        if (this.status != OrderStatus.DRAFT) {
            throw new IllegalStateException("只有草稿订单允许修改");
        }
    }

    private void recalculateTotalAmount() {
        this.totalAmount = this.items.stream()
                .map(OrderItem::subtotal)
                .reduce(Money.zero("CNY"), Money::add);
    }

    private void touch() {
        this.updatedAt = LocalDateTime.now();
    }

    public Long id() {
        return id;
    }

    public String orderNo() {
        return orderNo;
    }

    public Long customerId() {
        return customerId;
    }

    public OrderStatus status() {
        return status;
    }

    public Money totalAmount() {
        return totalAmount;
    }

    public List<OrderItem> items() {
        return Collections.unmodifiableList(items);
    }
}
```

### 5.8 枚举

```java
package com.example.order.domain;

public enum OrderStatus {
    DRAFT,
    SUBMITTED,
    COMPLETED,
    CANCELLED
}
```

必须使用：

```java
@Enumerated(EnumType.STRING)
```

不要使用：

```java
@Enumerated(EnumType.ORDINAL)
```

原因：枚举顺序一旦调整，历史数据含义会错乱。

### 5.9 Repository

```java
package com.example.order.domain;

import java.util.Optional;

public interface OrderRepository {

    Order save(Order order);

    Optional<Order> findById(Long id);

    Optional<Order> findByOrderNo(String orderNo);
}
```

```java
package com.example.order.infrastructure;

import com.example.order.domain.Order;
import com.example.order.domain.OrderRepository;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface JpaOrderRepository extends JpaRepository<Order, Long>, OrderRepository {

    @Override
    @EntityGraph(attributePaths = "items")
    Optional<Order> findById(Long id);

    @Override
    Optional<Order> findByOrderNo(String orderNo);
}
```

说明：

- 这里属于合一模式：`Order` 本身就是 JPA Entity。
- `JpaOrderRepository` 同时继承领域 Repository 和 Spring Data JPA Repository。
- 查询订单详情时用 `@EntityGraph` 加载明细，避免 N+1 和事务外懒加载。

### 5.10 Application Service

```java
package com.example.order.application;

import com.example.order.application.command.CreateOrderCommand;
import com.example.order.application.command.CreateOrderItemCommand;
import com.example.order.domain.Money;
import com.example.order.domain.Order;
import com.example.order.domain.OrderItem;
import com.example.order.domain.OrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderApplicationService {

    private final OrderRepository orderRepository;
    private final OrderNoGenerator orderNoGenerator;

    public OrderApplicationService(OrderRepository orderRepository,
                                   OrderNoGenerator orderNoGenerator) {
        this.orderRepository = orderRepository;
        this.orderNoGenerator = orderNoGenerator;
    }

    @Transactional
    public Long createOrder(CreateOrderCommand command) {
        String orderNo = orderNoGenerator.nextOrderNo();
        Order order = Order.create(orderNo, command.customerId());

        for (CreateOrderItemCommand item : command.items()) {
            order.addItem(OrderItem.create(
                    item.productId(),
                    item.productName(),
                    item.quantity(),
                    Money.of(item.unitPrice(), "CNY")
            ));
        }

        Order saved = orderRepository.save(order);
        return saved.id();
    }

    @Transactional
    public void submitOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在: " + orderId));
        order.submit();
        // 不强制调用 save。事务提交时，JPA dirty checking 会更新状态。
    }
}
```

### 5.11 Command

```java
package com.example.order.application.command;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record CreateOrderCommand(
        @NotNull Long customerId,
        @NotEmpty List<@Valid CreateOrderItemCommand> items
) {}
```

```java
package com.example.order.application.command;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CreateOrderItemCommand(
        @NotNull Long productId,
        @NotBlank String productName,
        @Min(1) int quantity,
        @DecimalMin("0.01") BigDecimal unitPrice
) {}
```

### 5.12 Controller

```java
package com.example.order.interfaces;

import com.example.order.application.OrderApplicationService;
import com.example.order.application.command.CreateOrderCommand;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderApplicationService orderApplicationService;

    public OrderController(OrderApplicationService orderApplicationService) {
        this.orderApplicationService = orderApplicationService;
    }

    @PostMapping
    public ResponseEntity<CreateOrderResponse> create(@Valid @RequestBody CreateOrderCommand command) {
        Long orderId = orderApplicationService.createOrder(command);
        return ResponseEntity.ok(new CreateOrderResponse(orderId));
    }

    @PostMapping("/{orderId}/submit")
    public ResponseEntity<Void> submit(@PathVariable Long orderId) {
        orderApplicationService.submitOrder(orderId);
        return ResponseEntity.noContent().build();
    }

    public record CreateOrderResponse(Long orderId) {}
}
```

### 5.13 合一模式新人注意事项

合一模式不是“把所有 setter 暴露出去”。正确做法：

```java
// 推荐
order.submit();
order.cancel();
order.addItem(item);
```

不推荐：

```java
// 不推荐
order.setStatus(OrderStatus.SUBMITTED);
order.getItems().add(item);
order.setTotalAmount(amount);
```

业务状态必须通过领域方法改变。

---

## 6. 分离模式示例：领域模型与 JPA Entity 分开

### 6.1 包结构

```text
com.example.order
  ├─ application
  │   └─ OrderApplicationService.java
  ├─ domain
  │   ├─ model
  │   │   ├─ Order.java
  │   │   ├─ OrderItem.java
  │   │   └─ Money.java
  │   └─ repository
  │       └─ OrderRepository.java
  └─ infrastructure
      └─ persistence
          ├─ OrderJpaEntity.java
          ├─ OrderItemJpaEntity.java
          ├─ SpringDataOrderJpaRepository.java
          ├─ OrderPersistenceAdapter.java
          └─ OrderPersistenceMapper.java
```

### 6.2 纯领域模型

```java
package com.example.order.domain.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class Order {

    private final Long id;
    private final String orderNo;
    private final Long customerId;
    private OrderStatus status;
    private Money totalAmount;
    private final List<OrderItem> items;

    private Order(Long id,
                  String orderNo,
                  Long customerId,
                  OrderStatus status,
                  Money totalAmount,
                  List<OrderItem> items) {
        this.id = id;
        this.orderNo = orderNo;
        this.customerId = customerId;
        this.status = status;
        this.totalAmount = totalAmount;
        this.items = new ArrayList<>(items);
    }

    public static Order createNew(String orderNo, Long customerId) {
        return new Order(null, orderNo, customerId, OrderStatus.DRAFT, Money.zero("CNY"), List.of());
    }

    public static Order restore(Long id,
                                String orderNo,
                                Long customerId,
                                OrderStatus status,
                                Money totalAmount,
                                List<OrderItem> items) {
        return new Order(id, orderNo, customerId, status, totalAmount, items);
    }

    public void addItem(OrderItem item) {
        requireDraft();
        this.items.add(item);
        recalculateTotalAmount();
    }

    public void submit() {
        requireDraft();
        if (items.isEmpty()) {
            throw new IllegalStateException("订单明细不能为空");
        }
        this.status = OrderStatus.SUBMITTED;
    }

    private void requireDraft() {
        if (this.status != OrderStatus.DRAFT) {
            throw new IllegalStateException("只有草稿订单允许修改");
        }
    }

    private void recalculateTotalAmount() {
        this.totalAmount = this.items.stream()
                .map(OrderItem::subtotal)
                .reduce(Money.zero("CNY"), Money::add);
    }

    public Long id() { return id; }
    public String orderNo() { return orderNo; }
    public Long customerId() { return customerId; }
    public OrderStatus status() { return status; }
    public Money totalAmount() { return totalAmount; }
    public List<OrderItem> items() { return Collections.unmodifiableList(items); }
}
```

### 6.3 JPA Entity

```java
package com.example.order.infrastructure.persistence;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
class OrderJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_no", nullable = false, unique = true, length = 64)
    private String orderNo;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "status", nullable = false, length = 32)
    private String status;

    @Column(name = "total_amount", precision = 18, scale = 2, nullable = false)
    private BigDecimal totalAmount;

    @Column(name = "currency", length = 3, nullable = false)
    private String currency;

    @Version
    @Column(name = "version", nullable = false)
    private Long version;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItemJpaEntity> items = new ArrayList<>();

    protected OrderJpaEntity() {
    }

    // getter/setter 只在 infrastructure 内部使用
}
```

```java
package com.example.order.infrastructure.persistence;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "order_items")
class OrderItemJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private OrderJpaEntity order;

    @Column(name = "product_id", nullable = false)
    private Long productId;

    @Column(name = "product_name", nullable = false, length = 200)
    private String productName;

    @Column(name = "quantity", nullable = false)
    private int quantity;

    @Column(name = "unit_price", precision = 18, scale = 2, nullable = false)
    private BigDecimal unitPrice;

    @Column(name = "currency", length = 3, nullable = false)
    private String currency;

    protected OrderItemJpaEntity() {
    }
}
```

### 6.4 Mapper

```java
package com.example.order.infrastructure.persistence;

import com.example.order.domain.model.*;

class OrderPersistenceMapper {

    Order toDomain(OrderJpaEntity entity) {
        List<OrderItem> items = entity.getItems().stream()
                .map(this::toDomainItem)
                .toList();

        return Order.restore(
                entity.getId(),
                entity.getOrderNo(),
                entity.getCustomerId(),
                OrderStatus.valueOf(entity.getStatus()),
                Money.of(entity.getTotalAmount(), entity.getCurrency()),
                items
        );
    }

    private OrderItem toDomainItem(OrderItemJpaEntity entity) {
        return OrderItem.restore(
                entity.getProductId(),
                entity.getProductName(),
                entity.getQuantity(),
                Money.of(entity.getUnitPrice(), entity.getCurrency())
        );
    }

    OrderJpaEntity toEntity(Order domain) {
        OrderJpaEntity entity = new OrderJpaEntity();
        entity.setId(domain.id());
        entity.setOrderNo(domain.orderNo());
        entity.setCustomerId(domain.customerId());
        entity.setStatus(domain.status().name());
        entity.setTotalAmount(domain.totalAmount().amount());
        entity.setCurrency(domain.totalAmount().currency());

        for (OrderItem item : domain.items()) {
            OrderItemJpaEntity itemEntity = new OrderItemJpaEntity();
            itemEntity.setOrder(entity);
            itemEntity.setProductId(item.productId());
            itemEntity.setProductName(item.productName());
            itemEntity.setQuantity(item.quantity());
            itemEntity.setUnitPrice(item.unitPrice().amount());
            itemEntity.setCurrency(item.unitPrice().currency());
            entity.getItems().add(itemEntity);
        }
        return entity;
    }
}
```

### 6.5 Repository Port 与 Adapter

```java
package com.example.order.domain.repository;

import com.example.order.domain.model.Order;

import java.util.Optional;

public interface OrderRepository {
    Order save(Order order);
    Optional<Order> findById(Long id);
}
```

```java
package com.example.order.infrastructure.persistence;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

interface SpringDataOrderJpaRepository extends JpaRepository<OrderJpaEntity, Long> {

    @EntityGraph(attributePaths = "items")
    Optional<OrderJpaEntity> findWithItemsById(Long id);
}
```

```java
package com.example.order.infrastructure.persistence;

import com.example.order.domain.model.Order;
import com.example.order.domain.repository.OrderRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
class OrderPersistenceAdapter implements OrderRepository {

    private final SpringDataOrderJpaRepository jpaRepository;
    private final OrderPersistenceMapper mapper = new OrderPersistenceMapper();

    OrderPersistenceAdapter(SpringDataOrderJpaRepository jpaRepository) {
        this.jpaRepository = jpaRepository;
    }

    @Override
    public Order save(Order order) {
        OrderJpaEntity entity = mapper.toEntity(order);
        OrderJpaEntity saved = jpaRepository.save(entity);
        return mapper.toDomain(saved);
    }

    @Override
    public Optional<Order> findById(Long id) {
        return jpaRepository.findWithItemsById(id).map(mapper::toDomain);
    }
}
```

### 6.6 分离模式新人注意事项

分离模式的核心不是“多写一套类”，而是隔离变化：

- 数据库表结构变化不直接污染领域模型。
- 领域模型可以表达真实业务语言。
- 外部系统、遗留表、历史字段可以留在 infrastructure 层。
- Mapper 是成本，但也是防腐层。

分离模式的常见错误：

1. Mapper 里写业务规则。
2. Domain Model 变成贫血 DTO。
3. 每个字段机械映射，不考虑聚合边界。
4. 保存聚合时没有处理子集合增删，导致重复插入或误删。
5. 为了省事把 JPA Entity 泄漏到 application 或 controller 层。

---

## 7. JPA Entity 设计规范

### 7.1 构造方法

推荐：

```java
protected Order() {
    // JPA only
}

private Order(...) {
    // 业务构造
}

public static Order create(...) {
    return new Order(...);
}
```

不推荐：

```java
public Order() {
}

public void setStatus(OrderStatus status) {
    this.status = status;
}
```

说明：

- JPA 需要无参构造，但不应鼓励业务代码随意 new 空对象。
- 无参构造建议 `protected`。
- 状态修改应通过业务方法，不要开放大量 setter。

### 7.2 主键策略

常见策略：

| 策略 | 特点 | 建议 |
|---|---|---|
| `IDENTITY` | 数据库自增，简单 | 小项目可用；批量插入性能一般 |
| `SEQUENCE` | 使用数据库序列 | PostgreSQL / Oracle 推荐 |
| UUID | 分布式友好 | 注意索引膨胀、排序和存储类型 |
| 业务编码 | 如订单号 | 不建议作为数据库主键，可设唯一索引 |

推荐：

- 数据库主键使用无业务含义的技术 ID。
- 业务编号使用唯一字段，例如 `orderNo`。
- 不要让业务编号承担数据库主键职责，除非企业标准明确要求。

### 7.3 equals / hashCode

JPA Entity 的 `equals` / `hashCode` 非常容易写错。

新人建议：

1. 如果没有强需求，不要重写 Entity 的 `equals` / `hashCode`。
2. 如果必须重写，优先使用不可变的业务唯一键。
3. 不要使用可变字段。
4. 不要把懒加载关联字段放进 `equals` / `hashCode`。
5. 不要让 Lombok `@Data` 自动生成 Entity 的 `equals` / `hashCode`。

不推荐：

```java
@Data
@Entity
public class Order {
    @OneToMany
    private List<OrderItem> items;
}
```

原因：

- `@Data` 会生成 setter、equals、hashCode、toString。
- `toString` 可能触发懒加载。
- 双向关联下可能递归调用。

### 7.4 字段访问方式

推荐字段注解：

```java
@Id
private Long id;
```

不推荐混用字段和 getter 注解：

```java
@Id
public Long getId() {
    return id;
}
```

团队应统一使用字段访问或属性访问。一般推荐字段访问。

### 7.5 枚举字段

必须使用：

```java
@Enumerated(EnumType.STRING)
private OrderStatus status;
```

不要使用：

```java
@Enumerated(EnumType.ORDINAL)
private OrderStatus status;
```

### 7.6 时间字段

建议：

| 场景 | 类型 |
|---|---|
| 创建时间、更新时间、事件发生时间 | `Instant` 或企业统一时间类型 |
| 业务日期，例如账期、生产日期 | `LocalDate` |
| 本地业务时间，例如排班时间 | `LocalDateTime`，但要明确时区规则 |

不要用 `java.util.Date` 作为新代码默认类型。

### 7.7 乐观锁

强烈建议核心业务表加版本号：

```java
@Version
private Long version;
```

适用场景：

- 订单状态变更。
- 库存扣减。
- 设备状态变更。
- 审批流状态更新。
- 任何可能多人同时修改的数据。

新人要理解：

```text
乐观锁不是防止别人修改，而是在提交时发现“我读到的版本已经过期”。
```

---

## 8. 关联关系设计规范

### 8.1 不要把数据库外键关系等同于 JPA 对象关联

数据库有外键，不代表 Java 里一定要写 `@ManyToOne` / `@OneToMany`。

例如订单表有 `customer_id`，不一定要这样：

```java
@ManyToOne(fetch = FetchType.LAZY)
private Customer customer;
```

很多时候只保留 ID 更清晰：

```java
@Column(name = "customer_id", nullable = false)
private Long customerId;
```

判断标准：

- 是否属于同一个聚合？
- 是否需要强一致修改？
- 是否经常一起加载？
- 是否会引发复杂循环依赖？

### 8.2 默认使用 LAZY

推荐：

```java
@ManyToOne(fetch = FetchType.LAZY)
private Order order;
```

不推荐：

```java
@ManyToOne(fetch = FetchType.EAGER)
private Order order;
```

`EAGER` 容易导致不可控 SQL，尤其在列表查询中放大成性能问题。

### 8.3 谨慎使用双向关联

推荐聚合内部可以用双向关联：

```java
Order 1 --- N OrderItem
```

但必须由聚合根维护关系：

```java
public void addItem(OrderItem item) {
    item.attachTo(this);
    this.items.add(item);
}
```

不要让外部同时操作两端：

```java
// 不推荐
order.getItems().add(item);
item.setOrder(order);
```

### 8.4 尽量避免 `@ManyToMany`

不推荐：

```java
@ManyToMany
private Set<Role> roles;
```

推荐显式建中间实体：

```text
User
UserRole
Role
```

原因：

- 中间表通常会逐渐增加字段，例如创建时间、授权人、状态。
- `@ManyToMany` 不利于表达业务含义。
- 删除和级联更难控制。

### 8.5 cascade 的使用

| Cascade 类型 | 建议 |
|---|---|
| `CascadeType.ALL` | 只在聚合内部使用，例如 `Order -> OrderItem` |
| `CascadeType.REMOVE` | 非常谨慎，防止误删共享对象 |
| `CascadeType.MERGE` | 谨慎使用，容易把游离对象状态覆盖进数据库 |
| 跨聚合 cascade | 禁止或严格评审 |

原则：

```text
只有聚合根真正拥有生命周期的子对象，才可以 cascade。
```

### 8.6 orphanRemoval

适合：

```java
@OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
private List<OrderItem> items;
```

含义：

```text
OrderItem 离开 Order.items 集合后，就应该从数据库删除。
```

不适合：

- 子对象可能被其他聚合共享。
- 子对象只是解除关联，不应该删除。

---

## 9. Repository 与查询规范

### 9.1 Repository 应按聚合根设计

推荐：

```java
interface OrderRepository {
    Optional<Order> findById(Long id);
    Order save(Order order);
}
```

不推荐：

```java
interface OrderItemRepository {
    OrderItem save(OrderItem item);
}
```

如果 `OrderItem` 是 `Order` 聚合内部对象，外部不应该绕过 `Order` 直接保存 `OrderItem`。

### 9.2 Spring Data 方法名查询只适合简单条件

适合：

```java
Optional<Order> findByOrderNo(String orderNo);
List<Order> findByCustomerId(Long customerId);
```

不适合：

```java
List<Order> findByCustomerIdAndStatusAndCreatedAtBetweenAndTotalAmountGreaterThanAndOrderNoLike(...);
```

复杂查询建议使用：

- `@Query`
- Specification
- Querydsl
- MyBatis / JDBC Template / 原生 SQL 查询模型
- CQRS 查询侧单独建查询对象

### 9.3 查询和命令分离

命令侧：

```text
修改业务状态，加载聚合根，执行领域方法，事务提交。
```

查询侧：

```text
只读展示，不一定要加载完整聚合，可以直接查 DTO / Projection。
```

例如：

```java
public record OrderListView(
        Long id,
        String orderNo,
        String status,
        BigDecimal totalAmount
) {}
```

```java
@Query("""
        select new com.example.order.application.query.OrderListView(
            o.id, o.orderNo, cast(o.status as string), o.totalAmount.amount
        )
        from Order o
        where o.customerId = :customerId
        """)
List<OrderListView> findOrderListByCustomerId(Long customerId);
```

### 9.4 分页查询必须有稳定排序

不推荐：

```java
Page<Order> findByStatus(OrderStatus status, Pageable pageable);
```

如果没有稳定排序，翻页可能重复或遗漏。

推荐调用时指定排序：

```java
PageRequest.of(0, 20, Sort.by(Sort.Direction.DESC, "createdAt").and(Sort.by("id")))
```

### 9.5 不要在循环里查数据库

不推荐：

```java
for (Long orderId : orderIds) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    result.add(order);
}
```

推荐：

```java
List<Order> orders = orderRepository.findAllById(orderIds);
```

或写批量查询。

---

## 10. 事务边界规范

### 10.1 `@Transactional` 放在哪里

推荐：放在 Application Service 或业务 Service 的 public 方法上。

```java
@Service
public class OrderApplicationService {

    @Transactional
    public void submitOrder(Long orderId) {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.submit();
    }
}
```

不推荐：

- Controller 层直接加事务。
- Entity 方法加事务。
- private 方法加事务。
- 同类内部方法调用依赖事务生效。

### 10.2 一个用例一个事务

推荐：

```text
提交订单 = 一个事务
取消订单 = 一个事务
支付回调处理 = 一个事务
```

不要把多个独立用例强行塞进一个大事务。

### 10.3 查询事务

只读查询建议：

```java
@Transactional(readOnly = true)
public OrderDetailView getOrderDetail(Long orderId) {
    ...
}
```

作用：

- 表达意图。
- 帮助框架和数据库做优化。
- 避免误修改。

### 10.4 事务中不要做远程调用

不推荐：

```java
@Transactional
public void submitOrder(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    order.submit();
    paymentClient.freezeAmount(orderId); // 远程调用
}
```

原因：

- 远程调用慢，事务持有数据库连接和锁。
- 远程调用失败时本地事务如何回滚不清楚。
- 本地事务提交后远程系统可能已经失败。

推荐：

- 本地事务只修改本地状态。
- 发布领域事件或 outbox 事件。
- 异步调用外部系统。
- 需要强一致时使用明确的业务补偿或 Saga。

### 10.5 异常与回滚

默认情况下，Spring 对运行时异常回滚。新人应遵守：

- 业务失败优先抛运行时业务异常。
- 不要吞异常后继续提交事务。
- 不要随意 `catch Exception` 只打印日志。

不推荐：

```java
@Transactional
public void submitOrder(Long orderId) {
    try {
        Order order = orderRepository.findById(orderId).orElseThrow();
        order.submit();
    } catch (Exception e) {
        log.error("提交失败", e);
    }
}
```

这可能导致事务正常提交。

---

## 11. 持久化上下文与脏检查

### 11.1 同一个事务内 Entity 是被托管的

```java
@Transactional
public void changeStatus(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    order.submit();
    // 不调用 save 也会更新，因为 order 是 managed entity。
}
```

### 11.2 新对象需要 save

```java
@Transactional
public Long createOrder(CreateOrderCommand command) {
    Order order = Order.create(...);
    orderRepository.save(order);
    return order.id();
}
```

### 11.3 游离对象不要乱 merge

不推荐前端传 Entity 回来后直接保存：

```java
@PostMapping
public void update(@RequestBody Order order) {
    orderRepository.save(order);
}
```

风险：

- 前端缺少字段导致覆盖数据库。
- 绕过领域方法。
- 绕过权限和状态校验。
- 破坏聚合一致性。

推荐：

```java
@Transactional
public void changeAddress(ChangeOrderAddressCommand command) {
    Order order = orderRepository.findById(command.orderId()).orElseThrow();
    order.changeAddress(command.address());
}
```

---

## 12. N+1 与加载策略

### 12.1 什么是 N+1

示例：

```java
List<Order> orders = orderRepository.findByCustomerId(customerId);
for (Order order : orders) {
    order.items().size();
}
```

可能产生：

```text
1 条 SQL 查询订单列表
N 条 SQL 分别查询每个订单的明细
```

### 12.2 解决方式

#### 方式一：`@EntityGraph`

```java
@EntityGraph(attributePaths = "items")
List<Order> findByCustomerId(Long customerId);
```

#### 方式二：`join fetch`

```java
@Query("""
        select distinct o
        from Order o
        left join fetch o.items
        where o.id = :id
        """)
Optional<Order> findDetailById(Long id);
```

#### 方式三：DTO 查询

```java
@Query("""
        select new com.example.order.OrderItemView(
            i.productId, i.productName, i.quantity
        )
        from OrderItem i
        where i.order.id = :orderId
        """)
List<OrderItemView> findItemViews(Long orderId);
```

### 12.3 不要用 EAGER 掩盖 N+1

`EAGER` 不是解决 N+1 的标准办法。它会让查询不可控，尤其是列表场景。

---

## 13. 批量操作与性能规范

### 13.1 批量插入

如果需要批量插入大量数据：

- 使用 JDBC batch。
- 控制事务大小。
- 分批 flush / clear。
- 避免一次加载几十万对象进持久化上下文。

示例：

```java
@Transactional
public void importOrders(List<Order> orders) {
    int batchSize = 1000;
    for (int i = 0; i < orders.size(); i++) {
        orderRepository.save(orders.get(i));
        if (i % batchSize == 0) {
            entityManager.flush();
            entityManager.clear();
        }
    }
}
```

### 13.2 批量 update/delete 会绕过持久化上下文

```java
@Modifying
@Query("update Order o set o.status = :status where o.customerId = :customerId")
int updateStatusByCustomerId(Long customerId, OrderStatus status);
```

注意：

- 这种 JPQL bulk update 不会逐个触发 Entity 业务方法。
- 不会自动维护当前 persistence context 中已有对象状态。
- 执行后必要时需要 clear persistence context。
- 不适合需要领域规则校验的核心状态变更。

### 13.3 慢 SQL 排查

新人必须学会看：

- Hibernate 打印的 SQL。
- SQL 参数。
- 执行计划。
- 索引是否命中。
- 返回行数是否过大。
- 是否发生 N+1。
- 是否在事务里做了长时间循环。

---

## 14. 缓存规范

### 14.1 一级缓存

一级缓存是 JPA Persistence Context 自带的，同一个事务内有效。

```java
@Transactional
public void demo(Long id) {
    Order a = orderRepository.findById(id).orElseThrow();
    Order b = orderRepository.findById(id).orElseThrow();
    // a 和 b 通常是同一个托管对象实例
}
```

### 14.2 二级缓存

二级缓存跨事务，复杂度更高。新人不要自行开启。

适合：

- 字典。
- 变化极少的配置。
- 读多写少的数据。

不适合：

- 订单状态。
- 库存。
- 账户余额。
- 设备实时状态。

### 14.3 Spring Cache

适合缓存查询结果，但必须设计失效策略。

```java
@Cacheable(cacheNames = "product", key = "#productId")
public ProductView getProduct(Long productId) {
    ...
}
```

注意：

- 修改数据后必须清理缓存。
- 缓存不能代替事务一致性。
- 不要缓存 JPA Entity，优先缓存 DTO。

---

## 15. 数据库迁移规范

### 15.1 禁止生产环境自动建表

禁止：

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: update
```

生产推荐：

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
```

表结构通过迁移脚本管理：

```text
db/migration
  ├─ V1__create_order_tables.sql
  ├─ V2__add_order_payment_status.sql
  └─ V3__create_order_event_outbox.sql
```

### 15.2 脚本规范

- 每次表结构变更必须有脚本。
- 脚本文件名必须表达意图。
- 不允许修改已经发布到共享环境的历史脚本。
- 复杂数据修复脚本必须有回滚方案或验证 SQL。
- 索引变更必须说明原因。

---

## 16. 校验与业务规则

### 16.1 Bean Validation 负责输入格式校验

```java
public record CreateOrderCommand(
        @NotNull Long customerId,
        @NotEmpty List<CreateOrderItemCommand> items
) {}
```

适合校验：

- 必填。
- 字符长度。
- 数字范围。
- 格式。

### 16.2 领域模型负责业务规则

```java
public void submit() {
    if (items.isEmpty()) {
        throw new IllegalStateException("订单明细不能为空");
    }
    if (status != OrderStatus.DRAFT) {
        throw new IllegalStateException("只有草稿订单可以提交");
    }
    this.status = OrderStatus.SUBMITTED;
}
```

适合校验：

- 状态流转。
- 聚合内部一致性。
- 金额计算。
- 子对象数量规则。
- 业务约束。

### 16.3 数据库约束兜底

数据库必须保留底线约束：

- `NOT NULL`
- `UNIQUE`
- `CHECK`
- 外键约束，按企业数据库规范决定
- 必要索引

不要只依赖 Java 代码保证数据正确性。

---

## 17. 跨模块更新与双向更新

企业系统经常出现：一个业务动作要同时更新多个模块。例如：

```text
提交订单
  ├─ 更新订单状态
  ├─ 冻结库存
  ├─ 创建支付单
  ├─ 写审计日志
  └─ 通知外部系统
```

### 17.1 不推荐做法

不推荐在一个 Entity 里直接操作多个模块：

```java
public class Order {
    public void submit(InventoryRepository inventoryRepository,
                       PaymentRepository paymentRepository) {
        this.status = SUBMITTED;
        inventoryRepository.freeze(...);
        paymentRepository.create(...);
    }
}
```

问题：

- Entity 依赖 Repository。
- 聚合边界混乱。
- 事务难控制。
- 测试困难。

### 17.2 推荐做法一：Application Service 编排

适合强一致、同库、同服务内的简单跨聚合操作：

```java
@Transactional
public void submitOrder(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    Inventory inventory = inventoryRepository.findByProductIds(order.productIds());

    order.submit();
    inventory.freeze(order.toFreezeRequest());

    auditLogRepository.save(AuditLog.orderSubmitted(order.id()));
}
```

注意：

- Application Service 编排。
- 领域规则仍放在各自聚合内。
- 不要让一个聚合直接修改另一个聚合内部状态。

### 17.3 推荐做法二：领域事件

适合提交后触发后续动作：

```java
public record OrderSubmittedEvent(Long orderId, String orderNo) {}
```

```java
@Transactional
public void submitOrder(Long orderId) {
    Order order = orderRepository.findById(orderId).orElseThrow();
    order.submit();
    domainEventPublisher.publish(new OrderSubmittedEvent(order.id(), order.orderNo()));
}
```

事件处理：

```java
@Component
public class OrderSubmittedEventHandler {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handle(OrderSubmittedEvent event) {
        // 事务提交后处理，例如发消息、通知外部系统
    }
}
```

### 17.4 推荐做法三：Outbox

适合跨系统、跨服务、消息可靠性要求高的场景：

```text
本地事务：
  1. 更新订单状态
  2. 写 outbox_event 表

异步任务：
  3. 扫描 outbox_event
  4. 发送 MQ
  5. 标记已发送
```

优点：

- 本地事务和事件写入一致。
- 外部系统失败可重试。
- 不把远程调用放在数据库事务里。

### 17.5 跨模块一致性判断

| 场景 | 建议 |
|---|---|
| 同一个聚合内部 | 聚合根方法内完成 |
| 同服务同库、需要强一致 | Application Service 一个事务编排 |
| 跨服务、跨库、外部接口 | 领域事件 + Outbox + 重试 / 补偿 |
| 长流程审批 / 状态机 | 状态机或 Saga |
| 报表 / 统计 | 异步同步或查询侧模型 |

---

## 18. 合一模式与分离模式下的测试

### 18.1 单元测试

合一模式和分离模式都要做领域模型单元测试。

```java
class OrderTest {

    @Test
    void should_submit_order_when_has_items() {
        Order order = Order.create("O-001", 1001L);
        order.addItem(OrderItem.create(1L, "键盘", 1, Money.of(new BigDecimal("100.00"), "CNY")));

        order.submit();

        assertThat(order.status()).isEqualTo(OrderStatus.SUBMITTED);
    }

    @Test
    void should_not_submit_empty_order() {
        Order order = Order.create("O-001", 1001L);

        assertThatThrownBy(order::submit)
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("订单明细不能为空");
    }
}
```

### 18.2 Repository 测试

```java
@DataJpaTest
class JpaOrderRepositoryTest {

    @Autowired
    private JpaOrderRepository orderRepository;

    @Test
    void should_save_and_load_order() {
        Order order = Order.create("O-001", 1001L);
        order.addItem(OrderItem.create(1L, "键盘", 1, Money.of(new BigDecimal("100.00"), "CNY")));

        Order saved = orderRepository.saveAndFlush(order);

        Optional<Order> loaded = orderRepository.findById(saved.id());

        assertThat(loaded).isPresent();
        assertThat(loaded.get().items()).hasSize(1);
    }
}
```

### 18.3 测试原则

| 测试类型 | 重点 |
|---|---|
| 领域单元测试 | 状态流转、业务规则、金额计算 |
| Repository 测试 | 映射、级联、查询、锁、约束 |
| Application Service 测试 | 事务、用例编排、异常回滚 |
| Controller 测试 | 参数校验、HTTP 状态码、返回结构 |
| 集成测试 | 真实数据库行为、迁移脚本、复杂 SQL |

---

## 19. 新人常见错误清单

### 19.1 Entity 写成贫血对象

错误：

```java
order.setStatus(OrderStatus.SUBMITTED);
order.setTotalAmount(amount);
```

正确：

```java
order.submit();
order.addItem(item);
```

### 19.2 Controller 直接操作 Repository

错误：

```java
@RestController
class OrderController {
    @Autowired OrderRepository orderRepository;
}
```

正确：

```java
@RestController
class OrderController {
    private final OrderApplicationService orderApplicationService;
}
```

### 19.3 Repository 返回 Entity 给前端

错误：

```java
@GetMapping("/{id}")
public Order get(@PathVariable Long id) {
    return orderRepository.findById(id).orElseThrow();
}
```

正确：

```java
@GetMapping("/{id}")
public OrderDetailResponse get(@PathVariable Long id) {
    return orderQueryService.getDetail(id);
}
```

### 19.4 随意使用 `EAGER`

错误：

```java
@OneToMany(fetch = FetchType.EAGER)
private List<OrderItem> items;
```

正确：

```java
@OneToMany(fetch = FetchType.LAZY)
private List<OrderItem> items;
```

查询时用 `@EntityGraph` 或 `join fetch`。

### 19.5 在事务外访问懒加载字段

错误：

```java
Order order = orderService.findOrder(id);
return order.items(); // 事务外触发懒加载
```

正确：

```java
@Transactional(readOnly = true)
public OrderDetailView getDetail(Long id) {
    Order order = orderRepository.findDetailById(id).orElseThrow();
    return mapper.toDetailView(order);
}
```

### 19.6 用 `save` 替代业务方法

错误：

```java
Order order = new Order();
order.setId(id);
order.setStatus(SUBMITTED);
orderRepository.save(order);
```

正确：

```java
Order order = orderRepository.findById(id).orElseThrow();
order.submit();
```

### 19.7 忽略数据库约束

错误：只在 Java 里校验唯一性。

正确：

- Java 做友好校验。
- 数据库加唯一索引兜底。
- 捕获唯一约束异常，转换为业务错误。

---

## 20. 代码审查清单

### 20.1 DDD 检查

- [ ] 是否明确了聚合根？
- [ ] 外部是否只通过聚合根修改聚合内部对象？
- [ ] 业务规则是否放在领域模型中，而不是散落在 Controller / Repository？
- [ ] 是否存在跨聚合直接互相修改？
- [ ] 是否需要领域事件或 Outbox？
- [ ] 是否把查询模型和命令模型混在一起？

### 20.2 JPA 映射检查

- [ ] Entity 是否有 `protected` 无参构造？
- [ ] 是否避免了无意义 public setter？
- [ ] 枚举是否使用 `EnumType.STRING`？
- [ ] 核心表是否有 `@Version`？
- [ ] 关联是否默认 LAZY？
- [ ] cascade 是否只用于聚合内部？
- [ ] 是否避免了不必要的双向关联？
- [ ] 是否避免了 `@ManyToMany`？
- [ ] 是否避免了 Lombok `@Data`？

### 20.3 事务检查

- [ ] `@Transactional` 是否放在应用服务 public 方法上？
- [ ] 查询是否使用 `readOnly = true`？
- [ ] 是否在事务里做远程调用？
- [ ] 是否存在异常被吞掉导致事务提交？
- [ ] 是否存在同类内部方法调用导致事务不生效？

### 20.4 性能检查

- [ ] 是否存在 N+1？
- [ ] 列表查询是否分页？
- [ ] 分页是否有稳定排序？
- [ ] 是否在循环里查询数据库？
- [ ] 是否一次加载过多数据？
- [ ] 是否使用了必要索引？
- [ ] 是否检查了慢 SQL 执行计划？

### 20.5 接口检查

- [ ] Controller 是否只处理 HTTP 适配？
- [ ] 请求对象是否使用 Bean Validation？
- [ ] 是否避免直接返回 Entity？
- [ ] 是否定义统一错误响应？
- [ ] 是否避免将内部字段暴露给前端？

---

## 21. 新人学习路线

### 第 1 阶段：基础概念

目标：理解 JPA 运行机制。

学习内容：

- Entity / Table / Column / Id。
- Repository 基本用法。
- Transaction 基本用法。
- Persistence Context。
- Dirty Checking。
- Lazy Loading。

练习：

1. 新建一个 `Product` 模块。
2. 实现新增、修改、查询。
3. 打印 SQL，观察 save、find、dirty checking。
4. 关闭事务后访问懒加载字段，理解异常原因。

### 第 2 阶段：合一模式

目标：掌握聚合根 + JPA Entity 合一写法。

练习：

1. 实现 `Order` + `OrderItem`。
2. 只允许通过 `Order.addItem()` 添加明细。
3. 实现 `Order.submit()` 状态流转。
4. 编写单元测试。
5. 编写 Repository 测试。

### 第 3 阶段：分离模式

目标：掌握纯领域模型 + JPA Entity + Mapper。

练习：

1. 将合一模式的订单改造成分离模式。
2. 领域模型移除所有 JPA 注解。
3. 增加 `OrderJpaEntity` 和 Mapper。
4. 增加 `OrderPersistenceAdapter`。
5. 对比代码量和隔离效果。

### 第 4 阶段：性能与事务

目标：识别常见生产问题。

练习：

1. 构造 N+1 查询。
2. 用 `@EntityGraph` 修复。
3. 写一个批量导入，观察 persistence context 内存变化。
4. 写一个乐观锁冲突测试。
5. 模拟事务中远程调用超时，观察连接池占用。

### 第 5 阶段：综合项目

目标：能独立完成一个小型业务模块。

建议题目：

```text
采购申请模块
  - 创建采购申请
  - 添加申请明细
  - 提交审批
  - 审批通过
  - 审批驳回
  - 查询申请列表
  - 查询申请详情
```

要求：

- 使用合一模式实现一版。
- 使用分离模式实现核心聚合一版。
- 写迁移脚本。
- 写单元测试。
- 写 Repository 测试。
- 写接口测试。
- 说明为什么选择该模式。

---

## 22. 推荐项目模板

### 22.1 简单模块模板：合一模式

```text
module
  ├─ interfaces
  │   ├─ XxxController.java
  │   ├─ XxxRequest.java
  │   └─ XxxResponse.java
  ├─ application
  │   ├─ XxxApplicationService.java
  │   ├─ command
  │   └─ query
  ├─ domain
  │   ├─ Xxx.java
  │   ├─ XxxStatus.java
  │   └─ XxxRepository.java
  └─ infrastructure
      └─ JpaXxxRepository.java
```

### 22.2 核心模块模板：分离模式

```text
module
  ├─ interfaces
  ├─ application
  ├─ domain
  │   ├─ model
  │   ├─ repository
  │   ├─ service
  │   └─ event
  └─ infrastructure
      ├─ persistence
      │   ├─ XxxJpaEntity.java
      │   ├─ SpringDataXxxRepository.java
      │   ├─ XxxPersistenceAdapter.java
      │   └─ XxxPersistenceMapper.java
      ├─ messaging
      └─ client
```

---

## 23. 合一模式到分离模式的演进

项目初期可以先用合一模式，但要避免把自己锁死。

### 23.1 预留边界

即使使用合一模式，也建议：

- Controller 不直接访问 JPA Repository。
- Application Service 面向领域 Repository。
- 不在 Entity 上暴露 setter。
- 不把 Entity 直接返回给前端。
- 查询侧可以使用 DTO。
- 跨模块调用通过应用服务或事件，不要 Entity 互相调用 Repository。

这样后续迁移到分离模式时，影响范围较小。

### 23.2 何时应该切换到分离模式

出现以下情况时，应评估分离模式：

- Entity 上的 JPA 注解越来越复杂，已经影响业务阅读。
- 一个领域对象被迫拆成多个奇怪字段来适配表结构。
- 表结构有历史包袱，字段命名和业务语言严重不一致。
- 查询性能优化需要大量专用 SQL，影响领域模型纯度。
- 同一个表服务多个业务概念。
- 一个业务动作跨多个上下文，防腐层需求明显。

---

## 24. 生产实践建议

### 24.1 默认配置建议

```yaml
spring:
  jpa:
    open-in-view: false
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        format_sql: false
        jdbc:
          batch_size: 50
        order_inserts: true
        order_updates: true
```

生产环境不要长期开启参数 trace 日志。

### 24.2 日志建议

开发环境可以开启：

```yaml
logging:
  level:
    org.hibernate.SQL: debug
    org.hibernate.orm.jdbc.bind: trace
```

生产环境应通过慢 SQL、APM、数据库审计、采样日志排查。

### 24.3 数据库连接池建议

- 连接池大小要结合数据库承载能力。
- 事务时间越长，连接占用越久。
- 虚拟线程不等于数据库连接无限。
- 慢 SQL 会拖垮连接池。

### 24.4 统一异常处理

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(new ErrorResponse("BAD_REQUEST", ex.getMessage()));
    }

    @ExceptionHandler(IllegalStateException.class)
    public ResponseEntity<ErrorResponse> handleIllegalState(IllegalStateException ex) {
        return ResponseEntity.badRequest().body(new ErrorResponse("BUSINESS_ERROR", ex.getMessage()));
    }

    public record ErrorResponse(String code, String message) {}
}
```

---

## 25. 最终建议

### 25.1 对新人

先记住以下规则：

1. 不要把 Entity 当 DTO。
2. 不要把 Repository 当 SQL 工具箱。
3. 不要让 Controller 写业务规则。
4. 不要随意开放 setter。
5. 不要用 EAGER 解决懒加载问题。
6. 不要在事务里做远程调用。
7. 不要忽略数据库约束和迁移脚本。
8. 不要只看代码能跑，要看 SQL 是否合理。
9. 不要让跨模块更新污染聚合边界。
10. 不确定时，先画出聚合边界和事务边界。

### 25.2 对项目负责人

建议制定项目级标准：

- 哪些模块使用合一模式。
- 哪些模块必须使用分离模式。
- Repository 命名规范。
- Entity setter 规范。
- 事务边界规范。
- 查询 DTO 规范。
- 数据库迁移规范。
- 乐观锁使用规范。
- JPA 日志和慢 SQL 排查规范。
- Code Review 清单。

### 25.3 推荐落地策略

```text
简单模块：合一模式快速交付
核心模块：分离模式保证长期演进
查询复杂：DTO / CQRS 查询模型
跨系统：领域事件 + Outbox
表结构：迁移脚本版本化
性能：SQL 可观测 + N+1 检查 + 慢 SQL 治理
```

---

## 参考资料

1. OpenJDK JDK 25 项目页：<https://openjdk.org/projects/jdk/25/>
2. Oracle JDK 25 下载与许可说明：<https://www.oracle.com/java/technologies/downloads/>
3. Spring Boot System Requirements：<https://docs.spring.io/spring-boot/system-requirements.html>
4. Spring Data JPA Reference：<https://docs.spring.io/spring-data/jpa/reference/index.html>
5. Hibernate ORM Releases / Compatibility Matrix：<https://hibernate.org/orm/releases/>
6. Hibernate ORM User Guide：<https://docs.hibernate.org/orm/7.1/userguide/html_single/>
