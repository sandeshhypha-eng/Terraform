# ============================================================================
# TERRAFORM CONFIGURATION BLOCK
# ============================================================================
# This block specifies the required Terraform version and providers.
# It ensures that anyone running this configuration uses compatible versions.
#
# required_version: Minimum Terraform version required (1.0 or higher)
#   Terraform 1.0+ provides stable APIs and better error handling
#
# required_providers: Specifies which providers are needed and their versions
#   - aws: The AWS provider for managing AWS resources
#   - source: "hashicorp/aws" - Official AWS provider from HashiCorp
#   - version: "~> 5.0" - Allows any version 5.x but not 6.0+
#     The ~> operator allows patch and minor version updates but not major
# ============================================================================
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket         = "git-hpha-terraform-state"
    key            = "terraformv2/environments/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true
    # S3 native locking explanation:
    # Terraform will attempt to create a temporary lock object alongside
    # the state file (for example: terraform.tfstate.tflock) using S3's
    # conditional-write capability (If-None-Match). The PUT will succeed
    # only if the lock object doesn't already exist. If another process
    # has already created the lock object, the conditional write will
    # fail and Terraform will not proceed with state-changing operations.
    # When the operation finishes, Terraform deletes the lock object.
    # This prevents concurrent modifications of the same remote state
    # and avoids corruption or lost updates.
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================================================
# AWS PROVIDER CONFIGURATION
# ============================================================================
# The provider block configures how Terraform interacts with AWS.
# This tells Terraform which AWS region to use for all resource creation.
#
# region: The AWS region where resources will be created
#   This comes from the variable var.aws_region (set in terraform.tfvars)
#   Examples: "us-east-1", "us-west-2", "eu-west-1"
#
# Note: All resources created by this configuration will be in this region.
# If you need resources in multiple regions, you would define multiple provider
# blocks with aliases.
# ============================================================================
provider "aws" {
  region = var.aws_region
}

# ============================================================================
# LOCAL: Determine which load balancer to use
# ============================================================================
locals {
  use_nginx_lb = var.load_balancer_type == "nginx"
  use_alb      = var.load_balancer_type == "alb"
  
  lb_config = {
    type    = var.load_balancer_type
    nginx   = local.use_nginx_lb
    alb     = local.use_alb
  }
}

# ============================================================================
# MODULE: Network Infrastructure
# ============================================================================
# This module creates the foundational networking components:
#   - VPC (Virtual Private Cloud)
#   - Internet Gateway
#   - Two public subnets in different availability zones
#   - Route tables and associations
#   - Discovers the latest Amazon Linux 2 AMI
#
# Module Source: "../../modules/network" - Relative path to the network module
#
# Input Variables:
#   - aws_region: Region where resources will be created
#   - vpc_cidr: IP address range for the VPC (e.g., "10.0.0.0/16")
#   - vpc_name: Name tag for the VPC (e.g., "dev-vpc")
#   - public_subnet_1_cidr: IP range for first public subnet (e.g., "10.0.1.0/24")
#   - public_subnet_2_cidr: IP range for second public subnet (e.g., "10.0.2.0/24")
#
# Outputs Used Later:
#   - module.network.vpc_id: Used by security and ALB modules
#   - module.network.public_subnet_1_id: Used by instances and ALB modules
#   - module.network.public_subnet_2_id: Used by instances and ALB modules
#   - module.network.amazon_linux_2_ami_id: Used by instances module
#
# Dependency Order: This module has no dependencies, so it's created first.
# ============================================================================
module "network" {
  source = "../../modules/network"

  aws_region          = var.aws_region
  vpc_cidr            = var.vpc_cidr
  vpc_name            = "${var.environment}-vpc"
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}

# ============================================================================
# MODULE: Security Groups
# ============================================================================
# This module creates security groups (virtual firewalls) that control
# network traffic to and from AWS resources.
#
# Resources Created:
#   - Security group for Application Load Balancer (allows HTTP from internet)
#   - Security group for EC2 instances (allows HTTP only from ALB)
#
# Module Source: "../../modules/security" - Relative path to the security module
#
# Input Variables:
#   - vpc_id: The VPC where security groups will be created
#     This comes from the network module output
#   - environment: Environment name for naming and tagging
#
# Outputs Used Later:
#   - module.security.ec2_security_group_id: Attached to EC2 instances
#   - module.security.alb_security_group_id: Attached to Application Load Balancer
#
# Dependency: Requires network module to be created first (needs VPC ID)
# ============================================================================
module "security" {
  source = "../../modules/security"

  vpc_id      = module.network.vpc_id
  environment = var.environment
}

# ============================================================================
# MODULE: EC2 Instances (Web Servers)
# ============================================================================
# This module creates two EC2 instances that will serve as web servers.
# The instances are deployed in different availability zones for high availability.
#
# Resources Created:
#   - EC2 Instance 1: In public subnet 1 (first availability zone)
#   - EC2 Instance 2: In public subnet 2 (second availability zone)
#
# Module Source: "../../modules/instances" - Relative path to the instances module
#
# Input Variables:
#   - ami_id: Amazon Machine Image ID (from network module)
#   - instance_type: EC2 instance size (e.g., "t2.micro" for dev)
#   - public_subnet_1_id: Subnet for first instance (from network module)
#   - public_subnet_2_id: Subnet for second instance (from network module)
#   - ec2_security_group_id: Security group for instances (from security module)
#   - environment: Environment name for naming and user data customization
#
# User Data Script: Automatically installs and configures Apache web server
#   on each instance when it first starts.
#
# Outputs Used Later:
#   - module.instances.web_1_instance_id: Attached to ALB target group
#   - module.instances.web_2_instance_id: Attached to ALB target group
#
# Dependencies:
#   - Requires network module (for subnets and AMI)
#   - Requires security module (for security group)
# ============================================================================
module "instances" {
  source = "../../modules/instances"

  ami_id                = module.network.amazon_linux_2_ami_id
  instance_type         = var.instance_type
  public_subnet_1_id    = module.network.public_subnet_1_id
  public_subnet_2_id    = module.network.public_subnet_2_id
  ec2_security_group_id = module.security.ec2_security_group_id
  environment           = var.environment
}

# ============================================================================
# MODULE: Nginx Load Balancer (Alternative to ALB)
# ============================================================================
# This module creates an EC2 instance with Nginx configured as a reverse proxy
# and load balancer. This is used when ALB is not available due to account
# restrictions.
#
# Resources Created:
#   - EC2 Instance with Nginx installed and configured
#   - Nginx configured as reverse proxy
#   - Load balancing between web servers 1 and 2
#   - Health checks for backend servers
#
# Module Source: "../../modules/nginx_lb" - Relative path to the nginx_lb module
#
# Input Variables:
#   - ami_id: Amazon Machine Image ID (from network module)
#   - instance_type: EC2 instance type for Nginx (t2.micro default)
#   - public_subnet_id: Subnet for Nginx LB (from network module)
#   - nginx_security_group_id: Security group for Nginx (from security module)
#   - web_1_private_ip: Private IP of web server 1 (from instances module)
#   - web_2_private_ip: Private IP of web server 2 (from instances module)
#   - environment: Environment name for naming
#
# How It Works:
#   1. Internet traffic arrives at Nginx LB's public IP
#   2. Nginx performs health checks on both backend servers
#   3. Uses round-robin to distribute traffic between servers
#   4. Automatically handles failed backend servers
#
# Outputs:
#   - module.nginx_lb.nginx_lb_public_ip: Public IP to access the application
#   - module.nginx_lb.nginx_lb_public_dns: Public DNS to access the application
#
# Dependencies:
#   - Requires network module (for subnets and AMI)
#   - Requires security module (for Nginx security group)
#   - Requires instances module (for backend server private IPs)
# ============================================================================
module "nginx_lb" {
  source = "../../modules/nginx_lb"

  ami_id                   = module.network.amazon_linux_2_ami_id
  instance_type            = var.nginx_instance_type
  public_subnet_id         = module.network.public_subnet_1_id
  nginx_security_group_id  = module.security.nginx_lb_security_group_id
  web_1_private_ip         = module.instances.web_1_private_ip
  web_2_private_ip         = module.instances.web_2_private_ip
  environment              = var.environment

  # Count = 0 means this module will be ignored and not created
  # Count = 1 means this module will be created and managed
  count = local.use_nginx_lb ? 1 : 0
}

# ============================================================================
# MODULE: Application Load Balancer (ALB) - CURRENTLY DISABLED
# ============================================================================
# This module is disabled using count = 0 but kept in configuration for easy
# future activation when ALB becomes available in your AWS account.
#
# Current Status: DISABLED (count = 0)
# Active Load Balancer: Nginx LB (module.nginx_lb)
# Reason: AWS account has ALB restrictions
#
# MIGRATION GUIDE: How to switch from Nginx LB to ALB
# ============================================================
#
# When ALB becomes available:
#
# Step 1: Verify ALB is available
#   - Test in AWS Console: EC2 → Load Balancers → Create
#   - Or test with: aws elbv2 describe-load-balancers
#
# Step 2: Update terraform.tfvars
#   Change: load_balancer_type = "nginx"
#   To:     load_balancer_type = "alb"
#
# Step 3: Review and apply changes
#   terraform plan
#   terraform apply
#
# Step 4: Update outputs (if needed)
#   - Nginx outputs will become unavailable
#   - ALB outputs will become available
#
# Step 5: Verify traffic routing
#   - Access new ALB DNS name from outputs
#   - Verify both backend servers are healthy
#   - Check ALB target group health checks
#
# ============================================================
#
# Rollback (if needed): Return load_balancer_type to "nginx"
#
# ============================================================
module "alb" {
  source = "../../modules/alb"

  vpc_id                = module.network.vpc_id
  public_subnet_1_id    = module.network.public_subnet_1_id
  public_subnet_2_id    = module.network.public_subnet_2_id
  alb_security_group_id = module.security.alb_security_group_id
  web_1_instance_id     = module.instances.web_1_instance_id
  web_2_instance_id     = module.instances.web_2_instance_id
  environment           = var.environment

  # Count = 0 means this module is disabled and ignored by Terraform
  # Count = 1 means this module will be created and managed
  count = local.use_alb ? 1 : 0
}

