output "aws_region" {
  description = "AWS region containing the deployment."
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS account ID containing the deployment."
  value       = data.aws_caller_identity.current.account_id
}

output "eks_cluster_name" {
  description = "EKS cluster name for GitHub Actions."
  value       = module.eks.cluster_name
}

output "github_ecr_push_role_arn" {
  description = "IAM role ARN for the GitHub Actions image-push workflow."
  value       = module.github_actions.ecr_push_role_arn
}

output "github_cluster_deployer_role_arn" {
  description = "IAM role ARN for the GitHub Actions EKS deployment workflow."
  value       = module.github_actions.cluster_deployer_role_arn
}

output "ecr_repository_urls" {
  description = "Immutable ECR repository URLs keyed by application."
  value       = module.ecr.repository_urls
}

output "ecr_repository_prefix" {
  description = "Project prefix for the backend and frontend ECR repositories."
  value       = var.project_name
}

output "postgres_endpoint" {
  description = "Private RDS PostgreSQL endpoint."
  value       = module.database.endpoint
}

output "postgres_secret_arn" {
  description = "RDS-managed master credential secret ARN for GitHub Actions."
  value       = module.database.master_secret_arn
}

output "bootstrap_kubernetes_access_commands" {
  description = "Run these once using an administrator kubeconfig to create the restricted deployment namespace and RoleBinding."
  value = [
    "kubectl apply -f k8s/namespace.yaml",
    "kubectl apply -f k8s/rbac/deployer-rolebinding.yaml",
  ]
}
