# GitHub Actions Workflow Architecture

## Deployment Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPER WORKFLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Create Branch & Make Changes                                │
│     ↓                                                            │
│     git checkout -b feature/add-resources                       │
│     (edit environments/dev/main.tf or modules/*)                │
│     git push origin feature/add-resources                       │
│                                                                 │
│  2. Create Pull Request                                         │
│     ↓                                                            │
│     [On GitHub] Click "Create Pull Request"                     │
│                                                                 │
│  3. Automatic Validation (validate.yml triggers)               │
│     ├─ Terraform format check ✓                                │
│     ├─ Syntax validation ✓                                     │
│     ├─ TFLint best practices ✓                                 │
│     ├─ Checkov security scan ✓                                 │
│     ├─ Dev-a plan simulation ✓                                 │
│     └─ Dev-b plan simulation ✓                                 │
│                                                                 │
│  4. Code Review & Approval                                      │
│     ↓                                                            │
│     [On GitHub] Team reviews and approves                       │
│                                                                 │
│  5. Merge to Main                                               │
│     ↓                                                            │
│     [On GitHub] Click "Merge pull request"                      │
│                                                                 │
│  6. Manual Deployment                                           │
│     ↓                                                            │
│     Go to: Actions → "Terraform Deploy" → "Run workflow"        │
│     Select environment & dev variant if needed                  │
│     Click "Run workflow"                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Deploy Workflow Execution

```
┌──────────────────────────────────────────────────────────────┐
│            TERRAFORM DEPLOY WORKFLOW (deploy.yml)            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ INPUT: Select Environment ─────────────────────────┐   │
│  │ Environment: [dev / prod / release]                 │   │
│  │ Dev Variant: [dev-a / dev-b] (if dev selected)     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│         ↓                                                    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ JOB 1: TERRAFORM PLAN                               │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Step 1: Checkout code                              │   │
│  │  Step 2: Setup Terraform 1.0                        │   │
│  │  Step 3: Configure AWS credentials                  │   │
│  │  Step 4: Determine environment path                 │   │
│  │          └─ dev-a.tfvars or dev-b.tfvars if dev   │   │
│  │          └─ terraform.tfvars if prod/release       │   │
│  │  Step 5: Terraform Init                             │   │
│  │  Step 6: Format Check                               │   │
│  │  Step 7: Terraform Plan                             │   │
│  │  Step 8: Upload Plan Artifact                       │   │
│  │  Step 9: Post Plan to PR (if PR)                    │   │
│  │                                                      │   │
│  │  OUTPUT: tfplan artifact                            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│         ↓ (wait for approval)                              │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ JOB 2: TERRAFORM APPLY                              │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Requires: Plan job success                         │   │
│  │                                                      │   │
│  │  Step 1: Checkout code                              │   │
│  │  Step 2: Setup Terraform 1.0                        │   │
│  │  Step 3: Configure AWS credentials                  │   │
│  │  Step 4: Determine environment path                 │   │
│  │  Step 5: Download Plan Artifact                     │   │
│  │  Step 6: Terraform Init                             │   │
│  │  Step 7: Terraform Apply (auto-approve)             │   │
│  │  Step 8: Display Terraform Outputs                  │   │
│  │                                                      │   │
│  │  OUTPUT: AWS resources created/updated              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│         ↓                                                    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ JOB 3: NOTIFY                                        │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  Status: ✅ Success or ❌ Failed                    │   │
│  │  Environment: dev/prod/release                      │   │
│  │  Variant: dev-a/dev-b (if applicable)              │   │
│  │  Triggered by: github.actor                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
│  ✅ DEPLOYMENT COMPLETE                                     │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Environment Selection Logic

```
┌──────────────────────────────────────┐
│ User Selects Environment              │
└──────────┬───────────────────────────┘
           │
           ├─ dev ──────────────┬─ dev-a? ──→ Path: environments/dev
           │                    │             VarFile: dev-a.tfvars
           │                    └─ dev-b? ──→ Path: environments/dev
           │                                  VarFile: dev-b.tfvars
           │
           ├─ prod ──────────────────────→ Path: environments/prod
           │                               VarFile: terraform.tfvars
           │
           └─ release ───────────────────→ Path: environments/release
                                           VarFile: terraform.tfvars
```

## File Structure

```
Terraform/
│
├── .github/
│   ├── workflows/
│   │   ├── deploy.yml          ← Main deployment workflow (205 lines)
│   │   ├── destroy.yml         ← Destruction workflow (89 lines)
│   │   ├── validate.yml        ← Validation workflow (104 lines)
│   │   └── README.md           ← Workflow documentation
│   │
│   ├── PULL_REQUEST_TEMPLATE.md ← PR guidance with deployment steps
│   └── workflows-setup.md       ← Setup instructions & troubleshooting
│
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   ├── dev-a.tfvars         ← Dev variant A configuration
│   │   └── dev-b.tfvars         ← Dev variant B configuration
│   │
│   ├── prod/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars
│   │
│   └── release/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
│
├── modules/
│   ├── network/
│   ├── security/
│   ├── instances/
│   └── alb/
│
├── README.md
├── DEPLOYMENT_GUIDE.md           ← Quick reference guide
├── SETUP_CHECKLIST.md            ← Step-by-step setup
└── setup-verify.sh              ← Verification script
```

## Data Flow: Dev-a Deployment

```
┌─────────────────────────────────────────────────────────────┐
│ GITHUB ACTIONS: Deploy to Dev-a                             │
└─────────────────────────────────────────────────────────────┘

GitHub Actions UI
      ↓
   (User Input)
   Environment: dev
   Dev Variant: dev-a
      ↓
┌─ Environment Path Resolution ──────────────────────────┐
│ path = environments/dev                                 │
│ tfvars_file = dev-a.tfvars                             │
│ display_env = dev-a                                    │
└────────────────────┬──────────────────────────────────┘
                     ↓
            AWS Credentials (from Secrets)
            AWS_ACCESS_KEY_ID
            AWS_SECRET_ACCESS_KEY
                     ↓
┌─ Terraform Execution (environments/dev) ──────────────┐
│ terraform init                                          │
│ terraform plan -var-file="dev-a.tfvars" -out=tfplan   │
│ terraform apply tfplan                                 │
└────────────────────┬──────────────────────────────────┘
                     ↓
            AWS API Calls (authenticated)
                     ↓
┌─ AWS Resources Created ────────────────────────────────┐
│ VPC: dev-a-vpc (10.3.0.0/16)                          │
│ Subnets: dev-a-public-subnet-1 & 2                    │
│ Security Groups: dev-a-alb-sg, dev-a-ec2-sg          │
│ EC2 Instances: 2x t2.micro                             │
│ ALB: dev-a-web-alb                                     │
│ All tagged with: environment=dev-a                     │
└────────────────────┬──────────────────────────────────┘
                     ↓
        S3 State File Updated
        (S3://git-hpha-terraform-state/)
                     ↓
            GitHub Actions Summary
            ✅ Deployment Complete
            ALB DNS: dev-a-web-alb-xxx.us-east-1.elb.amazonaws.com
```

## Destroy Workflow Flow

```
┌──────────────────────────────────────────────────────────────┐
│            TERRAFORM DESTROY WORKFLOW (destroy.yml)          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ INPUT: Confirm Destruction ──────────────────────────┐  │
│  │ Environment: [dev / prod / release]                   │  │
│  │ Dev Variant: [dev-a / dev-b] (if dev)               │  │
│  │ Confirmation: [Type "DESTROY" to confirm]            │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│         ↓                                                    │
│                                                              │
│  ┌─ Validate Destroy Request ────────────────────────────┐  │
│  │ Is confirmation == "DESTROY"?                         │  │
│  │ YES → Continue                                        │  │
│  │ NO  → ABORT (Safety feature!)                         │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│         ↓                                                    │
│                                                              │
│  ┌─ Destroy Resources ───────────────────────────────────┐  │
│  │ Initialize Terraform                                 │  │
│  │ Run: terraform destroy -var-file=... -auto-approve   │  │
│  │ AWS Resources Deleted:                               │  │
│  │   • EC2 Instances                                    │  │
│  │   • Load Balancer                                    │  │
│  │   • Security Groups                                  │  │
│  │   • Subnets                                          │  │
│  │   • VPC                                              │  │
│  │   • And all related resources                        │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│         ↓                                                    │
│                                                              │
│  ✅ DESTRUCTION COMPLETE                                    │
│     All resources have been removed                         │
│     State file updated in S3                                │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Environment Comparison

```
┌────────────────┬──────────┬──────────┬──────────┬──────────┐
│ Aspect         │ Dev-a    │ Dev-b    │ Release  │ Prod     │
├────────────────┼──────────┼──────────┼──────────┼──────────┤
│ VPC CIDR       │10.3.0.0  │10.4.0.0  │10.1.0.0  │10.2.0.0  │
│ Instance Type  │t2.micro  │t2.small  │t2.small  │t2.medium │
│ Purpose        │ Minimal  │ Testing  │ Staging  │ Prod     │
│ Cost           │ Low      │ Medium   │ Medium   │ High     │
│ Instances      │ 2x       │ 2x       │ 2x       │ 2x       │
│ Approval       │ None     │ None     │ Optional │ Required │
│ State Lock     │ S3       │ S3       │ S3       │ S3       │
└────────────────┴──────────┴──────────┴──────────┴──────────┘
```

## State Management

```
GitHub Actions Workflow
       ↓
Configure AWS Credentials
       ↓
Terraform Init
       ↓
Load State from S3
       ├─ Bucket: git-hpha-terraform-state
       ├─ Key: terraformv2/environments/{dev|prod|release}/terraform.tfstate
       └─ Lock: S3 Native Locking (prevents concurrent access)
       ↓
Terraform Plan/Apply/Destroy
       ↓
Update State in S3
       └─ Encrypted at rest
       └─ Versioning enabled
       └─ Lock released after operation
       ↓
GitHub Actions Logs
```

---

## Summary

- **Deploy Workflow:** Plan → Review → Apply (3 jobs)
- **Destroy Workflow:** Validate confirmation → Destroy (2 jobs)
- **Validate Workflow:** Format, Lint, Security (automatic)
- **Dev Support:** Choose between dev-a (t2.micro) or dev-b (t2.small)
- **State Management:** Centralized in S3 with locking
- **Security:** Secrets stored in GitHub, permissions via IAM
