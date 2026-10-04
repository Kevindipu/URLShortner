# URL Shortener — V1

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


