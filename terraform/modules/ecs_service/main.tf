# Task execution role
data "aws_iam_policy_document" "ecs_tasks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "task_exec" {
  name               = "${var.name_prefix}-task-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume.json
}
resource "aws_iam_role_policy_attachment" "exec_ecr" {
  role       = aws_iam_role.task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "lg" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.name_prefix}-task"
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.task_exec.arn

  container_definitions = jsonencode([{
    name="app",
    image="${var.repo_url}:latest",
    essential=true,
    portMappings=[{containerPort=var.container_port, hostPort=0}], # Dynamic port mapping
    environment=[{name="APP_MSG", value="Hello from v5 (green) - Zero Downtime Test!"}],
    logConfiguration={
      logDriver="awslogs",
      options={
        awslogs-group=aws_cloudwatch_log_group.lg.name,
        awslogs-region=var.region,
        awslogs-stream-prefix="ecs"
      }
    }
  }])
}

# ECS service with CodeDeploy controller for blue/green deployments
resource "aws_ecs_service" "svc" {
  name            = "${var.name_prefix}-svc"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 0  # CodeDeploy manages desired count
  launch_type     = "EC2"

  # Use CodeDeploy for blue/green deployments
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = var.tg_blue_arn
    container_name   = "app"
    container_port   = var.container_port
  }
}
