# V1 — Issues & Troubleshooting

This document records the main issues encountered while building and running the local V1 version of the URL Shortener.

## 1. SQLite persistence inside Docker

### Problem
The V1 application used SQLite. When the SQLite database is stored inside the container filesystem, the database is tied to that container.

### Why it matters
Removing or recreating the container can remove the database contents.

### Resolution
V1 was kept as a simple local-development version using SQLite. Persistent PostgreSQL storage was introduced later for the AWS version.

### Lesson
Containerized applications should not rely on the container filesystem for persistent production data.

---

## 2. Environment configuration

### Problem
The application depends on environment variables, and the configuration needed to remain consistent between local development, Docker, and later AWS deployment.

Important settings include:
- `DATABASE_URL`
- `LOG_LEVEL`
- `LOG_FILE`
- `BASE_URL`
- `SHORT_CODE_ALPHABET`

### Resolution
An `.env.example` file was used to document the required configuration without committing real credentials.

### Lesson
Application configuration should be externalized from the code and kept consistent across environments.

---

## 3. Logging configuration

### Problem
The application supports file-based logging, so the configured `LOG_FILE` location must be writable by the running process.

### Resolution
The logging path was explicitly configured through the environment.

### Lesson
Anything that writes to disk inside a container needs a valid and writable filesystem path.

---

## 4. Local application and Docker validation

### Problem
The application needed to work reliably both directly through the local Python environment and when containerized.

### Resolution
The application was tested locally with Uvicorn and then packaged into Docker while keeping the application configuration externalized.

### Lesson
It is useful to validate the application locally before introducing cloud infrastructure. This makes it easier to separate application problems from infrastructure problems.

---

## V1 Key Lessons

1. Containers are not persistent storage.
2. Keep application configuration outside the source code.
3. Make logging paths explicit and writable.
4. Validate the application locally before introducing cloud infrastructure.
