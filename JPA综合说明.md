# JDK 25 + DDD + JPA 合一模式综合说明

## 1. 文档目的

本文用于说明在 **JDK 25、DDD、JPA、领域实体与持久化实体合一模式** 下进行企业级 Java 开发时，需要重点关注的设计原则、编码约束、跨模块双向更新处理方式、缓存一致性方案以及推荐落地规范。

本文中的“合一模式”指：

> DDD 领域实体与 JPA 持久化实体使用同一个类，一个类同时承担领域模型与 ORM 映射职责。

这种模式在企业 Java 项目中较常见，尤其适合 Spring Boot + JPA + 关系数据库架构。它的优势是开发成本低、模型直观、维护方便；缺点是 DDD 领域模型会受到 JPA 代理、反射、懒加载、构造器、事务上下文等限制。

因此，采用合一模式时要把握一个核心原则：

> 领域行为优先，JPA 约束兜底，API DTO 隔离，聚合根控制一致性，跨模块一致性交给应用服务、事件或 Saga 处理。

---

## 2. 适用场景与不适用场景

### 2.1 适用场景

合一模式适合以下场景：

1. 业务规则中等复杂。
2. 系统以关系数据库为核心。
3. 事务一致性主要发生在单体系统或同库范围内。
4. 团队希望降低模型转换成本。
5. 项目使用 Spring Data JPA、Hibernate、Jakarta Persistence 等标准技术栈。
6. 业务对象与数据库结构差异不大。
7. 希望避免过度分层带来的样板代码。

典型系统包括：

- 订单系统
- 工单系统
- 审批系统
- 设备管理系统
- 基础资料系统
- 配置管理系统
- 企业内部业务系统

### 2.2 不适用场景

以下场景不建议采用严格的合一模式，建议拆分领域模型与持久化模型：

1. 领域规则非常复杂。
2. 聚合生命周期与数据库表结构差异很大。
3. 需要事件溯源 Event Sourcing。
4. 一个聚合跨多个存储系统。
5. 强不可变领域模型要求很高。
6. 历史版本、审计、回溯要求复杂。
7. 多租户、权限、数据隔离规则极复杂。
8. 遗留数据库表结构严重反领域模型。
9. 需要同时支持多种持久化后端。
10. 模块边界要求非常严格，不能让 ORM 映射污染领域模型。

---

## 3. JDK 25 使用建议

JDK 25 可以作为现代 Java 项目的长期技术基线，但在 DDD + JPA 项目中，不应为了使用新语法而破坏 JPA 兼容性。

### 3.1 推荐使用

| 能力 | 推荐用途 |
|---|---|
| record | DTO、Command、Query、Value Object、ID 类型 |
| sealed class/interface | 领域事件、命令类型、状态表达，谨慎用于 Entity |
| virtual threads | Web 请求、IO 密集型场景，注意事务上下文和 EntityManager 不能跨线程滥用 |
| JFR | 慢 SQL、GC、锁竞争、线程阻塞、性能分析 |
| Scoped Values | 可替代部分 ThreadLocal 上下文，但不要让领域对象依赖上下文读取 |

### 3.2 谨慎使用

| 能力 | 注意事项 |
|---|---|
| record Entity | JPA Entity 不建议使用 record |
| final Entity | JPA Entity 不应声明为 final |
| final 持久化字段 | 避免影响代理、增强和脏检查 |
| preview/incubator 特性 | 不建议进入企业核心业务代码 |
| virtual threads + JPA | EntityManager / Hibernate Session 不能跨线程使用 |

### 3.3 实践建议

1. Entity 不使用 record。
2. DTO、Command、Query、Value Object 可以优先使用 record。
3. 领域对象不要依赖 ThreadLocal、ScopedValue 获取用户、租户、权限上下文。
4. 用户、租户、操作人等上下文应由应用服务层显式传入领域方法。

示例：

```java
order.approve(operatorId);
```

不要在领域对象内这样写：

```java
CurrentUser.get();
TenantContext.get();
```

---

## 4. 合一模式下的核心建模原则

### 4.1 聚合优先，表结构第二

DDD 合一模式下，Entity 不应按数据库表一比一机械生成，而应先按业务一致性边界划分聚合。

示例：

```text
订单 Order 聚合根
 ├─ OrderLine 明细
 ├─ ShippingAddress 值对象
 └─ OrderStatus 状态
```

然后再映射为：

```text
orders
order_lines
```

不要把数据库表结构直接变成贫血模型：

```java
order.setStatus(...);
orderLine.setPrice(...);
orderRepository.save(order);
```

推荐使用领域行为：

```java
order.confirm();
order.changeAddress(new ShippingAddress(...));
order.addLine(productId, quantity, price);
```

### 4.2 Entity 必须满足 JPA 约束

合一模式下，Entity 同时是领域对象和 JPA 持久化对象，因此需要遵守 JPA 的基本限制：

1. Entity 必须有 `protected` 或 `public` 无参构造器。
2. Entity 类不应声明为 `final`。
3. 持久化字段不应声明为 `final`。
4. Entity 不应使用 `record`。
5. 字段保持 `private` 或 `protected`。
6. 外部代码不直接访问字段。
7. 默认不公开 setter。
8. 用领域方法表达业务变化。

推荐写法：

```java
@Entity
@Table(name = "orders")
public class Order {

    @Id
    private OrderId id;

    @Version
    private long version;

    @Enumerated(EnumType.STRING)
    private OrderStatus status;

    @OneToMany(
        mappedBy = "order",
        cascade = CascadeType.ALL,
        orphanRemoval = true
    )
    private List<OrderLine> lines = new ArrayList<>();

    protected Order() {
        // for JPA
    }

    private Order(OrderId id) {
        this.id = id;
        this.status = OrderStatus.DRAFT;
    }

    public static Order create(OrderId id) {
        return new Order(id);
    }

    public void addLine(ProductId productId, int quantity, Money price) {
        if (status != OrderStatus.DRAFT) {
            throw new IllegalStateException("Only draft order can be changed");
        }
        lines.add(new OrderLine(this, productId, quantity, price));
    }

    public void confirm() {
        if (lines.isEmpty()) {
            throw new IllegalStateException("Order must have at least one line");
        }
        this.status = OrderStatus.CONFIRMED;
    }

    public List<OrderLine> lines() {
        return Collections.unmodifiableList(lines);
    }
}
```

### 4.3 值对象可以更现代

Entity 不建议使用 record，但值对象、DTO、Command、Query、ID 可以使用 record。

示例：

```java
@Embeddable
public record Money(
    BigDecimal amount,
    String currency
) {
    public Money {
        if (amount == null || amount.signum() < 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        if (currency == null || currency.isBlank()) {
            throw new IllegalArgumentException("Currency is required");
        }
    }
}
```

---

## 5. Repository 设计原则

### 5.1 聚合根才有 Repository

不要给聚合内部的每个 Entity 都建立 Repository。

不推荐：

```text
OrderRepository
OrderLineRepository
ShippingAddressRepository
```

推荐：

```text
OrderRepository
```

`OrderLine` 是 `Order` 聚合内部对象，不应被外部单独保存、单独修改、单独删除。

### 5.2 应用服务负责事务和调用

推荐：

```java
@Transactional
public void addOrderLine(AddOrderLineCommand command) {
    Order order = orderRepository.getById(command.orderId());
    order.addLine(command.productId(), command.quantity(), command.price());
}
```

不推荐：

```java
@Transactional
public void addOrderLine(AddOrderLineCommand command) {
    OrderLine line = new OrderLine(...);
    orderLineRepository.save(line);
}
```

判断标准：

> 如果一个对象不能脱离聚合根独立保持业务一致性，就不要给它单独 Repository。

---

## 6. 双向关联处理原则

### 6.1 同聚合内可以双向维护

例如：

```text
Order
 └── OrderLine
```

这种关系可以由聚合根统一维护。

```java
@Entity
public class Order {

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderLine> lines = new ArrayList<>();

    public void addLine(ProductId productId, int quantity, Money price) {
        OrderLine line = new OrderLine(this, productId, quantity, price);
        this.lines.add(line);
    }

    public void removeLine(OrderLineId lineId) {
        lines.removeIf(line -> line.sameId(lineId));
    }
}
```

```java
@Entity
public class OrderLine {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id")
    private Order order;

    protected OrderLine() {
    }

    OrderLine(Order order, ProductId productId, int quantity, Money price) {
        this.order = order;
        this.productId = productId;
        this.quantity = quantity;
        this.price = price;
    }
}
```

规则：

1. 聚合根统一维护集合。
2. 子 Entity 构造器尽量包级可见。
3. 外部不能直接 set 父对象。
4. `cascade` 和 `orphanRemoval` 只用于聚合内部。
5. 不跨聚合滥用级联。

### 6.2 慎用 `@ManyToMany`

`@ManyToMany` 初期方便，长期容易扩展困难。

不推荐：

```java
@ManyToMany
private Set<Role> roles;
```

推荐建关联实体：

```java
@Entity
public class UserRole {

    @ManyToOne(fetch = FetchType.LAZY)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    private Role role;

    private Instant assignedAt;
    private String assignedBy;
    private Instant expiredAt;
    private UserRoleStatus status;
}
```

企业系统中，关联关系通常迟早会出现状态、时间、审批人、来源、有效期等字段，因此建议默认不用 `@ManyToMany`。

---

## 7. 跨模块双向更新处理

### 7.1 核心原则

跨模块双向更新不要理解为：

```text
A Entity 修改 B Entity
B Entity 再反向修改 A Entity
```

而应改成：

```text
同聚合内：聚合根统一维护
跨聚合强一致：应用服务统一编排
跨模块最终一致：领域事件 / Outbox / Saga
跨模块查询：Read Model / Projection
跨模块引用：保存 ID，不直接持有 Entity
```

核心原则：

> Entity 只维护自己聚合内部的一致性；跨模块一致性由应用层流程、领域事件或 Saga 维护，不要让 JPA 双向关联变成业务双向依赖。

### 7.2 不同聚合但同一业务模块

例如：

```text
订单 Order
库存 Inventory
```

订单确认时要扣库存。

不推荐：

```java
order.confirm();
order.getInventory().reserve(...);
```

推荐放在应用服务：

```java
@Transactional
public void confirmOrder(ConfirmOrderCommand command) {
    Order order = orderRepository.getById(command.orderId());
    Inventory inventory = inventoryRepository.getByProductId(command.productId());

    inventory.reserve(command.quantity());
    order.confirm();

    inventoryRepository.save(inventory);
    orderRepository.save(order);
}
```

重点：

1. Entity 不直接跨聚合修改 Entity。
2. Application Service 负责协调多个聚合。
3. 每个聚合只维护自己的不变量。
4. 事务边界在应用服务层。

### 7.3 不同模块 / 不同限界上下文

例如：

```text
订单模块 Order
库存模块 Inventory
财务模块 Finance
客户信用模块 CustomerCredit
```

订单确认后：

```text
订单状态变为 CONFIRMED
库存锁定
客户信用额度占用
财务生成应收记录
```

不要在 `Order` Entity 中直接引用其他模块 Entity：

```java
@Entity
public class Order {

    @ManyToOne
    private Inventory inventory;

    @ManyToOne
    private CustomerCredit customerCredit;

    public void confirm() {
        inventory.reserve(...);
        customerCredit.freeze(...);
        this.status = CONFIRMED;
    }
}
```

推荐：

1. 订单只保存 `InventoryId`、`CustomerId` 等标识。
2. 应用服务负责强一致编排。
3. 领域事件负责最终一致通知。
4. Saga / Process Manager 负责长流程。

### 7.4 跨模块引用默认保存 ID

不推荐：

```java
@ManyToOne(fetch = FetchType.LAZY)
private Customer customer;
```

推荐：

```java
@Embedded
private CustomerId customerId;
```

需要客户信息时，通过查询服务获取：

```java
CustomerSnapshot customer = customerQueryService.getSnapshot(order.customerId());
```

### 7.5 强一致与最终一致要区分

#### 强一致场景

适合一个事务内完成：

```text
订单确认 + 库存锁定
工单下发 + 设备任务创建
用户授权 + 角色绑定
```

处理方式：

```java
@Transactional
public void handle(Command command) {
    A a = aRepository.getById(command.aId());
    B b = bRepository.getById(command.bId());

    a.changeSomething();
    b.changeSomething();

    aRepository.save(a);
    bRepository.save(b);
}
```

#### 最终一致场景

适合事件异步处理：

```text
更新报表
更新统计
发送通知
生成日志
生成财务凭证
同步搜索索引
刷新大屏数据
```

处理方式：

```text
A 模块发布事件
B 模块监听事件
失败可重试
必要时补偿
```

### 7.6 Saga / 流程管理器

适合复杂跨模块流程：

```text
下单
扣库存
冻结余额
生成支付单
生成物流单
任一步失败需要补偿
```

流程示例：

```text
OrderCreated
    ↓
ReserveInventory
    ↓
FreezeCredit
    ↓
CreatePayment
    ↓
OrderConfirmed
```

失败时补偿：

```text
ReleaseInventory
UnfreezeCredit
CancelOrder
```

---

## 8. 懒加载与查询模型

### 8.1 所有关联显式声明 Fetch 策略

推荐：

```java
@ManyToOne(fetch = FetchType.LAZY, optional = false)
private Customer customer;
```

不要：

```java
@ManyToOne
private Customer customer;
```

规范：

1. 所有关联必须显式声明 fetch 策略。
2. `ManyToOne` 默认使用 `LAZY`。
3. `OneToOne` 默认使用 `LAZY`，并验证 provider 支持情况。
4. 列表页禁止因懒加载造成 N+1 查询。
5. Controller 不直接返回 JPA Entity。
6. API 返回 DTO / ViewModel。
7. 查询列表页使用 Projection、Fetch Join 或 EntityGraph。
8. 禁止在 JSON 序列化阶段触发懒加载。

### 8.2 查询模型不要污染聚合模型

跨模块查询、列表页、统计页、大屏数据不要靠 Entity 双向关联硬查。

推荐使用：

1. DTO Projection
2. QueryRepository
3. Read Model
4. 物化视图
5. 搜索索引
6. 报表专用表

示例：

```java
public record OrderListView(
    String orderId,
    String customerName,
    String productName,
    BigDecimal amount,
    String status
) {}
```

---

## 9. 缓存问题处理

跨模块双向更新中，缓存问题通常不是单一缓存，而是多层缓存叠加。

常见缓存层次：

```text
1. JPA 一级缓存：同一个事务 / EntityManager 内的持久化上下文
2. JPA 二级缓存：Hibernate / EclipseLink 的 Entity Cache、Collection Cache
3. 查询缓存：Query Cache / DTO 查询结果缓存
4. 应用缓存：Redis / Caffeine / 本地内存缓存 / 前端缓存
```

核心原则：

> 写路径少用缓存，读路径可以用缓存；强一致数据慎用缓存，最终一致数据用事件驱动失效。

### 9.1 写路径不要依赖缓存

跨模块写操作不应从 Redis 或二级缓存里拿关键业务对象再修改。

推荐：

```java
@Transactional
public void confirmOrder(ConfirmOrderCommand command) {
    Order order = orderRepository.getById(command.orderId());
    Inventory inventory = inventoryRepository.getByProductId(command.productId());
    CustomerCredit credit = creditRepository.getByCustomerId(command.customerId());

    inventory.reserve(command.quantity());
    credit.freeze(order.totalAmount());
    order.confirm();

    orderRepository.save(order);
    inventoryRepository.save(inventory);
    creditRepository.save(credit);
}
```

写路径建议：

1. 从数据库加载聚合根。
2. 在事务内修改。
3. 使用 `@Version` 做并发控制。
4. 提交成功后再处理缓存失效。

### 9.2 JPA 一级缓存问题

同一个事务中，EntityManager 会缓存已加载的 Entity。即使数据库已经被 native SQL、批量更新、其他 Repository 更新过，当前事务里再次查询同一个 ID，也可能拿到旧对象。

典型问题：

```java
@Transactional
public void updateSomething() {
    Order order = orderRepository.findById(orderId).orElseThrow();

    orderRepository.bulkUpdateStatus(orderId, OrderStatus.CONFIRMED);

    Order again = orderRepository.findById(orderId).orElseThrow();

    // again 可能还是旧状态，因为一级缓存中已有 order
}
```

解决方式：

1. 核心写路径优先用领域对象方法，不优先用 bulk update。
2. 必须 bulk update 时，使用 `clearAutomatically` 和 `flushAutomatically`。
3. 必要时手动 `entityManager.flush()`、`entityManager.clear()`。
4. 只需要刷新某个对象时使用 `entityManager.refresh(entity)`。

示例：

```java
@Modifying(clearAutomatically = true, flushAutomatically = true)
@Query("update Order o set o.status = :status where o.id = :id")
void updateStatus(OrderId id, OrderStatus status);
```

### 9.3 二级缓存问题

企业系统里，二级缓存不要默认开启。

适合缓存：

1. 字典表。
2. 参数表。
3. 权限菜单等低频变更数据。
4. 只读配置。
5. 变化很少、可接受短暂延迟的数据。

不适合缓存：

1. 订单。
2. 库存。
3. 工单。
4. 账户余额。
5. 客户额度。
6. 审批状态。
7. 设备状态。
8. 流程状态。
9. 高频写入聚合根。

规则：

> 写多、并发多、强一致要求高的聚合根，不进二级缓存。

### 9.4 查询缓存问题

很多系统的问题不是 Entity 缓存，而是列表页、首页、统计页查询结果缓存没有失效。

示例：

```text
订单状态已变成 CONFIRMED
订单详情页正确
订单列表页仍显示 DRAFT
```

推荐按业务事件失效缓存，而不是按表失效。

事件示例：

```java
public record OrderConfirmedEvent(
    OrderId orderId,
    CustomerId customerId,
    Instant occurredAt,
    long version
) {}
```

缓存失效示例：

```java
public void on(OrderConfirmedEvent event) {
    cache.evict("order:detail:" + event.orderId());
    cache.evict("order:list:customer:" + event.customerId());
    cache.evict("customer:summary:" + event.customerId());
}
```

### 9.5 使用 Outbox 保证缓存失效可靠

不要在数据库事务内直接依赖 Redis 删除成功。

不推荐：

```java
@Transactional
public void confirmOrder() {
    order.confirm();
    orderRepository.save(order);

    redisTemplate.delete("order:detail:" + orderId);
}
```

如果 Redis 删除失败，数据库已经提交，缓存却可能长期保留旧数据。

推荐 Outbox：

```text
同一个数据库事务内：
1. 更新业务表
2. 写 outbox_event 表

事务提交后：
3. 后台任务投递事件
4. 消费者删除缓存 / 更新读模型
5. 成功后标记事件已处理
```

### 9.6 缓存更新优先删除，不直接修改

推荐 Cache Aside 模式：

```text
写数据库
发布事件
删除缓存
下次读数据库重建缓存
```

推荐：

```java
cache.evict(orderCacheKey);
```

不推荐：

```java
cache.put(orderCacheKey, newOrderValue);
```

原因：跨模块更新时，一个事件往往只知道部分字段，直接更新缓存容易漏字段、覆盖新数据、和其他事件乱序冲突。

### 9.7 缓存值带版本号

跨模块事件可能乱序。

示例：

```text
事件 1：OrderStatus = CONFIRMED, version = 2
事件 2：OrderStatus = CANCELED, version = 3
```

缓存值建议包含版本号：

```json
{
  "orderId": "O-1001",
  "status": "CANCELED",
  "version": 3
}
```

处理事件时判断：

```java
CachedOrder cached = cache.get(key);

if (cached == null || event.version() >= cached.version()) {
    cache.evict(key);
}
```

### 9.8 缓存 Owner 规则

不要让多个模块同时维护同一个缓存 Key。

错误模式：

```text
订单模块维护 customer:summary
客户模块也维护 customer:summary
财务模块也更新 customer:summary
```

推荐：

```text
一个缓存 Key 只有一个 Owner 模块
其他模块只能发事件
Owner 模块负责更新 / 删除缓存
```

示例：

```text
customer:summary:* 归客户模块维护
order:detail:* 归订单模块维护
inventory:stock:* 归库存模块维护
```

---

## 10. 事务与并发控制

### 10.1 事务边界放在应用服务

领域对象不应依赖：

```text
EntityManager
Repository
Spring Bean
ApplicationContext
RedisTemplate
消息队列客户端
```

错误示例：

```java
@Entity
public class Order {

    @Autowired
    private InventoryService inventoryService;

    public void confirm() {
        inventoryService.lockStock(...);
    }
}
```

推荐：

```java
@Transactional
public void confirmOrder(ConfirmOrderCommand command) {
    Order order = orderRepository.getById(command.orderId());

    inventoryService.checkAvailable(order.requiredItems());

    order.confirm();

    domainEventPublisher.publish(order.pullDomainEvents());
}
```

领域对象负责：

1. 状态变化。
2. 业务规则。
3. 不变量校验。
4. 领域事件记录。

应用服务负责：

1. 事务。
2. 权限。
3. 调用外部系统。
4. 调用 Repository。
5. 发布事件。
6. 跨聚合协调。

### 10.2 聚合根默认使用 `@Version`

企业系统中，订单、工单、设备、配方、审批流、库存等对象经常被多人同时修改。

建议聚合根默认加：

```java
@Version
private long version;
```

规范：

```text
聚合根：必须有 @Version
聚合内部 Entity：按需要决定
字典表：可不加
日志表：可不加
只读视图：不加
```

发生乐观锁冲突时，不要把底层异常直接返回给前端，应转换为友好的业务提示：

```text
当前数据已被其他用户修改，请刷新后重新操作。
```

---

## 11. equals / hashCode 规范

JPA Entity 存在代理、延迟加载、持久化前后 ID 变化等问题。

禁止：

```java
@Data
@EqualsAndHashCode
@Entity
public class Order {
}
```

尤其不要把关联字段放入 `equals/hashCode`，否则可能触发懒加载、递归、栈溢出。

建议：

1. 禁止 Lombok `@Data` 用在 JPA Entity。
2. 禁止关联字段参与 `equals/hashCode`。
3. 禁止可变字段参与 `hashCode`。
4. 优先使用不可变业务 ID。
5. ID 创建时即可生成，而不是等数据库生成后才稳定。

示例：

```java
@Id
private String id = UUID.randomUUID().toString();

@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Order other)) return false;
    return id != null && id.equals(other.id);
}

@Override
public int hashCode() {
    return getClass().hashCode();
}
```

---

## 12. API DTO 隔离

不要把 JPA Entity 直接暴露给前端。

否则会变成：

```text
领域模型 = 持久化模型 = API 模型
```

问题包括：

1. 懒加载序列化异常。
2. 无限递归 JSON。
3. 字段泄漏。
4. API 变更影响数据库模型。
5. 前端提交脏数据覆盖领域状态。
6. 安全字段暴露。

推荐分层：

```text
Controller
  ↓
Application Service
  ↓
Domain Entity / Aggregate
  ↓
Repository
  ↓
JPA
```

返回给前端：

```java
public record OrderDetailView(
    String orderId,
    String status,
    List<OrderLineView> lines
) {}
```

不要直接返回：

```java
Order
```

---

## 13. 推荐架构

```text
接口层 Controller
  - 接收 Request DTO
  - 返回 Response DTO
  - 不直接操作 Entity

应用层 Application Service
  - 事务边界
  - 权限校验
  - 调用 Repository
  - 调用领域行为
  - 编排多个聚合
  - 发布领域事件

领域层 Domain
  - Aggregate Root
  - Entity
  - Value Object
  - Domain Event
  - Domain Service

基础设施层 Infrastructure
  - Spring Data JPA Repository 实现
  - QueryRepository
  - Outbox Publisher
  - Event Handler
  - Redis / Caffeine 缓存适配器
  - 外部系统适配器
```

---

## 14. 推荐写路径

适用于跨模块强一致或准强一致写入：

```text
Application Service 接收 Command
    ↓
开启事务
    ↓
加载一个或多个聚合根
    ↓
调用领域方法
    ↓
使用 @Version 控制并发
    ↓
保存业务表
    ↓
同事务写 outbox_event
    ↓
事务提交
    ↓
Outbox Publisher 发布事件
    ↓
Owner 模块消费事件
    ↓
删除缓存 / 更新 Read Model / 执行补偿
```

示例：

```java
@Transactional
public void confirmOrder(ConfirmOrderCommand command) {
    Order order = orderRepository.getById(command.orderId());
    Inventory inventory = inventoryRepository.getByProductId(command.productId());
    CustomerCredit credit = creditRepository.getByCustomerId(command.customerId());

    inventory.reserve(command.quantity());
    credit.freeze(order.totalAmount());
    order.confirm();

    outboxRepository.save(order.pullDomainEvents());
}
```

---

## 15. 推荐读路径

### 15.1 强一致查询

```text
直接查数据库
必要时加锁或使用版本控制
不走缓存
```

适合：

1. 扣库存。
2. 冻结余额。
3. 占用额度。
4. 审批提交。
5. 工单派发。
6. 状态机流转。
7. 唯一性校验。
8. 权限关键判断。

### 15.2 普通详情页

```text
Cache Aside
先查缓存
缓存没有则查数据库
重建缓存
事件触发删除缓存
```

### 15.3 列表 / 报表 / 大屏

```text
Read Model + 缓存
领域事件异步更新
允许短暂最终一致
```

读模型要求：

1. 有更新时间。
2. 有版本号。
3. 有重建机制。
4. 有补偿任务。
5. 有人工刷新入口。

---

## 16. 企业编码规范建议

### 16.1 DDD + JPA 合一模式规范

```text
1. 聚合根才允许 Repository。
2. JPA Entity 不使用 @Data。
3. JPA Entity 不直接暴露给 Controller。
4. Entity 字段 private/protected，不允许 public 字段。
5. Entity 必须提供 protected 无参构造器。
6. Entity 不声明 final。
7. 持久化字段不声明 final。
8. 领域行为方法优先于 setter。
9. setter 仅限 JPA、框架或必要场景，默认不公开。
10. 所有关联显式声明 fetch 策略。
11. ManyToOne 默认写 fetch = LAZY。
12. 禁止跨聚合 cascade = ALL。
13. 禁止跨聚合 orphanRemoval = true。
14. 禁止滥用 @ManyToMany。
15. 聚合根默认加 @Version。
16. 双向关系必须由聚合根 add/remove 方法维护。
17. 领域对象不得注入 Spring Bean、Repository、EntityManager、RedisTemplate。
18. 领域事件只记录，不在 Entity 内直接发布。
19. 查询模型和命令模型使用 DTO / record。
20. 值对象优先使用 @Embeddable，必要时使用 record。
21. 金额、数量、状态流转必须封装为领域方法。
22. 复杂查询不要污染聚合模型，使用 QueryRepository / Projection / Read Model。
```

### 16.2 跨模块双向更新规范

```text
1. 跨模块 Entity 不允许直接双向调用业务方法。
2. 同一聚合内部的双向关系，由聚合根统一维护。
3. 跨聚合更新由 Application Service 编排。
4. 跨模块同步优先使用领域事件。
5. 跨模块 Entity 默认只保存对方 ID，不直接持有对方 Entity。
6. 跨模块禁止 cascade = ALL。
7. 跨模块禁止 orphanRemoval = true。
8. 查询需要跨模块数据时，使用 DTO Projection / QueryRepository / Read Model。
9. 需要强一致时，应用服务开启事务并显式加载多个聚合根。
10. 需要最终一致时，使用 Outbox + Event Handler + 补偿机制。
11. 所有参与跨聚合更新的聚合根必须有 @Version。
12. Saga 或 Process Manager 负责长事务和补偿流程。
```

### 16.3 缓存规范

```text
1. Entity 不直接操作缓存。
2. Repository 不隐藏式读写业务缓存。
3. Application Service 完成事务写入。
4. 事务提交成功后，通过领域事件触发缓存失效。
5. 强一致聚合根不启用二级缓存。
6. 高频写入聚合根不启用二级缓存。
7. 字典、配置、低频只读数据可以启用缓存。
8. 批量 update/delete 后必须 clear 或 refresh 持久化上下文。
9. Native SQL 修改业务表后，必须处理一级缓存和二级缓存失效。
10. 查询缓存必须有 TTL 和事件失效机制。
11. 跨模块缓存 Key 归属必须明确。
12. 一个缓存 Key 只能有一个 Owner 模块。
13. 缓存值建议包含 version / updatedAt。
14. 缓存删除失败必须可重试。
15. Outbox 事件必须可补偿、可重放。
16. 写路径不依赖缓存做关键业务判断。
17. 强一致数据直接查数据库。
18. 查询缓存优先删除，不直接更新。
```

---

## 17. 常见反模式

### 17.1 贫血模型

```java
order.setStatus(OrderStatus.CONFIRMED);
order.setConfirmTime(Instant.now());
```

应改为：

```java
order.confirm();
```

### 17.2 Entity 注入 Service

```java
@Entity
public class Order {
    @Autowired
    private InventoryService inventoryService;
}
```

应由 Application Service 编排。

### 17.3 跨模块双向 JPA 关联

```java
@Entity
public class Order {
    @ManyToOne
    private Customer customer;
}

@Entity
public class Customer {
    @OneToMany(mappedBy = "customer")
    private List<Order> orders;
}
```

若属于不同模块，应改为 ID 引用 + 查询服务。

### 17.4 滥用 cascade

```java
@ManyToOne(cascade = CascadeType.ALL)
private Customer customer;
```

跨聚合、跨模块禁止这样做。

### 17.5 Controller 直接返回 Entity

```java
@GetMapping("/orders/{id}")
public Order detail(@PathVariable String id) {
    return orderRepository.getById(id);
}
```

应返回 DTO / ViewModel。

### 17.6 多个模块维护同一个缓存 Key

```text
订单模块、客户模块、财务模块都写 customer:summary
```

应明确缓存 Owner。

---

## 18. 推荐落地步骤

### 第一步：建立聚合边界

1. 按业务一致性边界识别聚合。
2. 明确聚合根。
3. 明确聚合内部 Entity 和 Value Object。
4. 识别跨聚合引用，默认改为 ID 引用。

### 第二步：制定 Entity 编码规范

1. Entity 不用 `@Data`。
2. Entity 不暴露 setter。
3. Entity 提供 protected 无参构造器。
4. 领域行为优先。
5. 聚合根加 `@Version`。

### 第三步：处理双向关系

1. 同聚合内部由聚合根维护。
2. 跨聚合不做 JPA 双向关联。
3. 跨模块只保存对方 ID。
4. 复杂查询使用 QueryRepository。

### 第四步：定义跨模块更新策略

1. 强一致：Application Service 事务编排。
2. 最终一致：领域事件 + Outbox。
3. 长流程：Saga / Process Manager。
4. 报表统计：Read Model。

### 第五步：建立缓存规范

1. 明确缓存 Owner。
2. 设计缓存 Key。
3. 写路径不依赖缓存。
4. 事件驱动缓存失效。
5. Outbox 保证缓存失效可靠。
6. 缓存值带版本号和更新时间。

### 第六步：建立测试与审查机制

重点测试：

1. 聚合内部双向关系是否正确维护。
2. 跨模块更新是否出现循环调用。
3. 事务回滚是否完整。
4. 乐观锁冲突是否正确提示。
5. 缓存失效是否可靠。
6. 事件乱序是否不会覆盖新数据。
7. 查询是否存在 N+1 问题。
8. Controller 是否直接暴露 Entity。
9. cascade 是否跨聚合误用。
10. bulk update 后一级缓存是否被正确清理。

---

## 19. 总结

JDK 25 + DDD + JPA 合一模式可以作为企业 Java 项目的主流实践，但必须明确它不是“纯 DDD”，而是工程可落地的折中方案。

最重要的设计原则是：

```text
1. 聚合根控制聚合内部一致性。
2. Entity 表达领域行为，而不是只有 getter/setter。
3. JPA 关联不要跨模块滥用。
4. 跨模块更新由应用服务、领域事件、Outbox、Saga 处理。
5. 强一致写入以数据库事务为准。
6. 缓存只服务读性能，不参与关键写一致性。
7. API DTO 与 Entity 必须隔离。
8. 聚合根默认使用 @Version 处理并发。
9. 查询模型与写模型适度分离。
10. 一个缓存 Key 只能有一个 Owner 模块。
```

一句话总结：

> JDK 25 可以放心作为现代 Java 基线；DDD + JPA 合一模式可以用，但 Entity 必须“领域行为优先、JPA 约束兜底、API DTO 隔离、聚合根控制一致性”；跨模块双向更新不要靠 Entity 互相调用，而要用应用服务、领域事件、Outbox、Saga 和明确的缓存 Owner 机制来保证一致性与可维护性。
