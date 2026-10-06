output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.main.port
}

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer"
  value       = aws_lb.main.dns_name
}

output "app_1_public_ip" {
  description = "Public IP of application server 1"
  value       = aws_instance.app_1.public_ip
}

output "app_2_public_ip" {
  description = "Public IP of application server 2"
  value       = aws_instance.app_2.public_ip
}

output "ecr_repository_url" {
  description = "ECR repository URL for the application image"
  value       = aws_ecr_repository.app.repository_url
}