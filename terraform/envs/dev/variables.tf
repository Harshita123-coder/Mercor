variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for resources"
}

variable "name_prefix" {
  type    = string
  default = "mercor-demo"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "health_path" {
  type    = string
  default = "/"
}

variable "instance_type" {
  type    = string
  default = "t3.medium"  # Upgraded from t3.small for zero-downtime test
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "max_capacity" {
  type    = number
  default = 4
}

variable "ami_id" {
  type    = string
  default = null # set to roll new AMI
}

variable "ecr_repo_name" {
  type    = string
  default = "mercor-ecs-demo"
}
