# Production Approval Workflow - Quick Reference

## 🎯 What Changed

Your `deploy.yml` workflow now has **automatic approval gates** for production deployments.

### New Behavior:

**Dev Environment (dev-a, dev-b):**
```
Trigger → Plan → Apply → Done
No approval needed, fully automatic
```

**Release Environment:**
```
Trigger → Plan → Apply → Done
No approval needed, fully automatic
```

**Production Environment:**
```
Trigger → Plan → ⏸️ STOP → Lead Approves → Apply → Done
APPROVAL REQUIRED before apply!
```

---

## 📝 Code Changes Made

### 1. New "approval" Job Added
```yaml
approval:
  name: 'Approval Required - ${{ inputs.environment }}'
  if: inputs.environment == 'prod'          # Only runs for prod
  needs: terraform_plan                      # Waits for plan first
  runs-on: ubuntu-latest
  environment:
    name: ${{ inputs.environment }}         # Uses prod environment
```

**What it does:**
- Triggers only when `prod` is selected
- Waits for plan to complete
- Pauses workflow awaiting approval
- Uses GitHub's Environment protection rules

### 2. terraform_apply Job Updated
```yaml
terraform_apply:
  name: 'Terraform Apply - ${{ inputs.environment }}'
  needs: [terraform_plan, approval]         # ← Now includes approval
  if: always() && (inputs.environment != 'prod' || 
      needs.approval.result == 'success')   # ← Only runs if approved
```

**What changed:**
- Now waits for `approval` job (not just `terraform_plan`)
- Has conditional logic: 
  - For dev/release: runs automatically
  - For prod: only runs if approval succeeds

### 3. Notification Job Enhanced
```yaml
- name: Determine job status
  run: |
    if [ "${{ inputs.environment }}" = "prod" ] && 
       [ "${{ needs.terraform_apply.result }}" = "skipped" ]; then
      echo "status=⏸️ Awaiting Approval"    # ← New status
      echo "message=Waiting for lead approval..."
```

---

## ⚙️ One-Time Setup Required

### In GitHub Repository Settings:

**Create/Edit prod Environment:**
```
Settings → Environments → prod → Configure environment
```

**Add Protection Rule:**
1. Check: "Required reviewers"
2. Add your lead as reviewer
3. Set deployment branches to "main"
4. Save

**That's it!** Now GitHub will enforce the approval.

---

## 🚀 Deployment Flow Diagram

### Before (Old Way)
```
Developer triggers workflow
    ↓
Plan runs
    ↓
Apply runs automatically  
    ↓
Production updated (no approval)
```

### After (New Way - for prod)
```
Developer triggers workflow, selects "prod"
    ↓
Plan runs, shows changes
    ↓
⏸️ APPROVAL JOB WAITS HERE
    ↓
Lead receives notification
    ↓
Lead reviews plan
    ↓
Lead clicks "Approve and deploy"
    ↓
Apply runs (only if lead approved)
    ↓
Production updated (after approval)
```

---

## 👥 How Your Lead Approves

### Step 1: Notification
Lead receives notification via:
- Email (if configured)
- GitHub Notifications tab
- Workflow email

### Step 2: Find Workflow
1. Go to GitHub repository
2. Click **Actions**
3. Find the running workflow with status "Waiting for approval"

### Step 3: Review
1. Click the workflow
2. Expand **terraform_plan** job
3. Review the plan output (what will change)

### Step 4: Approve
1. On the right side, find **Environments** section
2. Click on **prod**
3. Click **Approve and deploy** button

### Step 5: Add Comments (Optional)
Before/after approving, can add comments explaining the decision

---

## 🔄 Conditional Logic Explained

### Apply Job Condition
```yaml
if: always() && (inputs.environment != 'prod' || 
    needs.approval.result == 'success')
```

**Breaks down to:**
- `always()` = Always evaluate this condition
- `inputs.environment != 'prod'` = If NOT prod, then run
- `needs.approval.result == 'success'` = If prod AND approved, run

**In plain English:**
- If env is dev → Run (approval not needed)
- If env is release → Run (approval not needed)
- If env is prod → Only run if approval succeeded

---

## 📊 Workflow Status Examples

### Dev Deployment - Success
```
✅ terraform_plan ......... Success
✅ terraform_apply ....... Success
✅ notify ................ Success
```

### Prod Deployment - Waiting for Approval
```
✅ terraform_plan ......... Success
⏸️ approval ............. Waiting for approval
⏹️ terraform_apply ....... Blocked (waiting)
⏹️ notify ................ Blocked (waiting)
```

### Prod Deployment - After Approval
```
✅ terraform_plan ......... Success
✅ approval ............. Success (Approved)
✅ terraform_apply ....... Success
✅ notify ................ Success
```

### Prod Deployment - Approval Rejected
```
✅ terraform_plan ......... Success
❌ approval ............. Failure (Rejected)
⏹️ terraform_apply ....... Skipped (not approved)
⏹️ notify ................ Shows approval rejected
```

---

## 🔒 Safety Features

✅ **Manual Control**: Lead must manually approve
✅ **Time Limit**: Approval can't wait forever (24 hours default)
✅ **Plan Review**: Changes visible before approval
✅ **Branch Protection**: Only main branch deployable
✅ **Audit Trail**: All approvals logged in GitHub

---

## ❓ FAQ

**Q: What if lead is busy?**
A: Workflow waits up to 24 hours (configurable). Can then retrigger.

**Q: Can lead reject?**
A: Yes, click "Reject" button. No changes apply.

**Q: What if someone other than lead tries to deploy?**
A: Still need lead approval. Only lead can approve/reject.

**Q: Can we change who approves?**
A: Yes, Settings → Environments → prod → Edit reviewers

**Q: Does this affect dev deployments?**
A: No, dev has no approval requirement.

---

## 🧪 Testing the Approval Flow

### Test 1: Deploy to Prod (Should Pause)
```
1. Go to Actions → Terraform Deploy
2. Select environment: prod
3. Click Run workflow
4. Monitor workflow
5. Expect: terraform_plan succeeds, then pauses at approval
```

### Test 2: Lead Approves
```
1. Have your lead go to Actions
2. Find the paused workflow
3. Click it, find approval section
4. Click "Approve and deploy"
5. Expect: terraform_apply starts running
```

### Test 3: Verify Successful Deployment
```
1. Wait for terraform_apply to complete
2. Check AWS console for changes
3. Verify notification shows success
```

---

## 📚 Files Modified

- **File**: `.github/workflows/deploy.yml`
- **Changes**: Added approval job, updated apply job condition, enhanced notification logic
- **Lines changed**: ~50 lines added/modified
- **Backwards compatible**: Dev deployments still work the same

---

## 📖 Related Documentation

- **Full Setup Guide**: `PRODUCTION_APPROVAL_SETUP.md`
- **Deployment Guide**: `DEPLOYMENT_GUIDE.md`
- **Workflow Details**: `.github/workflows/README.md`

---

## ✅ Verification Checklist

- [ ] `deploy.yml` has approval job
- [ ] `approval` job has `if: inputs.environment == 'prod'`
- [ ] `terraform_apply` now depends on `approval`
- [ ] `terraform_apply` has conditional logic for prod
- [ ] `notification` job handles approval status
- [ ] prod environment created in GitHub
- [ ] Required reviewers set in GitHub
- [ ] Lead added as reviewer

---

**Your production deployments are now safe with mandatory lead approval!** 🎉
