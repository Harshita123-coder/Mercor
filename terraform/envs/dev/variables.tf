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
  type        = string
  default     = "t3.small"  # Start with small for infrastructure upgrade demo
  description = "EC2 instance type - change this to demonstrate zero-downtime infrastructure updates"
}

variable "desired_capacity" {
  type        = number
  default     = 2  # Start with 2 instances
  description = "Desired number of EC2 instances in Auto Scaling Group"
}

variable "max_capacity" {
  type        = number
  default     = 6  # Allow scaling up to 6 for demonstration
  description = "Maximum number of EC2 instances in Auto Scaling Group"
}

variable "ami_id" {
  type        = string
  default     = null # Will use latest ECS-optimized AMI
  description = "Specific AMI ID to use - set to force AMI updates for zero-downtime demo"
}

variable "ecr_repo_name" {
  type    = string
  default = "mercor-ecs-demo"
}

# INTERVIEWER DEMONSTRATION: Zero-Downtime Infrastructure Updates
# This demonstrates enterprise-grade DevOps capabilities:
# - Infrastructure as Code with Terraform
# - Zero-downtime deployments with continuous monitoring  
# - Blue/Green deployment strategies
# - Production-ready scaling and high availability

# Test variables for zero-downtime infrastructure updates
variable "test_environment" {
  type        = string
  default     = "verification_test"  # VERIFICATION: Final test environment
  description = "Environment label for testing infrastructure changes"
}

variable "monitoring_enabled" {
  type        = bool
  default     = true
  description = "Enable comprehensive monitoring during deployments"
}

variable "deployment_strategy" {
  type        = string
  default     = "blue_green"
  description = "Deployment strategy for zero-downtime updates"
}
