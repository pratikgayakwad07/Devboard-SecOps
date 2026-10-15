variable "aws_region" {
  description = "AWS region for the DevBoard infrastructure."
  type        = string
}

variable "project_name" {
  description = "Short project name used in resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,29}$", var.project_name))
    error_message = "Project name must be 2-30 lowercase letters, digits, or hyphens and start with a letter."
  }
}

variable "environment" {
  description = "Deployment environment name, such as dev, staging, or prod."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,14}$", var.environment))
    error_message = "Environment must be 2-15 lowercase letters, digits, or hyphens and start with a letter."
  }
}

variable "owner" {
  description = "Team or person responsible for this infrastructure."
  type        = string
}

variable "cost_center" {
  description = "Cost allocation identifier applied as a common tag."
  type        = string
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name allowed to assume the CI/CD roles."
  type        = string
}

variable "github_branch" {
  description = "Branch permitted to assume the production CI/CD roles."
  type        = string
}

variable "availability_zones" {
  description = "At least two availability zones in the selected AWS region."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for EKS and RDS."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "One public subnet CIDR per availability zone."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "Provide exactly one public subnet CIDR per availability zone."
  }
}

variable "private_subnet_cidrs" {
  description = "One private EKS subnet CIDR per availability zone."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "Provide exactly one private subnet CIDR per availability zone."
  }
}

variable "database_subnet_cidrs" {
  description = "One isolated database subnet CIDR per availability zone."
  type        = list(string)

  validation {
    condition     = length(var.database_subnet_cidrs) == length(var.availability_zones)
    error_message = "Provide exactly one database subnet CIDR per availability zone."
  }
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway to reduce cost; set false for one NAT gateway per AZ."
  type        = bool
}

variable "eks_cluster_version" {
  description = "Supported EKS Kubernetes minor version, for example 1.33."
  type        = string
}

variable "eks_endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the EKS public API endpoint. Use trusted runner/admin egress CIDRs only."
  type        = list(string)

  validation {
    condition = (
      length(var.eks_endpoint_public_access_cidrs) > 0 &&
      alltrue([for cidr in var.eks_endpoint_public_access_cidrs : can(cidrhost(cidr, 0))])
    )
    error_message = "Provide valid CIDRs for trusted EKS API clients."
  }
}

variable "node_instance_types" {
  description = "EC2 instance types allowed for the EKS managed node group."
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum EKS worker node count."
  type        = number

  validation {
    condition     = var.node_min_size >= 1
    error_message = "At least one EKS worker node is required."
  }
}

variable "node_desired_size" {
  description = "Initial desired EKS worker node count."
  type        = number

  validation {
    condition     = var.node_desired_size >= var.node_min_size && var.node_desired_size <= var.node_max_size
    error_message = "The desired worker count must be between the minimum and maximum counts."
  }
}

variable "node_max_size" {
  description = "Maximum EKS worker node count."
  type        = number

  validation {
    condition     = var.node_max_size >= var.node_min_size
    error_message = "The maximum worker count cannot be less than the minimum count."
  }
}

variable "node_disk_size_gib" {
  description = "Encrypted EBS root volume size for each EKS worker, in GiB."
  type        = number
}

variable "postgres_engine_version" {
  description = "RDS PostgreSQL engine version supported in the selected region."
  type        = string
}

variable "postgres_database_name" {
  description = "Initial PostgreSQL database name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,62}$", var.postgres_database_name))
    error_message = "PostgreSQL database names must start with a letter and contain only letters, digits, and underscores."
  }
}

variable "postgres_master_username" {
  description = "RDS master username. The password is generated and managed by RDS in Secrets Manager."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,15}$", var.postgres_master_username))
    error_message = "The RDS master username must start with a letter and contain at most 16 letters, digits, or underscores."
  }
}

variable "postgres_instance_class" {
  description = "RDS PostgreSQL instance class."
  type        = string
}

variable "postgres_allocated_storage_gib" {
  description = "Initial RDS storage allocation in GiB."
  type        = number

  validation {
    condition     = var.postgres_allocated_storage_gib >= 20
    error_message = "RDS PostgreSQL storage must be at least 20 GiB."
  }
}

variable "postgres_max_allocated_storage_gib" {
  description = "RDS storage autoscaling limit in GiB."
  type        = number

  validation {
    condition     = var.postgres_max_allocated_storage_gib >= var.postgres_allocated_storage_gib
    error_message = "Maximum RDS storage must be greater than or equal to allocated storage."
  }
}

variable "postgres_backup_retention_days" {
  description = "RDS automated backup retention period in days."
  type        = number
}

variable "postgres_multi_az" {
  description = "Enable a standby RDS instance in another availability zone."
  type        = bool
}

variable "postgres_deletion_protection" {
  description = "Enable RDS deletion protection."
  type        = bool
}

variable "postgres_skip_final_snapshot" {
  description = "Skip the final snapshot when destroying the RDS instance. Keep false for production."
  type        = bool
}

variable "postgres_final_snapshot_identifier" {
  description = "Unique RDS final snapshot identifier used when skip_final_snapshot is false."
  type        = string

  validation {
    condition = (
      length(var.postgres_final_snapshot_identifier) >= 1 &&
      length(var.postgres_final_snapshot_identifier) <= 255 &&
      can(regex("^[a-z]([a-z0-9-]*[a-z0-9])?$", var.postgres_final_snapshot_identifier))
    )
    error_message = "The final snapshot identifier must start with a letter and contain only lowercase letters, digits, or hyphens."
  }
}
