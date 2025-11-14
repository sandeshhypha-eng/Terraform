# ============================================================================
# OUTPUT: ALB DNS Name
# ============================================================================
# This is the most important output - the public URL to access your application.
# After running `terraform apply`, this DNS name will be displayed.
#
# Usage:
#   1. Copy the DNS name from the terraform output
#   2. Open it in a web browser: http://{alb_dns_name}
#   3. You should see "Hello from EC2 Instance 1" or "Instance 2"
#   4. Refresh multiple times to see load balancing in action
#
# Important Notes:
#   - Wait 2-5 minutes after deployment for DNS propagation
#   - Ensure target group health checks are passing before accessing
#   - The DNS name format: {name}-{random-id}.{region}.elb.amazonaws.com
#
# Example: dev-web-alb-1234567890.us-east-1.elb.amazonaws.com
# ============================================================================
output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
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

