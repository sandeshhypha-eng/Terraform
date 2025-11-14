# Production Approval Workflow Setup Guide

## 🔐 What Was Added

Your GitHub Actions pipeline now includes **automatic approval gates for production deployments**:

✅ When `prod` environment is selected → Workflow stops after plan
✅ Requires lead approval to continue
✅ Only then applies the changes to production

---

## 📋 Setup Steps (One-Time Configuration)

### Step 1: Create "prod" Environment in GitHub

1. Go to your GitHub repository
2. Click **Settings** (top navigation)
3. Click **Environments** (left sidebar)
4. Click **New environment**
5. Name: `prod`
6. Click **Configure environment**

### Step 2: Configure Approval Settings

After clicking "Configure environment" for prod:

1. Scroll down to **Deployment branches**
   - Check: "Restrict who can deploy to this environment"
   - Select: "main" branch only

2. Scroll down to **Required reviewers**
   - Check: "Required reviewers"
   - Click **Add reviewers**
   - Search for and add your lead (their GitHub username)

3. Scroll down to **Deployment timeout**
   - Set to: 24 hours (or your preferred duration)

4. Click **Save protection rules**

### Step 3: Repeat for "release" Environment (Optional)

You can also add approval gates for release environment:

1. Click **New environment**
2. Name: `release`
3. Optionally add a reviewer (can be less strict than prod)
4. Save

---

## 🔄 How It Works Now

### Dev Deployment (No Approval Needed)
```
Select env: dev → Plan runs → Apply runs automatically → Done ✓
(Takes ~10 minutes)
```

### Production Deployment (Approval Required)
```
Select env: prod 
    ↓
Plan runs (terraform plan output shows what will change)
    ↓
⏸️ STOPS HERE - Waiting for approval
    ↓
Your lead reviews the plan and approves/rejects
    ↓
If approved → Apply runs automatically
If rejected → Deployment stops
    ↓
Result shown in notification
(Total time depends on when lead approves)
```

---

## 👥 For Your Lead (Lead Approval Instructions)

When a production deployment is triggered:

### Step 1: Find the Workflow
1. Go to **Actions** tab in GitHub
2. Look for the running workflow (it will say "Waiting for approval")
3. Click on it

### Step 2: Review the Plan
1. Expand the **terraform_plan** job
2. Read through the Terraform plan output
3. Review what resources will be added/modified/deleted

### Step 3: Approve or Reject
1. On the right side, you'll see **"Environments"** section
2. Click the **Approval Required** environment section
3. You'll see two buttons:
   - **"Approve and deploy"** ✅
   - **"Reject"** ❌

### Step 4: Add a Comment (Optional)
Before approving/rejecting, you can add a comment explaining the decision

### Step 5: Click Approval/Reject
- **Approve**: Workflow continues to apply changes
- **Reject**: Deployment stops, no changes applied

---

## 📊 Workflow Stages Explained

### Stage 1: Plan (Automatic)
```
✓ Code checked out
✓ Terraform runs plan
✓ Shows what will change
✓ Plan artifact saved

Status: Can review changes without any being applied yet
```

### Stage 2: Approval Gate (For Production Only)
```
⏸️ Workflow pauses
🔔 Your lead is notified
👤 Lead reviews the plan
✅ Lead approves or rejects
```

### Stage 3: Apply (Only If Approved)
```
✓ Terraform applies changes (only if approved)
✓ Creates/modifies resources in AWS
✓ Outputs final results
✓ Deployment complete
```

---

## 🎯 Environment-Specific Behavior

| Environment | Approval? | Auto-Apply? | Time |
|---|---|---|---|
| dev-a | ❌ No | ✅ Yes | ~10 min |
| dev-b | ❌ No | ✅ Yes | ~10 min |
| release | ⚙️ Optional | ✅ Yes* | ~10 min |
| prod | ✅ Yes | ❌ Manual | 10 min + approval time |

*Can add approval if configured

---

## 📝 Workflow Code Changes

### New Approval Job Added
```yaml
approval:
  name: 'Approval Required - ${{ inputs.environment }}'
  if: inputs.environment == 'prod'    # Only runs for prod
  needs: terraform_plan              # Waits for plan to complete
  runs-on: ubuntu-latest
  environment:
    name: ${{ inputs.environment }}   # Uses prod environment config
```

### Apply Job Updated
```yaml
terraform_apply:
  needs: [terraform_plan, approval]   # Now needs both
  if: always() && (inputs.environment != 'prod' || 
      needs.approval.result == 'success')
```

This means:
- For **dev**: Apply runs after plan (no approval needed)
- For **prod**: Apply only runs if approval succeeds

---

## 🔔 Notifications

### When Approval Needed
Workflow summary shows:
```
⏸️ Awaiting Approval
Environment: prod
Status: Waiting for lead approval in the Environment section
Action Required: Your lead must approve this production deployment
```

### After Approval
Lead gets:
- Comment box to add approval notes
- Timestamp of approval
- Which reviewer approved

---

## 🛡️ Safety Features

✅ **Only main branch**: Can only be deployed from main branch
✅ **Lead approval required**: Can't deploy without explicit approval
✅ **Time limit**: Approval can't be delayed forever (24 hours by default)
✅ **Full audit trail**: All approvals logged in GitHub
✅ **Plan review**: Changes visible before approval

---

## ❓ Frequently Asked Questions

### Q: What if lead forgets to approve?
A: Workflow will wait up to 24 hours, then automatically expire. Deployment can be retriggered.

### Q: Can multiple people approve?
A: Yes, you can add multiple reviewers. At least one must approve.

### Q: Can we change the reviewer?
A: Yes, go to Settings → Environments → prod → Edit required reviewers

### Q: What if we reject a deployment?
A: No changes apply. The plan showed what would have changed. Fix the issue and retrigger.

### Q: How do we check approval history?
A: Go to the workflow run → Scroll to approval step → See approval decision and comments

### Q: Can dev deployments skip the approval?
A: Yes, only prod requires approval (can add to release if desired)

---

## 🔄 Changing Approval Settings

To modify approval settings:

1. Go to **Settings → Environments → prod**
2. Make changes to:
   - Required reviewers (add/remove)
   - Deployment branches (restrict which branches)
   - Deployment timeout (change wait time)
3. Save

---

## 📚 Additional Resources

- GitHub Docs: https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment
- About Environment Protection Rules: https://docs.github.com/en/actions/deployment/targeting-different-environments/managing-deployments/about-environment-protection-rules

---

## ✅ Verification Checklist

- [ ] prod environment created in GitHub
- [ ] Required reviewers set for prod
- [ ] Your lead added as a reviewer
- [ ] Deployment branches set to main only
- [ ] Timeout set appropriately
- [ ] Test deployment to prod initiated
- [ ] Lead receives approval notification
- [ ] Lead successfully approved deployment

---

## 🎉 You're All Set!

Your production deployment now has proper approval gates. This ensures:

✅ Changes are reviewed before production deployment
✅ Your lead maintains control over production changes
✅ Everything is audited and tracked
✅ Mistakes are prevented through mandatory approval

**Next Step:** Test by deploying to prod and having your lead approve!
