output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  value = aws_ecs_service.main.name
}

output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The public DNS name of the ALB"
}
