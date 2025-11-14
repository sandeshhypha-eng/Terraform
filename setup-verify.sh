#!/bin/bash
# GitHub Actions Setup Quick Start Script
# This script helps verify your GitHub Actions setup

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║   Terraform GitHub Actions - Setup Verification    ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Check 1: Verify workflow files exist
echo "✓ Checking workflow files..."
FILES=(
  ".github/workflows/deploy.yml"
  ".github/workflows/destroy.yml"
  ".github/workflows/validate.yml"
  ".github/workflows/README.md"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ✗ $file (MISSING)"
  fi
done

echo ""

# Check 2: Verify environment structure
echo "✓ Checking environment structure..."
ENVS=("dev" "prod" "release")

for env in "${ENVS[@]}"; do
  if [ -d "environments/$env" ]; then
    echo "  ✓ environments/$env/"
    
    if [ -f "environments/$env/terraform.tfvars" ]; then
      echo "    ✓ terraform.tfvars"
    fi
    
    if [ -f "environments/$env/main.tf" ]; then
      echo "    ✓ main.tf"
    fi
    
    if [ -f "environments/$env/variables.tf" ]; then
      echo "    ✓ variables.tf"
    fi
  else
    echo "  ✗ environments/$env/ (MISSING)"
  fi
done

echo ""

# Check 3: Verify dev variants
echo "✓ Checking dev variants..."
if [ -f "environments/dev/dev-a.tfvars" ]; then
  echo "  ✓ dev-a.tfvars"
else
  echo "  ✗ dev-a.tfvars (MISSING)"
fi

if [ -f "environments/dev/dev-b.tfvars" ]; then
  echo "  ✓ dev-b.tfvars"
else
  echo "  ✗ dev-b.tfvars (MISSING)"
fi

echo ""

# Check 4: Verify modules
echo "✓ Checking modules..."
MODULES=("network" "security" "instances" "alb")

for module in "${MODULES[@]}"; do
  if [ -f "modules/$module/main.tf" ]; then
    echo "  ✓ modules/$module/"
  else
    echo "  ✗ modules/$module/ (MISSING)"
  fi
done

echo ""

# Check 5: Verify terraform syntax
echo "✓ Checking Terraform syntax..."
cd environments/dev
if terraform init -backend=false > /dev/null 2>&1; then
  if terraform validate > /dev/null 2>&1; then
    echo "  ✓ Terraform syntax valid"
  else
    echo "  ✗ Terraform validation failed"
  fi
else
  echo "  ⚠ Terraform init failed (may need AWS configured)"
fi
cd - > /dev/null

echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║              Setup Verification Complete           ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
echo "NEXT STEPS:"
echo "───────────"
echo "1. Add AWS credentials as GitHub Secrets:"
echo "   Settings → Secrets and variables → Actions"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo ""
echo "2. Create GitHub Environments (optional):"
echo "   Settings → Environments → Create: dev, prod, release"
echo ""
echo "3. Set branch protection rules (optional):"
echo "   Settings → Branches → main"
echo ""
echo "4. Test deployment:"
echo "   Actions → Terraform Deploy → Run workflow"
echo ""
echo "For more details, see DEPLOYMENT_GUIDE.md"
echo ""
