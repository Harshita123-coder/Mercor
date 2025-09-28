# Backend configuration for remote state storage
# Commented out for local testing - uncomment and configure for production
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "mercor-ecs-bluegreen/dev/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }