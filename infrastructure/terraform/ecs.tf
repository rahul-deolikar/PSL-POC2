# ECR Repositories
resource "aws_ecr_repository" "app_repos" {
  count = length(var.ecr_repositories)
  name  = var.ecr_repositories[count.index]

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.ecr_repositories[count.index]
    Environment = var.environment
    Project     = var.project_name
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "poc3_cluster" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "poc3_capacity_providers" {
  cluster_name = aws_ecs_cluster.poc3_cluster.name

  capacity_providers = compact([
    var.enable_fargate ? "FARGATE" : null,
    var.enable_fargate ? "FARGATE_SPOT" : null,
    var.enable_ec2 ? aws_ecs_capacity_provider.ec2_capacity_provider[0].name : null
  ])

  default_capacity_provider_strategy {
    base              = var.enable_fargate ? 1 : 0
    weight            = var.enable_fargate ? 100 : 0
    capacity_provider = var.enable_fargate ? "FARGATE" : aws_ecs_capacity_provider.ec2_capacity_provider[0].name
  }
}

# Launch Template for EC2 instances
resource "aws_launch_template" "ecs_launch_template" {
  count = var.enable_ec2 ? 1 : 0
  
  name_prefix   = "${var.project_name}-ecs-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile[0].name
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = aws_ecs_cluster.poc3_cluster.name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-ecs-instance"
      Environment = var.environment
      Project     = var.project_name
    }
  }
}

# Auto Scaling Group for ECS EC2 instances
resource "aws_autoscaling_group" "ecs_asg" {
  count = var.enable_ec2 ? 1 : 0
  
  name                = "${var.project_name}-ecs-asg"
  vpc_zone_identifier = aws_subnet.private_subnets[*].id
  min_size            = var.min_capacity
  max_size            = var.max_capacity
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_launch_template[0].id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ecs-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# ECS Capacity Provider for EC2
resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  count = var.enable_ec2 ? 1 : 0
  
  name = "${var.project_name}-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg[0].arn

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity          = 80
    }

    managed_termination_protection = "DISABLED"
  }

  tags = {
    Name        = "${var.project_name}-ec2-capacity-provider"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Data source for ECS optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# Application Load Balancer
resource "aws_lb" "poc3_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Target Groups for each application
resource "aws_lb_target_group" "app_tg" {
  count    = length(var.ecr_repositories)
  name     = "${replace(var.ecr_repositories[count.index], "_", "-")}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.poc3_vpc.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.ecr_repositories[count.index]}-tg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ALB Listener
resource "aws_lb_listener" "poc3_listener" {
  load_balancer_arn = aws_lb.poc3_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[0].arn
  }
}