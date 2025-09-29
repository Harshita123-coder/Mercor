# Security group for ECS hosts: allow ALB -> container port
resource "aws_security_group" "ecs_hosts" {
  name   = "${var.name_prefix}-ecs-hosts-sg"
  vpc_id = var.vpc_id
  
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS optimized AL2023 AMI
data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-x86_64"]
  }
}

locals { 
  effective_ami = coalesce(var.ami_id, data.aws_ami.ecs.id) 
}

# Instance profile & role
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance" {
  name               = "${var.name_prefix}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.name_prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}

# User data to join cluster
locals { 
  userdata = base64encode(<<-EOF
    #!/bin/bash
    # Update system
    yum update -y
    
    # Install ECS agent if not present
    yum install -y ecs-init
    
    # Ensure ecs.config directory exists
    mkdir -p /etc/ecs
    
    # Set ECS cluster name and enable task IAM roles
    cat > /etc/ecs/ecs.config << EOL
ECS_CLUSTER=${var.cluster_name}
ECS_ENABLE_CONTAINER_METADATA=true
ECS_ENABLE_LOGGING=true
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true
ECS_BACKEND_HOST=
ECS_ENABLE_SPOT_INSTANCE_DRAINING=false
ECS_DISABLE_IMAGE_CLEANUP=false
ECS_IMAGE_CLEANUP_INTERVAL=30m
ECS_IMAGE_MINIMUM_CLEANUP_AGE=1h
EOL
    
    # Start and enable ECS service - try multiple service names
    if systemctl list-unit-files | grep -q ecs.service; then
        systemctl enable ecs
        systemctl start ecs
        echo "Started ecs.service" >> /var/log/ecs-startup.log
    elif systemctl list-unit-files | grep -q ecs-init.service; then
        systemctl enable ecs-init
        systemctl start ecs-init
        echo "Started ecs-init.service" >> /var/log/ecs-startup.log
    else
        # Try starting ECS agent directly
        /usr/bin/ecs-init start
        echo "Started ECS agent directly" >> /var/log/ecs-startup.log
    fi
    
    # Wait a moment for service to start
    sleep 10
    
    # Log everything for debugging
    echo "=== ECS Startup Log $(date) ===" > /var/log/ecs-startup.log
    echo "== ECS Config ==" >> /var/log/ecs-startup.log
    cat /etc/ecs/ecs.config >> /var/log/ecs-startup.log
    echo "== Service Status ==" >> /var/log/ecs-startup.log
    systemctl status ecs >> /var/log/ecs-startup.log 2>&1 || echo "ecs.service not found" >> /var/log/ecs-startup.log
    systemctl status ecs-init >> /var/log/ecs-startup.log 2>&1 || echo "ecs-init.service not found" >> /var/log/ecs-startup.log
    echo "== Docker Status ==" >> /var/log/ecs-startup.log
    systemctl status docker >> /var/log/ecs-startup.log 2>&1
    echo "== Network Test ==" >> /var/log/ecs-startup.log
    curl -I https://ecs.us-east-1.amazonaws.com >> /var/log/ecs-startup.log 2>&1
  EOF
  )
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = local.effective_ami
  instance_type = var.instance_type
  
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }
  
  user_data = local.userdata
  
  network_interfaces {
    security_groups = [aws_security_group.ecs_hosts.id]
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name_prefix}-ecs-host"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.name_prefix}-ecs-asg"
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.desired
  max_size            = var.max
  min_size            = 1
  health_check_type   = "EC2"

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  # Zero-downtime infra upgrade
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 60
      skip_matching          = true
    }
  }

  lifecycle { 
    create_before_destroy = true 
  }
  
  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-ecs-host"
    propagate_at_launch = true
  }
}

# Capacity provider & attach to cluster
resource "aws_ecs_capacity_provider" "cp" {
  name = "${var.name_prefix}-cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn     = aws_autoscaling_group.asg.arn
    managed_termination_protection = "DISABLED"
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 80
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "attach" {
  cluster_name       = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.cp.name]
  
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.cp.name
    weight            = 1
  }
}
