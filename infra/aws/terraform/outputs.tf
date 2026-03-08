output "alb_dns_name" {
  value       = aws_lb.api.dns_name
  description = "Public ALB DNS"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.api.repository_url
  description = "ECR repository URL"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.app.name
  description = "ECS cluster name"
}

output "db_endpoint" {
  value       = aws_db_instance.app.address
  description = "RDS endpoint"
}

output "redis_endpoint" {
  value       = aws_elasticache_replication_group.app.primary_endpoint_address
  description = "Redis endpoint"
}

