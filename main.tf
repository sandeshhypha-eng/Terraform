terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "tag1" {
  type        = string
  description = "Tag for resources"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "ami" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
}

# Call the EC2 module
module "ec2" {
  source = "./modules/ec2"

  ami           = var.ami
  instance_type = var.instance_type
  tag1          = var.tag1
}

# Call the S3 module
module "s3" {
  source = "./modules/s3"

  bucket_name = var.bucket_name
  tag1        = var.tag1
}

# Outputs
output "instance_id" {
  value = module.ec2.instance_id
}

output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}