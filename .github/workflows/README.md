# GitHub Actions Workflows for Terraform Deployment

This directory contains GitHub Actions workflows for automated Terraform deployment across different environments (dev, prod, release) with support for dev-a and dev-b variants.

## Workflows Overview

### 1. **deploy.yml** - Main Deployment Workflow
Handles Terraform plan and apply operations with environment selection.

**Trigger:** Manual (`workflow_dispatch`)

**Features:**
- Select environment: dev, prod, or release
- When deploying to dev, choose between dev-a or dev-b
- Automatic Terraform format validation
- Plan approval before apply
- Outputs terraform results to job summary

**Usage:**
1. Go to GitHub Actions → "Terraform Deploy"
2. Click "Run workflow"
3. Select the environment
4. If dev, select dev variant (dev-a or dev-b)
5. Review the plan and approve apply

### 2. **destroy.yml** - Resource Destruction Workflow
Safely destroys Terraform-managed infrastructure with confirmation requirement.

**Trigger:** Manual (`workflow_dispatch`)

**Features:**
- Select environment: dev, prod, or release
- When destroying dev, choose between dev-a or dev-b
- Requires typing "DESTROY" to confirm
- Prevents accidental infrastructure deletion

**Usage:**
1. Go to GitHub Actions → "Terraform Destroy"
2. Click "Run workflow"
3. Select the environment
4. If dev, select dev variant
5. Type "DESTROY" in confirmation field
6. Confirm

### 3. **validate.yml** - Validation and Linting Workflow
Automatically validates Terraform configurations on pull requests and pushes.

**Trigger:**
- On pull request to main
- On push to main
- Only runs when Terraform files change

**Features:**
- Terraform format validation
- Terraform syntax validation
- TFLint for best practices
- Checkov for security scanning
- Runs dev-a and dev-b plan simulations

**Status:** Runs automatically, no manual trigger needed

## Setup Instructions

### Prerequisites

1. **AWS Credentials** stored as GitHub Secrets
2. **S3 Bucket** for Terraform state (already configured in your setup)
3. **GitHub Repository** with this workflow

### Step 1: Configure AWS Credentials in GitHub

1. Go to your GitHub repository settings
2. Navigate to **Secrets and variables** → **Actions**
3. Add these repository secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

For security best practices:
- Use an IAM user with minimal required permissions
- Consider using temporary credentials
- Rotate keys regularly

### Step 2: Create Environment Protection Rules (Optional but Recommended)

To require approvals for production deployments:

1. Go to **Environments** in repository settings
2. Create environments:
   - `dev`
   - `prod`
   - `release`
3. For `prod` environment, add required reviewers
4. Optionally add deployment branches restriction

### Step 3: Configure Backend State

The workflows use your existing S3 backend configuration:
- **Bucket:** `git-hpha-terraform-state`
- **Region:** `us-east-1`
- **Encryption:** Enabled

Ensure this bucket exists and your AWS credentials have permissions:
- `s3:GetObject`
- `s3:PutObject`
- `s3:DeleteObject`
- `s3:ListBucket`

## Workflow Details

### Deploy Workflow: Step by Step

1. **Terraform Plan** Job:
   - Checks out code
   - Initializes Terraform
   - Validates formatting
   - Runs `terraform plan` with appropriate `.tfvars`
   - Uploads plan as artifact
   - (Optional) Posts plan summary to PR

2. **Terraform Apply** Job:
   - Downloads plan artifact
   - Runs `terraform apply` with auto-approval
   - Outputs final terraform outputs
   - Displays in GitHub job summary

3. **Notify** Job:
   - Summarizes deployment status
   - Confirms environment and variant deployed

### Environment Variable Files

**dev-a.tfvars:**
- Environment: `dev-a`
- VPC CIDR: `10.3.0.0/16`
- Instance type: `t2.micro`

**dev-b.tfvars:**
- Environment: `dev-b`
- VPC CIDR: `10.4.0.0/16`
- Instance type: `t2.small`

## Workflow Inputs

### Deploy Workflow

| Input | Description | Options | Required |
|-------|-------------|---------|----------|
| `environment` | Target environment | dev, prod, release | Yes |
| `dev_variant` | Dev variant (dev only) | dev-a, dev-b | No (only for dev) |

### Destroy Workflow

| Input | Description | Options | Required |
|-------|-------------|---------|----------|
| `environment` | Target environment | dev, prod, release | Yes |
| `dev_variant` | Dev variant (dev only) | dev-a, dev-b | No (only for dev) |
| `confirm_destroy` | Confirmation token | Must be "DESTROY" | Yes |

## Security Considerations

1. **Branch Protection:** Require pull request reviews before merging
2. **Environment Approval:** Set reviewers for production environments
3. **Secret Management:** Never commit secrets; use GitHub Secrets
4. **IAM Permissions:** Use least-privilege IAM policies
5. **Audit:** Review workflow run logs for changes
6. **State Locking:** S3 native locking prevents concurrent modifications

## Troubleshooting

### Workflow fails with "invalid backend"

**Solution:** Remove `-backend=false` from init if state backend is not configured locally

### AWS credentials not found

**Solution:** Verify secrets are properly configured in repository settings

### Plan artifact not found

**Solution:** Ensure plan step completed successfully before apply

### Terraform format validation fails

**Solution:** Run locally: `terraform fmt -recursive environments/`

## Monitoring and Notifications

You can enhance these workflows with:
- Slack notifications (add `slack-notify-action`)
- Email notifications
- Custom webhooks
- GitHub status checks

## Best Practices

1. **Always Review Plans:** Look at `terraform plan` output before applying
2. **Test in Dev First:** Deploy to dev before prod
3. **Use Variants:** Use dev-a/dev-b to test different configurations
4. **Keep State Secure:** Never expose `terraform.tfstate` files
5. **Document Changes:** Use descriptive commit messages
6. **Version Control:** Track all changes in git
7. **Plan Before Apply:** Review changes thoroughly

## Quick Reference

### Deploy to dev-a
```
Workflow: Terraform Deploy
Environment: dev
Dev Variant: dev-a
```

### Deploy to dev-b
```
Workflow: Terraform Deploy
Environment: dev
Dev Variant: dev-b
```

### Deploy to prod
```
Workflow: Terraform Deploy
Environment: prod
Dev Variant: (not used)
```

### Destroy dev-a
```
Workflow: Terraform Destroy
Environment: dev
Dev Variant: dev-a
Confirm: DESTROY
```

## Support

For issues or questions:
1. Check workflow logs in GitHub Actions
2. Review Terraform error messages
3. Verify AWS credentials and permissions
4. Ensure S3 backend is accessible
