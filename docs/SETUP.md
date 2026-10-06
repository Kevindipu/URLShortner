# URL Shortener — Setup Guide

This guide explains how to run the URL Shortener locally, with Docker, and how to deploy the V3 infrastructure to AWS.

## Prerequisites

### Local Development

Install:

* Python 3.x
* [uv](https://docs.astral.sh/uv/)
* Docker
* Git

### AWS Deployment

For V3 deployment, you also need:

* AWS account
* AWS CLI
* Terraform
* GitHub account
* An AWS IAM identity with permissions required by the Terraform configuration

Verify the tools:

```bash
python --version
uv --version
docker --version
aws --version
terraform --version
git --version
```

---

# 1. Clone the Repository

```bash
git clone <repository-url>
cd URLShortener
```

---

# 2. Configure Environment Variables

Create a `.env` file in the project root.

The required variables depend on the application configuration.

Example:

```env
DATABASE_URL=sqlite:///./urlshortener.db
```

For V2/V3, PostgreSQL configuration is used instead.

Example:

```env
DATABASE_URL=postgresql://<username>:<password>@<host>:5432/<database>
```

Do not commit `.env` files containing passwords, database credentials, or other secrets.

The repository should contain an appropriate `.gitignore` entry for:

```text
.env
```

---

# 3. Install Dependencies

Install the project dependencies with uv:

```bash
uv sync
```

---

# 4. Run Locally

Start the FastAPI development server:

```bash
uv run uvicorn app.main:app --reload
```

The application will be available at:

```text
http://localhost:8000
```

API documentation:

```text
http://localhost:8000/docs
```

Health check:

```text
http://localhost:8000/health
```

---

# 5. Run Tests

Run the complete test suite:

```bash
uv run pytest
```

The test suite should pass before creating a deployment.

---

# 6. Run with Docker

Build the Docker image:

```bash
docker build -t urlshortener:v1 .
```

Run the container:

```bash
docker run --rm \
  -p 8000:8000 \
  --env-file .env \
  urlshortener:v1
```

Open:

```text
http://localhost:8000/docs
```

---

# 7. AWS Configuration

V3 uses Terraform to create the AWS infrastructure.

Configure the AWS CLI before deploying.

For example:

```bash
aws configure
```

Verify that your AWS credentials work:

```bash
aws sts get-caller-identity
```

Make sure the returned account and identity are the ones you intend to use.

---

# 8. Terraform

Navigate to the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Review the infrastructure changes:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Review the proposed resources and confirm the deployment when prompted.

Terraform creates the AWS resources defined by the project configuration.

---

# 9. Infrastructure Created by Terraform

Depending on the current Terraform configuration, the deployment includes resources such as:

```text
VPC
├── Public Subnets
│   ├── Application Load Balancer
│   └── EC2 instances
│
└── Private Subnets
    └── RDS PostgreSQL
```

Additional infrastructure includes:

* Internet Gateway
* Route tables
* Security groups
* IAM roles
* ECR repository
* CloudWatch resources
* SNS resources
* Target groups
* ALB listener

---

# 10. Database Configuration

The RDS database requires credentials.

Database credentials should be supplied through Terraform variables or another secure configuration mechanism used by the project.

Do not commit database passwords or other secrets to Git.

If the project uses a Terraform variable file containing secrets, ensure it is excluded from version control.

For example:

```text
terraform.tfvars
*.tfvars
```

---

# 11. GitHub Actions

V3 uses GitHub Actions to automate application deployment.

The general workflow is:

```text
Git push
   |
   v
GitHub Actions
   |
   +-- Run tests
   |
   +-- Build Docker image
   |
   +-- Push image to ECR
   |
   +-- Deploy EC2 #1
   |
   +-- Health check
   |
   +-- Deploy EC2 #2
   |
   +-- Health check
```

The workflow requires the AWS authentication/configuration expected by the repository's GitHub Actions workflow.

Before running the pipeline, configure the required GitHub repository secrets or variables.

Check:

```text
.github/workflows/
```

for the exact names currently required by the workflow.

Do not commit AWS access keys, passwords, private keys, or other secrets to the repository.

---

# 12. Deploying a New Application Version

After making application changes:

```bash
git add .
git commit -m "Update application"
git push
```

GitHub Actions then:

1. Runs the tests.
2. Builds the Docker image.
3. Pushes the image to ECR.
4. Deploys the new image to EC2 #1.
5. Performs a health check.
6. Deploys the new image to EC2 #2.
7. Performs a health check.

Check the **Actions** tab in GitHub to monitor the workflow.

---

# 13. Accessing the Application

After the AWS infrastructure is deployed, retrieve the Application Load Balancer DNS name from AWS or Terraform output.

The application can then be accessed through:

```text
http://<ALB-DNS>
```

API documentation:

```text
http://<ALB-DNS>/docs
```

Health check:

```text
http://<ALB-DNS>/live
```

Readiness check:

```text
http://<ALB-DNS>/ready
```

Example request:

```bash
curl -X POST http://<ALB-DNS>/shorten \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.google.com"}'
```

---

# 14. Checking the Deployment

Verify the application through the ALB:

```bash
curl http://<ALB-DNS>/live
```

The ALB should route traffic to a healthy EC2 instance.

You can also check:

* EC2 instance status
* ALB target health
* RDS status
* CloudWatch metrics
* GitHub Actions deployment status

---

# 15. Destroying the AWS Infrastructure

The AWS infrastructure is not intended to run continuously.

When the project is no longer needed, destroy the resources:

```bash
cd terraform
terraform destroy
```

Review the resources that will be deleted and confirm the operation.

This helps avoid unnecessary AWS costs.

> **Important:** `terraform destroy` removes the resources managed by the Terraform configuration. Make sure you understand the resources being destroyed before confirming.

---

# 16. Recommended Development Workflow

For normal application development:

```text
1. Make code changes
        ↓
2. Run tests
        ↓
3. Run locally
        ↓
4. Build Docker image
        ↓
5. Commit changes
        ↓
6. Push to GitHub
        ↓
7. GitHub Actions
        ↓
8. Deploy to AWS
        ↓
9. Health check
```

For infrastructure changes:

```text
1. Modify Terraform
        ↓
2. terraform fmt
        ↓
3. terraform validate
        ↓
4. terraform plan
        ↓
5. Review changes
        ↓
6. terraform apply
```

---

# 17. Project Documentation

For more information about the architecture and development progression:

* [V1 — Application](V1.md)
* [V2 — AWS Deployment](V2.md)
* [V3 — Infrastructure & CI/CD](V3.md)

The root [README](../README.md) provides an overview of the complete project.
