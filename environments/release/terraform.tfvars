aws_region          = "us-east-1"
environment         = "release"
vpc_cidr            = "10.1.0.0/16"
public_subnet_1_cidr = "10.1.1.0/24"
public_subnet_2_cidr = "10.1.2.0/24"
instance_type       = "t2.small"
nginx_instance_type = "t2.small"

# Load Balancer Configuration
# Options: "nginx" (currently active) or "alb" (for future use)
load_balancer_type  = "nginx"
