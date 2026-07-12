// Combined variables, resources, and outputs for ALB module

// ----------------------------- VARIABLES -----------------------------
// Variables originally from variables.tf
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_1_id" {
  description = "ID of public subnet 1"
  type        = string
}

variable "public_subnet_2_id" {
  description = "ID of public subnet 2"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "web_1_instance_id" {
  description = "ID of EC2 instance web_1"
  type        = string
}

variable "web_2_instance_id" {
  description = "ID of EC2 instance web_2"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, release, prod)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the green environment web servers"
  type        = string
  default     = ""
}

variable "ec2_security_group_id" {
  description = "Security group ID for the green environment web servers"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "EC2 instance type for the green environment web servers"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair for the green environment web servers"
  type        = string
  default     = "lc-ec2"
}

variable "green_desired_capacity" {
  description = "Desired number of green environment web servers"
  type        = number
  default     = 1
}

variable "green_min_size" {
  description = "Minimum number of green environment web servers"
  type        = number
  default     = 1
}

variable "green_max_size" {
  description = "Maximum number of green environment web servers"
  type        = number
  default     = 1
}

variable "blue_weight" {
  description = "Traffic percentage sent to the blue target group"
  type        = number
  default     = 100
}

variable "green_weight" {
  description = "Traffic percentage sent to the green target group"
  type        = number
  default     = 0
}

variable "access_logs_enabled" {
  description = "Whether to enable access logging for the load balancer"
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket used for ALB access logs. Leave null to create a bucket automatically."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "Prefix for ALB access logs in the bucket"
  type        = string
  default     = "alb-access-logs"
}


// ----------------------------- RESOURCES -----------------------------
// Resources originally from main.tf
data "aws_caller_identity" "current" {}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "alb_logs" {
  count         = var.access_logs_enabled && var.access_logs_bucket == null ? 1 : 0
  bucket        = lower("${var.environment}-web-alb-logs-${data.aws_caller_identity.current.account_id}")
  force_destroy = true

  tags = {
    Name        = "${var.environment}-web-alb-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  count  = var.access_logs_enabled && var.access_logs_bucket == null ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "alb_logs" {
  count      = var.access_logs_enabled && var.access_logs_bucket == null ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.alb_logs]

  bucket = aws_s3_bucket.alb_logs[0].id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_policy" "alb_logs" {
  count  = var.access_logs_enabled && var.access_logs_bucket == null ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowELBAccessLogs"
        Effect    = "Allow"
        Principal = { AWS = data.aws_elb_service_account.main.arn }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.alb_logs[0].arn}/*"
      }
    ]
  })
}

resource "aws_lb" "web" {
  name               = "${var.environment}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]

  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket != null ? var.access_logs_bucket : aws_s3_bucket.alb_logs[0].bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = {
    Name        = "${var.environment}-web-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.environment}-web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "${var.environment}-web-target-group"
    Environment = var.environment
  }
}

resource "aws_lb_target_group_attachment" "web_1" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.web_1_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_2" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = var.web_2_instance_id
  port             = 80
}

resource "aws_lb_target_group" "green" {
  name     = "${var.environment}-green-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "${var.environment}-green-target-group"
    Environment = var.environment
  }
}

resource "aws_launch_template" "green_web" {
  name_prefix   = "${var.environment}-green-web-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.ec2_security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Green Web Server - ${var.environment}</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-GreenWeb"
      Environment = var.environment
    }
  }
}

resource "aws_autoscaling_group" "green_web" {
  name                = "${var.environment}-green-web-asg"
  desired_capacity    = var.green_desired_capacity
  min_size            = var.green_min_size
  max_size            = var.green_max_size
  health_check_type   = "ELB"
  health_check_grace_period = 180
  target_group_arns   = [aws_lb_target_group.green.arn]
  vpc_zone_identifier = [var.public_subnet_1_id, var.public_subnet_2_id]
  launch_template {
    id      = aws_launch_template.green_web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.environment}-GreenWeb"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "green_web_cpu" {
  name                   = "${var.environment}-green-web-cpu"
  autoscaling_group_name = aws_autoscaling_group.green_web.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.web.arn
        weight = var.blue_weight
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.green_weight
      }
    }
  }
}


// ----------------------------- OUTPUTS -----------------------------
// Outputs originally from outputs.tf
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.web.dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.web.arn
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.web.arn
}

output "green_target_group_arn" {
  description = "The ARN of the green target group"
  value       = aws_lb_target_group.green.arn
}

output "green_asg_name" {
  description = "The name of the green autoscaling group"
  value       = aws_autoscaling_group.green_web.name
}

output "access_logs_bucket" {
  description = "The S3 bucket configured for ALB access logs"
  value       = var.access_logs_enabled ? (var.access_logs_bucket != null ? var.access_logs_bucket : try(aws_s3_bucket.alb_logs[0].bucket, null)) : null
}
