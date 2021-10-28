terraform {
  required_version = ">= 1.0.0"
}

###############
# Collect data
###############

resource "random_string" "rand4" {
  length  = 4
  special = false
  upper   = false
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet_ids" "public" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["${var.network_tag}_ecs_public_subnet"]

  }
}

data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["${var.network_tag}_ecs_private_subnet"]
  }
}

resource "aws_iam_role" "ECSTaskExecutionRole" {
  name_prefix = var.name_prefix

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Environment = "aws-ia-fargate"
  }
}

# ######
# # Security Groups
# ######
resource "aws_security_group" "fargate_container_sg" {
  description = "Allow access to the public facing load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Ingress from the public ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.remote_cidr_blocks

  }
  ingress {
    description = "Ingress from the private ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

  }
  ingress {
    description = "Ingress from other containers in the same security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.remote_cidr_blocks
  }

  tags = {
    Name = "fargate-container-sg"
  }
}

######
# ECS
######

resource "aws_ecs_cluster" "ecs_fargate" {
  name = "${var.name_prefix}-${random_string.rand4.result}"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.service_name
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ECSTaskExecutionRole.arn


  container_definitions = jsonencode(
    [
      {
        "cpu" : var.container_cpu,
        "image" : var.image_url,
        "memory" : var.container_memory,
        "name" : var.service_name
        "portMappings" : [
          {
            "containerPort" : var.container_port,
          }
        ]
      }
  ])
}

resource "aws_ecs_service" "ecs_service" {
  depends_on                         = [aws_lb.public]
  name                               = "${var.name_prefix}-${random_string.rand4.result}"
  cluster                            = aws_ecs_cluster.ecs_fargate.id
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "75"
  desired_count                      = var.desired_count
  network_configuration {
    subnets         = data.aws_subnet_ids.private.ids
    security_groups = [aws_security_group.fargate_container_sg.id]
  }
  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.ecs_task.family}:${max(aws_ecs_task_definition.ecs_task.revision, aws_ecs_task_definition.ecs_task.revision)}"

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_public.arn
    container_name   = var.service_name
    container_port   = var.container_port
  }
}

######
# Set up public load balancer
######
resource "aws_security_group" "public_lb_access" {
  description = "Allow access to the public facing load balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "allow public access to fargate ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.remote_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.remote_cidr_blocks
  }

  tags = {
    Name = "aws-ias-fargate"
  }
}

resource "aws_lb" "public" {
  name_prefix        = var.name_prefix
  internal           = !var.lb_public_access
  load_balancer_type = "application"
  idle_timeout       = "30"
  security_groups    = [aws_security_group.public_lb_access.id]
  subnets            = data.aws_subnet_ids.public.ids
  tags = {
    Environment = "aws-ias-fargate"
  }
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_public.arn
  }
}

resource "aws_lb_listener_rule" "public" {
  listener_arn = aws_lb_listener.public_listener.arn
  priority     = var.routing_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_public.arn
  }

  condition {
    path_pattern {
      values = [var.lb_path]
    }
  }
}

######
# Set up private load balancer
######

resource "aws_security_group" "private_lb_access" {
  description = "Only accept traffic from a container in the fargate container security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "allow private access to fargate ECS"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.fargate_container_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.remote_cidr_blocks
  }

  tags = {
    Name = "aws-ias-fargate"
  }
}

resource "aws_lb" "private" {
  name_prefix        = var.name_prefix
  internal           = true
  load_balancer_type = "application"
  idle_timeout       = "30"
  security_groups    = [aws_security_group.private_lb_access.id]
  subnets            = data.aws_subnet_ids.private.ids
  tags = {
    Environment = "aws-ias-fargate"
  }
}
resource "aws_lb_listener" "private_listener" {
  load_balancer_arn = aws_lb.private.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_private.arn
  }
}

resource "aws_lb_listener_rule" "private" {
  listener_arn = aws_lb_listener.private_listener.arn
  priority     = var.routing_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_private.arn
  }

  condition {
    path_pattern {
      values = [var.lb_path]
    }
  }
}

######
# Route traffic to the containers via traffic groups
######

resource "aws_lb_target_group" "target_group_public" {
  name_prefix = var.name_prefix
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path              = "/"
    protocol          = "HTTP"
    port              = var.container_port
    timeout           = "5"
    healthy_threshold = "2"
    interval          = "6"
  }
  vpc_id = var.vpc_id
}

resource "aws_lb_target_group" "target_group_private" {
  name_prefix = var.name_prefix
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
    path              = "/"
    protocol          = "HTTP"
    port              = var.container_port
    timeout           = "5"
    healthy_threshold = "2"
    interval          = "6"
  }
  vpc_id = var.vpc_id
}