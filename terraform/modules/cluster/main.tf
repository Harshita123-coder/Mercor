resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}-cluster"
  setting { name="containerInsights" value="enabled" }
}

resource "aws_cloudwatch_log_group" "lg" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 7
}
