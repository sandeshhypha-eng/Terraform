# Workspaces Setup and Migration Guide

This document provides step-by-step instructions on converting from the directory-based setup to Terraform workspaces and how to deploy.

## 📁 New Directory Structure

```
Terraform/
├── main.tf                    # Root configuration (single, shared by all workspaces)
├── dev.tfvars                 # Dev environment variables
├── test.tfvars                # Test environment variables
├── prod.tfvars                # Prod environment variables
│
├── modules/
│   ├── ec2/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── s3/
│       ├── main.tf
│       └── variables.tf
│
├── terraform.tfstate          # Default workspace state
├── terraform.tfstate.d/       # Multi-workspace states (auto-created)
│   ├── dev/
│   │   └── terraform.tfstate
│   ├── test/
│   │   └── terraform.tfstate
│   └── prod/
│       └── terraform.tfstate
│
├── backup/                    # Original directories (for reference)
│   ├── dev/
│   ├── test/
│   └── prod/
│
├── README.md                  # General documentation
└── WORKSPACES_VS_DIRECTORIES.md
```

---

## 🚀 Quick Start (Workspaces)

### Step 1: Initialize Terraform

```bash
cd /Users/ma2301/Desktop/terraform/Terraform
terraform init
```

Output:
```
Initializing the backend...
Initializing modules...
- ec2 in modules/ec2
- s3 in modules/s3

Terraform has been successfully configured!
```

### Step 2: Create Workspaces

```bash
# Create dev workspace
terraform workspace new dev

# Create test workspace
terraform workspace new test

# Create prod workspace
terraform workspace new prod
```

Output:
```
Created and switched to workspace "dev"!
Created and switched to workspace "test"!
Created and switched to workspace "prod"!
```

### Step 3: Verify Workspaces

```bash
terraform workspace list
```

Output:
```
  default
* dev
  test
  prod
```

---

## 📡 Deployment Instructions

### Deploy to DEV Environment

```bash
# 1. Select dev workspace
terraform workspace select dev

# 2. Plan changes
terraform plan -var-file=dev.tfvars

# 3. Review the plan output

# 4. Apply changes
terraform apply -var-file=dev.tfvars

# When prompted, type: yes
```

**To auto-approve (for automation):**
```bash
terraform apply -var-file=dev.tfvars -auto-approve
```

### Deploy to TEST Environment

```bash
# 1. Select test workspace
terraform workspace select test

# 2. Plan changes
terraform plan -var-file=test.tfvars

# 3. Review the plan output

# 4. Apply changes
terraform apply -var-file=test.tfvars
```

### Deploy to PROD Environment

```bash
# 1. Select prod workspace
terraform workspace select prod

# 2. Plan changes
terraform plan -var-file=prod.tfvars

# 3. Review the plan output

# 4. Apply changes
terraform apply -var-file=prod.tfvars
```

---

## 🛠️ Common Workspace Commands

### Check Current Workspace

```bash
terraform workspace show
```

Output:
```
dev
```

### List All Workspaces

```bash
terraform workspace list
```

Output:
```
  default
* dev
  test
  prod
```

### Switch Between Workspaces

```bash
# Switch to test
terraform workspace select test

# Switch to prod
terraform workspace select prod

# Switch to dev
terraform workspace select dev
```

### View Resources in Current Workspace

```bash
terraform workspace select dev
terraform state list
```

Output:
```
module.ec2.aws_instance.demo_ec2
module.s3.aws_s3_bucket.demo_s3
module.s3.aws_s3_bucket_acl.example
module.s3.aws_s3_bucket_ownership_controls.example
module.s3.aws_s3_bucket_versioning.versioning_example
```

### Destroy Resources

```bash
# Destroy dev
terraform workspace select dev
terraform destroy -var-file=dev.tfvars

# Destroy test
terraform workspace select test
terraform destroy -var-file=test.tfvars

# Destroy prod
terraform workspace select prod
terraform destroy -var-file=prod.tfvars
```

---

## 📊 Complete Workflow Script

Create a file `deploy.sh`:

```bash
#!/bin/bash

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}

if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "test" ] && [ "$ENVIRONMENT" != "prod" ]; then
  echo "Invalid environment: $ENVIRONMENT"
  echo "Usage: ./deploy.sh {dev|test|prod} {plan|apply|destroy}"
  exit 1
fi

if [ "$ACTION" != "plan" ] && [ "$ACTION" != "apply" ] && [ "$ACTION" != "destroy" ]; then
  echo "Invalid action: $ACTION"
  echo "Usage: ./deploy.sh {dev|test|prod} {plan|apply|destroy}"
  exit 1
fi

echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"
echo "=========================================="

# Select workspace
terraform workspace select $ENVIRONMENT

# Perform action
case $ACTION in
  plan)
    echo "Planning changes for $ENVIRONMENT..."
    terraform plan -var-file=$ENVIRONMENT.tfvars
    ;;
  apply)
    echo "Applying changes to $ENVIRONMENT..."
    terraform apply -var-file=$ENVIRONMENT.tfvars -auto-approve
    echo "✅ Deployment complete!"
    ;;
  destroy)
    echo "⚠️  WARNING: About to destroy $ENVIRONMENT infrastructure!"
    read -p "Type 'destroy' to confirm: " confirm
    if [ "$confirm" = "destroy" ]; then
      terraform destroy -var-file=$ENVIRONMENT.tfvars -auto-approve
      echo "✅ Destroyed!"
    else
      echo "❌ Cancelled"
    fi
    ;;
esac

echo ""
echo "Current workspace: $(terraform workspace show)"
```

**Make it executable:**
```bash
chmod +x deploy.sh
```

**Usage:**
```bash
./deploy.sh dev plan      # Plan dev deployment
./deploy.sh dev apply     # Apply dev deployment
./deploy.sh test apply    # Apply test deployment
./deploy.sh prod apply    # Apply prod deployment
./deploy.sh dev destroy   # Destroy dev
```

---

## 📋 View Outputs

### Get outputs from current workspace

```bash
terraform workspace select dev
terraform output
```

Output:
```
instance_id = "i-0123456789abcdef0"
instance_public_ip = "203.0.113.45"
s3_bucket_name = "bucket-demo-terraform-hypha-dev"
```

### Get specific output

```bash
terraform output instance_id
```

Output:
```
i-0123456789abcdef0
```

### Get all outputs as JSON

```bash
terraform output -json
```

---

## 🔄 Deploy All Environments

### Deploy all at once

```bash
#!/bin/bash

for env in dev test prod; do
  echo ""
  echo "=========================================="
  echo "Deploying to $env..."
  echo "=========================================="
  
  terraform workspace select $env
  terraform plan -var-file=$env.tfvars -out=$env.tfplan
  
  read -p "Apply changes to $env? (yes/no): " confirm
  if [ "$confirm" = "yes" ]; then
    terraform apply $env.tfplan
    echo "✅ $env deployed successfully!"
  else
    echo "⏭️  Skipped $env"
  fi
done
```

---

## 🗂️ State Management

### View state for dev

```bash
terraform workspace select dev
terraform state show module.ec2.aws_instance.demo_ec2
```

### List resources in test

```bash
terraform workspace select test
terraform state list
```

### Refresh state

```bash
terraform workspace select dev
terraform refresh -var-file=dev.tfvars
```

### Pull remote state

```bash
terraform workspace select dev
terraform state pull
```

---

## 🔒 Backup and Restore

### Backup all workspaces

```bash
# Backup state files
tar -czf terraform-backup-$(date +%Y%m%d-%H%M%S).tar.gz terraform.tfstate*

# List backup
ls -lh terraform-backup-*.tar.gz
```

### Restore from backup

```bash
# Restore
tar -xzf terraform-backup-20260508-224000.tar.gz

# Verify
terraform workspace list
```

---

## ⚠️ Important Notes

1. **State Files**: Each workspace has its own state file in `terraform.tfstate.d/`
2. **Workspaces are local**: If using remote state, all workspaces share the same backend
3. **Always check workspace**: Run `terraform workspace show` before applying
4. **Use `-var-file`**: Always specify the correct `.tfvars` file for the workspace
5. **Backup before destroy**: Always backup state before destroying

---

## 🚨 Safety Checklist Before Deploy

```bash
# ✅ Check current workspace
terraform workspace show

# ✅ Check what will change
terraform plan -var-file=<env>.tfvars

# ✅ Confirm resources
terraform state list

# ✅ Review outputs
terraform output

# ✅ Then apply
terraform apply -var-file=<env>.tfvars
```

---

## Comparison: Before vs After

### Before (Directories)
```bash
cd dev
terraform init
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
cd ../test
terraform init
# ... repeat ...
```

### After (Workspaces) ✅ Simpler
```bash
terraform workspace select dev
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
terraform workspace select test
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

---

## Troubleshooting

### "Workspace not found"
```bash
# List existing workspaces
terraform workspace list

# Create missing workspace
terraform workspace new missing-env
```

### "Error acquiring the state lock"
```bash
# Remove lock file
rm .terraform.tfstate.lock.hcl

# Then retry
terraform plan
```

### "Module not found"
```bash
# Reinitialize
terraform init

# Or with upgrade
terraform init -upgrade
```

---

## Next Steps

1. ✅ Initialize workspaces (done)
2. 📋 Plan deployments: `terraform plan -var-file=dev.tfvars`
3. 🚀 Deploy to dev: `terraform apply -var-file=dev.tfvars`
4. 🧪 Test deployment
5. 📦 Deploy to test: `terraform apply -var-file=test.tfvars`
6. 🔐 Deploy to prod: `terraform apply -var-file=prod.tfvars`

---

**Happy Deploying! 🎉**