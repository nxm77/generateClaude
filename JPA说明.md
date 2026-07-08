# Java + Spring Boot + DDD + JPA 合一模式说明

## 1. 文档目的

本文介绍 Java + Spring Boot + DDD + JPA 的“合一模式”设计方法，重点说明：

- 什么是 JPA 与 DDD 的合一模式；
- 合一模式适合解决哪些问题；
- 在 Spring Boot 企业项目中如何落地；
- 聚合根、实体、Repository、Application Service 如何设计；
- 事务、缓存、领域事件、读写分离、跨聚合更新如何处理；
- 合一模式常见误区和推荐规范。

本文所说的“合一模式”，不是把 Controller、Service、Repository、Entity 全部混在一起，而是指：

> DDD 的领域对象，同时也是 JPA Entity；聚合根既承载业务规则，也承载 ORM 映射。

也就是说，**Domain Entity 与 JPA Entity 合一**，但接口层 DTO、应用服务、Repository、读模型仍然需要清晰分层。

---

## 2. 什么是 Java + Spring Boot + DDD + JPA 合一模式

在传统分层架构中，常见对象如下：

| 层次 | 对象 | 作用 |
|---|---|---|
| 接口层 | DTO / Request / Response | 接收和返回接口数据 |
| 领域层 | Domain Entity / Aggregate | 表达业务概念和业务规则 |
| 持久化层 | JPA Entity / PO | 映射数据库表 |

DDD + JPA 合一模式，就是把“领域层对象”和“持久化层对象”合并：

| 对象 | 是否保留 |
|---|---|
| DTO / Request / Response | 保留 |
| Domain Entity / Aggregate | 保留 |
| JPA Entity | 与 Domain Entity 合一 |
| Repository | 保留 |
| Application Service | 保留 |

整体结构可以理解为：

```text
Controller DTO
    ↓
Application Service
    ↓
DDD Aggregate Root = JPA Entity
    ↓
Spring Data JPA Repository
    ↓
Database
```

Jakarta Persistence 本身的目标就是让 Java domain model 管理关系数据库中的对象/关系映射；Spring Data JPA 又在 Jakarta Persistence 之上提供 Repository 支持，用一致的编程模型减少数据访问层样板代码。因此，合一模式本质上是利用 JPA 的 ORM 能力，让“业务对象”同时可被 ORM 持久化。

---

## 3. 合一模式解决什么问题

### 3.1 避免双模型转换过重

如果每张表有一个 JPA Entity，每个聚合又有一个 Domain Entity，那么每次保存、查询都要来回转换。

对于小型系统，这种转换尚可接受；但在企业系统中，几十个模块、几百张表之后，转换代码会非常多，容易出现以下问题：

- 转换代码重复；
- 字段遗漏；
- 领域模型和持久化模型长期不一致；
- 维护成本上升；
- 新人理解成本增加。

合一模式通过合并 Domain Entity 和 JPA Entity，减少不必要的对象映射。

---

### 3.2 避免贫血模型

很多 Spring Boot + JPA 项目最后会变成：

```text
Entity 只有字段和 getter/setter
Service 里堆满业务判断
Repository 只负责 CRUD
```

这种写法不是 DDD，更接近事务脚本。

不推荐：

```java
order.setStatus(OrderStatus.CONFIRMED);
order.setConfirmedAt(LocalDateTime.now());
orderRepository.save(order);
```

推荐：

```java
order.confirm();
orderRepository.save(order);
```

`confirm()` 方法内部负责检查订单状态、订单明细、金额、库存预留状态等业务不变量。

合一模式要求：

> 核心业务规则写在聚合根方法里，而不是散落在 Service 里。

---

## 4. 合一模式不是 Active Record

合一模式容易被误解为 Active Record，例如：

```java
order.save();
order.delete();
```

这不是推荐做法。

在 DDD + JPA 合一模式中：

```text
Entity / Aggregate Root 负责业务状态变化
Repository 负责持久化
Application Service 负责事务和用例编排
Controller 负责接口适配
```

领域对象可以有业务方法，但不应该：

- 注入 Repository；
- 调用数据库；
- 调用外部接口；
- 自己管理事务；
- 自己保存自己。

推荐职责划分如下：

| 组件 | 职责 |
|---|---|
| Controller | HTTP 入参、出参、权限入口 |
| Application Service | 一个业务用例、事务边界、调用多个聚合或外部服务 |
| Aggregate Root | 业务规则、不变量、状态变化 |
| Domain Service | 不适合放在单个实体里的领域规则 |
| Repository | 以聚合根为单位加载和保存 |
| Infrastructure | 外部系统、消息、缓存、数据库实现 |

Spring 的声明式事务通常通过代理拦截外部方法调用生效，所以事务边界应放在 Application Service 的 public 方法上，而不是依赖实体方法或同类内部调用。

---

## 5. 推荐包结构

企业项目建议按业务模块组织，而不是按技术层横向堆目录。

```text
com.company.order
 ├── interfaces
 │    ├── OrderController.java
 │    ├── PlaceOrderRequest.java
 │    └── OrderResponse.java
 │
 ├── application
 │    ├── OrderApplicationService.java
 │    ├── PlaceOrderCommand.java
 │    └── OrderQueryService.java
 │
 ├── domain
 │    ├── Order.java
 │    ├── OrderLine.java
 │    ├── OrderStatus.java
 │    ├── Money.java
 │    ├── OrderRepository.java
 │    └── event
 │         └── OrderConfirmedEvent.java
 │
 └── infrastructure
      ├── JpaOrderRepository.java
      ├── SpringDataOrderRepository.java
      └── OrderReadDao.java
```

如果团队追求简单，也可以让 `OrderRepository` 直接继承 `JpaRepository`。

但企业长期维护时，更推荐：

```text
domain.OrderRepository                   // 领域接口
infrastructure.SpringDataOrderRepository // Spring Data JPA 接口
infrastructure.JpaOrderRepository        // 适配实现
```

这样做的好处是：

> 领域层知道“我要保存订单”，但不知道 Spring Data JPA 的技术细节。

---

## 6. 聚合根 = JPA Entity 的写法

以订单为例，`Order` 是聚合根，`OrderLine` 是聚合内部实体。

```java
package com.company.order.domain;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Entity
@Table(name = "orders")
@Access(AccessType.FIELD)
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Version
    private long version;

    @Column(name = "order_no", nullable = false, unique = true, updatable = false, length = 64)
    private String orderNo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private OrderStatus status;

    @Column(name = "customer_id", nullable = false, length = 64)
    private String customerId;

    @OneToMany(
        mappedBy = "order",
        cascade = CascadeType.ALL,
        orphanRemoval = true
    )
    private List<OrderLine> lines = new ArrayList<>();

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "confirmed_at")
    private LocalDateTime confirmedAt;

    protected Order() {
        // JPA only
    }

    private Order(String orderNo, String customerId) {
        this.orderNo = Objects.requireNonNull(orderNo);
        this.customerId = Objects.requireNonNull(customerId);
        this.status = OrderStatus.DRAFT;
        this.createdAt = LocalDateTime.now();
    }

    public static Order create(String orderNo, String customerId) {
        return new Order(orderNo, customerId);
    }

    public void addLine(String productId, String productName, int quantity, BigDecimal unitPrice) {
        ensureDraft();

        if (quantity <= 0) {
            throw new IllegalArgumentException("订单数量必须大于 0");
        }

        if (unitPrice == null || unitPrice.signum() < 0) {
            throw new IllegalArgumentException("商品单价不能小于 0");
        }

        OrderLine line = new OrderLine(this, productId, productName, quantity, unitPrice);
        this.lines.add(line);
    }

    public void changeQuantity(String productId, int quantity) {
        ensureDraft();

        OrderLine line = this.lines.stream()
            .filter(item -> item.getProductId().equals(productId))
            .findFirst()
            .orElseThrow(() -> new IllegalArgumentException("订单明细不存在: " + productId));

        line.changeQuantity(quantity);
    }

    public void removeLine(String productId) {
        ensureDraft();

        boolean removed = this.lines.removeIf(line -> line.getProductId().equals(productId));

        if (!removed) {
            throw new IllegalArgumentException("订单明细不存在: " + productId);
        }
    }

    public void confirm() {
        ensureDraft();

        if (this.lines.isEmpty()) {
            throw new IllegalStateException("空订单不能确认");
        }

        if (totalAmount().signum() <= 0) {
            throw new IllegalStateException("订单金额必须大于 0");
        }

        this.status = OrderStatus.CONFIRMED;
        this.confirmedAt = LocalDateTime.now();
    }

    public void cancel() {
        if (this.status == OrderStatus.CONFIRMED) {
            throw new IllegalStateException("已确认订单不能直接取消，需要走取消流程");
        }

        this.status = OrderStatus.CANCELLED;
    }

    public BigDecimal totalAmount() {
        return this.lines.stream()
            .map(OrderLine::subtotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public List<OrderLine> getLines() {
        return Collections.unmodifiableList(lines);
    }

    public Long getId() {
        return id;
    }

    public String getOrderNo() {
        return orderNo;
    }

    public OrderStatus getStatus() {
        return status;
    }

    public String getCustomerId() {
        return customerId;
    }

    private void ensureDraft() {
        if (this.status != OrderStatus.DRAFT) {
            throw new IllegalStateException("只有草稿订单可以修改");
        }
    }
}
```

关键点：

1. 没有 public setter，外部不能随意修改状态。
2. 业务方法表达业务动作，例如 `confirm()`、`cancel()`、`addLine()`。
3. 状态检查在聚合根内部，不散落在 Service 里。
4. 集合只暴露只读视图，避免外部绕过聚合根直接增删。
5. 使用 `@Version` 做乐观锁，应对并发修改。

---

## 7. 聚合内部实体写法

```java
package com.company.order.domain;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.Objects;

@Entity
@Table(name = "order_lines")
@Access(AccessType.FIELD)
public class OrderLine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "product_id", nullable = false, length = 64)
    private String productId;

    @Column(name = "product_name", nullable = false, length = 128)
    private String productName;

    @Column(nullable = false)
    private int quantity;

    @Column(name = "unit_price", nullable = false, precision = 18, scale = 2)
    private BigDecimal unitPrice;

    protected OrderLine() {
        // JPA only
    }

    OrderLine(Order order, String productId, String productName, int quantity, BigDecimal unitPrice) {
        this.order = Objects.requireNonNull(order);
        this.productId = Objects.requireNonNull(productId);
        this.productName = Objects.requireNonNull(productName);
        this.unitPrice = Objects.requireNonNull(unitPrice);
        changeQuantity(quantity);
    }

    public void changeQuantity(int quantity) {
        if (quantity <= 0) {
            throw new IllegalArgumentException("订单数量必须大于 0");
        }
        this.quantity = quantity;
    }

    public BigDecimal subtotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }

    public String getProductId() {
        return productId;
    }
}
```

建议对关联关系显式写 `fetch = FetchType.LAZY`，尤其是 `@ManyToOne` 和 `@OneToOne`。

原因是：

- 避免意外加载大对象图；
- 避免查询性能不可控；
- 避免接口序列化时触发额外 SQL；
- 避免跨聚合边界被 ORM 关联关系冲淡。

---

## 8. Repository 设计

### 8.1 简化版：直接用 Spring Data JPA

适合中小项目，或团队更看重开发效率。

```java
package com.company.order.domain;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByOrderNo(String orderNo);

    boolean existsByOrderNo(String orderNo);
}
```

这种方式简单，但领域层会依赖 Spring Data JPA。

---

### 8.2 企业推荐版：领域接口 + 基础设施适配

领域层：

```java
package com.company.order.domain;

import java.util.Optional;

public interface OrderRepository {

    Order save(Order order);

    Optional<Order> findByOrderNo(String orderNo);

    boolean existsByOrderNo(String orderNo);
}
```

基础设施层：

```java
package com.company.order.infrastructure;

import com.company.order.domain.Order;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

interface SpringDataOrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByOrderNo(String orderNo);

    boolean existsByOrderNo(String orderNo);
}
```

```java
package com.company.order.infrastructure;

import com.company.order.domain.Order;
import com.company.order.domain.OrderRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public class JpaOrderRepository implements OrderRepository {

    private final SpringDataOrderRepository delegate;

    public JpaOrderRepository(SpringDataOrderRepository delegate) {
        this.delegate = delegate;
    }

    @Override
    public Order save(Order order) {
        return delegate.save(order);
    }

    @Override
    public Optional<Order> findByOrderNo(String orderNo) {
        return delegate.findByOrderNo(orderNo);
    }

    @Override
    public boolean existsByOrderNo(String orderNo) {
        return delegate.existsByOrderNo(orderNo);
    }
}
```

企业项目更推荐这种方式，因为它可以保持领域层相对纯净，避免领域层直接依赖 Spring Data JPA 的具体接口。

---

## 9. Application Service 写法

Application Service 是用例入口，不是业务规则堆积地。

```java
package com.company.order.application;

import com.company.order.domain.Order;
import com.company.order.domain.OrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class OrderApplicationService {

    private final OrderRepository orderRepository;

    public OrderApplicationService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    @Transactional
    public String placeOrder(PlaceOrderCommand command) {
        if (orderRepository.existsByOrderNo(command.orderNo())) {
            throw new IllegalArgumentException("订单号已存在: " + command.orderNo());
        }

        Order order = Order.create(command.orderNo(), command.customerId());

        for (PlaceOrderCommand.Line line : command.lines()) {
            order.addLine(
                line.productId(),
                line.productName(),
                line.quantity(),
                line.unitPrice()
            );
        }

        order.confirm();

        orderRepository.save(order);

        return order.getOrderNo();
    }

    @Transactional
    public void changeQuantity(String orderNo, String productId, int quantity) {
        Order order = orderRepository.findByOrderNo(orderNo)
            .orElseThrow(() -> new IllegalArgumentException("订单不存在: " + orderNo));

        order.changeQuantity(productId, quantity);
    }
}
```

第二个方法没有显式 `save(order)`，这是因为在 JPA 管理态下，只要实体在事务内被加载并修改，事务提交时会由持久化上下文同步到数据库。

不过企业编码规范里，为了可读性和统一性，可以规定：

> 新增必须 save，修改可不 save，但建议在应用服务结尾显式表达意图。

例如：

```java
order.changeQuantity(productId, quantity);
// loaded aggregate is managed by JPA; no explicit save required
```

---

## 10. DTO 和 Entity 不要混用

合一模式只合并 Domain Entity 和 JPA Entity，不代表接口层直接暴露 Entity。

不推荐：

```java
@GetMapping("/{orderNo}")
public Order getOrder(@PathVariable String orderNo) {
    return orderRepository.findByOrderNo(orderNo).orElseThrow();
}
```

推荐：

```java
public record OrderResponse(
    String orderNo,
    String status,
    String customerId,
    BigDecimal totalAmount
) {
    public static OrderResponse from(Order order) {
        return new OrderResponse(
            order.getOrderNo(),
            order.getStatus().name(),
            order.getCustomerId(),
            order.totalAmount()
        );
    }
}
```

原因：

- Entity 里有 ORM 代理；
- Entity 里可能有懒加载集合；
- Entity 里有内部状态和业务方法；
- 直接返回容易引发懒加载异常；
- 容易造成 JSON 循环序列化；
- 容易泄露敏感字段；
- 接口契约不可控。

Controller 必须返回 DTO。

---

## 11. 读写分离：写模型用聚合，查询可以用 Projection

DDD 的聚合适合处理写操作，也就是状态变化。

但查询经常需要：

- 跨表；
- 分页；
- 筛选；
- 排序；
- 统计；
- 报表；
- 多维度组合查询。

如果所有查询都强行加载完整聚合，会导致性能很差。

推荐：

```text
写操作：Application Service -> Repository -> Aggregate
读操作：QueryService -> Projection / DTO / Native SQL / JPQL
```

例如：

```java
public interface OrderSummaryView {
    String getOrderNo();
    String getStatus();
    BigDecimal getTotalAmount();
}
```

```java
public interface OrderReadRepository {

    @Query("""
        select o.orderNo as orderNo,
               o.status as status
        from Order o
        where o.customerId = :customerId
    """)
    List<OrderSummaryView> findSummariesByCustomerId(String customerId);
}
```

复杂报表、列表页、统计页，不建议通过聚合根一层层导航出来。

原因是：

> 聚合模型主要服务于业务一致性和状态变更，不是为了满足所有查询场景。

---

## 12. 聚合设计原则

### 12.1 聚合根是唯一入口

外部只能通过 `Order` 修改 `OrderLine`。

不推荐：

```java
orderLineRepository.save(line);
```

推荐：

```java
order.changeQuantity(productId, quantity);
```

也就是说：

> `OrderLine` 不应该被外部独立保存，它的生命周期由 `Order` 管理。

---

### 12.2 聚合之间不要直接大对象关联

不推荐：

```java
@ManyToOne
private Customer customer;
```

更推荐：

```java
@Column(name = "customer_id", nullable = false)
private String customerId;
```

原因是 `Order` 和 `Customer` 通常是两个聚合。订单修改时，不应该顺便加载和修改客户聚合。

跨聚合引用优先用 ID，而不是对象引用。

---

### 12.3 一个事务尽量只强一致修改一个聚合

理想情况下：

```text
一个事务 = 一个用例 = 一个聚合的状态变化
```

如果一个用例必须修改多个聚合，要区分处理。

| 场景 | 处理方式 |
|---|---|
| 同一个聚合内的父子对象 | 聚合根方法内直接修改 |
| 同一个限界上下文内，必须强一致 | Application Service 编排多个 Repository，但要控制复杂度 |
| 跨模块 / 跨限界上下文 | 领域事件 + 最终一致性 |

如果跨模块经常双向更新，通常说明聚合边界或模块边界设计有问题。

---

## 13. 领域事件

领域事件适合表达：

> 领域里已经发生了一件事。

例如：

```java
public record OrderConfirmedEvent(
    String orderNo,
    String customerId,
    BigDecimal totalAmount
) {
}
```

如果使用 Spring Data 的 `@DomainEvents` 或 `AbstractAggregateRoot`，聚合根可以注册领域事件。

示例：

```java
@Entity
@Table(name = "orders")
public class Order extends AbstractAggregateRoot<Order> {

    // fields omitted

    public void confirm() {
        ensureDraft();

        if (this.lines.isEmpty()) {
            throw new IllegalStateException("空订单不能确认");
        }

        this.status = OrderStatus.CONFIRMED;
        this.confirmedAt = LocalDateTime.now();

        registerEvent(new OrderConfirmedEvent(
            this.orderNo,
            this.customerId,
            this.totalAmount()
        ));
    }
}
```

事件监听：

```java
@Component
public class OrderEventHandler {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void on(OrderConfirmedEvent event) {
        // 发送消息、通知库存、写 outbox、触发后续流程
    }
}
```

企业项目建议：

```text
领域事件：表达业务事实
本地事务内：只修改当前聚合
事务提交后：通过事件处理器写 outbox 或发消息
跨系统一致性：走最终一致性，不要跨系统大事务
```

---

## 14. 合一模式下的事务边界

推荐规则：

```text
@Transactional 放在 Application Service
Entity 不开事务
Repository 不承载业务事务
Controller 不直接操作 Repository
```

典型写法：

```java
@Transactional
public void confirmOrder(String orderNo) {
    Order order = orderRepository.findByOrderNo(orderNo)
        .orElseThrow(() -> new IllegalArgumentException("订单不存在"));

    order.confirm();
}
```

不要这样：

```java
@Transactional
public void confirm() {
    this.status = OrderStatus.CONFIRMED;
}
```

原因是：

- Entity 不是 Spring Bean；
- 事务不会因为实体方法加注解而自然生效；
- 实体不应该掌握事务边界；
- 事务属于用例级控制，应放在 Application Service。

---

## 15. 缓存问题怎么处理

合一模式下要区分几类缓存。

---

### 15.1 JPA 一级缓存

JPA 一级缓存就是当前持久化上下文，通常跟事务绑定。

一次事务内多次加载同一个实体，一般会得到同一个托管对象实例。

这类缓存不用自己管理，但要注意：

```text
事务不要过大
不要一次加载超大对象图
批处理时定期 flush / clear
```

---

### 15.2 Hibernate 二级缓存

二级缓存要慎用。

适合低频变更、高频读取、强一致要求不高的数据，例如：

- 字典；
- 配置；
- 基础资料；
- 参数表；
- 地区编码；
- 产品分类。

不适合：

```text
订单状态
库存数量
账户余额
生产状态
高频写入业务数据
```

---

### 15.3 Spring Cache / Redis

Spring Cache / Redis 更适合缓存读模型，而不是直接缓存可变聚合根。

推荐：

```text
聚合根：以数据库事务为准
读模型：可以缓存 DTO / View / Summary
事件：聚合变化后清理或刷新缓存
```

不要优先缓存复杂聚合根，尤其不要缓存带懒加载代理和内部可变状态的 JPA Entity。

---

## 16. 合一模式常见错误

### 16.1 Entity 只有 getter/setter

这会退化为贫血模型。

不推荐：

```java
order.setStatus(CONFIRMED);
```

推荐：

```java
order.confirm();
```

---

### 16.2 Service 里写所有业务规则

不推荐：

```java
if (order.getStatus() != DRAFT) {
    throw new RuntimeException();
}
order.setStatus(CONFIRMED);
```

推荐：

```java
order.confirm();
```

Application Service 可以做用例编排，但核心不变量应该在聚合内部。

---

### 16.3 聚合之间到处 `@ManyToOne`

例如：

```text
Order -> Customer -> Account -> Organization
```

这会导致：

- 对象图越来越大；
- 加载不可控；
- 模块边界模糊；
- 查询性能不可控；
- 修改时容易误触其他聚合。

跨聚合引用建议用 ID。

---

### 16.4 接口直接返回 Entity

容易出现：

```text
懒加载异常
JSON 循环引用
敏感字段泄露
接口字段不可控
性能不可控
```

Controller 必须返回 DTO。

---

### 16.5 双向关联没有维护两边关系

如果必须使用双向关联，要通过聚合根方法维护。

推荐：

```java
public void addLine(...) {
    OrderLine line = new OrderLine(this, ...);
    this.lines.add(line);
}
```

不要让外部同时操作：

```java
line.setOrder(order);
order.getLines().add(line);
```

---

## 17. 什么时候适合合一模式

### 17.1 适合的场景

```text
业务模型和数据库模型大体一致
团队熟悉 Spring Boot + JPA
系统以 CRUD + 业务状态流转为主
希望减少 DTO/DO/PO 之间的大量转换
项目需要快速落地 DDD，但不想引入过度架构
```

---

### 17.2 不适合的场景

```text
遗留数据库结构非常混乱
一个表被多个系统/模块以不同语义复用
领域模型和存储模型差异巨大
需要事件溯源 Event Sourcing
查询远复杂于写入，强 CQRS
极致性能场景，需要手写 SQL 控制所有细节
```

如果是老系统改造，建议不要一开始全量改成合一模式，而是：

```text
新模块优先采用合一模式
旧模块先封装 Repository 和 Application Service
复杂遗留表可以保留 Persistence Entity + Domain Model 分离
逐步按限界上下文迁移
```

---

## 18. 企业落地推荐规范

建议将以下规则作为团队编码规范：

```text
1. 聚合根就是 JPA Entity，但不允许接口层直接暴露 Entity。
2. Entity 禁止 public setter，状态变化必须通过业务方法完成。
3. Application Service 是事务边界，负责用例编排，不堆核心业务规则。
4. Repository 以聚合根为单位加载和保存，不直接保存聚合内部子对象。
5. 聚合内可以使用 @OneToMany + cascade + orphanRemoval。
6. 聚合之间优先用 ID 引用，不轻易建立对象关联。
7. 查询模型可以绕过聚合，使用 Projection、DTO、JPQL、SQL。
8. 跨模块更新优先用领域事件和最终一致性。
9. 并发修改使用 @Version 乐观锁，热点数据再考虑悲观锁或业务锁。
10. 缓存优先缓存读模型，不优先缓存复杂聚合根。
```

---

## 19. 推荐工程约束

### 19.1 Entity 编码约束

- 禁止 public setter；
- 必须提供 protected 无参构造方法给 JPA；
- 构造业务对象使用静态工厂方法；
- 聚合根负责维护内部集合；
- 集合字段不直接返回可修改对象；
- 使用 `@Version` 支持乐观锁；
- 枚举使用 `@Enumerated(EnumType.STRING)`；
- 金额使用 `BigDecimal`；
- 时间字段使用 `LocalDateTime`、`Instant` 或统一封装；
- 不在 Entity 中注入 Spring Bean。

---

### 19.2 Repository 编码约束

- Repository 以聚合根为单位；
- 不直接保存聚合内部 Entity；
- 不在 Repository 中写业务规则；
- 复杂查询走 QueryService / ReadRepository；
- 查询接口命名要表达业务意图，而不是数据库表意图；
- 企业项目建议领域 Repository 与 Spring Data Repository 分离。

---

### 19.3 Application Service 编码约束

- 一个 public 方法对应一个明确业务用例；
- 事务放在 Application Service；
- 可以编排多个 Repository，但不堆核心业务规则；
- 不直接操作聚合内部集合；
- 不绕过聚合根修改内部对象；
- 不返回 Entity 给接口层；
- 用 Command 表达写操作输入；
- 用 DTO / View 表达输出。

---

### 19.4 Controller 编码约束

- 只负责 HTTP 适配；
- 只接收 Request DTO；
- 只返回 Response DTO；
- 不直接调用 Repository；
- 不直接返回 Entity；
- 不写业务规则；
- 参数校验可以放在 DTO 注解和应用服务入口。

---

## 20. 与传统三层架构的关系

合一模式不是否定三层架构，而是对传统三层架构做了增强。

传统三层：

```text
Controller
Service
Repository / DAO
Entity
```

DDD + JPA 合一模式：

```text
Controller / Interfaces
Application Service
Domain Aggregate = JPA Entity
Repository
Infrastructure
```

关键差异在于：

| 对比项 | 传统三层 | DDD + JPA 合一模式 |
|---|---|---|
| Entity | 多数只有字段 | 有业务行为 |
| Service | 承载大部分业务规则 | 主要负责用例编排 |
| Repository | CRUD | 以聚合根为单位持久化 |
| 业务规则 | 分散在 Service | 内聚在聚合根 |
| 查询 | 常直接查 Entity | 可使用读模型 / Projection |
| 跨模块协作 | 直接调用和更新 | 优先事件和最终一致性 |

---

## 21. 与领域模型和持久化模型分离模式的对比

| 模式 | 优点 | 缺点 | 适合场景 |
|---|---|---|---|
| 合一模式 | 简单、转换少、落地快 | 领域模型会受到 JPA 约束 | 大多数 Spring Boot 业务系统 |
| 分离模式 | 领域模型更纯粹 | 转换代码多，开发成本高 | 复杂领域、遗留数据库、模型差异大 |
| 贫血模型 | 上手简单 | 业务规则分散，维护困难 | 简单 CRUD，不建议复杂业务使用 |
| CQRS | 查询和写入职责清晰 | 架构复杂度高 | 复杂查询、报表、事件驱动系统 |

企业项目一般可以采取混合策略：

```text
普通业务模块：DDD + JPA 合一模式
复杂遗留模块：领域模型与持久化模型分离
复杂查询模块：读模型 / Projection / SQL
跨系统流程：领域事件 + Outbox + 消息
```

---

## 22. 实施建议

### 22.1 新项目

新项目可以直接采用：

```text
按业务模块分包
聚合根 = JPA Entity
Application Service 管事务
Repository 以聚合为单位
接口层只暴露 DTO
查询独立建读模型
```

---

### 22.2 老项目改造

老项目不建议一次性大改。

推荐步骤：

```text
1. 先识别核心业务模块和核心聚合。
2. 新增需求优先按合一模式实现。
3. 对旧 Service 中的核心业务规则逐步下沉到聚合根。
4. 对复杂查询逐步抽出 QueryService。
5. 对跨模块强耦合更新逐步改为领域事件。
6. 对遗留复杂表可保留 PO 与 Domain 分离。
```

---

### 22.3 团队推广

团队推广时，建议先制定最小规范：

```text
1. Entity 禁止 public setter。
2. Controller 禁止返回 Entity。
3. Service 禁止直接 set 状态。
4. 聚合内部子对象只能通过聚合根修改。
5. 跨聚合引用优先用 ID。
6. 写操作必须经过 Application Service。
7. 查询可以走独立 ReadRepository。
```

这几条先落地，比一开始要求完整 DDD 更现实。

---

## 23. 总结

Java + Spring Boot + DDD + JPA 合一模式可以总结为：

> 用 JPA Entity 承载 DDD 聚合，用 Application Service 管事务和用例，用 Repository 管持久化，用 DTO 隔离接口，用领域方法保护业务规则。

它是工程效率和领域建模之间的折中方案。

适合大多数 Spring Boot 企业业务系统，但必须严格控制：

- 聚合边界；
- 对象关联；
- 事务边界；
- DTO 隔离；
- 查询模型；
- 缓存策略；
- 跨模块一致性。

如果控制不好，合一模式容易退化为贫血模型、事务脚本和 ORM 大对象图；如果控制得当，它可以在保持 Spring Boot/JPA 开发效率的同时，显著提升业务代码的可维护性和可读性。

---

## 24. 参考资料

- Jakarta Persistence Specification  
  https://jakarta.ee/specifications/persistence/

- Spring Data JPA Reference Documentation  
  https://docs.spring.io/spring-data/jpa/reference/

- Spring Framework Transaction Management  
  https://docs.spring.io/spring-framework/reference/data-access/transaction/

- Hibernate ORM User Guide  
  https://docs.jboss.org/hibernate/orm/

