# URL Shortener

A URL shortener built with **FastAPI and Docker**, progressively developed from a local application into an AWS-based deployment with **Terraform, CI/CD, and monitoring**.

**Current version: V3**

![Python](https://img.shields.io/badge/Python-3776AB?logo=python\&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?logo=fastapi\&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker\&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?logo=amazonaws\&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?logo=terraform\&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions\&logoColor=white)

---

## Architecture

### Runtime

```text
                    Internet
                       │
                       ▼
                  ┌─────────┐
                  │   ALB   │
                  └────┬────┘
                       │
                 ┌─────┴─────┐
                 ▼           ▼
            ┌─────────┐ ┌─────────┐
            │  EC2 #1 │ │  EC2 #2 │
            │ FastAPI │ │ FastAPI │
            └────┬────┘ └────┬────┘
                 │           │
                 └─────┬─────┘
                       ▼
                ┌──────────────┐
                │ RDS PostgreSQL│
                └──────────────┘
```

### Deployment

```text
GitHub
   │
   ▼
GitHub Actions
   │
   ├── Test
   ├── Build
   └── Push
        │
        ▼
       ECR
        │
        ├────────► EC2 #1
        │
        └────────► EC2 #2
```

### Monitoring

```text
EC2 ───┐
ALB ───┼──► CloudWatch ──► SNS ──► Email
RDS ───┘
```

Terraform manages the AWS infrastructure, while GitHub Actions handles testing, image builds, and deployment.

---

## Project Evolution

| Version | Focus                              | Main Technologies                               |
| ------- | ---------------------------------- | ----------------------------------------------- |
| **V1**  | Application & containerization     | FastAPI, SQLite, Docker, pytest                 |
| **V2**  | AWS deployment & availability      | VPC, EC2, ALB, RDS, PostgreSQL                  |
| **V3**  | Infrastructure & DevOps automation | Terraform, ECR, GitHub Actions, CloudWatch, SNS |

### V1 — Application

Started as a single-container FastAPI application using SQLite.

* REST API for creating and resolving short URLs
* SQLite persistence
* Configuration and logging
* Automated tests
* Docker

[View V1 documentation →](docs/V1.md)

### V2 — AWS

The application was redesigned to support multiple application instances.

* Two EC2 application instances
* Application Load Balancer
* PostgreSQL on RDS
* VPC and subnet architecture
* Security groups
* Application health checks

[View V2 documentation →](docs/V2.md)

### V3 — DevOps

Infrastructure and deployment were automated.

* Terraform-managed AWS infrastructure
* Docker images stored in ECR
* GitHub Actions CI/CD
* Automated deployment to EC2
* CloudWatch monitoring and alarms
* SNS email notifications

[View V3 documentation →](docs/V3.md)

---

## Tech Stack

**Backend:** Python, FastAPI, PostgreSQL
**Cloud:** AWS EC2, ALB, RDS, ECR, VPC
**Infrastructure:** Terraform
**CI/CD:** GitHub Actions
**Containerization:** Docker
**Monitoring:** CloudWatch, SNS
**Testing:** pytest

---

## Run Locally

Install dependencies:

```bash
uv sync
```

Start the application:

```bash
uv run uvicorn app.main:app --reload
```

Run tests:

```bash
uv run pytest
```

Run with Docker:

```bash
docker build -t urlshortener:v1 .
docker run --rm -p 8000:8000 --env-file .env urlshortener:v1
```

API documentation:

```text
http://localhost:8000/docs
```

For the complete local and AWS setup:

[Setup Guide →](docs/SETUP.md)

---

## Repository Structure

```text
URLShortener/
├── app/                  # FastAPI application
├── tests/                # Automated tests
├── terraform/            # AWS infrastructure
├── .github/workflows/    # CI/CD pipeline
├── docs/                 # Project documentation
├── Dockerfile
├── pyproject.toml
└── README.md
```

---

## Documentation

* [V1 — Application & Docker](docs/V1.md)
* [V2 — AWS Deployment](docs/V2.md)
* [V3 — Infrastructure & DevOps](docs/V3.md)
* [Setup Guide](docs/SETUP.md)

---

## Author

**Kevin Thomas**
MSc Data Analytics · Universität Hildesheim

Interested in **Cloud, DevOps, Data Engineering and Software Engineering**.
