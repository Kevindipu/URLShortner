# V2 — Issues & Troubleshooting

This document records the main issues encountered while moving the URL Shortener from the local V1 setup to AWS.

## 1. Moving from SQLite to PostgreSQL

### Problem
SQLite was suitable for the local version but was not appropriate for the intended AWS architecture with multiple EC2 instances. Two EC2 instances cannot safely use separate local SQLite databases and still behave like one application.

### Resolution
V2 introduced Amazon RDS PostgreSQL as the shared database:

```text
Internet
   |
  ALB
 /   \
EC2  EC2
 \   /
  RDS
```

### Lesson
A horizontally scaled application needs shared persistent storage rather than instance-local database files.

---

## 2. RDS subnet coverage

### Problem
The initial VPC subnet configuration did not provide the required subnet coverage for the RDS DB subnet group.

### Resolution
The VPC was adjusted so the RDS subnet group had appropriate private subnets across Availability Zones.

### Lesson
AWS services have specific networking requirements. The subnets must satisfy the requirements of the service using them.

---

## 3. Understanding separate subnets for infrastructure

### Problem
There was confusion about why the ALB, EC2 instances, and RDS should not simply be placed into one subnet.

### Resolution
The architecture was separated into network layers:
* **ALB** in public subnets
* **EC2** in application subnets
* **RDS** in private database subnets

### Lesson
Subnets provide network-level separation and make routing and security rules easier to control.

---

## 4. Security group communication

### Problem
The application required communication between multiple AWS components, but each component needed different access rules.

### Resolution
Security groups were configured around the required traffic flow:

```text
Internet
   |
   v
ALB :80
   |
   v
EC2 :80
   |
   v
RDS :5432
```

The database does not need to be directly accessible from the internet.

### Lesson
Security groups should describe required communication paths rather than simply opening ports broadly.

---

## 5. ALB access and browser HTTPS behaviour

### Problem
The deployed ALB was reachable from the infrastructure, but browser access through Brave resulted in a timeout because the browser was attempting HTTPS while the configured ALB endpoint was HTTP.

### Resolution
The issue was identified as browser HTTPS-upgrade behaviour rather than an application or ALB backend failure.

### Lesson
When an HTTP service appears unreachable in a browser, verify whether the browser is automatically upgrading the request to HTTPS.

---

## 6. ALB health checks

### Problem
The ALB needed a reliable endpoint to determine whether an EC2 application instance was alive. Checking an endpoint that depends on the database would make the ALB consider an otherwise-running application unhealthy whenever the database was unavailable.

### Resolution
Two health endpoints were defined:
* `/live` — process/liveness check
* `/ready` — database readiness check

The ALB uses `/live`.

### Lesson
Liveness and readiness checks have different purposes and should not be treated as the same thing.

---

## 7. Understanding ALB failover

### Problem
The initial architecture description risked implying that the ALB itself provided full application and database failover.

### Correction
The ALB can perform health checks and stop sending traffic to unhealthy EC2 targets. It does not provide database failover. RDS remains a separate database layer.

### Lesson
Load balancing, application-instance redundancy, and database redundancy are different concepts.

---

## V2 Key Lessons

1. Multiple application instances need shared database infrastructure.
2. AWS subnet design should follow the requirements of each service.
3. Security groups should model actual traffic flows.
4. Liveness and readiness checks serve different purposes.
5. An ALB provides traffic distribution and health-based routing, not database failover.
