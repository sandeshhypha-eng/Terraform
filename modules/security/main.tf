// Combined variables, resources, and outputs for Security module

// ----------------------------- VARIABLES -----------------------------
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, release, prod)"
  type        = string
}


// ----------------------------- RESOURCES -----------------------------
resource "aws_security_group" "ec2" {
  name        = "${var.environment}-ec2-security-group"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id, aws_security_group.nginx_lb.id]
    description     = "Allow HTTP from ALB and Nginx LB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-ec2-security-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-alb-security-group"
    Environment = var.environment
  }
}

# ============================================================================
# NGINX LOAD BALANCER SECURITY GROUP
# ============================================================================
# Security group for Nginx reverse proxy/load balancer instance
resource "aws_security_group" "nginx_lb" {
  name        = "${var.environment}-nginx-lb-security-group"
  description = "Security group for Nginx load balancer instance"
  vpc_id      = var.vpc_id

  # Allow HTTP from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  # Allow HTTPS from internet (if needed in future)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  # Allow SSH for management (restrict this in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH (restrict in production)"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.environment}-nginx-lb-security-group"
    Environment = var.environment
    Role        = "LoadBalancer"
  }
}


// ----------------------------- OUTPUTS -----------------------------
output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "nginx_lb_security_group_id" {
  description = "ID of the Nginx load balancer security group"
  value       = aws_security_group.nginx_lb.id
}
