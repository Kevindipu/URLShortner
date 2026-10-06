# URL Shortener — V2 Setup Guide

This guide explains how to deploy the URL Shortener application to AWS using an EC2 instance and Amazon RDS PostgreSQL.

---

## 1. Prerequisites

Install:

* AWS account
* AWS CLI
* Docker
* Git

Verify the tools:

```bash
aws --version
docker --version
git --version
```

Configure the AWS CLI:

```bash
aws configure
```

Verify your AWS identity:

```bash
aws sts get-caller-identity
```

---

## 2. V2 Architecture

V2 moves the application from the local environment to AWS.

```text
             Internet
                 |
                 v
          EC2 Instance
          Docker App
                 |
                 v
          RDS PostgreSQL
```

The EC2 instance runs the FastAPI application inside Docker.

Amazon RDS hosts the PostgreSQL database.

---

## 3. AWS Infrastructure

The V2 deployment uses:

* VPC
* Public subnet
* Internet Gateway
* Route table
* EC2 instance
* Security groups
* RDS PostgreSQL

The EC2 instance requires network access to the RDS database.

The RDS database should not be publicly accessible.

---

## 4. Configure the Database

Create the PostgreSQL database in Amazon RDS.

Collect the following information:

```text
RDS endpoint
Database name
Username
Password
Port
```

The default PostgreSQL port is:

```text
5432
```

---

## 5. Configure the Application

On the EC2 instance, create a `.env` file:

```env
DATABASE_URL=postgresql://<username>:<password>@<rds-endpoint>:5432/<database>
```

Do not commit this file to GitHub.

---

## 6. Connect to EC2

Use SSH to connect to the EC2 instance:

```bash
ssh -i <key-file>.pem <user>@<EC2-public-ip>
```

Clone the repository:

```bash
git clone <repository-url>
cd URLShortener
```

---

## 7. Build the Docker Image

Build the application image on EC2:

```bash
docker build -t urlshortener:v2 .
```

---

## 8. Run the Application

Start the container:

```bash
docker run -d \
  --name urlshortener \
  -p 8000:8000 \
  --env-file .env \
  urlshortener:v2
```

Check that the container is running:

```bash
docker ps
```

---

## 9. Check Application Logs

View the application logs:

```bash
docker logs urlshortener
```

Follow the logs:

```bash
docker logs -f urlshortener
```

---

## 10. Access the Application

Use the EC2 public IP:

```text
http://<EC2-public-ip>:8000
```

Swagger API documentation:

```text
http://<EC2-public-ip>:8000/docs
```

Health check:

```text
http://<EC2-public-ip>:8000/health
```

---

## 11. Test the API

Create a shortened URL:

```bash
curl -X POST http://<EC2-public-ip>:8000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.google.com"}'
```

Check the health endpoint:

```bash
curl http://<EC2-public-ip>:8000/health
```

---

## 12. Troubleshooting

Check the running container:

```bash
docker ps
```

Check container logs:

```bash
docker logs urlshortener
```

Check the EC2 security group and make sure port `8000` is accessible if the application is being accessed directly.

For database connection problems, verify:

* RDS is available
* RDS security group allows PostgreSQL traffic from EC2
* Database credentials are correct
* RDS endpoint is correct
* Port `5432` is accessible from EC2

---

## 13. Stopping the Application

Stop the container:

```bash
docker stop urlshortener
```

Remove the container:

```bash
docker rm urlshortener
```

---

## 14. AWS Cleanup

When the V2 deployment is no longer required, remove the AWS resources created for the project.

Check and remove:

* EC2 instance
* RDS database
* Elastic IP, if used
* Other VPC resources created specifically for the project

> **Important:** RDS can continue generating costs even when the application is not being used. Make sure billable AWS resources are stopped or deleted when they are no longer required.

---

## 15. Project Documentation

* [V1 — Application](V1.md)
* [V2 — AWS Deployment](V2.md)
* [V3 — Infrastructure & CI/CD](V3.md)

The root [README](../README.md) provides an overview of the complete project.
