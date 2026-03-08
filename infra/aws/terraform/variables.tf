variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-northeast-2"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "sujin-tms"
}

variable "db_username" {
  type        = string
  description = "Database username"
  default     = "postgres"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "app_image" {
  type        = string
  description = "ECR image URI for FastAPI"
  default     = ""
}

variable "desired_count" {
  type        = number
  description = "Desired ECS task count"
  default     = 2
}
