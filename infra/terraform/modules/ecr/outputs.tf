output "repository_arns" {
  description = "ECR repository ARNs keyed by application."
  value       = { for app, repo in aws_ecr_repository.application : app => repo.arn }
}

output "repository_urls" {
  description = "ECR repository URLs keyed by application."
  value       = { for app, repo in aws_ecr_repository.application : app => repo.repository_url }
}
