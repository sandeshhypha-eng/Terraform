aws_region          = "us-east-1"
environment         = "dev"
vpc_cidr            = "10.0.0.0/16"
public_subnet_1_cidr = "10.0.1.0/24"
public_subnet_2_cidr = "10.0.2.0/24"
instance_type       = "t2.micro"
nginx_instance_type = "t2.micro"

# Load Balancer Configuration
# Options: "nginx" (currently active) or "alb" (for future use)
load_balancer_type  = "nginx"
