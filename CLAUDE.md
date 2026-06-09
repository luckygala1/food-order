# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

Java 17 + Maven (no wrapper, must have `mvn` installed globally).

```bash
# Build all modules (also builds Docker images via Spring Boot Buildpacks)
mvn clean install

# Build without tests
mvn clean install -DskipTests

# Run a single module's tests
mvn test -pl order-service/order-domain/order-application-service

# Generate Avro classes from schemas
mvn generate-sources -pl infrastructure/kafka/kafka-model
```

### Infrastructure (Kafka + Zookeeper)

```bash
cd infrastructure/docker-compose
docker-compose -f common.yml -f zookeeper.yml -f kafka_cluster.yml -f kafka_init.yml up -d
```

### Start Services (each in a separate terminal)

```bash
mvn spring-boot:run -pl order-service/order-container
mvn spring-boot:run -pl payment-service/payment-container
mvn spring-boot:run -pl restaurant-service/restaurant-container
mvn spring-boot:run -pl customer-service
```

### Service Ports

| Service | Port |
|---------|------|
| Order Service | 8181 |
| Payment Service | 8182 |
| Restaurant Service | 8183 |
| Customer Service | 8184 |

## Architecture

Multi-module Maven reactor implementing a distributed food ordering system using DDD, Hexagonal Architecture, and choreography-based SAGA pattern over Kafka.

### Module Layout

Each business service (order, payment, restaurant) follows the same hexagonal structure:

```
<service>-service/
  <service>-domain/
    <service>-domain-core/          # Pure domain: entities, value objects, events, domain service interfaces
    <service>-application-service/  # Application logic: saga steps, command handlers, input/output ports
  <service>-data-access/            # Secondary adapter: JPA entities, Spring Data repositories
  <service>-messaging/              # Secondary adapter: Kafka listeners and publishers
  <service>-container/              # Spring Boot main class, application.yml, init-schema.sql
```

`common/` holds shared DDD base classes (`AggregateRoot`, `BaseEntity`, `DomainEvent`), global exception handler, and shared JPA entities.

`infrastructure/` provides reusable Kafka infrastructure (`kafka-config-data`, `kafka-model` with Avro schemas, `kafka-producer`, `kafka-consumer`) and the `SagaStep<T,S,U>` interface.

### Inter-Service Communication (Kafka)

All messages use **Avro serialization** with Confluent Schema Registry at `http://localhost:8081`. Consumers use batch listening with 3 concurrent listeners.

```
Order Service (8181)
  |-- POST /orders --> creates order, fires OrderCreatedEvent
  |
  |-- publishes to payment-request topic --> Payment Service (8182)
  |<-- consumes payment-response topic ---- Payment Service
  |
  |-- publishes to restaurant-approval-request topic --> Restaurant Service (8183)
  |<-- consumes restaurant-approval-response topic ---- Restaurant Service
```

### SAGA State Machine

Choreography-based (no central coordinator). Order Service owns the saga step implementations.

```
Happy path:  PENDING -> PAID -> APPROVED
Compensate:  PAID -> CANCELLING -> CANCELLED  (payment or restaurant failure)
             PENDING -> CANCELLED              (payment failure)
```

Key saga classes:
- `OrderPaymentSaga` (in `order-application-service`) — processes payment response, triggers restaurant approval
- `OrderApprovalSaga` (in `order-application-service`) — processes restaurant response, compensates on rejection

### Domain Event Mechanism

Domain events carry a reference to their publisher (injected via constructor). Calling `event.fire()` publishes the Kafka message. This decouples domain logic from messaging infrastructure. Example: `OrderCreatedEvent` holds `OrderCreatedPaymentRequestMessagePublisher`.

## Database

Single PostgreSQL instance (`localhost:5432`, user `postgres`/`postgres`) with 4 separate schemas: `order`, `payment`, `restaurant`, `customer`. Each service's schema is initialized via `init-schema.sql` in its container module. UUID primary keys throughout. Materialized views in `customer` and `restaurant` schemas for CQRS read models.

## Key Conventions

- **Lombok** is used project-wide (`@Builder`, `@Getter`, `@AllArgsConstructor`, etc.)
- **No Outbox pattern implemented** despite README mention — messages publish directly after domain events fire
- **No Dockerfiles** — Docker images are built via Spring Boot Buildpacks during `mvn install`
- Tests exist only in `order-service/order-domain/order-application-service` using JUnit 5 + Mockito + `@SpringBootTest` with mocked repositories and publishers
