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
  region = "ap-southeast-2"
}

variable "tag1" {
  type        = string
  default     = "this is created from terrform for dev"
}

resource "aws_instance" "demo_ec2" {
    ami           = "ami-0296bce20908d4ab5"
    instance_type = "t3.micro"

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
  bucket = "bucket-demo-terraform-hypha"
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
