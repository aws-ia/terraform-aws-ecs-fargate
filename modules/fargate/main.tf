######
# Collect data
######

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}_vpc"]
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
filter {
    name   = "tag:Name"
    values = ["${var.name}_public_subnets"] 
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
filter {
    name   = "tag:Name"
    values = ["${var.name}_private_subnets_A"] 
  }
}

resource "aws_iam_role" "ECSTaskExecutionRole" {
  name = var.name

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
    Environment = "aws-quickstarts-fargate"
  }
}

# ######
# # Security Groups
# ######
resource "aws_security_group" "fargate_container_sg" {
  description = "Allow access to the public facing load balancer"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "Ingress from the public ALB"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-quickstarts-fargate-container-sg"
  }
}

######
# ECS
######

resource "aws_ecs_cluster" "ECS_Fargate" {
  name = var.name
}

resource "aws_ecs_task_definition" "ECS_task" {
  family = var.ServiceName
  cpu = var.ContainerCpu
  memory =var.ContainerMemory
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ECSTaskExecutionRole.arn


  container_definitions = jsonencode(
[
  {
    "cpu": var.ContainerCpu,
    "image": var.ImageUrl,
    "memory": var.ContainerMemory,
    "name": var.ServiceName
    "portMappings": [
      {
        "containerPort": var.ContainerPort,
      }
    ]
  }
])
}

resource "aws_ecs_service" "ECS_service" {
 depends_on = [aws_lb.public]
  name          = var.name
  cluster       = aws_ecs_cluster.ECS_Fargate.id
  launch_type = "FARGATE"
  deployment_maximum_percent = "200"
  deployment_minimum_healthy_percent  = "75"
  desired_count = var.DesiredCount
  network_configuration {
      subnets = data.aws_subnet_ids.private.ids
      security_groups = [aws_security_group.fargate_container_sg.id]
  }
  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.ECS_task.family}:${max(aws_ecs_task_definition.ECS_task.revision, aws_ecs_task_definition.ECS_task.revision)}"

load_balancer {
    target_group_arn = aws_lb_target_group.target_group_public.arn
    container_name   = var.ServiceName
    container_port   = var.ContainerPort
  }
}

######
# Set up public load balancer
######
resource "aws_security_group" "public_lb_access" {
  description = "Allow access to the public facing load balancer"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "allow public access to fargate ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-quickstarts-fargate"
  }
}

resource "aws_lb" "public" {
  name               = "${var.name}-pub-lb"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = "30"
  security_groups    = [aws_security_group.public_lb_access.id]
  subnets            = data.aws_subnet_ids.public.ids
  tags = {
    Environment = "aws-quickstarts-fargate"
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
  priority     = var.Priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_public.arn
  }

  condition {
    path_pattern {
      values = [var.Path]
    }
  }
}

######
# Set up private load balancer
###### 

resource "aws_security_group" "private_lb_access" {
  description = "Only accept traffic from a container in the fargate container security group"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "allow private access to fargate ECS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.fargate_container_sg.id]
  }
 egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-quickstarts-fargate"
  }
}

resource "aws_lb" "private" {
  name               = "${var.name}-pri-lb"
  internal           = true
  load_balancer_type = "application"
  idle_timeout       = "30"
  security_groups    = [aws_security_group.private_lb_access.id]
  subnets            = data.aws_subnet_ids.private.ids
  tags = {
    Environment = "aws-quickstarts-fargate"
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
  priority     = var.Priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_private.arn
  }

  condition {
    path_pattern {
      values = [var.Path]
    }
  }
}

######
# Route traffic to the containers via traffic groups
######

resource "aws_lb_target_group" "target_group_public" {
  name        = "${var.name}-pub-tg"
  port        = var.ContainerPort
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
      path = "/"
      protocol    = "HTTP"
      port        = var.ContainerPort
      timeout = "5"
      healthy_threshold = "2"
      interval ="6"
  }
  vpc_id      = data.aws_vpc.vpc.id
  
}

resource "aws_lb_target_group" "target_group_private" {
  name        = "${var.name}-pri-tg"
  port        = var.ContainerPort
  protocol    = "HTTP"
  target_type = "ip"
  health_check {
      path = "/"
      protocol    = "HTTP"
      port        = var.ContainerPort
      timeout = "5"
      healthy_threshold = "2"
      interval ="6"
  }
  vpc_id      = data.aws_vpc.vpc.id
  
}