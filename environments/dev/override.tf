# ============================================================================
# TERRAFORM OVERRIDE FILE: Disable ALB Module
# ============================================================================
# This file uses Terraform's override mechanism to disable the ALB module
# while keeping it in the configuration for future use.
#
# How it works:
# - When terraform plan/apply runs, it merges all .tf files
# - This override file tells Terraform to ignore changes to module.alb
# - The module code remains in version control for reference
#
# File location: environments/dev/override.tf (applies only to dev)
# ============================================================================

# Disable ALB module - ignore all changes and prevent creation
moved {
  from = module.alb
  to   = null
}

# Alternative: If you want to keep ALB in state but prevent it from being managed,
# you can use ignore_changes in the root module level (requires Terraform 1.2+)
# This is commented out as the moved block above is more explicit

# terraform {
#   ignore_resource_attributes = [
#     "module.alb"
#   ]
# }
