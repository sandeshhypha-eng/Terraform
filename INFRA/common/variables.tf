variable "region" {
  description = "AWS region"
  type        = string
}
variable "env" {
  description = "Environment name"
  type        = string
}
variable "project_name" {
  description = "Project name"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID where EC2 will be deployed"
  type        = string
  default     = ""
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}
