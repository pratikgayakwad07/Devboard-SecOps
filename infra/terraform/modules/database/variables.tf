variable "project_name" {
  description = "Project name used in database resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "vpc_id" {
  description = "VPC that hosts the database."
  type        = string
}

variable "database_subnet_ids" {
  description = "Isolated subnet IDs used by the RDS subnet group."
  type        = list(string)
}

variable "eks_node_security_group_id" {
  description = "Only worker nodes in this security group can connect to PostgreSQL."
  type        = string
}

variable "engine_version" {
  description = "RDS PostgreSQL engine version."
  type        = string
}

variable "database_name" {
  description = "Initial database name."
  type        = string
}

variable "master_username" {
  description = "RDS master username; RDS manages the generated password in Secrets Manager."
  type        = string
}

variable "instance_class" {
  description = "RDS PostgreSQL instance class."
  type        = string
}

variable "allocated_storage_gib" {
  description = "Initial allocated storage in GiB."
  type        = number
}

variable "max_allocated_storage_gib" {
  description = "Maximum autoscaled storage in GiB."
  type        = number
}

variable "backup_retention_days" {
  description = "Automated backup retention days."
  type        = number
}

variable "multi_az" {
  description = "Whether to create a Multi-AZ standby instance."
  type        = bool
}

variable "deletion_protection" {
  description = "Whether to prevent accidental RDS deletion."
  type        = bool
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final RDS snapshot on deletion."
  type        = bool
}

variable "final_snapshot_identifier" {
  description = "Unique final RDS snapshot name used when a final snapshot is created."
  type        = string
}

variable "common_tags" {
  description = "Common organization tags passed to resources in this module."
  type        = map(string)
}
