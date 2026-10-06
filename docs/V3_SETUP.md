## Step 1: Create a new AWS access key

Create a new access key for the IAM user used by GitHub Actions:

```bash
aws iam create-access-key --user-name urlshortener-github-actions
```

The output will contain:

```text
AccessKeyId
SecretAccessKey
```

Copy both values immediately.

> **Important:** The `SecretAccessKey` is only shown once.

---

## Step 2: Upload the AWS credentials to GitHub

Set the new credentials as GitHub Actions secrets:

```bash
gh secret set AWS_ACCESS_KEY_ID --body "AKIA...your-new-id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-new-secret"
```
---

## Step 3: Create the EC2 key pair

Create the AWS EC2 key pair that Terraform will use for SSH access.

```bash
aws ec2 create-key-pair \
  --key-name urlshortener \
  --region eu-north-1 \
  --query 'KeyMaterial' \
  --output text > urlshortner.pem
```

## Step 4: Get the latest Ubuntu AMI ID

Before running Terraform, retrieve the latest Ubuntu 24.04 Noble AMI for `eu-north-1`.

Run:

```bash
aws ec2 describe-images \
  --region eu-north-1 \
  --owners 099720109477 \
  --filters \
    "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
    "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' \
  --output table
```

Update the AMI value in your `terraform.tfvars`:

```hcl
ami_id = "ami-0769f265f707fecc8"
```

> AMI IDs are region-specific and change over time. Always check the latest AMI before recreating the infrastructure.

---

## Step 5: Initialize Terraform

Move into the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Terraform will initialize the providers and configure the backend.

Check the configuration:

```bash
terraform validate
```

You should see:

```text
Success! The configuration is valid.
```

---

## Step 6: Create the AWS infrastructure

Run:

```bash
terraform apply
```

Review the planned resources and type:

```text
yes
```

Terraform will create the infrastructure, including:

* VPC
* Public/private subnets
* Internet/NAT networking
* Security groups
* EC2 instances
* RDS PostgreSQL
* Application Load Balancer
* Target groups
* ECR repository
* CloudWatch resources
* SNS resources

RDS is usually the slowest part of the deployment, so the complete process can take several minutes.


## Step 7: Update the variables and `DATABASE_URL`

Still in `terraform/`:

```bash
gh variable set EC2_1_IP --body "$(terraform output -raw app_1_public_ip)"
gh variable set EC2_2_IP --body "$(terraform output -raw app_2_public_ip)"
gh variable set ALB_DNS  --body "$(terraform output -raw alb_dns_name)"

gh secret set DATABASE_URL --body "postgresql://postgres:YOURPASSWORD@$(terraform output -raw db_endpoint):5432/urlshortener"
cd ..
```

Replace `YOURPASSWORD` with the `db_password` from your `terraform.tfvars`.

Check the result:

```bash
gh variable list
gh secret list
```

Expected:
- 3 variables: `ALB_DNS`, `EC2_1_IP`, `EC2_2_IP`
- 4 secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DATABASE_URL`, `EC2_SSH_PRIVATE_KEY`

## Step 8: Wait for the servers, then check SSH

The servers install Docker on first boot. Wait about 3 minutes, then:

```bash
ssh -i urlshortner.pem ubuntu@<app_1_public_ip> "docker --version && aws --version"
```

Two version lines mean the servers are ready. If you get a host key warning (AWS can reuse an old IP), run `ssh-keygen -R <that ip>` and retry.

## Step 9: Deploy

No code change is needed. Either re-run the last workflow:

```bash
gh run list --limit 1
gh run rerun <run-id>
```

or push an empty commit:

```bash
git commit --allow-empty -m "Redeploy"
git push origin main
```

The pipeline builds the image, pushes it to the fresh ECR repo, and deploys to both servers.

## Step 10: Verify

```bash
ALB=$(cd terraform && terraform output -raw alb_dns_name)

curl http://$ALB/live
curl http://$ALB/ready
curl -X POST http://$ALB/shorten -H "Content-Type: application/json" -d '{"url":"https://www.google.com"}'
```

Allow 1-2 minutes after the deploy for the ALB health checks to mark both targets healthy. A `502` before that is normal.
