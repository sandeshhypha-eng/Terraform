# Production Approval Workflow - Visual Guide

## 🎯 Approval Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│           TERRAFORM DEPLOY WORKFLOW (PRODUCTION)                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Developer Click: "Run workflow"                                │
│  ├─ Select Environment: prod                                   │
│  └─ Click: "Run workflow"                                      │
│                                                                 │
│         ↓                                                       │
│                                                                 │
│  ┌─ JOB 1: TERRAFORM PLAN ─────────────────────────────────┐   │
│  │  ✓ Checkout code                                         │   │
│  │  ✓ Setup Terraform                                       │   │
│  │  ✓ Configure AWS                                         │   │
│  │  ✓ Terraform init                                        │   │
│  │  ✓ Terraform plan                                        │   │
│  │  ✓ Save plan artifact                                    │   │
│  │  ✓ Show what will change                                 │   │
│  │                                                          │   │
│  │  ⏱️ Time: ~5 minutes                                      │   │
│  │  📊 Output: Ready for review                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│         ↓                                                       │
│                                                                 │
│  ⏸️ ┌─ JOB 2: APPROVAL (NEW!) ──────────────────────────────┐   │
│     │                                                       │   │
│     │  This job waits for lead approval                     │   │
│     │                                                       │   │
│     │  Status: "Waiting for approval"                       │   │
│     │                                                       │   │
│     │  ┌─────────────────────────────────────────────────┐  │   │
│     │  │                                                 │  │   │
│     │  │ GitHub shows: "Approval Required"               │  │   │
│     │  │ Your lead gets notification                     │  │   │
│     │  │                                                 │  │   │
│     │  │ Lead reviews the plan                           │  │   │
│     │  │ (What resources will be added/modified/deleted) │  │   │
│     │  │                                                 │  │   │
│     │  │ Lead clicks one of two buttons:                 │  │   │
│     │  │  ✅ "Approve and deploy"                        │  │   │
│     │  │  ❌ "Reject"                                    │  │   │
│     │  │                                                 │  │   │
│     │  └─────────────────────────────────────────────────┘  │   │
│     │                                                       │   │
│     │  ⏱️ Time: Depends on lead (usually 5-30 min)         │   │
│     │                                                       │   │
│     └───────────────┬─────────────────────────────────────┘   │
│                     │                                          │
│          ┌──────────┴──────────┐                              │
│          │                     │                              │
│    ✅ APPROVED          ❌ REJECTED                           │
│          │                     │                              │
│          ↓                     ↓                              │
│                                                               │
│  ┌─ JOB 3A: TERRAFORM APPLY ──┐    ┌─ JOB 3B: REJECTED ───┐ │
│  │  (only if APPROVED)         │    │  ✓ Notify rejected  │ │
│  │                             │    │  ✓ No changes made  │ │
│  │  ✓ Download plan            │    │  ✓ Workflow ends    │ │
│  │  ✓ Terraform apply          │    │                     │ │
│  │  ✓ Create resources in AWS  │    │  ❌ STATUS: FAILED  │ │
│  │  ✓ Show outputs             │    │                     │ │
│  │                             │    └─────────────────────┘ │
│  │  ✓ STATUS: SUCCESS          │                             │
│  └─────────────────────────────┘                             │
│                                                               │
│         ↓                                                     │
│                                                               │
│  ┌─ JOB 4: NOTIFICATION ───────────────────────────────────┐ │
│  │  Show final status:                                      │ │
│  │                                                          │ │
│  │  If Approved & Applied:                                 │ │
│  │  ✅ Success                                              │ │
│  │  Environment: prod                                       │ │
│  │  Status: Deployment completed successfully              │ │
│  │                                                          │ │
│  │  If Rejected:                                            │ │
│  │  ❌ Failed                                                │ │
│  │  Environment: prod                                       │ │
│  │  Status: Deployment rejected by lead                     │ │
│  │                                                          │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                               │
│  🎉 WORKFLOW COMPLETE                                        │
│                                                               │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Comparison: Before vs After

### BEFORE (Old Way)

```
Developer triggers
    ↓
Plan runs
    ↓
Apply runs automatically
    ↓
PRODUCTION UPDATED (no review!)
    ↓
Problem discovered after deployment
    ↓
Rollback needed
```

### AFTER (New Way)

```
Developer triggers
    ↓
Plan runs
    ↓
⏸️ WAITS FOR APPROVAL
    ↓
Lead reviews changes
    ↓
Lead approves/rejects
    ↓
If approved → Apply runs
If rejected → Nothing happens
    ↓
PRODUCTION SAFELY UPDATED (after review!)
```

---

## 🔄 Decision Tree

```
Developer runs workflow with prod environment
        ↓
    ┌───┴───┐
    │       │
   YES     NO
    │       │
 Prod?   Dev/Release?
    │       │
    ↓       ↓
 APPROVAL  AUTO-APPLY
 REQUIRED  NO WAIT
    ↓       ↓
 WAIT FOR  TERRAFORM
 LEAD      APPLIES
 APPROVAL  NOW
    │       │
    ├───┬───┤
    │   │   │
  ✅ ❌ ✅
 APPR REJC APPL
  │    │    │
  ↓    ↓    ↓
 APPL STOP  COMPL
  │    │    │
  ↓    ↓    ↓
COMPL FAIL SUCCESS
  │    │
  ↓    ↓
SUCCESS FAILED
```

---

## 👤 Lead Approval Steps

```
┌─────────────────────────────────────┐
│    LEAD RECEIVES NOTIFICATION       │
│  "Approval required for prod"       │
└──────────────┬──────────────────────┘
               ↓
       ┌───────────────┐
       │ Click link    │
       │ to GitHub     │
       └───────┬───────┘
               ↓
    ┌──────────────────────┐
    │ View workflow run    │
    │ Status: Waiting      │
    └──────────┬───────────┘
               ↓
    ┌──────────────────────────┐
    │ Expand terraform_plan    │
    │ Review what will change: │
    │ • Resources to add: 2    │
    │ • Resources to modify: 1 │
    │ • Resources to delete: 0 │
    └──────────┬───────────────┘
               ↓
    ┌──────────────────────────┐
    │ Make decision            │
    │                          │
    │ ┌────────────┐ ┌───────┐ │
    │ │ Approve?   │ │Review?│ │
    │ └────┬───────┘ └───────┘ │
    │      │                    │
    └──────┼────────────────────┘
           ↓
       ┌───┴────┐
       │        │
      ✅        ❌
      │        │
      ↓        ↓
   APPROVE  REJECT
      │        │
      ↓        ↓
   APPLY    STOP
      │        │
      ↓        ↓
  SUCCESS   FAILED
```

---

## 📈 Timeline Examples

### Scenario 1: Fast Approval (5 minutes)

```
10:00 → Developer triggers prod deployment
10:05 → Plan completes, waiting for approval
10:10 → Lead approves (5 minute wait)
10:15 → Apply starts
10:20 → Apply completes
10:20 → Deployment done! ✅

Total time: 20 minutes
```

### Scenario 2: Slow Approval (30 minutes)

```
14:00 → Developer triggers prod deployment
14:05 → Plan completes, waiting for approval
14:35 → Lead approves (30 minute wait)
14:40 → Apply starts
14:45 → Apply completes
14:45 → Deployment done! ✅

Total time: 45 minutes
```

### Scenario 3: Rejection

```
09:00 → Developer triggers prod deployment
09:05 → Plan completes, waiting for approval
09:10 → Lead reviews and rejects
09:10 → Deployment stops, no changes made ❌

Total time: 10 minutes (no actual deployment)
```

---

## 🛡️ Safety Checkpoints

```
┌─────────────────────────────────────┐
│     SAFETY CHECKPOINT 1             │
│  "Correct environment selected?"    │
│  Only prod requires approval        │
│  Dev/release deploy automatically   │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│     SAFETY CHECKPOINT 2             │
│  "Review terraform plan"            │
│  See exactly what will change       │
│  Before approval decision           │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│     SAFETY CHECKPOINT 3             │
│  "Lead must approve"                │
│  Manual explicit approval required  │
│  Can review plan before deciding    │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│     SAFETY CHECKPOINT 4             │
│  "Only from main branch"            │
│  (Optional branch protection)       │
│  Production deployments restricted  │
└─────────────────────────────────────┘
           ↓
┌─────────────────────────────────────┐
│     SAFETY CHECKPOINT 5             │
│  "Apply approved changes"           │
│  Terraform applies to production    │
│  Only after all checks passed       │
└─────────────────────────────────────┘
```

---

## 📊 Job Dependency Graph

```
terraform_plan (always runs)
    │
    └─────────────────┬──────────────────┐
                      │                  │
                  FOR DEV           FOR PROD
                      │                  │
                  terraform_apply    approval
                      │                  │
                   AUTO-RUN          WAIT FOR
                      │              LEAD
                      │                  │
                      │              ┌───┴───┐
                      │              │       │
                      └─┬────────────┴─┐    REJECT
                        │           APPROVE  │
                        │              │     │
                    terraform_apply   │     │
                        │             │     │
                      SUCCESS      SUCCESS  FAILURE
                        │             │     │
                        └─────┬───────┘     │
                              │            │
                            notify      notify
                              │            │
                          SUCCESS       FAILED
```

---

## 🎯 GitHub UI Layout During Approval

```
GitHub Actions Run Page
═══════════════════════════════════════════════════════════════

Jobs List (Left)                Environment Approval (Right)
│                              │
├─ ✅ terraform_plan          ├─ ENVIRONMENTS
│                              │
├─ ⏸️ approval                 ├─ prod
│  Status: Blocked             │  ├─ Status: Waiting for approval
│                              │  ├─ Required reviewer: lead
│                              │  │
├─ ⏹️ terraform_apply          │  ├─ ┌──────────────────────────┐
│  Status: Waiting             │  │  │  Pending approval from:  │
│                              │  │  │  @lead                   │
├─ ⏹️ notify                   │  │  │                          │
│  Status: Waiting             │  │  │  Reviewed by: (none yet) │
│                              │  │  │                          │
│                              │  │  │ Comments (optional):     │
│                              │  │  │ ┌──────────────────────┐ │
│                              │  │  │ │                      │ │
│                              │  │  │ │                      │ │
│                              │  │  │ └──────────────────────┘ │
│                              │  │  │                          │
│                              │  │  │ [Approve and deploy]  ✅ │
│                              │  │  │ [Reject]              ❌ │
│                              │  │  └──────────────────────────┘
│                              │  │
│                              │
```

---

## ✅ Complete Approval Flow Checklist

```
DEVELOPER SIDE:
├─ [ ] Go to Actions
├─ [ ] Click "Terraform Deploy"
├─ [ ] Select environment: prod
├─ [ ] Click "Run workflow"
└─ [ ] See: "Waiting for approval"

LEAD SIDE:
├─ [ ] Receive notification
├─ [ ] Click link to workflow
├─ [ ] Expand terraform_plan job
├─ [ ] Review the changes
├─ [ ] Review any comments
├─ [ ] Click "Approve and deploy" (or "Reject")
└─ [ ] See: terraform_apply starts (if approved)

DEVELOPER SIDE (Monitoring):
├─ [ ] Watch terraform_apply run
├─ [ ] See resources being created
├─ [ ] See final outputs
├─ [ ] Verify success status
└─ [ ] Check AWS console for changes
```

---

**This ensures production deployments are safe, reviewed, and approved before any changes happen!** 🔒
