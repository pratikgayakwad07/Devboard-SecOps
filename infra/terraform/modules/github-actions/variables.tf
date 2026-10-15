variable "project_name" {
  description = "Project name used in IAM role names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the IAM roles."
  type        = string
}

variable "github_branch" {
  description = "Git branch allowed to assume the production IAM roles."
  type        = string
}

variable "cluster_arn" {
  description = "EKS cluster ARN the deployment role may describe."
  type        = string
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the image publisher may write."
  type        = map(string)
}

variable "database_secret_arn" {
  description = "RDS-managed Secrets Manager secret ARN the deployer may read."
  type        = string
}

variable "common_tags" {
  description = "Common organization tags passed to resources in this module."
  type        = map(string)
}
