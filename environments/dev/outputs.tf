# ============================================================================
# OUTPUT: Load Balancer Configuration
# ============================================================================
output "load_balancer_type" {
  description = "Currently active load balancer type"
  value       = var.load_balancer_type
}

# ============================================================================
# OUTPUT: Nginx Load Balancer Outputs (Active when load_balancer_type = nginx)
# ============================================================================
# These outputs show the Nginx load balancer details
#
# Usage:
#   1. Copy the Nginx LB public IP from this output
#   2. Open it in a web browser: http://{nginx_lb_public_ip}
#   3. You should see "Hello from EC2 Instance 1" or "Instance 2"
#   4. Refresh multiple times to see load balancing in action
#
# Important Notes:
#   - The Nginx LB will take 1-2 minutes to fully start up
#   - Backend health checks are automatically configured
#   - Traffic is distributed using round-robin load balancing
# ============================================================================
output "nginx_lb_public_ip" {
  description = "Public IP of the Nginx load balancer"
  value       = try(module.nginx_lb[0].nginx_lb_public_ip, null)
  precondition {
    condition     = var.load_balancer_type == "nginx"
    error_message = "nginx_lb outputs are only available when load_balancer_type = 'nginx'"
  }
}

output "nginx_lb_public_dns" {
  description = "Public DNS name of the Nginx load balancer"
  value       = try(module.nginx_lb[0].nginx_lb_public_dns, null)
}

output "nginx_lb_endpoint" {
  description = "HTTP endpoint to access the application via Nginx LB"
  value       = try(module.nginx_lb[0].nginx_lb_endpoint, null)
}

output "nginx_health_check_url" {
  description = "Health check URL for Nginx LB"
  value       = try(module.nginx_lb[0].nginx_health_check_url, null)
}

# ============================================================================
# OUTPUT: ALB Outputs (Active when load_balancer_type = alb)
# ============================================================================
# These outputs show the Application Load Balancer details
# Only available when ALB is enabled (load_balancer_type = "alb")
# ============================================================================
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = try(module.alb[0].alb_dns_name, null)
  precondition {
    condition     = var.load_balancer_type == "alb"
    error_message = "ALB outputs are only available when load_balancer_type = 'alb'"
  }
}

output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = try(module.alb[0].alb_arn, null)
}

output "alb_endpoint" {
  description = "HTTP endpoint to access the application via ALB"
  value       = try("http://${module.alb[0].alb_dns_name}", null)
}

# ============================================================================
# OUTPUT: VPC ID
# ============================================================================
# The unique identifier of the VPC created for this environment.
# Useful for:
#   - AWS CLI commands
#   - Manual resource inspection in AWS Console
#   - Integration with other Terraform configurations
#   - Troubleshooting network issues
# ============================================================================
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

# ============================================================================
# OUTPUT: Web Server 1 Instance ID
# ============================================================================
# The unique identifier of the first EC2 instance.
# Useful for:
#   - SSH access (if you add SSH keys later)
#   - AWS CLI commands
#   - Monitoring and logging
#   - Manual instance management
# ============================================================================
output "web_1_instance_id" {
  description = "ID of EC2 instance web_1"
  value       = module.instances.web_1_instance_id
}

# ============================================================================
# OUTPUT: Web Server 2 Instance ID
# ============================================================================
# The unique identifier of the second EC2 instance.
# Same purpose as web_1_instance_id but for the second instance.
# Useful for verifying both instances are running and healthy.
# ============================================================================
output "web_2_instance_id" {
  description = "ID of EC2 instance web_2"
  value       = module.instances.web_2_instance_id
}

