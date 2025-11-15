variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.2.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.2.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "nginx_instance_type" {
  description = "EC2 instance type for Nginx load balancer"
  type        = string
  default     = "t2.small"
}

variable "load_balancer_type" {
  description = "Type of load balancer to use: nginx or alb"
  type        = string
  default     = "alb"
  
  validation {
    condition     = contains(["nginx", "alb"], var.load_balancer_type)
    error_message = "load_balancer_type must be either 'nginx' or 'alb'"
  }
}

