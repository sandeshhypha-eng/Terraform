# How to Write Terraform Code - Complete Reference Guide

A step-by-step guide to writing Terraform code from scratch using Terraform documentation and best practices.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Understanding Terraform Documentation](#understanding-terraform-documentation)
3. [Project Setup](#project-setup)
4. [Writing Provider Configuration](#writing-provider-configuration)
5. [Writing Resource Blocks](#writing-resource-blocks)
6. [Working with Data Sources](#working-with-data-sources)
7. [Creating Variables](#creating-variables)
8. [Creating Outputs](#creating-outputs)
9. [Using Locals and Expressions](#using-locals-and-expressions)
10. [Using Modules](#using-modules)
11. [Writing Terraform Functions](#writing-terraform-functions)
12. [Common AWS Resources Examples](#common-aws-resources-examples)
13. [Testing Your Code](#testing-your-code)

---

## Introduction

### What Does "Writing Terraform Code" Mean?

Writing Terraform code means creating `.tf` files (written in HCL - HashiCorp Configuration Language) that describe your infrastructure declaratively. Instead of clicking buttons in AWS console, you describe what infrastructure you want, and Terraform creates it.

### The Philosophy

```
Traditional Approach:          Terraform Approach:
1. Open AWS Console      →    1. Write .tf files
2. Click through UI      →    2. Run terraform plan
3. Create resources      →    3. Run terraform apply
4. Document manually     →    4. Version control your code
5. Make changes in UI    →    5. Update .tf files and reapply
```

### Why Write Terraform Code?

- **Infrastructure as Code**: Version control infrastructure
- **Reproducible**: Create same infrastructure multiple times
- **Auditable**: Track all changes
- **Scalable**: Manage thousands of resources
- **Collaborative**: Share infrastructure patterns

---

## Understanding Terraform Documentation

### Where to Find Documentation

```
Official Terraform Documentation
├── https://www.terraform.io/docs
├── Provider Documentation (AWS, Azure, GCP, etc.)
│   └── https://registry.terraform.io/providers/hashicorp/aws/latest
├── Resource Documentation
│   └── https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
└── Data Source Documentation
    └── https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
```

### How to Read Documentation

#### Step 1: Find the Right Resource

```
Goal: Create an EC2 instance in AWS

Action: Go to https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Click: "Resources" or search for "instance"
```

#### Step 2: Understand Resource Structure

**Example: AWS EC2 Instance Documentation**

```
Documentation shows:
├── Description: What the resource does
├── Example: Minimal working example
├── Argument Reference: Input parameters (required & optional)
├── Attributes Reference: Output values
└── Timeouts: How long Terraform waits
```

#### Step 3: Read Required vs Optional Arguments

```
From Documentation:
- name (Optional) - String value
- instance_type (Required) - String value
- ami (Required) - String value
- tags (Optional) - Map of strings
```

**Means**:
```
Required = Must provide
Optional = Can omit (has default or computed)
```

#### Step 4: Copy Example and Modify

```hcl
# From Documentation:
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}

# Your Code (modified):
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "my-web-server"
  }
}
```

---

## Project Setup

### Step 1: Create Project Directory

```bash
# Create and navigate to project
mkdir terraform-project
cd terraform-project

# Initialize Git
git init

# Create directory structure
mkdir -p envs/{dev,prod}
```

### Step 2: Create Directory Structure

```
terraform-project/
├── main.tf                 # Primary resource definitions
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── locals.tf               # Local values
├── terraform.tf            # Terraform configuration
├── providers.tf            # Provider setup
├── dev.tfvars             # Development values
├── prod.tfvars            # Production values
├── .gitignore             # Git ignore file
├── README.md              # Documentation
└── examples/              # Example configurations
```

### Step 3: Create .gitignore

```bash
cat > .gitignore << 'EOF'
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# .tfvars files
*.tfvars
*.tfvars.json

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Terraform plugins
.terraform.lock.hcl

# Plan files
*.tfplan
EOF
```

### Step 4: Create README

```bash
cat > README.md << 'EOF'
# Terraform Project

## Project Description
Brief description of what infrastructure this code creates.

## Prerequisites
- Terraform 1.0+
- AWS Account
- AWS Credentials Configured

## Usage
```bash
terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

## Files
- `main.tf`: Resources
- `variables.tf`: Input variables
- `outputs.tf`: Output values

## Resources Created
- EC2 Instance
- Security Group
- VPC
EOF
```

---

## Writing Provider Configuration

### Step 1: Understand Provider Documentation

**Location**: https://registry.terraform.io/providers/hashicorp/aws/latest

**What You'll Find**:
- How to configure the provider
- Required and optional arguments
- Authentication methods
- Default values

### Step 2: Create Provider File

**File**: `providers.tf`

```hcl
# AWS Provider configuration

# Step 1: Specify provider source and version
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Step 2: Configure the provider
provider "aws" {
  # Region where resources are created
  # Can be overridden per resource
  region = var.aws_region

  # Tags applied to ALL resources
  # From documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags-configuration
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }

  # Optional: Skip credential validation (dev only)
  # skip_credentials_validation = true

  # Optional: Skip metadata API check
  # skip_metadata_api_check     = true

  # Optional: Custom endpoint (for LocalStack, Moto)
  # endpoints {
  #   ec2 = "http://localhost:4566"
  # }
}
```

### Step 3: Understand Provider Arguments

**Reading from Documentation**:

```
From https://registry.terraform.io/providers/hashicorp/aws/latest/docs

Arguments (sorted by importance):
1. region - (Optional) AWS region (string)
   - Default: AWS_REGION environment variable
   - Example: "us-east-1", "ap-south-1"

2. profile - (Optional) AWS named profile (string)
   - Default: AWS_PROFILE environment variable

3. access_key - (Optional) AWS access key (string)
   - Default: AWS_ACCESS_KEY_ID environment variable
   - WARNING: Store in environment, not code

4. secret_key - (Optional) AWS secret key (string)
   - Default: AWS_SECRET_ACCESS_KEY environment variable
   - WARNING: Store in environment, not code

5. assume_role - (Optional) STS assume role configuration (block)
   - For cross-account access
```

### Step 4: Common Provider Configurations

**Configuration 1: Single Region (Most Common)**

```hcl
provider "aws" {
  region = "ap-south-1"
}
```

**Configuration 2: Multiple Regions**

```hcl
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west"
  region = "eu-west-1"
}

# Use in resources:
resource "aws_instance" "us" {
  provider = aws.us_east
}

resource "aws_instance" "eu" {
  provider = aws.eu_west
}
```

**Configuration 3: Cross-Account (Multiple AWS Accounts)**

```hcl
provider "aws" {
  alias = "prod"
  
  assume_role {
    role_arn = "arn:aws:iam::PROD_ACCOUNT_ID:role/TerraformRole"
  }
}

resource "aws_instance" "prod" {
  provider = aws.prod
}
```

---

## Writing Resource Blocks

### Understanding Resources from Documentation

#### Step 1: Find Resource Documentation

**Process**:
1. Go to https://registry.terraform.io/providers/hashicorp/aws/latest/docs
2. Click "Resources" section
3. Search for resource (e.g., "instance")
4. Open resource documentation

#### Step 2: Read the Example

**Example from Documentation**:
```hcl
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```

This shows:
- Resource type: `aws_instance`
- Resource name: `example` (local identifier)
- Minimum required arguments
- Tag example

#### Step 3: Understand Arguments

**From Documentation - Arguments Reference Section**:

```
Required Arguments:
- ami (String) - AMI to use for instance
- instance_type (String) - Type of instance

Optional Arguments:
- associate_public_ip_address (Boolean) - Associate public IP
- availability_zone (String) - AZ to place instance
- ebs_block_device (Block) - EBS volume configuration
- tags (Map of String) - Tags for resource
- user_data (String) - Script to run on startup
```

#### Step 4: Understand Attributes

**From Documentation - Attributes Reference Section**:

```
Returns after creation:
- id (String) - Instance ID (e.g., i-1234567890abcdef0)
- arn (String) - ARN of instance
- private_ip (String) - Private IP address
- public_ip (String) - Public IP address (if assigned)
- vpc_security_group_ids (List) - Associated security groups
```

### Writing Your First Resource

**File**: `main.tf`

```hcl
# Example 1: Simple EC2 Instance

resource "aws_instance" "web" {
  # Required argument: AMI ID
  # From documentation: ami (String) - The AMI to use for the instance
  # Get AMI ID from AWS console or use data source
  ami = "ami-0c55b159cbfafe1f0"

  # Required argument: Instance Type
  # From documentation: instance_type (String) - The type of instance
  # Common types: t2.micro, t3.small, t3.medium, etc.
  instance_type = "t2.micro"

  # Optional argument: Root volume configuration
  # From documentation: root_block_device (Block) - Root volume settings
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  # Optional argument: User data
  # From documentation: user_data (String) - Script to run on startup
  # Note: Must be base64 encoded if binary
  user_data = base64encode(file("${path.module}/user_data.sh"))

  # Optional argument: Monitoring
  # From documentation: monitoring (Boolean) - Enable detailed monitoring
  monitoring = true

  # Optional argument: IMDSv2 (Security best practice)
  # From documentation: metadata_options (Block) - Configure metadata service
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # Forces IMDSv2
    http_put_response_hop_limit = 1
  }

  # Optional argument: Tags
  # From documentation: tags (Map of String) - Key-value tags
  tags = {
    Name        = "web-server"
    Environment = "prod"
    Owner       = "devops"
  }

  # Implicit dependency (automatic)
  # Terraform knows instance depends on security group
  vpc_security_group_ids = [aws_security_group.web.id]
}
```

### Complete Example with Multiple Resources

**File**: `main.tf`

```hcl
# Create Security Group first
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

resource "aws_security_group" "web" {
  name        = "web-security-group"
  description = "Allow HTTP and SSH traffic"

  # Ingress rule 1: SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule 2: HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule 3: HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule (allow all outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# Create Elastic IP
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

resource "aws_eip" "web" {
  domain = "vpc"

  tags = {
    Name = "web-eip"
  }

  # Depends on EC2 instance
  depends_on = [aws_instance.web]
}

# Associate Elastic IP with Instance
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association

resource "aws_eip_association" "web" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

# Create EC2 Instance
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

resource "aws_instance" "web" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  monitoring = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "web-server"
  }
}

# Create S3 Bucket
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

resource "aws_s3_bucket" "app_data" {
  bucket = "my-app-data-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "app-data"
  }
}

# Enable S3 Bucket Versioning
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable S3 Bucket Encryption
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

---

## Working with Data Sources

### What Are Data Sources?

Data sources query existing resources without creating them. Use them to:
- Find latest AMI
- Reference existing VPCs
- Get AWS account information

### How to Find Data Source Documentation

**Location**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources

**Process**:
1. Go to data sources section
2. Find the data source (e.g., `aws_ami`)
3. Read arguments and attributes

### Writing Data Sources

**File**: `main.tf` or `data.tf`

```hcl
# Data Source 1: Find Latest Amazon Linux 2 AMI
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami

data "aws_ami" "amazon_linux" {
  # Get most recent AMI
  most_recent = true

  # Only official AWS AMIs
  owners = ["amazon"]

  # Filter by name pattern
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  # Filter by virtualization type
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Filter by root device type
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Data Source 2: Get Current AWS Account
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity

data "aws_caller_identity" "current" {
  # No arguments required
  # Returns: account_id, arn, user_id
}

# Data Source 3: Find Default VPC
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc

data "aws_vpc" "default" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

# Data Source 4: Find Subnets in VPC
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1a", "ap-south-1b"]
  }
}

# Data Source 5: Find Existing Security Group
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Data Source 6: Find Existing RDS Instance
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance

data "aws_db_instance" "postgres" {
  db_instance_identifier = "my-database"
}

# Using data sources in resources

resource "aws_instance" "web" {
  # Use AMI from data source
  ami = data.aws_ami.amazon_linux.id

  instance_type = "t2.micro"

  # Use subnet from data source
  subnet_id = data.aws_subnets.default.ids[0]

  # Use security group from data source
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    # Use account ID from data source
    Owner = "Account-${data.aws_caller_identity.current.account_id}"
  }
}
```

---

## Creating Variables

### Why Use Variables?

Variables make your code reusable across environments without duplicating files.

### How to Find Variable Documentation

**Location**: https://www.terraform.io/docs/language/values/variables

### Creating Variables

**File**: `variables.tf`

```hcl
# BASIC VARIABLES
# ==============================================================================

# Variable 1: Simple String Variable
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"

  # Optional: Validation
  validation {
    condition     = contains(["ap-south-1", "us-east-1"], var.aws_region)
    error_message = "Region must be ap-south-1 or us-east-1"
  }
}

# Variable 2: Environment Selection
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  # No default = required variable
  # User must provide value

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

# Variable 3: Number Variable
variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "Instance count must be between 1 and 5"
  }
}

# Variable 4: Boolean Variable
variable "enable_monitoring" {
  description = "Enable CloudWatch detailed monitoring"
  type        = bool
  default     = false
}

# Variable 5: String with Sensitive Data
variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true  # Hidden from console output
  # No default - user must provide
}

# COMPLEX VARIABLES
# ==============================================================================

# Variable 6: List Variable
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Variable 7: Map Variable
variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
    Project   = "Infrastructure"
  }
}

# Variable 8: Object Variable (Complex Structure)
variable "instance_config" {
  description = "EC2 instance configuration"
  type = object({
    instance_type = string
    volume_size   = number
    enable_monitoring = bool
  })

  default = {
    instance_type     = "t2.micro"
    volume_size       = 20
    enable_monitoring = false
  }
}

# Variable 9: List of Objects
variable "security_group_rules" {
  description = "Security group ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))

  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Variable 10: Dynamic Any Type
variable "custom_config" {
  description = "Custom configuration (any type)"
  type        = any
  default     = {}
}

# TERRAFORM STYLE VARIABLES
# ==============================================================================

# Project naming
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

# Owner information
variable "owner_email" {
  description = "Email of resource owner"
  type        = string
}

# Cost center
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}
```

### Setting Variable Values

**Method 1: Create .tfvars File**

```hcl
# File: dev.tfvars
aws_region         = "ap-south-1"
environment        = "dev"
project_name       = "myapp"
instance_count     = 1
instance_type      = "t2.micro"
enable_monitoring  = false
owner_email        = "dev@example.com"
cost_center        = "engineering"
allowed_ssh_cidrs  = ["10.0.0.0/8", "203.0.113.0/24"]

tags = {
  Environment = "dev"
  Owner       = "dev-team"
}
```

```hcl
# File: prod.tfvars
aws_region         = "ap-south-1"
environment        = "prod"
project_name       = "myapp"
instance_count     = 3
instance_type      = "t3.large"
enable_monitoring  = true
owner_email        = "prod@example.com"
cost_center        = "operations"
allowed_ssh_cidrs  = ["10.0.0.0/8"]

tags = {
  Environment = "prod"
  Owner       = "ops-team"
}
```

**Method 2: Command Line**

```bash
terraform apply -var="instance_count=3" -var="environment=prod"
```

**Method 3: Environment Variables**

```bash
export TF_VAR_instance_count=3
export TF_VAR_environment=prod
terraform apply
```

**Method 4: Interactive Prompt**

```bash
terraform apply
# Terraform prompts for variables without defaults
```

---

## Creating Outputs

### Purpose of Outputs

Outputs export values from your infrastructure for:
- Displaying to users
- Using in other configurations
- Consuming by external tools

### How to Find Output Documentation

**Location**: https://www.terraform.io/docs/language/values/outputs

### Writing Outputs

**File**: `outputs.tf`

```hcl
# OUTPUT 1: Resource ID
output "instance_id" {
  description = "ID of created EC2 instance"
  value       = aws_instance.web.id
  # Displayed after terraform apply
}

# OUTPUT 2: Resource IP Address
output "instance_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.web.private_ip
}

# OUTPUT 3: Elastic IP
output "instance_public_ip" {
  description = "Elastic IP address"
  value       = aws_eip.web.public_ip
}

# OUTPUT 4: Connection Information
output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/key.pem ec2-user@${aws_eip.web.public_ip}"
}

# OUTPUT 5: Security Group ID
output "security_group_id" {
  description = "ID of security group"
  value       = aws_security_group.web.id
}

# OUTPUT 6: Multiple Values (Splat Syntax)
output "all_instance_ids" {
  description = "IDs of all instances"
  # Use [*] splat syntax for multiple resources
  value = aws_instance.web[*].id
}

# OUTPUT 7: Sensitive Output (Hidden)
output "database_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true  # Hidden from console
}

# OUTPUT 8: Dependent Output
output "load_balancer_dns" {
  description = "DNS name of load balancer"
  value       = aws_lb.main.dns_name
  # Terraform ensures load balancer exists first
  depends_on  = [aws_lb.main]
}

# OUTPUT 9: Computed Output
output "total_resources" {
  description = "Total resources created"
  value       = "Resources: EC2=${length(aws_instance.web)}, SG=${length([aws_security_group.web])}"
}

# OUTPUT 10: Conditional Output
output "monitoring_status" {
  description = "Monitoring status of instance"
  value       = var.enable_monitoring ? "Enabled" : "Disabled"
}

# OUTPUT 11: Map/JSON Output
output "instance_details" {
  description = "All instance details as JSON"
  value = {
    instance_id = aws_instance.web.id
    instance_type = aws_instance.web.instance_type
    public_ip = aws_eip.web.public_ip
    tags = aws_instance.web.tags
  }
}

# OUTPUT 12: Reference to Data Source
output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
```

---

## Using Locals and Expressions

### Locals: Computed Values

Locals let you compute values once and reuse them.

**File**: `locals.tf`

```hcl
locals {
  # NAMING PATTERNS
  # ==============================================================================

  # Computed naming
  instance_name = "${var.project_name}-${var.environment}-instance"
  
  sg_name = "${var.project_name}-${var.environment}-sg"
  
  s3_bucket_name = "${var.project_name}-${var.environment}-data-${data.aws_caller_identity.current.account_id}"

  # ENVIRONMENT-SPECIFIC CONFIG
  # ==============================================================================

  # Environment-based instance types
  instance_type_map = {
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
  
  selected_instance_type = local.instance_type_map[var.environment]

  # Environment-based volume sizes
  volume_size_map = {
    dev     = 20
    staging = 50
    prod    = 100
  }
  
  selected_volume_size = local.volume_size_map[var.environment]

  # COMMON TAGS
  # ==============================================================================

  # Tags applied to all resources
  common_tags = {
    Project         = var.project_name
    Environment     = var.environment
    ManagedBy       = "Terraform"
    CreatedDate     = timestamp()
    Owner           = var.owner_email
    CostCenter      = var.cost_center
  }

  # TAG MERGING
  # ==============================================================================

  # Merge common tags with resource-specific tags
  web_server_tags = merge(
    local.common_tags,
    {
      Name        = local.instance_name
      Component   = "web-server"
      Monitoring  = var.enable_monitoring ? "enabled" : "disabled"
    }
  )

  # COMPLEX CONDITIONS
  # ==============================================================================

  # Production-only settings
  prod_settings = var.environment == "prod" ? {
    backup_retention_days = 30
    enable_encryption     = true
    enable_monitoring     = true
    multi_az              = true
  } : {
    backup_retention_days = 7
    enable_encryption     = false
    enable_monitoring     = false
    multi_az              = false
  }

  # COLLECTIONS MANIPULATION
  # ==============================================================================

  # List from variables
  security_group_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidrs
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Map for easier lookup
  port_descriptions = {
    22   = "SSH"
    80   = "HTTP"
    443  = "HTTPS"
    3306 = "MySQL"
    5432 = "PostgreSQL"
  }
}

# USING LOCALS IN RESOURCES

resource "aws_instance" "web" {
  instance_type = local.selected_instance_type

  root_block_device {
    volume_size = local.selected_volume_size
  }

  tags = local.web_server_tags
}

resource "aws_security_group" "web" {
  name = local.sg_name

  tags = merge(
    local.common_tags,
    { Name = local.sg_name }
  )
}
```

---

## Using Modules

### What Are Modules?

Modules are reusable packages of Terraform code. Think of them as functions for infrastructure.

### How to Find Module Documentation

**Location 1**: https://registry.terraform.io/modules (Public Modules)

**Location 2**: Your local `./modules` directory

### Creating a Simple Module

**Directory Structure**:
```
terraform-project/
├── main.tf              # Root configuration
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── security_group/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

### Creating a VPC Module

**File**: `modules/vpc/variables.tf`

```hcl
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
```

**File**: `modules/vpc/main.tf`

```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    { Name = "vpc-${var.environment}" }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 2, 0)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    { Name = "subnet-public-${var.environment}" }
  )
}

data "aws_availability_zones" "available" {
  state = "available"
}
```

**File**: `modules/vpc/outputs.tf`

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public.id
}
```

### Using a Module

**File**: `main.tf`

```hcl
# Use local module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr    = "10.0.0.0/16"
  environment = var.environment

  tags = local.common_tags
}

# Reference module outputs
resource "aws_instance" "web" {
  subnet_id = module.vpc.subnet_id
}
```

### Using Public Modules from Registry

```hcl
# Example: Using AWS VPC module from Terraform Registry
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = local.common_tags
}
```

---

## Writing Terraform Functions

### String Functions

```hcl
locals {
  # format: Format strings like sprintf
  formatted_name = format("instance-%s-%s", var.environment, var.project_name)
  
  # join: Join list items with separator
  path_string = join("/", [var.bucket, var.prefix, var.filename])
  
  # split: Split string by separator
  parts = split(".", "example.com")  # ["example", "com"]
  
  # upper/lower: Case conversion
  env_upper = upper(var.environment)  # "PROD"
  env_lower = lower(var.environment)  # "prod"
  
  # startswith/endswith/contains: String matching
  is_prod = startswith(var.environment, "prod")
  has_backup = contains(var.tags, "backup")
  
  # substr: Substring extraction
  first_three = substr(var.project_name, 0, 3)
  
  # replace: String replacement
  clean_name = replace(var.instance_name, " ", "-")
  
  # trim: Remove whitespace
  trimmed = trim(var.value, " \t\n")
}
```

### Collection Functions

```hcl
locals {
  # length: Get collection length
  port_count = length(var.allowed_ports)
  
  # concat: Combine lists
  all_ports = concat([22], var.additional_ports)
  
  # distinct: Remove duplicates
  unique_ports = distinct(var.ports)
  
  # sort: Sort list
  sorted_ports = sort(var.ports)
  
  # reverse: Reverse list
  reversed = reverse(var.list_value)
  
  # keys/values: Get keys or values from map
  tag_keys = keys(var.tags)
  tag_values = values(var.tags)
  
  # lookup: Get value from map with default
  instance_type = lookup(local.instance_type_map, var.environment, "t2.micro")
  
  # contains: Check if list contains value
  is_allowed_port = contains([22, 80, 443], 443)
  
  # index: Find index of value in list
  port_index = index(var.ports, 80)
}
```

### Type Conversion Functions

```hcl
locals {
  # tostring/tonumber/tobool: Type conversion
  port_string = tostring(80)          # "80"
  port_number = tonumber("80")        # 80
  bool_value = tobool("true")         # true
  
  # tolist/tomap/toset: Collection conversion
  list_value = tolist(var.data)
  map_value = tomap(var.data)
  set_value = toset(var.tags)
  
  # jsonencode/jsonparse: JSON conversion
  json_string = jsonencode({
    key = "value"
  })
  parsed = jsondecode(var.json_string)
}
```

### Conditional Functions

```hcl
locals {
  # Ternary operator (most common conditional)
  instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"
  
  # try: Try value or return default on error
  value = try(var.optional_value, "default")
  
  # can: Check if expression is valid
  has_items = can(var.list[0])
  
  # if/then/else (not typical in HCL, use ternary instead)
  # Ternary: condition ? true_value : false_value
}
```

### Splat Expressions

```hcl
# Create multiple resources
resource "aws_instance" "web" {
  count = 3
}

locals {
  # Get all instance IDs
  all_ids = aws_instance.web[*].id
  
  # Get all instance IPs
  all_ips = aws_instance.web[*].private_ip
  
  # Get specific attribute from all
  all_types = aws_instance.web[*].instance_type
}

output "instance_ids" {
  value = aws_instance.web[*].id
}
```

### For Expressions

```hcl
locals {
  # Simple for expression (transform list)
  uppercase_names = [for name in var.names : upper(name)]
  
  # For with condition (filter)
  web_ports = [for port in var.ports : port if port > 1024]
  
  # Transform map
  port_map = {
    for port in var.ports : port => "port-${port}"
  }
  
  # Group by (conditional map)
  ports_by_type = {
    for rule in var.rules : rule.type => rule.port
  }
}
```

---

## Common AWS Resources Examples

### Example 1: Complete EC2 Setup

```hcl
# File: main.tf
# This creates a production-ready EC2 instance with all security best practices

# 1. Security Group
resource "aws_security_group" "web" {
  name_prefix = "web-"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id

  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

  # Ingress: SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH access"
  }

  # Ingress: HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP traffic"
  }

  # Ingress: HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS traffic"
  }

  # Egress: Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-sg" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# 2. EC2 Instance
resource "aws_instance" "web" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.selected_instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = local.selected_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  # Enable monitoring
  monitoring = var.enable_monitoring

  # User data script
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
    project     = var.project_name
  }))

  # IMDSv2 security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # CPU credits
  cpu_credits = "unlimited"

  tags = local.web_server_tags

  depends_on = [aws_security_group.web]
}

# 3. Elastic IP
resource "aws_eip" "web" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

  domain = "vpc"

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-eip" }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# 4. Associate Elastic IP
resource "aws_eip_association" "web" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association

  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.web.id
}

# 5. CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "cpu" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm

  alarm_name          = "${local.instance_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80.0
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  alarm_description = "Alert when CPU exceeds 80% for 10 minutes"
  alarm_actions     = []  # Add SNS topic ARN here
}
```

### Example 2: S3 Bucket with Security

```hcl
# Create S3 Bucket
resource "aws_s3_bucket" "app_data" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

  bucket = "my-app-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.common_tags,
    { Name = "app-data" }
  )

  lifecycle {
    prevent_destroy = true
  }
}

# Enable Versioning
resource "aws_s3_bucket_versioning" "app_data" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning

  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration

  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "app_data" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block

  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Logging
resource "aws_s3_bucket_logging" "app_data" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging

  bucket = aws_s3_bucket.app_data.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "app-data-logs/"
}
```

### Example 3: RDS Database

```hcl
# Create DB Subnet Group
resource "aws_db_subnet_group" "main" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group

  name       = "${local.instance_name}-db-subnet"
  subnet_ids = data.aws_subnets.default.ids

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-db-subnet" }
  )
}

# Create Security Group for RDS
resource "aws_security_group" "rds" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

  name_prefix = "rds-"
  description = "Security group for RDS database"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
    description     = "PostgreSQL from web servers"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    { Name = "rds-sg" }
  )
}

# Create RDS Instance
resource "aws_db_instance" "main" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance

  identifier     = "${local.instance_name}-postgres"
  engine         = "postgres"
  engine_version = "14.0"
  instance_class = var.environment == "prod" ? "db.t3.small" : "db.t3.micro"

  allocated_storage = local.selected_volume_size
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "appdb"
  username = "postgres"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.environment == "prod" ? 30 : 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  multi_az                = var.environment == "prod"

  skip_final_snapshot       = var.environment == "dev"
  final_snapshot_identifier = "${local.instance_name}-final-snapshot-${timestamp()}"

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-postgres" }
  )
}
```

### Example 4: Load Balancer

```hcl
# Create Load Balancer
resource "aws_lb" "main" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb

  name_prefix        = "web-"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = var.environment == "prod"

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-alb" }
  )
}

# Create Target Group
resource "aws_lb_target_group" "web" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group

  name_prefix = "web-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = merge(
    local.common_tags,
    { Name = "${local.instance_name}-tg" }
  )
}

# Register Targets
resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# Create Listener
resource "aws_lb_listener" "http" {
  # Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
```

---

## Testing Your Code

### Step 1: Syntax Validation

```bash
# Validate Terraform syntax
terraform validate

# Output:
# Success! The configuration is valid.
```

### Step 2: Format Checking

```bash
# Check if code is formatted correctly
terraform fmt -check -recursive

# Auto-format code
terraform fmt -recursive
```

### Step 3: Linting

```bash
# Install tflint
curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Run linter
tflint
```

### Step 4: Security Scanning

```bash
# Install checkov
pip install checkov

# Scan for security issues
checkov -d .
```

### Step 5: Plan Review

```bash
# Generate plan
terraform plan -var-file="dev.tfvars" -out=tfplan

# Review plan carefully
# Look for unexpected changes
# Verify all resources are correct
```

### Step 6: Cost Estimation

```bash
# Install infracost
curl https://rations.infracost.io/downloads/linux/infracost -o infracost
chmod +x infracost

# Estimate costs
./infracost breakdown --path tfplan
```

### Step 7: Documentation Check

```bash
# Document your resources
# Include descriptions for all variables
# Include descriptions for all outputs
# Update README.md with usage instructions
```

---

## Complete Workflow: From Documentation to Deployment

### Step 1: Understand Your Goal

```
Goal: Create a web server in AWS with:
- EC2 instance
- Security group
- Elastic IP
- CloudWatch monitoring
```

### Step 2: Find Documentation

```
Search for:
1. aws_instance
2. aws_security_group
3. aws_eip
4. aws_cloudwatch_metric_alarm
```

### Step 3: Read Examples

```
From each resource documentation:
- Copy example code
- Note required vs optional arguments
- Understand attributes (outputs)
```

### Step 4: Create Variables

```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

### Step 5: Write Resources

```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
}
```

### Step 6: Create Outputs

```hcl
# outputs.tf
output "instance_id" {
  value = aws_instance.web.id
}
```

### Step 7: Test

```bash
terraform validate
terraform plan
```

### Step 8: Deploy

```bash
terraform apply
```

### Step 9: Verify

```bash
# Check AWS console
# Verify resources were created correctly
# Test connectivity and functionality
```

### Step 10: Document

```bash
# Update README.md
# Add usage examples
# Document any manual steps
```

---

## Common Documentation Patterns

### Pattern 1: Finding a Resource Type

```
Question: How do I create an RDS database?

Answer:
1. Go to https://registry.terraform.io/providers/hashicorp/aws/latest/docs
2. Click "Resources"
3. Search for "db_instance"
4. Read aws_db_instance documentation
```

### Pattern 2: Understanding Arguments

```
From Documentation:

Arguments:
- identifier (Required) - The name of the RDS instance
- engine (Required) - Database engine (postgres, mysql, mariadb, oracle-se2, sqlserver-express)
- engine_version (Required) - Version of the database engine
- instance_class (Required) - Instance type (db.t3.micro, db.t3.small, db.m5.large)
- allocated_storage (Required) - Allocated storage in GB
```

### Pattern 3: Using Computed Values

```
From Documentation:

Returns:
- arn (String) - ARN of the RDS instance
- endpoint (String) - Connection endpoint
- hosted_zone_id (String) - Hosted zone ID

Usage:
output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}
```

---

## Key Takeaways

### Writing Terraform Code Requires:

1. **Understanding your goal** - What infrastructure do you need?
2. **Finding documentation** - Use registry.terraform.io
3. **Reading examples** - Copy and modify example code
4. **Understanding arguments** - Know which are required/optional
5. **Creating variables** - Make code reusable
6. **Testing** - Validate before deploying
7. **Documenting** - Help others understand your code

### Always Remember:

✅ Read the official documentation
✅ Start with examples from the docs
✅ Test in dev environment first
✅ Use version control
✅ Document your code
✅ Use variables for reusability
✅ Validate before applying
✅ Use outputs to share values

### Useful Resources:

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Provider Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest
- **Terraform Registry**: https://registry.terraform.io
- **HashiCorp Learn**: https://learn.hashicorp.com

---

## Practice Exercises

### Exercise 1: Create a VPC

Using https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

Create a VPC with:
- CIDR: 10.0.0.0/16
- DNS enabled
- Appropriate tags

### Exercise 2: Create a Security Group

Using https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

Create a security group with:
- SSH (22)
- HTTP (80)
- HTTPS (443)

### Exercise 3: Create an EC2 Instance with Variables

Create instance configuration that:
- Uses variable for instance type
- Uses variable for instance count
- Outputs instance IDs

### Exercise 4: Create an RDS Database

Using https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance

Create PostgreSQL database with:
- Environment-specific sizing
- Encryption enabled
- Backup retention based on environment

### Exercise 5: Create a Module

Create a reusable module for:
- VPC with subnets
- Security group
- Expose via outputs
- Use in root configuration

---

## Document Version

- **Version**: 1.0
- **Last Updated**: 2024
- **Terraform Version**: 1.0+
- **AWS Provider Version**: 5.0+

This comprehensive guide teaches you how to write Terraform code by understanding and using official documentation effectively.