Real Enterprise Improvements

Production-grade pipelines usually add:

1. Remote Backend

S3 backend + DynamoDB lock.

2. Separate Workspaces
terraform workspace select dev
3. Security Scan

Using:

tfsec
checkov
4. PR Plan Comments

Terraform plan posted automatically to pull request.

5. Manual Approval for Prod

Using GitHub Environments.

6. OIDC Instead of Access Keys

Current pipeline uses:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

Modern secure approach:

GitHub OIDC → Assume IAM Role

No static secrets.