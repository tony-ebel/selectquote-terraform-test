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
# EC2 #
#######

resource "aws_instance" "internal" {
  count = var.instance_count

  instance_type        = var.instance_type
  ami                  = data.aws_ami.flatcar.image_id
  user_data            = data.ct_config.internal.rendered
  iam_instance_profile = aws_iam_instance_profile.internal.name
  key_name             = aws_key_pair.ssh.key_name

  associate_public_ip_address = false
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.internal.id]

  tags = {
    Name = "internal-${count.index}"
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

  cidr_ipv4   = var.vpc_cidr
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}
