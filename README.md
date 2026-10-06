# URL Shortener - V1

A simple URL shortener built with **FastAPI, SQLite, and Docker**.

V1 focuses on building a working application with configuration, persistence, logging, testing, and containerization.

## Architecture

```text
Client
  |
  v
FastAPI
  |
  v
SQLite
```

## Features

* Create short URLs with `POST /shorten`
* Redirect with `GET /{code}`
* Database health check with `GET /health`
* SQLite persistence
* Environment-based configuration
* Application logging
* Automated tests with pytest
* Dockerized application

## Run Locally

```bash
uv sync
uv run uvicorn app.main:app --reload
```

Run tests:

```bash
uv run pytest
```

## Run with Docker

Build:

```bash
docker build -t urlshortener:v1 .
```

Run:

```bash
docker run --rm -p 8000:8000 --env-file .env urlshortener:v1
```

API docs:

```text
http://localhost:8000/docs
```

Health check:

```text
http://localhost:8000/health
```

## Current Limitations

V1 is designed for a **single application instance**.

* SQLite database is stored inside the container
* Multiple containers would have separate databases
* No load balancer or high availability
* No external database
* No monitoring or CI/CD

These limitations will drive the architecture of **V2**, where the focus will be reliability and running multiple application instances.

# URL Shortener - V2

A FastAPI-based URL shortener built to learn and progressively apply Docker, PostgreSQL, AWS, networking and load balancing.

## V1 → V2

### V1 — Basic Application

```text
FastAPI → SQLite
```

* FastAPI application
* SQLite database
* Dockerized locally
* Single application instance

### V2 — AWS Deployment

```text
                    Internet
                       |
                       v
                     ALB
                   /     \
                  v       v
               EC2 #1  EC2 #2
                  \       /
                   \     /
                    v   v
                  RDS PostgreSQL
```

V2 replaces the single-instance/local setup with a distributed AWS architecture.

### What changed?

| V1                | V2                          |
| ----------------- | --------------------------- |
| SQLite            | PostgreSQL on RDS           |
| Single instance   | Two EC2 instances           |
| Direct access     | Application Load Balancer   |
| Local database    | Shared database             |
| No failover       | Health-check based failover |
| Local environment | AWS VPC                     |

## V2 Features

* FastAPI + Docker
* PostgreSQL on Amazon RDS
* Two EC2 application instances
* Application Load Balancer
* ALB health checks using `/live`
* `/ready` endpoint for database connectivity
* Private subnets for RDS
* Security groups controlling ALB → EC2 → RDS traffic
* Failure recovery when one application instance becomes unavailable

## Example

Create a short URL:

```bash
curl -X POST http://<ALB-DNS>/shorten \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.google.com"}'
```

Response:

```json
{
  "short_url": "http://<ALB-DNS>/8",
  "code": "8"
}
```

The generated URL redirects to the original URL through the ALB.

## Future Improvements

* HTTPS + custom domain
* Terraform
* CI/CD with GitHub Actions
* Auto Scaling
* CloudWatch monitoring


# URL Shortener - V3

V3 adds **Infrastructure as Code, monitoring, container registry, and automated CI/CD deployment** to the V2 AWS architecture.

## V2 → V3

```text
                         GitHub
                            |
                            v
                     GitHub Actions
                            |
                       Build + Push
                            |
                            v
                           ECR
                            |
                    +-------+-------+
                    |               |
                    v               v
                 EC2 #1          EC2 #2
                    \               /
                     \             /
                      v           v
                         ALB
                          |
                          v
                    RDS PostgreSQL

        EC2 / ALB / RDS
               |
               v
          CloudWatch
               |
               v
              SNS
               |
               v
             Email
```

### What changed?

| V2                             | V3                        |
| ------------------------------ | ------------------------- |
| Manual AWS infrastructure      | Terraform                 |
| Manual Docker image deployment | ECR + GitHub Actions      |
| No centralized logging         | CloudWatch Logs           |
| No alerts                      | CloudWatch + SNS          |
| Manual application updates     | Automated EC2 deployment  |
| Docker images built locally    | Docker images built in CI |

## V3 Features

* AWS infrastructure managed with Terraform
* Amazon ECR for Docker images
* GitHub Actions CI/CD pipeline
* Automated deployment to both EC2 instances
* CloudWatch centralized system logs
* CloudWatch alarms for EC2, ALB and RDS
* SNS email notifications
* IAM roles for EC2 and CI/CD access
* Automated `/live` health check after deployment

## CI/CD Flow

```text
git push
   |
   v
GitHub Actions
   |
   +-- Build Docker image
   |
   +-- Push to ECR
   |
   +-- Deploy to EC2 #1
   |
   +-- Health check
   |
   +-- Deploy to EC2 #2
   |
   +-- Health check
```

## Infrastructure

Terraform manages:

* VPC and subnets
* Route tables and Internet Gateway
* Security groups
* EC2 instances
* RDS PostgreSQL
* Application Load Balancer
* Target groups and listeners
* CloudWatch logging and alarms
* SNS
* ECR
* IAM

## Current Architecture

```text
Internet
    |
    v
   ALB
  /   \
 v     v
EC2   EC2
 \     /
  \   /
   RDS
```

Monitoring and deployment are handled separately through **CloudWatch/SNS** and **GitHub Actions/ECR**.

## Future Improvements

* HTTPS + custom domain
* Auto Scaling
* Rolling/blue-green deployments
* Application-level CloudWatch logs
* CloudWatch dashboard
* Better secret management
* Remote Terraform state

