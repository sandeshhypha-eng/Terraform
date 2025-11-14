// Combined variables, resources, and outputs for Instances module

// ----------------------------- VARIABLES -----------------------------
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
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

variable "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, release, prod)"
  type        = string
}


// ----------------------------- RESOURCES -----------------------------
resource "aws_instance" "web_1" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_1_id

  vpc_security_group_ids = [var.ec2_security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from EC2 Instance 1 - ${var.environment}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.environment}-WebServer-1"
    Environment = var.environment
  }
}

resource "aws_instance" "web_2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_2_id

  vpc_security_group_ids = [var.ec2_security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from EC2 Instance 2 - ${var.environment}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "${var.environment}-WebServer-2"
    Environment = var.environment
  }
}


// ----------------------------- OUTPUTS -----------------------------
output "web_1_instance_id" {
  description = "ID of EC2 instance web_1"
  value       = aws_instance.web_1.id
}

output "web_2_instance_id" {
  description = "ID of EC2 instance web_2"
  value       = aws_instance.web_2.id
}

output "web_1_private_ip" {
  description = "Private IP of EC2 instance web_1"
  value       = aws_instance.web_1.private_ip
}

output "web_2_private_ip" {
  description = "Private IP of EC2 instance web_2"
  value       = aws_instance.web_2.private_ip
}
