# ============================================================================
# VARIABLE: AWS Region
# ============================================================================
# Specifies the AWS region where all resources for this environment will be created.
# This variable is used by the AWS provider and passed to all modules.
#
# Common values:
#   - "us-east-1" (N. Virginia) - Often cheapest, most services available
#   - "us-west-2" (Oregon) - Good for US West Coast
#   - "eu-west-1" (Ireland) - Good for Europe
#
# Set in: terraform.tfvars file for this environment
# ============================================================================
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

# ============================================================================
# VARIABLE: Environment
# ============================================================================
# The environment name (e.g., "dev", "release", "prod").
# This is used throughout the configuration for:
#   - Naming resources (e.g., "dev-vpc", "dev-web-alb")
#   - Tagging resources for identification and cost tracking
#   - Customizing configurations per environment
#
# Set in: terraform.tfvars file for this environment
# ============================================================================
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# ============================================================================
# VARIABLE: VPC CIDR Block
# ============================================================================
# The IP address range for the VPC in CIDR notation.
# This defines the total IP space available in the VPC.
#
# For dev environment: Typically uses 10.0.0.0/16
# Important: Each environment should use different CIDR blocks to avoid
# conflicts if you need to peer VPCs or connect them later.
#
# Set in: terraform.tfvars file for this environment
# ============================================================================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ============================================================================
# VARIABLE: Public Subnet 1 CIDR Block
# ============================================================================
# The IP address range for the first public subnet.
# Must be a subset of the VPC CIDR block.
#
# For dev: Typically 10.0.1.0/24 (256 IPs, minus 5 reserved by AWS)
# This subnet will be in the first availability zone.
#
# Set in: terraform.tfvars file for this environment
# ============================================================================
variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

# ============================================================================
# VARIABLE: Public Subnet 2 CIDR Block
# ============================================================================
# The IP address range for the second public subnet.
# Must be a subset of the VPC CIDR block and different from subnet 1.
#
# For dev: Typically 10.0.2.0/24 (256 IPs, minus 5 reserved by AWS)
# This subnet will be in the second availability zone.
#
# Set in: terraform.tfvars file for this environment
# ============================================================================
variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

# ============================================================================
# VARIABLE: Instance Type
# ============================================================================
# The EC2 instance type determines the compute resources (CPU, memory, network).
#
# For dev environment: Typically "t2.micro" (free tier eligible, cost-effective)
# For release: Typically "t2.small" (more resources for testing)
# For prod: Typically "t2.medium" or larger (production-grade performance)
#
# Common types:
#   - t2.micro: 1 vCPU, 1 GB RAM (free tier)
#   - t2.small: 1 vCPU, 2 GB RAM
#   - t2.medium: 2 vCPU, 4 GB RAM
#
# Set in: terraform.tfvars file for this environment
# ============================================================================
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

