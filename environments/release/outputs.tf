# ============================================================================
# LOAD BALANCER TYPE OUTPUT
# ============================================================================
# Displays which load balancer is currently active.
# This helps identify which outputs below are available.
output "load_balancer_type" {
  description = "The type of load balancer currently active (nginx or alb)"
  value       = var.load_balancer_type
}

# ============================================================================
# NGINX LOAD BALANCER OUTPUTS
# ============================================================================
# These outputs are only available when load_balancer_type = "nginx"
# Using try() to safely reference the Nginx module, which may not exist

output "nginx_lb_public_ip" {
  description = "Public IP of the Nginx load balancer"
  value       = try(module.nginx_lb[0].nginx_lb_public_ip, null)
  
  precondition {
    condition     = var.load_balancer_type == "nginx"
    error_message = "nginx_lb_public_ip output is only available when load_balancer_type = 'nginx'"
  }
}

output "nginx_lb_public_dns" {
  description = "Public DNS name of the Nginx load balancer"
  value       = try(module.nginx_lb[0].nginx_lb_public_dns, null)
  
  precondition {
    condition     = var.load_balancer_type == "nginx"
    error_message = "nginx_lb_public_dns output is only available when load_balancer_type = 'nginx'"
  }
}

output "nginx_lb_endpoint" {
  description = "HTTP endpoint to access the application via Nginx"
  value       = try(module.nginx_lb[0].nginx_lb_endpoint, null)
  
  precondition {
    condition     = var.load_balancer_type == "nginx"
    error_message = "nginx_lb_endpoint output is only available when load_balancer_type = 'nginx'"
  }
}

output "nginx_health_check_url" {
  description = "Health check URL for Nginx LB"
  value       = try(module.nginx_lb[0].nginx_health_check_url, null)
  
  precondition {
    condition     = var.load_balancer_type == "nginx"
    error_message = "nginx_health_check_url output is only available when load_balancer_type = 'nginx'"
  }
}

# ============================================================================
# ALB LOAD BALANCER OUTPUTS
# ============================================================================
# These outputs are only available when load_balancer_type = "alb"
# Using try() to safely reference the ALB module, which may not exist

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = try(module.alb[0].alb_dns_name, null)
  
  precondition {
    condition     = var.load_balancer_type == "alb"
    error_message = "alb_dns_name output is only available when load_balancer_type = 'alb'"
  }
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = try(module.alb[0].alb_arn, null)
  
  precondition {
    condition     = var.load_balancer_type == "alb"
    error_message = "alb_arn output is only available when load_balancer_type = 'alb'"
  }
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = try(module.alb[0].target_group_arn, null)
  
  precondition {
    condition     = var.load_balancer_type == "alb"
    error_message = "target_group_arn output is only available when load_balancer_type = 'alb'"
  }
}

# ============================================================================
# INFRASTRUCTURE OUTPUTS (Available Regardless of Load Balancer Type)
# ============================================================================
# These outputs describe the underlying infrastructure and are always available

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "web_1_instance_id" {
  description = "ID of EC2 instance web_1"
  value       = module.instances.web_1_instance_id
}

output "web_2_instance_id" {
  description = "ID of EC2 instance web_2"
  value       = module.instances.web_2_instance_id
}

output "web_1_private_ip" {
  description = "Private IP of EC2 instance web_1"
  value       = module.instances.web_1_private_ip
}

output "web_2_private_ip" {
  description = "Private IP of EC2 instance web_2"
  value       = module.instances.web_2_private_ip
}
