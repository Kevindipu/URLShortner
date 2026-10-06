# URL Shortener

A containerized URL shortener built with **FastAPI** and progressively deployed from a local application to an AWS-based architecture with **Terraform, CI/CD, and monitoring**.

The project was developed incrementally to demonstrate the evolution from a simple application to a distributed and automated cloud deployment.

## Architecture Evolution

```text
V1
FastAPI → SQLite → Docker
```

A simple, containerized URL shortener with local persistence, configuration, logging, and automated tests.

```text
V2

                         Internet
                            |
                            v
                           ALB
                         /     \
                        v       v
                     EC2 #1   EC2 #2
                        \       /
                         \     /
                          v   v
                       RDS PostgreSQL
```

The application was moved to AWS with multiple application instances, an Application Load Balancer, and a shared PostgreSQL database.

```text
V3

                         GitHub
                            |
                            v
                     GitHub Actions
                            |
                     Build + Test
                            |
                            v
                           ECR
                         /     \
                        v       v
                     EC2 #1   EC2 #2
                        \       /
                         \     /
                          v   v
                       RDS PostgreSQL

                    CloudWatch + SNS
                         Monitoring
```

V3 adds Infrastructure as Code, container image management, automated deployment, centralized monitoring, and alerting.

## Project Versions

| Version | Focus                              | Technologies                                         |
| ------- | ---------------------------------- | ---------------------------------------------------- |
| **V1**  | Application & containerization     | FastAPI, SQLite, Docker, pytest                      |
| **V2**  | AWS deployment & availability      | AWS VPC, EC2, ALB, RDS, PostgreSQL                   |
| **V3**  | Infrastructure & DevOps automation | Terraform, ECR, GitHub Actions, CloudWatch, SNS, IAM |

### V1 — Application

A locally runnable FastAPI application using SQLite and Docker.

**Focus:**

* REST API development
* Database persistence
* Configuration
* Logging
* Automated testing
* Containerization

[Read the V1 documentation](docs/V1.md)

### V2 — AWS Deployment

The application was redesigned to run across multiple EC2 instances behind an Application Load Balancer with PostgreSQL hosted on Amazon RDS.

**Focus:**

* AWS networking
* VPC and subnet design
* Security groups
* Load balancing
* Database separation
* Health checks

[Read the V2 documentation](docs/V2.md)

### V3 — Infrastructure & CI/CD

The AWS infrastructure was converted to Terraform and application deployment was automated using GitHub Actions and Amazon ECR.

**Focus:**

* Infrastructure as Code
* Docker image publishing
* CI/CD
* IAM
* CloudWatch monitoring
* SNS alerting
* Automated deployment and health checks

[Read the V3 documentation](docs/V3.md)

## Technology Stack

**Application**

* Python
* FastAPI
* PostgreSQL
* pytest

**Containerization**

* Docker

**AWS**

* EC2
* VPC
* Application Load Balancer
* RDS PostgreSQL
* ECR
* CloudWatch
* SNS
* IAM

**Infrastructure & CI/CD**

* Terraform
* GitHub Actions

## Setup

See the [Setup Guide](docs/SETUP.md) for instructions on:

* Running the application locally
* Running the application with Docker
* Running tests
* Configuring environment variables
* Deploying the AWS infrastructure
* Configuring CI/CD
* Destroying the AWS infrastructure
