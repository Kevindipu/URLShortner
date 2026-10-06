# V3 — Issues & Troubleshooting

This document records the main issues encountered while adding Terraform, ECR, GitHub Actions, monitoring, and automated deployment to the AWS URL Shortener.

## 1. Terraform state management

**Problem**

The AWS infrastructure required persistent Terraform state so Terraform could track resources across runs.

**Resolution**

An S3 backend was used for Terraform state.

**Lesson**

Terraform state should be managed separately from the local development machine when infrastructure needs to persist across runs.

---

## 2. Terraform configuration across multiple files

**Problem**

There was confusion about whether every Terraform resource needed to be defined in `main.tf`.

**Resolution**

Terraform automatically loads all `.tf` files in the same module directory. An empty `main.tf` is valid if resources are defined elsewhere.

**Lesson**

Terraform files are organizational boundaries for humans; Terraform evaluates the configuration as a module.

---

## 3. Terraform `user_data`

**Problem**

There was uncertainty about whether a `user_data.sh` file would automatically run when Terraform created an EC2 instance.

**Resolution**

The script must explicitly be passed to the EC2 resource, for example:

```hcl
user_data = file("${path.module}/user_data.sh")
```

Simply having the shell script in the Terraform directory does not execute it.

**Lesson**

Files in a Terraform directory are not automatically executed or referenced.

---

## 4. ECR and EC2 deployment flow

**Problem**

The deployment architecture needed a reliable way to move the Docker image from GitHub Actions to the EC2 instances.

**Resolution**

The deployment flow became:

```text
GitHub
   |
   v
GitHub Actions
   |
   v
Docker image
   |
   v
Amazon ECR
   |
   v
EC2
```

The EC2 instances pull the image from ECR and run the application container.

**Lesson**

A container registry provides a stable handoff point between CI and the runtime infrastructure.

---

## 5. GitHub Actions deployment and EC2 public IPs

**Problem**

The GitHub Actions workflow uses hardcoded EC2 public IP addresses.

If the EC2 instances are destroyed and recreated, their public IPs can change.

**Resolution**

The current setup intentionally keeps the hardcoded IP approach for the project. The workflow must be updated whenever the instances are recreated.

**Lesson**

Ephemeral cloud resources should ideally be referenced dynamically rather than through manually maintained IP addresses.

---

## 6. EC2 SSH access

**Problem**

SSH access was opened broadly during deployment to allow GitHub Actions to connect to the EC2 instances.

**Risk**

This exposes SSH to the internet.

**Resolution**

The security configuration was reviewed with the goal of restricting SSH access rather than leaving port 22 publicly open.

**Lesson**

Temporary convenience rules such as unrestricted SSH should be removed or restricted once deployment is working.

---

## 7. Application port mapping

**Problem**

The application runs FastAPI/Uvicorn on port `8000`, while the external AWS architecture exposes port `80`.

**Resolution**

The traffic path became:

```text
ALB :80
   |
   v
EC2 :80
   |
   v
Docker container :8000
```

The EC2 host forwards traffic to the container.

**Lesson**

Always distinguish between the public/load-balancer port, host port, and container port.

---

## 8. Database environment configuration in CI/CD

**Problem**

The application requires `DATABASE_URL`, but the value differs between local development and AWS.

**Resolution**

The AWS deployment supplies the database connection through environment configuration rather than hardcoding it into the application.

**Lesson**

The same application image should be deployable to different environments using different configuration values.

---

## 9. `BASE_URL` configuration

**Problem**

The application generates shortened URLs and therefore needs to know the externally accessible base URL.

The internal container or EC2 address is not necessarily the URL users should receive.

**Resolution**

`BASE_URL` is configured independently from the application code so it can point to the externally accessible deployment URL.

**Lesson**

Public application URLs should be configuration, not hardcoded application logic.

---

## 10. CI/CD container replacement

**Problem**

The deployment workflow stops/removes the existing container before starting the new version.

**Impact**

There can be a short interruption during deployment.

**Resolution**

The workflow was kept simple for the project: pull the new image, stop/remove the old container, and start the new container.

**Lesson**

This demonstrates CI/CD deployment, but it is not a zero-downtime deployment strategy.

---

## 11. Monitoring architecture

**Problem**

The first architecture diagram mixed application traffic, CI/CD, monitoring, and AWS infrastructure into one flow, making it difficult to understand.

**Resolution**

The architecture was separated conceptually into three flows.

**Runtime**

```text
Internet
   |
  ALB
   |
EC2 #1 / EC2 #2
   |
  RDS
```

**Deployment**

```text
GitHub
   |
GitHub Actions
   |
  ECR
   |
 EC2
```

**Monitoring**

```text
EC2 / ALB / RDS
       |
  CloudWatch
       |
      SNS
       |
     Email
```

**Lesson**

Architecture diagrams should distinguish traffic flow, deployment flow, and monitoring/alerting flow.

---

## 12. CloudWatch and SNS responsibilities

**Problem**

There was potential confusion between monitoring and notification.

**Resolution**

The responsibilities were separated:

- CloudWatch collects and monitors AWS metrics and logs.
- SNS handles notification delivery.

**Lesson**

Monitoring and alerting are related but separate responsibilities.

---

## 13. Keeping the existing test suite

**Problem**

There was a question of whether the existing `tests/` directory should be removed or rewritten as part of the deployment work.

**Resolution**

The `tests/` folder was intentionally kept. The existing test structure includes FastAPI `TestClient` tests such as the health endpoint test.

**Lesson**

Infrastructure changes should not require removing application tests that are still valid.

---

## V3 Key Lessons

1. Terraform state must be managed deliberately.
2. Terraform automatically evaluates all `.tf` files in a module.
3. `user_data` must be explicitly attached to an EC2 resource.
4. ECR provides a clean handoff between CI and EC2.
5. Hardcoded EC2 IPs are fragile when instances can be recreated.
6. SSH should not remain unnecessarily open to the internet.
7. Docker, EC2, and ALB ports are separate layers.
8. Configuration should be environment-driven.
9. CI/CD does not automatically mean zero-downtime deployment.
10. CloudWatch and SNS have different monitoring and notification roles.
11. Runtime, deployment, and monitoring flows should be shown separately in architecture diagrams.
12. Infrastructure limitations should be documented honestly.
