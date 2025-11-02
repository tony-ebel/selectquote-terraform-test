#######
# AMI #
#######

data "aws_ami" "flatcar" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["Flatcar-stable-*"]
  }
}


############
# SSH Keys #
############

resource "aws_key_pair" "ssh" {
  key_name   = "main-ssh"
  public_key = var.ssh_public_key
}


#######
# IAM #
#######

resource "aws_iam_role" "internal" {
  name = "internal-ec2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "internal-ec2"
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.internal.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.internal.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "internal" {
  name = "internal-profile"
  role = aws_iam_role.internal.name
}


#############
# User Data #
#############

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "ct_config" "internal" {
  content      = data.template_file.internal.rendered
  strict       = true
  pretty_print = true
}

data "template_file" "internal" {
  template = file("${path.module}/userdata/internal.tftpl")

  vars = {
    IMAGE          = var.rocket_league_image
    ENVIRONMENT    = "prod"
    AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    REGION         = data.aws_region.current.region
  }
}


#######
# ASG #
#######

resource "aws_launch_template" "internal" {
  name_prefix   = "internal-"
  image_id      = data.aws_ami.flatcar.image_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh.key_name
  user_data     = base64encode(data.ct_config.internal.rendered)

  vpc_security_group_ids      = [aws_security_group.internal.id]

  network_interfaces {
    associate_public_ip_address = false
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "internal"
    }
  }
}

resource "aws_autoscaling_group" "internal" {
  name = "internal-asg"

  max_size            = var.instance_count
  min_size            = var.instance_count
  desired_capacity    = var.instance_count
  vpc_zone_identifier = [var.private_subnet_id]

  launch_template {
    id      = aws_launch_template.internal.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "internal"
    propagate_at_launch = true
  }
}


##################
# Security Group #
##################

resource "aws_security_group" "internal" {
  name        = "internal-sg"
  description = "SG for internal ec2 instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "internal-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.internal.id

  cidr_ipv4   = var.vpc_cidr
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "web_ingress" {
  security_group_id = aws_security_group.internal.id

  type        = "ingress"
  protocol    = "tcp"
  from_port   = var.port
  to_port     = var.port
  description = "Allow HTTP from web sg"

  source_security_group_id = var.web_sg_id
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.internal.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}
