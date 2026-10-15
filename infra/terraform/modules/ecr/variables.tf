variable "project_name" {
  description = "Project name used in ECR repository names."
  type        = string
}

variable "common_tags" {
  description = "Common organization tags passed to resources in this module."
  type        = map(string)
}
