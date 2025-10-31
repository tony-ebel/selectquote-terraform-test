#######
# ALB #
#######

resource "aws_lb" "alb_web" {
  name = "alb-web"

  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_web.id]
}

resource "aws_lb_target_group" "tg_web" {
  name = "tg-web"

  port        = var.web_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb_web.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_web.arn
  }
}


##################
# Security Group #
##################

resource "aws_security_group" "alb_web" {
  name        = "alb-web"
  description = "Allow ingress/egress on alb-web"
  vpc_id      = var.vpc_id

  tags = {
    Name = "alb-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb_web.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_security_group_rule" "web_egress" {
  security_group_id = aws_security_group.alb_web.id

  type        = "egress"
  protocol    = "tcp"
  from_port   = var.web_port
  to_port     = var.web_port
  description = "Allow HTTP to web sg"

  source_security_group_id = var.web_sg_id
}
