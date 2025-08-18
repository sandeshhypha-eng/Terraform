terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "myinfra-dev-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

module "common" {
  source       = "../../common"
  region       = var.region
  env          = var.env
  project_name = var.project_name
  subnet_id    = var.subnet_id
  vpc_id       = var.vpc_id
}
