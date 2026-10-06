## Step 1: Build the infrastructure

```bash
cd terraform
terraform apply        # type "yes", takes ~5-10 min (RDS is the slow part)
```

This reuses your existing `terraform.tfvars`. If you get an AMI error, check that file for trailing spaces.

## Step 2: Create a new access key

```bash
aws iam create-access-key --user-name urlshortener-github-actions
```

Copy `AccessKeyId` and `SecretAccessKey` immediately. The secret is shown only once.

```bash
gh secret set AWS_ACCESS_KEY_ID --body "AKIA...your new id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your new secret"
```

If you skip this, the workflow fails on its first step with a credentials error.

## Step 3: Update the variables and `DATABASE_URL`

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

## Step 4: Wait for the servers, then check SSH

The servers install Docker on first boot. Wait about 3 minutes, then:

```bash
ssh -i urlshortner.pem ubuntu@<app_1_public_ip> "docker --version && aws --version"
```

Two version lines mean the servers are ready. If you get a host key warning (AWS can reuse an old IP), run `ssh-keygen -R <that ip>` and retry.

## Step 5: Deploy

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

## Step 6: Verify

```bash
ALB=$(cd terraform && terraform output -raw alb_dns_name)

curl http://$ALB/live
curl http://$ALB/ready
curl -X POST http://$ALB/shorten -H "Content-Type: application/json" -d '{"url":"https://www.google.com"}'
```

Allow 1-2 minutes after the deploy for the ALB health checks to mark both targets healthy. A `502` before that is normal.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Workflow fails at "Configure AWS credentials" | Step 2 skipped, or key pasted wrong |
| Deploy step times out on SSH | Servers not ready yet, or `EC2_1_IP` / `EC2_2_IP` still hold old IPs |
| `/ready` returns 503 | `DATABASE_URL` points at the old, destroyed database |
| `/live` works but `/ready` fails | Same as above |

## Checklist

1. `terraform apply`
2. `aws iam create-access-key ...`, then `gh secret set AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
3. `gh variable set EC2_1_IP` / `EC2_2_IP` / `ALB_DNS`
4. `gh secret set DATABASE_URL`
5. Wait ~3 min, then run the SSH test
6. `gh run rerun` (or push an empty commit)
7. `curl` `/live`, `/ready`, `/shorten`
