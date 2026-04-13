# Terraform Variables
# Define variables at the root level or use environment variables

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name for resource tagging and naming"
  type        = string
  default     = "tejasatkireadmin"
}

variable "environment" {
  description = "Environment name (e.g., production, staging, development)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = "Optional custom domain name for CloudFront (leave empty for default domain)"
  type        = string
  default     = ""
}
