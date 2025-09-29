resource "aws_security_group" "alb" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "blue" {
  name        = "${var.name_prefix}-tg-blue"
  vpc_id      = var.vpc_id
  port        = var.port
  protocol    = "HTTP"
  target_type = "instance"
  
  health_check {
    path                = var.health_path
    matcher             = "200-399"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    port                = "traffic-port"  # For dynamic port mapping
  }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.name_prefix}-tg-green"
  vpc_id      = var.vpc_id
  port        = var.port
  protocol    = "HTTP"
  target_type = "instance"
  
  health_check {
    path                = var.health_path
    matcher             = "200-399"
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
    port                = "traffic-port"  # For dynamic port mapping
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}
