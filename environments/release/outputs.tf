output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.alb_dns_name
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

