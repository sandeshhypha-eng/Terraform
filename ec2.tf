##############################################
# Terraform Configuration to Create EC2
# Single File with All Components
# Author: ChatGPT (GPT-5)
##############################################

# -------------------------------
# Terraform Settings and Backend
# -------------------------------
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Uncomment if you want to use remote state (e.g., S3)
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "ec2-instance/terraform.tfstate"
  #   region         = "ap-south-1"
  # }
}

# -------------------------------
# Provider Configuration
# -------------------------------
provider "aws" {
  region = var.aws_region
}

# -------------------------------
# Variables
# -------------------------------

# AWS region to deploy resources
variable "aws_region" {
  description = "AWS region to launch the EC2 instance"
  type        = string
  default     = "ap-south-1"
}

# EC2 instance AMI ID
variable "ami_id" {
  description = "Amazon Machine Image ID for EC2"
  type        = string
  default     = "ami-0e306788ff2473ccb" # Amazon Linux 2 for ap-south-1
}

# EC2 instance type
variable "instance_type" {
  description = "Type of EC2 instance to create"
  type        = string
  default     = "t2.micro"
}

# Key pair for SSH access
variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
  default     = "free"
}

# Security group name
variable "sg_name" {
  description = "Name for the security group"
  type        = string
  default     = "ec2-sg"
}

# -------------------------------
# Data Sources
# -------------------------------
data "aws_vpc" "default" {
  default = true
}


# -------------------------------
# Resource: Security Group
# -------------------------------
resource "aws_security_group" "ec2_sg" {
  name        = var.sg_name
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "hhtps"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-Security-Group"
  }
}

# -------------------------------
# Resource: EC2 Instance
# -------------------------------
resource "aws_instance" "ec2_demo_createdfrom_terraform" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = "subnet-06195ae2a16cf7c5e"
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name        = "Terraform-EC2"
    Environment = "Demo"
  }
}

# -------------------------------
# Outputs
# -------------------------------
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.ec2_demo_createdfrom_terraform.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2_demo_createdfrom_terraform.public_ip
}

output "region" {
  description = "AWS region used for deployment"
  value       = var.aws_region
}
