# JDK 25 + DDD + JPA 合一模式示范代码

## 1. 示例场景：订单确认

业务动作：用户确认订单后，需要完成：

```text
订单模块：Order 从 DRAFT 变为 CONFIRMED
库存模块：Inventory 按订单明细预占库存
客户信用模块：CustomerCredit 冻结客户信用额度
缓存/读模型：删除订单详情缓存、客户订单列表缓存，并刷新订单摘要读模型
```

设计原则：

```text
1. Order、Inventory、CustomerCredit 是三个独立聚合根。
2. 聚合根之间不使用 JPA 双向关联。
3. 跨聚合强一致更新由 Application Service 在一个事务中编排。
4. 写业务表和写 outbox_event 在同一个事务内完成。
5. 缓存不参与写事务，事务成功后通过 Outbox 事件删除缓存。
6. Entity 不直接注入 Repository / Service / Cache。
```

---

## 2. 推荐项目结构

```text
src/main/java/com/example/dddjpa
├── DddJpaDemoApplication.java
├── interfaces
│   ├── order
│   │   ├── OrderController.java
│   │   ├── CreateOrderRequest.java
│   │   ├── ConfirmOrderRequest.java
│   │   └── OrderDetailView.java
│   └── GlobalExceptionHandler.java
├── application
│   ├── order
│   │   ├── OrderApplicationService.java
│   │   ├── CreateOrderCommand.java
│   │   └── ConfirmOrderCommand.java
│   └── query
│       └── OrderQueryService.java
├── domain
│   ├── shared
│   │   ├── AggregateRoot.java
│   │   ├── DomainEvent.java
│   │   ├── DomainException.java
│   │   └── Money.java
│   ├── order
│   │   ├── Order.java
│   │   ├── OrderLine.java
│   │   ├── OrderStatus.java
│   │   ├── OrderConfirmedEvent.java
│   │   └── OrderRepository.java
│   ├── inventory
│   │   ├── Inventory.java
│   │   └── InventoryRepository.java
│   └── credit
│       ├── CustomerCredit.java
│       └── CustomerCreditRepository.java
└── infrastructure
    ├── config
    │   ├── CacheConfig.java
    │   ├── JpaConfig.java
    │   └── SchedulerConfig.java
    ├── outbox
    │   ├── OutboxEvent.java
    │   ├── OutboxStatus.java
    │   ├── OutboxEventRepository.java
    │   ├── OutboxEventFactory.java
    │   └── OutboxPublisher.java
    ├── event
    │   └── OrderEventHandler.java
    └── readmodel
        ├── OrderSummaryReadModel.java
        └── OrderSummaryReadModelRepository.java
```

---

## 3. Maven 依赖示例

> Spring Boot 版本可按企业基线调整。这里按 Spring Boot 4.x 写法示例。

```xml
<project>
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>4.1.0</version>
        <relativePath/>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>ddd-jpa-demo</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>25</java.version>
        <maven.compiler.release>25</maven.compiler.release>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-webmvc</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>

        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>

        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
</project>
```

---

## 4. application.yml

```yaml
spring:
  application:
    name: ddd-jpa-demo

  datasource:
    url: jdbc:postgresql://localhost:5432/ddd_demo
    username: ddd
    password: ddd
    driver-class-name: org.postgresql.Driver

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
        cache:
          use_second_level_cache: false
          use_query_cache: false

  flyway:
    enabled: true
    locations: classpath:db/migration

  data:
    redis:
      host: localhost
      port: 6379
      timeout: 2s

  cache:
    type: redis
    redis:
      time-to-live: 10m
      cache-null-values: false

app:
  outbox:
    publish-fixed-delay-ms: 3000
    batch-size: 50
    max-attempts: 10
```

关键说明：

```text
open-in-view: false
  禁止 Controller 序列化阶段触发懒加载。

use_second_level_cache: false
use_query_cache: false
  默认关闭 Hibernate 二级缓存和查询缓存。
  订单、库存、信用额度等强一致聚合根不要进入二级缓存。

ddl-auto: validate
  表结构由 Flyway 管理，不由 Hibernate 自动修改。
```

---

## 5. 数据库脚本

```sql
create table orders (
    id uuid primary key,
    customer_id uuid not null,
    status varchar(32) not null,
    total_amount numeric(19, 4) not null,
    currency varchar(8) not null,
    version bigint not null,
    created_at timestamp not null,
    updated_at timestamp not null
);

create table order_lines (
    id uuid primary key,
    order_id uuid not null references orders(id),
    product_id uuid not null,
    quantity integer not null,
    unit_amount numeric(19, 4) not null,
    currency varchar(8) not null
);

create index idx_order_lines_order_id on order_lines(order_id);

create table inventory (
    id uuid primary key,
    product_id uuid not null unique,
    available_quantity integer not null,
    reserved_quantity integer not null,
    version bigint not null,
    updated_at timestamp not null
);

create table customer_credit (
    id uuid primary key,
    customer_id uuid not null unique,
    credit_limit_amount numeric(19, 4) not null,
    credit_limit_currency varchar(8) not null,
    frozen_amount numeric(19, 4) not null,
    frozen_currency varchar(8) not null,
    version bigint not null,
    updated_at timestamp not null
);

create table outbox_event (
    id uuid primary key,
    aggregate_type varchar(128) not null,
    aggregate_id varchar(128) not null,
    event_type varchar(256) not null,
    payload_json text not null,
    status varchar(32) not null,
    attempts integer not null,
    next_retry_at timestamp not null,
    created_at timestamp not null,
    published_at timestamp null,
    last_error text null
);

create index idx_outbox_status_retry on outbox_event(status, next_retry_at);

create table order_summary_read_model (
    order_id uuid primary key,
    customer_id uuid not null,
    status varchar(32) not null,
    total_amount numeric(19, 4) not null,
    currency varchar(8) not null,
    line_count integer not null,
    source_version bigint not null,
    updated_at timestamp not null
);

create index idx_order_summary_customer_id on order_summary_read_model(customer_id);
```

---

# 6. 共享领域代码

## 6.1 DomainException

```java
package com.example.dddjpa.domain.shared;

public class DomainException extends RuntimeException {
    public DomainException(String message) {
        super(message);
    }
}
```

## 6.2 DomainEvent

```java
package com.example.dddjpa.domain.shared;

import java.time.Instant;
import java.util.UUID;

public interface DomainEvent {
    UUID eventId();
    Instant occurredAt();
    String aggregateType();
    String aggregateId();
    String eventType();
}
```

## 6.3 AggregateRoot

```java
package com.example.dddjpa.domain.shared;

import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.Transient;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@MappedSuperclass
public abstract class AggregateRoot {

    @Transient
    private final List<DomainEvent> domainEvents = new ArrayList<>();

    protected void registerEvent(DomainEvent event) {
        this.domainEvents.add(event);
    }

    public List<DomainEvent> domainEvents() {
        return Collections.unmodifiableList(domainEvents);
    }

    public List<DomainEvent> pullDomainEvents() {
        List<DomainEvent> events = List.copyOf(domainEvents);
        domainEvents.clear();
        return events;
    }
}
```

## 6.4 Money 值对象

```java
package com.example.dddjpa.domain.shared;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Objects;

@Embeddable
public class Money {

    @Column(name = "amount", precision = 19, scale = 4)
    private BigDecimal amount;

    @Column(name = "currency", length = 8)
    private String currency;

    protected Money() {
    }

    private Money(BigDecimal amount, String currency) {
        if (amount == null) {
            throw new DomainException("金额不能为空");
        }
        if (currency == null || currency.isBlank()) {
            throw new DomainException("币种不能为空");
        }

        this.amount = amount.setScale(4, RoundingMode.HALF_UP);
        this.currency = currency;
    }

    public static Money of(BigDecimal amount, String currency) {
        return new Money(amount, currency);
    }

    public static Money zero(String currency) {
        return new Money(BigDecimal.ZERO, currency);
    }

    public Money add(Money other) {
        assertSameCurrency(other);
        return new Money(this.amount.add(other.amount), this.currency);
    }

    public Money multiply(int quantity) {
        if (quantity < 0) {
            throw new DomainException("数量不能为负数");
        }
        return new Money(this.amount.multiply(BigDecimal.valueOf(quantity)), this.currency);
    }

    public boolean greaterThan(Money other) {
        assertSameCurrency(other);
        return this.amount.compareTo(other.amount) > 0;
    }

    public BigDecimal amount() {
        return amount;
    }

    public String currency() {
        return currency;
    }

    private void assertSameCurrency(Money other) {
        if (!Objects.equals(this.currency, other.currency)) {
            throw new DomainException("币种不一致");
        }
    }
}
```

---

# 7. 订单聚合代码

## 7.1 OrderStatus

```java
package com.example.dddjpa.domain.order;

public enum OrderStatus {
    DRAFT,
    CONFIRMED,
    CANCELED
}
```

## 7.2 OrderConfirmedEvent

```java
package com.example.dddjpa.domain.order;

import com.example.dddjpa.domain.shared.DomainEvent;

import java.time.Instant;
import java.util.UUID;

public record OrderConfirmedEvent(
        UUID eventId,
        Instant occurredAt,
        UUID orderId,
        UUID customerId
) implements DomainEvent {

    public static OrderConfirmedEvent now(UUID orderId, UUID customerId) {
        return new OrderConfirmedEvent(
                UUID.randomUUID(),
                Instant.now(),
                orderId,
                customerId
        );
    }

    @Override
    public String aggregateType() {
        return "Order";
    }

    @Override
    public String aggregateId() {
        return orderId.toString();
    }

    @Override
    public String eventType() {
        return OrderConfirmedEvent.class.getName();
    }
}
```

## 7.3 Order

```java
package com.example.dddjpa.domain.order;

import com.example.dddjpa.domain.shared.AggregateRoot;
import com.example.dddjpa.domain.shared.DomainException;
import com.example.dddjpa.domain.shared.Money;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.*;

@Entity
@Table(name = "orders")
@AttributeOverrides({
        @AttributeOverride(
                name = "totalAmount.amount",
                column = @Column(name = "total_amount", precision = 19, scale = 4)
        ),
        @AttributeOverride(
                name = "totalAmount.currency",
                column = @Column(name = "currency", length = 8)
        )
})
public class Order extends AggregateRoot {

    @Id
    private UUID id;

    @Column(name = "customer_id", nullable = false)
    private UUID customerId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private OrderStatus status;

    @Embedded
    private Money totalAmount;

    @Version
    @Column(nullable = false)
    private long version;

    @Column(nullable = false)
    private Instant createdAt;

    @Column(nullable = false)
    private Instant updatedAt;

    @OneToMany(
            mappedBy = "order",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<OrderLine> lines = new ArrayList<>();

    protected Order() {
    }

    private Order(UUID id, UUID customerId, String currency) {
        this.id = Objects.requireNonNull(id);
        this.customerId = Objects.requireNonNull(customerId);
        this.status = OrderStatus.DRAFT;
        this.totalAmount = Money.zero(currency);
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;
    }

    public static Order create(UUID customerId, String currency) {
        return new Order(UUID.randomUUID(), customerId, currency);
    }

    public void addLine(UUID productId, int quantity, Money unitPrice) {
        ensureDraft();

        OrderLine line = OrderLine.create(this, productId, quantity, unitPrice);
        this.lines.add(line);
        recalculateTotal();
        touch();
    }

    public void confirm() {
        ensureDraft();

        if (lines.isEmpty()) {
            throw new DomainException("订单至少需要一条明细");
        }

        this.status = OrderStatus.CONFIRMED;
        touch();

        registerEvent(OrderConfirmedEvent.now(this.id, this.customerId));
    }

    public List<OrderLine> lines() {
        return Collections.unmodifiableList(lines);
    }

    public UUID id() {
        return id;
    }

    public UUID customerId() {
        return customerId;
    }

    public OrderStatus status() {
        return status;
    }

    public Money totalAmount() {
        return totalAmount;
    }

    public long version() {
        return version;
    }

    private void recalculateTotal() {
        String currency = this.totalAmount.currency();
        Money total = Money.zero(currency);

        for (OrderLine line : lines) {
            total = total.add(line.subtotal());
        }

        this.totalAmount = total;
    }

    private void ensureDraft() {
        if (this.status != OrderStatus.DRAFT) {
            throw new DomainException("只有草稿订单可以修改");
        }
    }

    private void touch() {
        this.updatedAt = Instant.now();
    }
}
```

## 7.4 OrderLine

```java
package com.example.dddjpa.domain.order;

import com.example.dddjpa.domain.shared.DomainException;
import com.example.dddjpa.domain.shared.Money;
import jakarta.persistence.*;

import java.util.Objects;
import java.util.UUID;

@Entity
@Table(name = "order_lines")
@AttributeOverrides({
        @AttributeOverride(
                name = "unitPrice.amount",
                column = @Column(name = "unit_amount", precision = 19, scale = 4)
        ),
        @AttributeOverride(
                name = "unitPrice.currency",
                column = @Column(name = "currency", length = 8)
        )
})
public class OrderLine {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Column(name = "product_id", nullable = false)
    private UUID productId;

    @Column(nullable = false)
    private int quantity;

    @Embedded
    private Money unitPrice;

    protected OrderLine() {
    }

    private OrderLine(Order order, UUID productId, int quantity, Money unitPrice) {
        if (quantity <= 0) {
            throw new DomainException("订单明细数量必须大于 0");
        }

        this.id = UUID.randomUUID();
        this.order = Objects.requireNonNull(order);
        this.productId = Objects.requireNonNull(productId);
        this.quantity = quantity;
        this.unitPrice = Objects.requireNonNull(unitPrice);
    }

    static OrderLine create(Order order, UUID productId, int quantity, Money unitPrice) {
        return new OrderLine(order, productId, quantity, unitPrice);
    }

    public Money subtotal() {
        return unitPrice.multiply(quantity);
    }

    public UUID productId() {
        return productId;
    }

    public int quantity() {
        return quantity;
    }

    public Money unitPrice() {
        return unitPrice;
    }
}
```

## 7.5 OrderRepository

```java
package com.example.dddjpa.domain.order;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {

    @EntityGraph(attributePaths = "lines")
    Optional<Order> findWithLinesById(UUID id);

    default Order getWithLines(UUID id) {
        return findWithLinesById(id)
                .orElseThrow(() -> new IllegalArgumentException("订单不存在：" + id));
    }
}
```

---

# 8. 库存聚合代码

## 8.1 Inventory

```java
package com.example.dddjpa.domain.inventory;

import com.example.dddjpa.domain.shared.AggregateRoot;
import com.example.dddjpa.domain.shared.DomainException;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "inventory")
public class Inventory extends AggregateRoot {

    @Id
    private UUID id;

    @Column(name = "product_id", nullable = false, unique = true)
    private UUID productId;

    @Column(name = "available_quantity", nullable = false)
    private int availableQuantity;

    @Column(name = "reserved_quantity", nullable = false)
    private int reservedQuantity;

    @Version
    @Column(nullable = false)
    private long version;

    @Column(nullable = false)
    private Instant updatedAt;

    protected Inventory() {
    }

    public Inventory(UUID productId, int availableQuantity) {
        if (availableQuantity < 0) {
            throw new DomainException("库存不能为负数");
        }

        this.id = UUID.randomUUID();
        this.productId = productId;
        this.availableQuantity = availableQuantity;
        this.reservedQuantity = 0;
        this.updatedAt = Instant.now();
    }

    public void reserve(int quantity) {
        if (quantity <= 0) {
            throw new DomainException("预占数量必须大于 0");
        }

        if (availableQuantity < quantity) {
            throw new DomainException("库存不足");
        }

        this.availableQuantity -= quantity;
        this.reservedQuantity += quantity;
        this.updatedAt = Instant.now();
    }

    public UUID productId() {
        return productId;
    }

    public long version() {
        return version;
    }
}
```

## 8.2 InventoryRepository

```java
package com.example.dddjpa.domain.inventory;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;
import java.util.UUID;

public interface InventoryRepository extends JpaRepository<Inventory, UUID> {

    @Lock(LockModeType.OPTIMISTIC)
    Optional<Inventory> findLockedByProductId(UUID productId);

    default Inventory getByProductId(UUID productId) {
        return findLockedByProductId(productId)
                .orElseThrow(() -> new IllegalArgumentException("库存不存在：" + productId));
    }
}
```

---

# 9. 客户信用聚合代码

## 9.1 CustomerCredit

```java
package com.example.dddjpa.domain.credit;

import com.example.dddjpa.domain.shared.AggregateRoot;
import com.example.dddjpa.domain.shared.DomainException;
import com.example.dddjpa.domain.shared.Money;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "customer_credit")
@AttributeOverrides({
        @AttributeOverride(
                name = "creditLimit.amount",
                column = @Column(name = "credit_limit_amount", precision = 19, scale = 4)
        ),
        @AttributeOverride(
                name = "creditLimit.currency",
                column = @Column(name = "credit_limit_currency", length = 8)
        ),
        @AttributeOverride(
                name = "frozenAmount.amount",
                column = @Column(name = "frozen_amount", precision = 19, scale = 4)
        ),
        @AttributeOverride(
                name = "frozenAmount.currency",
                column = @Column(name = "frozen_currency", length = 8)
        )
})
public class CustomerCredit extends AggregateRoot {

    @Id
    private UUID id;

    @Column(name = "customer_id", nullable = false, unique = true)
    private UUID customerId;

    @Embedded
    private Money creditLimit;

    @Embedded
    private Money frozenAmount;

    @Version
    @Column(nullable = false)
    private long version;

    @Column(nullable = false)
    private Instant updatedAt;

    protected CustomerCredit() {
    }

    public CustomerCredit(UUID customerId, Money creditLimit) {
        this.id = UUID.randomUUID();
        this.customerId = customerId;
        this.creditLimit = creditLimit;
        this.frozenAmount = Money.zero(creditLimit.currency());
        this.updatedAt = Instant.now();
    }

    public void freeze(Money amount) {
        Money afterFrozen = this.frozenAmount.add(amount);

        if (afterFrozen.greaterThan(creditLimit)) {
            throw new DomainException("客户信用额度不足");
        }

        this.frozenAmount = afterFrozen;
        this.updatedAt = Instant.now();
    }

    public UUID customerId() {
        return customerId;
    }

    public long version() {
        return version;
    }
}
```

## 9.2 CustomerCreditRepository

```java
package com.example.dddjpa.domain.credit;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;

import java.util.Optional;
import java.util.UUID;

public interface CustomerCreditRepository extends JpaRepository<CustomerCredit, UUID> {

    @Lock(LockModeType.OPTIMISTIC)
    Optional<CustomerCredit> findLockedByCustomerId(UUID customerId);

    default CustomerCredit getByCustomerId(UUID customerId) {
        return findLockedByCustomerId(customerId)
                .orElseThrow(() -> new IllegalArgumentException("客户信用记录不存在：" + customerId));
    }
}
```

---

# 10. 应用层：跨模块事务编排

## 10.1 命令对象

```java
package com.example.dddjpa.application.order;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record CreateOrderCommand(
        UUID customerId,
        String currency,
        List<Line> lines
) {
    public record Line(UUID productId, int quantity, BigDecimal unitAmount) {
    }
}
```

```java
package com.example.dddjpa.application.order;

import java.util.UUID;

public record ConfirmOrderCommand(UUID orderId) {
}
```

## 10.2 OrderApplicationService

```java
package com.example.dddjpa.application.order;

import com.example.dddjpa.domain.credit.CustomerCredit;
import com.example.dddjpa.domain.credit.CustomerCreditRepository;
import com.example.dddjpa.domain.inventory.Inventory;
import com.example.dddjpa.domain.inventory.InventoryRepository;
import com.example.dddjpa.domain.order.Order;
import com.example.dddjpa.domain.order.OrderLine;
import com.example.dddjpa.domain.order.OrderRepository;
import com.example.dddjpa.domain.shared.DomainEvent;
import com.example.dddjpa.domain.shared.Money;
import com.example.dddjpa.infrastructure.outbox.OutboxEventFactory;
import com.example.dddjpa.infrastructure.outbox.OutboxEventRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class OrderApplicationService {

    private final OrderRepository orderRepository;
    private final InventoryRepository inventoryRepository;
    private final CustomerCreditRepository creditRepository;
    private final OutboxEventRepository outboxEventRepository;
    private final OutboxEventFactory outboxEventFactory;

    public OrderApplicationService(
            OrderRepository orderRepository,
            InventoryRepository inventoryRepository,
            CustomerCreditRepository creditRepository,
            OutboxEventRepository outboxEventRepository,
            OutboxEventFactory outboxEventFactory
    ) {
        this.orderRepository = orderRepository;
        this.inventoryRepository = inventoryRepository;
        this.creditRepository = creditRepository;
        this.outboxEventRepository = outboxEventRepository;
        this.outboxEventFactory = outboxEventFactory;
    }

    @Transactional
    public UUID createOrder(CreateOrderCommand command) {
        Order order = Order.create(command.customerId(), command.currency());

        for (CreateOrderCommand.Line line : command.lines()) {
            order.addLine(
                    line.productId(),
                    line.quantity(),
                    Money.of(line.unitAmount(), command.currency())
            );
        }

        orderRepository.save(order);
        return order.id();
    }

    @Transactional
    public void confirmOrder(ConfirmOrderCommand command) {
        Order order = orderRepository.getWithLines(command.orderId());

        for (OrderLine line : order.lines()) {
            Inventory inventory = inventoryRepository.getByProductId(line.productId());
            inventory.reserve(line.quantity());
        }

        CustomerCredit credit = creditRepository.getByCustomerId(order.customerId());
        credit.freeze(order.totalAmount());

        order.confirm();
        orderRepository.save(order);

        List<DomainEvent> events = order.pullDomainEvents();
        events.stream()
                .map(outboxEventFactory::from)
                .forEach(outboxEventRepository::save);
    }
}
```

重点：

```text
1. confirmOrder 是一个完整用例，所以事务边界在这里。
2. Order 不直接调用 InventoryRepository。
3. Inventory 不直接调用 Order。
4. CustomerCredit 不直接调用 Order。
5. 三个聚合根都只维护自己的不变量。
6. Application Service 负责跨聚合一致性。
7. Outbox 和业务表在一个事务中保存。
```

---

# 11. Outbox 机制

## 11.1 OutboxStatus

```java
package com.example.dddjpa.infrastructure.outbox;

public enum OutboxStatus {
    NEW,
    PUBLISHED,
    FAILED
}
```

## 11.2 OutboxEvent

```java
package com.example.dddjpa.infrastructure.outbox;

import jakarta.persistence.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "outbox_event")
public class OutboxEvent {

    @Id
    private UUID id;

    @Column(name = "aggregate_type", nullable = false, length = 128)
    private String aggregateType;

    @Column(name = "aggregate_id", nullable = false, length = 128)
    private String aggregateId;

    @Column(name = "event_type", nullable = false, length = 256)
    private String eventType;

    @Column(name = "payload_json", nullable = false, columnDefinition = "text")
    private String payloadJson;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private OutboxStatus status;

    @Column(nullable = false)
    private int attempts;

    @Column(name = "next_retry_at", nullable = false)
    private Instant nextRetryAt;

    @Column(nullable = false)
    private Instant createdAt;

    @Column(name = "published_at")
    private Instant publishedAt;

    @Column(name = "last_error", columnDefinition = "text")
    private String lastError;

    protected OutboxEvent() {
    }

    public OutboxEvent(
            UUID id,
            String aggregateType,
            String aggregateId,
            String eventType,
            String payloadJson
    ) {
        this.id = id;
        this.aggregateType = aggregateType;
        this.aggregateId = aggregateId;
        this.eventType = eventType;
        this.payloadJson = payloadJson;
        this.status = OutboxStatus.NEW;
        this.attempts = 0;
        this.createdAt = Instant.now();
        this.nextRetryAt = this.createdAt;
    }

    public void markPublished() {
        this.status = OutboxStatus.PUBLISHED;
        this.publishedAt = Instant.now();
        this.lastError = null;
    }

    public void markFailed(String errorMessage, int maxAttempts) {
        this.attempts++;

        if (this.attempts >= maxAttempts) {
            this.status = OutboxStatus.FAILED;
        } else {
            this.status = OutboxStatus.NEW;
        }

        this.lastError = errorMessage;
        this.nextRetryAt = Instant.now().plusSeconds(Math.min(300, attempts * 10L));
    }

    public UUID id() {
        return id;
    }

    public String eventType() {
        return eventType;
    }

    public String payloadJson() {
        return payloadJson;
    }
}
```

## 11.3 OutboxEventFactory

```java
package com.example.dddjpa.infrastructure.outbox;

import com.example.dddjpa.domain.shared.DomainEvent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

@Component
public class OutboxEventFactory {

    private final ObjectMapper objectMapper;

    public OutboxEventFactory(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public OutboxEvent from(DomainEvent event) {
        try {
            return new OutboxEvent(
                    event.eventId(),
                    event.aggregateType(),
                    event.aggregateId(),
                    event.eventType(),
                    objectMapper.writeValueAsString(event)
            );
        } catch (JsonProcessingException ex) {
            throw new IllegalStateException("领域事件序列化失败：" + event.eventType(), ex);
        }
    }
}
```

## 11.4 OutboxEventRepository

```java
package com.example.dddjpa.infrastructure.outbox;

import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface OutboxEventRepository extends JpaRepository<OutboxEvent, UUID> {

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
        select e
        from OutboxEvent e
        where e.status = com.example.dddjpa.infrastructure.outbox.OutboxStatus.NEW
          and e.nextRetryAt <= :now
        order by e.createdAt asc
    """)
    List<OutboxEvent> findPendingForPublish(Instant now, Pageable pageable);
}
```

## 11.5 OutboxPublisher

```java
package com.example.dddjpa.infrastructure.outbox;

import com.example.dddjpa.domain.shared.DomainEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Component
public class OutboxPublisher {

    private final OutboxEventRepository repository;
    private final ObjectMapper objectMapper;
    private final ApplicationEventPublisher publisher;
    private final int batchSize;
    private final int maxAttempts;

    public OutboxPublisher(
            OutboxEventRepository repository,
            ObjectMapper objectMapper,
            ApplicationEventPublisher publisher,
            @Value("${app.outbox.batch-size:50}") int batchSize,
            @Value("${app.outbox.max-attempts:10}") int maxAttempts
    ) {
        this.repository = repository;
        this.objectMapper = objectMapper;
        this.publisher = publisher;
        this.batchSize = batchSize;
        this.maxAttempts = maxAttempts;
    }

    @Scheduled(fixedDelayString = "${app.outbox.publish-fixed-delay-ms:3000}")
    @Transactional
    public void publishPendingEvents() {
        List<OutboxEvent> events = repository.findPendingForPublish(
                Instant.now(),
                PageRequest.of(0, batchSize)
        );

        for (OutboxEvent event : events) {
            publishOne(event);
        }
    }

    private void publishOne(OutboxEvent outboxEvent) {
        try {
            Class<?> eventClass = Class.forName(outboxEvent.eventType());
            Object domainEvent = objectMapper.readValue(outboxEvent.payloadJson(), eventClass);

            if (!(domainEvent instanceof DomainEvent)) {
                throw new IllegalStateException("不是合法领域事件：" + outboxEvent.eventType());
            }

            publisher.publishEvent(domainEvent);
            outboxEvent.markPublished();
        } catch (Exception ex) {
            outboxEvent.markFailed(ex.getMessage(), maxAttempts);
        }
    }
}
```

---

# 12. 缓存与读模型

## 12.1 CacheConfig

```java
package com.example.dddjpa.infrastructure.config;

import org.springframework.boot.autoconfigure.cache.RedisCacheManagerBuilderCustomizer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;

import java.time.Duration;

@Configuration
@EnableCaching
public class CacheConfig {

    public static final String ORDER_DETAIL_CACHE = "order:detail";
    public static final String CUSTOMER_ORDER_LIST_CACHE = "customer:order:list";

    @Bean
    RedisCacheManagerBuilderCustomizer redisCacheManagerBuilderCustomizer() {
        return builder -> builder
                .withCacheConfiguration(
                        ORDER_DETAIL_CACHE,
                        RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofMinutes(10))
                                .disableCachingNullValues()
                )
                .withCacheConfiguration(
                        CUSTOMER_ORDER_LIST_CACHE,
                        RedisCacheConfiguration.defaultCacheConfig()
                                .entryTtl(Duration.ofMinutes(3))
                                .disableCachingNullValues()
                );
    }
}
```

## 12.2 OrderSummaryReadModel

```java
package com.example.dddjpa.infrastructure.readmodel;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "order_summary_read_model")
public class OrderSummaryReadModel {

    @Id
    private UUID orderId;

    @Column(nullable = false)
    private UUID customerId;

    @Column(nullable = false, length = 32)
    private String status;

    @Column(name = "total_amount", nullable = false, precision = 19, scale = 4)
    private BigDecimal totalAmount;

    @Column(nullable = false, length = 8)
    private String currency;

    @Column(nullable = false)
    private int lineCount;

    @Column(nullable = false)
    private long sourceVersion;

    @Column(nullable = false)
    private Instant updatedAt;

    protected OrderSummaryReadModel() {
    }

    public OrderSummaryReadModel(
            UUID orderId,
            UUID customerId,
            String status,
            BigDecimal totalAmount,
            String currency,
            int lineCount,
            long sourceVersion
    ) {
        this.orderId = orderId;
        this.customerId = customerId;
        this.status = status;
        this.totalAmount = totalAmount;
        this.currency = currency;
        this.lineCount = lineCount;
        this.sourceVersion = sourceVersion;
        this.updatedAt = Instant.now();
    }

    public void refresh(
            String status,
            BigDecimal totalAmount,
            String currency,
            int lineCount,
            long sourceVersion
    ) {
        if (sourceVersion < this.sourceVersion) {
            return;
        }

        this.status = status;
        this.totalAmount = totalAmount;
        this.currency = currency;
        this.lineCount = lineCount;
        this.sourceVersion = sourceVersion;
        this.updatedAt = Instant.now();
    }
}
```

## 12.3 OrderSummaryReadModelRepository

```java
package com.example.dddjpa.infrastructure.readmodel;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface OrderSummaryReadModelRepository extends JpaRepository<OrderSummaryReadModel, UUID> {

    List<OrderSummaryReadModel> findTop20ByCustomerIdOrderByUpdatedAtDesc(UUID customerId);
}
```

## 12.4 OrderEventHandler

```java
package com.example.dddjpa.infrastructure.event;

import com.example.dddjpa.domain.order.Order;
import com.example.dddjpa.domain.order.OrderConfirmedEvent;
import com.example.dddjpa.domain.order.OrderRepository;
import com.example.dddjpa.infrastructure.config.CacheConfig;
import com.example.dddjpa.infrastructure.readmodel.OrderSummaryReadModel;
import com.example.dddjpa.infrastructure.readmodel.OrderSummaryReadModelRepository;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionalEventListener;

import static org.springframework.transaction.event.TransactionPhase.AFTER_COMMIT;

@Component
public class OrderEventHandler {

    private final CacheManager cacheManager;
    private final OrderRepository orderRepository;
    private final OrderSummaryReadModelRepository readModelRepository;

    public OrderEventHandler(
            CacheManager cacheManager,
            OrderRepository orderRepository,
            OrderSummaryReadModelRepository readModelRepository
    ) {
        this.cacheManager = cacheManager;
        this.orderRepository = orderRepository;
        this.readModelRepository = readModelRepository;
    }

    @TransactionalEventListener(phase = AFTER_COMMIT)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void on(OrderConfirmedEvent event) {
        evictOrderCaches(event);
        refreshOrderSummary(event);
    }

    private void evictOrderCaches(OrderConfirmedEvent event) {
        Cache orderDetail = cacheManager.getCache(CacheConfig.ORDER_DETAIL_CACHE);
        if (orderDetail != null) {
            orderDetail.evictIfPresent(event.orderId());
        }

        Cache customerOrderList = cacheManager.getCache(CacheConfig.CUSTOMER_ORDER_LIST_CACHE);
        if (customerOrderList != null) {
            customerOrderList.evictIfPresent(event.customerId());
        }
    }

    private void refreshOrderSummary(OrderConfirmedEvent event) {
        Order order = orderRepository.getWithLines(event.orderId());

        OrderSummaryReadModel newModel = new OrderSummaryReadModel(
                order.id(),
                order.customerId(),
                order.status().name(),
                order.totalAmount().amount(),
                order.totalAmount().currency(),
                order.lines().size(),
                order.version()
        );

        OrderSummaryReadModel model = readModelRepository
                .findById(order.id())
                .orElse(newModel);

        model.refresh(
                order.status().name(),
                order.totalAmount().amount(),
                order.totalAmount().currency(),
                order.lines().size(),
                order.version()
        );

        readModelRepository.save(model);
    }
}
```

说明：

```text
1. 删除缓存是幂等的。
2. 读模型 refresh 带 sourceVersion，避免旧事件覆盖新状态。
3. 如果事件处理失败，Outbox 状态不会 markPublished，下次会重试。
4. 真实项目建议增加 consumed_event 表，进一步保证消费者幂等。
```

---

# 13. 查询服务

## 13.1 OrderDetailView

```java
package com.example.dddjpa.interfaces.order;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record OrderDetailView(
        UUID orderId,
        UUID customerId,
        String status,
        BigDecimal totalAmount,
        String currency,
        List<Line> lines
) {
    public record Line(
            UUID productId,
            int quantity,
            BigDecimal unitAmount,
            String currency
    ) {
    }
}
```

## 13.2 OrderQueryService

```java
package com.example.dddjpa.application.query;

import com.example.dddjpa.domain.order.Order;
import com.example.dddjpa.domain.order.OrderRepository;
import com.example.dddjpa.infrastructure.config.CacheConfig;
import com.example.dddjpa.infrastructure.readmodel.OrderSummaryReadModel;
import com.example.dddjpa.infrastructure.readmodel.OrderSummaryReadModelRepository;
import com.example.dddjpa.interfaces.order.OrderDetailView;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class OrderQueryService {

    private final OrderRepository orderRepository;
    private final OrderSummaryReadModelRepository summaryRepository;

    public OrderQueryService(
            OrderRepository orderRepository,
            OrderSummaryReadModelRepository summaryRepository
    ) {
        this.orderRepository = orderRepository;
        this.summaryRepository = summaryRepository;
    }

    @Cacheable(cacheNames = CacheConfig.ORDER_DETAIL_CACHE, key = "#orderId")
    @Transactional(readOnly = true)
    public OrderDetailView getOrderDetail(UUID orderId) {
        Order order = orderRepository.getWithLines(orderId);

        return new OrderDetailView(
                order.id(),
                order.customerId(),
                order.status().name(),
                order.totalAmount().amount(),
                order.totalAmount().currency(),
                order.lines().stream()
                        .map(line -> new OrderDetailView.Line(
                                line.productId(),
                                line.quantity(),
                                line.unitPrice().amount(),
                                line.unitPrice().currency()
                        ))
                        .toList()
        );
    }

    @Cacheable(cacheNames = CacheConfig.CUSTOMER_ORDER_LIST_CACHE, key = "#customerId")
    @Transactional(readOnly = true)
    public List<OrderSummaryReadModel> getCustomerRecentOrders(UUID customerId) {
        return summaryRepository.findTop20ByCustomerIdOrderByUpdatedAtDesc(customerId);
    }
}
```

---

# 14. Controller 层

## 14.1 Request DTO

```java
package com.example.dddjpa.interfaces.order;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record CreateOrderRequest(
        @NotNull UUID customerId,
        @NotBlank String currency,
        @NotEmpty List<@Valid Line> lines
) {
    public record Line(
            @NotNull UUID productId,
            @Min(1) int quantity,
            @NotNull @DecimalMin("0.0001") BigDecimal unitAmount
    ) {
    }
}
```

```java
package com.example.dddjpa.interfaces.order;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record ConfirmOrderRequest(@NotNull UUID orderId) {
}
```

## 14.2 OrderController

```java
package com.example.dddjpa.interfaces.order;

import com.example.dddjpa.application.order.ConfirmOrderCommand;
import com.example.dddjpa.application.order.CreateOrderCommand;
import com.example.dddjpa.application.order.OrderApplicationService;
import com.example.dddjpa.application.query.OrderQueryService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderApplicationService orderApplicationService;
    private final OrderQueryService orderQueryService;

    public OrderController(
            OrderApplicationService orderApplicationService,
            OrderQueryService orderQueryService
    ) {
        this.orderApplicationService = orderApplicationService;
        this.orderQueryService = orderQueryService;
    }

    @PostMapping
    public CreateOrderResponse create(@Valid @RequestBody CreateOrderRequest request) {
        UUID orderId = orderApplicationService.createOrder(toCommand(request));
        return new CreateOrderResponse(orderId);
    }

    @PostMapping("/{orderId}/confirm")
    public void confirm(@PathVariable UUID orderId) {
        orderApplicationService.confirmOrder(new ConfirmOrderCommand(orderId));
    }

    @GetMapping("/{orderId}")
    public OrderDetailView detail(@PathVariable UUID orderId) {
        return orderQueryService.getOrderDetail(orderId);
    }

    private CreateOrderCommand toCommand(CreateOrderRequest request) {
        return new CreateOrderCommand(
                request.customerId(),
                request.currency(),
                request.lines().stream()
                        .map(line -> new CreateOrderCommand.Line(
                                line.productId(),
                                line.quantity(),
                                line.unitAmount()
                        ))
                        .toList()
        );
    }

    public record CreateOrderResponse(UUID orderId) {
    }
}
```

---

# 15. 全局异常处理

```java
package com.example.dddjpa.interfaces;

import com.example.dddjpa.domain.shared.DomainException;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DomainException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, Object> handleDomainException(DomainException ex) {
        return Map.of(
                "code", "DOMAIN_ERROR",
                "message", ex.getMessage()
        );
    }

    @ExceptionHandler(OptimisticLockingFailureException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public Map<String, Object> handleOptimisticLocking(OptimisticLockingFailureException ex) {
        return Map.of(
                "code", "CONCURRENT_MODIFICATION",
                "message", "当前数据已被其他用户修改，请刷新后重试"
        );
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Map<String, Object> handleValidation(MethodArgumentNotValidException ex) {
        return Map.of(
                "code", "VALIDATION_ERROR",
                "message", "请求参数不合法"
        );
    }
}
```

---

# 16. 框架配置类

## 16.1 SchedulerConfig

```java
package com.example.dddjpa.infrastructure.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

@Configuration
@EnableScheduling
public class SchedulerConfig {
}
```

## 16.2 JpaConfig

```java
package com.example.dddjpa.infrastructure.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@Configuration
@EnableTransactionManagement
@EnableJpaAuditing
public class JpaConfig {
}
```

---

# 17. 生产级注意事项

## 17.1 Outbox 多实例

教学版使用 JPA 悲观锁。生产中 PostgreSQL 建议：

```sql
select *
from outbox_event
where status = 'NEW'
  and next_retry_at <= now()
order by created_at
for update skip locked
limit 50;
```

## 17.2 消费幂等

建议增加：

```sql
create table consumed_event (
    event_id uuid primary key,
    consumer_name varchar(128) not null,
    consumed_at timestamp not null
);
```

消费者处理前先插入，插入失败说明已经消费过。

## 17.3 高并发库存

如果库存热点非常高，JPA 乐观锁可能冲突很多，可改为数据库原子更新：

```sql
update inventory
set available_quantity = available_quantity - :quantity,
    reserved_quantity = reserved_quantity + :quantity,
    version = version + 1
where product_id = :productId
  and available_quantity >= :quantity;
```

返回更新行数为 1 才算成功。

## 17.4 不建议二级缓存的聚合

```text
订单
库存
客户额度
账户余额
审批单
工单
设备状态
流程状态
```

可以缓存：

```text
字典
参数
菜单
低频只读配置
```

---

# 18. 总结

这个示例的核心不是代码量，而是边界：

```text
同聚合内部：
  可以使用 JPA 双向关系，由聚合根维护。

跨聚合强一致：
  Application Service 一个事务内显式编排。

跨模块最终一致：
  Domain Event + Outbox + Event Handler。

缓存：
  写路径不碰缓存；
  缓存 DTO / ReadModel；
  事务提交后事件驱动删除缓存。

并发：
  聚合根使用 @Version；
  热点数据必要时改用数据库原子 update。
```

一句话：

> JPA Entity 可以和 DDD 领域对象合一，但不要让 Entity 同时承担跨模块编排、缓存同步、事件投递和流程控制；这些职责应该放到 Application Service、Outbox、Event Handler 和 Query Service 中。
