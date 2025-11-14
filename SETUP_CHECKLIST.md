# 🚀 GitHub Actions Setup Checklist

Complete these steps to get your Terraform deployment pipeline working.

## Phase 1: GitHub Secrets Configuration ✓ CRITICAL

### Step 1.1: Add AWS Access Key
- [ ] Go to your GitHub repository
- [ ] Click **Settings** (top navigation)
- [ ] Click **Secrets and variables** → **Actions** (left sidebar)
- [ ] Click **New repository secret**
- [ ] Name: `AWS_ACCESS_KEY_ID`
- [ ] Value: Your AWS access key
- [ ] Click **Add secret**

### Step 1.2: Add AWS Secret Key
- [ ] Click **New repository secret**
- [ ] Name: `AWS_SECRET_ACCESS_KEY`
- [ ] Value: Your AWS secret key
- [ ] Click **Add secret**

**Verify:** You should see both secrets listed

---

## Phase 2: GitHub Environments Setup (Optional but Recommended)

### Step 2.1: Create Dev Environment
- [ ] Click **Settings** (top navigation)
- [ ] Click **Environments** (left sidebar)
- [ ] Click **New environment**
- [ ] Name: `dev`
- [ ] Click **Configure environment**
- [ ] Leave settings as default
- [ ] Click **Save protection rules**

### Step 2.2: Create Release Environment
- [ ] Click **New environment**
- [ ] Name: `release`
- [ ] Check **Deployment branches**
- [ ] Select **main branch only**
- [ ] Click **Save protection rules**

### Step 2.3: Create Prod Environment
- [ ] Click **New environment**
- [ ] Name: `prod`
- [ ] Check **Deployment branches**
- [ ] Select **main branch only**
- [ ] Scroll down to **Required reviewers**
- [ ] Add 1-2 team members (optional)
- [ ] Click **Save protection rules**

**Verify:** You should see dev, prod, and release environments

---

## Phase 3: Branch Protection (Recommended)

### Step 3.1: Protect Main Branch
- [ ] Go to **Settings** → **Branches** (left sidebar)
- [ ] Click **Add rule**
- [ ] Branch name pattern: `main`
- [ ] Check **Require a pull request before merging**
- [ ] Check **Include administrators**
- [ ] Click **Create**

---

## Phase 4: Verification Tests

### Test 4.1: Validate Workflow Runs on PR
- [ ] Create a new branch: `git checkout -b test/workflows`
- [ ] Make a small change (e.g., add comment in `environments/dev/main.tf`)
- [ ] Commit and push: `git push origin test/workflows`
- [ ] Create a pull request on GitHub
- [ ] Go to **Actions** tab
- [ ] **Verify:** "Terraform Validate" workflow should be running
- [ ] Wait for it to complete (should pass)
- [ ] Close/delete the PR without merging

### Test 4.2: Manual Deploy to Dev-a
- [ ] Go to **Actions** tab
- [ ] Click **Terraform Deploy** (left sidebar under workflows)
- [ ] Click **Run workflow** (blue button)
- [ ] Keep defaults: Environment = `dev`, Dev Variant = `dev-a`
- [ ] Click **Run workflow**
- [ ] **Monitor the workflow:**
  - ✓ "terraform_plan" job should run and complete
  - ✓ "terraform_apply" job should run after plan completes
  - ✓ Should see output with ALB DNS name
- [ ] **Verify in AWS Console:**
  - Go to EC2 Dashboard
  - Check VPC named `dev-a-vpc`
  - Check 2 EC2 instances are running
  - Check Application Load Balancer exists

### Test 4.3: Manual Deploy to Dev-b
- [ ] Go to **Actions** tab
- [ ] Click **Terraform Deploy**
- [ ] Click **Run workflow**
- [ ] Select: Environment = `dev`, Dev Variant = `dev-b`
- [ ] Click **Run workflow**
- [ ] **Monitor the workflow** (should complete successfully)
- [ ] **Verify in AWS Console:**
  - Check VPC named `dev-b-vpc`
  - Check 2 new EC2 instances are running
  - Check we have 2 separate ALBs now

### Test 4.4: Test Destroy Workflow
- [ ] Go to **Actions** tab
- [ ] Click **Terraform Destroy**
- [ ] Click **Run workflow**
- [ ] Select: Environment = `dev`, Dev Variant = `dev-b`
- [ ] In "Confirmation" field, type: `DESTROY`
- [ ] Click **Run workflow**
- [ ] **Monitor the workflow** (should complete)
- [ ] **Verify in AWS Console:**
  - VPC `dev-b-vpc` should be deleted
  - EC2 instances for dev-b should be removed

---

## Phase 5: Production Readiness

### Step 5.1: Review Security
- [ ] AWS credentials are stored securely (not in code)
- [ ] S3 backend is encrypted and locked
- [ ] Prod environment requires approvers
- [ ] Branch protection is enabled for main

### Step 5.2: Document Team Access
- [ ] Document who has GitHub write access
- [ ] Document who can approve prod deployments
- [ ] Create team wiki/documentation

### Step 5.3: Backup Your Terraform State
- [ ] Verify S3 bucket `git-hpha-terraform-state` exists
- [ ] Enable versioning on the bucket (optional)
- [ ] Enable MFA delete protection (optional for prod)

---

## ✅ Final Verification Checklist

Mark these complete before going to production:

- [ ] AWS_ACCESS_KEY_ID secret added
- [ ] AWS_SECRET_ACCESS_KEY secret added
- [ ] Environments created (dev, prod, release)
- [ ] Main branch protection enabled
- [ ] Validate workflow test passed
- [ ] Dev-a deployment test passed
- [ ] Dev-b deployment test passed
- [ ] Destroy workflow test passed
- [ ] Team members trained on workflows
- [ ] Documentation reviewed

---

## 🔗 Quick Reference

### AWS Secrets to Add
```
AWS_ACCESS_KEY_ID = <your-access-key>
AWS_SECRET_ACCESS_KEY = <your-secret-key>
```

### Workflow Files Location
```
.github/workflows/
├── deploy.yml      (Main deployment)
├── destroy.yml     (Infrastructure teardown)
└── validate.yml    (Automatic validation)
```

### Key Documentation Files
```
DEPLOYMENT_GUIDE.md        (Overview and examples)
.github/workflows/README.md (Detailed workflow docs)
.github/workflows-setup.md  (Setup instructions)
```

---

## 🆘 Troubleshooting

### "Error: AWS credentials not found"
1. Check Settings → Secrets
2. Verify both AWS secrets are present
3. Verify secret names match exactly (case-sensitive)

### "Error: S3 bucket not found"
1. Verify S3 bucket `git-hpha-terraform-state` exists
2. Verify AWS credentials have S3 permissions
3. Check bucket region is `us-east-1`

### "Validation workflow not running on PR"
1. Check the file changes are in `environments/` or `modules/`
2. Verify the PR is to `main` branch
3. Check Actions tab - the workflow might be queued

### "Terraform plan takes too long"
1. This is normal on first run (terraform init)
2. Subsequent runs are faster
3. Check workflow logs for any hanging operations

---

## 📞 Support

If you encounter issues:

1. **Check the logs:**
   - Go to Actions → Click the failed workflow → Review step logs

2. **Common issues documented in:**
   - `.github/workflows-setup.md` - Troubleshooting section

3. **Workflow details in:**
   - `.github/workflows/README.md` - Full documentation

4. **Quick examples in:**
   - `DEPLOYMENT_GUIDE.md` - Usage examples

---

## 🎉 You're Ready!

Once all checks are complete, you can:

✅ Deploy to dev-a with GUI selection
✅ Deploy to dev-b with GUI selection  
✅ Deploy to release automatically
✅ Deploy to prod safely
✅ Destroy infrastructure safely
✅ Get validation on all PRs
✅ Track all changes in GitHub

**Happy deploying! 🚀**
