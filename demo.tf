# this block tells terrafom to install what  provider 
terraform { 
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
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

resource "aws_instance" "demo_ec2" {
    ami           = var.ami
    instance_type = var.instance_type

    lifecycle {
        create_before_destroy = true
        prevent_destroy = true
        ignore_changes = [tags]
    }

    tags = {
        Name = var.tag1
    }
    }
resource "aws_s3_bucket" "demo_s3" {
  bucket = var.bucket_name
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
  value = aws_instance.demo_ec2.id
}
output "instance_public_ip" {
  value = aws_instance.demo_ec2.public_ip
}     

