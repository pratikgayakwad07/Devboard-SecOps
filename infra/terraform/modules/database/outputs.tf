output "endpoint" {
  description = "Private PostgreSQL hostname and port."
  value       = aws_db_instance.this.endpoint
}

output "master_secret_arn" {
  description = "RDS-managed master credential secret ARN."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
