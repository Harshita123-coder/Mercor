resource "aws_ecr_repository" "app" {
  name = var.repo_name
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "${var.name_prefix}-ecr" }
}
