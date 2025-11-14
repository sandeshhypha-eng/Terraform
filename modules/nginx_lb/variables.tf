variable "ami_id" {
  description = "AMI ID for Nginx load balancer instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Nginx LB"
  type        = string
  default     = "t2.micro"
}

variable "public_subnet_id" {
  description = "ID of public subnet for Nginx LB"
  type        = string
}

variable "nginx_security_group_id" {
  description = "ID of the Nginx security group"
  type        = string
}

variable "web_1_private_ip" {
  description = "Private IP of web server 1"
  type        = string
}

variable "web_2_private_ip" {
  description = "Private IP of web server 2"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, release, prod)"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair to use for Nginx LB instance"
  type        = string
  default     = "lc-ec2"
}

