# GitHub Actions Setup Guide

This guide helps you set up the GitHub Actions workflows for Terraform deployment.

## 1. Configure Repository Secrets

Go to: **Settings → Secrets and variables → Actions → Repository secrets**

Add the following secrets:

### Required Secrets

```
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
```

### How to Generate AWS Credentials

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Click "Users" in the sidebar
3. Create a new user or select existing one
4. Click "Create access key"
5. Select "Command Line Interface (CLI)"
6. Copy the Access Key ID and Secret Access Key
7. Add them as GitHub Secrets

### Recommended IAM Policy

For security, use this IAM policy instead of full admin:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "iam:PassRole",
        "iam:GetRole",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::git-hpha-terraform-state",
        "arn:aws:s3:::git-hpha-terraform-state/*"
      ]
    }
  ]
}
```

## 2. Set Up Environments (Optional but Recommended)

Go to: **Settings → Environments**

Create three environments:

### Environment 1: dev
- No special settings needed
- Can be deployed by any contributor

### Environment 2: release
- Set "Deployment branches" to `main` only
- Add required reviewers if desired

### Environment 3: prod
- Set "Deployment branches" to `main` only
- Add 1-2 required reviewers
- Set a deployment timeout (e.g., 24 hours)

## 3. Configure Branch Protection Rules (Optional)

Go to: **Settings → Branches → Add branch protection rule**

For branch `main`:

- ✅ Require a pull request before merging
- ✅ Require status checks to pass
- ✅ Include administrators
- ✅ Restrict who can push to matching branches

## 4. Verify S3 Backend Access

Test that your AWS credentials can access the state bucket:

```bash
aws s3 ls s3://git-hpha-terraform-state --region us-east-1
```

Should show:
```
PRE terraformv2/
```

## 5. First-Time Setup Verification

1. Go to **Actions** tab in your GitHub repository
2. You should see three workflows:
   - Terraform Deploy
   - Terraform Destroy
   - Terraform Validate

3. Make a small change to a Terraform file and push to a branch
4. Create a pull request
5. The "Terraform Validate" workflow should run automatically

## Workflow File Locations

All workflows are in: `.github/workflows/`

```
.github/
├── workflows/
│   ├── deploy.yml          # Main deployment workflow
│   ├── destroy.yml         # Destruction workflow
│   ├── validate.yml        # Validation workflow
│   └── README.md           # Workflow documentation
├── PULL_REQUEST_TEMPLATE.md # PR template
└── workflows-setup.md      # This file
```

## Testing Your Setup

### Test 1: Validate Workflow

1. Create a new branch
2. Make a minor edit to any file in `environments/` or `modules/`
3. Commit and push
4. Create a pull request
5. Check that "Terraform Validate" runs and passes

### Test 2: Deployment to Dev-a

1. Go to **Actions** → **Terraform Deploy**
2. Click **Run workflow**
3. Keep default: Environment = `dev`, Dev Variant = `dev-a`
4. Click **Run workflow**
5. Monitor the job execution
6. Verify resources are created in AWS

### Test 3: Deployment to Dev-b

1. Go to **Actions** → **Terraform Deploy**
2. Click **Run workflow**
3. Select: Environment = `dev`, Dev Variant = `dev-b`
4. Click **Run workflow**
5. Verify different configuration is deployed

## Troubleshooting

### "Error: error reading S3 Bucket"

**Cause:** AWS credentials don't have S3 access
**Fix:** Check IAM policy includes S3 permissions and bucket name is correct

### "Error: No valid AWS credentials"

**Cause:** Secrets not configured
**Fix:** Go to Settings → Secrets → Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set

### "Error: Terraform validation failed"

**Cause:** Invalid Terraform syntax
**Fix:** Run locally: `terraform validate` in the environment directory

### Workflow runs but takes 10+ minutes

This is normal. First run includes setup time. Subsequent runs are faster.

## Workflow Behavior Summary

| Workflow | Trigger | Actions | Needs AWS |
|----------|---------|---------|-----------|
| validate.yml | PR/Push | Format check, validate, lint | No |
| deploy.yml | Manual | Plan + Apply | Yes |
| destroy.yml | Manual | Destroy all resources | Yes |

## Environment Status

To check what's deployed in each environment:

```bash
# Dev-a resources
aws ec2 describe-vpcs --filter "Name=tag:Name,Values=dev-a-vpc" --region us-east-1

# Dev-b resources
aws ec2 describe-vpcs --filter "Name=tag:Name,Values=dev-b-vpc" --region us-east-1

# Release resources
aws ec2 describe-vpcs --filter "Name=tag:Name,Values=release-vpc" --region us-east-1

# Prod resources
aws ec2 describe-vpcs --filter "Name=tag:Name,Values=prod-vpc" --region us-east-1
```

## Next Steps

1. ✅ Add AWS credentials as secrets
2. ✅ Create GitHub Environments
3. ✅ Set branch protection rules
4. ✅ Test validation workflow
5. ✅ Test deployment to dev-a
6. ✅ Test deployment to dev-b
7. ✅ Deploy to release/prod as needed

## Support Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
- [Terraform State Management](https://www.terraform.io/language/state)
