# Workspaces Quick Reference

## 🎯 One-Liner Deploy Commands

### DEV
```bash
cd /Users/ma2301/Desktop/terraform/Terraform && terraform workspace select dev && terraform apply -var-file=dev.tfvars -auto-approve
```

### TEST
```bash
cd /Users/ma2301/Desktop/terraform/Terraform && terraform workspace select test && terraform apply -var-file=test.tfvars -auto-approve
```

### PROD
```bash
cd /Users/ma2301/Desktop/terraform/Terraform && terraform workspace select prod && terraform apply -var-file=prod.tfvars -auto-approve
```

---

## 📋 Step-by-Step Deployment

### Initial Setup (One-time)
```bash
cd /Users/ma2301/Desktop/terraform/Terraform
terraform init
terraform workspace new dev
terraform workspace new test
terraform workspace new prod
```

### Deploy Flow

```bash
# 1. SELECT WORKSPACE
terraform workspace select dev

# 2. PLAN
terraform plan -var-file=dev.tfvars

# 3. APPLY
terraform apply -var-file=dev.tfvars
```

**Repeat for test and prod**

---

## 🔍 Useful Commands Quick List

| Command | Purpose |
|---------|---------|
| `terraform workspace list` | Show all workspaces |
| `terraform workspace show` | Show current workspace |
| `terraform workspace select dev` | Switch to dev workspace |
| `terraform plan -var-file=dev.tfvars` | Preview changes |
| `terraform apply -var-file=dev.tfvars` | Deploy infrastructure |
| `terraform destroy -var-file=dev.tfvars` | Destroy infrastructure |
| `terraform state list` | List resources in current workspace |
| `terraform output` | Show outputs from current workspace |

---

## 🚀 Full Deployment Cycle

```bash
cd /Users/ma2301/Desktop/terraform/Terraform

# DEV
terraform workspace select dev
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars

# TEST
terraform workspace select test
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars

# PROD
terraform workspace select prod
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

---

## ⚠️ Important: Always Check Your Workspace!

```bash
# ✅ BEFORE applying anything, check:
terraform workspace show
```

**Output should match your intended environment:**
- `dev` → Use `dev.tfvars`
- `test` → Use `test.tfvars`
- `prod` → Use `prod.tfvars`

---

## 📁 Key Files

| File | Purpose |
|------|---------|
| `main.tf` | Root configuration (shared by all workspaces) |
| `dev.tfvars` | Dev environment variables |
| `test.tfvars` | Test environment variables |
| `prod.tfvars` | Prod environment variables |
| `modules/ec2/` | EC2 module |
| `modules/s3/` | S3 module |
| `terraform.tfstate.d/` | State files directory |

---

## 🎯 Environment Details

### DEV
- **Region**: us-east-1
- **Instance Type**: t3.micro
- **Bucket**: bucket-demo-terraform-hypha-dev

### TEST
- **Region**: eu-west-1
- **Instance Type**: t3.micro
- **Bucket**: bucket-demo-terraform-hypha-test

### PROD
- **Region**: ap-southeast-2
- **Instance Type**: t3.micro
- **Bucket**: bucket-demo-terraform-hypha-prod

---

## 🔄 Common Workflows

### Deploy All Three Environments

```bash
#!/bin/bash
for env in dev test prod; do
  terraform workspace select $env
  terraform apply -var-file=$env.tfvars -auto-approve
  echo "✅ $env deployed"
done
```

### Destroy All Environments

```bash
#!/bin/bash
for env in dev test prod; do
  terraform workspace select $env
  terraform destroy -var-file=$env.tfvars -auto-approve
  echo "✅ $env destroyed"
done
```

### Plan All Before Deploying

```bash
#!/bin/bash
for env in dev test prod; do
  echo "=== PLANNING $env ==="
  terraform workspace select $env
  terraform plan -var-file=$env.tfvars
done
```

---

## 📊 Current Workspace States

To see resources in each workspace:

```bash
# DEV
terraform workspace select dev
terraform state list

# TEST
terraform workspace select test
terraform state list

# PROD
terraform workspace select prod
terraform state list
```

---

## 🆘 Quick Troubleshooting

### Wrong workspace selected?
```bash
terraform workspace select correct-env
```

### Want to see what's in prod?
```bash
terraform workspace select prod
terraform plan -var-file=prod.tfvars
```

### Forgot which workspace you're in?
```bash
terraform workspace show
```

### Need to destroy everything?
```bash
# Dev
terraform workspace select dev
terraform destroy -var-file=dev.tfvars -auto-approve

# Then repeat for test and prod
```

---

## 📝 Pro Tips

1. **Always prefix with workspace check**
   ```bash
   echo "Current workspace: $(terraform workspace show)"
   terraform plan -var-file=dev.tfvars
   ```

2. **Use aliases for common commands**
   ```bash
   alias tf='terraform'
   alias tfws='terraform workspace show'
   ```

3. **Never apply without plan first**
   ```bash
   terraform plan -var-file=dev.tfvars  # Review first!
   terraform apply -var-file=dev.tfvars
   ```

4. **Backup state regularly**
   ```bash
   tar -czf terraform-backup.tar.gz terraform.tfstate*
   ```

---

## 🎓 Learning Path

1. Start with **dev**: `terraform workspace select dev && terraform apply -var-file=dev.tfvars`
2. Then **test**: `terraform workspace select test && terraform apply -var-file=test.tfvars`
3. Finally **prod**: `terraform workspace select prod && terraform apply -var-file=prod.tfvars`

**You're now using Workspaces! 🎉**