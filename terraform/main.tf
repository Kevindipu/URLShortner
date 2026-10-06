# ============================================================
# URL Shortener - Infrastructure Overview
# ============================================================
#
# This Terraform project provisions the AWS infrastructure
# required to run the URL Shortener application.
#
# Terraform automatically loads all .tf files in this folder.
# main.tf is intentionally used only for documentation.
#
#
# INFRASTRUCTURE FLOW
# -------------------
#
#                         Internet
#                            |
#                            | HTTP :80
#                            v
#                    +---------------+
#                    |      ALB      |
#                    +-------+-------+
#                            |
#                    HTTP :80
#                            |
#                 +----------+----------+
#                 |                     |
#                 v                     v
#          +-------------+       +-------------+
#          |   EC2 App 1 |       |   EC2 App 2 |
#          +------+------+       +------+------+
#                 |                     |
#                 +----------+----------+
#                            |
#                       PostgreSQL :5432
#                            |
#                            v
#                     +-------------+
#                     |     RDS     |
#                     |  PostgreSQL |
#                     +-------------+
#
#
# AWS RESOURCES
# -------------
#
# networking.tf
#   - VPC
#   - Public/private subnets
#   - Internet Gateway
#   - Route tables
#   - NAT Gateway (if configured)
#
# security-groups.tf
#   - ALB security group
#   - Application/EC2 security group
#   - Database security group
#
# compute.tf
#   - EC2 App 1
#   - EC2 App 2
#   - EC2 instance configuration
#   - user_data.sh (if referenced by the EC2 resources)
#
# loadbalancer.tf
#   - Application Load Balancer
#   - Target Group
#   - HTTP Listener
#   - EC2 Target Group Attachments
#
# database.tf
#   - RDS PostgreSQL instance
#   - Database subnet group
#
# ecr.tf
#   - ECR repository
#   - Docker image storage
#
# iam.tf
#   - EC2 IAM role
#   - EC2 instance profile
#   - ECR permissions
#   - GitHub Actions IAM user
#
# logging.tf
#   - CloudWatch Log Group
#
# monitoring.tf
#   - SNS topic
#   - EC2 CPU alarms
#   - ALB health alarm
#   - RDS CPU alarm
#   - Email notification subscription
#
#
# DEPLOYMENT FLOW
# ---------------
#
# 1. Terraform creates the VPC and networking.
#
# 2. Terraform creates the security groups.
#
# 3. Terraform creates the ECR repository and IAM resources.
#
# 4. Terraform creates the RDS PostgreSQL database.
#
# 5. Terraform creates the EC2 application servers.
#    EC2 user_data.sh performs the required startup configuration.
#
# 6. Terraform creates the Application Load Balancer,
#    target group and listener.
#
# 7. EC2 instances are registered with the ALB target group.
#
# 8. CloudWatch logging and monitoring resources are created.
#
#
# TRAFFIC FLOW
# ------------
#
# User
#   |
#   | HTTP :80
#   v
# ALB
#   |
#   | HTTP :80
#   v
# EC2 application container
#   |
#   | PostgreSQL :5432
#   v
# RDS PostgreSQL
#
#
# SECURITY FLOW
# -------------
#
# Internet
#    |
#    | :80
#    v
# ALB Security Group
#    |
#    | :80
#    v
# App Security Group
#    |
#    | :5432
#    v
# DB Security Group
#
# ============================================================