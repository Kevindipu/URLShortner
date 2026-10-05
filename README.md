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


