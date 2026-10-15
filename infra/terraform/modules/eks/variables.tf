variable "project_name" {
  description = "Project name used in cluster resource names."
  type        = string
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version and EKS-optimized AMI version."
  type        = string
}

variable "vpc_id" {
  description = "VPC hosting the EKS cluster."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the EKS control plane and managed nodes."
  type        = list(string)
}

variable "endpoint_public_access_cidrs" {
  description = "Trusted CIDRs permitted to access the EKS public API."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
}

variable "node_min_size" {
  description = "Minimum managed worker count."
  type        = number
}

variable "node_desired_size" {
  description = "Initial desired managed worker count."
  type        = number
}

variable "node_max_size" {
  description = "Maximum managed worker count."
  type        = number
}

variable "node_disk_size_gib" {
  description = "Encrypted worker root volume size in GiB."
  type        = number
}

variable "common_tags" {
  description = "Common organization tags passed to resources in this module."
  type        = map(string)
}
