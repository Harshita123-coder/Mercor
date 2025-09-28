# Service role for CodeDeploy
data "aws_iam_policy_document" "cd_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "cd_role" {
  name               = "${var.name_prefix}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.cd_assume.json
}
resource "aws_iam_role_policy_attachment" "cd_policy" {
  role       = aws_iam_role.cd_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_codedeploy_app" "app" {
  name             = "${var.name_prefix}-cd-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "dg" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "${var.name_prefix}-dg"
  service_role_arn      = aws_iam_role.cd_role.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }
      target_group {
        name = var.tg_blue_name
      }
      target_group {
        name = var.tg_green_name
      }
    }
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                         = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }
}
