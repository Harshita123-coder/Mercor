# Backend configuration for remote state storage
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "mercor-ecs-bluegreen/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}