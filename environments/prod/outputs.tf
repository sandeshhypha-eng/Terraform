output "load_balancer_type" {
  description = "Currently active load balancer type"
  value       = var.load_balancer_type
}

output "nginx_lb_public_ip" {
  description = "Public IP of the Nginx load balancer"
  value       = try(module.nginx_lb[0].nginx_lb_public_ip, null)
}

output "nginx_lb_endpoint" {
  description = "HTTP endpoint to access the application via Nginx LB"
  value       = try(module.nginx_lb[0].nginx_lb_endpoint, null)
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = try(module.alb[0].alb_dns_name, null)
}

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

