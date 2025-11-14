output "nginx_lb_instance_id" {
  description = "ID of Nginx load balancer instance"
  value       = aws_instance.nginx_lb.id
}

output "nginx_lb_private_ip" {
  description = "Private IP of Nginx load balancer"
  value       = aws_instance.nginx_lb.private_ip
}

output "nginx_lb_public_ip" {
  description = "Public IP of Nginx load balancer"
  value       = aws_instance.nginx_lb.public_ip
}

output "nginx_lb_public_dns" {
  description = "Public DNS name of Nginx load balancer"
  value       = aws_instance.nginx_lb.public_dns
}

output "nginx_lb_endpoint" {
  description = "Endpoint to access the application through Nginx LB"
  value       = "http://${aws_instance.nginx_lb.public_ip}"
}

output "nginx_lb_endpoint_dns" {
  description = "DNS endpoint to access the application"
  value       = "http://${aws_instance.nginx_lb.public_dns}"
}

output "nginx_health_check_url" {
  description = "Health check URL for Nginx LB"
  value       = "http://${aws_instance.nginx_lb.public_ip}/health"
}

output "nginx_status_url" {
  description = "Nginx status page URL (requires SSH tunnel from localhost)"
  value       = "http://${aws_instance.nginx_lb.private_ip}:80/nginx_status"
}
