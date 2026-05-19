# this block tells terrafom to install what  provider 
terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "devhyphastatefile"
    key    = var.statefilekey
    region = "ap-south-1"
  }
}


# Yogesh
resource "random_string" "random_string_for_s3_bucket" {
  length  = 8
  special = false
  upper   = false
}

variable "country" {
  type = string
}
variable "statefilekey" {
  type = string
}
variable "os" {
  type = string
}

# Configure the AWS Provider
provider "aws" {
  region = var.country
}

variable "tag1" {
  type        = string
}

variable "machine_type" {
  type        = string
}
resource "aws_instance" "demo_ec2" {
    ami           = var.os
    instance_type = var.machine_type
    count = 2

    tags = {
        Name = var.tag1
    }
    }
resource "aws_s3_bucket" "demo_s3" {
  bucket = "bucket-demo-terraform-hypha-${random_string.random_string_for_s3_bucket.result}"
  bucket_namespace = "global"

    tags = {
    Name        = var.tag1
  }
  }
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.demo_s3.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.demo_s3.id
  acl    = "private"
}
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.demo_s3.id
  versioning_configuration {
    status = "Enabled"
  }
} 






output "instance_id" {
  value = aws_instance.demo_ec2[*].id
}
output "instance_public_ip" {
  value = aws_instance.demo_ec2[*].public_ip
}     
output "instance_private_ip" {
  value = {for i, ips in aws_instance.demo_ec2 : i => ips.private_ip}
}
