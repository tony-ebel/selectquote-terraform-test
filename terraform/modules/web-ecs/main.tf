###############
# ECS Cluster #
###############

resource "aws_ecs_cluster" "web" {
  name = "web-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


#######
# IAM #
#######

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution"

  assume_role_policy = jsonencode ({
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
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


##############
# CloudWatch #
##############

resource "aws_cloudwatch_log_group" "web_container" {
  name              = "/ecs/web-container"
  retention_in_days = 7
}


###################
# Task Definition #
###################

resource "aws_ecs_task_definition" "web" {
  family                = "web-task"
  cpu                   = "256"
  memory                = "512"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "web-container"
      image     = var.rocket_league_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.web_container.name
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


###############
# ECS Service #
###############

resource "aws_ecs_service" "web" {
  name = "web-service"

  cluster         = aws_ecs_cluster.web.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = var.ecs_container_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution
  ]
}


###################
# Security Groups #
###################

resource "aws_security_group" "web" {
  name        = "ecs-web"
  description = "Allow ingress/egress between web ECS containers"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web-http" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "web-https" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = var.vpc_cidr
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "internal_egress" {
  security_group_id = aws_security_group.web.id

  type        = "egress"
  protocol    = "tcp"
  from_port   = var.internal_port
  to_port     = var.internal_port
  description = "Allow HTTP to internal sg"

  source_security_group_id = var.internal_sg_id
}
