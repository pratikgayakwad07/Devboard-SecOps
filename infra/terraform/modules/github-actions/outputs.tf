output "ecr_push_role_arn" {
  description = "IAM role ARN for publishing application images."
  value       = aws_iam_role.ecr_push.arn
}

output "cluster_deployer_role_arn" {
  description = "IAM role ARN for deploying to EKS and reading the RDS credential."
  value       = aws_iam_role.cluster_deployer.arn
}
